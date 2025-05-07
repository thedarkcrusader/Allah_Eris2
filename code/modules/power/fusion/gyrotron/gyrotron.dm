#define GYRO_POWER 25000

/obj/machinery/power/emitter/gyrotron
	name = "gyrotron"
	icon = 'icons/obj/machines/power/gyrotron.dmi'
	desc = "A heavy-duty, highly configurable industrial gyrotron suited for powering fusion reactors."
	icon_state = "emitter"
	req_lock_access = list(access_engine)
	use_power = POWER_USE_IDLE
	active_power_usage = GYRO_POWER

	var/initial_id_tag
	var/rate = 3
	var/mega_energy = 1

	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = list(
		/obj/item/stock_parts/radio/receiver,
	)
	stat_immune = 0
	base_type = /obj/machinery/power/emitter/gyrotron

/obj/machinery/power/emitter/gyrotron/anchored
	anchored = TRUE
	state = EMITTER_WELDED

/obj/machinery/power/emitter/gyrotron/Initialize()
	set_extension(src, /datum/extension/local_network_member)
	if(initial_id_tag)
		var/datum/extension/local_network_member/fusion = get_extension(src, /datum/extension/local_network_member)
		fusion.set_tag(null, initial_id_tag)
	change_power_consumption(mega_energy * GYRO_POWER, POWER_USE_ACTIVE)
	. = ..()

/obj/machinery/power/emitter/gyrotron/Process()
	change_power_consumption(mega_energy * GYRO_POWER, POWER_USE_ACTIVE)
	. = ..()

/obj/machinery/power/emitter/gyrotron/get_rand_burst_delay()
	return rate * 10

/obj/machinery/power/emitter/gyrotron/get_burst_delay()
	return rate * 10

/obj/machinery/power/emitter/gyrotron/get_emitter_damage()
	return mega_energy * 50

/obj/machinery/power/emitter/gyrotron/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if (active && powernet && avail(active_power_usage))
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")

/obj/machinery/power/emitter/gyrotron/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isMultitool(W))
		var/datum/extension/local_network_member/fusion = get_extension(src, /datum/extension/local_network_member)
		fusion.get_new_tag(user)
		return TRUE
	return ..()

#undef GYRO_POWER
