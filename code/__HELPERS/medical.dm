/proc/parse_zone(zone)
	switch(zone)
		if(BODY_ZONE_PRECISE_R_HAND)
			return "right hand"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "left hand"
		if(BODY_ZONE_L_ARM)
			return "left arm"
		if(BODY_ZONE_R_ARM)
			return "right arm"
		if(BODY_ZONE_L_LEG)
			return "left leg"
		if(BODY_ZONE_R_LEG)
			return "right leg"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "left foot"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "right foot"
		if(BODY_ZONE_PRECISE_NECK)
			return "throat"
		if(BODY_ZONE_PRECISE_GROIN)
			return "groin"
		if(BODY_ZONE_PRECISE_EARS)	//we want the chatlog to say 'grabbed his ear' not 'grabbed his ears' etc
			return "ear"
		if(BODY_ZONE_PRECISE_R_EYE)
			return "right eye"
		if(BODY_ZONE_PRECISE_L_EYE)
			return "left eye"
		if(BODY_ZONE_PRECISE_NOSE)
			return "nose"
		if(BODY_ZONE_PRECISE_R_INHAND)
			return "right hand"
		if(BODY_ZONE_PRECISE_L_INHAND)
			return "left hand"
		if(BODY_ZONE_PRECISE_SKULL)
			return "skull"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "mouth"
	return zone

/proc/parse_organ_slot(slot)
	switch(slot)
		if(ORGAN_SLOT_BRAIN)
			return "brain"
		if(ORGAN_SLOT_APPENDIX)
			return "appendix"
		if(ORGAN_SLOT_STOMACH)
			return "stomach"
		if(ORGAN_SLOT_GUTS)
			return "guts"
		if(ORGAN_SLOT_EARS)
			return "ears"
		if(ORGAN_SLOT_EYES)
			return "eyes"
		if(ORGAN_SLOT_LUNGS)
			return "lungs"
		if(ORGAN_SLOT_HEART)
			return "heart"
		if(ORGAN_SLOT_LIVER)
			return "liver"
		if(ORGAN_SLOT_TONGUE)
			return "tongue"
		if(ORGAN_SLOT_VOICE)
			return "vocal cords"
		if(ORGAN_SLOT_TAIL)
			return "tail"
	return slot
