/datum/eldritch_transmutation/mind_knife
	name = "Cerebral Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/book) 
	result_atoms = list(/obj/item/melee/sickly_blade/mind)
	required_shit_list = "A book and a knife."

/datum/eldritch_transmutation/eldritch_eye
	name = "Eldritch Eye"
	required_atoms = list(/obj/item/organ/eyes,/obj/item/flashlight) 
	result_atoms = list(/obj/item/clothing/glasses/hud/toggle/eldritch_eye)
	required_shit_list = "A pair of eyes and a flashlight"

/datum/eldritch_transmutation/final/mind_final
	name = "Beyond All Knowldege Lies Despair"
	required_atoms = list(/mob/living/carbon/human)
	required_shit_list = "Three dead bodies."

/datum/martial_art/Absolute_Spacial_Domination
	id = MARTIALART_SPACIALLDOMINANCE

/datum/martial_art/Absolute_Spacial_Domination/teach(mob/living/carbon/human/user, make_temporary)
	. = ..()
	RegisterSignal(user, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))

/datum/martial_art/Absolute_Spacial_Domination/remove(mob/living/carbon/human/user)
	UnregisterSignal(user, COMSIG_ATOM_BULLET_ACT)
	return ..()

/datum/martial_art/Absolute_Spacial_Domination/proc/on_bullet_act(mob/living/carbon/human/defender, obj/projectile/incoming, def_zone)
	if(!(defender.mobility_flags & MOBILITY_USE))
		return NONE
	if(defender.dna?.check_mutation(HULK))
		return NONE
	defender.visible_message(
		span_danger("[defender] deflects the projectile; [defender.p_they()] can't be hit with ranged weapons!"),
		span_userdanger("You deflect the projectile!"),
	)
	playsound(defender, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
	return BULLET_ACT_BLOCK

/datum/eldritch_transmutation/final/mind_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	var/datum/martial_art/Absolute_Spacial_Domination/deflection= new(user)
	deflection.teach(user)
	
	ADD_TRAIT(user, TRAIT_NOBREATH, type)
	ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, type)
	ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, type)
	
	priority_announce("Immense destabilization of the bluespace veil has been observed. @&#^$&#^@# THE HUNT BEGINS, LET SLIP THE DOGS OF WAR AND HUNT FREE FOREVER MORE!  $&#^@#@&#^ Immediate evacuation is advised.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	///grants the ascended heretic 9 points to spend
	if (ascension.ascended == TRUE)
		var/datum/antagonist/heretic/knowledge = user.mind?.has_antag_datum(/datum/antagonist/heretic)
		knowledge?.charge += 9
		
	return ..()

	

