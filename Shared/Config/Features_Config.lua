
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
    Leaderboards = {
        script_loaded = true,
        records_saved = 10,
    },
    Banks = {
        script_loaded = true,
        can_interact = true,
        Max_Money = 200000,
        Money_WD_Amount = 1000,
        D_Fees = 100,
        Model = "vzombies-assets::safe_joined",
        Scale = Vector(1.7, 1.7, 1.7),
        Interact_Check_Interval_ms = 675,
        Interact_Check_Distance_Squared_Max = 40000,
    },
    Levels = {
        script_loaded = true,
        levels_xp_func = function(level)
            return math.floor(((level^2)/3 + 60) + 0.5)
        end,
        score_mult_into_xp = 0.1
    },
    Vehicles = {
        script_loaded = true,
        can_interact = true,
    },
    Chargers = {
        script_loaded = true,
        can_interact = true,
        Interact_Check_Interval_ms = 700,
        Interact_Check_Distance_Squared_Max = 40000,
        charger_asset = "vzombies-assets::GD52_optimized",
        charger_scale = Vector(25, 25, 25),
        charger_emissive_key = "Emissive_Intensity",
        charger_emissive_target = 1,
        charger_emissive_material_index = -1,

        charger_start_sound = {
            asset = "vzombies-assets::charger_startup",
            volume = 0.9,
            radius = 400,
            falloff_distance = 3000,
        },
        charger_fail_sound = {
            asset = "vzombies-assets::charger_shutdown",
            volume = 0.9,
            radius = 400,
            falloff_distance = 3000,
        },
        charger_success_sound = {
            asset = "vzombies-assets::charger_success",
            volume = 0.9,
            radius = 500,
            falloff_distance = 4000,
        },
        charger_charging_loop_sound = {
            asset = "vzombies-assets::charger_plat_loop",
            volume = 0.6,
            radius = 400,
            falloff_distance = 2500,
            loop_mode = SoundLoopMode.Forever,
        }
    }
}