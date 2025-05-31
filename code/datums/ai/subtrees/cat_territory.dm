
/datum/ai_planning_subtree/flee_target/from_flee_key/cat_struggle
	flee_behaviour = /datum/ai_behavior/run_away_from_target/cat_struggle

/datum/ai_behavior/run_away_from_target/cat_struggle
	clear_failed_targets = TRUE

/datum/ai_planning_subtree/territorial_struggle
	///chance we become hostile to another cat
	var/hostility_chance = 20

/datum/ai_planning_subtree/territorial_struggle/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.gender != MALE || !SPT_PROB(hostility_chance, seconds_per_tick))
		return
	if(controller.blackboard_key_exists(BB_TRESSPASSER_TARGET))
		controller.queue_behavior(/datum/ai_behavior/territorial_struggle, BB_TRESSPASSER_TARGET, BB_HOSTILE_MEOWS)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/cat_tresspasser, BB_TRESSPASSER_TARGET, /mob/living/simple_animal/pet/cat)

/datum/ai_behavior/find_and_set/cat_tresspasser/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/ignore_types = controller.blackboard[BB_BABIES_CHILD_TYPES]
	for(var/mob/living/simple_animal/pet/cat/potential_enemy in oview(search_range, controller.pawn))
		if(potential_enemy.gender != MALE)
			continue
		if(is_type_in_list(potential_enemy, ignore_types))
			continue
		var/datum/ai_controller/basic_controller/enemy_controller = potential_enemy.ai_controller
		if(isnull(enemy_controller))
			continue
		//theyre already engaged in a battle, leave them alone!
		if(enemy_controller.blackboard_key_exists(BB_TRESSPASSER_TARGET))
			continue
		//u choose me and i choose u
		enemy_controller.set_blackboard_key(BB_TRESSPASSER_TARGET, controller.pawn)
		return potential_enemy
	return null

/datum/ai_behavior/territorial_struggle
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 0.25 SECONDS
	///chance the battle ends!
	var/end_battle_chance = 15

/datum/ai_behavior/territorial_struggle/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	if(target.ai_controller?.blackboard[target_key] != living_pawn)
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/territorial_struggle/perform(seconds_per_tick, datum/ai_controller/controller, target_key, cries_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, TRUE, target_key)
		return

	var/mob/living/living_pawn = controller.pawn
	var/list/threaten_list = controller.blackboard[cries_key]
	if(length(threaten_list))
		if(prob(50))
			if(prob(50))
				living_pawn.say(pick(threaten_list), forced = "ai_controller")
			else
				playsound(living_pawn, 'sound/vo/mobs/cat/cathiss.ogg', 80, TRUE, -1)

		else
			if(prob(50))
				target.say(pick(threaten_list), forced = "ai_controller")
			else
				playsound(target, 'sound/vo/mobs/cat/cathiss.ogg', 80, TRUE, -1)

	if(prob(35))
		if(prob(50))
			playsound(target, "smallslash", 100, TRUE, -1)
			target.do_attack_animation(living_pawn, "claw")
		else
			playsound(living_pawn, "smallslash", 100, TRUE, -1)
			living_pawn.do_attack_animation(target, "claw")

	if(!prob(end_battle_chance))
		return

	//50 50 chance we lose
	var/datum/ai_controller/loser_controller = prob(50) ? controller : target.ai_controller

	loser_controller.set_blackboard_key(BB_BASIC_MOB_FLEE_TARGET, target)
	loser_controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, TRUE)
	addtimer(CALLBACK(loser_controller, TYPE_PROC_REF(/datum/ai_controller, set_blackboard_key), BB_BASIC_MOB_FLEEING, FALSE), 10 SECONDS)
	target.ai_controller.clear_blackboard_key(BB_TRESSPASSER_TARGET)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/territorial_struggle/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
