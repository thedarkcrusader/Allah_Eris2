
/obj/item/clothing/cloak/raincloak
	name = "raincloak"
	desc = "A typical raincloak used to protect the wearer against various elements."
	color = null
	icon_state = "rain_cloak"
	item_state = "rain_cloak"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
//	body_parts_covered = ARMS|CHEST
	boobed = TRUE
	sleeved = 'icons/roguetown/clothing/onmob/cloaks.dmi'
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	hoodtype = /obj/item/clothing/head/hooded/rainhood
	toggle_icon_state = FALSE
	salvage_result = /obj/item/natural/hide/cured

/obj/item/clothing/cloak/raincloak/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/storage/concrete/grid/cloak)

/obj/item/clothing/cloak/raincloak/dropped(mob/living/carbon/human/user)
	..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	if(STR)
		var/list/things = STR.contents()
		for(var/obj/item/I in things)
			STR.remove_from_storage(I, get_turf(src))



/obj/item/clothing/cloak/raincloak/red
	color = CLOTHING_BLOOD_RED

/obj/item/clothing/cloak/raincloak/purple
	color = CLOTHING_PLUM_PURPLE

/obj/item/clothing/cloak/raincloak/mortus
	name = "funeral cloak"
	desc = "You're always shrouded by death."
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/cloak/raincloak/brown
	color = CLOTHING_BARK_BROWN

/obj/item/clothing/cloak/raincloak/green
	color = CLOTHING_FOREST_GREEN

/obj/item/clothing/cloak/raincloak/blue
	color = CLOTHING_SKY_BLUE

/obj/item/clothing/cloak/raincloak/random/Initialize()
	color = pick(CLOTHING_BLOOD_RED, CLOTHING_PLUM_PURPLE, CLOTHING_SOOT_BLACK, CLOTHING_BARK_BROWN, CLOTHING_FOREST_GREEN, CLOTHING_SKY_BLUE)
	..()

/obj/item/clothing/head/hooded/rainhood
	name = "hood"
	desc = "A hood that's attached to the raincoat."
	icon_state = "rain_hood"
	item_state = "rain_hood"
	slot_flags = ITEM_SLOT_HEAD
	dynamic_hair_suffix = ""
	edelay_type = 1 // Leaving as 1 so you get that small do_after for dramatic purposes
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	block2add = FOV_BEHIND

/obj/item/clothing/head/hooded/equipped(mob/user, slot)
	. = ..()
	user.update_fov_angles()

/obj/item/clothing/head/hooded/dropped(mob/user)
	. = ..()
	user.update_fov_angles()

/obj/item/clothing/cloak/raincloak/furcloak
	name = "fur cloak"
	icon_state = "furgrey"
	inhand_mod = FALSE
	hoodtype = /obj/item/clothing/head/hooded/rainhood/furhood
	salvage_amount = 1
	salvage_result = /obj/item/natural/fur

/obj/item/clothing/cloak/raincloak/furcloak/crafted/Initialize()
	. = ..()
	if(prob(50))
		color = pick("#685542","#66564d")

/obj/item/clothing/cloak/raincloak/furcloak/brown
	color = CLOTHING_MUD_BROWN

/obj/item/clothing/cloak/raincloak/furcloak/black
	color = CLOTHING_ASH_GREY

/obj/item/clothing/head/hooded/rainhood/furhood
	icon_state = "fur_hood"
	block2add = FOV_BEHIND
