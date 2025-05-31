/obj/item/weapon/tongs
	force = 5
	possible_item_intents = list(/datum/intent/mace/strike)
	name = "tongs"
	desc = ""
	icon_state = "tongs"
	icon = 'icons/roguetown/weapons/tools.dmi'
	sharpness = IS_BLUNT
	//dropshrink = 0.8
	wlength = 10
	slot_flags = ITEM_SLOT_HIP
	associated_skill = null
	var/obj/item/held_item = null
	var/hott = 0
	smeltresult = /obj/item/ingot/iron
	grid_width = 32
	grid_height = 96

/obj/item/weapon/tongs/examine(mob/user)
	. = ..()
	if(hott)
		. += "<span class='warning'>The tip is hot to the touch.</span>"

/obj/item/weapon/tongs/get_temperature()
	if(hott)
		return 150+T0C
	return ..()

/obj/item/weapon/tongs/fire_act(added, maxstacks)
	. = ..()
	hott = world.time
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(make_unhot), world.time), 10 SECONDS)

/obj/item/weapon/tongs/update_icon()
	. = ..()
	if(!held_item)
		icon_state = "tongs"
	else
		if(hott)
			icon_state = "tongsi1"
		else
			icon_state = "tongsi0"

/obj/item/weapon/tongs/proc/proxy_heat(incoming, max_heat)
	if(istype(held_item, /obj/item/storage/crucible))
		var/obj/item/storage/crucible/crucible = held_item
		crucible.crucible_temperature = min(crucible.crucible_temperature + incoming, max_heat)

/obj/item/weapon/tongs/proc/make_unhot(input)
	if(hott == input)
		hott = 0
	update_icon()

///Places the ingot on the atom, this can be either a turf or a table
/obj/item/weapon/tongs/proc/place_item_to_atom(atom/A, mob/user)
	if(held_item?.tong_interaction(A, user))
		return
	if(held_item && (isturf(A) || istype(A, /obj/structure/table)))
		held_item.forceMove(get_turf(A))
		held_item = null
		hott = 0
		update_icon()
	else if(held_item)
		to_chat(user, "<span class='warning'>Cannot place [held_item] here!</span>")

/obj/item/weapon/tongs/attack_self(mob/user)
	place_item_to_atom(get_turf(user), user)

/obj/item/weapon/tongs/dropped(mob/user)
	. = ..()
	place_item_to_atom(get_turf(src), user)

/obj/item/weapon/tongs/pre_attack_right(atom/A, mob/living/user, params)
	. = ..()
	place_item_to_atom(get_turf(A), user)

/obj/item/weapon/tongs/pre_attack(obj/item/A, mob/living/user, params)
	if(held_item?.tong_interaction(A, user))
		return

	if(!istype(A))
		return ..()

	if(A.tool_flags & TOOL_USAGE_TONGS)
		if(!held_item)
			user.visible_message("<span class='info'>[user] picks up [A] with [src].</span>")
			held_item = A
			A.forceMove(src)
			update_icon()
			return
	return ..()

/obj/item/weapon/tongs/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -9,"sy" = 1,"nx" = 12,"ny" = 1,"wx" = -8,"wy" = 1,"ex" = 6,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/weapon/tongs/stone
	name = "stone tongs"
	icon_state = "stonetongs"
	force = 3
	smeltresult = null
	anvilrepair = null
	max_integrity = 20

/obj/item/weapon/tongs/stone/update_icon()
	. = ..()
	if(!held_item)
		icon_state = "stonetongs"
	else
		if(hott)
			icon_state = "stonetongsi1"
		else
			icon_state = "stonetongsi0"

/atom/proc/tong_interaction(atom/target, mob/user)
	return FALSE
