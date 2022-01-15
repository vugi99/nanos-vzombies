
POWER_ON = false


PLAYING_PLAYERS = {}

ROUND_NB = 0
REMAINING_ZOMBIES_TO_SPAWN = 0

ZOMBIES_TO_SPAWN_TBL = {}

WaitingNewRound_Timer = nil

function RoundFinished(reset_all, restart_game)
    print("RoundFinished", reset_all, restart_game)
    if WaitingNewRound_Timer then
        Timer.ClearTimeout(WaitingNewRound_Timer)
        WaitingNewRound_Timer = nil
    end
    Timer.ClearInterval(ZOMBIES_SPAWN_INTERVAL)
    ZOMBIES_SPAWN_INTERVAL = 0
    REMAINING_ZOMBIES_TO_SPAWN = 0
    if (not reset_all and not restart_game) then
        for k, v in pairs(PLAYING_PLAYERS) do
            if not v:GetControlledCharacter() then
                SpawnCharacterForPlayer(v, k)
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
        DestroyBarricades()
        DestroyMapDoors()
        DestroyPowerups()

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
            Events.BroadcastRemote("GameOver")
        else
            Events.BroadcastRemote("WaveFinished")
        end
        WaitingNewRound_Timer = Timer.SetTimeout(function()
            WaitingNewRound_Timer = nil
            if PLAYING_PLAYERS_NB > 0 then
                StartRound()
            end
        end, t)
    end
end

function StartRound()
    print("StartRound")
    if ROUND_NB == 0 then
        SpawnMapDoors()
        SpawnMapBarricades()
        PickNewMysteryBox()
        UnlockRoom(1)
    end
    ROUND_NB = ROUND_NB + 1
    Events.BroadcastRemote("SetClientRoundNumber", ROUND_NB)
    REMAINING_ZOMBIES_TO_SPAWN = first_wave_zombies[1] + (Add_at_each_wave[1] * (ROUND_NB - 1))

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
            SpawnCharacterForPlayer(v, k)
        end
    end
    ZOMBIES_SPAWN_INTERVAL = Timer.SetInterval(SpawnZombieIntervalFunc, math.ceil(Zombies_Spawn_Cooldown/REMAINING_ZOMBIES_TO_SPAWN))
    SpawnZombieIntervalFunc()
end