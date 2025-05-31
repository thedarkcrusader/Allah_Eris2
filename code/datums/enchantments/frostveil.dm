/datum/enchantment/frostveil
	enchantment_name = "Frostveil"
	examine_text = "It feels rather cold."
	var/last_used

/datum/enchantment/frostveil/on_hit(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(world.time < src.last_used + 100)
		return
	if(isliving(target))
		var/mob/living/targeted = target
		targeted.apply_status_effect(/datum/status_effect/debuff/cold)
		targeted.visible_message(span_danger("[source] chills [targeted]!"))
		src.last_used = world.time

/datum/enchantment/frostveil/on_hit_response(obj/item/I, mob/living/carbon/human/owner, mob/living/carbon/human/attacker)
	if(world.time < src.last_used + 100)
		return
	if(isliving(attacker))
		attacker.apply_status_effect(/datum/status_effect/debuff/cold)
		attacker.visible_message(span_danger("[I] chills [attacker]!"))
		src.last_used = world.time
