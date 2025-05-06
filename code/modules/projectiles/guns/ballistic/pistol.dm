GLOBAL_VAR_INIT(does_howard_exist, FALSE)

/obj/item/gun/ballistic/automatic/pistol
	name = "stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = "sound/weapons/gunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 80
	rack_sound = "sound/weapons/pistolrack.ogg"
	bolt_drop_sound = "sound/weapons/pistolslidedrop.ogg"
	bolt_wording = "slide"
	feedback_types = list(
		"fire" = 2
	)

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/pacifist
	starting_mag_type = /obj/item/ammo_box/magazine/m10mm/sp

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE
	fire_sound = "sound/weapons/pistolshotsmall.ogg"
	feedback_types = list(
		"fire" = 3
	)

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	fire_delay = 7 //Very slightly slower than the .357
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	fire_sound = "sound/weapons/deaglefire.ogg"
	feedback_types = list(
		"fire" = 3
	)


/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = "A gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = "The original Russian version of a widely used Syndicate sidearm. Uses 9mm ammo."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
	feedback_types = list(
		"fire" = 2
	)

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "flat gun"
	desc = "A 2 dimensional gun.. what?"
	icon_state = "flatgun"
	feedback_types = list(
		"fire" = 2
	)
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/pistol/stickman/pickup(mob/living/user)
	SHOULD_CALL_PARENT(FALSE)
	to_chat(user, span_notice("As you try to pick up [src], it slips out of your grip.."))
	if(prob(50))
		to_chat(user, span_notice("..and vanishes from your vision! Where the hell did it go?"))
		qdel(src)
		user.update_icons()
	else
		to_chat(user, span_notice("..and falls into view. Whew, that was a close one."))
		user.dropItemToGround(src)

/obj/item/gun/ballistic/automatic/pistol/makeshift
	name = "makeshiftov pistol"
	desc = "A small, makeshift 10mm handgun. It's a miracle if it'll even fire."
	icon_state = "makeshift"
	spawnwithmagazine = FALSE
	fire_delay = 6

/obj/item/gun/ballistic/automatic/pistol/implant
	name = "Stechkin implant"
	desc = "A modified version of the Stechkin pistol placed inside of the forearm, allows for easy concealment."

/obj/item/gun/ballistic/automatic/pistol/v38
	name = "\improper Vatra M38 Pistol"
	desc = "A moderately-sized handgun that loads irregular .38 special magazines. Commonly found among Serbian police forces. 'Vatra Arms - 2506' is etched into the slide."
	icon_state = "v38"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/v38
	can_suppress = FALSE
	fire_sound = "sound/weapons/pistolshotmedium.ogg"
	feedback_types = list(
		"fire" = 3
	)

/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal
	starting_mag_type = /obj/item/ammo_box/magazine/v38/rubber

/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal/Initialize(mapload)
	if(GLOB.does_howard_exist || prob(90))
		return ..()
	GLOB.does_howard_exist = TRUE
	new/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal/howard(loc)
	qdel(src)

/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal/howard
	name = "\improper Vatra M38 \"Hauard\" Pistol"
	icon_state = "v38s"
	desc = "A moderately-sized, silver-plated handgun that loads irregular .38 special magazines. Commonly found among Serbian police forces. Its serial number is scratched out and replaced with \"Hauard\"."

/obj/item/gun/ballistic/automatic/pistol/v38/less_lethal/howard/Destroy()
	GLOB.does_howard_exist = FALSE //not anymore, goodbye!
	..()
	

/obj/item/gun/ballistic/automatic/pistol/boltpistol
	name = "Imperial Bolt Pistol"
	desc = "A smaller, sidearm variant of the Bolter. Typically blows people into chunks with every shot. Fires .75 caliber rounds."
	icon_state = "bpistol"
	item_state = "bpistol"
	icon = 'icons/obj/guns/grimdark.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/boltpistol
	can_suppress = TRUE // goes hard
	fire_delay = 2 // beeg gun, hard to fire rapidly
	fire_sound = "sound/weapons/bolter.ogg"

/obj/item/gun/ballistic/automatic/pistol/boltpistol/admin
	fire_delay = 0 // you are welcome
	mag_type = /obj/item/ammo_box/magazine/boltpistol/admin
