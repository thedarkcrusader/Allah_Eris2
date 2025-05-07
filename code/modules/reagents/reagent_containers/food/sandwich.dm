/obj/item/reagent_containers/food/snacks/slice/bread/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W,/obj/item/material/shard) || istype(W,/obj/item/reagent_containers/food/snacks))
		if (is_path_in_list(W.type, list(/obj/item/reagent_containers/food/snacks/custombowl, /obj/item/reagent_containers/food/snacks/csandwich)))
			return ..()
		var/obj/item/reagent_containers/food/snacks/csandwich/S = new(get_turf(src))
		S.use_tool(W,user)
		qdel(src)
		return TRUE
	return ..()

/obj/item/reagent_containers/food/snacks/csandwich
	name = "sandwich"
	desc = "The best thing since sliced bread."
	icon_state = "sandwich_top"
	trash = /obj/item/trash/plate
	bitesize = 2
	var/list/ingredients = list()
	var/fullname = ""
	var/renamed = 0

/obj/item/reagent_containers/food/snacks/csandwich/verb/rename_sandwich()
	set name = "Rename Sandwich"
	set category = "Object"
	var/mob/user = usr
	var/sandwich_label = ""

	if(!renamed)
		sandwich_label = sanitizeSafe(input(user, "Enter a new name for \the [src].", "Name", label_text), MAX_NAME_LEN)
		if(sandwich_label)
			to_chat(user, SPAN_NOTICE("You rename \the [src] to \"[sandwich_label] sandwich\"."))
			SetName("\improper [sandwich_label] sandwich")
			renamed = 1

/obj/item/reagent_containers/food/snacks/csandwich/use_tool(obj/item/W, mob/living/user, list/click_params)
	var/sandwich_limit = 4
	for(var/obj/item/O in ingredients)
		if(istype(O,/obj/item/reagent_containers/food/snacks/slice/bread))
			sandwich_limit += 4

	if(length(src.contents) > sandwich_limit)
		to_chat(user, SPAN_WARNING("If you put anything else on \the [src] it's going to collapse."))
		return TRUE

	if(istype(W,/obj/item/material/shard))
		if(!user.unEquip(W, src))
			FEEDBACK_UNEQUIP_FAILURE(user, W)
			return TRUE
		to_chat(user, SPAN_WARNING("You hide [W] in \the [src]."))
		update()
		return TRUE

	if(istype(W,/obj/item/reagent_containers/food/snacks))
		if (is_path_in_list(W.type, list(/obj/item/reagent_containers/food/snacks/custombowl, /obj/item/reagent_containers/food/snacks/csandwich)))
			return ..()
		if(!user.unEquip(W, src))
			FEEDBACK_UNEQUIP_FAILURE(user, W)
			return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] layers \the [W] over \the [src]."),
			SPAN_NOTICE("You layer \the [W] over \the [src].")
		)
		var/obj/item/reagent_containers/F = W
		F.reagents.trans_to_obj(src, F.reagents.total_volume)
		ingredients += W
		update()
		return TRUE

	return ..()

/obj/item/reagent_containers/food/snacks/csandwich/proc/update()
	var/i = 0
	ClearOverlays()

	filling_color = null
	var/list/ingredient_names = list()
	for (var/obj/item/reagent_containers/food/snacks/O as anything in ingredients)
		if (isnull(filling_color))
			filling_color = O.filling_color
		ingredient_names |= O.name // Use |= instead of += in case of duplicates, to avoid i.e. 'Chocolate, chocolate, and vanilla'

		i++
		var/image/I = new(icon, "sandwich_filling")
		I.color = O.filling_color
		I.pixel_x = pick(list(-1,0,1))
		I.pixel_y = (i*2)+1
		AddOverlays(I)

	var/image/T = new(src.icon, "sandwich_top")
	T.pixel_x = pick(list(-1,0,1))
	T.pixel_y = (length(ingredients) * 2)+1
	AddOverlays(T)

	fullname = english_list(ingredient_names)
	SetName(lowertext("[fullname] sandwich"))
	renamed = 0 //updating removes custom name
	if(length(name) > 80) SetName("[pick(list("absurd","colossal","enormous","ridiculous"))] sandwich")
	w_class = ceil(clamp((length(ingredients)/2),2,4))

/obj/item/reagent_containers/food/snacks/csandwich/Destroy()
	QDEL_NULL_LIST(ingredients)
	. = ..()

/obj/item/reagent_containers/food/snacks/csandwich/examine(mob/user)
	. = ..(user)
	var/obj/item/O = pick(contents)
	to_chat(user, SPAN_ITALIC("You think you can see [O.name] in there."))

/obj/item/reagent_containers/food/snacks/csandwich/use_before(mob/living/M as mob, mob/user as mob)
	. = FALSE
	if (!istype(M))
		return FALSE
	var/obj/item/shard
	for (var/obj/item/O in contents)
		if (istype(O,/obj/item/material/shard))
			shard = O
			break

	if (shard && M == user)
		to_chat(M, SPAN_WARNING("You lacerate your mouth on a [shard.name] in the sandwich!"))
		M.adjustBruteLoss(5) //TODO: Target head if human.
	return ..()
