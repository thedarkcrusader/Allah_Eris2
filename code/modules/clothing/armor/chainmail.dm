/obj/item/clothing/armor/chainmail
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	name = "haubergeon"
	desc = "Made out of interlocked steel rings. Offers superior resistance against arrows, stabs and cuts. \nUsually worn as padding for proper armor."
	icon_state = "haubergeon"
	blocksound = CHAINHIT
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel
	sellprice = VALUE_STEEL_ARMOR

	armor_class = AC_MEDIUM
	armor = ARMOR_MAILLE
	body_parts_covered = COVERAGE_ALL_BUT_LEGS
	prevent_crits = ALL_EXCEPT_BLUNT
	max_integrity = INTEGRITY_STRONG
	item_weight = 6 * STEEL_MULTIPLIER

//................ Iron Maille ............... //
/obj/item/clothing/armor/chainmail/iron
	name = "iron maille"
	desc = "A short-sleeved shirt made of iron rings. Offers good protection against arrows, stabs and cuts."
	icon_state = "ichainmail"
	smeltresult = /obj/item/ingot/iron
	sellprice = VALUE_IRON_ARMOR

	armor = ARMOR_MAILLE_IRON
	body_parts_covered = COVERAGE_TORSO
	max_integrity = INTEGRITY_STANDARD
	item_weight = 6 * IRON_MULTIPLIER

//................ Hauberk ............... //
/obj/item/clothing/armor/chainmail/hauberk
	name = "hauberk"
	desc = "A long shirt of maille, heavy on the shoulders. Can be worn as a shirt, but some men with hairy chests consider it torture."
	icon_state = "hauberk"
	item_state = "hauberk"
	sellprice = VALUE_STEEL_ARMOR_FINE

	body_parts_covered = COVERAGE_FULL
	do_sound_chain = TRUE
	item_weight = 6 * IRON_MULTIPLIER

//................ Ancient Haubergon ............... //
/obj/item/clothing/armor/chainmail/hauberk/vampire
	name = "ancient hauberk"
	desc = "A style of armor long out of use, rests easy on the shoulders. Has sleeves but doesn't cover the legs."
	icon_state = "vunder"
	sellprice = VALUE_STEEL_ARMOR_FINE

	armor_class = AC_LIGHT
	armor = ARMOR_SCALE
	body_parts_covered = COVERAGE_ALL_BUT_LEGS
	item_weight = 7 * STEEL_MULTIPLIER
