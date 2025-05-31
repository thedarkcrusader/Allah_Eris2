

/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/roguetown/items/books.dmi'
	icon_state = "basic_book_0"
	desc = ""
	dropshrink = 0.6
	drop_sound = 'sound/foley/dropsound/book_drop.ogg'
	force = 5
	throw_speed = 1
	throw_range = 5
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/blank.ogg'
	pickup_sound =  'sound/blank.ogg'
	firefuel = 2 MINUTES

	grid_width = 32
	grid_height = 64

	var/random_cover
	var/category = null

	var/base_icon_state = "basic_book"
	var/open = FALSE
	var/dat				//Actual page content
	var/due_date = 0	//Game time in 1/10th seconds
	var/author			//Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = TRUE		//0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title			//The real name of the book.
	var/window_size = null // Specific window size for the book, i.e: "1920x1080", Size x Width

	var/list/pages = list()
	var/bookfile
	var/curpage = 1
	var/textper = 100
	var/our_font = "Rosemary Roman"
	var/override_find_book = FALSE

/obj/item/book/examine(mob/user)
	. = ..()
	. += "<a href='byond://?src=[REF(src)];read=1'>Read</a>"

/obj/item/book/getonmobprop(tag)
	. = ..()
	if(tag)
		if(open)
			switch(tag)
				if("gen")
					return list("shrink" = 0.4,
	"sx" = -2,
	"sy" = -3,
	"nx" = 10,
	"ny" = -2,
	"wx" = 1,
	"wy" = -3,
	"ex" = 5,
	"ey" = -3,
	"northabove" = 0,
	"southabove" = 1,
	"eastabove" = 1,
	"westabove" = 0,
	"nturn" = 0,
	"sturn" = 0,
	"wturn" = 0,
	"eturn" = 0,
	"nflip" = 0,
	"sflip" = 0,
	"wflip" = 0,
	"eflip" = 0)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
		else
			switch(tag)
				if("gen")
					return list("shrink" = 0.4,
	"sx" = -2,
	"sy" = -3,
	"nx" = 10,
	"ny" = -2,
	"wx" = 1,
	"wy" = -3,
	"ex" = 5,
	"ey" = -3,
	"northabove" = 0,
	"southabove" = 1,
	"eastabove" = 1,
	"westabove" = 0,
	"nturn" = 0,
	"sturn" = 0,
	"wturn" = 0,
	"eturn" = 0,
	"nflip" = 0,
	"sflip" = 0,
	"wflip" = 0,
	"eflip" = 0)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

// ...... Book Cover Randomizer Code  (gives the book a radom cover when random_cover = TRUE)
/obj/item/book/Initialize()
	. = ..()
	if(random_cover)
		base_icon_state = "book[rand(1,8)]"
		icon_state = "[base_icon_state]_0"

/obj/item/book/attack_self(mob/user)
	if(!open)
		attack_right(user)
		return
	if(!user.can_read(src))
		return
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	read(user)
	user.update_inv_hands()

/obj/item/book/rmb_self(mob/user)
	attack_right(user)
	return

/obj/item/book/proc/read(mob/user)
	if(!open)
		to_chat(user, "<span class='info'>Open me first.</span>")
		return FALSE
	user << browse_rsc('html/book.png')
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		user.adjust_experience(/datum/skill/misc/reading, 4, FALSE)
		return
	if(in_range(user, src) || isobserver(user))
		if(!pages.len)
			if(!override_find_book)
				pages = SSlibrarian.get_book(bookfile)
		if(!pages.len)
			to_chat(user, "<span class='warning'>This book is completely blank.</span>")
		if(curpage > pages.len)
			curpage = 1
//		var/curdat = pages[curpage]
		var/dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
					<html><head><style type=\"text/css\">
					body { background-image:url('book.png');background-repeat: repeat; }</style></head><body scroll=yes>"}
		for(var/A in pages)
			dat += A
			dat += "<br>"
		dat += "<a href='byond://?src=[REF(src)];close=1' style='position:absolute;right:50px'>Close</a>"
		dat += "</body></html>"
		user << browse(dat, "window=reading;size=1000x700;can_close=1;can_minimize=0;can_maximize=0;can_resize=1;titlebar=0;border=0")
		onclose(user, "reading", src)
	else
		return "<span class='warning'>You're too far away to read it.</span>"


/obj/item/book/Topic(href, href_list)
	..()

	if(!usr)
		return

	if(href_list["close"])
		var/mob/user = usr
		if(user?.client && user.hud_used)
			if(user.hud_used.reads)
				user.hud_used.reads.destroy_read()
			user << browse(null, "window=reading")

	var/literate = usr.is_literate()
	if(!usr.canUseTopic(src, BE_CLOSE, literate))
		return

	if(href_list["read"])
		read(usr)

	if(href_list["turnpage"])
		if(pages.len >= curpage+2)
			curpage += 2
		else
			curpage = 1
		playsound(loc, 'sound/items/book_page.ogg', 100, TRUE, -1)
		read(usr)

/obj/item/book/attackby(obj/item/I, mob/user, params)
	return

/obj/item/book/attack_right(mob/user)
	if(!open)
		slot_flags &= ~ITEM_SLOT_HIP
		open = TRUE
		playsound(loc, 'sound/items/book_open.ogg', 100, FALSE, -1)
	else
		slot_flags |= ITEM_SLOT_HIP
		open = FALSE
		playsound(loc, 'sound/items/book_close.ogg', 100, FALSE, -1)
	curpage = 1
	update_icon()
	user.update_inv_hands()

/obj/item/book/update_icon()
	icon_state = "[base_icon_state]_[open]"

/obj/item/book/secret/ledger
	name = "catatoma"
	icon_state = "ledger_0"
	base_icon_state = "ledger"
	title = "Catatoma"
	dat = "To create a shipping order, use a scroll on me."
	var/fence = FALSE
	var/mob/current_reader
	var/current_category = "All"
	var/search_query = ""
	var/list/categories = list("All")
	var/list/types = list()
	var/list/cart = list() // Track items in cart
	// Removed selected_item variable as we're not using it anymore

/obj/item/book/secret/ledger/Initialize()
	. = ..()
	// Populate categories and types from SSmerchant.supply_cats and SSmerchant.supply_packs
	categories += SSmerchant.supply_cats
	for(var/pack in SSmerchant.supply_packs)
		var/datum/supply_pack/PA = SSmerchant.supply_packs[pack]
		if(!PA.contraband) // You can add a var to control whether to show contraband
			types += PA

/obj/item/book/secret/ledger/attack_self(mob/user)
	. = ..()
	current_reader = user
	current_reader << browse(generate_html(user),"window=ledger;size=800x810")

/obj/item/book/secret/ledger/proc/generate_html(mob/user)
	if(!length(types))
		for(var/pack in SSmerchant.supply_packs)
			var/datum/supply_pack/PA = SSmerchant.supply_packs[pack]
			if(!PA.contraband) // You can add a var to control whether to show contraband
				types += PA

	var/client/client = user
	if(!istype(client))
		client = user.client
	SSassets.transport.send_assets(client, list("try4_border.png", "try4.png", "slop_menustyle2.css"))
	user << browse_rsc('html/book.png')

	var/html = {"
		<!DOCTYPE html>
		<html lang="en">
		<meta charset='UTF-8'>
		<meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1'/>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>

		<style>
			@import url('https://fonts.googleapis.com/css2?family=Charm:wght@700&display=swap');
			body {
				font-family: "Charm", cursive;
				font-size: 1.2em;
				text-align: center;
				margin: 20px;
				color: #3e2723;
				background-color: rgb(31, 20, 24);
				background:
					url('[SSassets.transport.get_asset_url("try4_border.png")]'),
					url('book.png');
				background-repeat: no-repeat;
				background-attachment: fixed;
				background-size: 100% 100%;
			}
			h1 {
				text-align: center;
				font-size: 2em;
				border-bottom: 2px solid #3e2723;
				padding-bottom: 10px;
				margin-bottom: 20px;
			}
			.book-content {
				display: flex;
				height: 85%;
			}
			.sidebar {
				width: 30%;
				padding: 10px;
				border-right: 2px solid #3e2723;
				overflow-y: auto;
				max-height: 600px;
			}
			.main-content {
				width: 70%;
				padding: 10px;
				overflow-y: auto;
				max-height: 600px;
				text-align: left;
			}
			.categories {
				margin-bottom: 15px;
			}
			.category-btn {
				margin: 2px;
				padding: 5px;
				background-color: #d2b48c;
				border: 1px solid #3e2723;
				border-radius: 5px;
				cursor: pointer;
				font-family: "Charm", cursive;
			}
			.category-btn.active {
				background-color: #8b4513;
				color: white;
			}
			.search-box {
				width: 90%;
				padding: 5px;
				margin-bottom: 15px;
				border: 1px solid #3e2723;
				border-radius: 5px;
				font-family: "Charm", cursive;
			}
			.recipe-list {
				text-align: left;
			}
			.item-link {
				display: block;
				padding: 5px;
				color: #3e2723;
				text-decoration: none;
				border-bottom: 1px dotted #d2b48c;
			}
			.item-link:hover {
				background-color: rgba(210, 180, 140, 0.3);
			}
			.add-to-cart-btn {
				float: right;
				padding: 2px 5px;
				background-color: #8b4513;
				color: white;
				border: 1px solid #3e2723;
				border-radius: 3px;
				cursor: pointer;
				font-size: 0.8em;
				margin-left: 5px;
			}
			.item-content {
				padding: 10px;
			}
			.back-btn {
				margin-top: 10px;
				padding: 5px 10px;
				background-color: #d2b48c;
				border: 1px solid #3e2723;
				border-radius: 5px;
				cursor: pointer;
				font-family: "Charm", cursive;
			}
			.icon {
				width: 96px;
				height: 96px;
				vertical-align: middle;
				margin-right: 10px;
			}
			.result-icon {
				text-align: center;
				margin: 15px 0;
			}
			.order-button {
				display: inline-block;
				margin: 10px 0;
				padding: 8px 15px;
				background-color: #8b4513;
				color: white;
				border: 1px solid #3e2723;
				border-radius: 5px;
				cursor: pointer;
				font-family: "Charm", cursive;
				text-decoration: none;
			}
			.quantity-input {
				width: 60px;
				padding: 5px;
				text-align: center;
				font-family: "Charm", cursive;
			}
			.no-matches {
				font-style: italic;
				color: #8b4513;
				padding: 10px;
				text-align: center;
				display: none;
			}
			.cart-content {
				margin-top: 20px;
				border-top: 2px solid #3e2723;
				padding-top: 15px;
			}
			.cart-item {
				justify-content: space-between;
				padding: 5px 0;
				border-bottom: 1px dotted #d2b48c;
			}
			.remove-item {
				color: #8b4513;
				cursor: pointer;
				font-weight: bold;
			}
			.checkout-button {
				display: block;
				width: 80%;
				margin: 20px auto;
				padding: 10px;
				background-color: #8b4513;
				color: white;
				border: 1px solid #3e2723;
				border-radius: 5px;
				cursor: pointer;
				font-family: "Charm", cursive;
				text-decoration: none;
				font-size: 1.2em;
			}
			table {
				margin: 10px auto;
				border-collapse: collapse;
				width: 100%;
			}
			table, th, td {
				border: 1px solid #3e2723;
			}
			th, td {
				padding: 8px;
				text-align: left;
			}
			th {
				background-color: rgba(210, 180, 140, 0.3);
			}
			.hidden {
				display: none;
			}
			.item-details {
				margin: 15px 0;
				padding: 15px;
				border: 1px solid #3e2723;
				border-radius: 5px;
				background-color: rgba(210, 180, 140, 0.1);
			}
			.item-description {
				margin: 15px 0;
				font-style: italic;
			}
			.add-to-cart {
				display: flex;
				align-items: center;
				justify-content: center;
				margin: 15px 0;
			}
			.add-btn {
				padding: 8px 15px;
				background-color: #8b4513;
				color: white;
				border: 1px solid #3e2723;
				border-radius: 5px;
				cursor: pointer;
				font-family: "Charm", cursive;
				margin-left: 10px;
			}
			.order-section {
				width: 100%;
			}
			.cart-table {
				width: 100%;
			}
			.cart-actions {
				display: flex;
				justify-content: space-between;
				align-items: center;
			}
			.cart-quantity {
				width: 60px;
				padding: 5px;
				text-align: center;
			}
		</style>

		<body>
			<h1>Catacoma</h1>

			<div class="book-content">
				<div class="sidebar">
					<!-- Search box -->
					<input type="text" class="search-box" id="searchInput"
						placeholder="Search items..." value="[search_query]">

					<!-- Categories -->
					<div class="categories">
	"}

	for(var/category in categories)
		var/active_class = category == current_category ? "active" : ""
		html += "<button class='category-btn [active_class]' onclick=\"location.href='byond://?src=\ref[src];action=set_category&category=[url_encode(category)]'\">[category]</button>"

	html += {"
					</div>

					<!-- Item List -->
					<div class="recipe-list" id="itemList">
	"}

	for(var/datum/supply_pack/pack in types)
		var/should_show = TRUE
		if(pack.contraband && !fence)
			should_show = FALSE
		if(current_category != "All")
			if(pack.group != current_category)
				should_show = FALSE

		var/display_style = should_show ? "" : "display: none;"

		html += "<a class='item-link [display_style]' href='byond://?src=\ref[src];action=add_to_cart&item=\ref[pack]&quantity=1' style='[display_style]'>[pack.name] ([pack.cost] mammons)</a>"

	html += {"
						<div id="noMatchesMsg" class="no-matches">No matching items found.</div>
					</div>
				</div>

				<div class="main-content" id="mainContent">
					<div class='item-content'>
						<div class="order-section">
	"}

	// Display cart items
	if(length(cart) > 0)
		html += "<table class='cart-table'><tr><th>Item</th><th>Quantity</th><th>Cost</th><th>Actions</th></tr>"
		var/total_cost = 0

		for(var/datum/supply_pack/pack in cart)
			var/item_quantity = cart[pack]
			var/item_cost = pack.cost * item_quantity
			total_cost += item_cost

			html += "<tr class='cart-item'>"
			html += "<td>[pack.name]</td>"
			html += "<td>"
			html += "<form class='cart-actions' action='byond://?src=\ref[src];action=update_cart&item=\ref[pack]' method='get'>"
			html += "<input type='hidden' name='src' value='\ref[src]'>"
			html += "<input type='hidden' name='action' value='update_cart'>"
			html += "<input type='hidden' name='item' value='\ref[pack]'>"
			html += "<input type='number' name='quantity' value='[item_quantity]' min='1' max='100' class='cart-quantity'>"
			html += "<input type='submit' value='Update' class='add-btn' style='padding: 3px 8px; font-size: 0.8em;'>"
			html += "</form>"
			html += "</td>"
			html += "<td>[item_cost] mammons</td>"
			html += "<td><span class='remove-item' onclick=\"location.href='byond://?src=\ref[src];action=remove_from_cart&item=\ref[pack]'\">✖</span></td>"
			html += "</tr>"

		html += "<tr><td colspan='2'><strong>Total:</strong></td><td colspan='2'><strong>[total_cost] mammons</strong></td></tr>"
		html += "</table>"
		html += "<button class='checkout-button' onclick=\"location.href='byond://?src=\ref[src];action=checkout'\">Create Order Scroll</button>"

	else
		html += "<p>Your cart is empty. Click the 'Add' button next to items to add them to your order.</p>"

	html += {"
							</div>
						</div>
					</div>
				</div>
			</div>

			<script>
				// Live search functionality with debouncing
				let searchTimeout;
				document.getElementById('searchInput').addEventListener('keyup', function(e) {
					clearTimeout(searchTimeout);

					// Debounce the search to improve performance
					searchTimeout = setTimeout(function() {
						const query = document.getElementById('searchInput').value.toLowerCase();
						filterItems(query);
					}, 300);
				});

				function filterItems(query) {
					const itemLinks = document.querySelectorAll('.item-link');
					const currentCategory = "[current_category]";
					let anyVisible = false;

					itemLinks.forEach(function(link) {
						const itemName = link.textContent.toLowerCase();

						// Check if it matches the search query
						const matchesQuery = query === '' || itemName.includes(query);

						// If we have both a query and active category, respect both filters
						if (matchesQuery) {
							link.style.display = 'block';
							anyVisible = true;
						} else {
							link.style.display = 'none';
						}
					});

					// Show a message if no items match
					const noMatchesMsg = document.getElementById('noMatchesMsg');
					noMatchesMsg.style.display = anyVisible ? 'none' : 'block';

					// Remember the query
					window.location.replace(`byond://?src=\\ref[src];action=remember_query&query=${encodeURIComponent(query)}`);
				}

				// Initialize search based on any current query
				if ("[search_query]" !== "") {
					filterItems("[search_query]".toLowerCase());
				}
			</script>
		</body>
		</html>
	"}

	return html

/obj/item/book/secret/ledger/Topic(href, href_list)
	..()

	if(!current_reader)
		return

	if(!istype(current_reader) || current_reader.stat || !in_range(src, current_reader))
		return

	if(href_list["action"])
		switch(href_list["action"])
			if("set_category")
				current_category = url_decode(href_list["category"])
				search_query = "" // Reset search when changing category

			if("remember_query")
				search_query = url_decode(href_list["query"])

			if("add_to_cart")
				var/datum/supply_pack/item = locate(href_list["item"])
				var/quantity = text2num(href_list["quantity"])

				if(item && quantity > 0)
					if(cart[item])
						cart[item] += quantity
					else
						cart[item] = quantity

			if("update_cart")
				var/datum/supply_pack/item = locate(href_list["item"])
				var/quantity = text2num(href_list["quantity"])

				if(item && quantity > 0)
					cart[item] = quantity
				else if(quantity <= 0)
					cart.Remove(item)

			if("remove_from_cart")
				var/datum/supply_pack/item = locate(href_list["item"])
				if(item && cart[item])
					cart.Remove(item)

			if("checkout")
				create_order_scroll()
				return

	current_reader << browse(generate_html(current_reader), "window=ledger;size=900x810")

/obj/item/book/secret/ledger/proc/create_order_scroll()
	if(!current_reader || !length(cart))
		return

	var/obj/item/paper/scroll/cargo/C = new(current_reader.loc)

	for(var/datum/supply_pack/pack in cart)
		C.orders[pack] += cart[pack]

	C.rebuild_info()

	// Clear cart after creating order
	cart.Cut()
	current_reader.put_in_hands(C)
	to_chat(current_reader, "<span class='notice'>Your order has been written on a scroll.</span>")
	current_reader << browse(generate_html(current_reader), "window=ledger;size=800x810")

/obj/item/book/secret/ledger/fence
	name = "Smuggler's Manifest"
	title = " Smuggler's Manifest"
	fence = TRUE

/obj/item/book/bibble
	name = "The Book"
	icon_state = "bibble_0"
	base_icon_state = "bibble"
	title = "bible"
	dat = "gott.json"
	force = 2
	force_wielded = 4
	throwforce = 1
	possible_item_intents = list(/datum/intent/use, /datum/intent/mace/strike/wood)

/obj/item/book/bibble/read(mob/user)
	if(!open)
		to_chat(user, "<span class='info'>Open me first.</span>")
		return FALSE
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		user.adjust_experience(/datum/skill/misc/reading, 4, FALSE)
		return
	if(in_range(user, src) || isobserver(user))
		user.changeNext_move(CLICK_CD_MELEE)
		var/m
		var/list/verses = world.file2list("strings/bibble.txt")
		m = pick(verses)
		if(m)
			user.say(m)

/obj/item/book/bibble/attack(mob/living/M, mob/user)
	if(is_priest_job(user.mind?.assigned_role))
		if(!user.can_read(src))
			return
		M.apply_status_effect(/datum/status_effect/buff/blessed)
		user.visible_message("<span class='notice'>[user] blesses [M].</span>")
		playsound(user, 'sound/magic/bless.ogg', 100, FALSE)
		return

/datum/status_effect/buff/blessed
	id = "blessed"
	alert_type = /atom/movable/screen/alert/status_effect/buff/blessed
	effectedstats = list(STATKEY_LCK = 1)
	duration = 20 MINUTES

/atom/movable/screen/alert/status_effect/buff/blessed
	name = "Blessed"
	desc = ""
	icon_state = "buff"

/datum/status_effect/buff/blessed/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/blessed)

/datum/status_effect/buff/blessed/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/blessed)

/obj/item/book/law
	name = "Tome of Justice"
	desc = ""
	icon_state ="lawtome_0"
	base_icon_state = "lawtome"
	bookfile = "law.json"

/obj/item/book/knowledge1
	name = "Book of Knowledge"
	desc = ""
	icon_state ="book5_0"
	base_icon_state = "book5"
	bookfile = "knowledge.json"

/obj/item/book/secret/xylix
	name = "Book of Gold"
	desc = "{<font color='red'><blink>An ominous book with untold powers.</blink></font>}"
	icon_state ="xylix_0"
	base_icon_state = "xylix"
	icon_state ="spellbookmimic_0"
	base_icon_state = "pellbookmimic"
	bookfile = "xylix.json"

/obj/item/book/xylix/attack_self(mob/user)
	user.update_inv_hands()
	to_chat(user, "<span class='notice'>You feel laughter echo in your head.</span>")

//player made books
/obj/item/book/tales1
	name = "Assorted Tales From Yester Yils"
	desc = "By Alamere J Wevensworth"
	icon_state ="book_0"
	base_icon_state = "book"
	bookfile = "tales1.json"

/obj/item/book/festus
	name = "Book of Festus"
	desc = "Unknown Author"
	icon_state ="book2_0"
	base_icon_state = "book2"
	bookfile = "tales2.json"

/obj/item/book/tales3
	name = "Myths & Legends of Rockhill & Beyond Volume I"
	desc = "Arbalius The Younger"
	icon_state ="book3_0"
	base_icon_state = "book3"
	bookfile = "tales3.json"

/obj/item/book/bookofpriests
	name = "Holy Book of Saphria"
	desc = ""
	icon_state ="knowledge_0"
	base_icon_state = "knowledge"
	bookfile = "holyguide.json"

/obj/item/book/robber
	name = "Reading for Robbers"
	desc = "By Flavius of Dendor"
	icon_state ="basic_book_0"
	base_icon_state = "basic_book"
	bookfile = "tales4.json"

/obj/item/book/cardgame
	name = "Graystone's Torment Basic Rules"
	desc = "By Johnus of Doe"
	icon_state ="basic_book_0"
	base_icon_state = "basic_book"
	bookfile = "tales5.json"

/obj/item/book/blackmountain
	name = "Zabrekalrek, The Black Mountain Saga: Part One"
	desc = "Written by Gorrek Tale-Writer, translated by Hargrid Men-Speaker."
	icon_state ="book6_0"
	base_icon_state = "book6"
	bookfile = "tales6.json"

/obj/item/book/beardling
	name = "Rock and Stone - ABC & Tales for Beardlings"
	desc = "Distributed by the Dwarven Federation"
	icon_state ="book8_0"
	base_icon_state = "book8"
	bookfile = "tales7.json"

/obj/item/book/abyssor
	name = "A Tale of Those Who Live At Sea"
	desc = "By Bellum Aegir"
	icon_state ="book2_0"
	base_icon_state = "book2"
	bookfile = "tales8.json"

/obj/item/book/necra
	name = "Burial Rites for Necra"
	desc = "By Hunlaf, Gravedigger. Revised by Lenore, Priest of Necra."
	icon_state ="book6_0"
	base_icon_state = "book6"
	bookfile = "tales9.json"

/obj/item/book/noc
	name = "Dreamseeker"
	desc = "By Hunlaf, Gravedigger. Revised by Lenore, Priest of Necra."
	icon_state ="book6_0"
	base_icon_state = "book6"
	bookfile = "tales10.json"

/obj/item/book/fishing
	name = "Fontaine's Advanced Guide to Fishery"
	desc = "By Ford Fontaine"
	icon_state ="book2_0"
	base_icon_state = "book2"
	bookfile = "tales11.json"

/obj/item/book/sword
	name = "The Six Follies: How To Survive by the Sword"
	desc = "By Theodore Spillguts"
	icon_state ="book5_0"
	base_icon_state = "book5"
	bookfile = "tales12.json"

/obj/item/book/arcyne
	name = "Latent Magicks, where does Arcyne Power come from?"
	desc = "By Kildren Birchwood, scholar of Magicks"
	icon_state ="book4_0"
	base_icon_state = "book4"
	bookfile = "tales13.json"

/obj/item/book/nitebeast
	name = "Legend of the Nitebeast"
	desc = "By Paquetto the Scholar"
	icon_state ="book8_0"
	base_icon_state = "book8"
	bookfile = "tales14.json"

/obj/item/book/mysticalfog
	name = "Studie of the Etheral Foge phenomenon"
	desc = "By Roubert the Elder"
	icon_state ="book7_0"
	base_icon_state = "book8"
	bookfile = "tales15.json"

/obj/item/book/playerbook
	var/player_book_text = "moisture in the air or water leaks have rendered the carefully written caligraphy of this book unreadable"
	var/player_book_title = "unknown title"
	var/player_book_author = "unknown author"
	var/player_book_icon = "basic_book"
	var/player_book_author_ckey = "unknown"
	var/is_in_round_player_generated
	var/list/player_book_titles
	var/list/player_book_content
	var/list/book_icons = list(
	"Sickly green with embossed bronze" = "book8",
	"White with embossed obsidian" = "book7",
	"Black with embossed quartz" = "book6",
	"Blue with embossed ruby" = "book5",
	"Green with embossed amethyst" = "book4",
	"Purple with embossed emerald" = "book3",
	"Red with embossed sapphire" = "book2",
	"Brown with embossed gold" = "book1",
	"Brown without embossed material" = "basic_book")
	name = "unknown title"
	desc = "by an unknown author"
	icon_state = "basic_book_0"
	base_icon_state = "basic_book"
	override_find_book = TRUE

/obj/item/book/playerbook/proc/get_player_input(mob/living/in_round_player_mob, text)
	player_book_author_ckey = in_round_player_mob.ckey
	player_book_title = dd_limittext(capitalize(sanitize_hear_message(input(in_round_player_mob, "What title do you want to give the book? (max 42 characters)", "Title", "Unknown"))), MAX_NAME_LEN)
	player_book_author = "[dd_limittext(sanitize_hear_message(input(in_round_player_mob, "Do you want to preface your author name with an author title? (max 42 characters)", "Author Title", "")), MAX_NAME_LEN)] [in_round_player_mob.real_name]"
	player_book_icon = book_icons[input(in_round_player_mob, "Choose a book style", "Book Style") as anything in book_icons]
	player_book_text = text
	message_admins("[player_book_author_ckey]([in_round_player_mob.real_name]) has generated the player book: [player_book_title]")
	update_book_data()

/obj/item/book/playerbook/proc/update_book_data()
	name = "[player_book_title]"
	desc = "By [player_book_author]"
	icon_state = "[player_book_icon]_0"
	base_icon_state = "[player_book_icon]"
	pages = list("<b3><h3>Title: [player_book_title]<br>Author: [player_book_author]</b><h3>[player_book_text]")

/obj/item/book/playerbook/Initialize(mapload, in_round_player_generated, mob/living/in_round_player_mob, text, title)
	. = ..()
	is_in_round_player_generated = in_round_player_generated
	if(is_in_round_player_generated)
		INVOKE_ASYNC(src, PROC_REF(update_book_data), in_round_player_mob, text)
	else
		player_book_titles = SSlibrarian.pull_player_book_titles()
		if(title)
			player_book_content = SSlibrarian.file2playerbook(title)
		else
			player_book_content = SSlibrarian.file2playerbook(pick(player_book_titles))
		player_book_title = player_book_content["book_title"]
		player_book_author = player_book_content["author"]
		player_book_author_ckey = player_book_content["author_ckey"]
		player_book_icon = player_book_content["icon"]
		player_book_text = player_book_content["text"]
		update_book_data()

/obj/item/manuscript
	name = "manuscript"
	desc = "A written piece with aspirations of becoming a book."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "manuscript"
	dir = 2 //! dir is used to decide how many pages are displayed in the icon
	resistance_flags = FLAMMABLE
	var/number_of_pages = 2
	var/compiled_pages = null
	var/list/obj/item/paper/pages = new/list(2) //very intentional constructor

	var/author = "anonymous"
	var/content = ""
	var/category = "Unspecified"
	var/ckey = ""
	var/newicon = "basic_book_0"
	var/written = FALSE
	var/select_icon = "basic_book"
	var/list/book_icons = list(
		"Simple green" = "basic_book",
		"Simple black" = "book",
		"Simple red" = "book2",
		"Simple blue" = "book3",
		"Simple dark yellow" = "book4",
		"Brown with dark corners" = "book5",
		"Heavy purple with dark corners" = "book6",
		"Light purple with gold leaf" = "book7",
		"Light blue with gold leaf" = "book8",
		"Grey with gold leaf" = "knowledge")

/obj/item/manuscript/Initialize(mapload, list/obj/item/paper/preset_pages)
	. = ..()

	if(mapload || !preset_pages)
		for(var/i in 1 to length(pages))
			pages[i] = new /obj/item/paper(src)
	else
		for(var/i in 1 to length(preset_pages))
			pages[i] = preset_pages[i]
			preset_pages[i].forceMove(src) //lol

	update_pages()

/// Called when our pages have been updated.
/obj/item/manuscript/proc/update_pages()
	number_of_pages = length(pages)
	//name = "[number_of_pages] page manuscript"
	desc = "A [number_of_pages]-page written piece, with aspirations of becoming a book."
	update_icon()

	compiled_pages = null
	for(var/obj/item/paper/page as anything in pages)
		compiled_pages += "<p>[page.info]</p>\n"

/obj/item/manuscript/attackby(obj/item/I, mob/living/user)
	// why is a book crafting kit using the craft system, but crafting a book isn't?
	// Well, *for some reason*, the crafting system is made in such a way
	// as to make reworking it to allow you to put reqs vars in the crafted item near *impossible.*
	if(istype(I, /obj/item/book_crafting_kit))
		var/obj/item/book/playerbook/PB = new /obj/item/book/playerbook(get_turf(I.loc), TRUE, user, compiled_pages)
		qdel(I)
		if(user.Adjacent(PB))
			PB.add_fingerprint(user)
			user.put_in_hands(PB)
		return qdel(src)

	if((I.type == /obj/item/paper) || (I.type == /obj/item/paper/scroll))
		var/obj/item/paper/inserted_paper = I
		if(length(pages) == 8)
			to_chat(user, span_warning("I can not find a place to put [inserted_paper] into [src]..."))
			return

		inserted_paper.forceMove(src)
		pages += inserted_paper
		to_chat(user, span_notice("I put [inserted_paper] into [src]."))
		update_pages()
		updateUsrDialog()

	return ..()

/obj/item/manuscript/examine(mob/user)
	. = ..()
	. += span_info("<a href='byond://?src=[REF(src)];read=1'>Read</a>")

/obj/item/manuscript/Topic(href, href_list)
	..()

	if(!usr)
		return

	if(href_list["close"])
		var/mob/user = usr
		if(user?.client && user.hud_used)
			if(user.hud_used.reads)
				user.hud_used.reads.destroy_read()
			user << browse(null, "window=reading")

	var/literate = usr.is_literate()
	if(!usr.canUseTopic(src, BE_CLOSE, literate))
		return

	if(href_list["read"])
		read(usr)

/obj/item/manuscript/attack_self(mob/user)
	read(user)

/obj/item/manuscript/proc/read(mob/user)
	user << browse_rsc('html/book.png')
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		to_chat(span_warning("I study [src], but this verba still eludes me..."))
		user.adjust_experience(/datum/skill/misc/reading, 4, FALSE) //?
		return
	if(!in_range(user, src) && !isobserver(user))
		to_chat(user, span_warning("I am too far away to read [src]."))
		return

	var/dat = {"
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
		<head>
			<style type="text/css">
				body {
					background-image:url('book.png');
					background-repeat: repeat;
				}
			</style>
		</head>
		<body scroll=yes>
			[compiled_pages]
		</body>
	</html>
	"}
	user << browse(dat, "window=reading;size=1000x700;can_close=1;can_minimize=0;can_maximize=0;can_resize=0;")
	onclose(user, "reading", src)


/obj/item/manuscript/attack_right(mob/user)
	. = ..()
	var/obj/item/P = user.get_active_held_item()
	if(istype(P, /obj/item/natural/feather))
		// Prompt user to populate manuscript fields
		var/newtitle = dd_limittext(sanitize_hear_message(input(user, "Enter the title of the manuscript:") as text|null), MAX_CHARTER_LEN)
		var/newauthor = dd_limittext(sanitize_hear_message(input(user, "Enter the author's name:") as text|null), MAX_CHARTER_LEN)
		var/newcategory = input(user, "Select the category of the manuscript:") in list("Apocrypha & Grimoires", "Myths & Tales", "Legends & Accounts", "Thesis", "Eoratica")
		var/newicon = book_icons[input(user, "Choose a book style", "Book Style") as anything in book_icons]

		if (newtitle && newauthor && newcategory)
			name = newtitle
			author = newauthor
			category = newcategory
			ckey = user.ckey
			select_icon = newicon
			icon_state = "paperwrite"
			to_chat(user, "<span class='notice'>You have successfully authored and titled the manuscript.</span>")
			var/complete = input(user, "Is the manuscript finished?") in list("Yes", "No")
			if(complete == "Yes" && compiled_pages)
				written = TRUE
		else
			to_chat(user, "<span class='notice'>You must fill out all fields to complete the manuscript.</span>")
		return
	else if(istype(P, /obj/item/natural/feather) && written)
		to_chat(user, "<span class='notice'>The manuscript has already been authored and titled.</span>")
		return
	return ..()

/obj/item/manuscript/update_icon()
	. = ..()
	switch(length(pages))
		if(2)
			dir = SOUTH
		if(3)
			dir = NORTH
		if(4)
			dir = EAST
		if(5)
			dir = WEST
		if(6)
			dir = SOUTHEAST
		if(7)
			dir = SOUTHWEST
		else //8
			dir = NORTHWEST

/obj/item/manuscript/fire_act(added, maxstacks)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		add_overlay("paper_onfire_overlay")

/obj/item/manuscript/attack_hand(mob/living/user)
	if(isliving(user) && user.is_holding(src))
		var/obj/item/paper/pulled_page = pop(pages)
		user.put_in_inactive_hand(src) //move this to the side
		user.put_in_active_hand(pulled_page)

		if(number_of_pages > 2)
			to_chat(user, span_notice("I pull out \a [pulled_page] from [src]."))
			update_pages()
		else
			to_chat(user, span_notice("I pull apart the final entries of [src]."))
			var/obj/item/paper/last_page = pop(pages)
			user.temporarilyRemoveItemFromInventory(src, TRUE)
			user.put_in_hands(last_page)
			qdel(src)
			return

		return

	. = ..()

/obj/item/book_crafting_kit
	name = "book crafting kit"
	desc = "Apply on a written manuscript to create a book"
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "book_crafting_kit"




// ...... Books made by the Stonekeep community within #lore channel, approved & pushed by Guayo (current staff incharge of adding ingame books)

/* ______Example of layout of added in book

/obj/item/book/book_name_here
	name = "Title of your book here"
	desc = "Who wrote it or maybe some flavor here"
	bookfile = "filenamehere.json"
	random_cover = TRUE

____________End of Example*/

/obj/item/book/magicaltheory
	name = "Arcane Foundations - A historie of Magicks"
	desc = "Written by the rector of the Valerian College of Magick"
	icon_state ="knowledge_0"
	base_icon_state = "knowledge"
	bookfile = "MagicalTheory.json"

/obj/item/book/vownecrapage
	name = "Necra's Vow of Silence"
	desc = "A faded page, with seemingly no author."
	icon_state = "book8_0"
	base_icon_state = "book8"
	bookfile = "VowOfNecraPage.json"

/obj/item/book/godofdreamsandnightmares
	name = "God of Dreams & Nightmares"
	desc = "An old decrepit book, with seemingly no author."
	bookfile = "GodDreams.json"
	random_cover = TRUE

/obj/item/book/psybibleplayerbook
	name = "Psybible"
	desc = "An old tome, authored by Father Ambrose of Grenzelhoft."
	bookfile = "PsyBible.json"
	random_cover = TRUE

/obj/item/book/manners
	name = "Manners of Gentlemen"
	desc = "A popular guide for young people of genteel birth."
	icon_state ="basic_book_0"
	base_icon_state = "basic_book"
	bookfile = "manners.json"

/obj/item/book/advice_soup
	name = "Soup de Rattus"
	desc = "Weathered book containing advice on surviving a famine."
	bookfile = "AdviceSoup.json"
	random_cover = TRUE

/obj/item/book/advice_farming
	name = "The Secrets of the Agronome"
	desc = "Soilson bible."
	bookfile = "AdviceFarming.json"
	random_cover = TRUE

/obj/item/book/advice_weaving
	name = "A hundred kinds of stitches"
	desc = "Howe to weave, tailor, and sundry tailoring. By Agnea Corazzani."
	icon_state ="book8_0"
	base_icon_state = "book8"
	bookfile = "AdviceWeaving.json"

/obj/item/book/yeoldecookingmanual // new book with some tips to learn
	name = "Ye olde ways of cookinge"
	desc = "Penned by Svend Fatbeard, butler in the fourth generation"
	icon_state ="book8_0"
	base_icon_state = "book8"
	bookfile = "Neu_cooking.json"

/obj/item/book/psybibble
	name = "The Book"
	icon_state = "psybibble_0"
	base_icon_state = "psybibble"
	title = "bible"
	dat = "gott.json"
	force = 2
	force_wielded = 4
	throwforce = 1
	possible_item_intents = list(/datum/intent/use, /datum/intent/mace/strike/wood)

/obj/item/book/psybibble/read(mob/user)
	if(!open)
		to_chat(user, "<span class='info'>Open me first.</span>")
		return FALSE
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		user.adjust_experience(/datum/skill/misc/reading, 4, FALSE)
		return
	if(in_range(user, src) || isobserver(user))
		user.changeNext_move(CLICK_CD_MELEE)
		var/m
		var/list/verses = world.file2list("strings/psybibble.txt")
		m = pick(verses)
		if(m)
			user.say(m)

/obj/item/book/psybibble/attack(mob/living/M, mob/user)
	if(is_priest_job(user.mind.assigned_role))
		if(!user.can_read(src))
			return
		M.apply_status_effect(/datum/status_effect/buff/blessed)
		user.visible_message("<span class='notice'>[user] blesses [M].</span>")
		playsound(user, 'sound/magic/bless.ogg', 100, FALSE)
		return

/datum/status_effect/buff/blessed
	id = "blessed"
	alert_type = /atom/movable/screen/alert/status_effect/buff/blessed
	effectedstats = list(STATKEY_LCK = 1)
	duration = 20 MINUTES

/atom/movable/screen/alert/status_effect/buff/blessed
	name = "Blessed"
	desc = "Astrata's light flows through me."
	icon_state = "buff"

/datum/status_effect/buff/blessed/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_stress(/datum/stressevent/blessed)

/datum/status_effect/buff/blessed/on_remove()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_stress(/datum/stressevent/blessed)

/obj/item/book/rogue/howtogaffer
	name = "Dont be a gaff, the guild masters manual"
	desc = "the author page has rotted off with time"
	bookfile = "Gaff.json"
	random_cover = TRUE
