


function ZPlayingPlayerInit(ply)
    PLAYING_PLAYERS_NB = PLAYING_PLAYERS_NB + 1
    table.insert(PLAYING_PLAYERS, ply)
    ply:SetValue("ZMoney", Player_Start_Money, true)
    ply:SetValue("ZScore", 0, false)
    ply:SetValue("ZKills", 0, false)
    ply:SetValue("playing", true, false)
end

function SpawnCharacterForPlayer(ply, spawn_id)
    local cur_char = ply:GetControlledCharacter()
    if cur_char then
        cur_char:Destroy()
    end

    local new_char = Character(PLAYER_SPAWNS[spawn_id].location, PLAYER_SPAWNS[spawn_id].rotation)
    new_char:SetCameraMode(CAMERA_MODE)
    new_char:SetFallDamageTaken(0)
    ply:Possess(new_char)
    new_char:SetHealth(1000 + PlayerHealth)
    new_char:SetTeam(1)
    new_char:SetSpeedMultiplier(PlayerSpeedMultiplier)
    new_char:SetAccelerationSettings(1152, 512, 768, 128, 256, 256, 1024)
    new_char:SetBrakingSettings(2, 2, 128, 3000, 10, 0)
    new_char:SetValue("OwnedPerks", {}, true)
    new_char:SetValue("ZGrenadesNB", Start_Grenades_NB, true)

    AddCharacterWeapon(new_char, Player_Start_Weapon.weapon_name, Player_Start_Weapon.ammo)
end

function GetPlayersInRadius(loc, radius)
    local radius_sq = radius * radius
    local in_radius_players = {}
    for k, v in pairs(Character.GetPairs()) do
        local ply = v:GetPlayer()
        if ply then
            if v:GetLocation():DistanceSquared(loc) <= radius_sq then
                table.insert(in_radius_players, ply)
            end
        end
    end
    return in_radius_players
end

function GetPlayersAliveNB()
    local nb = 0
    for k, v in pairs(PLAYING_PLAYERS) do
        local char = v:GetControlledCharacter()
        if (char and not char:GetValue("PlayerDown")) then
            nb = nb + 1
        end
    end
    return nb
end

function PlayerCharacterDie(char)
    --[[if char:GetValue("PlayerDown") then
        Timer.ClearTimeout(char:GetValue("PlayerDownDieTimer"))
    end]]--
    if char:IsValid() then
        local ply = char:GetPlayer()
        if char:GetValue("RevivingPlayer") then
            local reviving_char = GetCharacterFromId(char:GetValue("RevivingPlayer"))
            if reviving_char then
                reviving_char:SetMovementEnabled(true)
                reviving_char:SetCanAim(true)
            end
        end
        char:Destroy()
        Buy(ply, math.floor(ply:GetValue("ZMoney") * Dead_MoneyLost / 100))
    end
end

function ClearRegenTimeouts(char)
    if char:GetValue("RegenTimeout") then
        Timer.ClearTimeout(char:GetValue("RegenTimeout"))
        char:SetValue("RegenTimeout", nil, false)
    end
    if char:GetValue("RegenInterval") then
        Timer.ClearInterval(char:GetValue("RegenInterval"))
        char:SetValue("RegenInterval", nil, false)
    end
end

Character.Subscribe("TakeDamage", function(char, damage, bone, type, from_direction, instigator, causer)
    local ply = char:GetPlayer()
    if ply then

        if instigator then
            return false
        end

        local chealth = char:GetHealth() - damage
        ClearRegenTimeouts(char)
        if chealth <= 1000 then
            char:SetValue("PlayerDown", true, true)
            Buy(ply, math.floor(ply:GetValue("ZMoney") * Down_MoneyLost / 100))
            char:SetValue("OwnedPerks", {}, true)
            for k, v in pairs(ZOMBIES_CHARACTERS) do
                if (v:GetValue("Target_type") == "player" and v:GetValue("Target") == char) then
                    ZombieRefreshTarget(v)
                end
            end

            local grenade = char:GetPicked()
            if (grenade and NanosUtils.IsA(grenade, Grenade)) then
                grenade:Destroy()
                local charInvID = GetCharacterInventory(char)
                if charInvID then
                    local Inv = PlayersCharactersWeapons[charInvID]
                    EquipSlot(char, Inv.selected_slot)
                end
            end

            char:SetValue(
                "PlayerDownDieTimer",
                Timer.SetTimeout(PlayerCharacterDie, PlayerDeadAfterTimerDown_ms, char),
                false
            )
            char:SetMovementEnabled(false)
            char:SetCanAim(false)
            char:PlayAnimation("nanos-world::A_Mannequin_Sit_Bench", AnimationSlotType.FullBody, true)

            local charInvID = GetCharacterInventory(char)
            if charInvID then
                local Inv = PlayersCharactersWeapons[charInvID]
                for i, v in ipairs(Inv.weapons) do
                    if v.slot == 3 then
                        if v.weapon then
                            if v.weapon:IsValid() then
                                v.destroying = true
                                v.weapon:Destroy()
                            end
                        end
                        table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
                        break
                    end
                end
                if Inv.selected_slot == 3 then
                    EquipSlot(char, 1)
                end
            end

            local al_nb = GetPlayersAliveNB()
            if al_nb == 0 then
                RoundFinished(false, true)
            end
        else
            char:SetValue("RegenTimeout", Timer.SetTimeout(function()
                if char:IsValid() then
                    --print("RegenTimeout, finished")
                    char:SetValue("RegenTimeout", nil, false)
                    char:SetValue("RegenInterval", Timer.SetInterval(function()
                        if char:IsValid() then
                            --print("RegenInterval")
                            local new_health = char:GetHealth() + PlayerRegenAddedHealth
                            local phealth = PlayerHealth
                            local perks = char:GetValue("OwnedPerks")
                            if (perks and perks["juggernog"]) then
                                phealth = PERKS_CONFIG.juggernog.PlayerHealth
                            end
                            if new_health >= 1000 + phealth then
                                char:SetHealth(1000 + phealth)
                                Timer.ClearInterval(char:GetValue("RegenInterval"))
                                char:SetValue("RegenInterval", nil, false)
                            else
                                char:SetHealth(new_health)
                            end
                            Events.CallRemote("UpdateGUIHealth", ply)
                        else
                            return false
                        end
                    end, PlayerRegenInterval_ms), false)
                end
            end, PlayerRegenHealthAfter_ms), false)
        end
    end
end)

Player.Subscribe("Spawn", function(ply)
    print("Player Joined")
    Events.CallRemote("LoadMapConfig", ply, MAP_CONFIG_TO_SEND)
    if ROUND_NB > 0 then
        Events.CallRemote("SetClientRoundNumber", ply, ROUND_NB)
    end
    if POWER_ON then
        Events.CallRemote("SetClientPowerON", ply, true)
    end
    if PLAYING_PLAYERS_NB < MAX_PLAYERS then
        ZPlayingPlayerInit(ply)
        if ROUND_NB == 0 then
            StartRound()
        end
    else
        table.insert(WAITING_PLAYERS, ply)
    end
end)

Player.Subscribe("Destroy", function(ply)
    print("Player Left")
    local char = ply:GetControlledCharacter()
    if char then
        if char:GetValue("PlayerDown") then
            Timer.ClearTimeout(char:GetValue("PlayerDownDieTimer"))
        end
        if char:GetValue("RevivingPlayer") then
            local reviving_char = GetCharacterFromId(char:GetValue("RevivingPlayer"))
            if reviving_char then
                reviving_char:SetMovementEnabled(true)
                reviving_char:SetCanAim(true)
            end
        end
        char:Destroy()
    end
    local p = ply:GetValue("playing")
    if p then
        PLAYING_PLAYERS_NB = PLAYING_PLAYERS_NB - 1
        for k, v in pairs(PLAYING_PLAYERS) do
            if v == ply then
                table.remove(PLAYING_PLAYERS, k)
                break
            end
        end
        if WAITING_PLAYERS[1] then
            local wply = WAITING_PLAYERS[1]
            ZPlayingPlayerInit(wply)
            table.remove(WAITING_PLAYERS, 1)
        end
        if GetPlayersAliveNB() == 0 then
            if PLAYING_PLAYERS_NB == 0 then
                RoundFinished(true)
            else
                RoundFinished(false, true)
            end
        end
    else
        for k, v in pairs(WAITING_PLAYERS) do
            if v == ply then
                table.remove(WAITING_PLAYERS, k)
                break
            end
        end
    end
end)

Events.Subscribe("RevivePlayer", function(ply, revive_char)
    local char = ply:GetControlledCharacter()
    if (char and char:IsValid() and not char:GetValue("PlayerDown")) then
        if revive_char:IsValid() then
            if revive_char:GetValue("PlayerDown") then
                if not revive_char:GetValue("RevivingPlayer") then
                    revive_char:SetValue("RevivingPlayer", char:GetID(), true)
                    char:SetMovementEnabled(false)
                    char:SetCanAim(false)
                end
            end
        end
    end
end)

Events.Subscribe("RevivePlayerFinished", function(ply, revived_char)
    local reviving_char = ply:GetControlledCharacter()
    if (ply:IsValid() and revived_char:IsValid() and reviving_char) then
        if revived_char:GetValue("RevivingPlayer") == reviving_char:GetID() then
            revived_char:SetValue("RevivingPlayer", nil, true)
            revived_char:SetValue("PlayerDown", nil, true)
            Timer.ClearTimeout(revived_char:GetValue("PlayerDownDieTimer"))
            revived_char:SetValue("PlayerDownDieTimer", nil, false)
            revived_char:SetMovementEnabled(true)
            revived_char:SetCanAim(true)
            revived_char:StopAnimation("nanos-world::A_Mannequin_Sit_Bench")
            revived_char:SetHealth(1000 + PlayerHealth)
            Events.CallRemote("UpdateGUIHealth", revived_char:GetPlayer())

            AddMoney(ply, Player_Revive_Money)
            reviving_char:SetMovementEnabled(true)
            reviving_char:SetCanAim(true)
        end
    end
end)

Events.Subscribe("RevivePlayerStopped", function(ply, revived_char)
    local reviving_char = ply:GetControlledCharacter()
    if (ply:IsValid() and revived_char:IsValid() and reviving_char) then
        if revived_char:GetValue("RevivingPlayer") == reviving_char:GetID() then
            revived_char:SetValue("RevivingPlayer", nil, true)
            reviving_char:SetMovementEnabled(true)
            reviving_char:SetCanAim(true)
        end
    end
end)

Events.Subscribe("RequestTabData", function(ply)
    if ply:IsValid() then
        local tblToSend = {}
        for k, v in pairs(PLAYING_PLAYERS) do
            table.insert(tblToSend, {
                v:GetAccountName(),
                tostring(v:GetValue("ZKills")),
                tostring(v:GetValue("ZScore")),
                tostring(v:GetPing()),
            })
        end
        Events.CallRemote("TabData", ply, tblToSend)
    end
end)

if ZDEV_MODE then
    Server.Subscribe("Chat", function(text, sender)
        if text == "/kill" then
            local char = sender:GetControlledCharacter()
            if char then
                local health = char:GetHealth()
                char:ApplyDamage(health - 1000)
            end
        end
    end)
end