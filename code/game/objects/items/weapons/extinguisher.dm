/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/tools/fire_extinguishers.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	throwforce = 10
	w_class = ITEM_SIZE_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 10.0
	base_parry_chance = 15
	matter = list(MATERIAL_STEEL = 90)
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")

	var/spray_amount = 120	//units of liquid per spray - 120 -> same as splashing them with a bucket per spray
	var/starting_water = 2000
	var/max_water = 2000
	var/last_use = 1.0
	var/safety = 1
	var/sprite_name = "fire_extinguisher"
	var/list/preferred_reagent = list(/datum/reagent/water)
	var/broken = FALSE

/obj/item/extinguisher/mini
	name = "mini fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	throwforce = 2
	w_class = ITEM_SIZE_SMALL
	force = 3.0
	spray_amount = 80
	starting_water = 1000
	max_water = 1000
	sprite_name = "miniFE"
	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 30)

/obj/item/extinguisher/Initialize()
	. = ..()
	create_reagents(max_water)
	if(starting_water > 0)
		reagents.add_reagent(/datum/reagent/water, starting_water)

/obj/item/extinguisher/empty
	starting_water = 0

/obj/item/extinguisher/mini/empty
	starting_water = 0

/obj/item/extinguisher/examine(mob/user, distance)
	. = ..()
	if(distance <= 0)
		to_chat(user, text("[icon2html(src, viewers(get_turf(src)))] [] contains [] units of fluid left!", src, src.reagents.total_volume))

/obj/item/extinguisher/attack_self(mob/user as mob)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	src.desc = "The safety is [safety ? "on" : "off"]."
	to_chat(user, "The safety is [safety ? "on" : "off"].")
	return

/obj/item/extinguisher/proc/propel_object(obj/O, mob/user, movementdirection)
	if(O.anchored) return

	var/obj/structure/bed/chair/C
	if(istype(O, /obj/structure/bed/chair))
		C = O

	var/list/move_speed = list(1, 1, 1, 2, 2, 3)
	for(var/i in 1 to 6)
		if(C) C.propelled = (6-i)
		O.Move(get_step(user,movementdirection), movementdirection)
		sleep(move_speed[i])

	//additional movement
	for(var/i in 1 to 3)
		O.Move(get_step(user,movementdirection), movementdirection)
		sleep(3)

/obj/item/extinguisher/use_before(obj/target, mob/living/user, click_parameters)
	if (!(istype(target, /obj/structure/hygiene/sink) || istype(target, /obj/structure/reagent_dispensers)))
		return FALSE

	var/amount = reagents.get_free_space()
	if (istype(target, /obj/structure/hygiene))
		if (amount <= 0)
			return FALSE //Will proceed with washing the extinguisher
		reagents.add_reagent(/datum/reagent/water, amount)

	else
		if (amount <= 0)
			to_chat(user, SPAN_WARNING("\The [src] is already full."))
			return TRUE
		if (target.reagents.total_volume <= 0)
			to_chat(user, SPAN_WARNING("\The [target] is empty."))
			return TRUE
		amount = target.reagents.trans_to_obj(src, max_water)

	if (istype(target, /obj/structure/reagent_dispensers/acid))
		to_chat(user, SPAN_DANGER("The acid violently eats away at \the [src]!"))
		do_spray(user)
		qdel(src)
		return TRUE

	to_chat(user, SPAN_NOTICE("You fill \the [src] with [amount] unit\s from \the [target]."))
	playsound(loc, 'sound/effects/refill.ogg', 50, 1, -6)
	return TRUE

/obj/item/extinguisher/use_tool(obj/item/item, mob/living/user, list/click_params)
	if (istype(item, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/container = item
		if (container.reagents.total_volume <= 0)
			to_chat(user, SPAN_WARNING("\The [item] is empty."))
			return TRUE
		if (reagents.get_free_space() <= 0)
			to_chat(user, SPAN_WARNING("\The [src] is already full"))
			return TRUE
		var/trans_amount = container.amount_per_transfer_from_this
		var/amount = container.reagents.trans_to_obj(src, trans_amount)

		if (reagents.has_reagent(/datum/reagent/acid))
			to_chat(user, SPAN_DANGER("The acid violently eats away at \the [src]!"))
			do_spray(user)
			qdel(src)
			return TRUE

		to_chat(user, SPAN_NOTICE("You fill \the [src] with [amount] unit\s from \the [container]."))
		playsound(src, 'sound/effects/pour.ogg', 25, 1)
		return TRUE
	else return ..()

/obj/item/extinguisher/afterattack(atom/target, mob/user, flag)
	if (!safety)
		if (src.reagents.total_volume < 1)
			to_chat(usr, SPAN_NOTICE("\The [src] is empty."))
			return

		if (broken)
			to_chat(user, SPAN_WARNING("The nozzle of \the [src] is gunked up beyond repair!"))
			return

		if (world.time < src.last_use + 20)
			return

		src.last_use = world.time

		playsound(src.loc, 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(target, src)

		if(user.buckled && isobj(user.buckled))
			addtimer(new Callback(src, PROC_REF(propel_object), user.buckled, user, direction), 0)

		visible_message(SPAN_NOTICE("\The [user] sprays towards \the [target] with \the [src]."))
		addtimer(new Callback(src, PROC_REF(do_spray), target), 0)

		if(!user.check_space_footing())
			step(user, direction)

		if (reagents.has_other_reagent(preferred_reagent) && prob(15))
			broken = TRUE
			to_chat(user, SPAN_WARNING("The foreign reagents gunked up the spraying mechanism, breaking \the [src]."))

	else
		return ..()

/obj/item/extinguisher/proc/do_spray(atom/Target)
	var/turf/T = get_turf(Target)
	var/available_spray = min(spray_amount, reagents.total_volume)
	if(!src || !reagents.total_volume)
		return

	var/obj/effect/water/W = new /obj/effect/water(get_turf(src))
	W.create_reagents(available_spray)
	reagents.trans_to_holder(W.reagents, available_spray, safety = 1)
	W.set_color()
	W.set_up(T)
