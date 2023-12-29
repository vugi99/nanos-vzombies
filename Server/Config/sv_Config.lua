

Package.Require("Config/Money_Config.lua")
Package.Require("Config/Rounds_Config.lua")
Package.Require("Config/Custom_Weapons_Config.lua")
Package.Require("Config/Mapvote_Config.lua")


Weapons_Dropped_Destroyed_After_ms = 60000

Map_Z_Limits_Check_Interval_ms = 20000

Allow_Player_Spawn_When_Game_Time_Is_Less_Than_s = 45



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


--------------------------------------------------------------------------------------------------------------------
-- Grenades Config

Start_Grenades_NB = 2
Max_Grenades_NB = 4

Grenade_TimeToExplode = 5
Grenade_Damage_Config = {200, 0, 200, 1000, 1} -- See : https://docs.nanos.world/docs/next/scripting-reference/classes/grenade#-setdamage


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

