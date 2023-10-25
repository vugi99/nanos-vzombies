

Package.Require("Config/Rich_Presences_Config.lua")
Package.Require("Config/Interact_Config.lua")
Package.Require("Config/Config_Esc_Menu.lua")



SKY_TIME = {3, 0} -- hours, min

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


-------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT SETTINGS CONFIG

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


    Clientside_Gibs = true,
}
VZ_CL_Current_Settings = {}
VZ_CL_Current_Settings = TableDeepCopy(VZ_CL_Default_Settings)