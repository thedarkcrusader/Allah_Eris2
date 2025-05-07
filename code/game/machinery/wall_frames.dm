/obj/item/frame
	name = "frame"
	desc = "Used for building machines."
	icon = 'icons/obj/machines/frames.dmi'
	icon_state = "alarm_bitem"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	var/build_machine_type
	var/refund_amt = 2
	var/refund_type = /obj/item/stack/material/steel
	var/reverse = 0 //if resulting object faces opposite its dir (like light fixtures)

/obj/item/frame/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(isWrench(W))
		new refund_type( get_turf(src.loc), refund_amt)
		qdel(src)
		return TRUE
	return ..()

/obj/item/frame/proc/try_build(turf/on_wall)
	if(!build_machine_type)
		return

	if (get_dist(on_wall,usr)>1)
		return

	var/ndir
	if(reverse)
		ndir = get_dir(usr,on_wall)
	else
		ndir = get_dir(on_wall,usr)

	if (!(ndir in GLOB.cardinal))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, SPAN_DANGER("\The [src] cannot be placed on this spot."))
		return
	if ((A.requires_power == 0 || A.name == "Space") && !isLightFrame())
		to_chat(usr, SPAN_DANGER("\The [src] cannot be placed in this area."))
		return

	var/wall_item = get_wall_item(loc, ndir)
	if (wall_item)
		to_chat(usr, SPAN_DANGER("There's already \a [wall_item] on this wall!"))
		return

	new build_machine_type(loc, ndir, src)
	qdel(src)

/obj/item/frame/proc/isLightFrame()
	return FALSE

/obj/item/frame/fire_alarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms."
	icon = 'icons/obj/machines/firealarm.dmi'
	icon_state = "casing"
	build_machine_type = /obj/machinery/firealarm

/obj/item/frame/air_alarm
	name = "air alarm frame"
	desc = "Used for building air alarms."
	icon = 'icons/obj/machines/airalarm.dmi'
	icon_state = "alarm_bitem"
	build_machine_type = /obj/machinery/alarm

/obj/item/frame/intercom
	name = "intercom frame"
	desc = "Used for building intercoms."
	icon = 'icons/obj/machines/radio.dmi'
	icon_state = "intercom-f"
	build_machine_type = /obj/item/device/radio/intercom

/obj/item/frame/intercom/get_mechanics_info()
	. = ..()
	. += "<p>To construct:</p>\
			<ol>\
				<li>Attach the frame to the wall</li>\
				<li>Install the circuitboard into the frame</li>\
				<li>Use cables to wire the intercom</li>\
				<li>Screwdriver to close the panel</li>\
			</ol>"
/obj/item/frame/light
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/structures/lighting.dmi'
	icon_state = "tube-construct-item"
	build_machine_type = /obj/machinery/light_construct
	reverse = 1

/obj/item/frame/light/isLightFrame()
	return TRUE

/obj/item/frame/light/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-item"
	refund_amt = 1
	build_machine_type = /obj/machinery/light_construct/small

/obj/item/frame/light/spot
	name = "large light fixture frame"
	build_machine_type = /obj/machinery/light_construct/spot
	refund_amt = 3

/obj/item/frame/supermatter_alarm
	name = "supermatter alarm frame"
	icon = 'icons/obj/structures/lighting.dmi'
	icon_state = "bulb-construct-item"
	refund_amt = 1
	build_machine_type = /obj/machinery/rotating_alarm/supermatter
