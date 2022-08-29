
POWER_ON = false


PLAYING_PLAYERS = {}
WAITING_PLAYERS = {}

ROUND_NB = 0
REMAINING_ENEMIES_TO_SPAWN = 0
GAME_TIMER_SECONDS = 0
GAME_PAUSED = false

ENEMIES_TO_SPAWN_TBL = {}

WaitingNewRound_Timer = nil
WaitingNewWave = false
WaitingMapvote = nil

In_Hellhound_Round = false

function RoundFinished(reset_all, restart_game, ply_left)
    print("RoundFinished", reset_all, restart_game)
    Timer.ClearInterval(ENEMIES_SPAWN_INTERVAL)
    ENEMIES_SPAWN_INTERVAL = 0
    REMAINING_ENEMIES_TO_SPAWN = 0
    In_Hellhound_Round = false
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
        SPAWNS_UNLOCKED = {}
        ROOMS_UNLOCKED = {}
        DestroyEnemies()
        DestroyBosses()
        DestroyMapDoors()
        DestroyPowerups()
        DestroyMapGrenades()

        for k, v in pairs(VZ_GLOBAL_FEATURES) do
            if v.destroy_func then
                CallENVFunc_NoError(v.destroy_func)
            elseif v.reset_func then
                CallENVFunc_NoError(v.reset_func)
            end
        end

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

        Events.Call("VZ_GameEnded", restart_game)
    end
    if not reset_all then
        local t = WaveInterval_ms
        if restart_game then
            t = GameOverInterval_ms
            if WaitingNewRound_Timer then
                if WaitingNewWave then
                    Events.BroadcastRemote("PlayVZSound", {basic_sound_tbl=GameOver_Sound})
                    Timer.ClearTimeout(WaitingNewRound_Timer)
                    WaitingNewRound_Timer = nil
                    WaitingNewWave = false
                end
            else
                Events.BroadcastRemote("PlayVZSound", {basic_sound_tbl=GameOver_Sound})
                WaitingMapvote = Package.Call("mapvote", "StartMapVote", Mapvote_tbl)
                --print(WaitingMapvote)
            end
        else
            if WaitingNewRound_Timer then
                Timer.ClearTimeout(WaitingNewRound_Timer)
                WaitingNewRound_Timer = nil
            end
            Events.BroadcastRemote("PlayVZSound", {basic_sound_tbl=WaveFinished_Sound})
            WaitingNewWave = true
        end
        if not WaitingNewRound_Timer then
            if WaitingMapvote == nil then
                WaitingNewRound_Timer = Timer.SetTimeout(function()
                    WaitingNewRound_Timer = nil
                    WaitingNewWave = false
                    if (PLAYING_PLAYERS_NB > 0 or (table_count(Player.GetAll()) > 0 and No_Players)) then
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

        for k, v in pairs(VZ_GLOBAL_FEATURES) do
            if v.start_new_game_func then
                CallENVFunc_NoError(v.start_new_game_func)
            end
        end

        UnlockRoom(1)
        DestroyMapGrenades()

        if Game_Time_On_Screen then
            GAME_TIMER_SECONDS = 0
            Events.BroadcastRemote("UpdateGameTime", 0)
        end

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
    Events.BroadcastRemote("SetClientRoundNumber", ROUND_NB, CanStartHellhoundRound())
    REMAINING_ENEMIES_TO_SPAWN = math.floor((First_Wave_Enemies + (Add_at_each_wave * (ROUND_NB - 1)) + (Add_at_each_wave_per_player * (ROUND_NB - 1) * PLAYING_PLAYERS_NB)) * Zombies_Number_Mult)
    if CanStartHellhoundRound() then
        if Enemies_Config.Hellhound.Spawning_Config.Number_To_Spawn_mult then
            REMAINING_ENEMIES_TO_SPAWN = math.floor(REMAINING_ENEMIES_TO_SPAWN * Enemies_Config.Hellhound.Spawning_Config.Number_To_Spawn_mult)
        end
    end

    --print(REMAINING_ENEMIES_TO_SPAWN)

    SendEnemiesRemaining()

    ENEMIES_TO_SPAWN_TBL = {}

    if not CanStartHellhoundRound() then
        local SpawningPercentages = {}
        for k, v in pairs(Enemies_Config.Zombie.Types) do
            SpawningPercentages[k] = 0
        end
        for k, v in pairs(Enemies_Config.Zombie.FirstWave) do
            SpawningPercentages[k] = v
        end

        for k, v in pairs(Enemies_Config.Zombie.Added_Per_Wave_Percentage) do
            local calculated = v * (ROUND_NB - 1)
            if calculated > 100 then
                calculated = 100
            end

            for k2, v2 in pairs(SpawningPercentages) do
                if k2 ~= k then
                    SpawningPercentages[k2] = v2 - calculated
                end
            end
            SpawningPercentages[k] = SpawningPercentages[k] + calculated
        end
        --print(NanosUtils.Dump(SpawningPercentages))

        local SpawningCount = {}
        for k, v in pairs(SpawningPercentages) do
            if v > 0 then
                SpawningCount[k] = math.floor(REMAINING_ENEMIES_TO_SPAWN * (v/100))
            end
        end
        --print(NanosUtils.Dump(SpawningCount))


        --local FastZombiesToSpawnNB = math.floor((Running_Zombies_Percentage_Start + (Added_Running_Zombies_Percentage_At_Each_Wave * (ROUND_NB - 1))) * REMAINING_ENEMIES_TO_SPAWN / 100)
        --local SlowZombiesToSpawnNB = REMAINING_ENEMIES_TO_SPAWN - FastZombiesToSpawnNB
        for k, v in pairs(SpawningCount) do
            for i = 1, v do
                table.insert(ENEMIES_TO_SPAWN_TBL, {"Zombie", k})
            end
        end

        local tbl_cnt = table_count(ENEMIES_TO_SPAWN_TBL)
        if tbl_cnt < REMAINING_ENEMIES_TO_SPAWN then
            for i = tbl_cnt, REMAINING_ENEMIES_TO_SPAWN do
                table.insert(ENEMIES_TO_SPAWN_TBL, {"Zombie", "run"})
            end
        end
    else
        for i = 1, REMAINING_ENEMIES_TO_SPAWN do
            table.insert(ENEMIES_TO_SPAWN_TBL, {"Hellhound", "hellhound"})
        end
        In_Hellhound_Round = true
    end


    for k, v in pairs(PLAYING_PLAYERS) do
        if ROUND_NB == 1 then
            v:SetValue("ZMoney", Player_Start_Money, true)
            v:SetValue("ZScore", 0, false)
            v:SetValue("ZKills", 0, false)
            SpawnCharacterForPlayer(v, k)
        end
    end

    local Spawn_Enemy_Interval_time = math.ceil(Enemies_Spawn_Cooldown/REMAINING_ENEMIES_TO_SPAWN)
    if Spawn_Enemy_Interval_time < Enemies_Spawn_Interval_min_time_ms then
        Spawn_Enemy_Interval_time = Enemies_Spawn_Interval_min_time_ms
    end
    ENEMIES_SPAWN_INTERVAL = Timer.SetInterval(SpawnEnemyIntervalFunc, Spawn_Enemy_Interval_time)
    SpawnEnemyIntervalFunc()

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

function CanStartHellhoundRound()
    if Hellhounds_Each_x_Rounds > 0 then
        if not IsEnemyDisabled("Hellhound") then
            if HELLHOUND_SPAWNS and table_count(HELLHOUND_SPAWNS) > 0 then
                if table_count(GetCustomSpawnsUnlocked(Enemies_Config["Hellhound"])) > 0 then
                    if ROUND_NB % Hellhounds_Each_x_Rounds == 0 then
                        return true
                    end
                end
            end
        end
    end
end

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Server", "Console", function(text)
        local split_txt = split_str(text, " ")
        if (split_txt[1] and split_txt[2]) then
            if split_txt[1] == "round_nb" then
                ROUND_NB = tonumber(split_txt[2]) - 1
                print("ROUND_NB set to", ROUND_NB + 1)

                REMAINING_ENEMIES_TO_SPAWN = 0
                for k, v in pairs(GetEnemiesCharsCopy()) do
                    v:SetHealth(0)
                end
            end
        end
    end)
end

VZ_EVENT_SUBSCRIBE("Server", "Tick", function(ds)
    if not GAME_PAUSED then
        if Game_Time_On_Screen then
            if ROUND_NB > 0 then
                GAME_TIMER_SECONDS = GAME_TIMER_SECONDS + ds
                --print(GAME_TIMER_SECONDS)
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "TogglePauseGame", function(ply)
    if Can_Host_Pause_Game then
        if ply:GetIP() == "127.0.0.1" then
            GAME_PAUSED = not GAME_PAUSED
            print("Game Paused", GAME_PAUSED)

            Events.BroadcastRemote("ClientPauseGame", GAME_PAUSED)

            if GAME_PAUSED then
                -- Stop or kills zombies
                for k, v in pairs(GetMergedEnemiesChars()) do
                    if v:IsValid() then
                        if not v:IsInRagdollMode() then
                            if not v:GetValue("PunchCoolDownTimer") then
                                if v:GetValue("Target_type") == "player" then
                                    v:SetValue("Target", nil, false)
                                    v:StopMovement()
                                elseif (v:GetValue("Target_type") == "barricade" or v:GetValue("Target_type") == "vault" or v:GetValue("GroundAnim")) then
                                    local zombie_type = v:GetValue("EnemyType")
                                    REMAINING_ENEMIES_TO_SPAWN = REMAINING_ENEMIES_TO_SPAWN + 1
                                    table.insert(ENEMIES_TO_SPAWN_TBL, zombie_type)
                                    v:SetHealth(0)
                                end
                            end
                        end
                    end
                end

                -- Destroy grenades of the world to avoid zombies going in ragdoll during pause
                for k, v in pairs(Grenade.GetPairs()) do
                    v:Destroy()
                end
            end
        end
    end
end)