--mod_storage = dofile(minetest.get_modpath("online_shop") .. "/mod_storage.lua")
local storage = minetest.get_mod_storage()
mod_storage = {}

function mod_storage.get_value(key)
	return storage:get_string(key)
end

function mod_storage.set_value(key, value)
	storage:set_string(key, value)
end

online_shop = {}

dofile(minetest.get_modpath("online_shop") .. "/helper.lua")
dofile(minetest.get_modpath("online_shop") .. "/privs.lua")
dofile(minetest.get_modpath("online_shop") .. "/craftitems.lua")
dofile(minetest.get_modpath("online_shop") .. "/shop.lua")
dofile(minetest.get_modpath("online_shop") .. "/online_shop_offline_banlist.lua")
dofile(minetest.get_modpath("online_shop") .. "/online_shopping.lua")
dofile(minetest.get_modpath("online_shop") .. "/manage_shops.lua")
dofile(minetest.get_modpath("online_shop") .. "/chatcommands.lua")