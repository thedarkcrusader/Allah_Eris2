GLOBAL_LIST_EMPTY(portals)					        //list of all /obj/effect/portal
GLOBAL_LIST_EMPTY(machines)					        //NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !

GLOBAL_LIST(chemical_reactions_list)				//list of all /datum/chemical_reaction datums. Used during chemical reactions
GLOBAL_LIST(chemical_reagents_list)				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_INIT(chemical_reagents_color_list, build_chemical_reagent_color_list())		//list of random colors for reagents, initiated at roundstart or when a reagent is created
GLOBAL_LIST_EMPTY(crafting_recipes)				//list of all table craft recipes
GLOBAL_LIST_EMPTY(anvil_recipes)				//list of all anvil crafted recipes
GLOBAL_LIST_EMPTY(artificer_recipes)			//list of all artificer recipes
GLOBAL_LIST_EMPTY(alch_grind_recipes)			//list of all alchemy grinding recipes
GLOBAL_LIST_EMPTY(alch_cauldron_recipes)		//list of all alchemy cauldron recipes
GLOBAL_LIST_EMPTY(poi_list)					//list of points of interest for observe/follow
GLOBAL_LIST_EMPTY(pinpointer_list)			//list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_LIST_EMPTY(zombie_infection_list) 		// A list of all zombie_infection organs, for any mass "animation"
GLOBAL_LIST_EMPTY(ladders)
GLOBAL_LIST_EMPTY(trophy_cases)

GLOBAL_LIST_INIT(reverse_dir, list(2, 1, 3, 8, 10, 9, 11, 4, 6, 5, 7, 12, 14, 13, 15, 32, 34, 33, 35, 40, 42, 41, 43, 36, 38, 37, 39, 44, 46, 45, 47, 16, 18, 17, 19, 24, 26, 25, 27, 20, 22, 21, 23, 28, 30, 29, 31, 48, 50, 49, 51, 56, 58, 57, 59, 52, 54, 53, 55, 60, 62, 61, 63))

GLOBAL_LIST_EMPTY(mob_spawners) 		    // All mob_spawn objects

/* COLORS */
GLOBAL_LIST_INIT(peasant_dyes, list(
	"Linen" = CLOTHING_LINEN,
	"Canvas" = CLOTHING_CANVAS,
	"Soot Black" = CLOTHING_SOOT_BLACK,
	"Winestain Red" = CLOTHING_WINESTAIN_RED,
	"Peasant Brown" = CLOTHING_PEASANT_BROWN,
	"Mud Brown" = CLOTHING_MUD_BROWN,
	"Chestnut" = CLOTHING_CHESTNUT,
	"Old Leather" = CLOTHING_OLD_LEATHER,
	"Spring Green" = CLOTHING_SPRING_GREEN,
	"Berry Blue" = CLOTHING_BERRY_BLUE,
))
GLOBAL_PROTECT(peasant_dyes)

GLOBAL_LIST_INIT(noble_dyes, list(
	"Dark Ink" = CLOTHING_DARK_INK,
	"Plum Purple" = CLOTHING_PLUM_PURPLE,
	"Salmon" = CLOTHING_SALMON,
	"Maroon" = CLOTHING_MAROON,
	"Red Ochre" =  CLOTHING_RED_OCHRE,
	"Forest Green" = CLOTHING_FOREST_GREEN,
	"Sky Blue" = CLOTHING_SKY_BLUE,
	"Mustard Yellow" = CLOTHING_MUSTARD_YELLOW,
	"Yellow Ochre" = CLOTHING_YELLOW_OCHRE,
	"Ash Grey" = CLOTHING_ASH_GREY,
	"Russet" = CLOTHING_RUSSET,
	"Blood Red" = CLOTHING_BLOOD_RED,
	"Swampweed" = CLOTHING_SWAMPWEED,
	"Ocean" = CLOTHING_OCEAN,
))
GLOBAL_PROTECT(noble_dyes)

GLOBAL_LIST_INIT(royal_dyes, list(
	"Royal Black" = CLOTHING_ROYAL_BLACK,
	"Royal Red" = CLOTHING_ROYAL_RED,
	"Royal Purple" = CLOTHING_ROYAL_PURPLE,
	"Royal Majenta" = CLOTHING_ROYAL_MAJENTA,
	"Royal Teal" = CLOTHING_ROYAL_TEAL,

	"Bark Brown" = CLOTHING_BARK_BROWN,
	"Bog Green" = CLOTHING_BOG_GREEN,
	"Fyritius Orange" = CLOTHING_FYRITIUS_ORANGE,
	"Pear Yellow" = CLOTHING_PEAR_YELLOW,
	"Chalk White" = CLOTHING_CHALK_WHITE,
))
GLOBAL_PROTECT(royal_dyes)

GLOBAL_LIST_INIT(steam_armor, list(
	/obj/item/clothing/armor/steam,
	/obj/item/clothing/gloves/plate/steam,
	/obj/item/clothing/head/helmet/heavy/steam,
	/obj/item/clothing/shoes/boots/armor/steam,
	/obj/item/clothing/cloak/boiler,
))
