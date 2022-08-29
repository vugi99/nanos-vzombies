


MAP_ROOMS = {}

MAP_ROOMS[1] = {}
MAP_ROOMS[2] = {}
MAP_ROOMS[3] = {}


PLAYER_SPAWNS = {}
table.insert(PLAYER_SPAWNS, {
    location = Vector(290.000, -177.000, 1.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000)
})
table.insert(PLAYER_SPAWNS, {
    location = Vector(302.000, 189.000, 1.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000)
})


MAP_DOORS = {}
table.insert(MAP_DOORS, {
    location = Vector(4932.000, -58.000, 143.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(0.363, 5.440, 2.880),
    price = 200,
    between_rooms = {2, 3, },
    required_rooms = {1, 2, },
    model = "nanos-world::SM_Cube"
})
table.insert(MAP_DOORS, {
    location = Vector(2947.000, -58.000, 143.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(0.362, 5.440, 2.880),
    price = 100,
    between_rooms = {1, 2, },
    required_rooms = {1, },
    model = "nanos-world::SM_Cube"
})


MAP_WEAPONS = {}
table.insert(MAP_WEAPONS, {
    location = Vector(-88.000, 1799.000, 110.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    price = 500,
    weapon_name = "DesertEagle",
    max_ammo = 200
})
table.insert(MAP_WEAPONS, {
    location = Vector(-88.000, 2002.000, 110.000),
    rotation = Rotator(0.000000, 179.999435, 0.000000),
    price = 500,
    weapon_name = "GE3",
    max_ammo = 400
})
table.insert(MAP_WEAPONS, {
    location = Vector(394.000, 812.000, 110.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    price = 500,
    weapon_name = "AK47",
    max_ammo = 400
})



-- ZOMBIE BARRICADES
table.insert(MAP_ROOMS[1], {
    barricade_location = Vector(2051.000, -888.000, 186.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_move_to_b_target_location = Vector(2051.000, -948.000, 1.000),
    z_reach_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_leave_b_tp_location = Vector(2051.000, -828.000, 1.000),
    z_spawns = {},
    type = "barricade",
    z_leave_b_tp_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_ground_debris_location = Vector(2051.000, -788.000, 1.000)
})
table.insert(MAP_ROOMS[2], {
    barricade_location = Vector(4066.000, -871.000, 185.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_move_to_b_target_location = Vector(4066.000, -931.000, 0.000),
    z_reach_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_leave_b_tp_location = Vector(4066.000, -811.000, 0.000),
    z_spawns = {},
    type = "barricade",
    z_leave_b_tp_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_ground_debris_location = Vector(4066.000, -771.000, 0.000)
})
table.insert(MAP_ROOMS[3], {
    barricade_location = Vector(6117.000, -871.000, 185.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_move_to_b_target_location = Vector(6117.000, -931.000, 0.000),
    z_reach_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_leave_b_tp_location = Vector(6117.000, -811.000, 0.000),
    z_spawns = {},
    type = "barricade",
    z_leave_b_tp_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_ground_debris_location = Vector(6117.000, -771.000, 0.000)
})
table.insert(MAP_ROOMS[1], {
    barricade_location = Vector(1625.000, -790.000, 185.000),
    barricade_rotation = Rotator(0.000000, 0.000000, 0.000000),
    z_move_to_b_target_location = Vector(1625.000, -850.000, 0.000),
    z_reach_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_leave_b_tp_location = Vector(1625.000, -730.000, 0.000),
    z_spawns = {},
    type = "barricade",
    z_leave_b_tp_rotation = Rotator(0.000000, 90.000000, -0.000000),
    z_ground_debris_location = Vector(1625.000, -690.000, 0.000)
})


MAP_PACK_A_PUNCH = {
    location = Vector(2182.000, 1590.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000),
    weapon_location = Vector(2119.000, 1562.000, 84.000),
    weapon_rotation = Rotator(0.000000, 89.999992, -0.000000)
}


MAP_POWER = {
    location = Vector(2197.000, 990.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000),
    handle_location = Vector(2178.000, 990.000, 118.000),
    handle_rotation = Rotator(0.000000, 89.999992, 90.000000)
}


MAP_MYSTERY_BOXES = {}
table.insert(MAP_MYSTERY_BOXES, {
    location = Vector(435.000, 2069.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})
table.insert(MAP_MYSTERY_BOXES, {
    location = Vector(435.000, 2780.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})
table.insert(MAP_MYSTERY_BOXES, {
    location = Vector(435.000, 1379.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})


MAP_PERKS = {}
MAP_PERKS.juggernog = {
    location = Vector(2165.000, 3255.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.quick_revive = {
    location = Vector(2151.000, 3613.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.doubletap = {
    location = Vector(2178.000, 2903.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.three_gun = {
    location = Vector(2128.000, 3965.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.stamin_up = {
    location = Vector(2140.000, 4346.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}
MAP_PERKS.speed_cola = {
    location = Vector(2137.000, 4696.000, 1.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
}


MAP_Z_LIMITS = {
    max = 1716.0,
    min = -787.0
}


MAP_WUNDERFIZZ = {}
table.insert(MAP_WUNDERFIZZ, {
    location = Vector(2480.000, 2529.000, 0.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})
table.insert(MAP_WUNDERFIZZ, {
    location = Vector(2480.000, 2050.000, 0.000),
    rotation = Rotator(0.000000, 89.999992, 0.000000)
})


MAP_INTERACT_TRIGGERS = {}
table.insert(MAP_INTERACT_TRIGGERS, {
    location = Vector(1177.000, 5319.000, 100.000),
    distance_sq = 160000.0,
    interact_text = "TEST CUSTOM INTERACT",
    event_name = "CustomInteractTest"
})


MAP_TELEPORTERS = {}
table.insert(MAP_TELEPORTERS, {
    location = Vector(3094.000, 3773.000, 106.000),
    price = 1,
    teleport_back_ms = 0,
    teleporter_cooldown_ms = 0,
    distance_sq = 90000.0,
    teleport_to = {
        {
            location = Vector(3101.000, 2954.000, 1.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
    },
    teleport_back = {
    },
})
table.insert(MAP_TELEPORTERS, {
    location = Vector(4048.000, 3773.000, 106.000),
    price = 2,
    teleport_back_ms = 0,
    teleporter_cooldown_ms = 120000,
    distance_sq = 90000.0,
    teleport_to = {
        {
            location = Vector(4077.000, 2920.000, 1.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
    },
    teleport_back = {
    },
})
table.insert(MAP_TELEPORTERS, {
    location = Vector(5063.000, 3811.000, 115.000),
    price = 3,
    teleport_back_ms = 0,
    teleporter_cooldown_ms = 0,
    distance_sq = 90000.0,
    teleport_to = {
        {
            location = Vector(4975.000, 2974.000, 1.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
        {
            location = Vector(5013.000, 2609.000, 0.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
    },
    teleport_back = {
    },
})
table.insert(MAP_TELEPORTERS, {
    location = Vector(6203.000, 3809.000, 115.000),
    price = 4,
    teleport_back_ms = 10000,
    teleporter_cooldown_ms = 0,
    distance_sq = 90000.0,
    teleport_to = {
        {
            location = Vector(6146.000, 2891.000, 0.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
        {
            location = Vector(6108.000, 2602.000, 1.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
    },
    teleport_back = {
        {
            location = Vector(5770.000, -135.000, 1.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
        {
            location = Vector(5774.000, 146.000, 1.000),
            rotation = Rotator(0.000000, 0.000000, 0.000000)
        },
    },
})


-- Zombie Vaults
table.insert(MAP_ROOMS[1], {
    type = "vault",
    z_spawns = {},
    z_target_location_1 = Vector(1230.000, -1165.000, 0.000),
    z_target_rotation_1 = Rotator(0.000000, 90.000000, -0.000000),
    z_leave_location_1 = Vector(1230.000, -685.000, 0.000),
    z_leave_rotation_1 = Rotator(0.000000, 90.000000, -0.000000),
    z_target_location_2 = Vector(1230.000, -1130.000, 0.000),
    z_target_rotation_2 = Rotator(0.000000, 90.000000, -0.000000),
    z_leave_location_2 = Vector(1230.000, -805.000, 0.000),
    z_leave_rotation_2 = Rotator(0.000000, 90.000000, -0.000000)
})


MAP_LIGHT_ZONES = {}
table.insert(MAP_LIGHT_ZONES, {
    location = Vector(-66.000, 4125.000, 203.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(16.147, 24.997, 6.387)
})


MAP_SETTINGS = {
    spawn_nanos_sky = true,
    time_overwrite = {nil, nil},
    Bosses_Enabled = true,
    Sky_Light_Intensity = -1.0,
    Sun_Light_Intensity = -1.0,
    disabled_enemies = {
    },
}


MAP_STATIC_MESHES = {}
table.insert(MAP_STATIC_MESHES, {
    location = Vector(3810.000, -3203.000, 149.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(100.000, 2.000, 3.000),
    model = "nanos-world::SM_Cube"
})
table.insert(MAP_STATIC_MESHES, {
    location = Vector(-1070.000, 1857.000, 149.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(2.000, 100.000, 3.000),
    model = "nanos-world::SM_Cube"
})
table.insert(MAP_STATIC_MESHES, {
    location = Vector(3810.000, 6927.000, 149.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(100.000, 2.000, 3.000),
    model = "nanos-world::SM_Cube"
})
table.insert(MAP_STATIC_MESHES, {
    location = Vector(8860.000, 1857.000, 149.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(2.000, 100.000, 3.000),
    model = "nanos-world::SM_Cube"
})
table.insert(MAP_STATIC_MESHES, {
    location = Vector(-80.000, 1900.000, 149.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    scale = Vector(2.000, 2.000, 3.000),
    model = "nanos-world::SM_Cube"
})


HELLHOUND_SPAWNS = {}
table.insert(HELLHOUND_SPAWNS, {
    location = Vector(1330.000, 200.000, 0.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    room = 1
})
table.insert(HELLHOUND_SPAWNS, {
    location = Vector(1930.000, 200.000, 0.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    room = 1
})
table.insert(HELLHOUND_SPAWNS, {
    location = Vector(1340.000, 2090.000, 0.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    room = 1
})
table.insert(HELLHOUND_SPAWNS, {
    location = Vector(1340.000, 3670.000, 0.000),
    rotation = Rotator(0.000000, 0.000000, 0.000000),
    room = 1
})


-- Zombie Spawns
table.insert(MAP_ROOMS[1][2].z_spawns, {
    location = Vector(1551.000, -2133.000, 1.000),
    rotation = Rotator(0.000000, 89.999748, 0.000000),
    ground_anim = false
})
table.insert(MAP_ROOMS[1][1].z_spawns, {
    location = Vector(1926.000, -2157.000, 1.000),
    rotation = Rotator(0.000000, 89.999680, 0.000000),
    ground_anim = true
})
table.insert(MAP_ROOMS[2][1].z_spawns, {
    location = Vector(4075.000, -1284.000, 1.000),
    rotation = Rotator(0.000000, 89.999680, 0.000000),
    ground_anim = true
})
table.insert(MAP_ROOMS[3][1].z_spawns, {
    location = Vector(6150.000, -1284.000, 1.000),
    rotation = Rotator(0.000000, 89.999680, 0.000000),
    ground_anim = true
})
table.insert(MAP_ROOMS[1][3].z_spawns, {
    location = Vector(1249.000, -1958.000, 1.000),
    rotation = Rotator(0.000000, 89.999748, 0.000000),
    ground_anim = true
})
table.insert(MAP_ROOMS[1], {
    type = "ground",
    location = Vector(2567.000, 607.000, 0.000),
    rotation = Rotator(0.000000, 179.999374, 0.000000),
    ground_anim = true
})
table.insert(MAP_ROOMS[1][1].z_spawns, {
    location = Vector(2209.000, -2157.000, 1.000),
    rotation = Rotator(0.000000, 89.999680, 0.000000),
    ground_anim = true
})
table.insert(MAP_ROOMS[1][1].z_spawns, {
    location = Vector(2447.000, -2157.000, 1.000),
    rotation = Rotator(0.000000, 89.999680, 0.000000),
    ground_anim = true
})
table.insert(MAP_ROOMS[1], {
    type = "ground",
    location = Vector(2600.000, 1286.000, 0.000),
    rotation = Rotator(0.000000, 179.999390, 0.000000),
    ground_anim = false
})
table.insert(MAP_ROOMS[1][2].z_spawns, {
    location = Vector(1628.000, -1123.000, 1.000),
    rotation = Rotator(0.000000, 89.999954, 0.000000),
    ground_anim = true
})




Package.Subscribe("Load", function()
	Events.Call("VZOMBIES_MAP_CONFIG", MAP_ROOMS, PLAYER_SPAWNS, MAP_DOORS, MAP_WEAPONS, MAP_PACK_A_PUNCH, MAP_POWER, MAP_MYSTERY_BOXES, MAP_PERKS, MAP_Z_LIMITS, MAP_WUNDERFIZZ, MAP_INTERACT_TRIGGERS, MAP_TELEPORTERS, MAP_LIGHT_ZONES, MAP_SETTINGS, MAP_STATIC_MESHES, HELLHOUND_SPAWNS)
end)