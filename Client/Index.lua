Package.Require("Sh_Funcs.lua")

Events.Subscribe("LoadMapConfig", function(MAP_CONFIG)
    --print("LoadMapConfig")

    for k, v in pairs(MAP_CONFIG) do
        _ENV[k] = v
    end
    Package.Require("Config.lua")
    Package.Require("SoundsFuncs.lua")
    Package.Require("Sky.lua")
    Package.Require("Gui.lua")
    Package.Require("Sounds.lua")
    Package.Require("cl_Inventory.lua")
    Package.Require("Interact.lua")
    Package.Require("Spec.lua")
    Package.Require("cl_Grenades.lua")
end)

if Client.GetLocalPlayer() then
    Package.Subscribe("Load", function()
        Events.CallRemote("VZPlayerJoinedAfterReload")
    end)
end