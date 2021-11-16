
PLAYING_PLAYERS_NB = 0

MAP_CONFIG_LOADED = false
MAP_CONFIG_TO_SEND = {}

MAX_PLAYERS = 0

Package.RequirePackage("nanos-world-weapons")

Package.Require("Sh_Funcs.lua")

local function split_str(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local Config_Data = {
    "MAP_ROOMS", "PLAYER_SPAWNS", "MAP_DOORS", "MAP_WEAPONS", "MAP_PACK_A_PUNCH", "MAP_POWER", "MAP_MYSTERY_BOXES", "MAP_PERKS", "MAP_Z_LIMITS"
}

Events.Subscribe("VZOMBIES_MAP_CONFIG", function(...)
    if not MAP_CONFIG_LOADED then
        local args = table.pack(...)
        for i = 1, args.n do
            local v = args[i]
            MAP_CONFIG_TO_SEND[Config_Data[i]] = v
            _ENV[Config_Data[i]] = v
        end

        MAP_CONFIG_LOADED = true

        MAX_PLAYERS = table_count(PLAYER_SPAWNS)

        LoadServerFiles()

        print("VZombies : Map Config Loaded")
    else
        Package.Warn("VZombies : Trying to load another map config while a map config is already loaded")
    end
end)

function LoadServerFiles()
    Package.Require("Config.lua")
    Package.Require("Rounds.lua")
    Package.Require("Map.lua")
    Package.Require("Zombies.lua")
    Package.Require("Players.lua")
    Package.Require("Money.lua")
    Package.Require("SoundsFuncs.lua")
    Package.Require("Inventory.lua")
    Package.Require("Powerups.lua")

    Events.Call("VZOMBIES_GAMEMODE_LOADED")
end



local map_path = Server.GetMap()
if map_path then
    local splited_map_path = split_str(map_path, ":")
    if (splited_map_path[1] and splited_map_path[2]) then
        local map_path_in_maps = "Server/Maps/" .. splited_map_path[1] .. ";" .. splited_map_path[2] .. ".lua"
        local map_files = Package.GetFiles("Server/Maps", ".lua")
        for i, v in ipairs(map_files) do
            --print(v)
            if v == map_path_in_maps then
                Package.Require(v)
                break
            end
        end
    end
end