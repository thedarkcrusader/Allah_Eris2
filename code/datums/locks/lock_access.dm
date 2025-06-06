/// Check if obj has a lock datum and optionally if it uses a key
/obj/proc/lock_check(key = FALSE)
	if(!lock || !istype(lock, /datum/lock))
		return FALSE
	if(key && !lock.uses_key)
		return FALSE
	return TRUE

/// Query lock datum if we are locked or return false if no lock datum
/obj/proc/locked()
	if(!lock_check())
		return FALSE
	return lock.locked

/obj/proc/lock_toggle()
	if(!lock_check())
		return FALSE
	lock.toggle()

/obj/proc/lock()
	if(!lock_check())
		return FALSE
	lock.lock()

/obj/proc/unlock()
	if(!lock_check())
		return FALSE
	lock.unlock()

/// Override for interaction blocking and feedback
/obj/proc/pre_lock_interact(mob/user)
	return TRUE

/// Called when our key fails to toggle the lock
/obj/proc/lock_failed(mob/user, silent = FALSE, message)
	var/used_message = "This isn't the right key for [src]."
	if(message)
		used_message = message
	to_chat(user, span_notice(used_message))
	rattle(silent)

/// Shake a bit make a noise
/obj/proc/rattle(silent = FALSE)
	if(!silent && rattle_sound)
		playsound(get_turf(src), rattle_sound, 100)
	var/oldx = pixel_x
	animate(src, pixel_x = oldx + 1, time = 0.5)
	animate(pixel_x = oldx - 1, time = 0.5)
	animate(pixel_x = oldx, time = 0.5)

/// Called when locked
/obj/proc/on_lock(mob/user, silent = FALSE)
	if(!silent && lock_sound)
		playsound(get_turf(src), lock_sound, 100)
		user.visible_message(span_notice("[user] locks \the [src]."), span_notice("I lock \the [src]"), span_notice("I hear a click."))
		return
	to_chat(user, span_notice("I lock \the [src]."))

/// Called when unlocked
/obj/proc/on_unlock(mob/user, silent = FALSE)
	if(!silent && unlock_sound)
		playsound(get_turf(src), unlock_sound, 100)
		user.visible_message(span_notice("[user] unlocks \the [src]."), span_notice("I unlock \the [src]"), span_notice("I hear a click."))
		return
	to_chat(user, span_notice("I unlock \the [src]."))

/// Somethings might care when a lock is added to them
/obj/proc/on_lock_add(mob/user)
	return

/// Copy obj access to another obj returns success
/obj/proc/copy_access(obj/O)
	if(!O.has_access())
		return FALSE
	lockids = O.get_access()
	return TRUE

/// Returns obj access list copy or null
/obj/proc/get_access()
	if(!length(lockids))
		return null
	return lockids.Copy()

/// Check if obj has access set
/obj/proc/has_access()
	var/list/access = get_access()
	if(!islist(access) || !length(access))
		return FALSE
	return TRUE

/// Access to english string
/obj/proc/access2string()
	var/list/access = get_access()
	if(!islist(access) || !length(access))
		return
	return english_list(access)
