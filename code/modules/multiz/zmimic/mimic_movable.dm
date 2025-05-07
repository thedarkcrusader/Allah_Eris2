/// The mimic (if any) that's *directly* copying us.
/atom/movable/var/atom/movable/openspace/mimic/bound_overlay
/// If TRUE, this atom is ignored by Z-Mimic.
/atom/movable/var/z_flags

/atom/movable/forceMove(atom/dest)
	. = ..(dest)
	if (. && bound_overlay)
		// The overlay will handle cleaning itself up on non-openspace turfs.
		if (isturf(dest))
			bound_overlay.forceMove(get_step(src, UP))
			if (dir != bound_overlay.dir)
				bound_overlay.set_dir(dir)
		else	// Not a turf, so we need to destroy immediately instead of waiting for the destruction timer to proc.
			qdel(bound_overlay)

/atom/movable/Move()
	. = ..()
	if (. && bound_overlay)
		bound_overlay.forceMove(get_step(src, UP))
		if (bound_overlay.dir != dir)
			bound_overlay.set_dir(dir)

/atom/movable/set_dir(ndir)
	. = ..()
	if (. && bound_overlay)
		bound_overlay.set_dir(ndir)

/atom/movable/update_above()
	if (!bound_overlay || !isturf(loc))
		return

	var/turf/T = loc

	if (TURF_IS_MIMICING(T.above))
		SSzcopy.queued_overlays += bound_overlay
		bound_overlay.queued += 1
	else
		qdel(bound_overlay)

// Grabs a list of every openspace object that's directly or indirectly mimicing this object. Returns an empty list if none found.
/atom/movable/proc/get_above_oo()
	. = list()
	var/atom/movable/curr = src
	while (curr.bound_overlay)
		. += curr.bound_overlay
		curr = curr.bound_overlay

// -- Openspace movables --

/atom/movable/openspace
	name = ""
	simulated = FALSE
	anchored = TRUE
	mouse_opacity = FALSE

/atom/movable/openspace/can_fall()
	return FALSE

// No blowing up abstract objects.
/atom/movable/openspace/ex_act(ex_sev)
	SHOULD_CALL_PARENT(FALSE)
	return

/atom/movable/openspace/singularity_act()
	return

/atom/movable/openspace/singularity_pull()
	return

/atom/movable/openspace/singuloCanEat()
	return

// -- MULTIPLIER / SHADOWER --

// Holder object used for dimming openspaces & copying lighting of below turf.
/atom/movable/openspace/multiplier
	name = "openspace multiplier"
	desc = "You shouldn't see this."
	icon = 'icons/effects/lighting_overlay.dmi'
	icon_state = LIGHTING_TRANSPARENT_ICON_STATE
	plane = OPENTURF_MAX_PLANE
	layer = MIMICED_LIGHTING_LAYER
	color = SHADOWER_DARKENING_COLOR
	//blend_mode = BLEND_MULTIPLY

/atom/movable/openspace/multiplier/Destroy()
	var/turf/myturf = loc
	if (istype(myturf))
		myturf.shadower = null

	return ..()

/atom/movable/openspace/multiplier/proc/copy_lighting(atom/movable/lighting_overlay/LO)
	appearance = LO
	layer = MIMICED_LIGHTING_LAYER
	plane = OPENTURF_MAX_PLANE
	invisibility = 0

	if (icon_state == LIGHTING_BASE_ICON_STATE)
		blend_mode = BLEND_MULTIPLY
		// We're using a color matrix, so just darken the colors across the board.
		var/list/c_list = color
		c_list[CL_MATRIX_RR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_RG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_RB] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_GR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_GG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_GB] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_BR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_BG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_BB] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_AR] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_AG] *= SHADOWER_DARKENING_FACTOR
		c_list[CL_MATRIX_AB] *= SHADOWER_DARKENING_FACTOR
		color = c_list

		//Hackfix until I look into planes a bit more, we copy the plane of turf
		var/turf/myturf = loc
		if (istype(myturf))
			plane = myturf.plane
	else
		// Not a color matrix, so we can just use the color var ourselves.
		color = (icon_state == LIGHTING_DARKNESS_ICON_STATE) ? COLOR_WHITE : SHADOWER_DARKENING_COLOR

	var/turf/parent = loc
	ASSERT(isturf(parent))
	UpdateOverlays()

	if (bound_overlay)
		update_above()

// -- OPENSPACE OVERLAY --
// todo: rename

// Object used to hold a mimiced atom's appearance.
/atom/movable/openspace/mimic
	plane = OPENTURF_MAX_PLANE
	var/atom/movable/associated_atom
	var/depth
	var/queued = 0
	var/destruction_timer
	var/mimiced_type
	var/original_z
	var/override_depth
	var/have_performed_fixup = FALSE

/atom/movable/openspace/mimic/New()
	SHOULD_CALL_PARENT(FALSE) // Probably a reason for this but I don't know it
	atom_flags |= ATOM_FLAG_INITIALIZED
	SSzcopy.openspace_overlays += 1

/atom/movable/openspace/mimic/Destroy()
	SSzcopy.openspace_overlays -= 1

	if (associated_atom)
		associated_atom.bound_overlay = null
		associated_atom = null

	if (destruction_timer)
		deltimer(destruction_timer)

	return ..()

/atom/movable/openspace/mimic/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return tool.resolve_attackby(loc, user, click_params)

/atom/movable/openspace/mimic/attack_hand(mob/user)
	to_chat(user, SPAN_NOTICE("You cannot reach \the [src] from here."))

/atom/movable/openspace/mimic/examine(...)
	SHOULD_CALL_PARENT(FALSE)
	. = associated_atom.examine(arglist(args))	// just pass all the args to the copied atom

/atom/movable/openspace/mimic/forceMove(turf/dest)
	. = ..()
	if (TURF_IS_MIMICING(dest))
		if (destruction_timer)
			deltimer(destruction_timer)
			destruction_timer = null
	else if (!destruction_timer)
		destruction_timer = QDEL_IN(src, 10 SECONDS)

// Called when the turf we're on is deleted/changed.
/atom/movable/openspace/mimic/proc/owning_turf_changed()
	if (!destruction_timer)
		destruction_timer = QDEL_IN(src, 10 SECONDS)

// -- TURF PROXY --

// This thing holds the mimic appearance for non-OVERWRITE turfs.
/atom/movable/openspace/turf_proxy
	plane = OPENTURF_MAX_PLANE
	mouse_opacity = 0
	z_flags = ZMM_IGNORE // Only one of these should ever be visible at a time, the mimic logic will handle that.

/atom/movable/openspace/turf_proxy/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return tool.resolve_attackby(loc, user, click_params)

/atom/movable/openspace/turf_proxy/attack_hand(mob/user as mob)
	loc.attack_hand(user)

/atom/movable/openspace/turf_proxy/attack_generic(mob/user as mob)
	loc.attack_generic(user)

/atom/movable/openspace/turf_proxy/examine(...)
	SHOULD_CALL_PARENT(FALSE)
	. = loc.examine(arglist(args))


// -- TURF MIMIC --

// A type for copying non-overwrite turfs' self-appearance.
/atom/movable/openspace/turf_mimic
	plane = OPENTURF_MAX_PLANE	// These *should* only ever be at the top?
	mouse_opacity = 0
	var/turf/delegate

/atom/movable/openspace/turf_mimic/Initialize(mapload, ...)
	. = ..()
	ASSERT(isturf(loc))
	delegate = loc:below

/atom/movable/openspace/turf_mimic/use_tool(obj/item/tool, mob/user, list/click_params)
	SHOULD_CALL_PARENT(FALSE)
	return tool.resolve_attackby(loc, user, click_params)

/atom/movable/openspace/turf_mimic/attack_hand(mob/user as mob)
	to_chat(user, SPAN_NOTICE("You cannot reach \the [src] from here."))

/atom/movable/openspace/turf_mimic/attack_generic(mob/user as mob)
	to_chat(user, SPAN_NOTICE("You cannot reach \the [src] from here."))

/atom/movable/openspace/turf_mimic/examine(...)
	SHOULD_CALL_PARENT(FALSE)
	. = delegate.examine(arglist(args))
