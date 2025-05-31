/datum/status_effect/frost_trap
	id = "frozen_trapped"
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/freon
	var/icon/cube

/datum/status_effect/frost_trap/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_attacked))
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	owner.add_overlay(cube)

/datum/status_effect/frost_trap/proc/on_attacked(datum/source, damage,type,zone)
	to_chat(owner, span_danger("The ice around me violently shatters; damaging me further!"))
	owner.remove_status_effect(/datum/status_effect/frost_trap)
	owner.apply_damage(damage,type,zone)
	return

/datum/status_effect/frost_trap/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	owner.cut_overlay(cube)
	UnregisterSignal(owner,COMSIG_MOB_APPLY_DAMGE)
	return ..()
