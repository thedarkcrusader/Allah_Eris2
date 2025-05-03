/*
It's like a regular ol' straight pipe, but you can turn it on and off.
*/

/obj/machinery/atmospherics/components/binary/valve
	icon_state = "mvalve_map-3"

	name = "manual valve"
	desc = "A pipe with a valve that can be used to disable flow of gas through it."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_OPEN //Intentionally no allow_silicon flag
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	custom_reconcilation = TRUE

	var/frequency = 0
	var/id = null

	var/valve_type = "m" //lets us have a nice, clean, OOP update_icon_nopipes()

	construction_type = /obj/item/pipe/binary
	pipe_state = "mvalve"

	var/switching = FALSE


/obj/machinery/atmospherics/components/binary/valve/Destroy()
	//Should only happen on extreme circumstances
	if(on)
		//Let's give presumably now-severed pipenets a chance to scramble for what's happening at next SSair fire()
		if(parents[1])
			parents[1].update = PIPENET_UPDATE_STATUS_RECONCILE_NEEDED
		if(parents[2])
			parents[2].update = PIPENET_UPDATE_STATUS_RECONCILE_NEEDED
	. = ..()

// This is what handles the actual functionality of combining 2 pipenets when the valve is open
// Basically when a pipenet updates it will consider both sides to be the same for the purpose of the gas update
/obj/machinery/atmospherics/components/binary/valve/return_pipenets_for_reconcilation(datum/pipeline/requester)
	. = ..()
	if(!on)
		return
	. |= parents[1]
	. |= parents[2]

/obj/machinery/atmospherics/components/binary/valve/update_icon_nopipes(animation = FALSE)
	normalize_cardinal_directions()
	if(animation)
		flick("[valve_type]valve_[on][!on]-[set_overlay_offset(piping_layer)]", src)
	icon_state = "[valve_type]valve_[on ? "on" : "off"]-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/valve/proc/toggle()
	if(on)
		on = FALSE
		update_icon_nopipes()
		investigate_log("was closed by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
		investigate_log("was closed by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_SUPERMATTER)  // yogs - Makes supermatter invest useful
	else
		on = TRUE
		update_icon_nopipes()
		update_parents()
		var/datum/pipeline/parent1 = parents[1]
		parent1.reconcile_air()
		investigate_log("was opened by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
		investigate_log("was opened by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_SUPERMATTER) // yogs - Makes supermatter invest useful

/obj/machinery/atmospherics/components/binary/valve/interact(mob/user)
	add_fingerprint(usr)
	if(switching)
		return
	update_icon_nopipes(TRUE)
	switching = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_interact)), 10)

/obj/machinery/atmospherics/components/binary/valve/proc/finish_interact()
	toggle()
	switching = FALSE


/obj/machinery/atmospherics/components/binary/valve/digital // can be controlled by AI
	icon_state = "dvalve_map-3"

	name = "digital valve"
	desc = "A digitally controlled valve."
	valve_type = "d"
	pipe_state = "dvalve"

	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_OPEN | INTERACT_MACHINE_OPEN_SILICON

/obj/machinery/atmospherics/components/binary/valve/digital/update_icon_nopipes(animation)
	if(!is_operational())
		normalize_cardinal_directions()
		icon_state = "dvalve_nopower-[set_overlay_offset(piping_layer)]"
		return
	..()


/obj/machinery/atmospherics/components/binary/valve/layer2
	piping_layer = 2
	icon_state = "mvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/layer4
	piping_layer = 4
	icon_state = "mvalve_map-4"

/obj/machinery/atmospherics/components/binary/valve/on
	on = TRUE

/obj/machinery/atmospherics/components/binary/valve/on/layer2
	piping_layer = 2
	icon_state = "mvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/on/layer4
	piping_layer = 4
	icon_state = "mvalve_map-4"

/obj/machinery/atmospherics/components/binary/valve/digital/layer2
	piping_layer = 2
	icon_state = "dvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/digital/layer4
	piping_layer = 4
	icon_state = "dvalve_map-4"

/obj/machinery/atmospherics/components/binary/valve/digital/on
	on = TRUE

/obj/machinery/atmospherics/components/binary/valve/digital/on/layer2
	piping_layer = 2
	icon_state = "dvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/digital/on/layer4
	piping_layer = 4
	icon_state = "dvalve_map-4"
