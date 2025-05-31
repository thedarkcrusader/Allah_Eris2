/datum/round_event_control/necra_embrace
	name = "Necra's Embrace"
	track = EVENT_TRACK_PERSONAL
	typepath = /datum/round_event/necra_embrace
	weight = 10
	earliest_start = 35 MINUTES
	max_occurrences = 1
	min_players = 30

	tags = list(
		TAG_HAUNTED,
	)

/datum/round_event_control/necra_embrace/canSpawnEvent(players_amt, gamemode, fake_check)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!istype(H) || H.stat == DEAD || !H.client)
			continue
		if(H.age != AGE_OLD)
			continue
		if(!H.patron || !is_tennite(H))
			continue
		return TRUE

	return FALSE

/datum/round_event/necra_embrace/start()
	var/list/necra_targets = list()
	var/list/tennite_targets = list()

	for(var/mob/living/carbon/human/human_mob in GLOB.player_list)
		if(!istype(human_mob) || human_mob.stat == DEAD || !human_mob.client)
			continue
		if(human_mob.age != AGE_OLD)
			continue
		if(!human_mob.patron || !is_tennite(human_mob))
			continue

		if(istype(human_mob.patron, /datum/patron/divine/necra))
			necra_targets += human_mob
		else
			tennite_targets += human_mob

	var/list/valid_targets = necra_targets.len ? necra_targets : tennite_targets

	if(!valid_targets.len)
		return

	var/mob/living/carbon/human/chosen_one = pick(valid_targets)

	var/datum/objective/embrace_death/new_objective = new(owner = chosen_one.mind)
	chosen_one.mind.add_personal_objective(new_objective)

	to_chat(chosen_one, span_userdanger("YOU ARE GODS' CHOSEN!"))
	to_chat(chosen_one, span_biginfo("You have lived a good life, but everything must come to an end. Necra wishes you to embrace death and earn a well deserved rest. Say goodbye to your loved ones, and take care of all remaining affairs, for this death will final. Your soul will have guaranteed place in the Cycle."))
	chosen_one.playsound_local(chosen_one, 'sound/ambience/noises/genspooky (1).ogg', 100)

	chosen_one.mind.announce_personal_objectives()
