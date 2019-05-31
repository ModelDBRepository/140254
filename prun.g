/**
 * This model implements a morphologically extended version of the fast-spiking
 * neuron by Golomb et al.
 * Conductances were taken from:
 *      Golomb, Donner, Shacham, Shlosberg, Amitai Y, et al. (2007)
 *      Mechanisms of Firing Patterns in Fast-Spiking Cortical Interneurons.
 *      PLoS Comput Biol 3(8): e156. doi:10.1371/journal.pcbi.0030156.
 */

paron -parallel

/* Simulation time and other simulation parameters. */
float T = 4.0

/* Print some info. */
if ({mynode} == 0)
    echo "*****************************************************************************"
    echo "Number of nodes: "{nnodes}
    echo "T      = "{T}" sec"
    echo "*****************************************************************************"
end

float spikeoutdt = 1e-3
float vmoutdt    = 1e-4
float simdt      = 1e-5
int   spikesteps = {T / simdt}

include protodefs
include protocols
include utils

setrand -sprng
randseed

/* Set the clocks. */
setclock 2 {1.0e-4}
setclock 1 {vmoutdt}
setclock 0 {simdt}

/**************************************************************************
 * Model configuration
 **************************************************************************/

/* Flags for electrical coupling [GJ = 1 (soma), 2 (primary dendrites), or
 * 3 (secondary dendrites)], current injection from file (CI = 1) and
 * synaptic input from file (SI = 1).                                     */
int GJ = 0
int CI = 1
int SI = 0

int n
float GJcond = 0.5e-9

/* Read the cell description and create a second FS model neuron. */
readcell fsn_soma_dend.p /fsn[{mynode}]

/* Current step injection into one of the FS cells if mynode==0 or 1. */
if ({mynode} == -1)
	create pulsegen /pulse_inj
	setfield /pulse_inj level1 50.0e-12 delay1 0.5 width1 2.0 level2 0.0 delay2 0.0 width2 100.0 \
        	            baselevel 0.0 trig_mode 0
	raddmsg /pulse_inj /fsn[0]/soma INJECT output
end

/* Compartment name. */
str pchan

/* Scale channel density. */
float scale_AMPA = 500
float scale_GABA = 1.0 * {scale_AMPA}

/* Scale AMPA channel conductances. */
foreach pchan ({el /fsn[{mynode}]/##[TYPE=synchan]})
	if ({strcmp {getpath {pchan} -tail} "AMPA_channel"} == 0)
		setfield {pchan} gmax {{scale_AMPA} * {getfield {pchan} gmax}}
	end
end

/* Scale GABA channel conductances. */
foreach pchan ({el /fsn[{mynode}]/##[TYPE=synchan]})
	if ({strcmp {getpath {pchan} -tail} "GABA_channel"} == 0)
		setfield {pchan} gmax {{scale_GABA} * {getfield {pchan} gmax}}
	end
end

/* Create current injection from file ./input/fsn<N>_istim.dat, where N is the cell number (N=0,1). */
if (CI == 1)
	echo "Current injection (read from file) ..."
	create disk_in /in[{mynode}]
	setfield /in[{mynode}] nx 1 ny 1 filename "./input/fsn"{mynode}"_istim.dat" leave_open 1 fileformat 0
	echo {getfield /in[{mynode}] filename}
	useclock /in[{mynode}] 2
	raddmsg  /in[{mynode}] /fsn[{mynode}]/soma INJECT val[0][0]
end


/* Synaptic input. */
if (SI == 1)

	/* Read synaptic input times from files. */
	if (!{exists /input})
		create neutral /input
	end

	str ttpath
	str sgpath

	echo "Include AMPA synapses (FS "{mynode}") ..."
	str chan = "ampa"
	
	if (!{exists /input/fsn[{mynode}]})
		create neutral /input/fsn[{mynode}]
	end
        
        /* Read the spike trains for each AMPA channel. */
	int j = 0
    	foreach pchan ({el /fsn[{mynode}]/##[TYPE=synchan]})
    	    if ({strcmp {getpath {pchan} -tail} "AMPA_channel"} == 0)
    	    
    	        /* Create the timetable and fill it with values from file. */
				ttpath = "/input/fsn["@{mynode}@"]/tt_"@{chan}@"["@{j}@"]"
				create timetable {ttpath}
				setfield {ttpath} maxtime {T}  method 4  act_val 1.0 \
	                          fname "./input/"{chan}"/fsn"{mynode}"_"{chan}{j}".dat"
	        	call {ttpath} TABFILL
		        
	        	/* Create the spike generator. */
	        	sgpath = "/input/fsn["@{mynode}@"]/sg_"@{chan}@"["@{j}@"]"
	        	
	        	create spikegen {sgpath}
	        	setfield {sgpath} output_amp 1 thresh 0.5 abs_refract 0.0001
		        
	        	/* Connect timetable with spike generator. */
	        	raddmsg {ttpath} {sgpath} INPUT activation
			
			j = j + 1
    	    end
    	end
    	
    	/* Connect AMPA. */
	j = 0
    	foreach pchan ({el /fsn[{mynode}]/##[TYPE=synchan]})
    	    /* Connect spike trains to AMPA. */
    	    if ({strcmp {getpath {pchan} -tail} "AMPA_channel"} == 0)
    	    	sgpath = "/input/fsn["@{mynode}@"]/sg_"@{chan}@"["@{j}@"]"
	        	raddmsg {sgpath} {pchan} SPIKE
		j = j + 1
    	    end
    	end
    	
	echo "Include GABA synapses (FS "{mynode}") ..."
	chan = "gaba"
    	if (!{exists /input/fsn[{mynode}]})
			create neutral /input/fsn[{mynode}]
        end
        
        /* Read the spike trains for each GABA channel. */
	j = 0
    	foreach pchan ({el /fsn[{mynode}]/##[TYPE=synchan]})
    	    if ({strcmp {getpath {pchan} -tail} "GABA_channel"} == 0)
    	    
    	        /* Create the timetable and fill it with values from file. */
				ttpath = "/input/fsn["@{mynode}@"]/tt_"@{chan}@"["@{j}@"]"
				create timetable {ttpath}
				//echo {mynode}" - "{ttpath}
				setfield {ttpath} maxtime {T}  method 4  act_val 1.0 \
	                          fname "./input/"{chan}"/fsn"{mynode}"_"{chan}{j}".dat"
	        	call {ttpath} TABFILL
				
	        	/* Create the spike generator. */
	        	sgpath = "/input/fsn["@{mynode}@"]/sg_"@{chan}@"["@{j}@"]"
	        	//echo "Create "{sgpath}
	        	
	        	create spikegen {sgpath}
	        	setfield {sgpath} output_amp 1 thresh 0.5 abs_refract 0.0001
		        
	        	/* Connect timetable with spike generator. */
	        	raddmsg {ttpath} {sgpath} INPUT activation

			j = j + 1
    	    end
    	end
    	
    	/* Connect GABA. */
	j = 0
    	foreach pchan ({el /fsn[{mynode}]/##[TYPE=synchan]})
    	    if ({strcmp {getpath {pchan} -tail} "GABA_channel"} == 0)
    	    	sgpath = "/input/fsn["@{mynode}@"]/sg_"@{chan}@"["@{j}@"]"
	        	addmsg {sgpath} {pchan} SPIKE
		j = j + 1
    	    end
    	end
end

/* Create output. */
create asc_file /output/plot[{mynode}]
setfield /output/plot[{mynode}] filename "./output/fsn"{mynode}".dat"
echo {getfield /output/plot[{mynode}] filename}
useclock /output/plot[{mynode}] 1
raddmsg /fsn[{mynode}]/soma /output/plot[{mynode}] SAVE Vm
    
/* Connect via gap junction. */
if (GJ == 1)
	if ({mynode} == 0)
		echo "Electrical coupling (somatic)."
		raddmsg     /fsn[0]/soma /fsn[1]/soma@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/soma /fsn[0]/soma@{0}     RAXIAL {1.0/{GJcond}} Vm
	end
end

if (GJ == 2)
	if ({mynode} == 0)
		echo "Electrical coupling (proximal dendrites)."
		raddmsg     /fsn[0]/primdend1/prim_dend2 /fsn[1]/primdend1/prim_dend2@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/primdend1/prim_dend2 /fsn[0]/primdend1/prim_dend2@{0} RAXIAL {1.0/{GJcond}} Vm
    
		raddmsg     /fsn[0]/primdend2/prim_dend2 /fsn[1]/primdend2/prim_dend2@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/primdend2/prim_dend2 /fsn[0]/primdend2/prim_dend2@{0} RAXIAL {1.0/{GJcond}} Vm
	end
end

if (GJ == 3)
	if ({mynode} == 0)
		echo "Electrical coupling (secondary dendrites)."
		raddmsg     /fsn[0]/secdend1/sec_dend4 /fsn[1]/secdend1/sec_dend4@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/secdend1/sec_dend4 /fsn[0]/secdend1/sec_dend4@{0} RAXIAL {1.0/{GJcond}} Vm
		raddmsg     /fsn[0]/secdend2/sec_dend4 /fsn[1]/secdend2/sec_dend4@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/secdend2/sec_dend4 /fsn[0]/secdend2/sec_dend4@{0} RAXIAL {1.0/{GJcond}} Vm
    
		raddmsg     /fsn[0]/secdend3/sec_dend4 /fsn[1]/secdend3/sec_dend4@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/secdend3/sec_dend4 /fsn[0]/secdend3/sec_dend4@{0} RAXIAL {1.0/{GJcond}} Vm
		raddmsg     /fsn[0]/secdend4/sec_dend4 /fsn[1]/secdend4/sec_dend4@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/secdend4/sec_dend4 /fsn[0]/secdend4/sec_dend4@{0} RAXIAL {1.0/{GJcond}} Vm
		
		raddmsg     /fsn[0]/secdend5/sec_dend4 /fsn[1]/secdend5/sec_dend4@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/secdend5/sec_dend4 /fsn[0]/secdend5/sec_dend4@{0} RAXIAL {1.0/{GJcond}} Vm
		raddmsg     /fsn[0]/secdend6/sec_dend4 /fsn[1]/secdend6/sec_dend4@{1} RAXIAL {1.0/{GJcond}} Vm
		raddmsg@{1} /fsn[1]/secdend6/sec_dend4 /fsn[0]/secdend6/sec_dend4@{0} RAXIAL {1.0/{GJcond}} Vm
	end
end

check
reset
reset

setVrest /fsn[{mynode}]

/* Run the simulation. */
barrier
step {spikesteps}

/* Exit ... */
barrier
paroff
quit

