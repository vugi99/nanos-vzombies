

Package.Require("Config/Dev_Config.lua")
Package.Require("Config/Features_Config.lua")
Package.Require("Config/Server_Config.lua")
Package.Require("Config/Player_Config.lua")
Package.Require("Config/GUI_Config.lua")
Package.Require("Config/Sounds_Config.lua")
Package.Require("Config/Enemies_Config.lua")
Package.Require("Config/MysteryBox_Config.lua")
Package.Require("Config/Perks_Config.lua")
Package.Require("Config/Powerups_Config.lua")
Package.Require("Config/Bots_Config.lua")
Package.Require("Config/Admin_Config.lua")
Package.Require("Config/Vehicles_Config.lua")


Weapons_Ammo_Price_Percentage = 50


Parse_Custom_Settings = true

-------------------------------------------------------------------------------------------------
-- Pack a punch config

Pack_a_punch_damage_mult = 1.5

Pack_a_punch_price = 5000
Pack_a_punch_repack_price = 2500

Pack_a_punch_upgrade_time_ms = 3500

Pack_a_punch_destroy_weapon_time_ms = 20000

Pack_a_punch_weapon_material = "vzombies-assets::M_Pack_a_punch"
Pack_a_punch_weapon_material_index = -1

PAP_Repack_Config = {
    Blast_Furnace = {
        radius_sq = 400^2,
        cooldown_ms = 10000,
        damage_func = function(dist_sq)
            return 20000000/dist_sq
        end,
        damage_on_target = 1700,
        icon = "images/blast_furnace_icon.png",
        particle_asset = "nanos-world::P_Fire_03",
        particle_lifespan = 2500,
        particle_relative_loc = Vector(0, 0, -96),
    },
    Electric = {
        radius_sq = 600^2,
        cooldown_ms = 12500,
        damage_func = function(dist_sq)
            return 15000000/dist_sq
        end,
        damage_on_target = 1500,
        icon = "images/electric_icon.png",
        particle_asset = "nanos-world::P_Sparks",
        particle_lifespan = 2500,
        particle_relative_loc = Vector(0, 0, -20),
    },
}


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









Package.Require("Config_Script.lua")