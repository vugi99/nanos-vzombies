
PLAYING_PLAYERS_NB = PLAYING_PLAYERS_NB or 0

MAP_CONFIG_LOADED = MAP_CONFIG_LOADED or false
MAP_CONFIG_TO_SEND = MAP_CONFIG_TO_SEND or {}

MAX_PLAYERS = MAX_PLAYERS or 0

Package.Require("Config/Config.lua")
Package.Require("Config/sv_Config.lua")
Package.Require("Sh_Funcs.lua")
Package.Require("CustomWeapons.lua")
Package.Require("WonderWeapons.lua")
Package.Require("Prepare_Loops.lua")

if ZDEV_CONFIG.ENABLED then
    print("DEV MODE ENABLED")
end

local Config_Data = {
    "MAP_ROOMS", "PLAYER_SPAWNS", "MAP_DOORS", "MAP_WEAPONS", "MAP_PACK_A_PUNCH", "MAP_POWER", "MAP_MYSTERY_BOXES", "MAP_PERKS", "MAP_Z_LIMITS", "MAP_WUNDERFIZZ", "MAP_INTERACT_TRIGGERS", "MAP_TELEPORTERS", "MAP_LIGHT_ZONES", "MAP_SETTINGS", "MAP_STATIC_MESHES", "HELLHOUND_SPAWNS", "BANKS", "VEHICLES_PADS", "MAP_CHARGERS"
}
local Config_Data_Count = #Config_Data

local Config_Data_Replicated = {
    MAP_DOORS = true,
    MAP_WEAPONS = true,
    MAP_PACK_A_PUNCH = true,
    MAP_POWER = true,
    MAP_PERKS = true,
    MAP_INTERACT_TRIGGERS = true,
    MAP_TELEPORTERS = true,
    MAP_SETTINGS = true,
    BANKS = true,
    VEHICLES_PADS = true,
}

Events.Subscribe("VZOMBIES_MAP_CONFIG", function(...)
    if not MAP_CONFIG_LOADED then
        local args = table.pack(...)
        for i = 1, args.n do
            if i <= Config_Data_Count then
                local v = args[i]
                _ENV[Config_Data[i]] = v

                if Config_Data_Replicated[Config_Data[i]] then
                    MAP_CONFIG_TO_SEND[Config_Data[i]] = v
                end
            else
                Console.Warn("Got extra data passed into VZOMBIES_MAP_CONFIG, ignoring because it's not configured in the gamemode")
                break
            end
        end

        --DebugFullPrint(NanosTable.Dump(MAP_CONFIG_TO_SEND))

        MAP_CONFIG_LOADED = true

        MAX_PLAYERS = table_count(PLAYER_SPAWNS)

        if ((MAP_SETTINGS and MAP_SETTINGS.Multi_Spawns) or Force_Spawns_Multiplier) then
            if Players_Spawns_Multiplier > 1 then
                local new_count = math.floor(MAX_PLAYERS * Players_Spawns_Multiplier + 0.5)
                --print(new_count)

                local cur_count = MAX_PLAYERS

                local added_spawns = {}
                for i = 1, math.ceil(Players_Spawns_Multiplier) do
                    for k, v in pairs(PLAYER_SPAWNS) do
                        cur_count = cur_count + 1
                        table.insert(added_spawns, v)
                        if cur_count >= new_count then
                            break
                        end
                    end
                    if cur_count >= new_count then
                        break
                    end
                end

                for k, v in pairs(added_spawns) do
                    table.insert(PLAYER_SPAWNS, v) -- Breaks when sending to clients
                end

                --print(cur_count)

                MAX_PLAYERS = cur_count
            end
        end

        if Auto_Set_Server_MaxPlayers then
            Server.SetMaxPlayers(MAX_PLAYERS, false)
        end

        LoadServerFiles()

        print("Map Config Loaded")
    else
        Console.Warn("Trying to load another map config while a map config is already loaded")
    end
end)

function LoadServerFiles()
    --print("LoadServerFiles()")

    Package.Require("Compatibility.lua")
    Package.Require("Precache.lua")
    Package.Require("sh_Bots.lua")
    Package.Require("sh_Gibs.lua")
    Package.Require("Rounds.lua")
    Package.Require("Map.lua")
    Package.Require("Barricades.lua")
    Package.Require("Enemy.lua")
    Package.Require("Players.lua")
    Package.Require("Money.lua")
    Package.Require("Inventory.lua")
    Package.Require("Powerups.lua")
    Package.Require("Bots.lua")
    Package.Require("Noise.lua")

    if ZDEV_IsModeEnabled("ZDEV_MOD_MENU") then
        Package.Require("Mod_Menu.lua")
    end

    if Server_Admins_Enabled then
        Package.Require("Admin.lua")
    end

    for k, v in pairs(VZ_GLOBAL_FEATURES) do
        if v.script_loaded then
            Package.Require(k .. ".lua")
        end
    end

    if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts then
        if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Shared then
            for i, v in ipairs(VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Shared) do
                Package.Require(v)
            end
        end

        if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Server then
            for i, v in ipairs(VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Scripts.Server) do
                Package.Require(v)
            end
        end
    end

    print("VZombies " .. VZ_SELECTED_GAMEMODE .. " selected")

    VZ_EVENT_CALL("Events", "VZOMBIES_GAMEMODE_LOADED")
end

-- Note: Nanos 1.161 regression: Server.GetMap() returns "" on package reload all, the loading order loads the map package after vz.
Package.Subscribe("Load", function()
    print(Server.GetMap())
    if not MAP_CONFIG_LOADED then
        local map_path = Server.GetMap()
        --print(map_path)
        if map_path then
            local map_path_in_maps = "Server/Maps/" .. map_path .. ".lua"
            local map_files = Package.GetFiles("Server/Maps", ".lua")
            for i, v in ipairs(map_files) do
                --print(v)
                if v == map_path_in_maps then
                    Package.Require(v)
                    break
                end
            end
        end
    else
        Console.Warn("HotReload - Not supported, beware of bugs")
    end
end)


Package.Subscribe("Load", function()
    print("VZombies " .. Package.GetVersion() .. " Loaded")
end)

if Send_Errors_To_Server then
    Events.SubscribeRemote("LogErrorFromClient", function(ply, text, logtype)
        local logtype_name = "Unknown"
        for k, v in pairs(LogType) do
            if v == logtype then
                logtype_name = k
            end
        end

        print("Received error log from client", ply:GetID(), ply:GetAccountName(), logtype_name, text)
    end)
end