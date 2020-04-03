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

minetest.register_chatcommand("shops", {
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