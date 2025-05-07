#define DRYING_TIME 5 * 60*10 //for 1 unit of depth in puddle (amount var)
#define BLOOD_SIZE_SMALL     1
#define BLOOD_SIZE_MEDIUM    2
#define BLOOD_SIZE_BIG       3
#define BLOOD_SIZE_NO_MERGE -1

var/global/list/image/splatter_cache=list()

/obj/decal/cleanable/blood
	name = "blood"
	desc = "It's some blood. That's not supposed to be there."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7", "dir_splatter_1", "dir_splatter_2")
	blood_DNA = list()
	generic_filth = TRUE
	persistent = TRUE
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | NO_CLIENT_COLOR
	cleanable_scent = "blood"
	scent_descriptor = SCENT_DESC_ODOR

	var/base_icon = 'icons/effects/blood.dmi'
	var/basecolor=COLOR_BLOOD_HUMAN // Color when wet.
	var/amount = 5
	var/drytime
	var/dryname = "dried blood"
	var/drydesc = "It's dry and crusty. Someone isn't doing their job."
	var/blood_size = BLOOD_SIZE_MEDIUM // A relative size; larger-sized blood will not override smaller-sized blood, except maybe at mapload.

/obj/decal/cleanable/blood/reveal_blood()
	if(!fluorescent || invisibility == 100)
		set_invisibility(0)
		fluorescent = ATOM_FLOURESCENCE_INACTIVE
		basecolor = COLOR_LUMINOL
		update_icon()

/obj/decal/cleanable/blood/clean_blood()
	fluorescent = ATOM_FLOURESCENCE_NONE
	if(invisibility != 100)
		set_invisibility(100)
		amount = 0
		STOP_PROCESSING(SSobj, src)
		remove_extension(src, /datum/extension/scent)
		return TRUE

/obj/decal/cleanable/blood/hide()
	return

/obj/decal/cleanable/blood/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/decal/cleanable/blood/Initialize(mapload)
	. = ..()
	if(merge_with_blood(!mapload))
		return INITIALIZE_HINT_QDEL
	start_drying()

// Returns true if overriden and needs deletion. If the argument is false, we will merge into any existing blood.
/obj/decal/cleanable/blood/proc/merge_with_blood(override = TRUE)
	. = FALSE
	if(blood_size == BLOOD_SIZE_NO_MERGE)
		return
	if(isturf(loc))
		for(var/obj/decal/cleanable/blood/B in loc)
			if(B == src)
				continue
			if(B.blood_size == BLOOD_SIZE_NO_MERGE)
				continue
			if(override && blood_size >= B.blood_size)
				if (B.blood_DNA)
					blood_DNA |= B.blood_DNA.Copy()
				qdel(B)
				continue
			if(B.blood_DNA)
				B.blood_DNA |= blood_DNA.Copy()
			. = TRUE

/obj/decal/cleanable/blood/proc/start_drying()
	drytime = world.time + DRYING_TIME * (amount+1)
	update_icon()
	START_PROCESSING(SSobj, src)

/obj/decal/cleanable/blood/Process()
	if(world.time > drytime)
		dry()

/obj/decal/cleanable/blood/on_update_icon()
	if(basecolor == "rainbow") basecolor = get_random_colour()
	color = basecolor
	if(basecolor == SYNTH_BLOOD_COLOUR)
		SetName("oil")
		desc = "It's black and greasy."
	else
		SetName(initial(name))
		desc = initial(desc)

/obj/decal/cleanable/blood/Crossed(mob/living/carbon/human/perp)
	if (!istype(perp))
		return
	if(amount < 1)
		return
	if(MOVING_DELIBERATELY(perp))
		return

	if (!perp.bloody_feet_custom(basecolor, amount, blood_DNA) && perp.buckled && istype(perp.buckled, /obj/structure/bed/chair/wheelchair))
		var/obj/structure/bed/chair/wheelchair/W = perp.buckled
		W.bloodiness = 4
		W.add_blood_custom(basecolor, amount, blood_DNA)
	amount--

/obj/decal/cleanable/blood/proc/dry()
	name = dryname
	desc = drydesc
	color = adjust_brightness(color, -50)
	amount = 0
	remove_extension(src, /datum/extension/scent)
	STOP_PROCESSING(SSobj, src)

/obj/decal/cleanable/blood/attack_hand(mob/living/carbon/human/user)
	..()
	if (amount && istype(user))
		if (user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		var/obj/item/clothing/gloves/gloves = user.get_equipped_item(slot_gloves)
		if(istype(gloves))
			gloves.add_blood_custom(basecolor, taken, list(blood_DNA.Copy()))
		else
			to_chat(user, SPAN_NOTICE("You get some of \the [src] on your hands."))
			if (!user.blood_DNA)
				user.blood_DNA = list()
			user.blood_DNA |= blood_DNA.Copy()
			user.bloody_hands = taken
			user.hand_blood_color = basecolor
			user.update_inv_gloves(1)
			user.verbs += /mob/living/carbon/human/proc/bloody_doodle

/obj/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2
	blood_size = BLOOD_SIZE_BIG
	scent_intensity = /singleton/scent_intensity/strong
	scent_range = 3

/obj/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "Drips and drops of blood."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1","2","3","4","5")
	amount = 0
	blood_size = BLOOD_SIZE_SMALL
	scent_intensity = /singleton/scent_intensity
	scent_range = 1

	var/list/drips

/obj/decal/cleanable/blood/drip/Initialize()
	. = ..()
	drips = list(icon_state)

/obj/decal/cleanable/blood/writing
	icon = 'icons/effects/writing.dmi'
	icon_state = "writing"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1","writing2","writing3","writing4","writing5")
	amount = 0
	var/message
	blood_size = BLOOD_SIZE_BIG
	scent_intensity = /singleton/scent_intensity
	scent_range = 1

/obj/decal/cleanable/blood/writing/New()
	..()
	if(LAZYLEN(random_icon_states))
		for(var/obj/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/decal/cleanable/blood/writing/examine(mob/user)
	. = ..()
	to_chat(user, "It reads: [SPAN_COLOR(basecolor, "\"[message]\"")]")

/obj/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib5", "gib6")
	var/fleshcolor = "#ffffff"
	blood_size = BLOOD_SIZE_NO_MERGE
	cleanable_scent = "viscera"
	scent_intensity = /singleton/scent_intensity/overpowering
	scent_range = 4

/obj/decal/cleanable/blood/gibs/on_update_icon()

	var/image/giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = get_random_colour()
	giblets.color = fleshcolor

	var/icon/blood = new(base_icon,"[icon_state]",dir)
	if(basecolor == "rainbow") basecolor = get_random_colour()
	blood.Blend(basecolor,ICON_MULTIPLY)

	icon = blood
	ClearOverlays()
	AddOverlays(giblets)

/obj/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")


/obj/decal/cleanable/blood/gibs/proc/streak(list/directions)
	var/direction = pick(directions)
	for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
		sleep(3)
		if (i > 0)
			var/obj/decal/cleanable/blood/b = new /obj/decal/cleanable/blood/splatter(loc)
			b.basecolor = src.basecolor
			b.update_icon()
		if (step_to(src, get_step(src, direction), 0))
			break

/obj/decal/cleanable/blood/gibs/start_drying()
	return

/obj/decal/cleanable/blood/gibs/merge_with_blood()
	return FALSE

/obj/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	generic_filth = TRUE
	persistent = TRUE
	var/dry = FALSE

/obj/decal/cleanable/mucus/Initialize()
	. = ..()
	addtimer(new Callback(src, PROC_REF(set_dry)), DRYING_TIME * 2)

/obj/decal/cleanable/mucus/proc/set_dry()
	dry = TRUE

#undef BLOOD_SIZE_SMALL
#undef BLOOD_SIZE_MEDIUM
#undef BLOOD_SIZE_BIG
#undef BLOOD_SIZE_NO_MERGE
