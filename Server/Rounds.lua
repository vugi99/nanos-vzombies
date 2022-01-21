
POWER_ON = false


PLAYING_PLAYERS = {}
WAITING_PLAYERS = {}

ROUND_NB = 0
REMAINING_ZOMBIES_TO_SPAWN = 0

ZOMBIES_TO_SPAWN_TBL = {}

WaitingNewRound_Timer = nil
WaitingNewWave = false
WaitingMapvote = nil

function RoundFinished(reset_all, restart_game, ply_left)
    print("RoundFinished", reset_all, restart_game)
    Timer.ClearInterval(ZOMBIES_SPAWN_INTERVAL)
    ZOMBIES_SPAWN_INTERVAL = 0
    REMAINING_ZOMBIES_TO_SPAWN = 0
    if (not reset_all and not restart_game) then
        for k, v in pairs(PLAYING_PLAYERS) do
            if not v:GetControlledCharacter() then
                SpawnCharacterForPlayer(v, k)
                if v.BOT then
                    v:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
                    RequestBotAction(v)
                end
            end
        end
    end
    if (reset_all or restart_game) then
        ROUND_NB = 0
        ResetMapPower()
        ResetPAP()
        SPAWNS_UNLOCKED = {}
        ROOMS_UNLOCKED = {}
        ResetMysteryBoxes()
        DestroyZombies()
        DestroyMapPerks()
        DestroyBarricades()
        DestroyMapDoors()
        DestroyPowerups()
        DestroyMapGrenades()
        ResetWunderfizzes()
        DestroyMapTeleporters()

        local New_Playing_Players = {}
        for k, v in pairs(PLAYING_PLAYERS) do
            if not v.BOT then
                if v ~= ply_left then
                    table.insert(New_Playing_Players, v)
                end
            else
                local char = v:GetControlledCharacter()
                if char then
                    char:Destroy()
                end
                v:Kick(true)
            end
        end

        ALL_BOTS = {}
        Events.BroadcastRemote("AllBotsLeft")
        PLAYING_PLAYERS = New_Playing_Players
        PLAYING_PLAYERS_NB = table_count(PLAYING_PLAYERS)

        -- To avoid them buying things in the game over interval
        for k, v in pairs(PLAYING_PLAYERS) do
            v:SetValue("ZMoney", -666, true) -- -666 to identify easily when they shouldn't do anything
        end

        for k, v in pairs(Weapon.GetAll()) do
            if (v:IsValid() and v:GetValue("DroppedWeaponName")) then
                v:Destroy()
            end
        end
    end
    if not reset_all then
        local t = WaveInterval_ms
        if restart_game then
            t = GameOverInterval_ms
            if WaitingNewRound_Timer then
                if WaitingNewWave then
                    Events.BroadcastRemote("GameOver")
                    Timer.ClearTimeout(WaitingNewRound_Timer)
                    WaitingNewRound_Timer = nil
                    WaitingNewWave = false
                end
            else
                Events.BroadcastRemote("GameOver")
                WaitingMapvote = Package.Call("mapvote", "StartMapVote", Mapvote_tbl)
                --print(WaitingMapvote)
            end
        else
            if WaitingNewRound_Timer then
                Timer.ClearTimeout(WaitingNewRound_Timer)
                WaitingNewRound_Timer = nil
            end
            Events.BroadcastRemote("WaveFinished")
            WaitingNewWave = true
        end
        if not WaitingNewRound_Timer then
            if WaitingMapvote == nil then
                WaitingNewRound_Timer = Timer.SetTimeout(function()
                    WaitingNewRound_Timer = nil
                    WaitingNewWave = false
                    if PLAYING_PLAYERS_NB > 0 then
                        StartRound()
                    end
                end, t)
            end
        end
    else
        if WaitingNewRound_Timer then
            Timer.ClearTimeout(WaitingNewRound_Timer)
            WaitingNewRound_Timer = nil
            WaitingNewWave = false
        end
        if Dynamic_Server_Description then
            Server.SetDescription(DSD_Idle_Text, false)
        end
    end
end
Package.Export("RoundFinished", RoundFinished)

function StartRound()
    print("StartRound " .. tostring(ROUND_NB + 1))
    if ROUND_NB == 0 then
        SpawnMapDoors()
        SpawnMapPerks()
        SpawnMapBarricades()
        PickNewMysteryBox()
        PickNewWunderfizz()
        UnlockRoom(1)
        DestroyMapGrenades()
        CreateMapTeleporters()

        if Bots_Enabled then
            local bots_to_spawn = MAX_PLAYERS - PLAYING_PLAYERS_NB
            if bots_to_spawn > Max_Bots then
                bots_to_spawn = Max_Bots
            end

            for i = PLAYING_PLAYERS_NB, PLAYING_PLAYERS_NB + bots_to_spawn - 1 do
                local Bot = VZBotJoin()
                HandlePlayerJoin(Bot, true)
            end
        end
    end
    ROUND_NB = ROUND_NB + 1
    Events.BroadcastRemote("SetClientRoundNumber", ROUND_NB)
    REMAINING_ZOMBIES_TO_SPAWN = (first_wave_zombies + (Add_at_each_wave * (ROUND_NB - 1)) + (Add_at_each_wave_per_player * (ROUND_NB - 1) * PLAYING_PLAYERS_NB)) * Zombies_Number_Mult
    SendZombiesRemaining()

    -- Calculate Number of fast zombies and slow zombies to spawn at this wave, add them to the ZOMBIES_TO_SPAWN_TBL tbl so i can use random on this table in the spawn zombie function
    local FastZombiesToSpawnNB = math.floor((Running_Zombies_Percentage_Start + (Added_Running_Zombies_Percentage_At_Each_Wave * (ROUND_NB - 1))) * REMAINING_ZOMBIES_TO_SPAWN / 100)
    local SlowZombiesToSpawnNB = REMAINING_ZOMBIES_TO_SPAWN - FastZombiesToSpawnNB
    --print("FastZombiesToSpawnNB", FastZombiesToSpawnNB)
    --print("SlowZombiesToSpawnNB", SlowZombiesToSpawnNB)
    ZOMBIES_TO_SPAWN_TBL = {}
    for i = 1, FastZombiesToSpawnNB do
        table.insert(ZOMBIES_TO_SPAWN_TBL, "run")
    end
    for i = 1, SlowZombiesToSpawnNB do
        table.insert(ZOMBIES_TO_SPAWN_TBL, "walk")
    end


    for k, v in pairs(PLAYING_PLAYERS) do
        if ROUND_NB == 1 then
            v:SetValue("ZMoney", Player_Start_Money, true)
            v:SetValue("ZScore", 0, false)
            v:SetValue("ZKills", 0, false)
            SpawnCharacterForPlayer(v, k)
        end
    end

    local Spawn_Z_Interval_time = math.ceil(Zombies_Spawn_Cooldown/REMAINING_ZOMBIES_TO_SPAWN)
    if Spawn_Z_Interval_time < Zombies_Spawn_Interval_min_time_ms then
        Spawn_Z_Interval_time = Zombies_Spawn_Interval_min_time_ms
    end
    ZOMBIES_SPAWN_INTERVAL = Timer.SetInterval(SpawnZombieIntervalFunc, Spawn_Z_Interval_time)
    SpawnZombieIntervalFunc()

    if Dynamic_Server_Description then
        local new_text = DSD_In_Game_Text[1] .. tostring(ROUND_NB)
        if DSD_In_Game_Text[2] then
            new_text = new_text .. DSD_In_Game_Text[2]
        end
        Server.SetDescription(new_text, false)
    end

    if ROUND_NB == 1 then
        Events.Call("VZ_GameStarted")
    end
    Events.Call("VZ_WaveStarted", ROUND_NB)
end

if Dynamic_Server_Description then
    Server.SetDescription(DSD_Idle_Text, false)
end

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Server", "Console", function(text)
        local split_txt = split_str(text, " ")
        if (split_txt[1] and split_txt[2]) then
            if split_txt[1] == "round_nb" then
                ROUND_NB = tonumber(split_txt[2]) - 1
                print("ROUND_NB set to", ROUND_NB + 1)
                
                REMAINING_ZOMBIES_TO_SPAWN = 0
                for k, v in pairs(GetZombiesCharsCopy()) do
                    v:SetHealth(0)
                end
            end
        end
    end)
end

--[[function CanAddMapToMapvotetbl(map_path)
    for i, v in ipairs(Mapvote_NotForMaps) do
        if v == map_path then
            return false
        end
    end

    local cur_map_path = Server.GetMap()
    if cur_map_path then
        if not Mapvote_AllowCurrentMap then
            if map_path == cur_map_path then
                return false
            end
        end
    end

    return true
end

function SplitMapAssetPackAndName(map_path)
    local splited = split_str(map_path, ":")
    return splited[1], splited[2]
end

function GenerateMapvoteTbl()
    local tbl = {
        time = Mapvote_Time,
        maps = {},
    }

    local map_files = Package.GetFiles("Server/Maps", ".lua")
    for i, v in ipairs(map_files) do
        local map_path = v:gsub(";", "::")
        if CanAddMapToMapvotetbl(map_path) then
            local map_asset_pack, map_name = SplitMapAssetPackAndName(map_path)
            tbl.maps[map_name] = {
                path = map_path,
                UI_name = map_name,
                image = "images/missing.png",
            }
        end
    end

    -- TODO : List all dirs in Assets/ , read Assets.toml, find maps, read Map.toml, check if compatible, then add if good

    return tbl
end

print(NanosUtils.Dump(GenerateMapvoteTbl()))]]--