
ZDEV_CONFIG = {
    ENABLED = false,
    DEV_MODES = {
        ZDEV_COMMANDS = true,
        ZDEV_DEBUG_TRACES = false,
        ZDEV_GODMODE = true,
        ZDEV_INFINITE_GRENADES = true,
        ZDEV_DEBUG_TRIGGERS = true,
        ZDEV_DEBUG_HIGHLIGHT_ZOMBIES = false,
        ZDEV_DEBUG_BOTS_MOVEMENT = false,
        ZDEV_DEBUG_BOTS_SHOOT = false,
        ZDEV_DEBUG_BOTS_FLEE = false,
        ZDEV_INFINITE_MONEY = true,
        ZDEV_DEBUG_ZOMBIES_SPAWNS = false,
        ZDEV_DEBUG_FUNCTION_CALLS = false,
        ZDEV_DEBUG_INTERACT = false,
        ZDEV_DEBUG_ENEMIES_PREDICTION = false,
    }
}

VZ_SELECTED_GAMEMODE = "SURVIVAL"

VZ_GAMEMODES_CONFIG = {
    SURVIVAL = {},


    SHARPSHOOTER = {
        Scripts = {
            Server = {
                "SubModes/Sharpshooter/Sharpshooter.lua",
            },
        },
        Config = {
            Weapon_Change_Interval_ms = 60000,
            Weapon_Ammo_Bag = 1000,
        },
        Powerups_Overwrite = {
            "carpenter",
            "nuke",
            "instakill",
            "x2"
        },
        overwrites = {
            MysteryBox = {
                can_interact = false,
            },
            Pack_a_punch = {
                can_interact = false,
            },
            Map_Weapons = {
                spawned = false,
                can_interact = false,
            },
            Revive = {
                can_interact = false,
            },
        },
    },


    INVISIBLE_ZOMBIES = {
        Scripts = {
            Server = {
                "SubModes/Invisible_Zombies/Invisible_Zombies.lua",
            },
        },
    },


    GUNGAME = {
        Scripts = {
            Server = {
                "SubModes/GunGame/GunGame.lua",
            },
            Client = {
                "SubModes/GunGame/cl_GunGame.lua",
            },
        },
        Config = {
            Weapon_Ammo_Bag = 10000,
            Kills_To_Next_Weapon = 20,
        },
        Powerups_Overwrite = {
            "carpenter",
            "nuke",
            "instakill",
            "x2"
        },
        overwrites = {
            MysteryBox = {
                can_interact = false,
            },
            Pack_a_punch = {
                can_interact = false,
            },
            Map_Weapons = {
                spawned = false,
                can_interact = false,
            },
        },
    },


    KILLJOY = {
        Scripts = {
            Server = {
                "SubModes/Killjoy/Killjoy.lua",
            },
            Client = {
                "SubModes/Killjoy/cl_Killjoy.lua",
            },
        },
        Config = {
            Killjoy_Minimum_Zombies_To_Activate = 80,
            Killjoy_Base_Health_Given = 350,
            Killjoy_Health_mult_per_kill = 1.005,

            Killjoy_Base_Weapon_Damage = 80,
            Killjoy_Weapon_Damage_mult_per_kill = 1.003,

            Killjoy_Weapon = function()
                local melee = Melee(location or Vector(), rotation or Rotator(), "nanos-world::SM_Shovel_01", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
                melee:SetAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Slash_Attack")
                melee:SetDamageSettings(0.3, 0.5)
                melee:SetCooldown(1)

                return melee
            end,
        },
    },
}

VZ_GLOBAL_FEATURES = {
    MysteryBox = {
        script_loaded = true,
        can_interact = true,
        reset_func = "ResetMysteryBoxes",
        start_new_game_func = "PickNewMysteryBox",
    },
    Pack_a_punch = {
        script_loaded = true,
        can_interact = true,
        reset_func = "ResetPAP",
    },
    Perks = {
        script_loaded = true,
        can_interact = true,
        start_new_game_func = "SpawnMapPerks",
        destroy_func = "DestroyMapPerks",
    },
    Wunderfizz = {
        script_loaded = true,
        can_interact = true,
        reset_func = "ResetWunderfizzes",
        start_new_game_func = "PickNewWunderfizz",
    },
    Map_Weapons = {
        spawned = true,
        can_interact = true,
    },
    Teleporters = {
        script_loaded = true,
        can_interact = true,
        start_new_game_func = "CreateMapTeleporters",
        destroy_func = "DestroyMapTeleporters",
    },
    Barricades = {
        can_interact = true,
        start_new_game_func = "SpawnMapBarricades",
        destroy_func = "DestroyBarricades",
    },
    Revive = {
        can_interact = true,
    },
}

SKY_TIME = {3, 0} -- hours, min

Weapons_Ammo_Price_Percentage = 50
Weapons_Dropped_Destroyed_After_ms = 60000

Map_Z_Limits_Check_Interval_ms = 20000

Send_Errors_To_Server = true

Auto_Set_Server_MaxPlayers = true

--------------------------------------------------------------------------------------------------------------
-- Player Config

CAMERA_MODE = CameraMode.FPSOnly

Player_Start_Weapon = {
    weapon_name = "M1911",
    ammo = 100
}
PlayerHealth = 100

PlayerRegenHealthAfter_ms = 15000
PlayerRegenInterval_ms = 500
PlayerRegenAddedHealth = 10

PlayerSpeedMultiplier = 1.5

PlayerDeadAfterTimerDown_ms = 30000
ReviveTime_ms = 5000

Player_Model = "nanos-world::SK_Mannequin"
Player_Model_Random_Color = true

--------------------------------------------------------------------------------------------------------------------------------
-- Rounds Config

WaveInterval_ms = 20000
GameOverInterval_ms = 30000

Can_Host_Pause_Game = true

Hellhounds_Each_x_Rounds = 6 -- Put 0 to disable, only on maps that supports it

-------------------------------------------------------------------------------------------------------------
-- Interact Config

Interact_Text_Y_Offset = 200

Doors_Interact_Check_Interval_ms = 500
Doors_Interact_Check_Trace_Distance_Max = 175

Barricades_Interact_Check_Interval_ms = 500
Barricades_Interact_Check_Distance_Squared_Max = 22500
Repair_Barricade_Interval_ms = 1750

DownPlayer_Interact_Check_Interval_ms = 500
DownPlayer_Interact_Check_Distance_Squared_Max = 22500

MBOX_Interact_Check_Interval_ms = 500
MBOX_Interact_Check_Distance_Squared_Max = 22500

POWER_Interact_Check_Interval_ms = 500
POWER_Interact_Check_Distance_Squared_Max = 40000

Perk_Interact_Check_Interval_ms = 500
Perk_Interact_Check_Distance_Squared_Max = 40000

PAP_Interact_Check_Interval_ms = 500
PAP_Interact_Check_Distance_Squared_Max = 40000

Wunderfizz_Interact_Check_Interval_ms = 500
Wunderfizz_Interact_Check_Distance_Squared_Max = 40000

Wunderfizz_Bottle_Interact_Check_Interval_ms = 500
Wunderfizz_Bottle_Interact_Check_Distance_Squared_Max = 35000

Custom_Interact_Check_Interval_ms = 500

Teleporters_Interact_Check_Interval_ms = 500

Gibs_Interact_Check_Interval_ms = 500
Gibs_Interact_Check_Distance_Squared_Max = 14400

----------------------------------------------------------------------------------------------------------
-- Money Config
Player_Start_Money = 500

Down_MoneyLost = 10 -- percentage
Dead_MoneyLost = 50 -- percentage

Player_Zombie_Damage_Money = 10
Player_Zombie_Kill_Money = 50
Player_Zombie_Kill_Knife_Money = 100

Player_Repair_Barricade_Money = 10
Player_Revive_Money = 100

--------------------------------------------------------------------------------------------------------------
-- GUI Config

How_To_Play_Text_Destroy_ms = 5000

Remaining_Enemies_Text = true

Player_Names_On_Heads = true
Player_Name_Displayed_at_dist_sq = 1440000
Player_Names_On_Heads_Canvas_Update_Interval_ms = 100

Player_To_Revive_image = "package://" .. Package.GetPath() .. "/Client/gui/images/to_revive.png"
To_Revive_Billboard_Relative_Location = Vector(0, 0, 100)

Game_Time_On_Screen = true
Game_Time_Canvas_Update_Interval_ms = 1000

Ping_Canvas_Update_Interval_ms = 30

Chat_Config = {Vector2D(-175, 0), Vector2D(400, 300), Vector2D(1, 0.75), Vector2D(1, 0.75), Vector2D(1, 0.75), true, true}

-----------------------------------------------------------------------------------------------------------
-- SOUNDS Config

RANDOM_SOUNDS = {
    barricade_slam = {
        base_ref = "vzombies-assets::slam_",
        random_start = 0,
        random_to = 5,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    zombie_attack = {
        base_ref = "vzombies-assets::attack_",
        random_start = 0,
        random_to = 15,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    hell_attack = {
        base_ref = "vzombies-assets::hell_attack_",
        random_start = 0,
        random_to = 6,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    brutus_attack = {
        base_ref = "vzombies-assets::brutus_swing_",
        random_start = 0,
        random_to = 4,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    zombie_death = {
        base_ref = "vzombies-assets::death_",
        random_start = 0,
        random_to = 10,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    brutus_death = {
        unique_sound = "vzombies-assets::Brutus_death",
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    hell_death = {
        base_ref = "vzombies-assets::hell_death_",
        random_start = 0,
        random_to = 6,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    barricade_snap = {
        base_ref = "vzombies-assets::snap_",
        random_start = 0,
        random_to = 5,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    barricade_break = {
        base_ref = "vzombies-assets::zmb_break_board_",
        random_start = 0,
        random_to = 5,
        always_digits = 2,
        volume = 0.6,
        radius = 400,
        falloff_distance = 2000,
    },
    zombie_behind = {
        base_ref = "vzombies-assets::behind_",
        random_start = 0,
        random_to = 4,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    zombie_soft = {
        base_ref = "vzombies-assets::soft_",
        random_start = 0,
        random_to = 5,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 4000,
    },
    zombie_sprint = {
        base_ref = "vzombies-assets::sprint_",
        random_start = 0,
        random_to = 8,
        always_digits = 2,
        volume = 1,
        radius = 500,
        falloff_distance = 4000,
    },
    zombie_crawl = {
        base_ref = "vzombies-assets::crawl_",
        random_start = 0,
        random_to = 5,
        always_digits = 2,
        volume = 1,
        radius = 350,
        falloff_distance = 3500,
    },
    zombie_hit_player = {
        base_ref = "vzombies-assets::zombie_hit_player_",
        random_start = 0,
        random_to = 5,
        always_digits = 2,
        volume = 1,
    },
    wunderfizz_impact = {
        base_ref = "vzombies-assets::random_perk_imp_",
        random_start = 0,
        random_to = 2,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2500,
    },
    spawn_dirt_sound = {
        base_ref = "vzombies-assets::spawn_dirt_",
        random_start = 0,
        random_to = 1,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2500,
    },
    napalm_death = {
        unique_sound = "vzombies-assets::Napalm_Death",
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    napalm_attack = {
        base_ref = "vzombies-assets::Napalm_Attack_",
        random_start = 0,
        random_to = 4,
        always_digits = 2,
        volume = 1,
        radius = 400,
        falloff_distance = 2000,
    },
    napalm_fire_sound = {
        base_ref = "vzombies-assets::Napalm_Fire_",
        random_start = 0,
        random_to = 5,
        always_digits = 2,
        volume = 1,
    },
}

NewWave_Sound = {
    asset = "vzombies-assets::mus_zombie_round_start",
    volume = 1,
}

Hellhound_Start_Sound = {
    asset = "vzombies-assets::dog_start",
    volume = 1,
}

WaveFinished_Sound = {
    asset = "vzombies-assets::mus_zombie_round_over",
    volume = 1,
}

Buy_Sound = {
    asset = "vzombies-assets::buy_accept",
    volume = 1,
}

Mbox_Changed_Sound = {
    asset = "vzombies-assets::mbox_child",
    volume = 1,
}

Barricade_Repair_Sound = {
    asset = "vzombies-assets::barricade_repair",
    volume = 1,
}

GameOver_Sound = {
    asset = "vzombies-assets::mx_game_over",
    volume = 0.6,
}

DownLoop_Sound = {
    asset = "vzombies-assets::laststand_loop",
    volume = 1.5,
}

OpenMBOX_Sound = {
    asset = "vzombies-assets::mbox_open",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

MBOX_Sound = {
    asset = "vzombies-assets::mbox_music_box",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

Powerup_Spawn_Sound = {
    asset = "vzombies-assets::p_spawn",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

Powerup_Loop_Sound = {
    asset = "vzombies-assets::p_loop",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

Powerup_Grab_Sound = {
    asset = "vzombies-assets::grab",
    volume = 1,
}

Carpenter_Sound = {
    asset = "vzombies-assets::carpiter",
    volume = 1,
}

MaxAmmo_Sound = {
    asset = "vzombies-assets::maxammo",
    volume = 1,
}

Nuke_Sound = {
    asset = "vzombies-assets::nuke",
    volume = 1,
}

Instakill_Sound = {
    asset = "vzombies-assets::instakill",
    volume = 1,
}

x2_Sound = {
    asset = "vzombies-assets::x2",
    volume = 1,
}

death_machine_Sound = {
    asset = "vzombies-assets::Death_Machine",
    volume = 1,
}

PowerOn_Sound = {
    asset = "vzombies-assets::power_on",
    volume = 1,
}

PowerOn3D_Sound = {
    asset = "vzombies-assets::power_on_3D",
    volume = 0.8,
    radius = 400,
    falloff_distance = 2500,
}

NewPerk_Sound = {
    asset = "vzombies-assets::drink_perk_rrr",
    volume = 1,
}

PAP_Upgrade_Sound = {
    asset = "vzombies-assets::pap_upgrade",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

PAP_Ready_Sound = {
    asset = "vzombies-assets::pap_ready",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

Zombie_Behind_Sound_Trigger_Config = {
    Interval_ms = 1000,
    Cooldown_ms = 19000,
    max_distance_sq = 810000,
    Rel_Rot_Between = {-70, 70},
    max_z_dist = 200,
}

Zombie_Amb_Sounds = {
    Interval_ms = 1000,
    Cooldown_ms = 10000
}

LastStand_Enter_Sound = {
    asset = "vzombies-assets::laststand_enter",
    volume = 1,
}

LastStand_Exit_Sound = {
    asset = "vzombies-assets::laststand_exit",
    volume = 1,
}

LowHealth_Loop_Sound = {
    asset = "vzombies-assets::lowhealth_lp",
    volume = 1,
}

LowHealth_Enter_Sound = {
    asset = "vzombies-assets::lowhealth_enter",
    volume = 1,
}

LowHealth_Exit_Sound = {
    asset = "vzombies-assets::lowhealth_exit",
    volume = 1,
}

LowHealth_Trigger_Health = 50 -- When health is <= of this value

Wunderfizz_leave_Sound = {
    asset = "vzombies-assets::rand_perk_mach_leave",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

Pack_A_Punch_Amb_Sound = {
    asset = "vzombies-assets::mus_packapunch_jingle",
    volume = 1,
    radius = 200,
    falloff_distance = 1500,
}

Wunderfizz_loop_Sound = {
    asset = "vzombies-assets::rand_perk_mach_loop",
    volume = 0.5,
    radius = 400,
    falloff_distance = 2500,
}

Wunderfizz_vortex_Sound = {
    asset = "vzombies-assets::wunder_vortex_loop",
    volume = 0.5,
    radius = 400,
    falloff_distance = 2500,
}

Wunderfizz_stop_Sound = {
    asset = "vzombies-assets::rand_perk_mach_stop",
    volume = 0.5,
    radius = 400,
    falloff_distance = 2500,
}

Barricade_Start_Repair = {
    asset = "vzombies-assets::barricade_start_repair",
    volume = 1,
}

Player_Teleport_Sound = {
    asset = "vzombies-assets::teleport_plr",
    volume = 1,
}

Napalm_Fire_Ambient_Sound = {
    asset = "vzombies-assets::Napalm_Fire",
    volume = 1,
    radius = 400,
    falloff_distance = 2500,
}

----------------------------------------------------------------------------------------------------------
-- ENEMIES CONFIG

First_Wave_Enemies = 5
Add_at_each_wave = 1
Add_at_each_wave_per_player = 1 -- number of zombies added at each wave per playing player
Zombies_Number_Mult = 2 -- The calculated number of zombies is multiplied by this

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

Enemies_Spawn_Cooldown = 60000 -- All the wave enemies will be spawned (if it doesn't reach the limit) after this time
Enemies_Spawn_Interval_min_time_ms = 500

DestroyEnemy_After_death_ms = 20000

Max_enemies_spawned = 30

Enemy_Route_Update_ms = 100
Enemy_Look_At_Update_ms = 300

Enemies_Target_Refresh_ms = 2500

Enemies_Ragdoll_Get_Up_Timeout_ms = 10000

Enemies_Check_Can_Damage_Interval_ms = 1000
Enemies_Damage_Prediction_Div = 2.5


Enemies_Stuck_DistanceSq = 4
Enemies_Stuck_Check_Each_ms = 2500
Enemies_Stuck_Respawn_After_x_Stuck = 8 -- Respawns after x times his location was flagged as same, resets when he reaches his target

Enemies_Ground_Dirt_Scale = Vector(5, 5, 5)

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

-- Some access to variables are hardcoded so adding more keys to other enemies could just do nothing, like the FirstWave key
Enemies_Config = {
    Zombie = {

        FirstWave = {
            walk = 100,
        },

        Added_Per_Wave_Percentage = {
            run = 7,
        },

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
            },
        },

        Behind_Sounds = RANDOM_SOUNDS.zombie_behind,
        Death_Sounds = RANDOM_SOUNDS.zombie_death,
        Attack_Sounds = RANDOM_SOUNDS.zombie_attack,

        Acceptance_Radius = 70, -- At which distance from the player they can hurt him

        Damage_Amount = 30,
        Damage_At_Distance_sq = 23000,
        Damage_Barricade_Cooldown_ms = 3000,
        Damage_Cooldown_ms = 1350,
        Can_Damage_After_ms = 1000, -- They can damage after waiting this time after leaving barricade (false reach fix)

        Collision_Radius = 17.0,

        Joker_Chance = 5, -- x amount TakeDamage will lead to joker for 10000 shots

        Models = {
            "vzombies-assets::SK_TSZombie",
            "vzombies-assets::SK_TSZombie2",
            "vzombies-assets::SK_TSZombie3",
            "vzombies-assets::SK_TSZombie4",
        },

        Attack_Anims = {
            {"vzombies-assets::Zombie_Atk_Cut_1", 150},
            {"vzombies-assets::Zombie_Atk_Cut_2", 280},
            {"vzombies-assets::Zombie_Atk_Cut_3", 400},
            {"vzombies-assets::ZombieAttack", 730},
            {"vzombies-assets::ZombieAttack2", 530},
        },

        Spawning_Config = {
            type = "zombie_spawns"
        },

        Gibs = Zombies_Gibs_Bones,
        Gibs_heart_bone = "head",
        Enemy_Materials_Assets = {
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
        Models_Materials = {
            SK_TSZombie = {
                body = 1,
                bottom = 1,
                top = 1,
                hair = 1,
            },
            SK_TSZombie2 = {
                body = 2,
                bottom = 2,
                top = 2,
                hair = 1,
            },
            SK_TSZombie3 = {
                body = 3,
                bottom = 3,
                top = 3,
                hair = 1,
            },
            SK_TSZombie4 = {
                body = 1,
                bottom = 2,
                top = 4,
                hair = 1,
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
            },
        },

        Death_Sounds = RANDOM_SOUNDS.hell_death,
        Attack_Sounds = RANDOM_SOUNDS.hell_attack,

        Acceptance_Radius = 100,
        Damage_Amount = 20,
        Damage_At_Distance_sq = 27000,
        Damage_Cooldown_ms = 1500,

        Collision_Radius = 20.0,
        --Collision_Height = 48,

        Health_Mult_By = 0.3, -- From basic health

        Models = {
            "vzombies-assets::SK_Wolf",
        },

        Attack_Anims = {
            {"vzombies-assets::ANIM_Wolf_Bite", 230},
            {"vzombies-assets::ANIM_Wolf_JumpBite", 270},
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
        Damage_Cooldown_ms = 1600,

        Collision_Radius = 22.0,

        Health_Mult_By = 4,

        Models = {
            "vzombies-assets::pumpkinhulk_l_shaw",
        },
        --"Bloody Baseball Bat with Nails" (https://skfb.ly/6tRNz) by Sviatoslav Semenov is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).

        Attack_Anims = {
            {"vzombies-assets::Brutus_Attack", 770},
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
        Damage_Cooldown_ms = 2000,

        Collision_Radius = 17.0,

        Health_Mult_By = 3,

        Models = {
            "vzombies-assets::SK_Napalm",
        },

        Attack_Anims = {
            {"vzombies-assets::Napalm_Attack", 1160},
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
}

Napalm_Fire_Radius_sq = 1000000
Napalm_Fire_Damage = 5
Napalm_Fire_Damage_Interval = 1500
Napalm_Explosion_Damage = {150, 0, 150, 1000, 1} -- Grenade SetDamage parameters

------------------------------------------------------------------------------------------------------------
-- MYSTERY BOX CONFIG
Mystery_box_price = 950

Mystery_box_weapon_time = 4.4
Mystery_box_weapon_time_reverse = 6
Mystery_box_translate_exp = 0

Mystery_box_fake_weapon_interval_ms = 250
Mystery_box_weapon_spawn_offset_z = 50
Mystery_box_weapon_target_offset_z = 100 -- box z + Mystery_box_weapon_target_offset_z target

NewMysteryBox_Timeout_ms = 3000

Active_MysteryBox_Particle = {
    path = "vzombies-assets::P_Launch",
    scale = Vector(0.5, 0.5, 0.5),
    relative_location = Vector(0, 0, 320),
}

Mystery_box_weapons = {
    {
        weapon_name = "AK47",
        max_ammo = 400,
    },
    {
        weapon_name = "AK74U",
        max_ammo = 400,
    },
    {
        weapon_name = "AK5C",
        max_ammo = 400,
    },
    {
        weapon_name = "AR4",
        max_ammo = 400,
    },
    {
        weapon_name = "ASVal",
        max_ammo = 300,
    },
    {
        weapon_name = "GE3",
        max_ammo = 400,
    },
    {
        weapon_name = "GE36",
        max_ammo = 400,
    },
    {
        weapon_name = "SA80",
        max_ammo = 400,
    },
    {
        weapon_name = "AP5",
        max_ammo = 300,
    },
    {
        weapon_name = "P90",
        max_ammo = 300,
    },
    {
        weapon_name = "SMG11",
        max_ammo = 300,
    },
    {
        weapon_name = "UMP45",
        max_ammo = 300,
    },
    {
        weapon_name = "DesertEagle",
        max_ammo = 200,
    },
    {
        weapon_name = "Glock",
        max_ammo = 200,
    },
    {
        weapon_name = "Makarov",
        max_ammo = 200,
    },
    {
        weapon_name = "Ithaca37",
        max_ammo = 100,
    },
    {
        weapon_name = "Moss500",
        max_ammo = 100,
    },
    {
        weapon_name = "Rem870",
        max_ammo = 100,
    },
    {
        weapon_name = "SPAS12",
        max_ammo = 100,
    },
    {
        weapon_name = "AWP",
        max_ammo = 100,
    },
    {
        weapon_name = "M1Garand",
        max_ammo = 200,
    },
    {
        weapon_name = "Lewis",
        max_ammo = 400,
    },
    {
        weapon_name = "ColtPython",
        max_ammo = 100,
    },
}

------------------------------------------------------------------------------------------
-- PERKS CONFIG

PERKS_CONFIG = {
    juggernog = {
        price = 2500,
        PlayerHealth = 250,
        Asset = "vzombies-assets::juggernog",
        scale = Vector(1.5, 1.5, 1.5),
        bottle_asset = "vzombies-assets::jugg_bottle",
        icon = "images/Juggernog_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_jugganog_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    quick_revive = {
        price = 1500,
        ReviveTime_ms = 2500,
        Asset = "vzombies-assets::revive",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::revive_bottle",
        icon = "images/Quick_Revive_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_revive_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    doubletap = {
        price = 2000,
        MultDamage = 1.33,
        Asset = "vzombies-assets::doubletap",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::doubletap_bottle",
        icon = "images/Doubletap_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_doubletap_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    three_gun = {
        price = 4000,
        Asset = "vzombies-assets::three_gun",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::three_gun_bottle",
        icon = "images/three_gun_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_mulekick_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    stamin_up = {
        price = 2000,
        Speed_Multiplier = 1.6,
        Asset = "vzombies-assets::stamin_up",
        scale = Vector(1, 1, 1),
        bottle_asset = "vzombies-assets::stamin_up_bottle",
        icon = "images/StaminUp_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_stamin_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    speed_cola = {
        price = 3000,
        Reload_Speed_Timescale = 1.3,
        Asset = "vzombies-assets::speed_cola",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::speed_cola_bottle",
        icon = "images/speed_cola_icon_fix.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_speed_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
}


Prone_Perk_Config = {
    enabled = true,
    money = 100,
    Rel_Rot_Between = {60, 120},
    Max_Distance_sq = 40000,
}


------------------------------------------------------------------------------------------------------------
-- Barricades Config

Barricades_Config = {
    top = {
        {
            rlocation = Vector(0.0, 0.0, 0.0),
            rrotation = Rotator(43.200119, 0, -90),
        },
        {
            rlocation = Vector(1.380162, 2.0, 15.16889),
            rrotation = Rotator(-17, 0, -90),
        },
        {
            rlocation = Vector(0.431459, 2.0, 37.039181),
            rrotation = Rotator(3.600425, 0, -90),
        },
        {
            rlocation = Vector(-3.838795, 4.0, -30.826599),
            rrotation = Rotator(3.600425, 0, -90),
        },
        {
            rlocation = Vector(-2.206051, 5.999997, -4.87792),
            rrotation = Rotator(35.999931, 180, 90),
        },
    },
    ground_root = {
        rrotation = Rotator(0, 110, 0),
    },
    ground = {
        {
            rlocation = Vector(0.0, 0.0, 0.0),
            rrotation = Rotator(0, 110, 0),
        },
        {
            rlocation = Vector(-2.018615, 17.085821, 4.0),
            rrotation = Rotator(3.6, -8, 0),
        },
        {
            rlocation = Vector(22.961943, 17.613297, 4.849293),
            rrotation = Rotator(2, -128, 0),
        },
        {
            rlocation = Vector(4.832057, -3.945788, 7.806882),
            rrotation = Rotator(178.0, 135.19993, 0),
        },
        {
            rlocation = Vector(5.943773, 16.603304, 8.924857),
            rrotation = Rotator(178.0, -164, 0),
        },
    },
}

-------------------------------------------------------------------------------------------------------------
-- Powerups Config

Powerup_Check_Grab_Interval_ms = 200
Powerup_Grab_Distance_Squared = 5625

Powerup_Delete_after_ms = 20000

Powerups_particle_path = "vzombies-assets::PS_Powerup"

Powerup_Spawn_Percentage = 2 -- x powerups for 100 zombies killed

Powerups_Names = {
    "carpenter",
    "max_ammo",
    "nuke",
    "instakill",
    "x2",
    "death_machine",
}

Powerups_Config = {
    carpenter = {
        repair_interval_ms = 500,
        money_won = 200,
        sound = Carpenter_Sound,
        SM_Path = "vzombies-assets::carpenter",
    },
    max_ammo = {
        sound = MaxAmmo_Sound,
        SM_Path = "vzombies-assets::max_ammo",
    },
    nuke = {
        money_won = 400,
        sound = Nuke_Sound,
        SM_Path = "vzombies-assets::nuke",
    },
    instakill = {
        duration = 30000,
        sound = Instakill_Sound,
        icon = "images/instakill_icon.png",
        SM_Path = "vzombies-assets::instakill",
    },
    x2 = {
        duration = 30000,
        sound = x2_Sound,
        icon = "images/x2_icon_fixed.png",
        SM_Path = "vzombies-assets::x2",
    },
    death_machine = {
        duration = 30000,
        minigun_weapon_name = "modern_weapons Minigun",
        minigun_clip = 10000,
        sound = death_machine_Sound,
        icon = "images/death_machine_icon.png",
        SM_Path = "vzombies-assets::minigun",
    },
}

-------------------------------------------------------------------------------------------------
-- Pack a punch config

Pack_a_punch_damage_mult = 1.5

Pack_a_punch_price = 5000

Pack_a_punch_upgrade_time_ms = 3500

Pack_a_punch_destroy_weapon_time_ms = 20000

Pack_a_punch_weapon_material = "vzombies-assets::M_Pack_a_punch"
Pack_a_punch_weapon_material_index = -1

-------------------------------------------------------------------------------------------------------------------
-- Server Description Config

Dynamic_Server_Description = true

DSD_In_Game_Text = {"Gamemode like COD:Zombies, Current wave : ", ", Join to help"} -- Wave number in the middle
DSD_Idle_Text = "Gamemode like COD:Zombies, Waiting for players"

--------------------------------------------------------------------------------------------------------------------
-- Grenades Config

Start_Grenades_NB = 2
Max_Grenades_NB = 4

Grenade_TimeToExplode = 5
Grenade_Damage_Config = {200, 0, 200, 1000, 1} -- See : https://docs.nanos.world/docs/next/scripting-reference/classes/grenade#-setdamage

---------------------------------------------------------------------------------------------------------------------
-- Wonderfizz Config

Wonderfizz_Price = 1500
Wonderfizz_Fake_Bottle_Interval_ms = 300
Wonderfizz_Real_Bottle_After_ms = 5000
Wonderfizz_Real_Bottle_Destroyed_After_ms = 10000
Wonderfizz_Move_Percentage = 7
Wonderfizz_Bottles_Offset = Vector(0, 0, 130)

Wonderfizz_Particle = "vzombies-assets::P_ky_cutter1"
Wonderfizz_Particle_Offset = Vector(0, 0, 115)

--------------------------------------------------------------------------------------------------------------------------------------------
-- Knife Config

Knife_Base_Damage = 40
Knife_Cooldown_ms = 2000
Knife_Switch_ms = 1500

-------------------------------------------------------------------------------------------------------------------------------------
-- Flashlights config

FLight_Config = {
    5, -- Intensity
    8000, -- Attenuation Radius
    31, -- Cone Angle (Relevant only for Spot light type)
    0, -- Inner Cone Angle Percent (Relevant only for Spot light type)
    35000, -- Max Draw Distance (Good for performance - 0 for infinite)
    true, -- Whether to use physically based inverse squared distance falloff, where Attenuation Radius is only clamping the light's contribution. (Spot and Point types only)
    true, -- Cast Shadows?
    true -- Enabled?
}

FLight_Profile = LightProfile.Shattered_05


---------------------------------------------------------------------------------------------------------------------------------------
-- Bots Config

Bots_Enabled = true
No_Players = false -- Won't spawn players, bots will play alone
Bots_Start_Moving_ms = 7500
Max_Bots = 3

Bots_Move_Max_Radius = 2500

Bots_Acceptance_Radius = 80
Bots_Reach_Acceptance_Radius_sq = 300^2

Bots_Remaining_Ammo_Bag_Buy_Refill = 30

Bots_CheckTarget_Interval = 2500
Bots_Target_MaxDistance3D_Sq = 36000000

Bots_Shoot_Inaccuracy_Each_Distance_Unit = 0.02

Bots_Reach_PAP_Around = 100
Bots_Reach_Door_Around = 125

Bots_Ragdoll_Get_Up_Timeout_ms = 10000

Bots_Zombies_Dangerous_Point_Distance_sq = 6250000
Bots_Flee_Zombies_Move_Distance = 750
Bots_Flee_Zombies_Move_Radius = 500
Bots_Flee_Point_Retry_Number = 3

Bots_Smart_Reload_Check_Interval_ms = 2500

Bots_Behavior_Config = {
    "REVIVE",
    "POWER",
    "POWERUPS",
    "WEAPONS",
    "PERKS",
    "PACKAPUNCH",
    "DOORS",
    "MOVE",
}

Bots_Weapons_Ranks = {
    "Makarov",
    "M1911",
    "Glock",
    "ColtPython",
    "DesertEagle",
    "AWP",
    "M1Garand",
    "Lewis",
    "Ithaca37",
    "Moss500",
    "Rem870",
    "SPAS12",
    "SMG11",
    "AP5",
    "UMP45",
    "P90",
    "ASVal",
    "AR4",
    "GE3",
    "GE36",
    "SA80",
    "AK5C",
    "AK74U",
    "AK47",
}

Bots_Perks_Buy_Order = {
    "juggernog",
    "doubletap",
    "three_gun",
    "quick_revive",
    "stamin_up",
}

Bots_Orders = {
    "MoveTo",
    "Follow",
    "StayHere",
}

Outline_Selected_Bot_Color = Color.GREEN
Bot_Select_At_Distance_sq = 250^2
Bot_MoveTo_Order_Distance_From_Camera = 5000
Bot_Follow_Order_Update_Rate = 250

-------------------------------------------------------------------------------------------------------------------------------
-- Discord Rich Presence

DRP_Enabled = true

DRP_ClientID = 923919278036635719 -- Put 0 for no clientID, large_image and large_text can't work with that

-- Use {ROUND_NB} for the round, {MAP_NAME} for the map name
DRP_CONFIG = {
    state = "In Round {ROUND_NB}",
    details = "Killing Zombies (Nanos World)",
    large_text = "On {MAP_NAME}",
    large_image = "avatar2_upscale",
}

-----------------------------------------------------------------------------------------------------------------------------------
-- Steam Rich Presence

Steam_Rich_Presence_Enabled = true
Steam_Rich_Presence_Text = "VZombies on {MAP_NAME}"

----------------------------------------------------------------------------------------------------------------------------------
-- Mapvote Settings

Mapvote_tbl = {
    time = 20,
    maps = {
        BlankMap = {
            path = "nanos-world::BlankMap",
            UI_name = "BlankMap",
            image = "images/missing.png",
        },
        --[[zm_kino_der_toten = {
            path = "zm-kino-der-toten::zm_kino_der_toten",
            UI_name = "Kino Der Toten",
            image = "../../../../../../../Server/Assets/zm-kino-der-toten/zm_kino_der_toten/zm_kino_der_toten/Map.jpg",
        },
        zm_nacht_der_untoten = {
            path = "zm-nacht-der-untoten::nacht_der_untoten",
            UI_name = "Nacht Der Untoten",
            image = "../../../../../../../Server/Assets/zm-nacht-der-untoten/nacht_der_untoten/nacht_der_untoten/Map.jpg",
        },
        zm_spiral = {
            path = "zm-spiral::zm-spiral",
            UI_name = "Spiral",
            image = "../../../../../../../Server/Assets/zm-spiral/zm-spiral/Map.jpg",
        },
        zm_cheese_cube = {
            path = "zm-cheese-cube::zm-cheese-cube",
            UI_name = "Cheese Cube",
            image = "../../../../../../../Server/Assets/zm-cheese-cube/zm-cheese-cube/Map.jpg",
        },
        zm_soul = {
            path = "zm-soul::ZMsoul",
            UI_name = "Soul",
            image = "../../../../../../../Server/Assets/zm-soul/ZMsoul/Map.jpg",
        },
        zm_town_bo3 = {
            path = "zm-town::zm_town_bo3",
            UI_name = "Town",
            image = "../../../../../../../Server/Assets/zm-town/zm_town_bo3/Map.jpg",
        },
        bigoffice = {
            path = "bigoffice::Maps_BigCompany",
            UI_name = "Big Office",
            image = "../../../../../../../Server/Assets/bigoffice/Maps/Maps_BigCompany/Map.jpg",
        },]]--
    }
}

--[[Mapvote_Time = 20
Mapvote_AllowCurrentMap = false
Mapvote_NotForMaps = {
    "nanos-world::BlankMap"
}]]--


-------------------------------------------------------------------------------------------------------------------------------------
-- CHALKS CONFIG

Chalks_Images = {
    AK5C = true,
    AK47 = true,
    AK74U = true,
    AP5 = true,
    AR4 = true,
    ASVal = true,
    AWP = true,
    ColtPython = true,
    DesertEagle = true,
    GE3 = true,
    GE36 = true,
    Glock = true,
    Ithaca37 = true,
    Lewis = true,
    M1Garand = true,
    M1911 = true,
    Makarov = true,
    Moss500 = true,
    P90 = true,
    Rem870 = true,
    SA80 = true,
    SMG11 = true,
    SPAS12 = true,
    UMP45 = true,
}

Chalks_Offset = Vector(10, 0, 13)
Chalks_Emissive_Color = Color.RED
Chalks_Emissive_Value = 10
Chalks_Size = Vector(5, 41.1, 73)

----------------------------------------------------------------------------------------------------------------------------
-- Players outlines

Outline_Players_Check_Interval_ms = 1500
Outline_Players_Color = Color.AZURE


---------------------------------------------------------------------------------------------------------------------------------------
-- Custom weapons added in mystery box

CustomWeaponsPackagesLoad = {
    modern_weapons = "ModernWeapons",
}

CustomWeapons_Mysterybox_Added = {
    modern_weapons = {
        {
            weapon_name = "RPK",
            max_ammo = 500,
        },
        {
            weapon_name = "M249",
            max_ammo = 500,
        },
        {
            weapon_name = "M60",
            max_ammo = 500,
        },
        {
            weapon_name = "Revolver_686",
            max_ammo = 200,
        },
        {
            weapon_name = "HW357",
            max_ammo = 200,
        },
        {
            weapon_name = "M4A2",
            max_ammo = 400,
        },
        {
            weapon_name = "SFAL",
            max_ammo = 400,
        },
        {
            weapon_name = "Rifle3",
            max_ammo = 400,
        },
        {
            weapon_name = "Galil",
            max_ammo = 400,
        },
        {
            weapon_name = "TAR22",
            max_ammo = 400,
        },
        {
            weapon_name = "AUG",
            max_ammo = 400,
        },
        {
            weapon_name = "M1897",
            max_ammo = 100,
        },
        {
            weapon_name = "Winchester",
            max_ammo = 70,
        },
        {
            weapon_name = "Shotgun4",
            max_ammo = 120,
        },
        {
            weapon_name = "MUZI",
            max_ammo = 300,
        },
        {
            weapon_name = "MP4",
            max_ammo = 300,
        },
        {
            weapon_name = "MP7",
            max_ammo = 300,
        },
        {
            weapon_name = "P80",
            max_ammo = 300,
        },
        {
            weapon_name = "VECTOR",
            max_ammo = 300,
        },
        {
            weapon_name = "UMP41",
            max_ammo = 300,
        },
    }
}

---------------------------------------------------------------------------------------------------------------------------------
-- PING CONFIG

Ping_Enabled = true

Ping_Max_Distance = 5000

Ping_Display_Time_ms = 20000





Package.Require("Config_Script.lua")