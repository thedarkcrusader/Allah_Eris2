/// Keeps the parent within the distance of its owner as naturally as possible,
/// but teleporting if necessary.
/datum/component/leash
	/// The owner of the leash. If this is qdeleted, the leash is as well.
	var/atom/movable/owner

	/// The maximum distance you can move from your owner
	var/distance

	/// The object type to create on the old turf when forcibly teleporting out
	var/force_teleport_out_effect

	/// The object type to create on the new turf when forcibly teleporting out
	var/force_teleport_in_effect

	var/beam_icon_state
	var/beam_icon
	var/list/beams = list()
	var/force_teleports
	var/datum/callback/break_callback

	VAR_PRIVATE
		// Pathfinding can yield, so only move us closer if this is the best one
		current_path_tick = 0
		last_completed_path_tick = 0

		performing_path_move = FALSE

/datum/component/leash/Initialize(
	atom/movable/owner,
	distance = 3,
	force_teleport_out_effect,
	force_teleport_in_effect,
	beam_icon_state,
	beam_icon,
	force_teleports = TRUE,
	break_callback,
)
	. = ..()

	if (!ismovable(parent))
		stack_trace("Parent must be a movable")
		return COMPONENT_INCOMPATIBLE

	if (!ismovable(owner))
		stack_trace("[owner] (owner) is not a movable")
		return COMPONENT_INCOMPATIBLE

	if (!isnum(distance))
		stack_trace("[distance] (distance) must be a number")
		return COMPONENT_INCOMPATIBLE

	if (!isnull(force_teleport_out_effect) && !ispath(force_teleport_out_effect))
		stack_trace("force_teleport_out_effect must be null or a path, not [force_teleport_out_effect]")
		return COMPONENT_INCOMPATIBLE

	if (!isnull(force_teleport_in_effect) && !ispath(force_teleport_in_effect))
		stack_trace("force_teleport_in_effect must be null or a path, not [force_teleport_in_effect]")
		return COMPONENT_INCOMPATIBLE

	src.owner = owner
	src.distance = distance
	src.force_teleport_out_effect = force_teleport_out_effect
	src.force_teleport_in_effect = force_teleport_in_effect
	src.beam_icon_state = beam_icon_state
	src.beam_icon = beam_icon
	src.force_teleports = force_teleports
	src.break_callback = break_callback

	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_qdel))

	var/static/list/container_connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(on_owner_moved),
	)

	AddComponent(/datum/component/connect_containers, owner, container_connections)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_parent_pre_move))

	check_distance()

/datum/component/leash/Destroy()
	owner = null
	QDEL_LIST(beams)
	return ..()

/datum/component/leash/proc/set_distance(distance)
	ASSERT(isnum(distance))
	src.distance = distance
	check_distance()

/datum/component/leash/proc/on_owner_qdel()
	PRIVATE_PROC(TRUE)

	if(break_callback)
		break_callback.Invoke()

	qdel(src)

/datum/component/leash/proc/on_owner_moved(atom/movable/source)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	check_distance()

/datum/component/leash/proc/on_parent_pre_move(atom/movable/source, atom/new_location)
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	if (performing_path_move)
		return NONE

	var/turf/new_location_turf = get_turf(new_location)
	if (get_dist(new_location_turf, owner) <= distance)
		return NONE

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/leash/proc/check_distance()
	set waitfor = FALSE
	PRIVATE_PROC(TRUE)

	if(beam_icon && beam_icon_state)
		var/list/true_path= get_path_to(parent, get_turf(owner), TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 33, 250, 1)
		true_path |= list(get_turf(owner))
		redraw_beams(true_path)

	if (get_dist(parent, owner) <= distance)
		return

	SEND_SIGNAL(parent, COMSIG_LEASH_PATH_STARTED)

	current_path_tick += 1
	var/our_path_tick = current_path_tick

	var/list/path = get_path_to(parent, get_turf(owner), TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), mintargetdist = distance)

	if (last_completed_path_tick > our_path_tick)
		return

	last_completed_path_tick = our_path_tick

	commit_path(path)

/datum/component/leash/proc/commit_path(list/turf/path)
	PRIVATE_PROC(TRUE)

	performing_path_move = TRUE

	var/atom/movable/movable_parent = parent

	for (var/turf/to_move as anything in path)
		// Could be an older path, don't make us teleport back
		if (!to_move.Adjacent(parent))
			continue

		movable_parent.Move(to_move)

	if (get_dist(parent, owner) > distance)
		force_teleport_back("incomplete path")

	performing_path_move = FALSE
	SEND_SIGNAL(parent, COMSIG_LEASH_PATH_COMPLETE)

/datum/component/leash/proc/force_teleport_back(reason)
	PRIVATE_PROC(TRUE)

	if(!force_teleports)
		if(break_callback)
			break_callback.Invoke()
		qdel(src)
		return

	var/atom/movable/movable_parent = parent

	SSblackbox.record_feedback("tally", "leash_force_teleport_back", 1, reason)

	if (force_teleport_out_effect)
		new force_teleport_out_effect(movable_parent.loc)

	movable_parent.forceMove(get_turf(owner))

	if (force_teleport_in_effect)
		new force_teleport_in_effect(movable_parent.loc)

	SEND_SIGNAL(parent, COMSIG_LEASH_FORCE_TELEPORT)


/datum/component/leash/proc/redraw_beams(list/path)
	for(var/datum/beam/beam as anything in beams)
		beams -= beam
		qdel(beam)

	var/atom/movable/movable_parent = parent
	if(!length(path))
		return
	var/turf/first_turf = path[1]
	var/atom/new_host = movable_parent

	var/normal_direction = get_dir(movable_parent, first_turf) // we want to follow 1 dir until it turns and follow that way
	var/dist = length(path)
	for(var/turf/to_move as anything in path)
		dist--
		if(dist == 0)
			beams += new_host.Beam(to_move, beam_icon_state, beam_icon, time = INFINITY)
			normal_direction = get_dir(new_host, to_move)
			new_host = to_move

		else if((get_dir(new_host, to_move) == normal_direction))
			continue

		beams += new_host.Beam(to_move, beam_icon_state, beam_icon, time = INFINITY)
		normal_direction = get_dir(new_host, to_move)
		new_host = to_move

/// A debug spawner that will create a corgi leashed to a bike horn, plus a beam
/obj/effect/spawner/debug_leash

/obj/effect/spawner/debug_leash/Initialize(mapload)
	. = ..()

	var/obj/item/weapon/whip/whip = new(loc)
	var/mob/living/simple_animal/hostile/retaliate/trufflepig/pig = new(loc)

	pig.AddComponent(/datum/component/leash, whip, 5, null, null, "chain", 'icons/effects/beam.dmi', FALSE)

	pig.Beam(whip)
