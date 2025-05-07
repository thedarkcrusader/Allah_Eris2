/obj/abstract/weather_system
	var/wind_direction =    0   // Bitflag; current wind direction.
	var/wind_strength =     1   // How strong is the wind currently?
	var/const/base_wind_delay = 0.5 // What is the base movement delay or increase applied by wind strength?

// Randomizes wind speed and direction sometimes.
/obj/abstract/weather_system/proc/handle_wind()
	// TODO: turbulence for chance of wind changes,
	// ferocity for strength of wind changes
	if(prob(66))
		return
	if(prob(10))
		if(!wind_direction)
			wind_direction = pick(GLOB.alldirs)
		else
			wind_direction = turn(wind_direction, pick(45, -45))
		mob_shown_wind.Cut()
	if(prob(10))
		var/old_strength = wind_strength
		wind_strength = clamp(wind_strength + rand(-1, 1), -1, 5)
		if(wind_strength < 0)
			wind_strength = abs(wind_strength)
			wind_direction = turn(wind_direction, 180)
		if(old_strength != wind_strength)
			mob_shown_wind.Cut()
	update_particle_system()

/obj/abstract/weather_system/proc/update_particle_system()
	for(var/obj/abstract/weather_particles/particle_source in particle_sources)
		particle_source.update_particle_system(src)

/obj/abstract/weather_system/proc/show_wind(mob/M, force = FALSE)
	var/mob_ref = weakref(M)
	if(mob_shown_wind[mob_ref] && !force)
		return FALSE
	mob_shown_wind[mob_ref] = TRUE
	. = TRUE
	var/turf/T = get_turf(M)
	if(istype(T))
		var/datum/gas_mixture/environment = T.return_air()
		if(environment && environment.return_pressure() >= MIN_WIND_PRESSURE) // Arbitrary low pressure bound.
			var/absolute_strength = abs(wind_strength)
			if(absolute_strength <= 0.5 || !wind_direction)
				to_chat(M, SPAN_NOTICE(FONT_SMALL("The wind is calm.")))
			else
				to_chat(M, SPAN_NOTICE(FONT_SMALL("The wind is blowing[absolute_strength > 2 ? " strongly" : ""] towards the [dir2text(wind_direction)].")))
