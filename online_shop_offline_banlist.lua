o_s_banlist = {}

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	local player_name = player:get_player_name()
	if o_s_banlist.check_if_on_list(player_name, o_s_banlist.get_banned_players()) == true then
		meta:set_string("online_shop_banstate", "banned")
		o_s_banlist.remove_from_banned(player_name)
		minetest.chat_send_player(player_name, "You have been banned from placing Shop Servers.")
	elseif o_s_banlist.check_if_on_list(player_name, o_s_banlist.get_unbanned_players()) == true then
		meta:set_string("online_shop_banstate", "")
		o_s_banlist.remove_from_unbanned(player_name)
		minetest.chat_send_player(player_name, "You have been unbanned from placing Shop Servers.")
	end
end)

function o_s_banlist.get_banned_players()
	local from_storage = mod_storage.get_value("banned")
	return o_s_methods.separate_string(from_storage, "|")
end

function o_s_banlist.get_unbanned_players()
	local from_storage = mod_storage.get_value("unbanned")
	return o_s_methods.separate_string(from_storage, "|")
end

function o_s_banlist.add_to_banned(player)
	local players = o_s_banlist.get_banned_players()
	if o_s_banlist.check_if_on_list(player, players) ~= true then
		table.insert(players, player)
	end
	mod_storage.set_value("banned", o_s_methods.join_string(players, "|"))
end

function o_s_banlist.remove_from_banned(player)
	local players = o_s_banlist.get_banned_players()
	for i, v in ipairs(players) do
		if v == player then
			table.remove(players, i)
		end
	end
	mod_storage.set_value("banned", o_s_methods.join_string(players, "|"))
end

function o_s_banlist.add_to_unbanned(player)
	local players = o_s_banlist.get_unbanned_players()
	if o_s_banlist.check_if_on_list(player, players) ~= true then
		table.insert(players, player)
	end
	mod_storage.set_value("unbanned", o_s_methods.join_string(players, "|"))
end

function o_s_banlist.remove_from_unbanned(player)
	local players = o_s_banlist.get_unbanned_players()
	for i, v in ipairs(players) do
		if v == player then
			table.remove(players, i)
		end
	end
	mod_storage.set_value("unbanned", o_s_methods.join_string(players, "|"))
end

function o_s_banlist.check_if_on_list(player, list)
	for i, v in ipairs(list) do
		if v == player then
			return true
		end
	end
	return false
end