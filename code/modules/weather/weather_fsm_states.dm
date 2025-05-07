/singleton/state/weather

	abstract_type = /singleton/state/weather

	var/name =         "Undefined"
	var/descriptor =   "The weather is undefined."

	var/cosmetic_message_chance = 5
	var/list/cosmetic_messages
	var/list/protected_messages
	var/cosmetic_span_class = "notice"

	var/icon = 'icons/effects/weather.dmi'
	var/icon_state
	var/particles/weather/particle_system

	var/alpha =        170
	var/minimum_time = 2 MINUTES
	var/maximum_time = 10 MINUTES
	var/is_liquid =    FALSE
	var/is_ice =       FALSE

	var/list/ambient_sounds
	var/list/ambient_indoors_sounds

/particles/weather
	width = 32
	height = 32
	bound1 = list(-16, -16, -20)
	bound2 = list(20, 20, 20)
	count = 100
	spawning = 2
	lifespan = 2 SECONDS // they'll hopefully hit the bounds long before this runs out
	// basic 3d projection matrix
	// 16px in the z axis = 1 in the y axis, because perspective memes i guess?
	transform = list(
		1,  0,    0,  0,
		0,  1,    0,  0,
		0,  1/16, 0,  0,
		0,  0,    0,  1,
	)
	fadein = 1
	position = generator("box", list(-16, 16, -16), list(20, 20, 20)) // start at the top in the Y axis
	/// How much does (east/west) wind affect the horizontal component of the particles?
	var/wind_intensity = 2
	/// What is the non-wind-affected velocity component of the particles?
	/// A list of two lists (minimum and maximum velocities) passed to a generator.
	var/list/base_velocity = list(list(0, -6, 0), list(0, -10, 0))

/singleton/state/weather/entered_state(datum/holder)
	. = ..()

	var/obj/abstract/weather_system/weather = holder
	weather.next_weather_transition = world.time + rand(minimum_time, maximum_time)
	weather.mob_shown_weather.Cut()
	weather.icon = icon
	weather.icon_state = icon_state
	weather.alpha = alpha

	if(is_liquid)
		weather.color = weather.water_colour
	else if(is_ice)
		weather.color = weather.ice_colour
	else
		weather.color = COLOR_WHITE

	if(ispath(particle_system))
		for(var/obj/abstract/weather_particles/particle_source in weather.particle_sources)
			particle_source.particles = new particle_system() // separate datums so that you could make some turfs have special effects in the future
		weather.update_particle_system() // sync wind, etc.
	else
		for(var/obj/abstract/weather_particles/particle_source in weather.particle_sources)
			if(particle_source.particles)
				QDEL_NULL(particle_source.particles)

/singleton/state/weather/proc/tick(obj/abstract/weather_system/weather)
	return

/singleton/state/weather/proc/handle_roofed_effects(mob/living/M, obj/abstract/weather_system/weather)
	return

/singleton/state/weather/proc/handle_protected_effects(mob/living/M, obj/abstract/weather_system/weather, obj/item/protected_by)
	if(prob(cosmetic_message_chance))
		if(protected_by && length(protected_messages))
			if(protected_by.loc == M)
				to_chat(M, "<span class='[cosmetic_span_class]'>[replacetext(pick(protected_messages), "$ITEM$", "your [protected_by.name]")]</span>")
			else
				to_chat(M, "<span class='[cosmetic_span_class]'>[replacetext(pick(protected_messages), "$ITEM$", "\the [protected_by]")]</span>")
		else if(length(cosmetic_messages))
			to_chat(M, "<span class='[cosmetic_span_class]'>[pick(cosmetic_messages)]</span>")

/singleton/state/weather/proc/handle_exposure_effects(mob/living/M, obj/abstract/weather_system/weather)
	handle_protected_effects(M, weather)

/singleton/state/weather/proc/handle_exposure(mob/living/M, exposure, obj/abstract/weather_system/weather)
	if(exposure == WEATHER_IGNORE || !weather.set_cooldown(M))
		return
	if(exposure == WEATHER_EXPOSED)
		handle_exposure_effects(M, weather)
	else if(exposure == WEATHER_ROOFED)
		handle_roofed_effects(M, weather)
	else if(exposure == WEATHER_PROTECTED)
		var/list/protected_by = M.get_weather_protection()
		if(LAZYLEN(protected_by))
			handle_protected_effects(M, weather, pick(protected_by))

/singleton/state/weather/proc/adjust_temperature(initial_temperature)
	return initial_temperature

/singleton/state/weather/proc/show_to(mob/living/M, obj/abstract/weather_system/weather)
	to_chat(M, descriptor)

/singleton/state/weather/calm
	name = "Calm"
	icon_state = "blank"
	descriptor = "The weather is calm."
	transitions = list(
		/singleton/state_transition/weather/cold,
		/singleton/state_transition/weather/rain
	)

/singleton/state/weather/cold
	name = "Cold"
	icon_state = "blank"
	descriptor = "There is a chill on the breeze."
	transitions = list(
		/singleton/state_transition/weather/calm,
		/singleton/state_transition/weather/snow,
		/singleton/state_transition/weather/rain
	)

/singleton/state/weather/cold/adjust_temperature(initial_temperature)
	return max(initial_temperature - 10, min(initial_temperature, T0C))

/singleton/state/weather/snow
	name = "Light Snow"
	icon_state = "snowfall_light"
	descriptor = "It is snowing gently."
	is_ice = TRUE
	transitions = list(
		/singleton/state_transition/weather/calm,
		/singleton/state_transition/weather/rain,
		/singleton/state_transition/weather/snow_medium
	)
	ambient_sounds =     list('sound/effects/weather/snow.ogg')
	protected_messages = list("Snowflakes collect atop $ITEM$.")
	cosmetic_messages =  list(
		"Snowflakes fall slowly around you.",
		"Flakes of snow drift gently past."
	)

/singleton/state/weather/snow/adjust_temperature(initial_temperature)
	return min(initial_temperature - 20, T0C)

/singleton/state/weather/snow/medium
	name =  "Snow"
	icon_state = "snowfall_med"
	descriptor = "It is snowing."
	transitions = list(
		/singleton/state_transition/weather/snow,
		/singleton/state_transition/weather/snow_heavy
	)

/singleton/state/weather/snow/heavy/adjust_temperature(initial_temperature)
	return min(initial_temperature - 25, T0C)

/singleton/state/weather/snow/heavy
	name =  "Heavy Snow"
	icon_state = "snowfall_heavy"
	descriptor = "It is snowing heavily."
	transitions =       list(/singleton/state_transition/weather/snow_medium)
	cosmetic_messages = list(
		"Gusting snow obscures your vision.",
		"Thick flurries of snow swirl around you."
	)
	cosmetic_span_class = "warning"

/singleton/state/weather/snow/heavy/adjust_temperature(initial_temperature)
	return min(initial_temperature - 30, T0C)

/singleton/state/weather/rain
	name =  "Light Rain"
	icon_state = null//"rain"
	particle_system = /particles/weather/rain
	descriptor = "It is raining gently."
	cosmetic_span_class = "notice"
	is_liquid = TRUE
	transitions = list(
		/singleton/state_transition/weather/calm,
		/singleton/state_transition/weather/storm
	)
	ambient_sounds =         list('sound/effects/weather/rain.ogg')
	ambient_indoors_sounds = list('sound/effects/weather/rain_indoors.ogg')
	cosmetic_messages =      list("Raindrops patter against you.")
	protected_messages =     list("Raindrops patter against $ITEM$.")
	var/list/roof_messages = list("Rain patters against the roof.")

/singleton/state/weather/rain/hail/handle_exposure_effects(mob/living/M, obj/abstract/weather_system/weather)
	to_chat(M, SPAN_NOTICE("The rain douses you!"))
	//Do something here so it's like splashing water


/particles/weather/rain
	icon = 'icons/effects/weather.dmi'
	icon_state = "rain_particle" // animated particles don't seem to work...
	wind_intensity = 1

/singleton/state/weather/rain/handle_roofed_effects(mob/living/M, obj/abstract/weather_system/weather)
	if(length(roof_messages) && prob(cosmetic_message_chance))
		to_chat(M, "<span class='[cosmetic_span_class]'>[pick(roof_messages)]</span>")

/singleton/state/weather/rain/storm
	name =  "Heavy Rain"
	icon_state = null // "storm"
	particle_system = /particles/weather/rain/storm
	descriptor = "It is raining heavily."
	cosmetic_span_class = "warning"
	transitions = list(
		/singleton/state_transition/weather/rain,
		/singleton/state_transition/weather/hail
	)
	cosmetic_messages =  list("Torrential rain thunders down around you.")
	protected_messages = list("Torrential rain thunders against $ITEM$.")
	roof_messages =      list("Torrential rain thunders against the roof.")
	ambient_sounds =     list('sound/effects/weather/rain_heavy.ogg')

/particles/weather/rain/storm
	wind_intensity = 3
	spawning = 5
	count = 200

/singleton/state/weather/rain/storm/tick(obj/abstract/weather_system/weather)
	..()
	if(prob(0.5))
		weather.lightning_strike()

/singleton/state/weather/rain/hail
	name =  "Hail"
	icon_state = "hail"
	particle_system = null
	descriptor = "It is hailing."
	cosmetic_span_class = "danger"
	is_liquid = FALSE
	is_ice = TRUE
	transitions =            list(/singleton/state_transition/weather/storm)
	cosmetic_messages =      list("Hail patters around you.")
	protected_messages =     list("Hail patters against $ITEM$.")
	roof_messages =          list("Hail clatters on the roof.")
	ambient_sounds =         list('sound/effects/weather/rain.ogg')
	ambient_indoors_sounds = list('sound/effects/weather/hail_indoors.ogg')

/singleton/state/weather/rain/hail/handle_exposure_effects(mob/living/M, obj/abstract/weather_system/weather)
	to_chat(M, SPAN_DANGER("You are pelted by a shower of hail!"))
	M.damage_health(rand(1,3), DAMAGE_BRUTE)

/singleton/state/weather/ash
	name =  "Ash"
	icon_state = "ashfall_light"
	descriptor = "A rain of ash falls from the sky."
	cosmetic_span_class = "warning"
	cosmetic_messages = list("Drifts of ash fall from the sky.")
