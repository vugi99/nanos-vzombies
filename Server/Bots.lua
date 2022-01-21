




function VZBot.prototype:Possess(char)
    if self:IsValid(true) then
        if (char and char:IsValid()) then
            self.Stored.Possessed = char
            Events.BroadcastRemote("BotUpdateValues", self.ID, self.Stored)
        end
    end
end

function VZBot.prototype:UnPossess()
    if self:IsValid(true) then
        if self.Stored.Possessed then
            self.Stored.Possessed = nil
            Events.BroadcastRemote("BotUpdateValues", self.ID, self.Stored)
        end
    end
end

function VZBot.prototype:SetName(name)
    if self:IsValid(true) then
        if name then
            if type(name) == "string" then
                self.Stored.Name = name
            end
        end
    end
end

function VZBot.prototype:Kick(already_removed)
    if self:IsValid(true) then
        self.Valid = false

        Events.BroadcastRemote("BotLeft", self.ID)

        if not already_removed then
            for k, v in pairs(PLAYING_PLAYERS) do
                if v == self then
                    PLAYING_PLAYERS_NB = PLAYING_PLAYERS_NB - 1
                    table.remove(PLAYING_PLAYERS, k)
                    break
                end
            end
        end
    end
end

function VZBot.prototype:SetValue(key, value, sync)
    if self:IsValid(true) then
        local keyV = "Values"
        if sync then
            keyV = "SyncedValues"
        end
        if (not self.Stored[keyV][key] or self.Stored[keyV][key] ~= value) then
            self.Stored[keyV][key] = value
            if sync then
                Events.BroadcastRemote("BotUpdateValues", self.ID, self.Stored)
            end
            for k, v in pairs(Sub_Callbacks.ValueChange) do
                v(self, key, value)
            end
        end
    end
end

function VZBotJoin()
    local Bot = setmetatable({}, VZBot.prototype)

    Bots_ID = Bots_ID + 1
    local this_id = Bots_ID
    Bot.ID = this_id

    Bot.Stored = {}
    Bot.Stored.Values = {}
    Bot.Stored.SyncedValues = {}
    Bot.BOT = true
    Bot.Valid = true
    Bot.Stored.NanosID = 500200 + Bots_ID

    Bot.Stored.Name = "Bot " .. tostring(Bots_ID)

    local l_count = table_last_count(ALL_BOTS)
    ALL_BOTS[l_count + 1] = Bot

    Timer.SetTimeout(function()
        if ALL_BOTS[l_count + 1] then
            if ALL_BOTS[l_count + 1].Valid then
                if ALL_BOTS[l_count + 1].ID == this_id then
                    local char = ALL_BOTS[l_count + 1]:GetControlledCharacter()
                    if char then
                        RequestBotAction(ALL_BOTS[l_count + 1])
                    end
                end
            end
        end
    end, Bots_Start_Moving_ms)

    Bot:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)

    return ALL_BOTS[l_count + 1]
end

DEFAULT_EREMOTE = Events.CallRemote

function Events.CallRemote(event_name, ply, ...)
    if ply.BOT then
        Events.Call("BOT_" .. event_name, ply, ...)
        return true
    end

    return DEFAULT_EREMOTE(event_name, ply, ...)
end

DEFAULT_EBROADCAST = Events.BroadcastRemote

function Events.BroadcastRemote(event_name, ...)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            Events.Call("BOT_" .. event_name, v, ...)
        end
    end

    return DEFAULT_EBROADCAST(event_name, ...)
end

function PlayerLeftCheckSyncPlayers(ply)
    for k, v in pairs(PLAYING_PLAYERS) do
        if v.BOT then
            if v:IsValid() then
                if v:GetValue("RequestedActionFromPlayer") == ply:GetID() then
                    RequestBotAction(v, ply)
                end
                if v:GetValue("BotAimPlayer") == ply:GetID() then
                    local random_ply = GetRandomPlayerWOOne(ply)
                    if random_ply then
                        v:SetValue("BotAimPlayer", random_ply:GetID(), true)
                    end
                end
            end
        end
    end
end

function GetBotFromBotID(bot_id)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            if v.ID == bot_id then
                return v
            end
        end
    end
end

function GetBotFromNanosBotID(bot_id)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            if v:GetID() == bot_id then
                return v
            end
        end
    end
end

function RequestBotAction(bot, wo_ply)
    local ply = GetRandomPlayer()
    if wo_ply then
        ply = GetRandomPlayerWOOne(wo_ply)
    end
    if ply then
        bot:SetValue("RequestedActionFromPlayer", ply:GetID(), false)
        Events.CallRemote("RequestBotAction", ply, bot.ID, bot.Stored, GetPlayerInventoryTable(bot), ROOMS_UNLOCKED)
    end
end

VZ_EVENT_SUBSCRIBE("Events", "BotAction", function(ply, bot_id, action, to_reach, target)
    local Bot = GetBotFromBotID(bot_id)
    if Bot then
        if Bot:GetValue("RequestedActionFromPlayer") == ply:GetID() then
            local char = Bot:GetControlledCharacter()
            if char then
                if char:IsValid() then
                    if not char:GetValue("PlayerDown") then
                        if not char:IsInRagdollMode() then
                            --print("BotAction", bot_id, action, to_reach)
                            char:SetValue("DoingAction", {action, target}, false)
                            local acceptance_r = Bots_Acceptance_Radius
                            char:MoveTo(to_reach, acceptance_r)
                            if (not char:GetValue("BOTShootingOn")) then
                                char:SetWeaponAimMode(AimMode.None)
                                char:LookAt(to_reach + Vector(0, 0, 100))
                            end
                        end
                    end
                end
            end
        end
    end
end)

function CheckToStopBotReviveTimer(char, revived_dead)
    local data = char:GetValue("BOTReviveData")
    if data then
        Timer.ClearTimeout(data[1])
        char:SetValue("BOTReviveData", nil, false)
        local bot = char:GetPlayer()
        if not revived_dead then
            RevivePlayerStopped(bot, GetCharacterFromId(data[2]))
        else
            RequestBotAction(bot)
        end
    end
end

VZ_EVENT_SUBSCRIBE("Character", "MoveCompleted", function(char, success)
    local bot = char:GetPlayer()
    if (bot and bot.BOT) then
        local action = char:GetValue("DoingAction")
        if action then
            --print("BOT", "MoveCompleted", success, action[1])
            if success then
                local WaitingSomething

                if action[1] == "POWER" then
                    if not POWER_ON then
                        PlayerTurnPowerON(bot, MAP_POWER_SM)
                    end
                elseif action[1] == "POWERUPS" then
                    local k, v = GetPowerupPickupFromPowerupID(action[2])
                    if k then
                        if v.SM_Powerup:IsValid() then
                            Events.Call("VZ_PowerupGrabbed", char, v.SM_Powerup:GetValue("GrabPowerup"), v.powerup_name)
                            DestroyPowerup(v)
                            PowerupGrabbed(v.powerup_name, char)
                        end
                        POWERUPS_PICKUPS[k] = nil
                    end
                elseif action[1] == "PERKS" then
                    if action[2]:IsValid() then
                        BuyPerk(bot, action[2])
                    end
                elseif action[1] == "WEAPONS" then
                    if action[2]:IsValid() then
                        InteractMapWeapon(action[2], char)
                        char:SetValue("BOTReloading", nil, false)
                    end
                elseif action[1] == "PACKAPUNCH" then
                    if action[2]:IsValid() then
                        if action[2]:GetValue("CanBuyPackAPunch") then
                            WaitingSomething = UpgradeWeapon(bot, action[2])
                            char:SetValue("BOTReloading", nil, false)
                            char:SetValue("BOTWaitingPAP", true, false)
                        end
                    end
                elseif action[1] == "DOORS" then
                    if (action[2] and action[2]:IsValid()) then
                        local door_id = action[2]:GetValue("DoorID")
                        if door_id then
                            BuyDoor(bot, door_id)
                        end
                    end
                elseif action[1] == "REVIVE" then
                    if action[2]:IsValid() then
                        if action[2]:GetValue("PlayerDown") then
                            local reviving = RevivePlayer(bot, action[2])
                            if reviving then
                                WaitingSomething = true
                                local TimeToRevive = ReviveTime_ms
                                local perks = char:GetValue("OwnedPerks")
                                if (perks and perks["quick_revive"]) then
                                    TimeToRevive = PERKS_CONFIG.quick_revive.ReviveTime_ms
                                end
                                char:SetValue("BOTReviveData", {Timer.SetTimeout(function()
                                    RevivePlayerFinished(bot, action[2])
                                    char:SetValue("BOTReviveData", nil, false)
                                    RequestBotAction(bot)
                                end, TimeToRevive), action[2]:GetID()}, false)
                            end
                        end
                    end
                end

                if not WaitingSomething then
                    RequestBotAction(bot)
                end
            elseif (char:IsValid() and not char:GetValue("PlayerDown") and not char:IsInRagdollMode()) then
                RequestBotAction(bot)
            end

            char:SetValue("DoingAction", nil, false)
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PAPUpgradedWeapon", function()
    for k, v in pairs(Character.GetPairs()) do
        if v:GetValue("BOTWaitingPAP") then
            InteractPAPWeapon(PAP_Upgrade_Data.upgraded_weapon, v)
            v:SetValue("BOTWaitingPAP", nil, false)
            local bot = v:GetPlayer()
            if bot then
                RequestBotAction(bot)
            end
            break
        end
    end
end)

function BotResetTarget(Bot)
    local char = Bot:GetControlledCharacter()
    if char:GetValue("BOTShootInterval") then
        char:SetValue("BOTShootingOn", nil, true)
        Timer.ClearInterval(char:GetValue("BOTShootInterval"))
        char:SetValue("BOTShootInterval", nil, false)
    end
end

function BOTShootIntervalFunc(char)
    if char:IsValid() then
        local weapon = char:GetPicked()
        if weapon then
            if weapon:GetAmmoClip() > 0 then
                local Shooting_On = char:GetValue("BOTShootingOn")
                if Shooting_On then
                    if not char:GetValue("BOTReloading") then
                        local shooting_on_char = GetCharacterFromId(Shooting_On)
                        if shooting_on_char then
                            if shooting_on_char:IsValid() then
                                if shooting_on_char:GetHealth() > 0 then
                                    local loc = shooting_on_char:GetLocation()
                                    local dist = char:GetLocation():Distance(loc)
                                    local rand_x, rand_y, rand_z = (math.random() - 0.5) * 2, (math.random() - 0.5) * 2, (math.random() - 0.5) * 2
                                    local inaccurate_loc = Vector(loc.X, loc.Y, loc.Z)
                                    inaccurate_loc.X = inaccurate_loc.X + Bots_Shoot_Inaccuracy_Each_Distance_Unit * dist * rand_x
                                    inaccurate_loc.Y = inaccurate_loc.Y + Bots_Shoot_Inaccuracy_Each_Distance_Unit * dist * rand_y
                                    inaccurate_loc.Z = inaccurate_loc.Z + Bots_Shoot_Inaccuracy_Each_Distance_Unit * dist * rand_z
                                    char:LookAt(inaccurate_loc)
                                    weapon:PullUse(0)
                                    --print(weapon:GetAmmoClip())
                                    -- 8, 8, 7, 6, ..., 1 ?
                                    if (weapon:GetAmmoClip() == 1) then
                                        --print("Bot Reload")

                                        -- Fake Reload
                                    --[[local clip_capacity = weapon:GetClipCapacity()
                                        if weapon:GetAmmoBag() < clip_capacity then
                                            clip_capacity = weapon:GetAmmoBag()
                                        end
                                        weapon:SetAmmoClip(clip_capacity)
                                        weapon:SetAmmoBag(weapon:GetAmmoBag() - clip_capacity)]]--

                                        weapon:Reload()
                                        char:SetValue("BOTReloading", true, false)
                                    end
                                    return
                                end
                            end
                        end
                        BotResetTarget(char:GetPlayer())
                    end
                end
            elseif (not char:GetValue("BOTReloading") and weapon:GetAmmoBag() > 0) then -- useful at ammo refill
                weapon:Reload()
                char:SetValue("BOTReloading", true, false)
            end
        else
            BotResetTarget(char:GetPlayer())
        end
    end
end

VZ_EVENT_SUBSCRIBE("Events", "NewBotTarget", function(ply, bot_id, target_char)
    local Bot = GetBotFromNanosBotID(bot_id)
    if Bot then
        local BotAimPlayer = Bot:GetValue("BotAimPlayer")
        if BotAimPlayer then
            if BotAimPlayer == ply:GetID() then
                if target_char:IsValid() then
                    local char = Bot:GetControlledCharacter()
                    if char then
                        if not char:GetValue("PlayerDown") then
                            if not char:IsInRagdollMode() then
                                local weapon = char:GetPicked()
                                if weapon then
                                    char:SetValue("BOTShootingOn", target_char:GetID(), true)
                                    char:SetValue("BOTShootInterval", Timer.SetInterval(BOTShootIntervalFunc,  weapon:GetCadence() * 1000, char), false)
                                    BOTShootIntervalFunc(char)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "BotLostTarget", function(ply, bot_id)
    local Bot = GetBotFromNanosBotID(bot_id)
    if Bot then
        local BotAimPlayer = Bot:GetValue("BotAimPlayer")
        if BotAimPlayer then
            if BotAimPlayer == ply:GetID() then
                BotResetTarget(Bot)
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Weapon", "Reload", function(weapon, char, ammo_to_reload)
    if char then
        local ply = char:GetPlayer()
        if (ply and ply.BOT) then
            char:SetValue("BOTReloading", nil, false)
            --print(weapon:GetAmmoBag())
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PowerupGrabbed", function(char, powerup_id, p_name)
    for k, v in pairs(Character.GetPairs()) do
        if v:IsValid() then
            if v ~= char then
                local possessing_ply = v:GetPlayer()
                if possessing_ply then
                    if possessing_ply.BOT then
                        local action = v:GetValue("DoingAction")
                        if action then
                            if (action[1] == "POWERUPS" and action[2] == powerup_id) then
                                v:SetValue("DoingAction", nil, false)
                                v:MoveTo(v:GetLocation(), 50)
                                RequestBotAction(possessing_ply)
                            end
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_DoorOpened", function(char, door_id)
    for k, v in pairs(Character.GetPairs()) do
        if v:IsValid() then
            if v ~= char then
                local possessing_ply = v:GetPlayer()
                if possessing_ply then
                    if possessing_ply.BOT then
                        local action = v:GetValue("DoingAction")
                        if action then
                            if (action[1] == "DOORS" and action[2] and not action[2]:IsValid()) then
                                v:SetValue("DoingAction", nil, false)
                                v:MoveTo(v:GetLocation(), 50)
                                RequestBotAction(possessing_ply)
                            end
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "RagdollModeChanged", function(char, old_state, new_state)
    local ply = char:GetPlayer()
    if (ply and ply.BOT) then
        if new_state then
            if char:GetHealth() > 0 then
                if not char:GetValue("PlayerDown") then
                    BotResetTarget(ply)
                    Timer.SetTimeout(function()
                        if char:IsValid() then
                            if char:GetHealth() > 0 then
                                if not char:GetValue("PlayerDown") then
                                    char:SetRagdollMode(false)
                                    RequestBotAction(ply)
                                end
                            end
                        end
                    end, Bots_Ragdoll_Get_Up_Timeout_ms)
                end
            end
        end
    end
end)