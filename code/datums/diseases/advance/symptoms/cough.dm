/*
//////////////////////////////////////

Coughing

	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmissibile.
	Low Level.

BONUS
	Will force the affected mob to drop small items!

//////////////////////////////////////
*/

/datum/symptom/cough

	name = "Cough"
	icon = "coughing"
	desc = "The virus irritates the throat of the host, causing occasional coughing."
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 2
	level = 1
	severity = 1
	base_message_chance = 15
	symptom_delay_min = 2
	symptom_delay_max = 15
	var/infective = FALSE
	threshold_descs = list(
		"Resistance 3" = "The host will drop small items when coughing.",
		"Resistance 10" = "Occasionally causes coughing fits that stun the host. The extra coughs do not spread the virus.",
		"Stage Speed 6" = "Increases cough frequency.",
		"Stealth 4" = "The symptom remains hidden until active.",
	)

/datum/symptom/cough/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.spread_flags & DISEASE_SPREAD_AIRBORNE) //infect bystanders
		infective = TRUE
	if(A.totalResistance() >= 3) //strong enough to drop items
		power = 1.5
	if(A.totalResistance() >= 10) //strong enough to stun (rarely)
		power = 2
	if(A.totalStageSpeed() >= 6) //cough more often
		symptom_delay_max = 10

/datum/symptom/cough/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span notice='warning'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>")
		else
			M.emote("cough")
			if(power >= 1.5)
				var/obj/item/I = M.get_active_held_item()
				if(I && I.w_class == WEIGHT_CLASS_TINY)
					M.dropItemToGround(I)
			if(power >= 2 && prob(10))
				to_chat(M, "<span notice='userdanger'>[pick("You have a coughing fit!", "You can't stop coughing!")]</span>")
				M.Immobilize(20)
				M.emote("cough")
				addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, emote), "cough"), 6)
				addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, emote), "cough"), 12)
				addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, emote), "cough"), 18)
			if(infective && M.CanSpreadAirborneDisease())
				A.spread(1)

