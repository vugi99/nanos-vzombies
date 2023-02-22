


VZ_Register_Input("Mod Menu", "M")

CreateVZFrame(GUI, "Mod_Menu", "65%", "65%", "Mod Menu", "Mod Menu", true)
AddVZFrameTab("Mod_Menu", "Player", "Player")
AddVZFrameTab("Mod_Menu", "Round", "Round")
AddVZFrameTab("Mod_Menu", "Enemies", "Enemies")
AddVZFrameTab("Mod_Menu", "World", "World")

AddTabCheckbox("Mod_Menu", "Player", "God Mode", function(checked)
    Events.CallRemote("VZMM_GodMode", checked)
end, true, false)

AddTabButton("Mod_Menu", "Player", "Noclip", function()
    Events.CallRemote("VZMM_Noclip")
end, "Toggle Noclip")

VZ_EVENT_SUBSCRIBE_REMOTE("Send_Weapons_Names", function(wn)
    AddTabSelect("Mod_Menu", "Player", "Give Weapon", function(selected)
        Events.CallRemote("VZMM_GiveWeap", selected)
    end, wn)
end)

AddTabSelect("Mod_Menu", "Round", "Give Powerup", function(selected)
    Events.CallRemote("VZMM_GivePowerup", selected)
end, Powerups_Names)


local _Perks_Names = {}
for k, v in pairs(PERKS_CONFIG) do
    table.insert(_Perks_Names, k)
end
AddTabSelect("Mod_Menu", "Player", "Give Perk", function(selected)
    Events.CallRemote("VZMM_GivePerk", selected)
end, _Perks_Names)


local highlight_color = Color(10, 2.5, 0)
Client.SetHighlightColor(highlight_color, 0, HighlightMode.Always)

function _MM_hle_vc(char, key, value)
    if key == "EnemyType" then
        if value then
            char:SetHighlightEnabled(true, 0)
        end
    end
end

AddTabCheckbox("Mod_Menu", "Enemies", "Highlight Enemies", function(checked)
    if checked then
        Character.Subscribe("ValueChange", _MM_hle_vc)
    else
        Character.Unsubscribe("ValueChange", _MM_hle_vc)
    end
    for k, v in pairs(Character.GetPairs()) do
        if v:GetValue("EnemyType") then
            v:SetHighlightEnabled(checked, 0)
        end
    end
end, false, false)

AddTabCheckbox("Mod_Menu", "Player", "Infinite Grenades", function(checked)
    Events.CallRemote("VZMM_InfGrenades", checked)
end, false, false)

AddTabButton("Mod_Menu", "Player", "PAP Weapon", function()
    Events.CallRemote("VZMM_PAP")
end, "Toggle PAP on Weapon")

local _PAP_Repack_Names = {}
for k, v in pairs(PAP_Repack_Config) do
    table.insert(_PAP_Repack_Names, k)
end
AddTabSelect("Mod_Menu", "Player", "Set PAP Repack Effect", function(selected)
    Events.CallRemote("VZMM_PAP", selected)
end, _PAP_Repack_Names)

AddTabTextInput("Mod_Menu", "Round", "Set Round", function(text)
    if (text and text ~= "") then
        local nb = tonumber(text)
        if nb then
            if math.floor(nb) == nb then
                Events.CallRemote("VZMM_SetRound", nb)
            end
        end
    end
end, "number", false)


local _PM_Names = {}
for k, v in pairs(Player_Models) do
    for i2, v2 in ipairs(v.Models) do
        table.insert(_PM_Names, v2)
    end
end

AddTabSelect("Mod_Menu", "Player", "Set Player Model", function(selected)
    Events.CallRemote("VZMM_SetPM", selected)
end, _PM_Names)

local _Cam_Modes_Names = {}
for k, v in pairs(CameraMode) do
    table.insert(_Cam_Modes_Names, k)
end

AddTabSelect("Mod_Menu", "Player", "Set Camera Mode", function(selected)
    Events.CallRemote("VZMM_SetCamMode", selected)
end, _Cam_Modes_Names)

AddTabTextInput("Mod_Menu", "World", "Set Time", function(text)
    if (text and text ~= "") then
        local splited = split_str(text, ":")
        if (splited[1] and splited[2]) then
            local h_nb = tonumber(splited[1])
            local m_nb = tonumber(splited[2])
            if (h_nb and m_nb) then
                if (math.floor(h_nb) == h_nb and math.floor(m_nb) == m_nb) then
                    if (h_nb >= 0 and h_nb <= 24 and m_nb >= 0 and m_nb <= 60) then
                        Sky.SetTimeOfDay(h_nb, m_nb)
                    end
                end
            end
        end
    end
end, "hours:minutes", false)

AddTabButton("Mod_Menu", "World", "Open Map Doors", function()
    Events.CallRemote("VZMM_OpenAllDoors")
end, "Open Map Doors (Can depend on Power)")

AddTabTextInput("Mod_Menu", "Player", "Set Money", function(text)
    if (text and text ~= "") then
        local nb = tonumber(text)
        if nb then
            if math.floor(nb) == nb then
                Events.CallRemote("VZMM_SetMoney", nb)
            end
        end
    end
end, "number", false)

AddTabCheckbox("Mod_Menu", "Player", "Infinite Money", function(checked)
    Events.CallRemote("VZMM_InfiniteMoney", checked)
end, true, false)

AddTabButton("Mod_Menu", "World", "Power", function()
    Events.CallRemote("VZMM_Power")
end, "Enable Power")

local _Weather_Type_Names = {}
for k, v in pairs(WeatherType) do
    table.insert(_Weather_Type_Names, k)
end

AddTabSelect("Mod_Menu", "World", "Set Weather", function(selected)
    World.SetWeather(WeatherType[selected])
end, _Weather_Type_Names)

if VZ_GetFeatureValue("Vehicles", "script_loaded") then
    local _Vehicles_Names = {}
    for k, v in pairs(VZVehicles) do
        table.insert(_Vehicles_Names, k)
    end
    AddTabSelect("Mod_Menu", "World", "Spawn Vehicle", function(selected)
        Events.CallRemote("VZMM_SpawnVehicle", selected)
    end, _Vehicles_Names)
end