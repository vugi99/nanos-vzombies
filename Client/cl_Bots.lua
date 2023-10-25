
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
    --print("CL_VZBot", Bot_id, NanosUtils.Dump(tbl))

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

            if v.Stored.Possessed then
                CallENVFunc_NoError("CheckToAddText3D", v.Stored.Possessed)
            end

            for k2, v2 in ipairs(ChangedValues) do
                for k3, v3 in pairs(Sub_Callbacks.ValueChange) do
                    v3(v, v2[1], v2[2])
                end
            end

            --print("CL VZBot end2", NanosUtils.Dump(v))

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

    if Bot.Stored.Possessed then
        CallENVFunc_NoError("CheckToAddText3D", Bot.Stored.Possessed)
    end

    local l_count = table_last_count(ALL_BOTS)
    ALL_BOTS[l_count + 1] = Bot

    for k2, v2 in pairs(tbl.SyncedValues) do
        for k3, v3 in pairs(Sub_Callbacks.ValueChange) do
            v3(Bot, k2, v2)
        end
    end

    --print("CL VZBot end", NanosUtils.Dump(ALL_BOTS[l_count + 1]))

    return ALL_BOTS[l_count + 1]
end
VZ_EVENT_SUBSCRIBE_REMOTE("BotUpdateValues", CL_VZBot)

VZ_EVENT_SUBSCRIBE_REMOTE("BotLeft", function(Bot_id)
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

VZ_EVENT_SUBSCRIBE_REMOTE("AllBotsLeft", function()
    for k, v in pairs(ALL_BOTS) do
        RemovePlayerMoney(v)
    end
    for k, v in pairs(BotsAimIntervals) do
        Timer.ClearInterval(v)
    end
    BotsAimIntervals = {}
    ALL_BOTS = {}
end)















function DrawBotMovementCylinder(char_loc, target_loc, color, text)
    local lft = char_loc:Distance(target_loc)/500
    Debug.DrawCylinder(target_loc - Vector(0, 0, 20), target_loc + Vector(0, 0, 180), Bots_Acceptance_Radius, 30, color, lft, 1)
    Debug.DrawCylinder(target_loc - Vector(0, 0, 20), target_loc + Vector(0, 0, 180), math.sqrt(Bots_Reach_Acceptance_Radius_sq), 30, Color.AZURE, lft, 1)
    --Debug.DrawCylinder(target_loc - Vector(0, 0, 20), target_loc + Vector(0, 0, 180), Bots_PreReach_Trigger_Radius, 30, Color.YELLOW, lft, 1)
    Debug.DrawString(target_loc + Vector(0, 0, 90), text, Color.WHITE, lft, false, 1)
end

function GetBotMoneyConsideringPrereach(bot, prereach)
    local cur_money = bot:GetValue("ZMoney")

    if prereach then
        if prereach[1] == "WEAPONS" then
            if prereach[2]:IsValid() then
                local weapon_id = prereach[2]:GetValue("MapWeaponID")
                if weapon_id then
                    return math.max(cur_money-MAP_WEAPONS[weapon_id].price, 0)
                end
            end
        elseif prereach[1] == "PERKS" then
            if prereach[2]:IsValid() then
                local perk_name = prereach[2]:GetValue("MapPerk")
                if perk_name then
                    return math.max(cur_money-PERKS_CONFIG[perk_name].price, 0)
                end
            end
        elseif prereach[1] == "DOORS" then
            if prereach[2]:IsValid() then
                local door_id = prereach[2]:GetValue("DoorID")
                if door_id then
                    local price = MAP_DOORS[door_id].price
                    return math.max(cur_money-price, 0)
                end
            end
        end
    end
    return cur_money
end


function GetPowerSM()
    for k, v in pairs(PreparedLoops["Power"]) do
        if v:GetValue("MapPower") then
            return v
        end
    end
end

function GetNearestPowerup(char, prereach)
    local char_loc = char:GetLocation()
    local nearest
    local nearest_dist_sq
    for k, v in pairs(StaticMesh.GetPairs()) do
        local PowerupID = v:GetValue("GrabPowerup")
        if PowerupID then
            if ((not prereach) or prereach[1] ~= "POWERUPS" or (prereach[1] == "POWERUPS" and prereach[2] ~= PowerupID)) then
                local loc = v:GetLocation()
                local dist_sq = char_loc:DistanceSquared(loc)
                if (not nearest_dist_sq or nearest_dist_sq > dist_sq) then
                    local path = Navigation.FindPathToLocation(char_loc, loc)
                    if (path.IsValid and not path.IsPartial) then
                        nearest = v
                        nearest_dist_sq = dist_sq
                    end
                end
            end
        end
    end

    return nearest
end

function GetNearestEnemy(loc)
    local nearest
    local nearest_dist_sq
    for k, v in pairs(PreparedLoops["Enemies"]) do
        if v:GetHealth() > 0 then
            local dist_sq = loc:DistanceSquared(v:GetLocation())
            if ((not nearest) or nearest_dist_sq > dist_sq) then
                nearest = v
                nearest_dist_sq = dist_sq
            end
        end
    end
    return nearest, nearest_dist_sq
end


function GetPerkToBuy(bot, char, prereach)
    local perks = char:GetValue("OwnedPerks")
    local Perk_To_Buy

    local prereach_perk
    if prereach then
        if prereach[1] == "PERKS" then
            if prereach[2]:IsValid() then
                prereach_perk = prereach[2]:GetValue("MapPerk")
            end
        end
    end

    for i, v in ipairs(Bots_Perks_Buy_Order) do
        if (MAP_PERKS[v] and not perks[v]) then
            if (not prereach or prereach[1] ~= "PERKS" or (prereach[1] == "PERKS" and prereach_perk ~= v and prereach_perk ~= nil)) then
                Perk_To_Buy = v
                break
            end
        end
    end

    --print(Perk_To_Buy)

    if Perk_To_Buy then
        local money = GetBotMoneyConsideringPrereach(bot, prereach)
        if money >= PERKS_CONFIG[Perk_To_Buy].price then
            for k, v in pairs(PreparedLoops["Perks"]) do
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

function GetWeaponOrAmmoToBuy(Bot, char, bot_inv, prereach)
    local Best_Inv_Weapon, Best_Inv_Weapon_Rank = GetBestInvWeapon(bot_inv)

    local prereach_weap
    if prereach then
        if prereach[1] == "WEAPONS" then
            prereach_weap = prereach[2]
        end
    end

    local money = GetBotMoneyConsideringPrereach(Bot, prereach)
    local Best_Can_Buy_Weapon
    local Best_Can_Buy_Weapon_Rank = 0
    for k, v in pairs(Weapon.GetPairs()) do
        if v:IsValid() then
            local weapon_id = v:GetValue("MapWeaponID")
            if weapon_id then
                if v ~= prereach_weap then
                    local weapon_name = MAP_WEAPONS[weapon_id].weapon_name
                    if money >= MAP_WEAPONS[weapon_id].price then
                        local rank = GetWeaponRank(weapon_name)
                        if rank > Best_Can_Buy_Weapon_Rank then
                            local path = Navigation.FindPathToLocation(char:GetLocation(), v:GetLocation())
                            if (path.IsValid and not path.IsPartial) then
                                Best_Can_Buy_Weapon = v
                                Best_Can_Buy_Weapon_Rank = rank
                            end
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
                        if v ~= prereach_weap then
                            local weapon_name = MAP_WEAPONS[weapon_id].weapon_name
                            if weapon_name == Best_Inv_Weapon.weapon_name then
                                local price = math.floor(MAP_WEAPONS[weapon_id].price * Weapons_Ammo_Price_Percentage / 100)
                                if Best_Inv_Weapon.pap then
                                    price = Pack_a_punch_price
                                end
                                if money >= price then
                                    local path = Navigation.FindPathToLocation(char:GetLocation(), v:GetLocation())
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
end

function GetPAPSM()
    if MAP_PACK_A_PUNCH then
        for k, v in pairs(PreparedLoops["PAP"]) do
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

function GetDoorToOpen(Bot, char, ROOMS_UNLOCKED, prereach)
    local money = GetBotMoneyConsideringPrereach(Bot, prereach)
    local char_loc = char:GetLocation()

    local prereach_door
    if prereach then
        if prereach[1] == "DOORS" then
            prereach_door = prereach[2]
        end
    end

    local CheapestDoorOpenable
    local CheapestDoorOpenablePrice
    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:IsValid() then
            local door_id = v:GetValue("DoorID")
            if door_id then
                if v ~= prereach_door then
                    local price = MAP_DOORS[door_id].price
                    if (not CheapestDoorOpenablePrice or price < CheapestDoorOpenablePrice) then
                        if money >= price then
                            if CanOpenDoor(door_id, ROOMS_UNLOCKED) then
                                local path = Navigation.FindPathToLocation(char_loc, v:GetLocation())
                                if (path.IsValid and not path.IsPartial) then
                                    CheapestDoorOpenable = v
                                    CheapestDoorOpenablePrice = price
                                else
                                    local point_around = Navigation.GetRandomPointInNavigableRadius(v:GetLocation(), Bots_Reach_Door_Around)
                                    if (point_around and point_around ~= Vector(0, 0, 0)) then
                                        local path2 = Navigation.FindPathToLocation(char_loc, point_around)
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
                    local path = Navigation.FindPathToLocation(char_loc, loc)
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

function IsZombieGood(v)
    if v:IsValid() then
        if v:GetValue("EnemyType") then
            if v:GetHealth() > 0 then
                if not v:IsInRagdollMode() then
                    return true
                end
            end
        end
    end
end

function findRotation( x1, y1, x2, y2 )
    local t = -math.deg(math.atan( x2 - x1, y2 - y1 ))
    t = t < 0 and t + 360 or t
    return t - 270
end

function GetBotMoveLocation(Bot, char)

    local loc = char:GetLocation()

    local zombies_locations = {}
    for k, v in pairs(Character.GetPairs()) do
        if IsZombieGood(v) then
            local zloc = v:GetLocation()
            if loc:DistanceSquared(zloc) <= Bots_Zombies_Dangerous_Point_Distance_sq then
                table.insert(zombies_locations, zloc)
            end
        end
    end
    if zombies_locations[1] then
        --local dangerous_point = CalculateMiddle(table.unpack(zombies_locations))
        local dangerous_point = CalculateMiddlePonderedByDistanceSq(char:GetLocation(), table.unpack(zombies_locations))
        local look_at_point = Rotator(0, findRotation(loc.X, loc.Y, dangerous_point.X, dangerous_point.Y), 0)
        local look_at_point_fw = look_at_point:GetForwardVector()

        local flee_middle = loc + look_at_point_fw * -1 * Bots_Flee_Zombies_Move_Distance
        if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_FLEE") then
            Debug.DrawLine(dangerous_point, loc, Color.RED, 1, 1)
            Debug.DrawLine(loc, flee_middle, Color.AZURE, 1, 1)
            Debug.DrawSphere(dangerous_point, 200, 40, Color.RED, 1, 1)
            Debug.DrawSphere(flee_middle, Bots_Flee_Zombies_Move_Radius, 50, Color.AZURE, 1, 1)
        end
        for i = 1, Bots_Flee_Point_Retry_Number do
            local flee_point = Navigation.GetRandomPointInNavigableRadius(flee_middle, Bots_Flee_Zombies_Move_Radius)
            if (flee_point and flee_point ~= Vector(0, 0, 0)) then
                local path = Navigation.FindPathToLocation(loc, flee_point)
                if (path.IsValid and not path.IsPartial) then
                    if path.Length <= Bots_Flee_Zombies_Move_Distance * 2 + Bots_Flee_Zombies_Move_Radius * 2 then
                        if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                            DrawBotMovementCylinder(char:GetLocation(), flee_point, Color.GREEN, "Flee")
                        end
                        return flee_point
                    end
                end
            end
        end
    end

    local reachable_loc = Navigation.GetRandomReachablePointInRadius(char:GetLocation(), Bots_Move_Max_Radius)
    if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
        DrawBotMovementCylinder(char:GetLocation(), reachable_loc, Color.GREEN, "MOVE")
    end
    return reachable_loc
end


local Clientside_Bot_Actions = {
    POWER = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        if (not prereach or prereach[1] ~= v) then
            if not POWER_ON then
                local SM = GetPowerSM()
                if SM then
                    local loc = SM:GetLocation()
                    local path = Navigation.FindPathToLocation(char:GetLocation(), loc)
                    if (path.IsValid and not path.IsPartial) then
                        if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                            DrawBotMovementCylinder(char:GetLocation(), loc, Color.GREEN, v)
                        end
                        Events.CallRemote("BotAction", bot_id, v, loc, nil, prereach)
                        return true
                    end
                end
            end
        end
    end,
    POWERUPS = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        local nearest_powerup = GetNearestPowerup(char, prereach)
        if nearest_powerup then
            local nearest_powerup_loc = nearest_powerup:GetLocation()
            if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                DrawBotMovementCylinder(char:GetLocation(), nearest_powerup_loc, Color.GREEN, v)
            end
            Events.CallRemote("BotAction", bot_id, v, nearest_powerup_loc, nearest_powerup:GetValue("GrabPowerup"), prereach)
            return true
        end
    end,
    PERKS = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        local perk_target = GetPerkToBuy(Bot, char, prereach)
        if perk_target then
            local loc = perk_target:GetLocation()
            local path = Navigation.FindPathToLocation(char:GetLocation(), loc)
            if (path.IsValid and not path.IsPartial) then
                if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                    DrawBotMovementCylinder(char:GetLocation(), loc, Color.GREEN, v)
                end
                Events.CallRemote("BotAction", bot_id, v, loc, perk_target, prereach)
                return true
            end
        end
    end,
    WEAPONS = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        local weapon_target = GetWeaponOrAmmoToBuy(Bot, char, bot_inv, prereach)
        if weapon_target then
            local loc = weapon_target:GetLocation()
            if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                DrawBotMovementCylinder(char:GetLocation(), loc, Color.GREEN, v)
            end
            Events.CallRemote("BotAction", bot_id, v, loc, weapon_target, prereach)
            return true
        end
    end,
    PACKAPUNCH = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        if POWER_ON then
            local money = GetBotMoneyConsideringPrereach(Bot, prereach)
            if money >= Pack_a_punch_price then
                local pack_a_punch = GetPAPSM()
                if pack_a_punch then
                    local Best_Inv_Weapon, Best_Inv_Weapon_Rank = GetBestInvWeapon(bot_inv)
                    if Best_Inv_Weapon then
                        if not Best_Inv_Weapon.pap then
                            local loc = pack_a_punch:GetLocation()
                            local point_around = Navigation.GetRandomPointInNavigableRadius(loc, Bots_Reach_PAP_Around)
                            if (point_around and point_around ~= Vector(0, 0, 0)) then
                                local path = Navigation.FindPathToLocation(char:GetLocation(), point_around)
                                --print(NanosUtils.Dump(path))
                                if (path.IsValid and not path.IsPartial) then
                                    if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                                        DrawBotMovementCylinder(char:GetLocation(), point_around, Color.GREEN, v)
                                    end
                                    Events.CallRemote("BotAction", bot_id, v, point_around, pack_a_punch, prereach)
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end,
    DOORS = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        local door_target = GetDoorToOpen(Bot, char, ROOMS_UNLOCKED, prereach)
        if door_target then
            local loc = door_target:GetLocation()
            if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                DrawBotMovementCylinder(char:GetLocation(), loc, Color.GREEN, v)
            end
            Events.CallRemote("BotAction", bot_id, v, loc, door_target, prereach)
            return true
        end
    end,
    MOVE = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        local reachable_loc = GetBotMoveLocation(Bot, char)
        if (reachable_loc and reachable_loc ~= Vector(0, 0, 0)) then
            Events.CallRemote("BotAction", bot_id, v, reachable_loc, nil, prereach)
        else
            Events.CallRemote("BotAction", bot_id, "FAILED", nil, prereach)
            Console.Warn("Bot MOVE didn't find ReachablePoint")
        end
        return true
    end,
    REVIVE = function(Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
        local down_char = GetNearestCharacterThatNeedRevive(char)

        if down_char then
            local loc = down_char:GetLocation()
            local nearest_e, nearest_dist_sq = GetNearestEnemy(loc)

            --if nearest_e then
                --print(math.sqrt(nearest_dist_sq), math.sqrt(char:GetLocation():DistanceSquared(loc) + Bots_Min_Nearest_Zombie_Distance_To_Revive_sq))
            --end

            if ((not nearest_e) or (nearest_dist_sq >= (char:GetLocation():DistanceSquared(loc) + Bots_Min_Nearest_Zombie_Distance_To_Revive_sq))) then
                if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                    DrawBotMovementCylinder(char:GetLocation(), loc, Color.GREEN, v)
                end
                Events.CallRemote("BotAction", bot_id, v, loc, down_char, prereach) -- Go revive
                return true
            else
                local reachable_loc = Navigation.GetRandomReachablePointInRadius(down_char:GetLocation(), Bots_Approaching_Down_Character_Radius) -- Try to approach down character

                local path = Navigation.FindPathToLocation(char:GetLocation(), reachable_loc)
                if (path.IsValid and not path.IsPartial) then

                    if ZDEV_IsModeEnabled("ZDEV_DEBUG_BOTS_ACTIONS") then
                        DrawBotMovementCylinder(char:GetLocation(), reachable_loc, Color.GREEN, "Revive_Around")
                    end
                    Events.CallRemote("BotAction", bot_id, "MOVE", reachable_loc, nil, prereach)
                    return true
                end
            end
        end
    end,
}


VZ_EVENT_SUBSCRIBE_REMOTE("RequestBotAction", function(bot_id, bot_stored, bot_inv, ROOMS_UNLOCKED, prereach)
    --print("RequestBotAction", bot_id)
    local Bot = CL_VZBot(bot_id, bot_stored)
    if Bot then
        local char = Bot:GetControlledCharacter()

        if not char:GetValue("PlayerDown") then
            for i, v in ipairs(Bots_Behavior_Config) do
                local ret = Clientside_Bot_Actions[v](Bot, bot_id, bot_inv, ROOMS_UNLOCKED, char, v, prereach)
                if ret then
                    return
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

                                for k, v in pairs(PreparedLoops.Enemies) do
                                    if v:GetHealth() > 0 then
                                        local loc = v:GetLocation()
                                        if char_loc:DistanceSquared(loc) <= Bots_Target_MaxDistance3D_Sq then
                                            local enemy_name = v:GetValue("EnemyName")
                                            local enemy_type = v:GetValue("EnemyType")

                                            local Aim_Offset = Vector(0, 0, 0)
                                            if Enemies_Config[enemy_name].Types[enemy_type].Bot_Aim_Offset then
                                                Aim_Offset = Enemies_Config[enemy_name].Types[enemy_type].Bot_Aim_Offset
                                            end

                                            local trace_mode = TraceMode.ReturnEntity
                                            if ZDEV_IsModeEnabled("ZDEV_DEBUG_TRACES") then
                                                trace_mode = trace_mode | TraceMode.DrawDebug
                                            end

                                            local trace = Trace.LineSingle(
                                                char_loc + Vector(0, 0, 90),
                                                loc + Aim_Offset,
                                                --CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.Pawn | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Mesh,
                                                CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Mesh,
                                                trace_mode,
                                                {char}
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

                                --print("can_shoot_on", table_count(can_shoot_on))

                                local CanShootOn = char:GetValue("BOTCanShootOn")
                                CanShootOn = CanShootOn or {}
                                local same = false
                                if Shooting_On then
                                    local same_count = 0
                                    for i, v in ipairs(can_shoot_on) do
                                        for i2, v2 in ipairs(CanShootOn) do
                                            if v:GetID() == v2 then
                                                same_count = same_count + 1
                                            end
                                        end
                                    end
                                    if not (same_count == table_count(CanShootOn) and table_count(can_shoot_on) == table_count(CanShootOn)) then
                                        same = true
                                    end
                                end

                                if not same then
                                    Events.CallRemote("NewBotTargets", Bot:GetID(), can_shoot_on)
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


function BotOrder(char, order)
    if (char and char:IsValid()) then
        if (not char:GetValue("PlayerDown") and not char:IsInRagdollMode()) then
            local local_char = Client.GetLocalPlayer():GetControlledCharacter()
            if local_char and not local_char:GetValue("PlayerDown") then
                if order == "MoveTo" then
                    local cam_loc = Client.GetLocalPlayer():GetCameraLocation()
                    local cam_rot = Client.GetLocalPlayer():GetCameraRotation()
                    local forward_vec = cam_rot:GetForwardVector()

                    local trace_mode = nil
                    if ZDEV_IsModeEnabled("ZDEV_DEBUG_TRACES") then
                        trace_mode = trace_mode | TraceMode.DrawDebug
                    end

                    local trace = Trace.LineSingle(
                        cam_loc,
                        cam_loc + forward_vec * Bot_MoveTo_Order_Distance_From_Camera,
                        CollisionChannel.WorldStatic,
                        trace_mode,
                        {char}
                    )

                    if trace.Success then
                        local path = Navigation.FindPathToLocation(char:GetLocation(), trace.Location)
                        if (path.IsValid and not path.IsPartial) then
                            Events.CallRemote("BotOrder", char, order, trace.Location)
                        end
                    end
                else
                    Events.CallRemote("BotOrder", char, order)
                end
            end
        end
    end
end