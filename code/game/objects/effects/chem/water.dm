/obj/effect/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	mouse_opacity = 0
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE

/obj/effect/water/New(loc)
	..()
	QDEL_IN(src, 15 SECONDS) // In case whatever made it forgets to delete it

/obj/effect/water/proc/set_up(turf/target, step_count = 5, delay = 5)
	set waitfor = FALSE
	if(!target)
		return
	for(var/i = 1 to step_count)
		if(!loc)
			return
		step_towards(src, target)
		var/turf/T = get_turf(src)
		if(T && reagents)
			var/list/splash_mobs = list()
			var/list/splash_others = list(T)
			for(var/atom/A in T)
				if(A.simulated)
					if(!ismob(A))
						splash_others += A
					else if(isliving(A))
						splash_mobs += A

			//each step splash 1/5 of the reagents on non-mobs
			//could determine the # of steps until target, but that would be complicated
			for(var/atom/A in splash_others)
				reagents.splash(A, (reagents.total_volume/step_count)/length(splash_others))
			for(var/mob/living/M in splash_mobs)
				reagents.splash(M, reagents.total_volume/length(splash_mobs))
			if(reagents.total_volume < 1)
				break
			if(T == get_turf(target))
				var/list/splash_targets = splash_others + splash_mobs
				var/splash_amount = reagents.total_volume / length(splash_targets)
				for(var/atom/atom in splash_targets)
					reagents.splash(atom, splash_amount)
				break

		sleep(delay)
	sleep(10)
	qdel(src)

/obj/effect/water/Move(turf/newloc)
	if(newloc.density)
		return 0
	. = ..()

/obj/effect/water/Bump(atom/A, called)
	if(reagents)
		reagents.touch(A)
	return ..()

//Used by spraybottles.
/obj/effect/water/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	icon_state = ""

/obj/effect/water/chempuff/on_reagent_change(max_vol)
	if (reagents)
		set_color(reagents.get_color())
