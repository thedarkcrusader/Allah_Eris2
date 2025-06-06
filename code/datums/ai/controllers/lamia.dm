/datum/ai_controller/lamia
	movement_delay = 0.4 SECONDS

	ai_movement = /datum/ai_movement/hybrid_pathing

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/sneak,
		/datum/ai_planning_subtree/flee_target,

		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,

		/datum/ai_planning_subtree/find_dead_bodies/mole,
		/datum/ai_planning_subtree/eat_dead_body,

	)

	idle_behavior = /datum/idle_behavior/idle_random_walk
