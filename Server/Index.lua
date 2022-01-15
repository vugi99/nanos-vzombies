
PLAYING_PLAYERS_NB = 0
PLAYERS_NB = 0

MAP_CONFIG_TO_SEND = {}

MAX_PLAYERS = 0

Package.RequirePackage("nanos-world-weapons")

Package.Require("Sh_Funcs.lua")



local Config_Data = {
    "MAP_ROOMS", "PLAYER_SPAWNS", "MAP_DOORS", "MAP_WEAPONS", "MAP_PACK_A_PUNCH", "MAP_POWER", "MAP_MYSTERY_BOXES", "MAP_PERKS", "MAP_Z_LIMITS"
}

Events.Subscribe("VZOMBIES_MAP_CONFIG", function(...)
    for i, v in ipairs({...}) do
        MAP_CONFIG_TO_SEND[Config_Data[i]] = v
        _ENV[Config_Data[i]] = v
    end

    MAX_PLAYERS = table_count(PLAYER_SPAWNS)

    LoadServerFiles()
end)

function LoadServerFiles()
    Package.Require("Config.lua")
    Package.Require("Map.lua")
    Package.Require("Rounds.lua")
    Package.Require("Zombies.lua")
    Package.Require("Players.lua")
    Package.Require("Money.lua")
    Package.Require("SoundsFuncs.lua")
    Package.Require("Inventory.lua")
    Package.Require("Powerups.lua")
end