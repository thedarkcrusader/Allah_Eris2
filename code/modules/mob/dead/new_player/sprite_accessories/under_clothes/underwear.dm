/datum/sprite_accessory/underwear
	icon = 'icons/roguetown/mob/underwear.dmi'
	use_static = FALSE

/datum/sprite_accessory/underwear/regm
	name = "Undies"
	icon_state = "male_reg"
	gender = MALE
	specuse = list("human", "aasimar", "tiefling", "halforc")

/datum/sprite_accessory/underwear/regme
	name = "Undiese"
	icon_state = "maleelf_reg"
	gender = MALE
	specuse = list("elf")

/datum/sprite_accessory/underwear/regmd
	name = "Undiesd"
	icon_state = "maledwarf_reg"
	gender = MALE
	specuse = list("dwarf")

/datum/sprite_accessory/underwear/female_bikini
	name = "Femundies"
	icon_state = "female_bikini"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/underwear/female_leotard
	name = "Femleotard"
	icon_state = "female_leotard"
	gender = FEMALE
	specuse = ALL_RACES_LIST
	roundstart = FALSE

//For use on Younglings
/datum/sprite_accessory/underwear/child
	name = "Youngling"
	icon_state = "child"
	gender = MALE
	specuse = ALL_RACES_LIST
	roundstart = FALSE

/datum/sprite_accessory/underwear/child_f
	name = "FemYoungling"
	icon_state = "child_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST
	roundstart = FALSE
