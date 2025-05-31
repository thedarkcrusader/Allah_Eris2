/mob/living/carbon/human/proc/get_hair_color()
	var/datum/bodypart_feature/hair/feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if(!feature)
		return "FFFFFF"
	return feature.hair_color

/mob/living/carbon/human/proc/get_facial_hair_color()
	var/datum/bodypart_feature/hair/feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if(!feature)
		return "FFFFFF"
	return feature.hair_color

/mob/living/carbon/human/proc/get_eye_color()
	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return "FFFFFF"
	return eyes.eye_color

/mob/living/carbon/human/proc/get_chest_color()
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return null
	for(var/marking_name in chest.markings)
		var/datum/body_marking/marking = GLOB.body_markings[marking_name]
		if(!marking.covers_chest)
			continue
		var/marking_color = chest.markings[marking_name]
		return marking_color
	return null

/mob/living/carbon/proc/get_bodypart_feature_of_slot(feature_slot)
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		for(var/datum/bodypart_feature/feature as anything in bodypart.bodypart_features)
			if(feature.feature_slot == feature_slot)
				return feature
	return null


/mob/living/carbon/human/proc/set_hair_color(new_color, updates_body = TRUE)
	var/datum/bodypart_feature/hair/feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if(!feature)
		return
	feature.hair_color = new_color
	feature.accessory_colors = new_color
	if(updates_body)
		update_body_parts()

/mob/living/carbon/human/proc/set_facial_hair_color(new_color, updates_body = TRUE)
	var/datum/bodypart_feature/hair/feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if(!feature)
		return
	feature.hair_color = new_color
	if(updates_body)
		update_body_parts()

/mob/living/carbon/human/proc/set_eye_color(new_color, new_secondary_color, updates_body = TRUE)
	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	eyes.eye_color = new_color
	if(new_secondary_color)
		eyes.second_color = new_secondary_color
	if(updates_body)
		update_body_parts()

/mob/living/carbon/human/proc/set_hair_style(datum/sprite_accessory/hair/head/style, updates_body = TRUE)
	if(!ispath(style) && !istype(style))
		return
	if(istype(style))
		style = style.type
	var/datum/bodypart_feature/hair/feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if(!feature)
		return
	feature.accessory_type = style
	if(updates_body)
		update_body_parts()

/mob/living/carbon/human/proc/set_facial_hair_style(datum/sprite_accessory/hair/facial/style, updates_body = TRUE)
	if(!ispath(style) && !istype(style))
		return
	if(istype(style))
		style = style.type
	var/datum/bodypart_feature/hair/feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if(!feature)
		return
	feature.accessory_type = style
	if(updates_body)
		update_body_parts()
