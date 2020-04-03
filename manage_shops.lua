minetest.register_chatcommand("manage_shops", {
	params = "",
	privs = { shout = true, online_shop_admin = true },
	description = "Allows admins to manage all shops across the server.",
	func = function(name, text)
		minetest.show_formspec(name, "online_shop:manage_shops_formspec", online_shop.manage_shops())
	end,
})

function online_shop.manage_shops(shop_owner)
	local list_stores = online_shop.list_stores()
	local shopslist = o_s_methods.join_string(list_stores, ",")
	
	if shop_owner == nil or shop_owner == "" then
		local storename = list_stores[1]
		shop_owner = online_shop.get_shop_owner(storename)
		
		mod_storage.set_value("manage_shops_store_name", storename)
		mod_storage.set_value("manage_shops_shop_owner", shop_owner)
	end
	
	local formspec = "size[8,11.5]"..
		"label[0,0;Shops:]"..
		"textlist[0,0.5;5,7.5;shops;"..shopslist.."]"..
		"label[0,8;Shop Owner: "..shop_owner.."]"..
		"button_exit[5.5,0.5;2.5,0.8;exit;Exit]"..
		"button[5.5,1.5;2.5,0.8;delete;Delete]"..
		"button[5.5,2.5;2.5,0.8;update_all;Update All]"..
		"textarea[0.25,8.75;8,3.5;reason_for_deletion;Reason for deletion:;]"
	return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "online_shop:manage_shops_formspec" then
		local player_name = player:get_player_name()
		if fields.shops then
			local shops_event = minetest.explode_textlist_event(fields.shops)
			if shops_event.type == "CHG" then
				local list_stores = online_shop.list_stores()
				local storename = list_stores[shops_event.index]
				local shop_owner = online_shop.get_shop_owner(storename)
				
				mod_storage.set_value("manage_shops_shop_name", storename)
				mod_storage.set_value("manage_shops_shop_owner", shop_owner)
				
				minetest.show_formspec(player_name, "online_shop:manage_shops_formspec", online_shop.manage_shops(shop_owner))
			end
		elseif fields.delete then
			local shop_name = mod_storage.get_value("manage_shops_shop_name")
			local shop_owner = mod_storage.get_value("manage_shops_shop_owner")
			
			local success = online_shop.delete_shop(shop_name)
			if success == true then
				minetest.chat_send_player(player_name, "Successfuly deleted the shop '"..shop_name.."'.")
				if online_shop.player_is_online(shop_owner) == true then
					local reason = ""
					if fields.reason_for_deletion ~= nil and fields.reason_for_deletion ~= "" then
						reason = "Reason for deletion: "..fields.reason_for_deletion
					end
					minetest.chat_send_player(shop_owner, "Your shop, '"..shop_name.."' has been deleted by an admin. "..reason)
				end
				minetest.show_formspec(player_name, "online_shop:manage_shops_formspec", online_shop.manage_shops(""))
			end
		elseif fields.update_all then
			online_shop.update_shops()
			minetest.show_formspec(player_name, "online_shop:manage_shops_formspec", online_shop.manage_shops(""))
			minetest.chat_send_player(player_name, "All shops were updated.")
		end
	end
end)

function online_shop.delete_shop(shop_name)
	if online_shop.store_exists(shop_name) == true then
		local pos_list = online_shop.pos_list_as_table(shop_name)
		for i, v in ipairs(pos_list) do
			local pos = minetest.string_to_pos(v)
			minetest.remove_node(pos)
		end
		mod_storage.set_value(shop_name.."_pos_list", "")
		online_shop.update_stores()
		return true
	end
	return false
end

function online_shop.update_shops()
	local list_stores = online_shop.list_stores()
	for i, v in ipairs(list_stores) do
		if online_shop.store_exists(v) == true then
			online_shop.update_shop(v)
			online_shop.update_stores()
		end
	end
end

function online_shop.update_shop(shop_name)
	local pos_list = online_shop.pos_list_as_table(shop_name)
	local new_pos_list = {}
	for i, v in ipairs(pos_list) do
		local pos = minetest.string_to_pos(v)
		if online_shop.update_shop_server(pos) == false then
			table.insert(new_pos_list, v)
		end
	end
	mod_storage.set_value(shop_name.."_pos_list", o_s_methods.join_string(new_pos_list, "|"))
end

function online_shop.update_shop_server(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	
	if meta:get_string("store_name") ~= nil or meta:get_string("store_name") ~= "" then
		if node.name ~= "online_shop:shop_server" then
			minetest.remove_node(pos)
			return true
		end
	end
	return false
end