

Package.Require("Config/Config.lua")
Package.Require("Sh_Funcs.lua")
Package.Require("Prepare_Loops.lua")

local Packages_Loaded = false
local _CallVZ_Loaded_Event = false

CLIENT_RECEIVED_SERVER_SETTINGS = nil

Package.Subscribe("Load", function()
    Packages_Loaded = true
    if _CallVZ_Loaded_Event then
        Events.Call("VZOMBIES_CLIENT_GAMEMODE_LOADED")
    end

    print("VZombies " .. Package.GetVersion() .. " Loaded")
end)

if VZ_BIND_EVENTS then
    for i, v in ipairs(VZ_BIND_EVENTS) do
        Input.Bind(table.unpack(v.params))
    end
else
    VZ_BIND_EVENTS = {}
end

function VZ_BIND(...)
    table.insert(VZ_BIND_EVENTS, {params = {...}})
    return Input.Bind(...)
end

Events.SubscribeRemote("LoadMapConfig", function(MAP_CONFIG)
    --print("LoadMapConfig")

    for k, v in pairs(MAP_CONFIG) do
        _ENV[k] = v
    end
    Package.Require("sh_Bots.lua")
    Package.Require("sh_Gibs.lua")
    Package.Require("Sky.lua")
    Package.Require("Gui.lua")
    Package.Require("RichPresences.lua")
    Package.Require("Input.lua")
    Package.Require("Sounds.lua")
    Package.Require("Interact.lua")
    Package.Require("Spec.lua")
    Package.Require("Chalks.lua")
    Package.Require("cl_Enemy.lua")
    Package.Require("Gibs.lua")
    Package.Require("cl_Bots.lua")
    Package.Require("Frame.lua")
    Package.Require("Settings.lua")

    if VZ_GetFeatureValue("Leaderboards", "script_loaded") then
        Package.Require("cl_Leaderboards.lua")
    end

    if ZDEV_IsModeEnabled("ZDEV_MOD_MENU") then
        Package.Require("cl_Mod_Menu.lua")
    end

    if (Server_Admins_Enabled and VZ_IsAdmin(Client.GetLocalPlayer())) then
        Package.Require("cl_Admin.lua")
    end

    if VZ_GetFeatureValue("Vehicles", "script_loaded") then
        Package.Require("cl_Vehicles.lua")
    end

    if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts then
        if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Client then
            for i, v in ipairs(VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Client) do
                Package.Require(v)
            end
        end
    end

    if Packages_Loaded then
        Events.Call("VZOMBIES_CLIENT_GAMEMODE_LOADED")
    else
        _CallVZ_Loaded_Event = true
    end
end)


if Send_Errors_To_Server then
    Console.Subscribe("LogEntry", function(text, type)
        if (type == LogType.Error or type == LogType.Fatal or type == LogType.ScriptingError) then
            Events.CallRemote("LogErrorFromClient", text, type)
        end
    end)
end

Events.SubscribeRemote("SendCustomSettingsToClient", function(settings)
    --print("SendCustomSettingsToClient RECEIVED", settings)
    CLIENT_RECEIVED_SERVER_SETTINGS = settings
    ApplyCustomSettings(CLIENT_RECEIVED_SERVER_SETTINGS)
end)