
POWER_ON = false


PLAYING_PLAYERS = {}
WAITING_PLAYERS = {}

GAME_LEFT_PLAYERS_STATS = {}

ROUND_NB = 0
REMAINING_ENEMIES_TO_SPAWN = 0
GAME_TIMER_SECONDS = 0
KILL_COUNT = 0
GAME_PAUSED = false
SPAWN_ENEMY_INTERVAL_TIME = nil
WAVE_TIMED_OUT = nil
WAVE_TIMEOUT = 0

ENEMIES_TO_SPAWN_TBL = {}

WaitingNewRound_Timer = nil
WaitingNewWave = false
WaitingMapvote = nil

In_Hellhound_Round = false

function NewRoundTimer_Func()
    WaitingNewRound_Timer = nil
    WaitingNewWave = false
    if (PLAYING_PLAYERS_NB > 0 or (table_count(Player.GetAll()) > 0 and No_Players)) then
        --print("Start next round timer")
        StartRound()
    end
end

function RoundFinished(reset_all, restart_game, ply_left)
    --print(NanosTable.Dump(debug.getinfo(2)))

    -- The round is restarting/resetting, abort anything, do not try to finish again.
    if (ROUND_NB == 0 and ((WaitingNewRound_Timer ~= nil) and (Timer.IsValid(WaitingNewRound_Timer)) or WaitingMapvote ~= nil)) then return print("RoundFinished aborted", reset_all, reset_all) end

    print("RoundFinished", reset_all, restart_game)
    if Timer.IsValid(ENEMIES_SPAWN_INTERVAL) then
        Timer.ClearInterval(ENEMIES_SPAWN_INTERVAL)
    end
    ENEMIES_SPAWN_INTERVAL = 0
    REMAINING_ENEMIES_TO_SPAWN = 0
    In_Hellhound_Round = false

    if Timer.IsValid(WAVE_TIMEOUT) then
        Timer.ClearTimeout(WAVE_TIMEOUT)
    end
    WAVE_TIMEOUT = 0
    WAVE_TIMED_OUT = nil

    for k, v in pairs(PLAYING_PLAYERS) do
        if IsValid(v) then
            if not v.BOT then
                if v:GetValue("PlayerXP") then
                    Events.CallRemote("PlayerLevelXPUpdate", v, Reliability.Reliable, v:GetValue("PlayerLevel"), v:GetValue("PlayerXP"))
                end
            end
        end
    end

    if (not reset_all and not restart_game) then
        VZ_EVENT_CALL("Events", "VZ_WaveFinished", ROUND_NB)

        if Players_Respawn_Between_Rounds then
            for k, v in pairs(PLAYING_PLAYERS) do
                if not v:GetControlledCharacter() then
                    ProtectedCall(function()
                        SpawnCharacterForPlayer(v, k)
                        if v.BOT then
                            v:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
                            RequestBotAction(v)
                        end
                    end)
                end
            end
        end
    end

    if (reset_all or restart_game) then
        VZ_EVENT_CALL("Events", "VZ_GameEnding", restart_game)

        ROUND_NB = 0
        ProtectedCall(ResetMapPower)
        SPAWNS_UNLOCKED = {}
        SPAWNS_ENABLED = {}
        ROOMS_UNLOCKED = {}
        ROOMS_SPAWNS_DISABLED = {}
        GAME_LEFT_PLAYERS_STATS = {}
        ProtectedCall(DestroyEnemies)
        ProtectedCall(DestroyBosses)
        ProtectedCall(DestroyMapDoors)
        ProtectedCall(DestroyPowerups)
        ProtectedCall(DestroyMapGrenades)

        for k, v in pairs(VZ_GLOBAL_FEATURES) do
            --print(k)
            if v.destroy_func then
                CallENVFunc_NoError(v.destroy_func)
            elseif v.reset_func then
                CallENVFunc_NoError(v.reset_func)
            end
        end

        local New_Playing_Players = {}
        for k, v in pairs(PLAYING_PLAYERS) do
            if v:IsValid() then
                ProtectedCall(function()
                    if not v.BOT then
                        if v ~= ply_left then
                            table.insert(New_Playing_Players, v)
                        end
                    else
                        local char = v:GetControlledCharacter()
                        if IsValid(char) then
                            char:Destroy()
                        end
                        v:Kick(true)
                    end
                end)
            end
        end

        ALL_BOTS = {}
        Events.BroadcastRemote("AllBotsLeft", Reliability.Reliable)
        PLAYING_PLAYERS = New_Playing_Players
        PLAYING_PLAYERS_NB = table_count(PLAYING_PLAYERS)

        -- To avoid them buying things in the game over interval
        for k, v in pairs(PLAYING_PLAYERS) do
            if IsValid(v) then
                v:SetValue("ZMoney", -666, true) -- -666 to identify easily when they shouldn't do anything
            end
        end

        for k, v in pairs(Weapon.GetAll()) do
            if (v:IsValid() and v:GetValue("DroppedWeaponName")) then
                v:Destroy()
            end
        end

        if DestroyVehicles then
            ProtectedCall(DestroyVehicles)
        end

        if DestroyPreReachTriggers then
            ProtectedCall(DestroyPreReachTriggers)
        end

        VZ_EVENT_CALL("Events", "VZ_GameEnded", restart_game)
    end
    if not reset_all then
        local t = WaveInterval_ms
        if restart_game then
            t = GameOverInterval_ms
            if WaitingNewRound_Timer then
                if WaitingNewWave then
                    Events.BroadcastRemote("PlayVZSound", Reliability.Reliable, {basic_sound_tbl=GameOver_Sound})
                    Timer.ClearTimeout(WaitingNewRound_Timer)
                    WaitingNewRound_Timer = nil
                    WaitingNewWave = false
                end
            else
                Events.BroadcastRemote("PlayVZSound", Reliability.Reliable, {basic_sound_tbl=GameOver_Sound})
                --print(WaitingMapvote)
            end
            if WaitingMapvote == nil then
                if StartMapVote then
                    WaitingMapvote = StartMapVote(Mapvote_tbl)
                end
            end
        else
            if WaitingNewRound_Timer then
                Timer.ClearTimeout(WaitingNewRound_Timer)
                WaitingNewRound_Timer = nil
            end
            Events.BroadcastRemote("PlayVZSound", Reliability.Reliable, {basic_sound_tbl=WaveFinished_Sound})
            WaitingNewWave = true
        end
        if not WaitingNewRound_Timer then
            if WaitingMapvote == nil then
                if not Timed_Waves then
                    WaitingNewRound_Timer = Timer.SetTimeout(NewRoundTimer_Func, t)
                else
                    NewRoundTimer_Func()
                end
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

function CheckRoundFinished(reset_all, restart_game, ply_left)
    --print("CheckRoundFinished", reset_all, restart_game)

    if (reset_all or restart_game) then
        RoundFinished(reset_all, restart_game, ply_left)
        return true
    end

    local al_nb = GetPlayersAliveNB()
    if al_nb == 0 then
        RoundFinished(false, true, ply_left)
        return true
    end

    if (table_count(ENEMY_CHARACTERS) == 0 and REMAINING_ENEMIES_TO_SPAWN <= 0 and (not WaitingNewRound_Timer)) then
        --print("Case no enemies")
        RoundFinished(false, false, ply_left)
        return true
    end

    if (WAVE_TIMED_OUT) then
        RoundFinished(false, false, ply_left)
        return true
    end

    local ret_game_reset = VZ_EVENT_CALL("Events", "VZ_CheckGameReset")
    if (not ret_game_reset) then
        RoundFinished(true, false, ply_left)
        return true
    end

    local ret_game_restart = VZ_EVENT_CALL("Events", "VZ_CheckGameRestart")
    if (not ret_game_restart) then
        RoundFinished(false, true, ply_left)
        return true
    end

    local ret_wave = VZ_EVENT_CALL("Events", "VZ_CheckWaveFinished")
    if (not ret_wave) then
        --print("Case VZ_CheckWaveFinished")
        RoundFinished(false, false, ply_left)
        return true
    end
end
Package.Export("CheckRoundFinished", CheckRoundFinished)

function StartRound()
    if ROUND_NB == 0 then
        if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].MIN_PLAYERS ~= nil then
            if table_count(Player.GetAll()) < VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].MIN_PLAYERS then
                --for k, v in pairs(Player.GetAll()) do
                    --v:SetValue("PlayerWaiting", "Waiting_More_Players", true)
                --end
                Events.BroadcastRemote("SetGlobalPlayerWaitingValue", Reliability.Reliable, "Waiting_More_Players")
                return
            end
        end
    end

    print("StartRound " .. tostring(ROUND_NB + 1))
    if ROUND_NB == 0 then
        VZ_EVENT_CALL("Events", "VZ_GameStarting")

        SpawnMapDoors()

        for k, v in pairs(VZ_GLOBAL_FEATURES) do
            if v.start_new_game_func then
                CallENVFunc_NoError(v.start_new_game_func)
            end
        end

        UnlockRoom(1)
        DestroyMapGrenades()

        KILL_COUNT = 0

        GAME_TIMER_SECONDS = 0
        if Game_Time_On_Screen then
            Events.BroadcastRemote("UpdateGameTime", Reliability.Reliable, 0)
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

        GAME_LEFT_PLAYERS_STATS = {}
    end

    WAVE_TIMED_OUT = nil
    ROUND_NB = ROUND_NB + 1
    Events.BroadcastRemote("SetClientRoundNumber", Reliability.Reliable, ROUND_NB, CanStartHellhoundRound())
    REMAINING_ENEMIES_TO_SPAWN = CalculateEnemiesToSpawn(ROUND_NB)
    if CanStartHellhoundRound() then
        if Enemies_Config.Hellhound.Spawning_Config.Number_To_Spawn_mult then
            REMAINING_ENEMIES_TO_SPAWN = math.floor(REMAINING_ENEMIES_TO_SPAWN * Enemies_Config.Hellhound.Spawning_Config.Number_To_Spawn_mult)
        end
    end

    --print(REMAINING_ENEMIES_TO_SPAWN)

    SendEnemiesRemaining()

    ENEMIES_TO_SPAWN_TBL = {}

    if not CanStartHellhoundRound() then
        local weight_sum = 0
        local SpawningPercentages = {}
        for k, v in pairs(Enemies_Waves_Weight_Functions) do
            SpawningPercentages[k] = {}
            for k2, v2 in pairs(v) do
                local weight = math.max(0, v2(ROUND_NB))
                SpawningPercentages[k][k2] = weight
                weight_sum = weight_sum + weight
            end
        end
        --print(NanosTable.Dump(SpawningPercentages))

        if weight_sum > 0 then
            local SpawningCount = {}
            for k, v in pairs(SpawningPercentages) do
                SpawningCount[k] = {}
                for k2, v2 in pairs(v) do
                    if v2 > 0 then
                        SpawningCount[k][k2] = math.floor((REMAINING_ENEMIES_TO_SPAWN * v2/weight_sum) + 0.5)
                    end
                end
            end
            --print(NanosTable.Dump(SpawningCount))


            --local FastZombiesToSpawnNB = math.floor((Running_Zombies_Percentage_Start + (Added_Running_Zombies_Percentage_At_Each_Wave * (ROUND_NB - 1))) * REMAINING_ENEMIES_TO_SPAWN / 100)
            --local SlowZombiesToSpawnNB = REMAINING_ENEMIES_TO_SPAWN - FastZombiesToSpawnNB
            for k, v in pairs(SpawningCount) do
                for k2, v2 in pairs(v) do
                    for i = 1, v2 do
                        table.insert(ENEMIES_TO_SPAWN_TBL, {k, k2})
                    end
                end
            end

            local tbl_cnt = table_count(ENEMIES_TO_SPAWN_TBL)
            --print(tbl_cnt, REMAINING_ENEMIES_TO_SPAWN)
            if tbl_cnt < REMAINING_ENEMIES_TO_SPAWN then
                local added_per_wave_names = {}
                for k, v in pairs(Enemies_Waves_Weight_Functions) do
                    for k2, v2 in pairs(v) do
                        if SpawningPercentages[k][k2] > 0 then -- Only add zombies that can still spawn
                            table.insert(added_per_wave_names, {k, k2})
                        end
                    end
                end
                local added_per_wave_names_c = table_count(added_per_wave_names)
                for i = tbl_cnt, (REMAINING_ENEMIES_TO_SPAWN-1) do
                    local selected_id = math.random(added_per_wave_names_c)
                    table.insert(ENEMIES_TO_SPAWN_TBL, {added_per_wave_names[selected_id][1], added_per_wave_names[selected_id][2]})
                end
            end

            if tbl_cnt > REMAINING_ENEMIES_TO_SPAWN then
                for i = REMAINING_ENEMIES_TO_SPAWN, (tbl_cnt-1) do
                    local selected_id = math.random(tbl_cnt-i + REMAINING_ENEMIES_TO_SPAWN)
                    table.remove(ENEMIES_TO_SPAWN_TBL, selected_id)
                end
            end

            --print(table_count(ENEMIES_TO_SPAWN_TBL))
        else
            warn("weight_sum is <= 0, cannot generate Enemies to spawn properly")
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
            v:SetValue("PlayerWaiting", nil, true)
            SpawnCharacterForPlayer(v, k)
        else
            if Game_Time_On_Screen then
                Events.CallRemote("UpdateGameTime", v, Reliability.Reliable, math.floor(GAME_TIMER_SECONDS))
            end
        end
    end

    SPAWN_ENEMY_INTERVAL_TIME = math.ceil(Enemies_Spawn_Cooldown/REMAINING_ENEMIES_TO_SPAWN)
    if SPAWN_ENEMY_INTERVAL_TIME < Enemies_Spawn_Interval_min_time_ms then
        SPAWN_ENEMY_INTERVAL_TIME = Enemies_Spawn_Interval_min_time_ms
    end
    ENEMIES_SPAWN_INTERVAL = Timer.SetInterval(SpawnEnemyIntervalFunc, SPAWN_ENEMY_INTERVAL_TIME)
    SpawnEnemyIntervalFunc()
    if Timed_Waves then
        SendWaveTimeRemaining()
        if Timer.IsValid(WAVE_TIMEOUT) then
            Timer.ClearTimeout(WAVE_TIMEOUT)
        end
        WAVE_TIMEOUT = Timer.SetTimeout(function()
            WAVE_TIMED_OUT = true
            CheckRoundFinished()
        end, REMAINING_ENEMIES_TO_SPAWN*(SPAWN_ENEMY_INTERVAL_TIME or 0))
    end

    if Dynamic_Server_Description then
        local new_text = DSD_In_Game_Text[1] .. tostring(ROUND_NB)
        if DSD_In_Game_Text[2] then
            new_text = new_text .. DSD_In_Game_Text[2]
        end
        Server.SetDescription(new_text, false)
    end

    if ROUND_NB == 1 then
        VZ_EVENT_CALL("Events", "VZ_GameStarted")
    end
    VZ_EVENT_CALL("Events", "VZ_WaveStarted", ROUND_NB, In_Hellhound_Round)
end

if Dynamic_Server_Description then
    Server.SetDescription(DSD_Idle_Text, false)
end

function CanStartHellhoundRound()
    if Hellhounds_Each_x_Rounds > 0 then
        if not IsEnemyDisabled("Hellhound") then
            if HELLHOUND_SPAWNS and table_count(HELLHOUND_SPAWNS) > 0 then
                if table_count(GetCustomSpawnsUnlocked(Enemies_Config["Hellhound"].Spawning_Config)) > 0 then
                    if ROUND_NB % Hellhounds_Each_x_Rounds == 0 then
                        return true
                    end
                end
            end
        end
    end
end

VZ_EVENT_SUBSCRIBE("Server", "Tick", function(ds)
    if not GAME_PAUSED then
        if ROUND_NB > 0 then
            GAME_TIMER_SECONDS = GAME_TIMER_SECONDS + ds
            --print(GAME_TIMER_SECONDS)
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("TogglePauseGame", function(ply)
    if Can_Host_Pause_Game then
        if ply:GetIP() == "127.0.0.1" then
            GAME_PAUSED = not GAME_PAUSED
            print("Game Paused", GAME_PAUSED)

            Events.BroadcastRemote("ClientPauseGame", Reliability.Reliable, GAME_PAUSED)

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
                                    table.insert(ENEMIES_TO_SPAWN_TBL, {v:GetValue("EnemyName"), zombie_type})
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

                -- Stop Bots
                for k, v in pairs(PLAYING_PLAYERS) do
                    if (v and v:IsValid() and v.BOT) then
                        local char = v:GetControlledCharacter()
                        if char then
                            CheckToStopBotReviveTimer(char, false)
                            BotResetTarget(v)
                            v:SetValue("BotAimPlayer", nil, true)

                            if char:GetValue("DoingAction") then
                                char:SetValue("DoingAction", nil, false)
                                char:MoveTo(char:GetLocation(), 50)
                            end
                        end
                    end
                end
            else
                for k, v in pairs(PLAYING_PLAYERS) do
                    if (v and v:IsValid() and v.BOT) then
                        local char = v:GetControlledCharacter()
                        if IsValid(char) then
                            if not char:GetValue("PlayerDown") then
                                RequestBotAction(v)
                                v:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
                            end
                        end
                    end
                end
            end
        end
    end
end)