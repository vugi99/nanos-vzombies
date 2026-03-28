



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
            Leaderboards = {
                script_loaded = false,
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
            Leaderboards = {
                script_loaded = false,
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

            Killjoy_Weapon = function(location, rotation)
                local melee = Melee(location or Vector(), rotation or Rotator(), "nanos-world::SM_Shovel_01", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
                melee:SetAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Slash_Attack")
                melee:SetDamageSettings(0.3, 0.5)
                melee:SetCooldown(1)

                return melee
            end,
        },
        overwrites = {
            Leaderboards = {
                script_loaded = false,
            },
        },
    },

    GRIEF = {
        Config = {
            Freeze_Player_Time_ms = 2500,
            Friendly_Damage = false,
        },
        overwrites = {
            Leaderboards = {
                script_loaded = false,
            },
        },
    },

    TOPDOWN = {
        Scripts = {
            Server = {
                "SubModes/TopDown/TopDown.lua",
            },
            Client = {
                "SubModes/TopDown/cl_TopDown.lua",
            },
        },
        Config = {
            Max_Arm_Length = 350,
            Min_Arm_Length = 25,
            Scroll_Mult = 1,
        },
    },
}