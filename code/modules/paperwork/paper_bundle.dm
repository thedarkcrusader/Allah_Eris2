/obj/item/paper_bundle
	name = "paper bundle"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	randpixel = 8
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	throw_range = 2
	throw_speed = 1
	layer = ABOVE_OBJ_LAYER
	attack_verb = list("bapped")
	var/page = 1    // current page
	var/list/pages = list()  // Ordered list of pages as they are to be displayed. Can be different order than src.contents.


/obj/item/paper_bundle/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/paper))
		var/obj/item/paper/paper = W
		if(!paper.can_bundle())
			USE_FEEDBACK_FAILURE("You cannot bundle these together!")
			return TRUE

	if (istype(W, /obj/item/paper/carbon))
		var/obj/item/paper/carbon/C = W
		if (!C.iscopy && !C.copied)
			to_chat(user, SPAN_NOTICE("Take off the carbon copy first."))
			return TRUE
	// adding sheets
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo))
		insert_sheet_at(user, length(pages)+1, W)
		return TRUE

	// burning
	if (istype(W, /obj/item/flame))
		burnpaper(W, user)
		return TRUE

	// merging bundles
	if (istype(W, /obj/item/paper_bundle))
		for(var/obj/O in W)
			O.forceMove(src)
			O.add_fingerprint(user)
			pages.Add(O)

		to_chat(user, SPAN_NOTICE("You add \the [W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name]."))
		qdel(W)
		return TRUE

	if (istype(W, /obj/item/pen))
		show_browser(user, "", "window=[name]") //Closes the dialog
		var/obj/P = pages[page]
		P.use_tool(W, user)
		update_icon()
		attack_self(user) //Update the browsed page.

	return ..()

/obj/item/paper_bundle/proc/insert_sheet_at(mob/user, index, obj/item/sheet)
	if (!user.unEquip(sheet, src))
		return
	var/bundle_name = "paper bundle"
	var/sheet_name = istype(sheet, /obj/item/photo) ? "photo" : "sheet of paper"
	bundle_name = (bundle_name == name) ? "the [bundle_name]" : name
	sheet_name = (sheet_name == sheet.name) ? "the [sheet_name]" : sheet.name

	to_chat(user, SPAN_NOTICE("You add [sheet_name] to [bundle_name]."))
	pages.Insert(index, sheet)
	if(index <= page)
		page++

/obj/item/paper_bundle/proc/burnpaper(obj/item/flame/P, mob/user)
	var/class = "warning"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/flame/lighter/zippo))
			class = "rose>"

		user.visible_message(SPAN_CLASS("[class]", "[user] holds \the [P] up to \the [src], trying to burn it!"), \
		SPAN_CLASS("[class]", "You hold \the [P] up to \the [src], burning it slowly."))

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message(SPAN_CLASS("[class]", "[user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap."), \
				SPAN_CLASS("[class]", "You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap."))

				if(user.get_inactive_hand() == src)
					user.drop_from_inventory(src)

				new /obj/decal/cleanable/ash(src.loc)
				qdel(src)

			else
				to_chat(user, SPAN_WARNING("You must hold \the [P] steady to burn \the [src]."))

/obj/item/paper_bundle/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		src.show_content(user)
	else
		to_chat(user, SPAN_NOTICE("It is too far away."))

/obj/item/paper_bundle/proc/show_content(mob/user as mob)
	var/dat
	var/obj/item/W = pages[page]

	// first
	if(page == 1)
		dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='byond://?src=\ref[src];prev_page=1'>Front</A></DIV>"
		dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='byond://?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
		dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='byond://?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"
	// last
	else if(page == length(pages))
		dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='byond://?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
		dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='byond://?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
		dat+= "<DIV STYLE='float;left; text-align:right; with:33.33333%'><A href='byond://?src=\ref[src];next_page=1'>Back</A></DIV><BR><HR>"
	// middle pages
	else
		dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='byond://?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
		dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='byond://?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
		dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='byond://?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"

	if(istype(pages[page], /obj/item/paper))
		var/obj/item/paper/P = W
		dat+= "<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.show_info(user)][P.stamps]</BODY></HTML>"
		show_browser(user, dat, "window=[name]")
	else if(istype(pages[page], /obj/item/photo))
		var/obj/item/photo/P = W
		dat += "<html><head><title>[P.name]</title></head><body style='overflow:hidden'>"
		dat += "<div> <img src='tmp_photo.png' width = '180'[P.scribble ? "<div> Written on the back:<br><i>[P.scribble]</i>" : null ]</body></html>"
		send_rsc(user, P.img, "tmp_photo.png")
		show_browser(user, jointext(dat, null), "window=[name]")

/obj/item/paper_bundle/attack_self(mob/user as mob)
	src.show_content(user)
	add_fingerprint(user)
	update_icon()
	return

/obj/item/paper_bundle/Topic(href, href_list)
	if(..())
		return 1
	if((src in usr.contents) || (istype(src.loc, /obj/item/material/folder) && (src.loc in usr.contents)))
		usr.set_machine(src)
		var/obj/item/in_hand = usr.get_active_hand()
		if(href_list["next_page"])
			if(in_hand && (istype(in_hand, /obj/item/paper) || istype(in_hand, /obj/item/photo)))
				insert_sheet_at(usr, page+1, in_hand)
			else if(page != length(pages))
				page++
				playsound(src.loc, "pageturn", 50, 1)
		if(href_list["prev_page"])
			if(in_hand && (istype(in_hand, /obj/item/paper) || istype(in_hand, /obj/item/photo)))
				insert_sheet_at(usr, page, in_hand)
			else if(page > 1)
				page--
				playsound(src.loc, "pageturn", 50, 1)
		if(href_list["remove"])
			var/obj/item/W = pages[page]
			usr.put_in_hands(W)
			pages.Remove(pages[page])

			to_chat(usr, SPAN_NOTICE("You remove the [W.name] from the bundle."))

			if(length(pages) <= 1)
				var/obj/item/paper/P = src[1]
				usr.drop_from_inventory(src)
				usr.put_in_hands(P)
				qdel(src)

				return

			if(page > length(pages))
				page = length(pages)

			update_icon()

		src.attack_self(usr)
		updateUsrDialog()
	else
		to_chat(usr, SPAN_NOTICE("You need to hold it in hands!"))

/obj/item/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	var/n_name = sanitizeSafe(input(usr, "What would you like to label the bundle?", "Bundle Labelling", null)  as text, MAX_NAME_LEN)
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == 0)
		SetName("[(n_name ? text("[n_name]") : "paper")]")
	add_fingerprint(usr)
	return


/obj/item/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

	to_chat(usr, SPAN_NOTICE("You loosen the bundle."))
	for(var/obj/O in src)
		O.dropInto(usr.loc)
		O.reset_plane_and_layer()
		O.add_fingerprint(usr)
	qdel(src)


/obj/item/paper_bundle/on_update_icon()
	var/obj/item/paper/P = pages[1]
	icon_state = P.icon_state
	CopyOverlays(P)
	underlays.Cut()
	var/i = 0
	var/photo
	for(var/obj/O in src)
		var/image/img = image('icons/obj/bureaucracy.dmi')
		if(istype(O, /obj/item/paper))
			img.icon_state = O.icon_state
			img.pixel_x -= min(1*i, 2)
			img.pixel_y -= min(1*i, 2)
			pixel_x = min(0.5*i, 1)
			pixel_y = min(  1*i, 2)
			underlays += img
			i++
		else if(istype(O, /obj/item/photo))
			var/obj/item/photo/Ph = O
			img = Ph.tiny
			photo = 1
			AddOverlays(img)
	if(i>1)
		desc =  "[i] papers clipped to each other."
	else
		desc = "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	AddOverlays(image('icons/obj/bureaucracy.dmi', "clip"))
	return
