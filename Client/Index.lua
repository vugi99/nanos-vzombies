Package.Require("Config.lua")
Package.Require("Sh_Funcs.lua")

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

Events.Subscribe("LoadMapConfig", function(MAP_CONFIG)
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

    if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts then
        if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Client then
            for i, v in ipairs(VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Client) do
                Package.Require(v)
            end
        end
    end
end)


if Send_Errors_To_Server then
    Client.Subscribe("LogEntry", function(text, type)
        if (type == LogType.Error or type == LogType.Fatal or type == LogType.ScriptingError) then
            Events.CallRemote("LogErrorFromClient", text, type)
        end
    end)
end