minetest.register_craftitem("online_shop:glass_shards", {
    description = "Glass Shards",
    inventory_image = "shop_glass_shards.png"
})

minetest.register_craft({
    type = "shapeless",
    output = "online_shop:glass_shards",
    recipe = {"default:glass"}
})

minetest.register_craftitem("online_shop:molten_plastic", {
    description = "Molten Plastic",
    inventory_image = "shop_molten_plastic.png"
})

minetest.register_craft({
	type = "cooking",
	output = "online_shop:molten_plastic",
	recipe = "basic_materials:plastic_sheet",
})

minetest.register_craftitem("online_shop:molten_glass", {
    description = "Molten Glass",
    inventory_image = "shop_molten_glass.png"
})

minetest.register_craft({
	type = "cooking",
	output = "online_shop:molten_glass",
	recipe = "online_shop:glass_shards",
})

minetest.register_craftitem("online_shop:plastic_fiberglass", {
    description = "Plastic Fiberglass",
    inventory_image = "shop_plastic_fiberglass.png"
})

minetest.register_craft({
    type = "shapeless",
    output = "online_shop:plastic_fiberglass",
    recipe = {"online_shop:molten_plastic", "online_shop:molten_glass"}
})

minetest.register_craftitem("online_shop:shop_server_motherboard", {
    description = "Shop Server Motherboard",
    inventory_image = "shop_shop_server_motherboard.png"
})

minetest.register_craft({
    type = "shapeless",
    output = "online_shop:shop_server_motherboard",
    recipe = {"default:copper_ingot", "online_shop:plastic_fiberglass", "dye:dark_green"}
})

minetest.register_craft({
    type = "shapeless",
    output = "currency:shop",
    recipe = {"default:sign_wall_wood", "default:chest_locked"}
})

minetest.register_craft({
    type = "shapeless",
    output = "currency:shop",
    recipe = {"default:sign_wall_metal", "default:chest_locked"}
})