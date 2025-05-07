/datum/gear_tweak/proc/get_contents(metadata)
	return

/datum/gear_tweak/proc/get_metadata(user, metadata, title)
	return

/datum/gear_tweak/proc/get_default()
	return

/datum/gear_tweak/proc/tweak_gear_data(metadata, datum/gear_data)
	return

/datum/gear_tweak/proc/tweak_item(user, obj/item/I, metadata)
	return

/datum/gear_tweak/proc/tweak_description(description, metadata, extend_description)
	return description

/*
* Color adjustment
*/

/datum/gear_tweak/color
	var/list/valid_colors

/datum/gear_tweak/color/New(list/valid_colors)
	src.valid_colors = valid_colors
	..()

/datum/gear_tweak/color/get_contents(metadata)
	return "Color: [SPAN_COLOR(metadata, "&#9899;")]"

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_WHITE

/datum/gear_tweak/color/get_metadata(user, metadata, title = CHARACTER_PREFERENCE_INPUT_TITLE)
	if(valid_colors)
		return input(user, "Choose a color.", title, metadata) as null|anything in valid_colors
	return input(user, "Choose a color.", title, metadata) as color|null

/datum/gear_tweak/color/tweak_item(user, obj/item/I, metadata)
	if(valid_colors && !(metadata in valid_colors))
		return
	I.color = sanitize_hexcolor(metadata, I.color)

/*
* Path adjustment
*/

/datum/gear_tweak/path
	var/list/valid_paths
	/// Stores extended descriptions by instance type (as opposed to metadata string)
	var/static/list/extended_description_cache

/datum/gear_tweak/path/New(list/valid_paths)
	if(!length(valid_paths))
		CRASH("No type paths given")
	var/list/duplicate_keys = duplicates(valid_paths)
	if(length(duplicate_keys))
		CRASH("Duplicate names found: [english_list(duplicate_keys)]")
	var/list/duplicate_values = duplicates(list_values(valid_paths))
	if(length(duplicate_values))
		CRASH("Duplicate types found: [english_list(duplicate_values)]")
	// valid_paths, but with names sanitized to remove \improper
	var/list/valid_paths_san = list()
	for(var/path_name in valid_paths)
		if(!istext(path_name))
			CRASH("Expected a text key, was [log_info_line(path_name)]")
		var/selection_type = valid_paths[path_name]
		if(!ispath(selection_type, /obj/item))
			CRASH("Expected an /obj/item path, was [log_info_line(selection_type)]")
		var/path_name_san = replacetext(path_name, "\improper", "")
		valid_paths_san[path_name_san] = selection_type
	src.valid_paths = sortAssoc(valid_paths_san)

/datum/gear_tweak/path/type/New(type_path)
	..(atomtype2nameassoclist(type_path))

/datum/gear_tweak/path/subtype/New(type_path)
	..(atomtypes2nameassoclist(subtypesof(type_path)))

/datum/gear_tweak/path/specified_types_list/New(type_paths)
	..(atomtypes2nameassoclist(type_paths))

/datum/gear_tweak/path/specified_types_args/New()
	..(atomtypes2nameassoclist(args))

/datum/gear_tweak/path/get_contents(metadata)
	return "Type: [metadata]"

/datum/gear_tweak/path/get_default()
	return valid_paths[1]

/datum/gear_tweak/path/get_metadata(user, metadata, title)
	return input(user, "Choose a type.", CHARACTER_PREFERENCE_INPUT_TITLE, metadata) as null|anything in valid_paths

/datum/gear_tweak/path/tweak_gear_data(metadata, datum/gear_data/gear_data)
	if(!(metadata in valid_paths))
		return
	gear_data.path = valid_paths[metadata]

/datum/gear_tweak/path/tweak_description(description, metadata, extend_description)
	metadata ||= get_default()
	if(!(metadata in valid_paths))
		return ..()
	var/obj/O = valid_paths[metadata]
	. = initial(O.desc) || description
	if (extend_description)
		extended_description_cache ||= new()
		var/extra_desc = extended_description_cache[O]
		if (isnull(extra_desc))
			var/atom/instance = new O(null)
			// Defaults to a non-null value to avoid initializing a given type more than once,
			// thanks to the if-check above doing an isnull-check rather than falsy one
			extended_description_cache[O] = extra_desc = (instance.GetExtendedLoadoutDescription() || "")
			qdel(instance)
		if(extra_desc)
			. += "<br>[extra_desc]"

/atom/proc/GetExtendedLoadoutDescription()
	return

/obj/item/storage/GetExtendedLoadoutDescription()
	var/list/description_counts = new()
	for(var/atom/A in src)
		description_counts[strip_improper(A.name)+"<br>"+A.desc]++

	var/list/item_descriptions = list("Contains:")
	if (length(description_counts))
		for (var/description_count in description_counts)
			item_descriptions.Add("[description_counts[description_count]]&#215;[description_count]")
	else
		item_descriptions.Add("<i>Nothing</i>")

	return FONT_SMALL(jointext(item_descriptions,"<br>"))

/*
* Content adjustment
*/

/datum/gear_tweak/contents
	var/list/valid_contents

/datum/gear_tweak/contents/New()
	valid_contents = args.Copy()
	..()

/datum/gear_tweak/contents/get_contents(metadata)
	return "Contents: [english_list(metadata, and_text = ", ", final_comma_text = "")]"

/datum/gear_tweak/contents/get_default()
	. = list()
	for(var/i = 1 to length(valid_contents))
		. += "Random"

/datum/gear_tweak/contents/get_metadata(user, list/metadata, title)
	. = list()
	for(var/i = length(metadata) to (length(valid_contents) - 1))
		metadata += "Random"
	for(var/i = 1 to length(valid_contents))
		var/entry = input(user, "Choose an entry.", CHARACTER_PREFERENCE_INPUT_TITLE, metadata[i]) as null|anything in (valid_contents[i] + list("Random", "None"))
		if(entry)
			. += entry
		else
			return metadata

/datum/gear_tweak/contents/tweak_item(owner, obj/item/I, list/metadata)
	if(length(metadata) != length(valid_contents))
		return
	for(var/i = 1 to length(valid_contents))
		var/path
		var/list/contents = valid_contents[i]
		if(metadata[i] == "Random")
			path = pick(contents)
			path = contents[path]
		else if(metadata[i] == "None")
			continue
		else
			path = 	contents[metadata[i]]
		if(path)
			new path(I)
		else
			log_debug("Failed to tweak item: Index [i] in [json_encode(metadata)] did not result in a valid path.")
			to_chat(owner, SPAN_WARNING("Your loadout selection for \the [I] that includes \the [metadata[i]] could not spawn properly. This likely means a saved configuration is no longer available or is invalid. Contact a dev for help. This is likely a bug."))

/*
* Ragent adjustment
*/

/datum/gear_tweak/reagents
	var/list/valid_reagents

/datum/gear_tweak/reagents/New(list/reagents)
	valid_reagents = reagents.Copy()
	..()

/datum/gear_tweak/reagents/get_contents(metadata)
	return "Reagents: [metadata]"

/datum/gear_tweak/reagents/get_default()
	return "Random"

/datum/gear_tweak/reagents/get_metadata(user, list/metadata, title)
	. = input(user, "Choose an entry.", CHARACTER_PREFERENCE_INPUT_TITLE, metadata) as null|anything in (valid_reagents + list("Random", "None"))
	if(!.)
		return metadata

/datum/gear_tweak/reagents/tweak_item(user, obj/item/I, list/metadata)
	if(metadata == "None")
		return
	var/reagent
	if(metadata == "Random")
		reagent = valid_reagents[pick(valid_reagents)]
	else
		reagent = valid_reagents[metadata]
	if(reagent)
		return I.reagents.add_reagent(reagent, I.reagents.get_free_space())

/*
* Custom Setup
*/
/datum/gear_tweak/custom_setup
	/*
	* The fully qualified path of a proc on the created item.
	* Provides the ability to carry out complex post-creation customization of a loadout object.
	*/
	var/custom_setup_proc

/datum/gear_tweak/custom_setup/New(custom_setup_proc)
	src.custom_setup_proc = custom_setup_proc
	..()

/datum/gear_tweak/custom_setup/tweak_item(user, item)
	call(item, custom_setup_proc)(user)

/*
* Custom [Var]
*/
/datum/gear_tweak/custom_var
	var/var_to_tweak
	/// The user input method to use if `valid_list_options` does not contain any items.
	var/input_method = PROC_REF(InputText)
	var/content_text
	var/input_title = CHARACTER_PREFERENCE_INPUT_TITLE
	var/input_message
	/// Used to sanitize when using the input_message and input_text methods.
	var/max_input_length = MAX_MESSAGE_LEN
	/// Used to sanitize when using the input_num method. Setting this var does not mandate setting max_input_value.
	var/min_input_value
	/// Used to sanitize when using the input_num method. Setting this var does not mandate setting min_input_value.
	var/max_input_value
	/// If this list contains items the user is limited to these choices.
	var/list/valid_list_options

/datum/gear_tweak/custom_var/New(list/valid_list_options)
	src.valid_list_options = valid_list_options
	..()

/datum/gear_tweak/custom_var/get_metadata(user, metadata, title)
	var/final_title = title || input_title || CHARACTER_PREFERENCE_INPUT_TITLE
	if(length(valid_list_options))
		return input(user, input_message + " Click cancel to use the default.", final_title, metadata) as null|anything in valid_list_options
	var/default = html_decode(metadata)
	return call(src, input_method)(user, input_message + " Leave blank to use the default.", final_title, default)

/datum/gear_tweak/custom_var/tweak_item(user, obj/item/item, metadata)
	if(!metadata)
		return
	if (length(valid_list_options) && !(metadata in valid_list_options))
		return
	metadata = TweakMetadata(metadata)
	SetVar(item, metadata)

/// Override this var if a particular proc call is needed, for example /SetName() when setting the name-var
/datum/gear_tweak/custom_var/proc/SetVar(obj/item/item, metadata)
	SHOULD_NOT_SLEEP(TRUE)
	PROTECTED_PROC(TRUE)
	item.vars[var_to_tweak] = metadata

/datum/gear_tweak/custom_var/proc/TweakMetadata(metadata)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	PROTECTED_PROC(TRUE)
	return metadata

/datum/gear_tweak/custom_var/get_contents(metadata)
	return "[content_text]: [metadata]"

// Note, didn't make these available for general use mainly due to the number of arguments needed for both input and sanitize
// Nothing stops you from generalizing these if you really wanted to
/datum/gear_tweak/custom_var/proc/InputNum(mob/user, message, title, default)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)
	var/num = input(user, message, title, default) as null|num
	if (isnum(min_input_value))
		num = max(min_input_value, num)
	if (isnum(max_input_value))
		num = min(max_input_value, num)
	return num

/datum/gear_tweak/custom_var/proc/InputText(mob/user, message, title, default, max_length)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)
	return sanitize(input(user, message, title, default) as null|text, max_input_length || MAX_MESSAGE_LEN, extra = FALSE)

/datum/gear_tweak/custom_var/proc/InputMessage(mob/user, message, title, default, max_length)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)
	return sanitize(input(user, message, title, default) as null|message, max_input_length || MAX_MESSAGE_LEN, extra = FALSE)

/datum/gear_tweak/custom_var/proc/InputColor(mob/user, message, title, default, max_length)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)
	return input(user, message, title, default) as null|color

/*
* Custom Name
*/

/datum/gear_tweak/custom_name
	var/list/valid_custom_names

/datum/gear_tweak/custom_name/New(list/valid_custom_names)
	src.valid_custom_names = valid_custom_names
	..()

/datum/gear_tweak/custom_name/get_contents(metadata)
	return "Name: [metadata]"

/datum/gear_tweak/custom_name/get_metadata(user, metadata, title)
	if(valid_custom_names)
		return input(user, "Choose an item name.", "Character Preference", metadata) as null|anything in valid_custom_names
	metadata = html_decode(metadata)
	return sanitize(input(user, "Choose the item's name. Leave it blank to use the default name.", "Item Name", metadata) as text|null, MAX_LNAME_LEN, extra = FALSE)

/datum/gear_tweak/custom_name/tweak_item(user, obj/item/I, metadata)
	if(!metadata)
		return
	var/lower = lowertext(metadata)
	if (!text_starts_with(lower, "a ") && !text_starts_with(lower, "an ") && !text_starts_with(lower, "the "))
		metadata = "\improper[metadata]"
	I.SetName(metadata)

/*
Custom Description
*/

/datum/gear_tweak/custom_desc
	var/list/valid_custom_desc

/datum/gear_tweak/custom_desc/New(list/valid_custom_desc)
	src.valid_custom_desc = valid_custom_desc
	..()

/datum/gear_tweak/custom_desc/get_contents(metadata)
	return "Description: [metadata]"

/datum/gear_tweak/custom_desc/get_metadata(user, metadata, title)
	if(valid_custom_desc)
		return input(user, "Choose an item description.", "Character Preference", metadata) as null|anything in valid_custom_desc
	metadata = html_decode(metadata)
	return sanitize(input(user, "Choose the item's description. Leave it blank to use the default description.", "Item Description", metadata) as message|null, MAX_DESC_LEN, extra = FALSE)

/datum/gear_tweak/custom_desc/tweak_item(user, obj/item/I, metadata)
	if(!metadata)
		return
	I.desc = metadata

/*
* Tablet Stuff
*/

/datum/gear_tweak/tablet
	var/list/ValidProcessors = list(/obj/item/stock_parts/computer/processor_unit/small)
	var/list/ValidBatteries = list(/obj/item/stock_parts/computer/battery_module/nano, /obj/item/stock_parts/computer/battery_module/micro, /obj/item/stock_parts/computer/battery_module)
	var/list/ValidHardDrives = list(/obj/item/stock_parts/computer/hard_drive/micro, /obj/item/stock_parts/computer/hard_drive/small, /obj/item/stock_parts/computer/hard_drive)
	var/list/ValidNetworkCards = list(/obj/item/stock_parts/computer/network_card, /obj/item/stock_parts/computer/network_card/advanced)
	var/list/ValidNanoPrinters = list(null, /obj/item/stock_parts/computer/nano_printer)
	var/list/ValidCardSlots = list(null, /obj/item/stock_parts/computer/card_slot)
	var/list/ValidTeslaLinks = list(null, /obj/item/stock_parts/computer/tesla_link)

/datum/gear_tweak/tablet/get_contents(list/metadata)
	var/list/names = list()
	var/obj/O = null
	if (length(metadata) != 7)
		return
	O = ValidProcessors[metadata[1]]
	if(O)
		names += initial(O.name)
	O = ValidBatteries[metadata[2]]
	if(O)
		names += initial(O.name)
	O = ValidHardDrives[metadata[3]]
	if(O)
		names += initial(O.name)
	O = ValidNetworkCards[metadata[4]]
	if(O)
		names += initial(O.name)
	O = ValidNanoPrinters[metadata[5]]
	if(O)
		names += initial(O.name)
	O = ValidCardSlots[metadata[6]]
	if(O)
		names += initial(O.name)
	O = ValidTeslaLinks[metadata[7]]
	if(O)
		names += initial(O.name)
	return english_list(names, and_text = ", ")

/datum/gear_tweak/tablet/get_metadata(mob/user, metadata, title)
	. = list()
	if(!istype(user))
		return

	var/list/names = list()
	var/counter = 1
	for(var/i in ValidProcessors)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	var/entry = input(user, "Choose a processor.", CHARACTER_PREFERENCE_INPUT_TITLE) in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidBatteries)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = input(user, "Choose a battery.", CHARACTER_PREFERENCE_INPUT_TITLE) in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidHardDrives)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = input(user, "Choose a hard drive.", CHARACTER_PREFERENCE_INPUT_TITLE) in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNetworkCards)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = input(user, "Choose a network card.", CHARACTER_PREFERENCE_INPUT_TITLE) in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNanoPrinters)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = input(user, "Choose a nanoprinter.", CHARACTER_PREFERENCE_INPUT_TITLE) in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidCardSlots)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = input(user, "Choose a card slot.", CHARACTER_PREFERENCE_INPUT_TITLE) in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidTeslaLinks)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	if (!user || !user.client)
		return
	entry = input(user, "Choose a tesla link.", CHARACTER_PREFERENCE_INPUT_TITLE) in names
	. += names[entry]

/datum/gear_tweak/tablet/get_default()
	. = list()
	for(var/i in 1 to TWEAKABLE_COMPUTER_PART_SLOTS)
		. += 1

/datum/gear_tweak/tablet/tweak_item(user, obj/item/modular_computer/tablet/I, list/metadata)
	if(length(metadata) < TWEAKABLE_COMPUTER_PART_SLOTS)
		return
	if(ValidProcessors[metadata[1]])
		var/t = ValidProcessors[metadata[1]]
		I.processor_unit = new t(I)
	if(ValidBatteries[metadata[2]])
		var/t = ValidBatteries[metadata[2]]
		I.battery_module = new t(I)
		I.battery_module.charge_to_full()
	if(ValidHardDrives[metadata[3]])
		var/t = ValidHardDrives[metadata[3]]
		I.hard_drive = new t(I)
	if(ValidNetworkCards[metadata[4]])
		var/t = ValidNetworkCards[metadata[4]]
		I.network_card = new t(I)
	if(ValidNanoPrinters[metadata[5]])
		var/t = ValidNanoPrinters[metadata[5]]
		I.nano_printer = new t(I)
	if(ValidCardSlots[metadata[6]])
		var/t = ValidCardSlots[metadata[6]]
		I.card_slot = new t(I)
	if(ValidTeslaLinks[metadata[7]])
		var/t = ValidTeslaLinks[metadata[7]]
		I.tesla_link = new t(I)
