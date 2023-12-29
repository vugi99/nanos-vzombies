

Package.Require("Config/Config.lua")
Package.Require("Config/cl_Config.lua")
Package.Require("Sh_Funcs.lua")
Package.Require("Prepare_Loops.lua")



function IsSelfCharacter(char)
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        if local_char == char then
            return true
        end
    end
    return false
end

function IsSpectatingPlayerCharacter(char)
    if Spectating_Player then
        local spec_char = Spectating_Player:GetControlledCharacter()
        --print("IsSpectatingPlayerCharacter", spec_char, char, Spectating_Player:GetID())
        if spec_char == char then
            return true
        end
    end
end





local Packages_Loaded = false
local _CallVZ_Loaded_Event = false

local Pre_Game_Canvas = Canvas(true, 	Color.TRANSPARENT, -1, true, true)
Pre_Game_Canvas:Subscribe("Update", function(self, width, height)
    self:DrawText("MISSING VZOMBIES MAP CONFIGURATION", Vector2D(math.floor(Viewport.GetViewportSize().X * 0.5), 10), FontType.OpenSans, 16, Color.RED, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
end)
Pre_Game_Canvas:Repaint()


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
    Pre_Game_Canvas:SetVisibility(false)

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

    Cl_Gamemode_Loaded = true
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

Client.SetEscapeMenuText(Escape_Menu_Text)