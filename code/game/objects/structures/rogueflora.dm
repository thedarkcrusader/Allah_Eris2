
//newtree

/obj/structure/flora/tree
	name = "old tree"
	desc = "An old, wicked tree that not even elves could love."
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "t1"
	opacity = 1
	density = 1
	max_integrity = 200
	blade_dulling = DULLING_CUT
	pixel_x = -16
	layer = 4.81
	plane = GAME_PLANE_UPPER
	attacked_sound = 'sound/misc/woodhit.ogg'
	destroy_sound = 'sound/misc/treefall.ogg'
	debris = list(/obj/item/grown/log/tree/stick = 2)
	static_debris = list(/obj/item/grown/log/tree = 1)
	alpha = 200
	var/stump_type = /obj/structure/table/wood/treestump
	metalizer_result = /obj/machinery/light/fueledstreet
	smeltresult = /obj/item/ore/coal

/obj/structure/flora/tree/attack_right(mob/user)
	if(user.mind && isliving(user))
		if(user.mind.special_items && user.mind.special_items.len)
			var/item = input(user, "What will I take?", "STASH") as null|anything in user.mind.special_items
			if(item)
				if(user.Adjacent(src))
					if(user.mind.special_items[item])
						var/path2item = user.mind.special_items[item]
						user.mind.special_items -= item
						var/obj/item/I = new path2item(user.loc)
						user.put_in_hands(I)
			return

/obj/structure/flora/tree/attacked_by(obj/item/I, mob/living/user)
	var/was_destroyed = obj_destroyed
	. = ..()
	if(.)
		if(!was_destroyed && obj_destroyed)
			record_featured_stat(FEATURED_STATS_TREE_FELLERS, user)
			GLOB.vanderlin_round_stats[STATS_TREES_CUT]++

/obj/structure/flora/tree/fire_act(added, maxstacks)
	if(added > 5)
		return ..()

/obj/structure/flora/tree/Initialize()
	. = ..()

	if(istype(loc, /turf/open/floor/grass))
		var/turf/T = loc
		T.ChangeTurf(/turf/open/floor/dirt)

/obj/structure/flora/tree/obj_destruction(damage_flag)
	if(stump_type)
		new stump_type(loc)
	. = ..()

/obj/structure/flora/tree/Initialize()
	. = ..()
	icon_state = "t[rand(1,16)]"

/obj/structure/flora/tree/evil/Initialize()
	. = ..()
	icon_state = "wv[rand(1,2)]"
	soundloop = new(src, FALSE)
	soundloop.start()

/obj/structure/flora/tree/evil/Destroy()
	soundloop.stop()
	if(controller)
		controller.endvines()
		controller.tree = null
		controller = null
	. = ..()

/obj/structure/flora/tree/evil
	var/datum/looping_sound/boneloop/soundloop
	var/datum/vine_controller/controller

/obj/structure/flora/tree/wise
	name = "wise tree"
	desc = "Dendor's favored. It seems to watch you with ancient awareness."
	icon_state = "mystical"
	var/activated = FALSE
	var/cooldown = FALSE
	var/retaliation_messages = list(
		"LEAVE FOREST ALONE!",
		"DENDOR PROTECTS!",
		"NATURE'S WRATH!",
		"BEGONE, INTERLOPER!"
	)

/obj/structure/flora/tree/wise/Initialize()
	. = ..()
	icon_state = "mystical"

/obj/structure/flora/tree/wise/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(activated && !cooldown)
		retaliate(user)

/obj/structure/flora/tree/wise/proc/retaliate(mob/living/target)
	if(cooldown || !istype(target) || !activated)
		return

	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 5 SECONDS)

	var/message = pick(retaliation_messages)
	say(span_danger("[message]"))

	var/atom/throw_target = get_edge_target_turf(src, get_dir(src, target))
	target.throw_at(throw_target, 4, 2)
	target.adjustBruteLoss(8)

/obj/structure/flora/tree/burnt
	name = "burnt tree"
	desc = "A scorched pillar of a once living tree."
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "t1"
	stump_type = /obj/structure/table/wood/treestump/burnt
	pixel_x = -32
	metalizer_result = /obj/machinery/anvil

/obj/structure/flora/tree/burnt/Initialize()
	. = ..()
	icon_state = "t[rand(1,4)]"


/obj/structure/flora/tree/underworld
	name = "screaming tree"
	desc = "human faces everywhere."
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "screaming1"
	opacity = 1
	density = 1
	resistance_flags = INDESTRUCTIBLE

/obj/structure/flora/tree/underworld/Initialize()
	. = ..()
	icon_state = "screaming[rand(1,3)]"

/obj/structure/flora/tree/stump/pine
	name = "pine stump"
	icon_state = "dead4"
	icon = 'icons/obj/flora/pines.dmi'
	static_debris = list(/obj/item/ore/coal/charcoal = 1)
	stump_type = null
	pixel_x = -32

/obj/structure/flora/tree/stump/pine/Initialize()
	. = ..()
	icon_state = "dead[rand(4,5)]"

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon_state = "pine1"
	desc = ""
	icon = 'icons/obj/flora/pines.dmi'
	pixel_w = -24
	density = 0
	max_integrity = 100
	static_debris = list(/obj/item/grown/log/tree = 2)
	stump_type = null

/obj/structure/flora/tree/pine/Initialize()
	. = ..()
	icon_state = "pine[rand(1, 4)]"

/obj/structure/flora/tree/pine/burn()
	new /obj/structure/flora/tree/pine/dead(get_turf(src))
	qdel(src)

/obj/structure/flora/tree/pine/dead
	name = "burnt pine tree"
	icon_state = "dead1"
	max_integrity = 50
	static_debris = list(/obj/item/ore/coal/charcoal = 1)
	resistance_flags = FIRE_PROOF
	stump_type = /obj/structure/flora/tree/stump/pine

/obj/structure/flora/tree/pine/dead/Initialize()
	. = ..()
	icon_state = "dead[rand(1, 3)]"

/*	.............  Treestump   ................ */	// Treestumps are now tables, so you can tablecraft with them and so on.
/obj/structure/table/wood/treestump
	name = "tree stump"
	desc = "Someone cut this tree down."
	icon = 'icons/roguetown/misc/tree.dmi'
	icon_state = "t1stump"
	max_integrity = 100
	climb_time = 0
	blade_dulling = DULLING_CUT
	static_debris = list()
	debris = null
	climb_offset = 14
	var/isunburnt = TRUE // Var needed for the burnt stump
	metalizer_result = /obj/machinery/anvil
	var/stump_loot = /obj/item/grown/log/tree/small

/obj/structure/table/wood/treestump/Initialize()
	. = ..()
	icon_state = "t[rand(1,4)]stump"

/obj/structure/table/wood/treestump/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/shovel))
		to_chat(user, "I start unearthing the stump...")
		playsound(loc,'sound/items/dig_shovel.ogg', 100, TRUE)
		if(do_after(user, 5 SECONDS))
			user.visible_message("<span class='notice'>[user] unearths \the [src].</span>", \
								"<span class='notice'>I unearth \the [src].</span>")
			if(isunburnt)
				new stump_loot(loc) // Rewarded with an extra small log if done the right way.return
			obj_destruction("brute")
	else
		. = ..()

/obj/structure/table/wood/treestump/burnt
	name = "tree stump"
	desc = "This stump is burnt. Maybe someone is trying to get coal the easy way."
	static_debris = list(/obj/item/ore/coal = 1)
	isunburnt = FALSE
	icon_state = "st1"
	icon = 'icons/roguetown/misc/tree.dmi'

/obj/structure/table/wood/treestump/burnt/Initialize()
	. = ..()
	icon_state = "st[rand(1,2)]"


/*	.............   Ancient log   ................ */	// Functionally a sofa, slightly better than sleeping on the ground
/obj/structure/chair/bench/ancientlog
	name = "ancient log"
	desc = "A felled piece of tree long forgotten, the poorman's sofa."
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "log1"
	blade_dulling = DULLING_CUT
	static_debris = list(/obj/item/grown/log/tree = 1)
	max_integrity = 200
	sleepy = 0.2
	pixel_x = -14
	pixel_y = 7
	pass_flags = PASSTABLE

/obj/structure/chair/bench/ancientlog/Initialize()
	. = ..()
	icon_state = "log[rand(1,2)]"

/obj/structure/chair/bench/ancientlog/post_buckle_mob(mob/living/M)
	..()
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 5)

/obj/structure/chair/bench/ancientlog/post_unbuckle_mob(mob/living/M)
	..()
	M.reset_offsets("bed_buckle")


//newbushes

/obj/structure/flora/grass
	name = "grass"
	desc = "The kindest blades you will ever meet in this world."
	icon = 'icons/roguetown/misc/foliage.dmi'
	icon_state = "grass1"
	attacked_sound = "plantcross"
	destroy_sound = "plantcross"
	max_integrity = 5
	debris = list(/obj/item/natural/fibers = 1)
	var/prob2findstuff // base % to find any useful thing in the bush, gets modded by perception
	var/islooted = FALSE	// for harvestable
	var/luckydouble			//	for various luck based effects

/obj/structure/flora/grass/spark_act()
	fire_act()

/obj/structure/flora/grass/Initialize()
	update_icon()
	AddComponent(/datum/component/grass)
	. = ..()

/obj/structure/flora/grass/Destroy()
	if(prob(5))
		new /obj/item/neuFarm/seed/mixed_seed(get_turf(src))
	. = ..()

/obj/structure/flora/grass/update_icon()
	icon_state = "grass[rand(1, 6)]"

/obj/structure/flora/grass/tundra
	name = "tundra grass"
	icon_state = "tundragrass1"

/obj/structure/flora/grass/tundra/update_icon()
	icon_state = "tundragrass[rand(1, 6)]"

/obj/structure/flora/grass/water
	name = "grass"
	desc = "This grass is sodden and muddy."
	icon_state = "swampgrass"
	max_integrity = 5

/obj/structure/flora/grass/water/reeds
	name = "reeds"
	desc = "This plant thrives in water, and shelters dangers."
	icon_state = "reeds"
	opacity = 1
	max_integrity = 10
	layer = 4.1

/obj/structure/flora/grass/water/update_icon()
	dir = pick(GLOB.cardinals)

/datum/component/grass/Initialize()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), PROC_REF(Crossed))

/datum/component/grass/proc/Crossed(datum/source, atom/movable/AM)
	var/atom/A = parent

	if(isliving(AM))
		var/mob/living/L = AM
		if(L.m_intent == MOVE_INTENT_SNEAK)
			return
		else
			playsound(A.loc, "plantcross", 90, FALSE, -1)
			var/oldx = A.pixel_x
			animate(A, pixel_x = oldx+1, time = 0.5)
			animate(pixel_x = oldx-1, time = 0.5)
			animate(pixel_x = oldx, time = 0.5)
			L.consider_ambush()
	return

// normal bush. Oldstyle. Kept for the managed palace hedges for now.
/obj/structure/flora/grass/bush
	name = "bush"
	desc = "A bush, a den for critters and treasures."
	icon_state = "bush"
	layer = ABOVE_ALL_MOB_LAYER
	var/res_replenish
	max_integrity = 35
	climbable = FALSE
	dir = SOUTH
	debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1)
	var/list/looty = list()
	var/bushtype

/obj/structure/flora/grass/bush/update_icon()
	icon_state = "bush"

/obj/structure/flora/grass/bush/tundra
	name = "tundra bush"
	icon_state = "bush_tundra"

/obj/structure/flora/grass/bush/tundra/update_icon()
	icon_state = "bush_tundra"

/obj/structure/flora/grass/bush/Initialize()
	if(prob(88))
		bushtype = pickweight(list(/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry=5,
					/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison=3,
					/obj/item/reagent_containers/food/snacks/produce/westleach=2))
	loot_replenish()
	pixel_x += rand(-3,3)
	return ..()

/obj/structure/flora/grass/bush/proc/loot_replenish()
	if(bushtype)
		looty += bushtype
	if(prob(66))
		looty += /obj/item/natural/thorn
	looty += /obj/item/natural/fibers


// normalbush looting
/obj/structure/flora/grass/bush/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "plantcross", 80, FALSE, -1)
		if(do_after(L, rand(1,5) DECISECONDS, src))
			if(prob(50) && looty.len)
				if(looty.len == 1)
					res_replenish = world.time + 8 MINUTES
				var/obj/item/B = pick_n_take(looty)
				if(B)
					B = new B(user.loc)
					user.put_in_hands(B)
					user.visible_message("<span class='notice'>[user] finds [B] in [src].</span>")
					return
			user.visible_message("<span class='warning'>[user] searches through [src].</span>")
			if(!looty.len)
				to_chat(user, "<span class='warning'>Picked clean.</span>")

/obj/structure/flora/grass/bush/CanPass(atom/movable/mover, turf/target)
	if(mover.throwing)
		mover.visible_message(span_danger("[mover] gets caught in \a [src]!"))
		return TRUE
	if(mover.pass_flags & PASSGRILLE)
		return TRUE
	if(ismob(mover))
		return TRUE
	return FALSE

// bush crossing
/obj/structure/flora/grass/bush/Crossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return

	var/mob/living/L = AM
	L.Immobilize(1 SECONDS)

	if(L.m_intent == MOVE_INTENT_RUN)
		L.visible_message(span_warning("[L] crashes into \a [src]!"), span_danger("I run into \a [src]."))
		log_combat(L, src, "ran into")
	else if(L.atom_flags & Z_FALLING)
		L.visible_message(span_warning("[L] falls onto \a [src]!"), span_danger("I fall onto \a [src]."))
		log_combat(L, src, "ran into")
	else
		to_chat(L, span_warning("I get stuck in \a [src]."))

	if(!ishuman(L))
		to_chat(L, span_warning("I cut myself on [src]'s thorns."))
		L.apply_damage(5, BRUTE)
	else
		var/mob/living/carbon/human/H = L
		var/obj/item/bodypart/BP = pick(H.bodyparts)
		BP.receive_damage(10)
		var/was_hard_collision = (H.m_intent == MOVE_INTENT_RUN || H.throwing || H.atom_flags & Z_FALLING)
		if((was_hard_collision && prob(10)) && !HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
			var/obj/item/natural/thorn/TH = new(src.loc)
			BP.add_embedded_object(TH, silent = TRUE)
			to_chat(H, span_danger("\A [TH] impales my [BP.name]."))
			if(!HAS_TRAIT(H, TRAIT_NOPAIN))
				H.emote("painscream")
				L.Stun(3 SECONDS) //that fucking hurt
				H.consider_ambush()
		else if(prob(70))
			to_chat(H, span_warning("A thorn [pick("slices","cuts","nicks")] my [BP.name]."))


/obj/structure/flora/grass/bush/wall
	name = "great bush"
	desc = "A bush, this one's roots are too thick and block the way."
	opacity = TRUE
	density = 1
	climbable = FALSE
	icon_state = "bushwall1"
	max_integrity = 150
	debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1, /obj/item/natural/thorn = 1)
	attacked_sound = 'sound/misc/woodhit.ogg'

/obj/structure/flora/grass/bush/wall/Initialize()
	. = ..()
	icon_state = "bushwall[pick(1,2)]"

/obj/structure/flora/grass/bush/wall/tundra
	name = "tundra great bush"
	icon_state = "bushwall1_tundra"

/obj/structure/flora/grass/bush/wall/tundra/Initialize()
	. = ..()
	icon_state = "bushwall[pick(1,2)]_tundra"

/obj/structure/flora/grass/bush/wall/update_icon()
	return

/obj/structure/flora/grass/bush/wall/CanPass(atom/movable/mover, turf/target)
	if(ismob(mover))
		return FALSE
	return ..()

/obj/structure/flora/grass/bush/wall/tall
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	desc = "A tall bush that has grown into a hedge."
	icon_state = "tallbush1"
	opacity = 1
	pixel_x = -16
	debris = null
	static_debris = null

/obj/structure/flora/grass/bush/wall/tall/Initialize()
	. = ..()
	icon_state = "tallbush[pick(1,2)]"

/obj/structure/flora/grass/bush/wall/tall/tundra
	name = "tundra great bush"
	icon_state = "tallbush1_tundra"

/obj/structure/flora/grass/bush/wall/tall/tundra/Initialize()
	. = ..()
	icon_state = "tallbush[pick(1,2)]_tundra"

/obj/structure/flora/grass/bush/wall/tall/bog
	desc = "A tall bush that has grown into a hedge... but this one seems diseased."
	name = "bog great bush"
	icon_state = "tallbush1_bog"

/obj/structure/flora/grass/bush/wall/tall/bog/Initialize()
	. = ..()
	icon_state = "tallbush[pick(1,2)]_bog"

// fyrituis bush
/obj/structure/flora/grass/pyroclasticflowers
	name = "odd group of flowers"
	desc = "A cluster of dangerously combustible flowers."
	icon_state = "pyroflower1"
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 1
	climbable = FALSE
	dir = SOUTH
	debris = list(/obj/item/natural/fibers = 1)
	var/list/looty2 = list()
	var/bushtype2
	var/res_replenish2

/obj/structure/flora/grass/pyroclasticflowers/update_icon()
	icon_state = "pyroflower[rand(1,3)]"

/obj/structure/flora/grass/pyroclasticflowers/Initialize()
	. = ..()
	if(prob(88))
		bushtype2 = pickweight(list(/obj/item/reagent_containers/food/snacks/produce/fyritius = 1))
	loot_replenish2()
	pixel_x += rand(-3,3)

/obj/structure/flora/grass/pyroclasticflowers/proc/loot_replenish2()
	if(bushtype2)
		looty2 += bushtype2
	if(prob(66))
		looty2 += /obj/item/reagent_containers/food/snacks/produce/fyritius

// pyroflower cluster looting
/obj/structure/flora/grass/pyroclasticflowers/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "plantcross", 80, FALSE, -1)
		if(do_after(L, rand(1,5) DECISECONDS, src))
			if(prob(50) && looty2.len)
				if(looty2.len == 1)
					res_replenish2 = world.time + 8 MINUTES
				var/obj/item/B = pick_n_take(looty2)
				if(B)
					B = new B(user.loc)
					user.put_in_hands(B)
					user.visible_message(span_notice("[user] finds [B] in [src]."))
					return
			user.visible_message(span_warning("[user] searches through [src]."))
			if(!looty2.len)
				to_chat(user, span_warning("Picked clean."))

// swarmpweed bush
/obj/structure/flora/grass/swampweed
	name = "bunch of swampweed"
	desc = "a green root good for smoking."
	icon_state = "swampweed1"
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 1
	climbable = FALSE
	dir = SOUTH
	debris = list(/obj/item/natural/fibers = 1)
	var/list/looty3 = list()
	var/bushtype3
	var/res_replenish3

/obj/structure/flora/grass/swampweed/Initialize()
	if(prob(88))
		bushtype3 = pickweight(list(/obj/item/reagent_containers/food/snacks/produce/swampweed = 1))
	loot_replenish3()
	pixel_x += rand(-3,3)
	return ..()

/obj/structure/flora/grass/swampweed/proc/loot_replenish3()
	if(bushtype3)
		looty3 += bushtype3
	if(prob(66))
		looty3 += /obj/item/reagent_containers/food/snacks/produce/swampweed





// pyroflower cluster looting
/obj/structure/flora/grass/pyroclasticflowers/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "plantcross", 80, FALSE, -1)
		if(do_after(L, rand(1,5) DECISECONDS, src))
			if(prob(50) && looty2.len)
				if(looty2.len == 1)
					res_replenish2 = world.time + 8 MINUTES
				var/obj/item/B = pick_n_take(looty2)
				if(B)
					B = new B(user.loc)
					user.put_in_hands(B)
					user.visible_message("<span class='notice'>[user] finds [B] in [src].</span>")
					return
			user.visible_message("<span class='warning'>[user] searches through [src].</span>")
			if(!looty2.len)
				to_chat(user, "<span class='warning'>Picked clean.</span>")

// swarmweed looting
/obj/structure/flora/grass/swampweed/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "plantcross", 80, FALSE, -1)
		if(do_after(L, rand(1,5) DECISECONDS, src))
			if(prob(50) && looty3.len)
				if(looty3.len == 1)
					res_replenish3 = world.time + 8 MINUTES
				var/obj/item/B = pick_n_take(looty3)
				if(B)
					B = new B(user.loc)
					user.put_in_hands(B)
					user.visible_message("<span class='notice'>[user] finds [B] in [src].</span>")
					return
			user.visible_message("<span class='warning'>[user] searches through [src].</span>")
			if(!looty3.len)
				to_chat(user, "<span class='warning'>Picked clean.</span>")

// varients


/obj/structure/flora/grass/pyroclasticflowers/update_icon()
	icon_state = "pyroflower[rand(1, 3)]"

/obj/structure/flora/grass/swampweed/update_icon()
	icon_state = "swarmpweed[rand(1, 3)]"


/obj/structure/flora/shroom_tree
	name = "shroom"
	desc = "A ginormous mushroom, prized by dwarves for their shroomwood."
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "mush1"
	opacity = 0
	density = 0
	max_integrity = 120
	blade_dulling = DULLING_CUT
	pixel_x = -16
	layer = 4.81
	attacked_sound = 'sound/misc/woodhit.ogg'
	destroy_sound = 'sound/misc/woodhit.ogg'
	static_debris = list( /obj/item/grown/log/tree/small = 1)
	dir = SOUTH

/obj/structure/flora/shroom_tree/attack_right(mob/user)
	if(user.mind && isliving(user))
		if(user.mind.special_items && user.mind.special_items.len)
			var/item = input(user, "What will I take?", "STASH") as null|anything in user.mind.special_items
			if(item)
				if(user.Adjacent(src))
					if(user.mind.special_items[item])
						var/path2item = user.mind.special_items[item]
						user.mind.special_items -= item
						var/obj/item/I = new path2item(user.loc)
						user.put_in_hands(I)
			return


/obj/structure/flora/shroom_tree/Initialize()
	. = ..()
	icon_state = "mush[rand(1,5)]"
	if(icon_state == "mush5")
		static_debris = list(/obj/item/natural/thorn=1, /obj/item/grown/log/tree/small = 1)
	pixel_x += rand(8,-8)
	var/static/list/loc_connections = list(COMSIG_ATOM_EXIT = PROC_REF(on_exit))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/flora/shroom_tree/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGRILLE))
		return 1
	if(get_dir(loc, target) == dir)
		return 0
	return 1

/obj/structure/flora/shroom_tree/proc/on_exit(datum/source, atom/movable/leaving, atom/new_location)
	SIGNAL_HANDLER
	if(get_dir(leaving.loc, new_location) == dir)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/flora/shroom_tree/fire_act(added, maxstacks)
	if(added > 5)
		return ..()

/obj/structure/flora/shroom_tree/obj_destruction(damage_flag)
	var/obj/structure/S = new /obj/structure/table/wood/treestump/shroomstump(loc)
	S.icon_state = "[icon_state]stump"
	. = ..()

/obj/structure/table/wood/treestump/shroomstump
	name = "shroom stump"
	desc = "It was a very happy shroom. Not anymore."
	icon_state = "mush1stump"
	desc = "Here once stood a mighty nether-cap, you feel a great sadness."
	opacity = 0
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	alpha = 255
	pixel_x = -16
	climb_offset = 14
	stump_loot = /obj/item/reagent_containers/food/snacks/truffles

/obj/structure/table/wood/treestump/shroomstump/Initialize()
	. = ..()
	icon_state = "mush[rand(1,4)]stump"

/obj/structure/roguerock
	name = "rock"
	desc = "Stone, faithful tool, weapon and companion."
	icon_state = "rock1"
	icon = 'icons/roguetown/misc/foliage.dmi'
	opacity = 0
	max_integrity = 50
	climbable = TRUE
	climb_time = 30
	density = TRUE
	layer = TABLE_LAYER
	blade_dulling = DULLING_BASH
	static_debris = null
	debris = null
	alpha = 255
	climb_offset = 14
	destroy_sound = 'sound/foley/smash_rock.ogg'
	attacked_sound = 'sound/foley/hit_rock.ogg'
	static_debris = list(/obj/item/natural/stone = 1)

/obj/structure/roguerock/Initialize()
	. = ..()
	icon_state = "rock[rand(1,4)]"


/*	..................   Thorn Bush   ................... */	// Updated to use searcher perception, can yield thorns
/obj/structure/flora/grass/thorn_bush
	name = "thorn bush"
	desc = "A thorny bush, bearing a bountiful collection of razor sharp thorns!"
	icon_state = "thornbush1"
	layer = ABOVE_ALL_MOB_LAYER
	blade_dulling = DULLING_CUT
	max_integrity = 35
	climbable = FALSE
	dir = SOUTH
	debris = list(/obj/item/natural/thorn = 3, /obj/item/grown/log/tree/stick = 1)
	prob2findstuff = 15

/obj/structure/flora/grass/thorn_bush/Initialize()
	. = ..()
	icon_state = "thornbush[rand(1,2)]"

/obj/structure/flora/grass/thorn_bush/attack_hand(mob/living/user)
	var/mob/living/L = user
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src.loc, "plantcross", 80, FALSE, -1)
	prob2findstuff = prob2findstuff + ( user.STAPER * 4 )
	user.visible_message(span_noticesmall("[user] searches through [src]."))

	if(do_after(L, rand(5 DECISECONDS, 2 SECONDS), src))

		if(islooted)
			to_chat(user, span_warning("Picked clean."))
			return

		if(prob(prob2findstuff))
			var/obj/item/natural/thorn/B = new
			user.put_in_hands(B)
			user.visible_message(span_notice("[user] finds [B] in [src]."))
			if(prob(20))
				islooted = TRUE

		else
			if(!HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
				user.apply_damage(5, BRUTE)
			to_chat(user, span_warning("You cut yourself on the thorns!"))

	prob2findstuff = 15

/obj/structure/flora/grass/thorn_bush/Crossed(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.Immobilize(10)
		if(L.m_intent == MOVE_INTENT_SNEAK)
			return
		if(L.m_intent == MOVE_INTENT_WALK)
			if(!ishuman(L))
				return
			else
				to_chat(L, span_warning("I'm scratched by the thorns."))
				L.apply_damage(5, BRUTE)
				L.Immobilize(10)

		if(L.m_intent == MOVE_INTENT_RUN)
			if(!ishuman(L))
				to_chat(L, "<span class='warning'>I'm cut on a thorn!</span>")
				L.apply_damage(5, BRUTE)
			else
				var/mob/living/carbon/human/H = L
				if(prob(80))
					if(!HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
						var/obj/item/bodypart/BP = pick(H.bodyparts)
						var/obj/item/natural/thorn/TH = new(src.loc)
						BP.add_embedded_object(TH, silent = TRUE)
						BP.receive_damage(10)
						to_chat(H, "<span class='danger'>\A [TH] impales my [BP.name]!</span>")
						L.Paralyze(10)
				else
					var/obj/item/bodypart/BP = pick(H.bodyparts)
					to_chat(H, "<span class='warning'>A thorn [pick("slices","cuts","nicks")] my [BP.name].</span>")
					BP.receive_damage(10)
					L.Immobilize(10)


/*	..................   Meagre Bush   ................... */	// This works on the characters stats and doesnt have a preset vendor content. Hardmode compared to the OG one.
/obj/structure/flora/grass/bush_meagre
	name = "bush"
	desc = "Home to thorns, spiders, and maybe some berries."
	icon_state = "bush1"
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 35
	climbable = FALSE
	dir = SOUTH
	debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1)
	prob2findstuff = 18
	var/prob2findgoodie = 15	// base % to find good stuff in the bush, gets modded by fortune and perception
	var/tobacco
	var/berries
	var/silky	// just for bog bushes, its part of a whole thing, don't add bog bushes outside bog
	var/goodie
	var/trashie = /obj/item/natural/thorn

/obj/structure/flora/grass/bush_meagre/update_icon()
	if(!silky)
		if(berries)
			icon_state = "bush_berry[rand(1,3)]"
		else
			icon_state = "bush[rand(1, 3)]"

/obj/structure/flora/grass/bush_meagre/tundra
	name = "tundra bush"
	icon_state = "bush1_tundra"

/obj/structure/flora/grass/bush_meagre/tundra/update_icon()
	icon_state = "bush[rand(1,3)]_tundra"

/obj/structure/flora/grass/bush_meagre/yellow
	name = "bog bush"
	icon_state = "bush1_bog"

/obj/structure/flora/grass/bush_meagre/yellow/update_icon()
	icon_state = "bush[rand(1,3)]_bog"

/obj/structure/flora/grass/bush_meagre/Initialize()
	if(silky)
		goodie = /obj/item/natural/worms/grub_silk
		if(prob(20))
			goodie = /obj/item/reagent_containers/food/snacks/produce/poppy
	else
		if(prob(30))
			tobacco = TRUE
			berries = FALSE
			goodie = /obj/item/reagent_containers/food/snacks/produce/westleach
		else
			tobacco = FALSE
			berries = TRUE
			if(prob(60))
				goodie = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry
			else
				goodie = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison
	pixel_x += rand(-3,3)
	if(prob(10))
		trashie = /obj/item/natural/fibers
	if(prob(70))
		debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1, /obj/item/natural/thorn = 1)
	return ..()

// bush crossing
/obj/structure/flora/grass/bush_meagre/Crossed(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.Immobilize(5)
		if(L.m_intent == MOVE_INTENT_WALK)
			L.Immobilize(5)
		if(L.m_intent == MOVE_INTENT_RUN)
			if(!ishuman(L))
				to_chat(L, "<span class='warning'>I'm cut on a thorn!</span>")
				L.apply_damage(5, BRUTE)
				L.Immobilize(5)
			else
				var/mob/living/carbon/human/H = L
				if(prob(20))
					if(!HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
						var/obj/item/bodypart/BP = pick(H.bodyparts)
						var/obj/item/natural/thorn/TH = new(src.loc)
						BP.add_embedded_object(TH, silent = TRUE)
						BP.receive_damage(10)
						to_chat(H, "<span class='danger'>\A [TH] impales my [BP.name]!</span>")
						L.Paralyze(5)
				else
					var/obj/item/bodypart/BP = pick(H.bodyparts)
					to_chat(H, "<span class='warning'>A thorn [pick("slices","cuts","nicks")] my [BP.name].</span>")
					BP.receive_damage(10)

/obj/structure/flora/grass/bush_meagre/attack_hand(mob/living/user)
	var/mob/living/L = user
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src.loc, "plantcross", 80, FALSE, -1)
	prob2findstuff = prob2findstuff + ( user.STAPER * 4 )
	prob2findgoodie = prob2findgoodie + ( user.STALUC * 2 ) + ( user.STAPER * 2 )
	luckydouble = ( user.STALUC * 2 )
	user.visible_message(span_noticesmall("[user] searches through [src]."))

	if(do_after(L, rand(5 DECISECONDS, 2 SECONDS), src))

		if(islooted)
			to_chat(user, span_warning("Picked clean."))
			return

		if(prob(prob2findstuff))

			if(prob(prob2findgoodie))
				var/obj/item/B = goodie
				if(B)
					B = new B(user.loc)
					user.put_in_hands(B)
					user.visible_message(span_notice("[user] finds [B] in [src]."))
					if(HAS_TRAIT(user, TRAIT_MIRACULOUS_FORAGING))
						if(prob(35))
							return
					if(prob(luckydouble))
						return
					else
						islooted = TRUE
						add_overlay("bush_empty_overlay")
					return
			else
				var/obj/item/B = trashie
				if(B)
					B = new B(user.loc)
					user.put_in_hands(B)
					user.visible_message(span_notice("[user] finds [B] in [src]."))
					if(HAS_TRAIT(user, TRAIT_MIRACULOUS_FORAGING))
						if(prob(35))
							return
					if(prob(luckydouble))
						return
					else
						islooted = TRUE
						add_overlay("bush_empty_overlay")
					return

		else
			to_chat(user, span_noticesmall("Didn't find anything."))
	prob2findstuff = 18
	prob2findgoodie = 15
	luckydouble	= 3


/obj/structure/flora/grass/bush_meagre/bog
	desc = "These large bushes are known to be well-liked by silkworms who make their nests in their dark depths."
	icon = 'icons/mob/creacher/trolls/troll.dmi'
	icon_state = "troll_hide"
	pixel_x = -16
	pixel_y = -1
	silky = TRUE
