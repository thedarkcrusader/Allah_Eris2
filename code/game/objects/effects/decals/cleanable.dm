/obj/decal/cleanable
	density = FALSE
	anchored = TRUE
	waterproof = FALSE
	var/persistent = FALSE
	var/generic_filth = FALSE
	var/age = 0
	var/list/random_icon_states
	var/image/hud_overlay/hud_overlay

	var/cleanable_scent
	var/scent_intensity = /singleton/scent_intensity/normal
	var/scent_descriptor = SCENT_DESC_SMELL
	var/scent_range = 2

	var/weather_sensitive = TRUE

/obj/decal/cleanable/Initialize()
	. = ..()
	if(isspace(loc))
		return INITIALIZE_HINT_QDEL
	hud_overlay = new /image/hud_overlay('icons/obj/hud_tile.dmi', src, "caution")
	hud_overlay.plane = EFFECTS_ABOVE_LIGHTING_PLANE
	set_cleanable_scent()

	if(weather_sensitive)
		SSweather_atoms.weather_atoms += src

/obj/decal/cleanable/Initialize(ml, _age)
	if(!isnull(_age))
		age = _age
	if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	SSpersistence.track_value(src, /datum/persistent/filth)
	. = ..()

/obj/decal/cleanable/Destroy()
	SSpersistence.forget_value(src, /datum/persistent/filth)
	if(weather_sensitive)
		SSweather_atoms.weather_atoms -= src
	. = ..()

/obj/decal/cleanable/water_act(depth)
	..()
	qdel(src)

/obj/decal/cleanable/clean_blood(ignore = 0)
	if(!ignore)
		qdel(src)
		return
	..()

/obj/decal/cleanable/proc/set_cleanable_scent()
	if(cleanable_scent)
		set_extension(src, /datum/extension/scent/custom, cleanable_scent, scent_intensity, scent_descriptor, scent_range)

/obj/decal/cleanable/process_weather(obj/abstract/weather_system/weather, singleton/state/weather/weather_state)
	if(!weather_sensitive)
		return PROCESS_KILL
	if(weather_state.is_liquid)
		alpha -= 15
		if(alpha <= 0)
			qdel(src)
