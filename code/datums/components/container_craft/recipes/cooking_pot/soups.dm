/datum/container_craft/cooking/egg_soup
	name = "Egg Soup"
	created_reagent = /datum/reagent/consumable/soup/egg
	requirements = list(/obj/item/reagent_containers/food/snacks/egg = 1)
	max_optionals = 2
	optional_wildcard_requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/vegetable = 2
	)
	finished_smell = /datum/pollutant/food/egg_soup
	crafting_time = 80 SECONDS

/datum/container_craft/cooking/cheese_soup
	name = "Cheese Soup"
	created_reagent = /datum/reagent/consumable/soup/cheese
	requirements = list(/obj/item/reagent_containers/food/snacks/cheese = 1)
	max_optionals = 2
	optional_wildcard_requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/vegetable = 2
	)
	finished_smell = /datum/pollutant/food/cheese_soup
	crafting_time = 80 SECONDS

/datum/container_craft/cooking/cheese_soup/wedge
	requirements = list(/obj/item/reagent_containers/food/snacks/cheese_wedge = 1)
