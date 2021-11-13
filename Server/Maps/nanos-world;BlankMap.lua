




MAP_ROOMS = {}

MAP_ROOMS[1] = {}
MAP_ROOMS[2] = {}
MAP_ROOMS[3] = {}


PLAYER_SPAWNS = {}
table.insert(PLAYER_SPAWNS, {
    location = Vector(290.000, -177.000, 2.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000)
})
table.insert(PLAYER_SPAWNS, {
    location = Vector(302.000, 189.000, 2.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000)
})


MAP_DOORS = {}
table.insert(MAP_DOORS, {
    location = Vector(2947.000, -58.000, 144.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(0.362, 5.440, 3.880),
    price = 100,
    between_rooms = {1, 2, },
    required_rooms = {1, },
    model = "nanos-world::SM_Cube"
})
table.insert(MAP_DOORS, {
    location = Vector(4932.000, -58.000, 144.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(0.363, 5.440, 3.880),
    price = 200,
    between_rooms = {2, 3, },
    required_rooms = {1, 2, },
    model = "nanos-world::SM_Cube"
})


MAP_WEAPONS = {}
table.insert(MAP_WEAPONS, {
    location = Vector(394.000, 812.000, 111.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    price = 500,
    weapon_name = "AK47",
    max_ammo = 400
})



-- ZOMBIE SPAWNS
table.insert(MAP_ROOMS[1], {
    barricade_location = Vector(1625.000, -790.000, 186.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_spawn_location = Vector(1628.000, -1123.000, 2.000),
    z_spawn_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_move_to_b_target_location = Vector(1625.000, -850.000, 1.000),
    z_reach_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_leave_b_tp_location = Vector(1625.000, -730.000, 1.000),
    z_leave_b_tp_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_ground_debris_location = Vector(1625.000, -690.000, 1.000)
})
table.insert(MAP_ROOMS[1], {
    barricade_location = Vector(2051.000, -888.000, 187.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_spawn_location = Vector(2099.000, -1247.000, 2.000),
    z_spawn_rotation = Rotator(0.000000, 75.599770, 0.000000),
    z_move_to_b_target_location = Vector(2051.000, -948.000, 2.000),
    z_reach_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_leave_b_tp_location = Vector(2051.000, -828.000, 2.000),
    z_leave_b_tp_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_ground_debris_location = Vector(2051.000, -788.000, 2.000)
})
table.insert(MAP_ROOMS[2], {
    barricade_location = Vector(4066.000, -871.000, 186.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_spawn_location = Vector(4075.000, -1284.000, 2.000),
    z_spawn_rotation = Rotator(0.000000, 89.999733, 0.000000),
    z_move_to_b_target_location = Vector(4066.000, -931.000, 1.000),
    z_reach_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_leave_b_tp_location = Vector(4066.000, -811.000, 1.000),
    z_leave_b_tp_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_ground_debris_location = Vector(4066.000, -771.000, 1.000)
})
table.insert(MAP_ROOMS[3], {
    barricade_location = Vector(6117.000, -871.000, 186.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_spawn_location = Vector(6150.000, -1284.000, 2.000),
    z_spawn_rotation = Rotator(0.000000, 89.999733, 0.000000),
    z_move_to_b_target_location = Vector(6117.000, -931.000, 1.000),
    z_reach_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_leave_b_tp_location = Vector(6117.000, -811.000, 1.000),
    z_leave_b_tp_rotation = Rotator(0.000000, 89.999992, 0.000000),
    z_ground_debris_location = Vector(6117.000, -771.000, 1.000)
})


MAP_PACK_A_PUNCH = {
    location = Vector(2182.000, 1590.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000),
    weapon_location = Vector(2119.000, 1562.000, 85.000),
    weapon_rotation = Rotator(0.000000, 89.999992, 0.000000)
}


MAP_POWER = {
    location = Vector(2197.000, 990.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000),
    handle_location = Vector(2178.000, 990.000, 119.000),
    handle_rotation = Rotator(0.000000, 89.999985, 89.999985)
}


MAP_MYSTERY_BOXES = {}
table.insert(MAP_MYSTERY_BOXES, {
    location = Vector(435.000, 2780.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})
table.insert(MAP_MYSTERY_BOXES, {
    location = Vector(435.000, 1379.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})
table.insert(MAP_MYSTERY_BOXES, {
    location = Vector(435.000, 2069.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})


MAP_PERKS = {}
MAP_PERKS.juggernog = {
    location = Vector(2165.000, 2422.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.quick_revive = {
    location = Vector(2151.000, 2780.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.doubletap = {
    location = Vector(2178.000, 2070.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.three_gun = {
    location = Vector(2128.000, 3132.000, 2.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}


MAP_Z_LIMITS = {
    max = 1716.0,
    min = -787.0
}




Package.Subscribe("Load", function()
	Events.Call("VZOMBIES_MAP_CONFIG", MAP_ROOMS, PLAYER_SPAWNS, MAP_DOORS, MAP_WEAPONS, MAP_PACK_A_PUNCH, MAP_POWER, MAP_MYSTERY_BOXES, MAP_PERKS, MAP_Z_LIMITS)
end)