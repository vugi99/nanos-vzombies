
function TableDeepCopy(tbl, parents)
    parents = parents or {}
    local newtbl = {}
    for k, v in pairs(tbl) do
        if (type(v) ~= "table" or v == tbl or parents[k] == v) then
            newtbl[k] = v
        else
            parents[k] = v
            newtbl[k] = TableDeepCopy(v, parents)
            parents = {}
        end
    end
    return newtbl
end

Package.Require("Config/Dev_Config.lua")
Package.Require("Config/Features_Config.lua")
Package.Require("Config/Server_Config.lua")
Package.Require("Config/Rich_Presences_Config.lua")
Package.Require("Config/Player_Config.lua")
Package.Require("Config/Rounds_Config.lua")
Package.Require("Config/Interact_Config.lua")
Package.Require("Config/Money_Config.lua")
Package.Require("Config/GUI_Config.lua")
Package.Require("Config/Sounds_Config.lua")
Package.Require("Config/Enemies_Config.lua")
Package.Require("Config/MysteryBox_Config.lua")
Package.Require("Config/Perks_Config.lua")
Package.Require("Config/Powerups_Config.lua")
Package.Require("Config/Bots_Config.lua")
Package.Require("Config/Mapvote_Config.lua")
Package.Require("Config/Custom_Weapons_Config.lua")
Package.Require("Config/Admin_Config.lua")
Package.Require("Config/Vehicles_Config.lua")

SKY_TIME = {3, 0} -- hours, min

Weapons_Dropped_Destroyed_After_ms = 60000

Map_Z_Limits_Check_Interval_ms = 20000

Parse_Custom_Settings = true

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



VZ_CL_Default_Settings = {
    Zombies_Remaining_Showed = true,
    Selected_Gamemode_Showed = true,
    Spectating_Player_Showed = true,
    Game_Time_Showed = true,
    --Player_Names_On_Heads = true,

    Ammo_Showed = true,
    Players_Money_Showed = true,
    Wave_Number_Showed = true,
    Player_Perks_Showed = true,
    Powerups_Showed = true,
    Grenades_Showed = true,
    Health_Bar_Showed = true,
    VOIP_Indicators_Showed = true,
    Levels_Showed = true,
    Notifications_Showed = true,

    Chat_Visibility = true,
}
VZ_CL_Current_Settings = {}
VZ_CL_Current_Settings = TableDeepCopy(VZ_CL_Default_Settings)









Package.Require("Config_Script.lua")