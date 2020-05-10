function online_shop.shop_server(pos)
	local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
	local meta = minetest.get_meta(pos)
	local store_name_t = meta:get_string("store_name")
	local item_label_t = meta:get_string("item_label")
	if store_name_t == nil or store_name_t == "" then store_name_t = "" end
	if item_label_t == nil or item_label_t == "" then item_label_t = "" end
	local formspec = "size[8.5,11.5]"..
		"label[0,0;" .. "Customers gave:" .. "]"..
		"list["..list_name..";customers_gave;0,0.5;4,2;]"..
		"label[0,2.5;" .. "Your stock:" .. "]"..
		"list["..list_name..";stock;0,3;4,2;]"..
		"label[4.5,0;" .. "You want:" .. "]"..
		"list["..list_name..";owner_wants;4.5,0.5;4,2;]"..
		"label[4.5,2.5;" .. "In exchange, you give:" .. "]"..
		"list["..list_name..";owner_gives;4.5,3;4,2;]"..
		"field[0.3,5.548;4,1;store_name;Store Name:;"..store_name_t.."]"..
		"button_exit[5,5.2;3,1;finish;Finish]"..
		"field[0.3,6.7;4,1;item_label;Item Label (i.e. 99 Clay Blocks for 10mg):;"..item_label_t.."]"..
		"list[current_player;main;0.25,7.5;8,4;]"
	return formspec
end

minetest.register_node("online_shop:shop_server", {
	description = "Shop Server",
	tiles = {
		"shop_shop_server_top.png",
		"shop_shop_server_top.png",
		"shop_shop_server_side.png",
		"shop_shop_server_side.png",
		"shop_shop_server_side.png",
		"shop_shop_server_front.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
	
	after_place_node = function(pos, placer, itemstack)
		local player_meta = placer:get_meta()
		if player_meta:get_string("online_shop_banstate") ~= "banned" then
			local owner = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Shopping Server (owned by "..owner..")")
			meta:set_string("owner", owner)
			local store_name = meta:set_string("store_name", "")
			local item_label = meta:set_string("item_label", "")
			local inv = meta:get_inventory()
			inv:set_size("customers_gave", 4*2)
			inv:set_size("stock", 4*2)
			inv:set_size("owner_wants", 4*2)
			inv:set_size("owner_gives", 4*2)
		else
			minetest.remove_node(pos)
			minetest.chat_send_player(placer:get_player_name(), "You have been banned from creating Shop Servers")
		end
	end,
	
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local store_name = meta:get_string("store_name")
		mod_storage.set_value("removed_store_name", store_name)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local pos_string = minetest.pos_to_string(pos)
		local store_name = mod_storage.get_value("removed_store_name")
		local player_name = digger:get_player_name()
		if store_name ~= nil and store_name ~= "" then
			online_shop.remove_from_shop(player_name, store_name, pos_string)
		end
		online_shop.update_stores()
	end,
	
	on_rightclick = function(pos, node, clicker, itemstack)
		mod_storage.set_value("last_pos", minetest.pos_to_string(pos))
		mod_storage.set_value("last_store_owner", clicker:get_player_name())
		local meta = minetest.get_meta(pos)
		if clicker:get_player_name() == meta:get_string("owner") and not clicker:get_player_control().aux1 then
			minetest.show_formspec(clicker:get_player_name(), "online_shop:shop_server_formspec", online_shop.shop_server(pos))
			local msv = meta:get_string("store_name")
			mod_storage.set_value("original_store_name", msv)
		elseif minetest.check_player_privs(clicker:get_player_name(), { online_shop_admin = true }) then
			minetest.show_formspec(clicker:get_player_name(), "online_shop:shop_server_formspec", online_shop.shop_server(pos))
			local msv = meta:get_string("store_name")
			mod_storage.set_value("original_store_name", msv)
		else
			minetest.chat_send_player(clicker:get_player_name(), "You do not own this shop server.")
		end
	end,
	
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local player_name = player:get_player_name()
		
		if meta:get_string("owner") == player_name then
			return true
		elseif minetest.check_player_privs(player_name, { online_shop_admin = true }) then
			return true
		end
		
		minetest.chat_send_player(player_name, "You do not own this shop server.")
		return false
	end
})

minetest.register_craft({
    type = "shapeless",
    output = "online_shop:shop_server",
    recipe = {"currency:shop", "online_shop:shop_server_motherboard"}
})

minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname == "online_shop:shop_server_formspec" and fields.finish ~= nil and fields.finish ~= "" then
		local last_store_owner = mod_storage.get_value("last_store_owner")
		local last_pos = mod_storage.get_value("last_pos")
		local original_store_name = mod_storage.get_value("original_store_name")
		local pos = minetest.string_to_pos(last_pos)
		local meta = minetest.get_meta(pos)
		
		if fields.store_name ~= nil and fields.store_name ~= "" and fields.item_label ~= nil and fields.item_label ~= "" then
			if not string.find(fields.store_name, "|") and not string.find(fields.item_label, "|") then
				if online_shop.store_exists(fields.store_name) == false then
					online_shop.add_to_shop(last_store_owner, fields.store_name, last_pos)
					online_shop.set_shop_owner(fields.store_name, last_store_owner)
					meta:set_string("store_name", fields.store_name)
					meta:set_string("item_label", fields.item_label)
					
					online_shop.update_shop_pos(original_store_name, fields.store_name, last_store_owner, last_pos)
					
					online_shop.add_store(fields.store_name)
					online_shop.update_stores()
					
					minetest.chat_send_player(last_store_owner, "Operation succeeded. Store server complete")
				else
					local owner = online_shop.get_shop_owner(fields.store_name)
					if owner == last_store_owner then
						online_shop.add_to_shop(last_store_owner, fields.store_name, last_pos)
						meta:set_string("store_name", fields.store_name)
						meta:set_string("item_label", fields.item_label)
						
						online_shop.update_shop_pos(original_store_name, fields.store_name, last_store_owner, last_pos)
						
						online_shop.add_store(fields.store_name)
						online_shop.update_stores()
					
						minetest.chat_send_player(last_store_owner, "Operation succeeded. Store server complete")
					else
						minetest.chat_send_player(last_store_owner, "Operation failed. This store is already owned by "..owner)
					end
				end
			else
				minetest.chat_send_player(last_store_owner, "Operation failed. Enter a valid 'Store Name' and 'Item Label'.")
			end
		else
			minetest.chat_send_player(last_store_owner, "Operation failed. Enter a valid 'Store Name' and 'Item Label'.")
		end
	else
		return
	end
end)

function online_shop.update_shop_pos(original_store_name, current_store_name, player_name, pos_string)
	if original_store_name ~= nil and original_store_name ~= "" then
		if current_store_name ~= original_store_name then
			online_shop.remove_from_shop(player_name, original_store_name, pos_string)
		end
	end
end

function online_shop.add_to_shop(player_name, store_name, pos_string)
	local pos_table = online_shop.pos_list_as_table(store_name)
	if pos_table ~= nil then
		local index = online_shop.pos_exists(pos_table, pos_string)
		if index == -1 then
			table.insert(pos_table, pos_string)
		end
		local new_pos_list = o_s_methods.join_string(pos_table, "|")
		mod_storage.set_value(store_name.."_pos_list", new_pos_list)
	else
		mod_storage.set_value(store_name.."_pos_list", pos_string)
	end
end

function online_shop.remove_from_shop(player_name, store_name, pos_string)
	local pos_table = online_shop.pos_list_as_table(store_name)
	if pos_table ~= nil then
		local index = online_shop.pos_exists(pos_table, pos_string)
		if index ~= -1 then
			table.remove(pos_table, index)
		end
		local new_pos_list = o_s_methods.join_string(pos_table, "|")
		mod_storage.set_value(store_name.."_pos_list", new_pos_list)
	end
end

function online_shop.pos_exists(pos_table, pos_string)
	local index = -1
	if pos_table ~= nil then
		for i, v in ipairs(pos_table) do
			if v == pos_string then
				index = i
			end
		end
	end
	return index
end

function online_shop.pos_list_as_table(store_name)
	local pos_list_s = mod_storage.get_value(store_name.."_pos_list")
	if pos_list_s ~= nil and pos_list_s ~= "" then
		local pos_table = o_s_methods.separate_string(pos_list_s, "|")
		return pos_table
	else
		return nil
	end
end

function online_shop.item_label_exists(store_name, item_label)
	local result = true
	local pos_table = online_shop.pos_list_as_table(store_name)
	if pos_table ~= nil then
		for i, v in ipairs(pos_table) do
			local pos = minetest.string_to_pos(v)
			local meta = minetest.get_meta(pos)
			if meta:get_string("item_label") ~= item_label then
				result = false
			end
		end
	end
	return result
end

function online_shop.get_item_labels(store_name)
	local t = {}
	local pos_table = online_shop.pos_list_as_table(store_name)
	if pos_table ~= nil then
		for i, v in ipairs(pos_table) do
			local pos = minetest.string_to_pos(v)
			local meta = minetest.get_meta(pos)
			table.insert(t, meta:get_string("item_label"))
		end
	end
	return t
end

function online_shop.get_item_label(store_name, pos)
	local meta = minetest.get_meta(pos)
	return meta:get_string("store_name")
end

function online_shop.store_exists(store_name)
	local store = mod_storage.get_value(store_name.."_pos_list")
	if store ~= nil and store ~= "" then
		return true
	end
	return false
end

function online_shop.add_store(store_name)
	local stores = online_shop.list_stores()
	if online_shop.store_exists_in_list(store_name, stores) == -1 then
		table.insert(stores, store_name)
		local new_stores_list = o_s_methods.join_string(stores, "|")
		mod_storage.set_value("stores_list", new_stores_list)
		return true
	end
	return false
end

function online_shop.remove_store(store_name)
	local stores = online_shop.list_stores()
	local index = online_shop.store_exists_in_list(store_name, stores)
	if index ~= -1 then
		table.remove(stores, index)
		local new_stores_list = o_s_methods.join_string(stores, "|")
		mod_storage.set_value("stores_list", new_stores_list)
	end
end

function online_shop.update_stores()
	local stores_table = online_shop.list_stores()
	if stores_table ~= nil then
		for i, v in ipairs(stores_table) do
			if online_shop.store_exists(v) == false then
				table.remove(stores_table, i)
			end
		end
		local new_stores_list = o_s_methods.join_string(stores_table, "|")
		mod_storage.set_value("stores_list", new_stores_list)
		return true
	end
	return false
end

function online_shop.store_exists_in_list(store_name, store_list)
	if store_list ~= nil then
		for i, v in ipairs(store_list) do
			if v == store_name then
				return i
			end
		end
	end
	return -1
end

function online_shop.list_stores()
	local stores = mod_storage.get_value("stores_list")
	return o_s_methods.separate_string(stores, "|")
end

function online_shop.get_shop_owner(store_name)
	return mod_storage.get_value(store_name.."_owner")
end

function online_shop.set_shop_owner(store_name, player_name)
	mod_storage.set_value(store_name.."_owner", player_name)
end
