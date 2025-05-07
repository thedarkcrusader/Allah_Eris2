// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/structures/buttons.dmi'
	icon_state = "light0"
	anchored = TRUE
	idle_power_usage = 20
	power_channel = LIGHT
	obj_flags = OBJ_FLAG_WALL_MOUNTED
	var/on = 0
	var/area/connected_area = null
	var/other_area = null

/obj/machinery/light_switch/Initialize()
	. = ..()
	if(other_area)
		src.connected_area = locate(other_area)
	else
		src.connected_area = get_area(src)

	if(name == initial(name))
		SetName("light switch ([connected_area.name])")

	connected_area.set_lightswitch(on)
	update_icon()

/obj/machinery/light_switch/on_update_icon()
	ClearOverlays()
	if(inoperable())
		icon_state = "light-p"
		set_light(0)
	else
		icon_state = "light[on]"
		var/color = on ? "#82ff4c" : "#f86060"
		AddOverlays(list(
			emissive_appearance(icon, "light[on]-overlay"),
			overlay_image(icon, "light[on]-overlay", color)
		))
		set_light(2, 0.25, color)

/obj/machinery/light_switch/examine(mob/user, distance)
	. = ..()
	if(distance)
		to_chat(user, "A light switch. It is [on? "on" : "off"].")

/obj/machinery/light_switch/proc/set_state(newstate)
	if(on != newstate)
		on = newstate
		connected_area.set_lightswitch(on)
		update_icon()

/obj/machinery/light_switch/proc/sync_state()
	if(connected_area && on != connected_area.lightswitch)
		on = connected_area.lightswitch
		update_icon()
		return 1

/obj/machinery/light_switch/interface_interact(mob/user)
	if(CanInteract(user, DefaultTopicState()))
		playsound(src, "switch", 30)
		set_state(!on)
		return TRUE

/obj/machinery/light_switch/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if (isScrewdriver(tool))
		var/obj/item/frame/light_switch/frame = new /obj/item/frame/light_switch(user.loc, 1)
		transfer_fingerprints_to(frame)
		qdel(src)
		return TRUE
	return ..()


/obj/machinery/light_switch/powered()
	. = ..(power_channel, connected_area) //tie our powered status to the connected area

/obj/machinery/light_switch/power_change()
	. = ..()
	//synch ourselves to the new state
	if(connected_area) //If an APC initializes before we do it will force a power_change() before we can get our connected area
		sync_state()

/obj/machinery/light_switch/emp_act(severity)
	if(inoperable())
		..(severity)
		return
	power_change()
	..(severity)
