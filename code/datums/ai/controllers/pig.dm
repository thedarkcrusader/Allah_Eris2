/datum/ai_controller/pig
	movement_delay = 0.8 SECONDS

	ai_movement = /datum/ai_movement/hybrid_pathing
	ai_traits = STOP_MOVING_WHEN_PULLED

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items(),
		BB_PET_TARGETING_DATUM = new /datum/targetting_datum/basic/not_friends(),
		BB_BABIES_PARTNER_TYPES = list(/mob/living/simple_animal/hostile/retaliate/trufflepig, /mob/living/simple_animal/hostile/retaliate/trufflepig/male, /mob/living/simple_animal/hostile/retaliate/trufflepig/female),
		BB_BABIES_CHILD_TYPES = list(/mob/living/simple_animal/hostile/retaliate/trufflepig/piglet = 90, /mob/living/simple_animal/hostile/retaliate/trufflepig/piglet/boy = 10),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/make_babies,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk
