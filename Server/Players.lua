


function ZPlayingPlayerInit(ply)
    PLAYING_PLAYERS_NB = PLAYING_PLAYERS_NB + 1
    table.insert(PLAYING_PLAYERS, ply)

    local ZMoney = Player_Start_Money
    local ZScore = 0
    local ZKills = 0

    if GAME_LEFT_PLAYERS_STATS[ply:GetSteamID()] then
        if GAME_LEFT_PLAYERS_STATS[ply:GetSteamID()][1] > Player_Start_Money then
            ZMoney = GAME_LEFT_PLAYERS_STATS[ply:GetSteamID()][1]
        end
        ZScore = GAME_LEFT_PLAYERS_STATS[ply:GetSteamID()][2]
        ZKills = GAME_LEFT_PLAYERS_STATS[ply:GetSteamID()][3]
    end

    ply:SetValue("ZMoney", ZMoney, true)
    ply:SetValue("ZScore", ZScore, false)
    ply:SetValue("ZKills", ZKills, false)
    ply:SetValue("playing", true, false)
end

function SpawnCharacterForPlayer(ply, spawn_id)
    local cur_char = ply:GetControlledCharacter()
    if cur_char then
        cur_char:Destroy()
    end

    local PM_Data = ply:GetValue("PM_Data") or {
        Model = nil,
        Parameters = {},
    }

    if not PM_Data.Model then
        local pm_names = {}
        local count = 0
        for k, v in pairs(Player_Models) do
            if v then
                table.insert(pm_names, k)
                count = count + 1
            end
        end

        if count > 0 then
            local random_pm_name = pm_names[math.random(count)]
            PM_Data.Model = Player_Models[random_pm_name].Models[math.random(table_count(Player_Models[random_pm_name].Models))]

            if Player_Models[random_pm_name].Random_Parameters then
                for i, v in ipairs(Player_Models[random_pm_name].Random_Parameters) do
                    if v.type == "Color" then
                        local r_color = Color.Random()
                        table.insert(PM_Data.Parameters, {v.type, v.name, r_color})
                    end
                end
            end
        else
            PM_Data.Model = "nanos-world::SK_Mannequin"
            Console.Warn("No Player_Models found, using Mannequin as fallback")
        end
    end

    local pain_sound = "nanos-world::A_Male_01_Pain"
    if PM_Data.gender == "male" then
        pain_sound = Player_Pain_Sounds_Male[math.random(table_count(Player_Pain_Sounds_Male))]
    elseif PM_Data.gender == "female" then
        pain_sound = Player_Pain_Sounds_Female[math.random(table_count(Player_Pain_Sounds_Male))]
    end

    local new_char = Character(PLAYER_SPAWNS[spawn_id].location + Vector(0, 0, 105), PLAYER_SPAWNS[spawn_id].rotation, PM_Data.Model, CollisionType.Auto, true, 100, "nanos-world::A_Male_01_Death", pain_sound)
    if not ply.BOT then
        new_char:SetCameraMode(ply:GetValue("MM_CamMode") or CAMERA_MODE)
    end
    new_char:SetFallDamageTaken(0)
    ply:Possess(new_char)
    new_char:SetHealth(1000 + PlayerHealth)
    new_char:SetTeam(1)
    new_char:SetSpeedMultiplier(PlayerSpeedMultiplier)
    new_char:SetAccelerationSettings(1152, 512, 768, 128, 256, 256, 1024)
    new_char:SetBrakingSettings(2, 2, 128, 3000, 10, 0)
    new_char:SetCapsuleSize(table.unpack(Player_Capsule_Size))
    new_char:SetRadialDamageToRagdoll(Character_RadialDamageToRagdoll)

    new_char:SetValue("OwnedPerks", {}, true)
    new_char:SetValue("ZGrenadesNB", Start_Grenades_NB, true)
    new_char:SetValue("CanUseKnife", true, true)
    new_char:SetValue("InFlashlightZones", {}, false)
    new_char:SetValue("WeirdPunchCount", 0, false)


    if ply.BOT then
        new_char:SetGaitMode(GaitMode.Sprinting)
    end

    for i, v in ipairs(PM_Data.Parameters) do
        if v[1] == "Color" then
            new_char:SetMaterialColorParameter(v[2], v[3])
        end
    end

    ply:SetValue("PM_Data", PM_Data, false)

    AddCharacterWeapon(new_char, Player_Start_Weapon.weapon_name, Player_Start_Weapon.ammo)

    if not ply.BOT then
        if (not VZA_MutedVOIPPlayers or not VZA_MutedVOIPPlayers[ply:GetSteamID()]) then
            ply:SetVOIPSetting(Player_VOIP_Setting_Alive)
        end
    end

    Events.Call("VZ_PlayerCharacterSpawned", new_char)
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
        if (char and (not char:GetValue("PlayerDown") or char:GetValue("SoloQuickReviving"))) then
            nb = nb + 1
        end
    end
    return nb
end

function GetPlayersAlive()
    local tbl = {}
    for k, v in pairs(PLAYING_PLAYERS) do
        local char = v:GetControlledCharacter()
        if (char and not char:GetValue("PlayerDown")) then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function GetPlayersWOBotsAliveNB()
    local nb = 0
    for k, v in pairs(PLAYING_PLAYERS) do
        if not v.BOT then
            local char = v:GetControlledCharacter()
            if (char and (not char:GetValue("PlayerDown") or char:GetValue("SoloQuickReviving"))) then
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
        --[[if char:GetValue("RevivingPlayer") then
            local reviving_char = GetCharacterFromId(char:GetValue("RevivingPlayer"))
            if reviving_char then
                reviving_char:SetInputEnabled(true)
                reviving_char:SetCanAim(true)
                CheckToStopBotReviveTimer(reviving_char, true)
            end
        end]]--
        if not char:GetValue("RevivingPlayer") then
            ply:SetVOIPSetting(VOIPSetting.Muted)

            char:Destroy()
            Buy(ply, math.floor(ply:GetValue("ZMoney") * Dead_MoneyLost / 100))

            for k, v in pairs(Player.GetPairs()) do
                if v ~= ply then
                    Events.CallRemote("AddNotification", v, ply:GetAccountName() .. " died", 10000)
                end
            end

            -- For When the character is destroyed because of Z Limits
            local al_nb = GetPlayersAliveNB()
            if al_nb == 0 then
                RoundFinished(false, true)
            end
        else
            char:SetValue("RevivingLastChance", true, false)
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

function ApplyGriefFreeze(ply, char)
    if VZ_SELECTED_GAMEMODE == "GRIEF" then
        if (VZ_GetGamemodeConfigValue("Freeze_Player_Time_ms") and VZ_GetGamemodeConfigValue("Freeze_Player_Time_ms") > 0) then
            if char:GetValue("GriefFreezeTimeout") then
                if Timer.IsValid(char:GetValue("GriefFreezeTimeout")) then
                    Timer.ClearTimeout(char:GetValue("GriefFreezeTimeout"))
                end
            end

            if not ply.BOT then
                char:SetInputEnabled(false)
                char:SetCanAim(false)
            end

            CheckToStopBotReviveTimer(char, false)
            if ply.BOT then
                BotResetTarget(ply)
                ply:SetValue("BotAimPlayer", nil, true)

                if char:GetValue("DoingAction") then
                    char:SetValue("DoingAction", nil, false)
                    char:MoveTo(char:GetLocation(), 50)
                end
            end
            char:SetValue("GriefFreezeTimeout", Timer.SetTimeout(function()
                char:SetValue("GriefFreezeTimeout", nil, false)
                if char:IsValid() then
                    if not char:GetValue("PlayerDown") then
                        if not ply.BOT then
                            char:SetInputEnabled(true)
                            char:SetCanAim(true)
                        else
                            RequestBotAction(ply)
                            ply:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
                        end
                    end
                end
            end, VZ_GetGamemodeConfigValue("Freeze_Player_Time_ms")), false)

            Events.CallRemote("PlayVZSound", ply, {basic_sound_tbl=Player_Grief_Sound})
        end
    end
end

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, type, from_direction, instigator, causer)
    local ply = char:GetPlayer()
    if ply then

        --print(ply, causer, "TakeDamage")

        if causer then
            if causer:IsValid() then
                if not causer:IsA(Character) then
                    local instig_char
                    if IsAVehicle(causer) then
                        instig_char = causer:GetPassenger(0)
                    else
                        instig_char = causer:GetHandler()
                    end
                    if instig_char then
                        local bot = instig_char:GetPlayer()
                        if (bot and bot.BOT) then
                            instigator = bot
                        end
                    end
                end
            end
        end

        if char:GetValue("PlayerDown") then
            return false
        end

        if instigator then
            --print("FALSE TakeDamage")
            if not VZ_GetGamemodeConfigValue("Friendly_Damage") then
                ApplyGriefFreeze(ply, char)
                return false
            end
        end

        local chealth = char:GetHealth() - damage
        ClearRegenTimeouts(char)
        if chealth <= 1000 then
            if char:GetVehicle() then
                char:LeaveVehicle()
            end

            local solo_quick_revive

            if PLAYING_PLAYERS_NB == 1 then -- solo
                solo_quick_revive = char:GetValue("OwnedPerks").quick_revive
            end

            char:SetValue("SoloQuickReviving", solo_quick_revive, true)

            char:SetValue("PlayerDown", true, true)
            Buy(ply, math.floor(ply:GetValue("ZMoney") * Down_MoneyLost / 100))
            char:SetValue("OwnedPerks", {}, true)
            for k, v in pairs(GetMergedEnemiesChars()) do
                if (v:GetValue("Target_type") == "player" and v:GetValue("Target") == char) then
                    EnemyRefreshTarget(v)
                end
            end

            local picked_thing = char:GetPicked()
            if (picked_thing and (picked_thing:IsA(Grenade) or picked_thing:IsA(Melee))) then
                picked_thing:Destroy()
                local charInvID = GetCharacterInventory(char)
                if charInvID then
                    local Inv = PlayersCharactersWeapons[charInvID]
                    EquipSlot(char, Inv.selected_slot)
                end
            end

            if char:GetValue("PlayerGrabbedBy") then
                char:StopAnimation("vzombies-assets::AS_NAAT_Human_Grab_To_Wrestle")
                char:SetValue("PlayerGrabbedBy", nil, true)
            end

            if not solo_quick_revive then
                char:SetValue(
                    "PlayerDownDieTimer",
                    Timer.SetTimeout(PlayerCharacterDie, PlayerDeadAfterTimerDown_ms, char),
                    false
                )
            end
            char:SetSpeedMultiplier(PlayerSpeedMultiplier)
            if not ply.BOT then
                char:SetInputEnabled(false)
                char:SetCanAim(false)
            end
            char:PlayAnimation("vzombies-assets::Death_Idle", AnimationSlotType.FullBody, true)

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

            -- Remove third weapon from inventory (if the player had three gun)
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

            -- Remove Speed Reload on equipped weapon (if the player had speed cola)
            local weap = char:GetPicked()
            if weap then
                if not weap:IsA(Grenade) and not weap:IsA(Melee) then
                    weap:ActivateSpeedReload(false)
                end
            end

            if solo_quick_revive then
                Timer.SetTimeout(function()
                    if char:IsValid() then
                        char:SetValue("SoloQuickReviving", nil, true)
                        RevivePlayerFinished_RevivedPart(char)
                    end
                end, PERKS_CONFIG.quick_revive.Solo_ReviveTime_ms)
            end

            Events.Call("VZ_CharacterDown", char)

            local al_nb = GetPlayersAliveNB()
            if al_nb == 0 then
                RoundFinished(false, true)
            end
        else
            if instigator then
                ApplyGriefFreeze(ply, char)
            end

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

function HandlePlayerJoin(ply, bot, waittostart)
    print("Player Joined", ply:GetAccountName())
    --print(ply:GetIP(), Server.GetIP())
    if not bot then

        -- Send required info to players when they join

        if Parse_Custom_Settings then
            Events.CallRemote("SendCustomSettingsToClient", ply, Server.GetCustomSettings())
        end

        Events.CallRemote("LoadMapConfig", ply, MAP_CONFIG_TO_SEND)
        if ROUND_NB > 0 then
            Events.CallRemote("SetClientRoundNumber", ply, ROUND_NB)
            SendEnemiesRemaining(ply)
            if Game_Time_On_Screen then
                Events.CallRemote("UpdateGameTime", ply, math.floor(GAME_TIMER_SECONDS))
            end
        end

        if POWER_ON then
            Events.CallRemote("SetClientPowerON", ply, true)
        end

        if GAME_PAUSED then
            Events.CallRemote("ClientPauseGame", ply, GAME_PAUSED)
        end

        if (ply:GetIP() == "127.0.0.1" and Can_Host_Pause_Game) then
            Events.CallRemote("PlayerCanPause", ply, true)
        end

        ply:SetVOIPSetting(VOIPSetting.Muted)

        -- Players join handle
        if PLAYING_PLAYERS_NB < MAX_PLAYERS then
            if not No_Players then
                ZPlayingPlayerInit(ply)
            else
                table.insert(WAITING_PLAYERS, ply)
                local waiting_val = true
                if No_Players then
                    waiting_val = "No_Players"
                end
                ply:SetValue("PlayerWaiting", waiting_val, true)
            end
            if ROUND_NB == 0 then
                if not WaitingNewRound_Timer then
                    if not waittostart then
                        StartRound()
                    end
                end
            end
        else
            local found_bot
            local game_restart
            if not No_Players then
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
            end
            if ((game_restart or found_bot) and not No_Players) then
                ZPlayingPlayerInit(ply)
                if game_restart then
                    RoundFinished(false, true)
                end
            else
                table.insert(WAITING_PLAYERS, ply)
                local waiting_val = true
                if No_Players then
                    waiting_val = "No_Players"
                end
                ply:SetValue("PlayerWaiting", waiting_val, true)
            end
        end

        Events.Call("VZ_PlayerJoined", ply, waittostart)
    else
        ZPlayingPlayerInit(ply)
    end
end
VZ_EVENT_SUBSCRIBE("Player", "Spawn", HandlePlayerJoin)
VZ_EVENT_SUBSCRIBE("Events", "VZOMBIES_GAMEMODE_LOADED", function()
    local OneJoined
    for k, v in pairs(Player.GetPairs()) do
        HandlePlayerJoin(v, false, true)
        OneJoined = true
    end
    if OneJoined then
        StartRound()
    end
end)

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
                reviving_char:SetInputEnabled(true)
                reviving_char:SetCanAim(true)
                CheckToStopBotReviveTimer(reviving_char, true)
            end
        end
        for k, v in pairs(PLAYING_PLAYERS) do
            local ochar = v:GetControlledCharacter()
            if ochar then
                if ochar:GetValue("RevivingPlayer") == char:GetID() then
                    if ochar:GetValue("RevivingLastChance") then
                        PlayerCharacterDie(ochar)
                    end
                    break
                end
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
            wply:SetValue("PlayerWaiting", nil, true)
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
        if No_Players then
            if table_count(Player.GetAll()) - 1 == 0 then
                RoundFinished(true, false, ply)
            end
        end
    end
    PlayerLeftCheckSyncPlayers(ply)

    if ply:GetValue("ZMoney") then
        GAME_LEFT_PLAYERS_STATS[ply:GetSteamID()] = {
            ply:GetValue("ZMoney"),
            ply:GetValue("ZScore"),
            ply:GetValue("ZKills"),
        }
    end

    Events.Call("VZ_PlayerLeft", ply)
end)

function RevivePlayer(ply, revive_char)
    local char = ply:GetControlledCharacter()
    if (char and char:IsValid() and not char:GetValue("PlayerDown")) then
        if (revive_char and revive_char:IsValid()) then
            if revive_char:GetValue("PlayerDown") then
                if not revive_char:GetValue("RevivingPlayer") then
                    revive_char:SetValue("RevivingPlayer", char:GetID(), true)
                    char:SetInputEnabled(false)
                    char:SetCanAim(false)
                    return true
                end
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("RevivePlayer", RevivePlayer)


function RevivePlayerFinished_RevivedPart(revived_char)
    revived_char:SetValue("RevivingPlayer", nil, true)

    revived_char:SetValue("PlayerDown", nil, true)
    if revived_char:GetValue("PlayerDownDieTimer") then
        Timer.ClearTimeout(revived_char:GetValue("PlayerDownDieTimer"))
    end
    revived_char:SetValue("PlayerDownDieTimer", nil, false)
    revived_char:SetInputEnabled(true)
    revived_char:SetCanAim(true)
    revived_char:StopAnimation("vzombies-assets::Death_Idle")
    revived_char:SetHealth(1000 + PlayerHealth)
    local revived_ply = revived_char:GetPlayer()
    Events.CallRemote("UpdateGUIHealth", revived_ply)
    if revived_ply.BOT then
        RequestBotAction(revived_ply)
        revived_ply:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
    end
end


function RevivePlayerFinished(ply, revived_char)
    local reviving_char = ply:GetControlledCharacter()
    if (ply:IsValid() and revived_char:IsValid() and reviving_char) then
        if revived_char:GetValue("RevivingPlayer") == reviving_char:GetID() then
            revived_char:SetValue("RevivingPlayer", nil, true)
            if not reviving_char:GetValue("PlayerDown") then
                RevivePlayerFinished_RevivedPart(revived_char)

                AddMoney(ply, Player_Revive_Money)
                reviving_char:SetInputEnabled(true)
                reviving_char:SetCanAim(true)
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("RevivePlayerFinished", RevivePlayerFinished)

function RevivePlayerStopped(ply, revived_char)
    local reviving_char = ply:GetControlledCharacter()
    if (ply:IsValid() and revived_char:IsValid() and reviving_char) then
        if revived_char:GetValue("RevivingPlayer") == reviving_char:GetID() then
            revived_char:SetValue("RevivingPlayer", nil, true)
            if not reviving_char:GetValue("PlayerDown") then
                reviving_char:SetInputEnabled(true)
                reviving_char:SetCanAim(true)
            end
            if revived_char:GetValue("RevivingLastChance") then
                PlayerCharacterDie(revived_char)
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("RevivePlayerStopped", RevivePlayerStopped)

VZ_EVENT_SUBSCRIBE_REMOTE("RequestTabData", function(ply)
    if ply:IsValid() then
        local tblToSend = {}
        for k, v in pairs(PLAYING_PLAYERS) do
            local level = tostring(v:GetValue("PlayerLevel"))
            if (v.BOT and VZ_GetFeatureValue("Levels", "script_loaded")) then
                level = "0"
            end
            table.insert(tblToSend, {
                v:GetAccountName(),
                tostring(v:GetValue("ZKills")),
                tostring(v:GetValue("ZMoney")),
                tostring(v:GetValue("ZScore")),
                tostring(v:GetPing()),
                level,
            })
        end
        Events.CallRemote("TabData", ply, tblToSend)
    end
end)

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Chat", "PlayerSubmit", function(text, sender)
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

VZ_EVENT_SUBSCRIBE_REMOTE("CustomMapInteract", function(ply, InteractThing)
    Events.Call(InteractThing.event_name, ply, InteractThing)
end)

local last_sent_value = -1

function SendEnemiesRemaining(ply)
    if Remaining_Enemies_Text then
        local remaining = REMAINING_ENEMIES_TO_SPAWN + table_count(ENEMY_CHARACTERS)
        if not ply then
            if last_sent_value ~= remaining then
                Events.BroadcastRemote("SetClientRemainingZombies", remaining)
            end
        else
            Events.CallRemote("SetClientRemainingZombies", ply, remaining)
        end
    end
end

VZ_EVENT_SUBSCRIBE_REMOTE("ServerSuicide", function(ply)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                char:ApplyDamage(char:GetHealth() - 1000)
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("ServerPing", function(ply, location, entity)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                Events.BroadcastRemote("SyncPing", ply:GetValue("CharacterColor"), location, entity)
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Package", "Unload", function()
    for k, v in pairs(Player.GetPairs()) do
        v:SetValue("PM_Data", nil, false)
        v:SetValue("MM_GodMode", nil, false)
        v:SetValue("MM_InfMoney", nil, false)
        v:SetValue("MM_InfGrenades", nil, false)
        v:SetValue("MM_CamMode", nil, false)
        v:SetValue("RepackCooldown", nil, false)
        v:SetValue("PlayerWaiting", nil, true)
    end
end)