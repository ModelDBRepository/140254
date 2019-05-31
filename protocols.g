/**
 * This methods runs the simulation for the time specified by 'duration' (in seconds).
 *
 */
function runCurrentInj(duration)
	float duration
	
	check
    reset
    reset
    step {{duration} / {getclock 0}}
end

function createOutput(protocolname, channel0, channel1)
	
	/* Create a temporary directory if not existent. */
    if ({exists /tmp} != 1)
        create neutral /tmp
    end
    
    /* Channel 0: current steps. */
    create asc_file /tmp/plotIVchan0
    setfield /tmp/plotIVchan0 filename "./output/"{protocolname}"_ch"{channel0}".dat"
    useclock /tmp/plotIVchan0 1

    /* Channel 1: voltage responses. */
    create asc_file /tmp/plotIVchan1
    setfield /tmp/plotIVchan1 filename "./output/"{protocolname}"_ch"{channel1}".dat"
    useclock /tmp/plotIVchan1 1
end

/**
 * Delete the temporary output elements.
 */
function deleteOutput
	delete /tmp/plotIVchan0
    delete /tmp/plotIVchan1
end


/**
 * ...
 */
function currentInj(comppath, path, level, scale, delay, duration)
    str comppath
    str path
    float level
    float scale
    float delay
    float duration
    
    if ({exists {path}} == 1)
        return
    end
    create pulsegen {path}
    setfield {path} level1 {{scale} * {level}}  delay1 {delay}  width1 {duration} \
                    level2 0.0                  delay2     0.0  width2     3600.0 \
                    baselevel 0.0 trig_mode 0
    
    create neutral {path}/level
    setfield {path}/level x {level}
    
    addmsg {path} {comppath} INJECT output
end

/**
 * Starts at 100 pA and increases with 
 *
 */
function runTesteCode(cellpath, scale)
	str   cellpath
    float scale

	float level    = {scale} * 100.0e-12 // Scale the default value of 100 pA.
	float stepsize = {level} *   0.2     // The step size is one-fifth.

    createOutput "TesteCode" 0 1
    
    /* Create one copy for each step. */
    int n
    for (n = 0; n < 5; n = n + 1)
        echo "n = "{n}
        
        copy {cellpath} /tmp/neuron[{n}]
        
        currentInj /tmp/neuron[{n}]/soma /tmp/cinj[{n}] {level} 1.0 0.1 0.5
        level = {level} + {stepsize}
        echo "Level = "{level}
        
        addmsg /tmp/cinj[{n}]        /tmp/plotIVchan0 SAVE output
        addmsg /tmp/neuron[{n}]/soma /tmp/plotIVchan1 SAVE Vm
    end
    
    /* Run the protocol (0.7 s total). */
    runCurrentInj 0.7
    
    /* Clean-up. */
    for (n = 0; n < 5; n = n + 1)
        delete /tmp/neuron[{n}]
        delete /tmp/cinj[{n}]
        echo "Delete temporary elements (n = "{n}")"
    end
    
    deleteOutput
end

/**
 * This function runs short (50 ms) steps of high amplitude.
 * Steps are 400, 450, ..., 650, 700 pA
 * cellpath is the path to the cell in which current is injected somatically
 * maxlevel is the maximal current amplitude
 */
function runAPWaveform(cellpath, scale)
	str   cellpath
    float scale
    
    float level    = {scale} * 200.0e-12 // Scale the default value of 200 pA.
    float stepsize = {level} / 6.0       // The step size is one sixth.
    
    createOutput "APWaveform" 0 1
    
    /* Create one copy for each step. */
    int n
    for (n = 0; n < 11; n = n + 1)
        echo "n = "{n}
        
        copy {cellpath} /tmp/neuron[{n}]
        
        currentInj /tmp/neuron[{n}]/soma /tmp/cinj[{n}] {level} 1.0 0.005 0.05
        level = {level} + {stepsize}
        echo "Level = "{level}
        
        addmsg /tmp/cinj[{n}]        /tmp/plotIVchan0 SAVE output
        addmsg /tmp/neuron[{n}]/soma /tmp/plotIVchan1 SAVE Vm
    end
    
    
    runCurrentInj 0.08
    
    /* Clean-up. */
    for (n = 0; n < 11; n = n + 1)
        delete /tmp/neuron[{n}]
        delete /tmp/cinj[{n}]
    end
    
    deleteOutput
end

/**
 * ...
 */
function currentInjFixDur(comppath, path, level, scale)
    str comppath
    str path
    float level
    float scale
    
    if ({exists {path}} == 1)
        return
    end
    create pulsegen {path}
    setfield {path} level1 {{scale} * {level}} delay1 0.1 width1 1.0 level2 0.0 delay2 0.0 width2 100.0 baselevel 0.0 trig_mode 0
    
    create neutral {path}/level
    setfield {path}/level x {level}
    
    addmsg {path} {comppath} INJECT output
end

/**
 * Run different steps of somatic current injection (1 sec).
 * cellpath is the path to the cell in which current is injected somatically (e.g. /fsn[0])
 * level is the amount of current to be injected at 100%. Current steps are testet for -280..160%.
 */
function runIV(cellpath, level)
    str cellpath
    float level

    /* Create a temporary directory if not existent. */
    if ({exists /tmp} != 1)
        create neutral /tmp
    end
    
    /* Channel 0: current steps. */
    create asc_file /tmp/plotIVchan0
    setfield /tmp/plotIVchan0 filename "./output/IVchan0.dat"
    useclock /tmp/plotIVchan0 1

    /* Channel 1: voltage responses. */
    create asc_file /tmp/plotIVchan1
    setfield /tmp/plotIVchan1 filename "./output/IVchan1.dat"
    useclock /tmp/plotIVchan1 1

    /* Create one copy for each step. */
    int n
    for (n = 0; n < 12; n = n + 1)
        echo "n = "{n}
        copy {cellpath} /tmp/fsn[{n}]
        currentInjFixDur /tmp/fsn[{n}]/soma /tmp/cinj[{n}] {level} {{{n}/2.5}-2.8}
        addmsg /tmp/cinj[{n}]     /tmp/plotIVchan0 SAVE output
        addmsg /tmp/fsn[{n}]/soma /tmp/plotIVchan1 SAVE Vm
    end
    
    /* Run the protocol (1.2 sec total). */
    check
    reset
    reset
    step {1.2/{getclock 0}}

    /* Clean-up. */
    for (n = 0; n < 12; n = n + 1)
        delete /tmp/fsn[{n}]
        delete /tmp/cinj[{n}]
    end
    delete /tmp/plotIVchan0
    delete /tmp/plotIVchan1
end


function setInj(path, level1)
    str path
    float level1

    setfield {path}       level1 {level1}
    setfield {path}/level x      {level1}
end

function scaleInj(path, scale)
    str path
    float scale
    setfield {path} level1 {{scale} * {getfield {path}/level x}}
    echo "Level1: "{getfield {path} level1}
end

/**
 * Run different steps of somatic current injection to test the frequency
 * response of the neuron. The stimulus should evoke sub- and superthreshold
 * responses.
 */
function runIDrest(cellpath, level)
    str cellpath
    float level

    /* Create a temporary directory if not existent. */
    if ({exists /tmp} != 1)
        create neutral /tmp
    end
    
    /* Channel 0: current steps. */
    create asc_file /tmp/plotIVchan0
    setfield /tmp/plotIVchan0 filename "./output/IDrestchan0.dat"
    useclock /tmp/plotIVchan0 1

    /* Channel 1: voltage responses. */
    create asc_file /tmp/plotIVchan1
    setfield /tmp/plotIVchan1 filename "./output/IDrestchan1.dat"
    useclock /tmp/plotIVchan1 1

    int n
    for (n = 0; n <= 11; n = n + 1)
        copy {cellpath} /tmp/fsn[{n}]
        currentInjFixDur /tmp/fsn[{n}]/soma /tmp/cinj[{n}] {level} {{{n}/2.5} + 1.2}
        setfield /tmp/cinj[{n}] width1 2.0

        addmsg /tmp/cinj[{n}]     /tmp/plotIVchan0 SAVE output
        addmsg /tmp/fsn[{n}]/soma /tmp/plotIVchan1 SAVE Vm
    end

    /* Run the protocol (1.2 sec total). */
    check
    reset
    reset
    step {2.2/{getclock 0}}

    /* Clean-up. */
    for (n = 0; n <= 11; n = n + 1)
        delete /tmp/fsn[{n}]
        delete /tmp/cinj[{n}]
    end
    delete /tmp/plotIVchan0
    delete /tmp/plotIVchan1
end
