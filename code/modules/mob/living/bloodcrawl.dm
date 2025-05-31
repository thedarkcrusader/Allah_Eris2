/obj/effect/dummy/phased_mob/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/canmove = TRUE

/obj/effect/dummy/phased_mob/slaughter/relaymove(mob/user, direction)
	forceMove(get_step(src,direction))

/obj/effect/dummy/phased_mob/slaughter/ex_act()
	return

/obj/effect/dummy/phased_mob/slaughter/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/mob/living/proc/phaseout(obj/effect/decal/cleanable/B)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/I in C.held_items)
			//TODO make it toggleable to either forcedrop the items, or deny
			//entry when holding them
			// literally only an option for carbons though
			to_chat(C, "<span class='warning'>I may not hold items while blood crawling!</span>")
			return FALSE
		var/obj/item/bloodcrawl/B1 = new(C)
		var/obj/item/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()

	notransform = TRUE
	INVOKE_ASYNC(src, PROC_REF(bloodpool_sink), B)

	return TRUE

/mob/living/proc/bloodpool_sink(obj/effect/decal/cleanable/B)
	var/turf/mobloc = get_turf(loc)

	visible_message("<span class='warning'>[src] sinks into the pool of blood!</span>")
	playsound(get_turf(src), 'sound/blank.ogg', 50, TRUE, -1)
	// Extinguish, unbuckle, stop being pulled, set our location into the
	// dummy object
	var/obj/effect/dummy/phased_mob/slaughter/holder = new /obj/effect/dummy/phased_mob/slaughter(mobloc)
	ExtinguishMob()

	// Keep a reference to whatever we're pulling, because forceMove()
	// makes us stop pulling
	var/pullee = pulling

	holder = holder
	forceMove(holder)

	// if we're not pulling anyone, or we can't eat anyone
	if(!pullee || bloodcrawl != BLOODCRAWL_EAT)
		notransform = FALSE
		return

	// if the thing we're pulling isn't alive
	if(!isliving(pullee))
		notransform = FALSE
		return

	var/mob/living/victim = pullee
	var/kidnapped = FALSE

	if(victim.stat == CONSCIOUS)
		visible_message("<span class='warning'>[victim] kicks free of the blood pool just before entering it!</span>", null, "<span class='notice'>I hear splashing and struggling.</span>")
	else
		victim.forceMove(src)
		victim.emote("scream")
		visible_message("<span class='warning'><b>[src] drags [victim] into the pool of blood!</b></span>", null, "<span class='notice'>I hear a splash.</span>")
		kidnapped = TRUE

	if(kidnapped)
		var/success = bloodcrawl_consume(victim)
		if(!success)
			to_chat(src, "<span class='danger'>I happily devour... nothing? Your meal vanished at some point!</span>")

	notransform = FALSE
	return TRUE

/mob/living/proc/bloodcrawl_consume(mob/living/victim)
	to_chat(src, "<span class='danger'>I begin to feast on [victim]... You can not move while you are doing this.</span>")

	var/sound = 'sound/blank.ogg'

	for(var/i in 1 to 3)
		playsound(get_turf(src),sound, 50, TRUE)
		sleep(30)

	if(!victim)
		return FALSE

	to_chat(src, "<span class='danger'>I devour [victim]. Your health is fully restored.</span>")
	revive(full_heal = TRUE, admin_revive = FALSE)

	// No defib possible after laughter
	victim.adjustBruteLoss(1000)
	victim.death()
	bloodcrawl_swallow(victim)
	return TRUE

/mob/living/proc/bloodcrawl_swallow(mob/living/victim)
	qdel(victim)

/obj/item/bloodcrawl
	name = "blood crawl"
	desc = ""
	icon = 'icons/effects/blood.dmi'
	item_flags = ABSTRACT | DROPDEL

/obj/item/bloodcrawl/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/mob/living/proc/exit_blood_effect(obj/effect/decal/cleanable/B)
	playsound(get_turf(src), 'sound/blank.ogg', 50, TRUE, -1)
	//Makes the mob have the color of the blood pool it came out of
	var/newcolor = rgb(149, 10, 10)
	if(istype(B, /obj/effect/decal/cleanable/xenoblood))
		newcolor = rgb(43, 186, 0)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	// but only for a few seconds
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, newcolor), 6 SECONDS)

/mob/living/proc/phasein(obj/effect/decal/cleanable/B)
	if(notransform)
		to_chat(src, "<span class='warning'>Finish eating first!</span>")
		return FALSE
	B.visible_message("<span class='warning'>[B] starts to bubble...</span>")
	if(!do_after(src, 2 SECONDS, B))
		return
	if(!B)
		return
	forceMove(B.loc)
	client.eye = src
	visible_message("<span class='boldwarning'>[src] rises out of the pool of blood!</span>")
	exit_blood_effect(B)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/bloodcrawl/BC in C)
			BC.flags_1 = null
			qdel(BC)
	QDEL_NULL(holder)
	return TRUE
