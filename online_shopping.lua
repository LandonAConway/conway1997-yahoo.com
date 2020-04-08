minetest.register_chatcommand("online_shopping", {
	params = "",
	privs = { shout = true },
	description = "Shows the online shopping interface.",
	func = function(name, text)
		local stores = online_shop.list_stores()
		if table.concat(stores) ~= nil and table.concat(stores) ~= "" then
			minetest.show_formspec(name, "online_shop:os_formspec", online_shop.shopping_ui(-1, name))
		else
			return false, "There are no stores."
		end
	end,
})

function online_shop.shopping_ui(index, player_name, owner_name)
	--Get Inventories
	local cust_gives = minetest.get_inventory({ type="detached", name="online_customer_gives_"..player_name })
	local cust_gets = minetest.get_inventory({ type="detached", name="online_customer_gets_"..player_name })
	local owner_wants = minetest.get_inventory({ type="detached", name="online_owner_wants_"..player_name })
	local owner_gives = minetest.get_inventory({ type="detached", name="online_owner_gives_"..player_name })
	cust_gives:set_size("main", 2*4)
	cust_gets:set_size("main", 2*4)
	owner_wants:set_size("main", 2*4)
	owner_gives:set_size("main", 2*4)
	
	--If started from command
	if index == -1 then
		index = 1
		
		local stores = online_shop.list_stores()
		if table.concat(stores) ~= nil and table.concat(stores) ~= "" then
			local player = minetest.get_player_by_name(player_name)
			local player_meta = player:get_meta()
			
			local storename = online_shop.list_stores()[1]
			player_meta:set_string("selected_shop_name", storename)
			
			local pos_list = online_shop.pos_list_as_table(storename)
			local selected_pos = pos_list[index]
			player_meta:set_string("selected_shop_pos", selected_pos)
			
			local pos = minetest.string_to_pos(selected_pos)
			local meta = minetest.get_meta(pos)
			online_shop.get_want(player, meta, pos)
			online_shop.get_give(player, meta, pos)
			
			owner_name = online_shop.get_shop_owner(storename)
		end
	end
	
	--Shops
	local list_stores = online_shop.list_stores()
	local shopslist = o_s_methods.join_string(list_stores, ",")
	
	local items = {}
	
	local lss = table.concat(list_stores)
	if lss ~= nil and lss ~= "" then
		items = online_shop.get_item_labels(list_stores[index])
	else
		index = 1
		items = { }
	end
	
	--Owners name
	if owner_name == nil then
		owner_name = ""
	end
	
	local available_items = o_s_methods.join_string(items, ",")
	
	local formspec = "size[14,12]"..
		"label[0,0;Shops:]"..
		"textlist[0,0.5;5,5;shops;"..shopslist..";"..index..";transparent]"..
		"label[0,6;Items Sold:]"..
		"textlist[0,6.5;5,5;shop_items;"..available_items..";1"..";transparent]"..
		"label[0,11.5;Shop Owner: "..owner_name.."]"..
		"label[5.5,0;You give (Pay here):]"..
		"list[detached:online_customer_gives_"..player_name..";main;5.5,0.5;4,2;]"..
		"label[5.5,3;You got:]"..
		"list[detached:online_customer_gets_"..player_name..";main;5.5,3.5;4,2;]"..
		"label[10,0;Owner Wants:]"..
		"list[detached:online_owner_wants_"..player_name..";main;10,0.5;4,2;]"..
		"label[10,3;In exchange, owner gives:]"..
		"list[detached:online_owner_gives_"..player_name..";main;10,3.5;4,2;]"..
		"button[5.5,6.5;4,0.8;exchange;Exchange]"..
		"button_exit[10,6.5;4,0.8;exit;Exit]"..
		"list[current_player;main;5.75,7.5;8,4;]"
		
	--If player is owner then add button
	if player_name == owner_name then
		formspec = formspec.."button[10,5.7;4,0.8;manage;Manage]"
	end
	
	return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "online_shop:os_formspec" then
		local shop_index = 1
		local player_meta = player:get_meta()
		if fields.shops then
			local shops_event = minetest.explode_textlist_event(fields.shops)
			if shops_event.type == "CHG" then
				local stores = online_shop.list_stores()
				local storename = stores[shops_event.index]
				player_meta:set_string("selected_shop_name", storename)
				
				if online_shop.store_exists(storename) == true then
					local shop_owner = online_shop.get_shop_owner(storename)
					local name = player:get_player_name()
					shop_index = shops_event.index
					local shopping_formspec = online_shop.shopping_ui(shop_index, name, shop_owner)
					
					local pos_list = online_shop.pos_list_as_table(storename)
					local selected_pos = pos_list[1]
					if selected_pos ~= nil and selected_pos ~= "" then
						local meta = minetest.get_meta(minetest.string_to_pos(selected_pos))
						online_shop.get_want(player, meta, minetest.string_to_pos(selected_pos))
						online_shop.get_give(player, meta, minetest.string_to_pos(selected_pos))
						player_meta:set_string("selected_shop_pos", selected_pos)
					end
					
					minetest.show_formspec(name, "online_shop:os_formspec", shopping_formspec)
				end
			end
		elseif fields.shop_items then
			local shop_items_event = minetest.explode_textlist_event(fields.shop_items)
			if shop_items_event.type == "CHG" then
				local selected_shop_name = player_meta:get_string("selected_shop_name")
				if selected_shop_name == nil or selected_shop_name == "" then
					selected_shop_name = online_shop.list_stores()[1]
				end
				if selected_shop_name ~= nil and selected_shop_name ~= "" then
					local pos_list = online_shop.pos_list_as_table(selected_shop_name)
					local selected_pos = pos_list[shop_items_event.index]
					local meta = minetest.get_meta(minetest.string_to_pos(selected_pos))
					online_shop.get_want(player, meta, minetest.string_to_pos(selected_pos))
					online_shop.get_give(player, meta, minetest.string_to_pos(selected_pos))
					player_meta:set_string("selected_shop_pos", selected_pos)
				end
			end
		elseif fields.exchange then
			local selected_pos = player_meta:get_string("selected_shop_pos")
			if selected_pos ~= nil and selected_pos ~= "" then
				local pos = minetest.string_to_pos(selected_pos)
				local meta = minetest.get_meta(pos)
				online_shop.exchange(player, meta, pos)
			end
		elseif fields.manage then
			local selected_shop_name = player_meta:get_string("selected_shop_name")
			local selected_shop_pos = player_meta:get_string("selected_shop_pos")
			local pos = minetest.string_to_pos(selected_shop_pos)
			online_shop.open_shop_formspec(player:get_player_name(), pos)
		end
	end
end)

function online_shop.exchange(player, meta, pos)
	local player_name = player:get_player_name()
	
	--Get owner wants
	local owner_wants = minetest.get_inventory({ type="detached", name="online_owner_wants_"..player_name })
	local owner_wants_inv_list = owner_wants:get_list("main")
	
	--Get owner gives
	local owner_gives = minetest.get_inventory({ type="detached", name="online_owner_gives_"..player_name })
	local owner_gives_inv_list = owner_gives:get_list("main")
	
	--Get customer gives
	local customer_gives = minetest.get_inventory({ type="detached", name="online_customer_gives_"..player_name })
	local customer_gives_inv_list = customer_gives:get_list("main")
	
	--Get customer gets
	local customer_gets = minetest.get_inventory({ type="detached", name="online_customer_gets_"..player_name })
	local customer_gets_inv_list = customer_gets:get_list("main")
	
	--Check if customer has what owner wants
	if online_shop.customer_has(owner_wants, customer_gives) == true then
		if online_shop.customer_has_room_for(owner_gives, customer_gets) == true then
			local owners_node = meta:get_inventory()
			if online_shop.owner_has_enough(owners_node, owner_gives) == true then
				online_shop.give_to_owner(owners_node, customer_gives)
				online_shop.give_to_customer(customer_gets, owners_node)
			else
				minetest.chat_send_player(player_name, "The owner needs to fill their stock.")
			end
		else
			minetest.chat_send_player(player_name, "You do not have enough room for the the exchange.")
		end
	else
		minetest.chat_send_player(player_name, "You do not have enough of what the owner wants.")
	end
end

function online_shop.customer_has(owner, customer)
	local owner_wants = owner:get_list("main")
	for _, stack in pairs(owner_wants) do
		if not customer:contains_item("main", stack) then
			return false
		end
	end
	return true
end

function online_shop.customer_has_room_for(owner, customer)
	local owner_wants = owner:get_list("main")
	for _, stack in pairs(owner_wants) do
		if not customer:room_for_item("main", stack) then
			return false
		end
	end
	return true
end

function online_shop.owner_has_enough(owner_stock, owner_give)
	local needs = owner_give:get_list("main")
	for _, stack in pairs(needs) do
		if not owner_stock:contains_item("stock", stack) then
			return false
		end
	end
	return true
end

function online_shop.give_to_owner(send_to, customer_has)
	local owner_wants = send_to:get_list("owner_wants")
	for _, stack in pairs(owner_wants) do
		local removed_from_customer = customer_has:remove_item("main", stack)
		send_to:add_item("customers_gave", removed_from_customer)
	end
end

function online_shop.give_to_customer(customer_gets, send_from)
	local owner_gives = send_from:get_list("owner_gives")
	for _, stack in pairs(owner_gives) do
		local removed_from_owner = send_from:remove_item("stock", stack)
		customer_gets:add_item("main", removed_from_owner)
	end
end

function online_shop.get_want(player, meta, pos)
	local player_name = player:get_player_name()
	
	local owner_wants = minetest.get_inventory({ type="detached", name="online_owner_wants_"..player_name })
	local inv_list = owner_wants:get_list("main")
	
	local node_inv = meta:get_inventory()
	local node_inv_list = node_inv:get_list("owner_wants")
	
	for _, stack in pairs(inv_list) do
		owner_wants:remove_item("main", stack)
	end
	
	for _, stack_ in pairs(node_inv_list) do
		owner_wants:add_item("main", stack_)
	end
end

function online_shop.get_give(player, meta, pos)
	local player_name = player:get_player_name()
	
	local owner_wants = minetest.get_inventory({ type="detached", name="online_owner_gives_"..player_name })
	local inv_list = owner_wants:get_list("main")
	
	local node_inv = meta:get_inventory()
	local node_inv_list = node_inv:get_list("owner_gives")
	
	for _, stack in pairs(inv_list) do
		owner_wants:remove_item("main", stack)
	end
	
	for _, stack_ in pairs(node_inv_list) do
		owner_wants:add_item("main", stack_)
	end
end

function online_shop.open_shop_formspec(player_name, pos)
	mod_storage.set_value("last_pos", minetest.pos_to_string(pos))
	mod_storage.set_value("last_store_owner", player_name)
	local player = minetest.get_player_by_name(player_name)
	local meta = minetest.get_meta(pos)
	if player_name == meta:get_string("owner") and not player:get_player_control().aux1 then
		minetest.show_formspec(player_name, "online_shop:shop_server_formspec", online_shop.shop_server(pos))
		local msv = meta:get_string("store_name")
		mod_storage.set_value("original_store_name", msv)
	elseif minetest.check_player_privs(player_name, { online_shop_admin = true }) then
		minetest.show_formspec(player_name, "online_shop:shop_server_formspec", online_shop.shop_server(pos))
		local msv = meta:get_string("store_name")
		mod_storage.set_value("original_store_name", msv)
	else
		minetest.chat_send_player(player_name, "You do not own this shop server.")
	end
end

function online_shop.create_inventory(player_name)
	minetest.create_detached_inventory("online_customer_gives_"..player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return count
		end,

		allow_put = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,

		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
	})
	
	minetest.create_detached_inventory("online_customer_gets_"..player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return count
		end,

		allow_put = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,

		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
	})
	
	minetest.create_detached_inventory("online_owner_wants_"..player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,

		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,

		allow_take = function(inv, listname, index, stack, player)
			return 0
		end,
	})
	
	minetest.create_detached_inventory("online_owner_gives_"..player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,

		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,

		allow_take = function(inv, listname, index, stack, player)
			return 0
		end,
	})
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	
	online_shop.create_inventory(player_name)
	
	local cust_gives = minetest.get_inventory({ type="detached", name="online_customer_gives_"..player_name })
	local cust_gets = minetest.get_inventory({ type="detached", name="online_customer_gets_"..player_name })
	local owner_wants = minetest.get_inventory({ type="detached", name="online_owner_wants_"..player_name })
	local owner_gives = minetest.get_inventory({ type="detached", name="online_owner_gives_"..player_name })
	cust_gives:set_size("main", 2*4)
	cust_gets:set_size("main", 2*4)
	owner_wants:set_size("main", 2*4)
	owner_gives:set_size("main", 2*4)
end)