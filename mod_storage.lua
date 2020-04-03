local storage = minetest.get_mod_storage()
local mod_storage = {}

function mod_storage.set_value(key, value)
    storage:set_string(key, minetest.serialize(value))
end

function mod_storage.get_value(key, value)
    return minetest.deserialize(storage:get_string(key))
end

return mod_storage