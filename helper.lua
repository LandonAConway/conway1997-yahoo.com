o_s_methods = {}

function o_s_methods.separate_string(inputstr, sep)
	if sep == nil then
		sep = ", "
	end
	
	local t = {}
	if string.find(inputstr, sep) then
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
		end
	else
		table.insert(t, inputstr)
	end
	
	return t
end

function o_s_methods.join_string(list, sep)
	if sep == nil then
		sep = ", "
	end
	
	return table.concat(list, sep)
end

function online_shop.player_is_online(player_name)
	for _, player in ipairs(minetest.get_connected_players()) do
		if player_name == player:get_player_name() == true then
			return true
		end
	end
	return false
end