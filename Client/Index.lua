Package.Require("Sh_Funcs.lua")
Package.Require("Config.lua")

if DRP_Enabled then
    if DRP_ClientID > 0 then
        Client.InitializeDiscord(DRP_ClientID)
    end
end

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
    Package.Require("Sky.lua")
    Package.Require("Gui.lua")
    Package.Require("Sounds.lua")
    Package.Require("cl_Inventory.lua")
    Package.Require("Interact.lua")
    Package.Require("Spec.lua")
    Package.Require("Chalks.lua")
    Package.Require("cl_Bots.lua")
end)