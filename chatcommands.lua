minetest.register_chatcommand("my_shops", {
	params = "",
	privs = { shout = true },
	description = "Lists all shops owned by the current player.",
	func = function(name, text)
		local owned_stores = {}
		local stores = online_shop.list_stores()
		for _, v in pairs(stores) do
			if online_shop.get_shop_owner(v) == name then
				table.insert(owned_stores, v)
			end
		end
		local result = table.concat(owned_stores, ", ")
		if result ~= nil and result ~= "" then
			return true, "You own the following shops: "..result.."."
		else
			return true, "You do not own any shops."
		end
	end,
})

minetest.register_chatcommand("show_player_shops", {
	params = "<player>",
	privs = { shout = true, online_shop_admin = true },
	description = "Lists all shops owned by the specified player.",
	func = function(name, text)
		if text ~= nil and text ~= "" then
			if minetest.player_exists(text) then
				local owned_stores = {}
				local stores = online_shop.list_stores()
				for _, v in pairs(stores) do
					if online_shop.get_shop_owner(v) == text then
						table.insert(owned_stores, v)
					end
				end
				local result = table.concat(owned_stores, ", ")
				if result ~= nil and result ~= "" then
					return true, "'"..text.."' owns the following shops: "..result.."."
				else
					return true, "'"..text.."' does not own any shops."
				end
			else
				return false, "Player '"..text.."' does not exist."
			end
		else
			return false, "Enter a player name."
		end
	end,
})

minetest.register_chatcommand("delete_player_shops", {
	params = "<player>",
	privs = { shout = true, online_shop_admin = true },
	description = "Deletes all shops owned by the specified player.",
	func = function(name, text)
		if text ~= nil and text ~= "" then
			if minetest.player_exists(text) then
				local owned_stores = {}
				local stores = online_shop.list_stores()
				for _, v in pairs(stores) do
					if online_shop.get_shop_owner(v) == text then
						table.insert(owned_stores, v)
						online_shop.delete_shop(v)
					end
				end
				local result = table.concat(owned_stores, ", ")
				local message = ""
				if result ~= nil and result ~= "" then
					message = "The following shops were deleted: "..result.."."
				else
					message = "'"..text.."' does not own any shops."
				end
				return true, message
			else
				return false, "Player '"..text.."' does not exist."
			end
		else
			return false, "Enter a player name."
		end
	end,
})

minetest.register_chatcommand("online_shop_ban", {
	params = "<player>",
	privs = { shout = true, online_shop_admin = true },
	description = "Ban a player from placing Shop Server nodes.",
	func = function(name, text)
		if text ~= nil and text ~= "" then
			if minetest.player_exists(text) then
				local player = minetest.get_player_by_name(text)
				if online_shop.player_is_online(text) == true then
					local meta = player:get_meta()
					meta:set_string("online_shop_banstate", "banned")
					
					minetest.chat_send_player(text, "You have been banned from placing Shop Servers.")
					return true, "Player '"..text.."' has been banned from placing Shop Servers."
				else
					o_s_banlist.remove_from_unbanned(text)
					o_s_banlist.add_to_banned(text)
					return true, "Player '"..text.."' is not online. Player will be banned the next time they join the server."
				end
			else
				return false, "Player '"..text.."' does not exist."
			end
		else
			return false, "Enter a player name."
		end
	end,
})

minetest.register_chatcommand("online_shop_unban", {
	params = "<player>",
	privs = { shout = true, online_shop_admin = true },
	description = "Unban a player from placing Shop Server nodes.",
	func = function(name, text)
		if text ~= nil and text ~= "" then
			if minetest.player_exists(text) then
				if online_shop.player_is_online(text) == true then
					local player = minetest.get_player_by_name(text)
					local meta = player:get_meta()
					meta:set_string("online_shop_banstate", "")
					
					minetest.chat_send_player(text, "You have been unbanned from placing Shop Servers.")
					return true, "Player '"..text.."' has been unbanned from placing Shop Servers."
				else
					o_s_banlist.remove_from_banned(text)
					o_s_banlist.add_to_unbanned(text)
					return true, "Player '"..text.."' is not online. Player will be unbanned the next time they join the server."
				end
			else
				return false, "Player '"..text.."' does not exist."
			end
		else
			return false, "Enter a player name."
		end
	end,
})