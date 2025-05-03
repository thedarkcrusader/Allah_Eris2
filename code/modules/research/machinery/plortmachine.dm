/**********************Plort Redemption Machine**************************/
//Accepts slime "Cores" as they are definetly NOT called, and turns them into stuff. Probably money? maybe goods? idk im writing this thing before i code it.

/obj/machinery/plortrefinery
	name = "plort redemption machine"
	desc = "A machine that accepts slime cores, and sells them to the highest bidder. This generates research, depending on the rarity."
	icon = 'icons/obj/machines/plortmachine.dmi'
	icon_state = "plortmachine"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	speed_process = TRUE
	var/research_point_multiplier = 1
	var/point_gain = 0
	var/datum/techweb/linked_techweb
	circuit = /obj/item/circuitboard/machine/plort

/obj/machinery/plortrefinery/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Selling cores at <b>[research_point_multiplier*100]%</b> their value.<span>"

/obj/machinery/plortrefinery/RefreshParts()
	var/research_point_multiplier_temp = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		research_point_multiplier_temp = 1 * M.rating
	research_point_multiplier = research_point_multiplier_temp

/obj/machinery/plortrefinery/attackby(obj/item/W, mob/user, params)
	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_screwdriver(user, "plortmachine_maintenance", "plortmachine", W))
		updateUsrDialog()
		return

	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return

	if(istype(W, /obj/item/slime_extract))
		refine_plort(W, user)
		return

/obj/machinery/plortrefinery/proc/refine_plort(obj/item/slime_extract/extract, mob/user)
	point_gain = extract.plort_value * research_point_multiplier
	linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, point_gain)
	if(user.add_exp(SKILL_SCIENCE, extract.plort_value * 5, extract.type))
		user.playsound_local(get_turf(src), 'sound/machines/ping.ogg', 25, TRUE)
		balloon_alert(user, "new sample processed: [extract.effectmod]")
	qdel(extract)

/obj/machinery/plortrefinery/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech
