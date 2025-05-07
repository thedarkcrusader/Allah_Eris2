/obj/item/material/knife
	abstract_type = /obj/item/material/knife
	name = "the concept of a knife"
	desc = "You call that a knife? This is a master item - berate the admin or mapper who spawned this!"
	icon = 'icons/obj/weapons/knife.dmi'
	icon_state = "knife"
	item_state = "knife"
	max_force = 15
	force_multiplier = 0.3
	base_parry_chance = 15
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	matter = list(MATERIAL_STEEL = 12000)
	origin_tech = list(TECH_MATERIAL = 1)
	unbreakable = TRUE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	sharp = TRUE
	edge = TRUE
	item_flags = ITEM_FLAG_CAN_HIDE_IN_SHOES


/obj/item/material/knife/unathi
	name = "dueling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon_state = "unathiknife"
	default_material = MATERIAL_WOOD
	applies_material_name = FALSE
	applies_material_colour = FALSE
	w_class = ITEM_SIZE_NORMAL


/obj/item/material/knife/kitchen
	name = "kitchen knife"
	icon_state = "kitchenknife"
	desc = "A general purpose chef's knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	applies_material_name = FALSE


/obj/item/material/knife/kitchen/cleaver
	name = "butcher's cleaver"
	desc = "A heavy blade used to process food, especially animal carcasses."
	icon_state = "butch"
	armor_penetration = 5
	force_multiplier = 0.18
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


/obj/item/material/knife/kitchen/cleaver/bronze
	name = "master chef's cleaver"
	desc = "A heavy blade used to process food. This one is so fancy, it must be for a truly exceptional chef. There aren't any here, so what it's doing here is anyone's guess."
	default_material = MATERIAL_BRONZE
	force_multiplier = 1


/obj/item/material/knife/combat
	name = "combat knife"
	desc = "A blade with a saw-like pattern on the reverse edge and a heavy handle."
	icon_state = "tacknife"
	force_multiplier = 0.2
	base_parry_chance = 30
	w_class = ITEM_SIZE_SMALL


/obj/item/material/knife/hook
	name = "meat hook"
	desc = "A sharp, metal hook what sticks into things."
	icon_state = "hook_knife"
	item_state = "hook_knife"
	sharp = FALSE


/obj/item/material/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/cult.dmi'
	icon_state = "render"
	base_parry_chance = 30
	applies_material_colour = FALSE
	applies_material_name = FALSE


/obj/item/material/knife/utility
	name = "utility knife"
	desc = "An utility knife with a polymer handle, commonly used through human space."
	icon_state = "utility"
	max_force = 10
	force_multiplier = 0.2
	w_class = ITEM_SIZE_SMALL


/obj/item/material/knife/utility/lightweight
	name = "lightweight utility knife"
	desc = "A lightweight utility knife made out of a steel alloy."
	icon_state = "titanium"
