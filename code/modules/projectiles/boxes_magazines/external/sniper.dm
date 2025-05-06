//Sniper Rifle

/obj/item/ammo_box/magazine/sniper_rounds
	name = ".50 BMG magazine"
	desc = "A six-round .50 BMG magazine that contains massive, oversized bullets. \
			These bullets will dismember limbs, penetrate armor, and paralyze targets."
	icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/p50
	max_ammo = 6
	caliber = CALIBER_50BMG

/obj/item/ammo_box/magazine/sniper_rounds/update_icon_state()
	. = ..()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/magazine/sniper_rounds/soporific
	name = ".50 BMG magazine (Soporific)"
	desc = "A three-round .50 BMG magazine that contains massive, oversized bullets. \
			These rounds instantly put their targets to sleep on contact."
	icon_state = "soporific"
	ammo_type = /obj/item/ammo_casing/p50/soporific
	max_ammo = 3

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = ".50 BMG magazine (Penetrator)"
	desc = "A five-round .50 BMG magazine that contains massive, oversized bullets. \
			These bullets are extremely powerful rounds capable of passing straight through cover and anyone unfortunate enough to be behind it."
	icon_state = "haemorrhage"
	ammo_type = /obj/item/ammo_casing/p50/penetrator
	max_ammo = 5
