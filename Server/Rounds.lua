
POWER_ON = false


PLAYING_PLAYERS = {}
WAITING_PLAYERS = {}

GAME_LEFT_PLAYERS_STATS = {}

ROUND_NB = 0
REMAINING_ENEMIES_TO_SPAWN = 0
GAME_TIMER_SECONDS = 0
KILL_COUNT = 0
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

    for k, v in pairs(PLAYING_PLAYERS) do
        if v:IsValid() then
            if not v.BOT then
                if v:GetValue("PlayerXP") then
                    Events.CallRemote("PlayerLevelXPUpdate", v, v:GetValue("PlayerLevel"), v:GetValue("PlayerXP"))
                end
            end
        end
    end

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
        Events.Call("VZ_GameEnding", restart_game)

        ROUND_NB = 0
        ResetMapPower()
        SPAWNS_UNLOCKED = {}
        SPAWNS_ENABLED = {}
        ROOMS_UNLOCKED = {}
        ROOMS_SPAWNS_DISABLED = {}
        GAME_LEFT_PLAYERS_STATS = {}
        DestroyEnemies()
        DestroyBosses()
        DestroyMapDoors()
        DestroyPowerups()
        DestroyMapGrenades()

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

        if DestroyVehicles then
            DestroyVehicles()
        end

        if DestroyPreReachTriggers then
            DestroyPreReachTriggers()
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
                if WaitingMapvote == nil then
                    if StartMapVote then
                        WaitingMapvote = StartMapVote(Mapvote_tbl)
                    end
                end
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

        KILL_COUNT = 0

        GAME_TIMER_SECONDS = 0
        if Game_Time_On_Screen then
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

        GAME_LEFT_PLAYERS_STATS = {}
    end

    ROUND_NB = ROUND_NB + 1
    Events.BroadcastRemote("SetClientRoundNumber", ROUND_NB, CanStartHellhoundRound())
    REMAINING_ENEMIES_TO_SPAWN = math.floor(Zombies_Number_Mult_Func(First_Wave_Enemies + (Add_at_each_wave * (ROUND_NB - 1)) + (Add_at_each_wave_per_player * (ROUND_NB - 1) * PLAYING_PLAYERS_NB), ROUND_NB) + 0.5)
    if CanStartHellhoundRound() then
        if Enemies_Config.Hellhound.Spawning_Config.Number_To_Spawn_mult then
            REMAINING_ENEMIES_TO_SPAWN = math.floor(REMAINING_ENEMIES_TO_SPAWN * Enemies_Config.Hellhound.Spawning_Config.Number_To_Spawn_mult)
        end
    end

    --print(REMAINING_ENEMIES_TO_SPAWN)

    SendEnemiesRemaining()

    ENEMIES_TO_SPAWN_TBL = {}

    if not CanStartHellhoundRound() then
        local MaxPercentages = {}

        local SpawningPercentages = {}
        for k, v in pairs(FirstWave) do
            SpawningPercentages[k] = {}
            MaxPercentages[k] = 0
            for k2, v2 in pairs(Enemies_Config[k].Types) do
                SpawningPercentages[k][k2] = 0
            end
            for k2, v2 in pairs(v) do
                SpawningPercentages[k][k2] = v2
                MaxPercentages[k] = MaxPercentages[k] + v2
            end
        end

        for k, v in pairs(Added_Per_Wave_Percentage) do
            for k2, v2 in pairs(v) do
                local calculated = v2 * (ROUND_NB - 1)
                if calculated > MaxPercentages[k] then
                    calculated = MaxPercentages[k]
                end

                for k3, v3 in pairs(SpawningPercentages) do
                    for k4, v4 in pairs(v3) do
                        if (k3 == k and k4 ~= k2) then
                            SpawningPercentages[k][k4] = v4 - calculated
                        end
                    end
                end

                SpawningPercentages[k][k2] = SpawningPercentages[k][k2] + calculated
            end
        end
        --print(NanosTable.Dump(SpawningPercentages))

        local SpawningCount = {}
        for k, v in pairs(SpawningPercentages) do
            SpawningCount[k] = {}
            for k2, v2 in pairs(v) do
                if v2 > 0 then
                    SpawningCount[k][k2] = math.floor((REMAINING_ENEMIES_TO_SPAWN * v2/100) + 0.5)
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
            for k, v in pairs(Added_Per_Wave_Percentage) do
                for k2, v2 in pairs(v) do
                    table.insert(added_per_wave_names, {k, k2})
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
                        RequestBotAction(v)
                        v:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
                    end
                end
            end
        end
    end
end)