
First_Wave_Enemies = 7
Add_at_each_wave = 1
Add_at_each_wave_per_player = 1 -- number of zombies added at each wave per playing player

--math.log(math.sqrt(round_nb) + 2.71)
Zombies_Number_Mult_Func = function(nb, round_nb)
    return nb*(1 + round_nb/math.log(round_nb/(2.5) + 1)/10)
end

Zombies_Health_Start = {
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    115,
    130,
}
Zombies_Health_Multiplier_At_Each_Wave = 1.1

Zombies_Nearest_SmartSpawns_Percentage = {
    16,
    15,
    14,
    12,
    10,
    9,
    8,
    6,
    4,
    3,
    2,
    1
}

Enemies_Spawn_Cooldown = 90000 -- All the wave enemies will be spawned (if it doesn't reach the limit) after this time
Enemies_Spawn_Interval_min_time_ms = 500

DestroyEnemy_After_death_ms = 20000

Max_enemies_spawned = 25
Max_Enemies_Dead_Ragdolls = 15

Enemy_Route_Update_ms = 100
Enemy_Look_At_Update_ms = 300

Enemies_Target_Refresh_ms = 2500

Enemies_Ragdoll_Get_Up_Timeout_ms = 10000

Enemies_Check_Can_Damage_Interval_ms = 1000
Enemies_Damage_Prediction_Div = 2.5


Enemies_Stuck_DistanceSq = 4
Enemies_Stuck_Check_Each_ms = 2500
Enemies_Stuck_Respawn_After_x_Stuck = 8 -- Respawns after x times his location was flagged as same, resets when he reaches his target

Enemies_Weird_Punch_Respawn_After_x_Weird = 25

Enemies_Ground_Dirt_Scale = Vector(5, 5, 5)

Enemies_Damage_Angle_LookAt = 80

Zombies_Gibs_Bones = {
    foot_l = {
        health_p = 10,
        asset = "vzombies-assets::FootL",
        materials = {
            "bottom",
        },
    },
    foot_r = {
        health_p = 10,
        asset = "vzombies-assets::FootR",
        materials = {
            "bottom",
        },
    },
    lowerarm_l = {
        health_p = 30,
        asset = "vzombies-assets::ForeArmL",
        Detach = {
            "hand_l",
        },
        materials = {
            "body",
        },
    },
    lowerarm_r = {
        health_p = 30,
        asset = "vzombies-assets::ForeArmR",
        Detach = {
            "hand_r",
        },
        materials = {
            "body",
        },
    },
    hand_l = {
        health_p = 10,
        asset = "vzombies-assets::HandL",
        materials = {
            "body",
        },
    },
    hand_r = {
        health_p = 10,
        asset = "vzombies-assets::HandR",
        materials = {
            "body",
        },
    },
    upperarm_l = {
        health_p = 50,
        asset = "vzombies-assets::ArmL",
        Detach = {
            "lowerarm_l",
        },
        materials = {
            "top",
            "body",
        },
    },
    upperarm_r = {
        health_p = 50,
        asset = "vzombies-assets::ArmR",
        Detach = {
            "lowerarm_r",
        },
        materials = {
            "body",
            "top",
        },
    },
    head = {
        health_p = 80,
        asset = "vzombies-assets::Head",
        materials = {
            "body",
            "hair",
        },
    },
    calf_l = {
        health_p = 30,
        asset = "vzombies-assets::KneeL",
        Detach = {
            "foot_l",
        },
        materials = {
            "bottom",
        },
    },
    calf_r = {
        health_p = 30,
        asset = "vzombies-assets::KneeR",
        Detach = {
            "foot_r",
        },
        materials = {
            "bottom",
        },
    },
    thigh_l = {
        health_p = 50,
        asset = "vzombies-assets::LegL",
        Detach = {
            "calf_l",
        },
        materials = {
            "bottom",
        },
    },
    thigh_r = {
        health_p = 50,
        asset = "vzombies-assets::LegR",
        Detach = {
            "calf_r",
        },
        materials = {
            "bottom",
        },
    },
}

Enemies_Gibs_Destroy_Timeout_ms = 25000
Enemies_Gibs_Max_Spawn_Distance_sq = 4000000
Enemies_Gibs_Can_Pickup = true

--Enemies_Gibs_Particle = "nanos-world::PS_Blood_Impact"

Vault_Animations = {
    VaultOverBox = {
        path = "vzombies-assets::VaultOverBox",
        timeout_ms = 1500,
        target_location_key = "z_target_location_2",
        target_rotation_key = "z_target_rotation_2",

        leave_location_key = "z_leave_location_2",
        leave_rotation_key = "z_leave_rotation_2",
    },
    JumpingRunning = {
        path = "vzombies-assets::JumpingRunning",
        timeout_ms = 1420,
        target_location_key = "z_target_location_1",
        target_rotation_key = "z_target_rotation_1",

        leave_location_key = "z_leave_location_1",
        leave_rotation_key = "z_leave_rotation_1",
    },
}

Enemies_Config = {
    Zombie = {

        -- Base walk = 190, base run = 380
        Types = {
            walk = {
                GaitMode = GaitMode.Walking,
                Speed_Multiplier = 1.4,
                Vault_Anim = Vault_Animations.VaultOverBox,
                Ambient_Sounds = RANDOM_SOUNDS.zombie_soft,
            },
            run = {
                GaitMode = GaitMode.Sprinting,
                Speed_Multiplier = 1.2,
                Vault_Anim = Vault_Animations.JumpingRunning,
                Ambient_Sounds = RANDOM_SOUNDS.zombie_sprint,
            },
            crawl = {
                GaitMode = GaitMode.Walking,
                Speed_Multiplier = 0.6,
                Vault_Anim = Vault_Animations.VaultOverBox,
                Ambient_Sounds = RANDOM_SOUNDS.zombie_crawl,
                Bot_Aim_Offset = Vector(0, 0, -30),

                New_Attack_Anims = {
                    {"vzombies-assets::AS_NAAT_Zombie_Attack_LH_Crawl", 725, 1400},
                    {"vzombies-assets::AS_NAAT_Zombie_Attack_RH_Crawl", 725, 1400},
                },
            },
        },

        Behind_Sounds = RANDOM_SOUNDS.zombie_behind,
        Death_Sounds = RANDOM_SOUNDS.zombie_death,
        Attack_Sounds = RANDOM_SOUNDS.zombie_attack,

        Acceptance_Radius = 70, -- At which distance from the player they can hurt him

        Damage_Amount = 30,
        Damage_At_Distance_sq = 23000,
        Damage_Barricade_Cooldown_ms = 3000,
        Can_Damage_After_ms = 1000, -- They can damage after waiting this time after leaving barricade (false reach fix)

        Collision_Radius = 17.0,

        Joker_Chance = 5, -- x amount TakeDamage will lead to joker for 10000 shots

        Models = {
            {
                asset = "vzombies-assets::SK_TSZombie",
                materials_slots = {
                    "bottom",
                    "top",
                    "hair",
                    "body",
                }
            },
        },

        Attack_Anims = {
            {"vzombies-assets::Zombie_Atk_Cut_1", 150, 700},
            {"vzombies-assets::Zombie_Atk_Cut_2", 280, 820},
            {"vzombies-assets::Zombie_Atk_Cut_3", 400, 660},

            {"vzombies-assets::ZombieAttack", 730, 1350},
            {"vzombies-assets::ZombieAttack2", 530, 1350},

            {"vzombies-assets::AS_NAAT_Zombie_Attack_BH_Stand", 520, 1650},
            {"vzombies-assets::AS_NAAT_Zombie_Attack_LH_Stand", 590, 1200},
            {"vzombies-assets::AS_NAAT_Zombie_Attack_RH_Stand", 590, 1200},
        },

        Spawning_Config = {
            type = "zombie_spawns"
        },

        Gibs = Zombies_Gibs_Bones,
        Gibs_heart_bone = "head",
        Enemy_Materials_Assets = {
            { -- First model
                body = {
                    "vzombies-assets::MI_TSZombie_Body_V1",
                    "vzombies-assets::MI_TSZombie_Body_V2",
                    "vzombies-assets::MI_TSZombie_Body_V3",
                },
                bottom = {
                    "vzombies-assets::MI_TSZombie_Bottom_V1",
                    "vzombies-assets::MI_TSZombie_Bottom_V2",
                    "vzombies-assets::MI_TSZombie_Bottom_V3",
                },
                top = {
                    "vzombies-assets::MI_TSZombie_Top_V1",
                    "vzombies-assets::MI_TSZombie_Top_V2",
                    "vzombies-assets::MI_TSZombie_Top_V3",
                    "vzombies-assets::MI_TSZombie_Top_V4",
                },
                hair = {
                    "vzombies-assets::MI_TSZombie_Hair",
                }
            },
        },

        Custom_Anims_Transform = {
            to_crawl = function(Custom_Anims_BP, char)
                Custom_Anims_BP:CallBlueprintEvent("SetZombieCrawl", char:GetID())
            end
        },

        Custom_Anims_Func = function(Custom_Anims_BP, char)
            char:AddActorTag("vzanimoverwrite")
            Custom_Anims_BP:CallBlueprintEvent("SetAnimBP", char:GetID(), char:GetValue("EnemyType") == "walk")
            if char:GetValue("EnemyType") == "crawl" then
                Custom_Anims_BP:CallBlueprintEvent("SetZombieCrawl", char:GetID())
            end
        end,
    },

    Hellhound = {
        Types = {
            hellhound = {
                GaitMode = GaitMode.Sprinting,
                Speed_Multiplier = 1.6,
                Bot_Aim_Offset = Vector(0, 0, -25),
                --[[Physical_Anim_Settings = {
                    {"root", true, false, 100000, 100000, 100000, 100000, 100000, 100000},
                },]]--
            },
        },

        Death_Sounds = RANDOM_SOUNDS.hell_death,
        Attack_Sounds = RANDOM_SOUNDS.hell_attack,

        Acceptance_Radius = 100,
        Damage_Amount = 20,
        Damage_At_Distance_sq = 27000,

        Collision_Radius = 20.0,
        --Collision_Height = 48,

        Health_Mult_By = 0.3, -- From basic health

        Models = {
            "vzombies-assets::SK_Wolf",
        },

        Attack_Anims = {
            {"vzombies-assets::ANIM_Wolf_Bite", 230, 700},
            {"vzombies-assets::ANIM_Wolf_JumpBite", 270, 850},
        },

        Spawning_Config = {
            type = "custom_spawns",
            table_name = "HELLHOUND_SPAWNS",
            room_key = "room",

            Number_To_Spawn_mult = 0.3, -- From basic number to spawn (zombies)
        },

        Custom_Anims_Func = function(Custom_Anims_BP, char)
            char:AddActorTag("vzanimoverwrite")
            Custom_Anims_BP:CallBlueprintEvent("SetHellhound")
        end,
    },

    Brutus = {
        Types = {
            brutus = {
                GaitMode = GaitMode.Sprinting,
                Speed_Multiplier = 1,
            },
        },

        Death_Sounds = RANDOM_SOUNDS.brutus_death,
        Attack_Sounds = RANDOM_SOUNDS.hell_attack,

        Boss = true,

        Acceptance_Radius = 120,
        Damage_Amount = 70,
        Damage_At_Distance_sq = 40000,

        Collision_Radius = 22.0,

        Health_Mult_By = 4,

        Models = {
            "vzombies-assets::pumpkinhulk_l_shaw",
        },
        --"Bloody Baseball Bat with Nails" (https://skfb.ly/6tRNz) by Sviatoslav Semenov is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).

        Attack_Anims = {
            {"vzombies-assets::Brutus_Attack", 770, 1550},
        },

        Spawning_Config = {
            type = "custom_spawns",
            table_name = "HELLHOUND_SPAWNS",
            room_key = "room",

            minimum_round_to_spawn = 10,
            spawn_chance_per_zombie = 2, -- out of 1000
        },

        Custom_Anims_Func = function(Custom_Anims_BP, char)
            char:AddActorTag("vzanimoverwrite")
            Custom_Anims_BP:CallBlueprintEvent("SetBrutus")
        end,
    },

    Napalm = {
        Types = {
            napalm = {
                GaitMode = GaitMode.Walking,
                Speed_Multiplier = 1.1,
            },
        },

        Behind_Sounds = RANDOM_SOUNDS.zombie_behind,
        Death_Sounds = RANDOM_SOUNDS.napalm_death,
        Attack_Sounds = RANDOM_SOUNDS.napalm_attack,

        Boss = true,

        Acceptance_Radius = 70,

        Damage_Amount = 100,
        Damage_At_Distance_sq = 23000,
        Damage_Barricade_Cooldown_ms = 3000,

        Collision_Radius = 17.0,

        Health_Mult_By = 3,

        Models = {
            "vzombies-assets::SK_Napalm",
        },

        Attack_Anims = {
            {"vzombies-assets::Napalm_Attack", 1160, 2500},
        },

        Spawning_Config = {
            type = "custom_spawns",
            table_name = "HELLHOUND_SPAWNS",
            room_key = "room",

            minimum_round_to_spawn = 10,
            spawn_chance_per_zombie = 2, -- out of 1000
        },

        Custom_Anims_Func = function(Custom_Anims_BP, char)
            char:AddActorTag("vzanimoverwrite")
            Custom_Anims_BP:CallBlueprintEvent("SetNapalm")
        end,
    },

    BusinessGraber = {

        Types = {
            walk = {
                GaitMode = GaitMode.Walking,
                Speed_Multiplier = 1.4,
                Vault_Anim = Vault_Animations.VaultOverBox,
                Ambient_Sounds = RANDOM_SOUNDS.zombie_soft,
            },
        },

        Behind_Sounds = RANDOM_SOUNDS.zombie_behind,
        Death_Sounds = RANDOM_SOUNDS.zombie_death,
        Attack_Sounds = RANDOM_SOUNDS.zombie_attack,

        Acceptance_Radius = 70, -- At which distance from the player they can hurt him

        Damage_Amount = 10,

        Damage_At_Distance_sq = 22000,
        Damage_Barricade_Cooldown_ms = 3000,
        Can_Damage_After_ms = 1000, -- They can damage after waiting this time after leaving barricade (false reach fix)

        Collision_Radius = 17.0,

        Health_Mult_By = 2,

        Boss = true,

        Models = {
            "vzombies-assets::SK_Zombie_M04_01",
            "vzombies-assets::SK_Zombie_M04_02",
            "vzombies-assets::SK_Zombie_M04_03",
            "vzombies-assets::SK_Zombie_M04_04",
            "vzombies-assets::SK_Zombie_M04_05",
            "vzombies-assets::SK_Zombie_M04_06",
            "vzombies-assets::SK_Zombie_M04_07",
            "vzombies-assets::SK_Zombie_M04_08",
        },

        Custom_Attack_Behavior = {
            type = "grab",
            Grab_Time_ms = 3500,
        },

        Spawning_Config = {
            type = "zombie_spawns",

            minimum_round_to_spawn = 8,
            spawn_chance_per_zombie = 2, -- out of 1000
        },

        Custom_Anims_Func = function(Custom_Anims_BP, char)
            char:AddActorTag("vzanimoverwrite")
            Custom_Anims_BP:CallBlueprintEvent("SetAnimBP", char:GetID(), char:GetValue("EnemyType") == "walk")
            if char:GetValue("EnemyType") == "crawl" then
                Custom_Anims_BP:CallBlueprintEvent("SetZombieCrawl", char:GetID())
            end
        end,
    },
}
Enemies_Config.BusinessGraber.Attack_Anims = {
    {"vzombies-assets::AS_NAAT_Zombie_Idle_To_Grab", 600, 1000 + Enemies_Config.BusinessGraber.Custom_Attack_Behavior.Grab_Time_ms},
}








Enemies_Config.UrbanZombie = TableDeepCopy(Enemies_Config.Zombie)
Enemies_Config.UrbanZombie.Models = {
    {
        asset = "vzombies-assets::SK_UrbanZombie_Body_A",
        materials_slots = {
            "body",
            "trousers",
        }
    },
}
Enemies_Config.UrbanZombie.Models[2] = TableDeepCopy(Enemies_Config.UrbanZombie.Models[1])
Enemies_Config.UrbanZombie.Models[2].asset = "vzombies-assets::SK_UrbanZombie_Body_B"
Enemies_Config.UrbanZombie.Enemy_Materials_Assets = {
    {
        body = {
            "vzombies-assets::MI_UrbanZombie_Body_V1",
            "vzombies-assets::MI_UrbanZombie_Body_V2",
            "vzombies-assets::MI_UrbanZombie_Body_V3",
            "vzombies-assets::MI_UrbanZombie_Body_V4",
            "vzombies-assets::MI_UrbanZombie_Body_V5",
        },
        trousers = {
            "vzombies-assets::MI_UrbanZombie_Trousers_V1",
            "vzombies-assets::MI_UrbanZombie_Trousers_V2",
            "vzombies-assets::MI_UrbanZombie_Trousers_V3",
            "vzombies-assets::MI_UrbanZombie_Trousers_V4",
        }
    },
}
Enemies_Config.UrbanZombie.Enemy_Materials_Assets[2] = Enemies_Config.UrbanZombie.Enemy_Materials_Assets[1]
Enemies_Config.UrbanZombie.Gibs = {
    foot_l = {
        health_p = 10,
        asset = "vzombies-assets::U_FootL",
        materials = {
            "trousers",
            "body",
        },
    },
    foot_r = {
        health_p = 10,
        asset = "vzombies-assets::U_FootR",
        materials = {
            "trousers",
            "body",
        },
    },
    lowerarm_l = {
        health_p = 30,
        asset = "vzombies-assets::U_ForeArmL",
        Detach = {
            "hand_l",
        },
        materials = {
            "body",
        },
    },
    lowerarm_r = {
        health_p = 30,
        asset = "vzombies-assets::U_ForeArmR",
        Detach = {
            "hand_r",
        },
        materials = {
            "body",
        },
    },
    hand_l = {
        health_p = 10,
        asset = "vzombies-assets::U_HandL",
        materials = {
            "body",
        },
    },
    hand_r = {
        health_p = 10,
        asset = "vzombies-assets::U_HandR",
        materials = {
            "body",
        },
    },
    upperarm_l = {
        health_p = 50,
        asset = "vzombies-assets::U_ArmL",
        Detach = {
            "lowerarm_l",
        },
        materials = {
            "body",
        },
    },
    upperarm_r = {
        health_p = 50,
        asset = "vzombies-assets::U_ArmR",
        Detach = {
            "lowerarm_r",
        },
        materials = {
            "body",
        },
    },
    head = {
        health_p = 80,
        asset = {"vzombies-assets::U_HeadA", "vzombies-assets::U_HeadB"},
        materials = {
            "body",
        },
    },
    calf_l = {
        health_p = 30,
        asset = "vzombies-assets::U_KneeL",
        Detach = {
            "foot_l",
        },
        materials = {
            "trousers",
            "body",
        },
    },
    calf_r = {
        health_p = 30,
        asset = "vzombies-assets::U_KneeR",
        Detach = {
            "foot_r",
        },
        materials = {
            "trousers",
            "body",
        },
    },
    thigh_l = {
        health_p = 50,
        asset = "vzombies-assets::U_LegL",
        Detach = {
            "calf_l",
        },
        materials = {
            "trousers",
            "body",
        },
    },
    thigh_r = {
        health_p = 50,
        asset = "vzombies-assets::U_LegR",
        Detach = {
            "calf_r",
        },
        materials = {
            "trousers",
            "body",
        },
    },
}

Enemies_Config.HoodieZombie = TableDeepCopy(Enemies_Config.UrbanZombie)
Enemies_Config.HoodieZombie.Models = {
    {
        asset = "vzombies-assets::SK_Urban_Zombie_Hoodie_A",
        materials_slots = {
            "body",
            "hoodie",
            "trousers",
        },
    }
}
Enemies_Config.HoodieZombie.Models[2] = TableDeepCopy(Enemies_Config.HoodieZombie.Models[1])
Enemies_Config.HoodieZombie.Models[2].asset = "vzombies-assets::SK_Urban_Zombie_Hoodie_B"
Enemies_Config.HoodieZombie.Enemy_Materials_Assets[1].hoodie = {
    "vzombies-assets::MI_UrbanZombie_Hoodie_V1",
    "vzombies-assets::MI_UrbanZombie_Hoodie_V2",
    "vzombies-assets::MI_UrbanZombie_Hoodie_V3",
    "vzombies-assets::MI_UrbanZombie_Hoodie_V4",
}
Enemies_Config.HoodieZombie.Enemy_Materials_Assets[2] = Enemies_Config.HoodieZombie.Enemy_Materials_Assets[1]

Enemies_Config.HoodieZombie.Gibs.lowerarm_l = {
    health_p = 30,
    asset = "vzombies-assets::U_HoodieForeArmL",
    Detach = {
        "hand_l",
    },
    materials = {
        "hoodie",
        "body",
    },
}
Enemies_Config.HoodieZombie.Gibs.lowerarm_r = {
    health_p = 30,
    asset = "vzombies-assets::U_HoodieForeArmR",
    Detach = {
        "hand_r",
    },
    materials = {
        "hoodie",
        "body",
    },
}
Enemies_Config.HoodieZombie.Gibs.upperarm_l = {
    health_p = 50,
    asset = "vzombies-assets::U_HoodieArmL",
    Detach = {
        "lowerarm_l",
    },
    materials = {
        "hoodie",
        "body",
    },
}
Enemies_Config.HoodieZombie.Gibs.upperarm_r = {
    health_p = 50,
    asset = "vzombies-assets::U_HoodieArmR",
    Detach = {
        "lowerarm_r",
    },
    materials = {
        "hoodie",
        "body",
    },
}

Enemies_Config.TankTopZombie = TableDeepCopy(Enemies_Config.UrbanZombie)
Enemies_Config.TankTopZombie.Models = {
    {
        asset = "vzombies-assets::SK_Urban_Zombie_TankTop_A",
        materials_slots = {
            "body",
            "trousers",
            "trousers",
            "body",
            "tanktop",
        },
    }
}
Enemies_Config.TankTopZombie.Models[2] = TableDeepCopy(Enemies_Config.TankTopZombie.Models[1])
Enemies_Config.TankTopZombie.Models[2].asset = "vzombies-assets::SK_Urban_Zombie_TankTop_B"
Enemies_Config.TankTopZombie.Enemy_Materials_Assets[1].tanktop = {
    "vzombies-assets::MI_UrbanZombie_TankTop_V1",
    "vzombies-assets::MI_UrbanZombie_TankTop_V2",
    "vzombies-assets::MI_UrbanZombie_TankTop_V3",
    "vzombies-assets::MI_UrbanZombie_TankTop_V4",
}
Enemies_Config.TankTopZombie.Enemy_Materials_Assets[2] = Enemies_Config.TankTopZombie.Enemy_Materials_Assets[1]

Napalm_Fire_Radius_sq = 1000000
Napalm_Fire_Damage = 5
Napalm_Fire_Damage_Interval = 1500
Napalm_Explosion_Damage = {150, 0, 150, 1000, 1} -- Grenade SetDamage parameters