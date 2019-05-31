/**
 * This method calculates the somatic, dendritic, and total area of the
 * membrane surface.
 * 
 * path - The path to the cell.
 */
function printStatsArea(path)
	str path
	str comp
	
	float pi   = 3.14159
	float dia, len, area_soma = 0.0, area_total = 0.0
	
	/* Get the total membrane area. */
	area_total = 0.0
	foreach comp ({el {path}/##[TYPE=compartment]})
		dia = {getfield {comp} dia}
		len = {getfield {comp} len}
		area_total = {{area_total} + {{pi} * {dia} * {len}}}
		//echo {comp}" "{{pi} * {dia} * {len}}
	end

	dia = {getfield {path}/soma dia}
	len = {getfield {path}/soma len}
	area_soma = {{pi} * {dia} * {len}}

	echo "Membrane surface: "{area_total}" m^2"
	echo "A_s       = "{area_soma}
	echo "A_d       = "{ {area_total} - {area_soma}}
	echo "A_d / A_s = "{{{area_total} - {area_soma}} / {area_soma}}
end

/**
 * This function adjusts the resting potential so that the leak current is in a steady state.
 */
function setVrest(path)
	str   path
	str   comppath, chanpath
	float Em, Isum
	
	foreach comppath ({el {path}/##[TYPE=compartment]})
		
		Isum = 0.0
		foreach chanpath ({el {comppath}/##[TYPE=tabchannel]})
			Isum = {Isum} + {getfield {chanpath} Ik}
		end
    	Em = {{getfield {comppath} Vm} - {Isum} * {getfield {comppath} Rm}}
    	setfield {comppath} Em {Em}
	end
end
