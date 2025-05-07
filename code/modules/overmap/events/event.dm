var/global/singleton/overmap_event_handler/overmap_event_handler = new()

/singleton/overmap_event_handler
	var/list/hazard_by_turf
	var/list/ship_events

/singleton/overmap_event_handler/New()
	..()
	hazard_by_turf = list()
	ship_events = list()

/singleton/overmap_event_handler/proc/create_events(z_level, overmap_size, number_of_events)
	// Acquire the list of not-yet utilized overmap turfs on this Z-level
	var/list/candidate_turfs = block(locate(OVERMAP_EDGE, OVERMAP_EDGE, z_level),locate(overmap_size - OVERMAP_EDGE, overmap_size - OVERMAP_EDGE,z_level))
	candidate_turfs = where(candidate_turfs, GLOBAL_PROC_REF(can_not_locate), /obj/overmap/visitable)

	for(var/i = 1 to number_of_events)
		if(!length(candidate_turfs))
			break
		var/overmap_event_type = pick(subtypesof(/datum/overmap_event))
		var/datum/overmap_event/datum_spawn = new overmap_event_type

		var/list/event_turfs = acquire_event_turfs(datum_spawn.count, datum_spawn.radius, candidate_turfs, datum_spawn.continuous)
		candidate_turfs -= event_turfs

		var/seed = rand(1, SHORT_REAL_LIMIT - 1)
		for(var/event_turf in event_turfs)
			var/type = pick(datum_spawn.hazards)
			if (datum_spawn.coordinated)
				new type(event_turf, seed)
			else
				new type(event_turf)

		qdel(datum_spawn)//idk help how do I do this better?

/singleton/overmap_event_handler/proc/acquire_event_turfs(number_of_turfs, distance_from_origin, list/candidate_turfs, continuous = TRUE)
	number_of_turfs = min(number_of_turfs, length(candidate_turfs))
	candidate_turfs = candidate_turfs.Copy() // Not this proc's responsibility to adjust the given lists

	var/origin_turf = pick(candidate_turfs)
	var/list/selected_turfs = list(origin_turf)
	var/list/selection_turfs = list(origin_turf)
	candidate_turfs -= origin_turf

	while(length(selection_turfs) && length(selected_turfs) < number_of_turfs)
		var/selection_turf = pick(selection_turfs)
		var/random_neighbour = get_random_neighbour(selection_turf, candidate_turfs, continuous, distance_from_origin)

		if(random_neighbour)
			candidate_turfs -= random_neighbour
			selected_turfs += random_neighbour
			if(get_dist(origin_turf, random_neighbour) < distance_from_origin)
				selection_turfs += random_neighbour
		else
			selection_turfs -= selection_turf

	return selected_turfs

/singleton/overmap_event_handler/proc/get_random_neighbour(turf/origin_turf, list/candidate_turfs, continuous = TRUE, range)
	var/fitting_turfs
	if(continuous)
		fitting_turfs = origin_turf.CardinalTurfs(FALSE)
	else
		fitting_turfs = trange(range, origin_turf)
	fitting_turfs = shuffle(fitting_turfs)
	for(var/turf/T in fitting_turfs)
		if(T in candidate_turfs)
			return T

/singleton/overmap_event_handler/proc/start_hazard(obj/overmap/visitable/ship/ship, obj/overmap/event/hazard)//make these accept both hazards or events
	if(!(ship in ship_events))
		ship_events += ship

	for(var/event_type in hazard.events)
		if(is_event_active(ship,event_type, hazard.difficulty))//event's already active, don't bother
			continue
		var/datum/event_meta/EM = new(hazard.difficulty, "Overmap event - [hazard.name]", event_type, add_to_queue = FALSE, is_one_shot = TRUE)
		var/datum/event/E = new event_type(EM)
		E.startWhen = 0
		E.endWhen = INFINITY
		E.affecting_z = ship.map_z
		if("victim" in E.vars)//for meteors and other overmap events that uses ships//might need a better solution
			E.vars["victim"] = ship
		LAZYADD(ship_events[ship], E)

/singleton/overmap_event_handler/proc/stop_hazard(obj/overmap/visitable/ship/ship, obj/overmap/event/hazard)
	for(var/event_type in hazard.events)
		var/datum/event/E = is_event_active(ship,event_type,hazard.difficulty)
		if(E)
			E.kill()
			LAZYREMOVE(ship_events[ship], E)

/singleton/overmap_event_handler/proc/is_event_active(ship, event_type, severity)
	if(!ship_events[ship])	return
	for(var/datum/event/E in ship_events[ship])
		if(E.type == event_type && E.severity == severity)
			return E

/singleton/overmap_event_handler/proc/on_turf_entered(turf/new_loc, obj/overmap/visitable/ship/ship, old_loc)
	if(!istype(ship))
		return
	if(new_loc == old_loc)
		return

	for(var/obj/overmap/event/E in hazard_by_turf[new_loc])
		start_hazard(ship, E)

/singleton/overmap_event_handler/proc/on_turf_exited(turf/old_loc, obj/overmap/visitable/ship/ship, new_loc)
	if(!istype(ship))
		return
	if(new_loc == old_loc)
		return

	for(var/obj/overmap/event/E in hazard_by_turf[old_loc])
		if(is_event_included(hazard_by_turf[new_loc],E))
			continue
		stop_hazard(ship,E)

/singleton/overmap_event_handler/proc/update_hazards(turf/T)//catch all updater
	if(!istype(T))
		return

	var/list/active_hazards = list()
	for(var/obj/overmap/event/E in T)
		if(is_event_included(active_hazards, E, TRUE))
			continue
		active_hazards += E

	if(!length(active_hazards))
		hazard_by_turf -= T
		GLOB.entered_event.unregister(T, src, PROC_REF(on_turf_entered))
		GLOB.exited_event.unregister(T, src, PROC_REF(on_turf_exited))
	else
		hazard_by_turf |= T
		hazard_by_turf[T] = active_hazards
		GLOB.entered_event.register(T, src, PROC_REF(on_turf_entered))
		GLOB.exited_event.register(T, src, PROC_REF(on_turf_exited))

	for(var/obj/overmap/visitable/ship/ship in T)
		for(var/datum/event/E in ship_events[ship])
			if(is_event_in_turf(E,T))
				continue
			E.kill()
			LAZYREMOVE(ship_events[ship], E)

		for(var/obj/overmap/event/E in active_hazards)
			start_hazard(ship,E)

/singleton/overmap_event_handler/proc/is_event_in_turf(datum/event/E, turf/T)
	for(var/obj/overmap/event/hazard in hazard_by_turf[T])
		if(E in hazard.events && E.severity == hazard.difficulty)
			return TRUE

/singleton/overmap_event_handler/proc/is_event_included(list/hazards, obj/overmap/event/E, equal_or_better)//this proc is only used so it can break out of 2 loops cleanly
	for(var/obj/overmap/event/A in hazards)
		if(istype(A,E.type) || istype(E,A.type))
			if(same_entries(A.events, E.events))
				if(equal_or_better)
					if(A.difficulty >= E.difficulty)
						return TRUE
					else
						hazards -= A
				else
					if(A.difficulty == E.difficulty)
						return TRUE

// We don't subtype /obj/overmap/visitable because that'll create sections one can travel to
//  And with them "existing" on the overmap Z-level things quickly get odd.
/obj/overmap/event
	name = "event"
	icon = 'icons/obj/overmap.dmi'
	icon_state = "blank"
	opacity = 1
	color = "#bb0000"

	/// For events which require coordinated randomness (overmap event datums with coordinated = TRUE)
	var/datum/prng/block/rng = null

	var/list/events
	var/list/event_icon_states
	var/difficulty = EVENT_LEVEL_MODERATE
	var/weaknesses //if the BSA can destroy them and with what
	var/list/victims //basically cached events on which Z level

	var/list/colors = list() //Pick a color from this list on init

	// Events must be detected by sensors, but are otherwise instantly visible.
	requires_contact = TRUE
	instant_contact = TRUE

/obj/overmap/event/Initialize(seed)
	. = ..()
	icon_state = pick(event_icon_states)
	overmap_event_handler.update_hazards(loc)
	if(length(colors))
		color = pick(colors)
	rng = new(seed)

/obj/overmap/event/Move()
	var/turf/old_loc = loc
	. = ..()
	if(.)
		overmap_event_handler.update_hazards(old_loc)
		overmap_event_handler.update_hazards(loc)

/obj/overmap/event/forceMove(atom/destination)
	var/old_loc = loc
	. = ..()
	if(.)
		overmap_event_handler.update_hazards(old_loc)
		overmap_event_handler.update_hazards(loc)

/obj/overmap/event/Destroy()//takes a look at this one as well, make sure everything is A-OK
	var/turf/T = loc
	. = ..()
	overmap_event_handler.update_hazards(T)

/obj/overmap/event/meteor
	name = "asteroid field"
	events = list(/datum/event/meteor_wave/overmap)
	event_icon_states = list("meteor1", "meteor2", "meteor3", "meteor4")
	difficulty = EVENT_LEVEL_MAJOR
	opacity = 0
	weaknesses = OVERMAP_WEAKNESS_MINING | OVERMAP_WEAKNESS_EXPLOSIVE
	colors = list("#fc1100", "#ca3227", "#be1e12")

/obj/overmap/event/electric
	name = "electrical storm"
	events = list(/datum/event/electrical_storm)
	opacity = 0
	event_icon_states = list("electrical1", "electrical2", "electrical3", "electrical4")
	difficulty = EVENT_LEVEL_MAJOR
	weaknesses = OVERMAP_WEAKNESS_EMP
	colors = list("#f5ed0c", "#f0e935", "#faf450")

/obj/overmap/event/dust
	name = "dust cloud"
	events = list(/datum/event/dust)
	opacity = 0
	event_icon_states = list("dust1", "dust2", "dust3", "dust4")
	weaknesses = OVERMAP_WEAKNESS_MINING | OVERMAP_WEAKNESS_EXPLOSIVE | OVERMAP_WEAKNESS_FIRE
	color = "#bdbdbd"

/obj/overmap/event/ion
	name = "ion cloud"
	events = list(/datum/event/ionstorm, /datum/event/computer_damage)
	opacity = 0
	event_icon_states = list("ion1", "ion2", "ion3", "ion4")
	difficulty = EVENT_LEVEL_MAJOR
	weaknesses = OVERMAP_WEAKNESS_EMP
	colors = list("#02faee", "#34d1c9", "#1b9ce7")

/obj/overmap/event/carp
	name = "carp shoal"
	events = list(/datum/event/mob_spawning/carp)
	opacity = 0
	difficulty = EVENT_LEVEL_MODERATE
	event_icon_states = list("carp1", "carp2")
	weaknesses = OVERMAP_WEAKNESS_EXPLOSIVE | OVERMAP_WEAKNESS_FIRE
	colors = list("#a960dd", "#cd60d3", "#ea50f2", "#f67efc")

	// did you know? 33% of all carp live an active lifestyle
	var/const/movement_chance = 33
	/// Chance to turn in either direction on updating movement
	var/turn_chance = 50
	/// Chance for the carp to stay still instead of moving
	var/stop_move_chance = 10
	/// How often to update movement
	var/movement_update_rate = 1 MINUTES
	var/next_update = INFINITY

	/// Slowest speed the carp can go
	var/migration_speed_min = 1 / (1.9 MINUTES)
	/// Fastest the carp can go
	var/migration_speed_max = 1 / (1.5 MINUTES)
	var/migration_speed = 0

/obj/overmap/event/carp/Initialize(_, seed)
	. = ..(seed)

	if (rng.chance(movement_chance))
		make_movable()
		dir = rng.random_dir()
		// Give the crew some time to get set up before carp begin to move (game time)
		addtimer(new Callback(src, PROC_REF(do_movement)), 18 MINUTES + rng.random(0, 4 MINUTES))

/obj/overmap/event/carp/Process()
	..()
	if (world.time > next_update)
		do_movement()

/obj/overmap/event/carp/proc/do_movement()
	next_update = world.time + movement_update_rate
	update_movement()

/// Turn up to 45 degrees and change speeds
/obj/overmap/event/carp/proc/update_movement()
	adjust_speed(-speed[1], -speed[2])

	if (rng.chance(turn_chance))
		dir = turn(dir, (rng.chance(50) * -1) * 45)

	if (rng.chance(stop_move_chance))
		return

	var/dir_x = SIGN((dir & EAST) * 1 + (dir & WEST) * -1)
	var/dir_y = SIGN((dir & NORTH) * 1 + (dir & SOUTH) * -1)
	if (dir_x == dir_y && dir_x == 0)
		return

	// pick a new speed
	migration_speed = migration_speed_min + (rng.random() * (migration_speed_max - migration_speed_min))
	adjust_speed(dir_x * migration_speed, dir_y * migration_speed)

/obj/overmap/event/carp/major
	name = "carp school"
	difficulty = EVENT_LEVEL_MAJOR
	event_icon_states = list("carp3", "carp4")
	colors = list("#a709db", "#c228c7", "#c444e4")

	stop_move_chance = 5

/obj/overmap/event/gravity
	name = "dark matter influx"
	weaknesses = OVERMAP_WEAKNESS_EXPLOSIVE
	events = list(/datum/event/gravity)
	event_icon_states = list("grav1", "grav2", "grav3", "grav4")
	opacity = 0
	colors = list("#9e5bd1", "#9339d8", "#9121e7")

//These now are basically only used to spawn hazards. Will be useful when we need to spawn group of moving hazards
/datum/overmap_event
	var/name = "map event"
	var/radius = 2
	var/count = 6
	var/hazards
	var/opacity = 1
	/// Should it coordinate random rolls (use the same seed)
	var/coordinated = FALSE
	var/continuous = TRUE //if it should form continous blob, or can have gaps

/datum/overmap_event/meteor
	name = "asteroid field"
	count = 15
	radius = 4
	continuous = FALSE
	hazards = /obj/overmap/event/meteor

/datum/overmap_event/electric
	name = "electrical storm"
	count = 11
	radius = 3
	opacity = 0
	hazards = /obj/overmap/event/electric

/datum/overmap_event/dust
	name = "dust cloud"
	count = 16
	radius = 4
	hazards = /obj/overmap/event/dust

/datum/overmap_event/ion
	name = "ion cloud"
	count = 8
	radius = 3
	opacity = 0
	hazards = /obj/overmap/event/ion

/datum/overmap_event/carp
	name = "carp shoal"
	count = 8
	radius = 3
	opacity = 0
	continuous = FALSE
	hazards = /obj/overmap/event/carp

/datum/overmap_event/carp/major
	name = "carp school"
	count = 5
	radius = 3
	coordinated = TRUE
	continuous = TRUE
	hazards = /obj/overmap/event/carp/major

/datum/overmap_event/gravity
	name = "dark matter influx"
	count = 12
	radius = 4
	opacity = 0
	hazards = /obj/overmap/event/gravity
