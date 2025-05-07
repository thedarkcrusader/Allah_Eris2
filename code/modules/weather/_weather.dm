/*
 * Notes on weather:
 *
 * - Weather is a single object that sits in the vis_contents of all outside turfs on
 *   its associated z-levels and is removed or added by /turf/proc/update_weather(),
 *   which is usually called from /turf/proc/set_outside().
 *
 * - Weather generally assumes any atom that cares about it will ask it directly and
 *   mobs do this in /mob/living/proc/handle_environment().
 *
 * - For this system to be scalable, it should minimize the amount of list-based
 *   processing it does and be primarily passive, allowing mobs to ignore it or
 *   poll it on their own time.
 *
 * - The weather object is queued on SSweather and is polled every fifteen seconds at time
 *   of writing. This is handled in /obj/abstract/weather_system/proc/tick().
 *
 * - When evaluating, weather will generally get more intense or more severe rather than
 *   jumping around randomly. Each state will set a minimum duration based on min/max time.
 *
 * - If polled between weather updates there is a chance of modifying wind speed and direction
 *   instead.
 */

/obj/abstract
	mouse_opacity = 0

/obj/abstract/weather_system
	plane             = DEFAULT_PLANE
	layer             = ABOVE_PROJECTILE_LAYER
	icon              = 'icons/effects/weather.dmi'
	icon_state        = "blank"
	invisibility      = INVISIBILITY_NONE
	appearance_flags  = (RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)

	// List of /singleton/state types that are forbidden.
	var/list/banned_weather_conditions

	var/obj/overmap/visitable/sector/exoplanet/planet //Optional planet to derive info from -> Could be generic visitable if expanded
	var/water_colour = COLOR_WATER    // Material to use for the properties of rain.
	var/ice_colour=   COLOR_ICE          // Material to use for the properties of snow and hail.

	var/list/affecting_zs                                // What z-levels are we affecting?
	var/datum/state_machine/weather/weather_system       // What is our internal state and how do we decide what state to use?
	var/next_weather_transition = 0                      // What world.time will we next evaluate our state?

	var/obj/abstract/lightning_overlay/lightning_overlay // A visible atom used for animated lighting effects.
	var/list/vis_contents_additions                  // Holder for a list used to add required atoms to turf vis_contents.
	/// A list of particle sources to randomize particle-based effects per-turf.
	var/list/obj/abstract/weather_particles/particle_sources = newlist(
		/obj/abstract/weather_particles,
		/obj/abstract/weather_particles,
		/obj/abstract/weather_particles,
		/obj/abstract/weather_particles
	)

// Main heartbeat proc, called by SSweather.
/obj/abstract/weather_system/proc/tick()

	// Check if we should move to a new state.
	if(world.time >= next_weather_transition)
		weather_system.evaluate()

	// Change wind direction and speed.
	handle_wind()

	// Handle periodic effects for ticks (like lightning)
	var/singleton/state/weather/rain/weather_state = weather_system.current_state
	if(istype(weather_state))
		weather_state.tick(src)


/obj/abstract/weather_system/Destroy()
	// Clean ourselves out of the vis_contents of our affected turfs.
	for(var/tz in affecting_zs)
		for(var/turf/T as anything in block(locate(1, 1, tz), locate(world.maxx, world.maxy, tz)))
			if(T.weather == src)
				T.weather = null
				T.refresh_vis_contents()
	vis_contents_additions.Cut()
	SSweather.unregister_weather_system(src)
	QDEL_NULL(lightning_overlay)
	. = ..()

// Called by /turf/examine() to show current weather status.
/obj/abstract/weather_system/examine(mob/user, distance)
	SHOULD_CALL_PARENT(FALSE)
	var/singleton/state/weather/weather_state = weather_system.current_state
	if(istype(weather_state))
		to_chat(user, SPAN_NOTICE(FONT_SMALL(weather_state.descriptor)))
	show_wind(user, force = TRUE)

// Called by /singleton/state/weather to assess validity of a state in the weather FSM.
/obj/abstract/weather_system/proc/supports_weather_state(singleton/state/weather/next_state)
	if(!istype(next_state))
		return FALSE

	//Here you would check if planet provides a reagent for rain
	// Not implemented but worth tracking for acid rain and other exotic weather phenomena in the future
	// if(next_state.is_liquid && isnull(water_material))
	// 	return FALSE
	// if(next_state.is_ice && isnull(ice_material))
	// 	return FALSE

	//Assumption ice is actual ice. You can get some forms of rain even in hot planets but ice needs that cool factor
	if (next_state.is_ice)
		if (planet && planet.exterior_atmosphere && planet.exterior_atmosphere.temperature > 5 CELSIUS)
			return FALSE

	if(length(banned_weather_conditions) && (next_state.type in banned_weather_conditions))
		return FALSE
	return TRUE

// Dummy object for lightning flash animation.
/obj/abstract/lightning_overlay
	plane             = EMISSIVE_PLANE
	layer             = ABOVE_LIGHTING_LAYER
	icon              = 'icons/effects/weather.dmi'
	icon_state        = "full"
	alpha             = 0
	invisibility      = INVISIBILITY_NONE
	appearance_flags  = RESET_COLOR | KEEP_APART

// Dummy object for weather particles.
/obj/abstract/weather_particles
	icon              = null
	invisibility      = INVISIBILITY_NONE
	appearance_flags  = RESET_COLOR | KEEP_APART
	layer             = ABOVE_PROJECTILE_LAYER

/obj/abstract/weather_particles/proc/update_particle_system(obj/abstract/weather_system/holder)
	if(!istype(particles, /particles/weather))
		return
	var/particles/weather/weather_particles = particles
	weather_particles.color = holder.color // sync color
	alpha = holder.alpha // sync alpha
	// reset rotation and velocity
	weather_particles.rotation = 0
	weather_particles.velocity = generator("vector", weather_particles.base_velocity[1], weather_particles.base_velocity[2], NORMAL_RAND)
	if(holder.wind_direction != 0 && holder.wind_strength != 0) // direction is set
		// rain always falls down, but if the wind is east or west
		// then it also gets a little bit of side momentum
		// based on the horizontal component of the direction
		var/wind_angle = 90 - dir2angle(holder.wind_direction) // byond's coordinate axis is fucky
		var/x_wind_vel = cos(wind_angle) * holder.wind_strength
		var/z_wind_vel = sin(wind_angle) * holder.wind_strength // experimental!
		// tilt to an angle that makes sense for our min/max velocity
		// 0 is south, but if our velocity is pure south we get -90, so add 90
		// and then invert it, because byond uses counter-clockwise and we want clockwise
		weather_particles.rotation = generator("num", 90 - arctan(x_wind_vel * 0.50, weather_particles.base_velocity[1][2]), 90 - arctan(x_wind_vel, weather_particles.base_velocity[2][2]), NORMAL_RAND)
		weather_particles.velocity += generator("vector", list(0, 0, 0), list(x_wind_vel, 0, z_wind_vel), NORMAL_RAND)
