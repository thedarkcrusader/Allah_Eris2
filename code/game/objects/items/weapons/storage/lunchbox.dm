/obj/item/storage/lunchbox
	max_storage_space = ITEM_SIZE_SMALL * 4
	icon = 'icons/obj/lunchboxes.dmi'
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_SMALL
	attack_verb = list("lunched")
	allow_slow_dump = TRUE
	var/filled = FALSE


/obj/item/storage/lunchbox/Initialize()
	. = ..()
	if (filled)
		var/list/lunches = lunchables_lunches()
		var/lunch = lunches[pick(lunches)]
		new lunch(src)
		var/list/snacks = lunchables_snacks()
		var/snack = snacks[pick(snacks)]
		new snack(src)
		var/list/drinks = lunchables_drinks()
		var/drink = drinks[pick(drinks)]
		new drink(src)


/obj/item/storage/lunchbox/rainbow
	name = "rainbow lunchbox"
	icon_state = "lunchbox_rainbow"
	item_state = "toolbox_pink"
	desc = "A little lunchbox. This one is the colors of the rainbow!"


/obj/item/storage/lunchbox/rainbow/filled
	filled = TRUE


/obj/item/storage/lunchbox/heart
	name = "heart lunchbox"
	icon_state = "lunchbox_lovelyhearts"
	item_state = "toolbox_pink"
	desc = "A little lunchbox. This one has cute little hearts on it!"


/obj/item/storage/lunchbox/heart/filled
	filled = TRUE


/obj/item/storage/lunchbox/cat
	name = "cat lunchbox"
	icon_state = "lunchbox_sciencecatshow"
	item_state = "toolbox_green"
	desc = "A little lunchbox. This one has a cute little science cat from a popular show on it!"


/obj/item/storage/lunchbox/cat/filled
	filled = TRUE


/obj/item/storage/lunchbox/nt
	name = "\improper NanoTrasen brand lunchbox"
	icon_state = "lunchbox_nanotrasen"
	item_state = "toolbox_red"
	desc = "A little lunchbox. This one is branded with the NanoTrasen logo!"


/obj/item/storage/lunchbox/ntmisprint
	name = "\improper misprinted NanoTrasen brand lunchbox"
	icon_state = "lunchbox_nanotrasenmisprint"
	item_state = "toolbox_blue"
	desc = "A little lunchbox. This one is branded with the NanoTrasen logo! Something looks off about it, though."


/obj/item/storage/lunchbox/dais
	name = "\improper DAIS brand lunchbox"
	icon_state = "lunchbox_dais"
	item_state = "toolbox_blue"
	desc = "A little lunchbox. This one is branded with the Deimos Advanced Information Systems logo!"


/obj/item/storage/lunchbox/nt/filled
	filled = TRUE


/obj/item/storage/lunchbox/mars
	name = "\improper Mariner University lunchbox"
	icon_state = "lunchbox_marsuniversity"
	item_state = "toolbox_red"
	desc = "A little lunchbox. This one is branded with the Mariner university logo!"


/obj/item/storage/lunchbox/mars/filled
	filled = TRUE


/obj/item/storage/lunchbox/cti
	name = "\improper CTI lunchbox"
	icon_state = "lunchbox_cti"
	item_state = "toolbox_blue"
	desc = "A little lunchbox. This one is branded with the CTI logo!"


/obj/item/storage/lunchbox/cti/filled
	filled = TRUE


/obj/item/storage/lunchbox/nymph
	name = "\improper Diona nymph lunchbox"
	icon_state = "lunchbox_dionanymph"
	item_state = "toolbox_yellow"
	desc = "A little lunchbox. This one is an adorable Diona nymph on the side!"


/obj/item/storage/lunchbox/nymph/filled
	filled = TRUE


/obj/item/storage/lunchbox/syndicate
	name = "black and red lunchbox"
	icon_state = "lunchbox_syndie"
	item_state = "toolbox_syndi"
	desc = "A little lunchbox. This one is a sleek black and red, made of a durable steel!"


/obj/item/storage/lunchbox/syndicate/filled
	filled = TRUE


/obj/item/storage/lunchbox/gcc
	name = "\improper GCC lunchbox"
	icon_state = "lunchbox_tcc"
	item_state = "toolbox_syndi"
	desc = "A little lunchbox. This one is branded with the flag of the Gilgamesh Colonial Confederation!"


/obj/item/storage/lunchbox/gcc/filled
	filled = TRUE


/obj/item/storage/lunchbox/scg
	name = "\improper SCG lunchbox"
	icon_state = "lunchbox_scg"
	item_state = "toolbox_blue"
	desc = "A little lunchbox. This one is branded with the flag of the Solar Assembly!"


/obj/item/storage/lunchbox/scg/filled
	filled = TRUE


/obj/item/storage/lunchbox/picnic
	name = "picnic basket"
	icon = 'icons/obj/picnic_basket.dmi'
	icon_state = "picnic_basket"
	item_state = "picnic_basket"
	desc = "A small, old-fashioned picnic basket. Great for lunches in the garden."


/obj/item/storage/lunchbox/picnic/filled
	filled = TRUE


/obj/item/storage/lunchbox/caltrops
	startswith = list(
		/obj/item/material/shard/caltrop = 4
	)

/obj/item/storage/lunchbox/caltrops/Initialize()
	. = ..()
	var/mimic_types = subtypesof(/obj/item/storage/lunchbox) - /obj/item/storage/lunchbox/caltrops
	var/obj/item/storage/lunchbox/mimic = pick(mimic_types)
	name = initial(mimic.name)
	icon_state = initial(mimic.icon_state)
	item_state = initial(mimic.item_state)
	desc = initial(mimic.desc)
