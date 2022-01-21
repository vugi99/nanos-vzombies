


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

    local new_char = Character(PLAYER_SPAWNS[spawn_id].location + Vector(0, 0, 105), PLAYER_SPAWNS[spawn_id].rotation)
    if not ply.BOT then
        new_char:SetCameraMode(CAMERA_MODE)
    end
    new_char:SetFallDamageTaken(0)
    ply:Possess(new_char)
    new_char:SetHealth(1000 + PlayerHealth)
    new_char:SetTeam(1)
    new_char:SetSpeedMultiplier(PlayerSpeedMultiplier)
    new_char:SetAccelerationSettings(1152, 512, 768, 128, 256, 256, 1024)
    new_char:SetBrakingSettings(2, 2, 128, 3000, 10, 0)
    new_char:SetValue("OwnedPerks", {}, true)
    new_char:SetValue("ZGrenadesNB", Start_Grenades_NB, true)
    new_char:SetValue("CanUseKnife", true, true)
    new_char:SetValue("InFlashlightZones", {}, false)

    if ply.BOT then
        new_char:SetGaitMode(GaitMode.Sprinting)
    end

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

function GetRandomPlayer()
    local players = Player.GetAll()
    return players[math.random(table_count(players))]
end

function GetRandomPlayerWOOne(ply)
    local players = Player.GetAll()
    local new_tbl = {}
    for k, v in pairs(players) do
        if v ~= ply then
            table.insert(new_tbl, v)
        end
    end
    return new_tbl[math.random(table_count(new_tbl))]
end

function GetPlayersInRadius_ToTeleport(not_ply, loc, radius_sq)
    local in_radius_players = {}
    for k, v in pairs(Character.GetPairs()) do
        local ply = v:GetPlayer()
        if ply then
            if ply ~= not_ply then
                if not v:GetValue("PlayerDown") then
                    if v:GetLocation():DistanceSquared(loc) <= radius_sq then
                        table.insert(in_radius_players, ply)
                    end
                end
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

function GetPlayersWOBotsAliveNB()
    local nb = 0
    for k, v in pairs(PLAYING_PLAYERS) do
        if not v.BOT then
            local char = v:GetControlledCharacter()
            if (char and not char:GetValue("PlayerDown")) then
                nb = nb + 1
            end
        end
    end
    return nb
end

function GetPlayingPlayersWOBots()
    local nb = 0
    for k, v in pairs(PLAYING_PLAYERS) do
        if not v.BOT then
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
                CheckToStopBotReviveTimer(reviving_char, true)
            end
        end
        char:Destroy()
        Buy(ply, math.floor(ply:GetValue("ZMoney") * Dead_MoneyLost / 100))

        -- For When the character is destroyed because of Z Limits
        local al_nb = GetPlayersAliveNB()
        if al_nb == 0 then
            RoundFinished(false, true)
        end
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

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, type, from_direction, instigator, causer)
    local ply = char:GetPlayer()
    if ply then

        if causer then
            if causer:IsValid() then
                local instig_char = causer:GetHandler()
                if instig_char then
                    local bot = instig_char:GetPlayer()
                    if (bot and bot.BOT) then
                        instigator = bot
                    end
                end
            end
        end

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

            local picked_thing = char:GetPicked()
            if (picked_thing and (NanosUtils.IsA(picked_thing, Grenade) or NanosUtils.IsA(picked_thing, Melee))) then
                picked_thing:Destroy()
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
            char:SetSpeedMultiplier(PlayerSpeedMultiplier)
            if not ply.BOT then
                char:SetMovementEnabled(false)
                char:SetCanAim(false)
            end
            char:PlayAnimation("nanos-world::A_Mannequin_Sit_Bench", AnimationSlotType.FullBody, true)

            CheckToStopBotReviveTimer(char, false)
            if ply.BOT then
                BotResetTarget(ply)
                ply:SetValue("BotAimPlayer", nil, true)

                if char:GetValue("DoingAction") then
                    --print("STOP MOVETO BOT")
                    char:SetValue("DoingAction", nil, false)
                    char:MoveTo(char:GetLocation(), 50)
                end
            end

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

function HandlePlayerJoin(ply, bot)
    print("Player Joined", ply:GetAccountName())
    if not bot then
        Events.CallRemote("LoadMapConfig", ply, MAP_CONFIG_TO_SEND)
        if ROUND_NB > 0 then
            Events.CallRemote("SetClientRoundNumber", ply, ROUND_NB)
            SendZombiesRemaining(ply)
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
            local found_bot
            local game_restart
            for k, v in pairs(PLAYING_PLAYERS) do
                if v.BOT then
                    found_bot = true
                    local char = v:GetControlledCharacter()
                    if char then
                        char:Destroy()
                    end
                    v:Kick()
                    if GetPlayersAliveNB() == 0 then
                        game_restart = true
                    end
                    break
                end
            end
            if (game_restart or found_bot) then
                ZPlayingPlayerInit(ply)
                if game_restart then
                    RoundFinished(false, true)
                end
            else
                table.insert(WAITING_PLAYERS, ply)
            end
        end
    else
        ZPlayingPlayerInit(ply)
    end
end
VZ_EVENT_SUBSCRIBE("Player", "Spawn", HandlePlayerJoin)
VZ_EVENT_SUBSCRIBE("Events", "VZPlayerJoinedAfterReload", HandlePlayerJoin)

VZ_EVENT_SUBSCRIBE("Player", "Destroy", function(ply)
    print("Player Left", ply:GetAccountName())
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
                CheckToStopBotReviveTimer(reviving_char, true)
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
        local player_was_waiting
        if WAITING_PLAYERS[1] then
            local wply = WAITING_PLAYERS[1]
            ZPlayingPlayerInit(wply)
            table.remove(WAITING_PLAYERS, 1)
            player_was_waiting = true
        end
        if GetPlayersWOBotsAliveNB() == 0 then
            if GetPlayingPlayersWOBots() == 0 then
                RoundFinished(true, false, ply)
            else
                RoundFinished(false, true, ply)
            end
        elseif (Bots_Enabled and not player_was_waiting) then
            local bot_count = table_count(VZBot.GetPairs())
            if bot_count < Max_Bots then
                local Bot = VZBotJoin()
                HandlePlayerJoin(Bot, true)
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
    PlayerLeftCheckSyncPlayers(ply)
end)

function RevivePlayer(ply, revive_char)
    local char = ply:GetControlledCharacter()
    if (char and char:IsValid() and not char:GetValue("PlayerDown")) then
        if revive_char:IsValid() then
            if revive_char:GetValue("PlayerDown") then
                if not revive_char:GetValue("RevivingPlayer") then
                    revive_char:SetValue("RevivingPlayer", char:GetID(), true)
                    char:SetMovementEnabled(false)
                    char:SetCanAim(false)
                    return true
                end
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "RevivePlayer", RevivePlayer)


function RevivePlayerFinished(ply, revived_char)
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
            local revived_ply = revived_char:GetPlayer()
            Events.CallRemote("UpdateGUIHealth", revived_ply)
            if revived_ply.BOT then
                RequestBotAction(revived_ply)
                revived_ply:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
            end

            AddMoney(ply, Player_Revive_Money)
            reviving_char:SetMovementEnabled(true)
            reviving_char:SetCanAim(true)
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "RevivePlayerFinished", RevivePlayerFinished)

function RevivePlayerStopped(ply, revived_char)
    local reviving_char = ply:GetControlledCharacter()
    if (ply:IsValid() and revived_char:IsValid() and reviving_char) then
        if revived_char:GetValue("RevivingPlayer") == reviving_char:GetID() then
            revived_char:SetValue("RevivingPlayer", nil, true)
            reviving_char:SetMovementEnabled(true)
            reviving_char:SetCanAim(true)
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "RevivePlayerStopped", RevivePlayerStopped)

VZ_EVENT_SUBSCRIBE("Events", "RequestTabData", function(ply)
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

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Server", "Chat", function(text, sender)
        if text then
            local splited_text = split_str(text, " ")
            local char
            if (splited_text[1] and splited_text[1] == "/kill" and splited_text[2]) then
                local name = splited_text[2]
                if splited_text[3] then
                    for i = 3, table_count(splited_text) do
                        name = name .. " " .. splited_text[i]
                    end
                end
                for k, v in pairs(Player.GetPairs()) do
                    --print(v)
                    if v:GetAccountName() == name then
                        char = v:GetControlledCharacter()
                        break
                    end
                end
            elseif text == "/kill" then
                char = sender:GetControlledCharacter()
            end
            if (char and char:GetHealth() > 0) then
                local health = char:GetHealth()
                char:ApplyDamage(health - 1000)
            end
        end
    end)
end

function GiveCharacterPerk(char, perk_name)
    local ply = char:GetPlayer()
    local char_perks = char:GetValue("OwnedPerks")
    char_perks[perk_name] = true
    char:SetValue("OwnedPerks", char_perks, true)
    if perk_name == "juggernog" then
        ClearRegenTimeouts(char)
        char:SetHealth(1000 + PERKS_CONFIG.juggernog.PlayerHealth)
        Events.CallRemote("UpdateGUIHealth", ply)
    elseif perk_name == "stamin_up" then
        char:SetSpeedMultiplier(PERKS_CONFIG.stamin_up.Speed_Multiplier)
    end
end

VZ_EVENT_SUBSCRIBE("Events", "CustomMapInteract", function(ply, InteractThing)
    Events.Call(InteractThing.event_name, ply, InteractThing)
end)

local last_sent_value = -1

function SendZombiesRemaining(ply)
    if Remaining_Zombies_Text then
        local remaining = REMAINING_ZOMBIES_TO_SPAWN + table_count(ZOMBIES_CHARACTERS)
        if not ply then
            if last_sent_value ~= remaining then
                Events.BroadcastRemote("SetClientRemainingZombies", remaining)
            end
        else
            Events.CallRemote("SetClientRemainingZombies", ply, remaining)
        end
    end
end

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Server", "Chat", function(text, ply)
        if text == "/noclip" then
            local char = ply:GetControlledCharacter()
            if char then
                local noclip = char:GetValue("NoClip")
                if noclip then
                    char:SetFlyingMode(false)
                    char:SetCollision(CollisionType.Normal)
                else
                    char:SetFlyingMode(true)
                    char:SetCollision(CollisionType.NoCollision)
                end
                char:SetValue("NoClip", not noclip, false)
            end
        end
    end)
end