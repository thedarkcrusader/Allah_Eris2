/datum/codex_category/species
	name = "Species"
	desc = "Sapient species encountered in known space."

/datum/codex_category/species/Initialize()
	for(var/thing in GLOB.species_by_name)
		var/singleton/species/species = GLOB.species_by_name[thing]
		if(!species.hidden_from_codex)
			var/datum/codex_entry/entry = new(_display_name = "[species.name] (species)")
			entry.lore_text = species.codex_description
			entry.mechanics_text = species.ooc_codex_information
			entry.update_links()
			SScodex.add_entry_by_string(entry.display_name, entry)
			SScodex.add_entry_by_string(species.name, entry)
			items += entry.display_name
	..()
