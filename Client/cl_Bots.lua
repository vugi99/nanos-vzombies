
local BotsAimIntervals = {}

function VZBot.prototype:SetValue(key, value)
    if self:IsValid(true) then
        if (not self.Stored.Values[key] or self.Stored.Values[key] ~= value) then
            self.Stored.Values[key] = value
            for k, v in pairs(Sub_Callbacks.ValueChange) do
                v(self, key, value)
            end
        end
    end
end

function CL_VZBot(Bot_id, tbl)
    for k, v in pairs(ALL_BOTS) do
        if v.ID == Bot_id then
            local ChangedValues = {}

            local OldSyncedValues = v.Stored.SyncedValues
            for k2, v2 in pairs(OldSyncedValues) do
                local found

                for k3, v3 in pairs(tbl.SyncedValues) do
                    if k2 == k3 then
                        found = true
                        if v2 ~= v3 then
                            table.insert(ChangedValues, {k3, v3})
                        end
                    end
                end

                if not found then
                    table.insert(ChangedValues, {k2, nil})
                end
            end

            for k2, v2 in pairs(tbl.SyncedValues) do
                local found

                for k3, v3 in pairs(OldSyncedValues) do
                    if k2 == k3 then
                        found = true
                    end
                end

                if not found then
                    table.insert(ChangedValues, {k2, v2})
                end
            end

            --print(NanosUtils.Dump(ChangedValues))

            local OldValues = v.Stored.Values
            v.Stored = tbl
            v.Stored.Values = OldValues

            for k2, v2 in ipairs(ChangedValues) do
                for k3, v3 in pairs(Sub_Callbacks.ValueChange) do
                    v3(v, v2[1], v2[2])
                end
            end
            return v
        end
    end

    local Bot = setmetatable({}, VZBot.prototype)

    Bot.ID = Bot_id

    Bot.Stored = tbl
    Bot.Stored.Values = {}
    Bot.BOT = true
    Bot.Valid = true

    Bot.Stored.Name = "Bot " .. tostring(Bot.ID)

    local l_count = table_last_count(ALL_BOTS)
    ALL_BOTS[l_count + 1] = Bot

    for k2, v2 in pairs(tbl.SyncedValues) do
        for k3, v3 in pairs(Sub_Callbacks.ValueChange) do
            v3(Bot, k2, v2)
        end
    end

    return ALL_BOTS[l_count + 1]
end
VZ_EVENT_SUBSCRIBE("Events", "BotUpdateValues", CL_VZBot)

VZ_EVENT_SUBSCRIBE("Events", "BotLeft", function(Bot_id)
    for k, v in pairs(ALL_BOTS) do
        if v.ID == Bot_id then
            RemovePlayerMoney(v)
            local Interval = BotsAimIntervals[v:GetID()]
            if Interval then
                Timer.ClearInterval(Interval)
                BotsAimIntervals[v:GetID()] = nil
            end
            v.Valid = false
            break
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "AllBotsLeft", function()
    for k, v in pairs(ALL_BOTS) do
        RemovePlayerMoney(v)
    end
    for k, v in pairs(BotsAimIntervals) do
        Timer.ClearInterval(v)
    end
    BotsAimIntervals = {}
    ALL_BOTS = {}
end)
















function GetPowerSM()
    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:GetValue("MapPower") then
            return v
        end
    end
end

function GetNearestPowerup(char)
    local char_loc = char:GetLocation()
    local nearest
    local nearest_dist_sq
    for k, v in pairs(StaticMesh.GetPairs()) do
        local PowerupID = v:GetValue("GrabPowerup")
        if PowerupID then
            local loc = v:GetLocation()
            local dist_sq = char_loc:DistanceSquared(loc)
            if (not nearest_dist_sq or nearest_dist_sq > dist_sq) then
                local path = Client.FindPathToLocation(char_loc, loc)
                if (path.IsValid and not path.IsPartial) then
                    nearest = v
                    nearest_dist_sq = dist_sq
                end
            end
        end
    end

    return nearest
end


function GetPerkToBuy(bot, char)
    local perks = char:GetValue("OwnedPerks")
    local Perk_To_Buy

    for i, v in ipairs(Bots_Perks_Buy_Order) do
        if (MAP_PERKS[v] and not perks[v]) then
            Perk_To_Buy = v
            break
        end
    end

    --print(Perk_To_Buy)

    if Perk_To_Buy then
        local money = bot:GetValue("ZMoney")
        if money >= PERKS_CONFIG[Perk_To_Buy].price then
            for k, v in pairs(StaticMesh.GetPairs()) do
                local perk_name = v:GetValue("MapPerk")
                if (perk_name and perk_name == Perk_To_Buy) then
                    return v
                end
            end
        end
    end

end

function GetWeaponRank(weapon_name)
    for i, v in ipairs(Bots_Weapons_Ranks) do
        if v == weapon_name then
            return i
        end
    end
    return 0
end

function GetBestInvWeapon(bot_inv)
    local Best_Inv_Weapon
    local Best_Inv_Weapon_Rank = 0
    for k, v in pairs(bot_inv.weapons) do
        local rank = GetWeaponRank(v.weapon_name)
        if rank > Best_Inv_Weapon_Rank then
            Best_Inv_Weapon_Rank = rank
            Best_Inv_Weapon = v
        end
    end

    return Best_Inv_Weapon, Best_Inv_Weapon_Rank
end

function GetWeaponOrAmmoToBuy(Bot, char, bot_inv)
    local Best_Inv_Weapon, Best_Inv_Weapon_Rank = GetBestInvWeapon(bot_inv)

    local money = Bot:GetValue("ZMoney")
    local Best_Can_Buy_Weapon
    local Best_Can_Buy_Weapon_Rank = 0
    for k, v in pairs(Weapon.GetPairs()) do
        if v:IsValid() then
            local weapon_id = v:GetValue("MapWeaponID")
            if weapon_id then
                local weapon_name = MAP_WEAPONS[weapon_id].weapon_name
                if money >= MAP_WEAPONS[weapon_id].price then
                    local rank = GetWeaponRank(weapon_name)
                    if rank > Best_Can_Buy_Weapon_Rank then
                        local path = Client.FindPathToLocation(char:GetLocation(), v:GetLocation())
                        if (path.IsValid and not path.IsPartial) then
                            Best_Can_Buy_Weapon = v
                            Best_Can_Buy_Weapon_Rank = rank
                        end
                    end
                end
            end
        end
    end

    if Best_Inv_Weapon_Rank < Best_Can_Buy_Weapon_Rank then
        return Best_Can_Buy_Weapon
    else
        local ammo_bag
        if Best_Inv_Weapon.weapon then
            ammo_bag = Best_Inv_Weapon.weapon:GetAmmoBag()
        else
            ammo_bag = Best_Inv_Weapon.ammo_bag
        end

        --print("ammo_bag", ammo_bag)
        if ammo_bag <= Bots_Remaining_Ammo_Bag_Buy_Refill then
            for k, v in pairs(Weapon.GetPairs()) do
                if v:IsValid() then
                    local weapon_id = v:GetValue("MapWeaponID")
                    if weapon_id then
                        local weapon_name = MAP_WEAPONS[weapon_id].weapon_name
                        if weapon_name == Best_Inv_Weapon.weapon_name then
                            local price = math.floor(MAP_WEAPONS[weapon_id].price * Weapons_Ammo_Price_Percentage / 100)
                            if Best_Inv_Weapon.pap then
                                price = Pack_a_punch_price
                            end
                            if money >= price then
                                local path = Client.FindPathToLocation(char:GetLocation(), v:GetLocation())
                                if (path.IsValid and not path.IsPartial) then
                                    return v
                                end
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end

function GetPAPSM()
    if MAP_PACK_A_PUNCH then
        for k, v in pairs(StaticMesh.GetPairs()) do
            if v:IsValid() then
                local is_pap = v:GetValue("IsPackAPunch")
                if is_pap then
                    return v
                end
            end
        end
    end
end

function CanOpenDoor(door_id, ROOMS_UNLOCKED)
    for i, v in ipairs(MAP_DOORS[door_id].required_rooms) do
        if not ROOMS_UNLOCKED[v] then
            return false
        end
    end
    return true
end

function GetDoorToOpen(Bot, char, ROOMS_UNLOCKED)
    local money = Bot:GetValue("ZMoney")
    local char_loc = char:GetLocation()

    local CheapestDoorOpenable
    local CheapestDoorOpenablePrice
    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:IsValid() then
            local door_id = v:GetValue("DoorID")
            if door_id then
                local price = MAP_DOORS[door_id].price
                if (not CheapestDoorOpenablePrice or price < CheapestDoorOpenablePrice) then
                    if money >= price then
                        if CanOpenDoor(door_id, ROOMS_UNLOCKED) then
                            local path = Client.FindPathToLocation(char_loc, v:GetLocation())
                            if (path.IsValid and not path.IsPartial) then
                                CheapestDoorOpenable = v
                                CheapestDoorOpenablePrice = price
                            else
                                local point_around = Client.GetRandomPointInNavigableRadius(v:GetLocation(), Bots_Reach_Door_Around)
                                if point_around then
                                    local path2 = Client.FindPathToLocation(char_loc, point_around)
                                    if (path2.IsValid and not path2.IsPartial) then
                                        CheapestDoorOpenable = v
                                        CheapestDoorOpenablePrice = price
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return CheapestDoorOpenable
end

function GetNearestCharacterThatNeedRevive(char)
    local char_loc = char:GetLocation()

    local nearest_down_char
    local nearest_down_char_distance_sq
    for k, v in pairs(Character.GetPairs()) do
        if v:IsValid() then
            local down = v:GetValue("PlayerDown")
            if down then
                local loc = v:GetLocation()
                local dist_sq = char_loc:DistanceSquared(loc)
                if (not nearest_down_char_distance_sq or dist_sq < nearest_down_char_distance_sq) then
                    local path = Client.FindPathToLocation(char_loc, loc)
                    if (path.IsValid and not path.IsPartial) then
                        nearest_down_char = v
                        nearest_down_char_distance_sq = dist_sq
                    end
                end
            end
        end
    end

    return nearest_down_char
end


VZ_EVENT_SUBSCRIBE("Events", "RequestBotAction", function(bot_id, bot_stored, bot_inv, ROOMS_UNLOCKED)
    local Bot = CL_VZBot(bot_id, bot_stored)
    if Bot then
        local char = Bot:GetControlledCharacter()

        if not char:GetValue("PlayerDown") then
            for i, v in ipairs(Bots_Behavior_Config) do
                if v == "POWER" then
                    if not POWER_ON then
                        local SM = GetPowerSM()
                        if SM then
                            local loc = SM:GetLocation()
                            local path = Client.FindPathToLocation(char:GetLocation(), loc)
                            if (path.IsValid and not path.IsPartial) then
                                Events.CallRemote("BotAction", bot_id, v, loc)
                                return
                            end
                        end
                    end
                elseif v == "POWERUPS" then
                    local nearest_powerup = GetNearestPowerup(char)
                    if nearest_powerup then
                        local nearest_powerup_loc = nearest_powerup:GetLocation()
                        Events.CallRemote("BotAction", bot_id, v, nearest_powerup_loc, nearest_powerup:GetValue("GrabPowerup"))
                        return
                    end
                elseif v == "PERKS" then
                    local perk_target = GetPerkToBuy(Bot, char)
                    if perk_target then
                        local loc = perk_target:GetLocation()
                        local path = Client.FindPathToLocation(char:GetLocation(), loc)
                        if (path.IsValid and not path.IsPartial) then
                            Events.CallRemote("BotAction", bot_id, v, loc, perk_target)
                            return
                        end
                    end
                elseif v == "WEAPONS" then
                    local weapon_target = GetWeaponOrAmmoToBuy(Bot, char, bot_inv)
                    if weapon_target then
                        local loc = weapon_target:GetLocation()
                        Events.CallRemote("BotAction", bot_id, v, loc, weapon_target)
                        return
                    end
                elseif v == "PACKAPUNCH" then
                    if POWER_ON then
                        local money = Bot:GetValue("ZMoney")
                        if money >= Pack_a_punch_price then
                            local pack_a_punch = GetPAPSM()
                            if pack_a_punch then
                                local Best_Inv_Weapon, Best_Inv_Weapon_Rank = GetBestInvWeapon(bot_inv)
                                if Best_Inv_Weapon then
                                    if not Best_Inv_Weapon.pap then
                                        local loc = pack_a_punch:GetLocation()
                                        local point_around = Client.GetRandomPointInNavigableRadius(loc, Bots_Reach_PAP_Around)
                                        if point_around then
                                            local path = Client.FindPathToLocation(char:GetLocation(), point_around)
                                            --print(NanosUtils.Dump(path))
                                            if (path.IsValid and not path.IsPartial) then
                                                Events.CallRemote("BotAction", bot_id, v, point_around, pack_a_punch)
                                                return
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                elseif v == "DOORS" then
                    local door_target = GetDoorToOpen(Bot, char, ROOMS_UNLOCKED)
                    if door_target then
                        local loc = door_target:GetLocation()
                        Events.CallRemote("BotAction", bot_id, v, loc, door_target)
                        return
                    end
                elseif v == "MOVE" then
                    local reachable_loc = Client.GetRandomReachablePointInRadius(char:GetLocation(), Bots_Move_Max_Radius)
                    Events.CallRemote("BotAction", bot_id, v, reachable_loc)
                    return
                elseif v == "REVIVE" then
                    local down_char = GetNearestCharacterThatNeedRevive(char)
                    if down_char then
                        local loc = down_char:GetLocation()
                        Events.CallRemote("BotAction", bot_id, v, loc, down_char)
                        return
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("VZBot", "ValueChange", function(Bot, key, value)
    if key == "BotAimPlayer" then
        local ply = Client.GetLocalPlayer()
        if value == ply:GetID() then
            BotsAimIntervals[Bot:GetID()] = Timer.SetInterval(function()
                local char = Bot:GetControlledCharacter()
                if char then
                    local char_loc = char:GetLocation()

                    if char then
                        if not char:GetValue("PlayerDown") then
                            if char:GetPicked() then
                                local can_shoot_on = {}

                                for k, v in pairs(Character.GetPairs()) do
                                    if v:GetValue("ZombieType") then
                                        if v:GetHealth() > 0 then
                                            local loc = v:GetLocation()
                                            if char_loc:DistanceSquared(loc) <= Bots_Target_MaxDistance3D_Sq then
                                                local trace = Client.Trace(
                                                    char_loc + Vector(0, 0, 90),
                                                    loc,
                                                    --CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.Pawn | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Mesh,
                                                    CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Mesh,
                                                    false,
                                                    true,
                                                    false,
                                                    {char},
                                                    ZDEV_IsModeEnabled("ZDEV_DEBUG_TRACES")
                                                )
                                                if trace.Success then
                                                    --if trace.ActorName ~= "StaticMeshActor" then
                                                        --print(NanosUtils.Dump(trace))
                                                    --end
                                                    if (trace.Entity and trace.Entity == v) then
                                                        table.insert(can_shoot_on, v)
                                                    end
                                                else
                                                    --print("Trace no SUCCESS")
                                                    table.insert(can_shoot_on, v)
                                                end
                                            end
                                        end
                                    end
                                end

                                local Shooting_On = char:GetValue("BOTShootingOn")
                                local selectNew = true
                                local shooting_on_in_list
                                if Shooting_On then
                                    shooting_on_in_list = false
                                    for i, v in ipairs(can_shoot_on) do
                                        if v:GetID() == Shooting_On then
                                            shooting_on_in_list = true
                                            selectNew = false
                                            break
                                        end
                                    end
                                end

                                if selectNew then
                                    local nearest_char
                                    local nearest_dist_sq
                                    for i, v in ipairs(can_shoot_on) do
                                        local loc = v:GetLocation()
                                        local dist_sq = char_loc:DistanceSquared(loc)
                                        if (not nearest_dist_sq or nearest_dist_sq > dist_sq) then
                                            nearest_char = v
                                            nearest_dist_sq = dist_sq
                                        end
                                    end

                                    if nearest_char then
                                        Events.CallRemote("NewBotTarget", Bot:GetID(), nearest_char)
                                    elseif shooting_on_in_list == false then
                                        Events.CallRemote("BotLostTarget", Bot:GetID())
                                    end
                                end
                            end
                        end
                    end
                end
            end, Bots_CheckTarget_Interval)
        else
            local Interval = BotsAimIntervals[Bot:GetID()]
            if Interval then
                Timer.ClearInterval(Interval)
                BotsAimIntervals[Bot:GetID()] = nil
            end
        end
    end
end)