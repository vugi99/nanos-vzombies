
POWER_ON = false

InteractType = nil
InteractThing = nil

RepairBarricadeInterval = nil

RevivingPlayerData = nil

if VZ_GetFeatureValue("Map_Weapons", "can_interact") then
    VZ_EVENT_SUBSCRIBE("Character", "Highlight", function(char, Highlight, ent)
        if IsSelfCharacter(char) then
            if ent then -- error when highlight ground weapons :thinking:
                local m_weap_id = ent:GetValue("MapWeaponID")
                if m_weap_id then
                    if Highlight then
                        BuyText(MAP_WEAPONS[m_weap_id].weapon_name .. " / Ammo", tostring(MAP_WEAPONS[m_weap_id].price) .. "$ / " .. tostring(math.floor(MAP_WEAPONS[m_weap_id].price * Weapons_Ammo_Price_Percentage / 100)) .. " $ / " .. tostring(Pack_a_punch_price))
                        InteractType = "MapWeapon"
                        InteractThing = m_weap_id
                    elseif (InteractType == "MapWeapon" and InteractThing == m_weap_id) then
                        InteractType = nil
                        InteractThing = nil
                        One_Time_Update_Data.InteractText = nil
                        One_Time_Updates_Canvas:Repaint()
                    end
                end
            end
        end
    end)
end

function InteractCheck(interact_type, loop_params, Interact_Check_Interval_ms, CheckFunc)
    Timer.SetInterval(function()
        if (InteractType == nil or InteractType == interact_type) then
            local local_player = Client.GetLocalPlayer()
            local local_char = local_player:GetControlledCharacter()

            -- Gibs outline disable
            for k, v in pairs(Prop.GetPairs()) do
                if v:IsValid() then
                    if v:GetValue("OutlinedInteract") then
                        v:SetValue("OutlinedInteract", nil)
                        v:SetOutlineEnabled(false, 0)
                    end
                end
            end

            local found
            if local_char then
                local local_char_location = local_char:GetLocation()
                if loop_params then
                    for k, v in pairs(loop_params.LoopFunc()) do
                        if (not loop_params.check_is_valid or v:IsValid()) then
                            found = CheckFunc(local_player, local_char, local_char_location, v)
                            if found then
                                break
                            end
                        end
                    end
                else
                    found = CheckFunc(local_player, local_char, local_char_location)
                end
            end
            if not found then
                if InteractType == interact_type then
                    InteractType = nil
                    InteractThing = nil
                    One_Time_Update_Data.InteractText = nil
                    One_Time_Updates_Canvas:Repaint()
                end
            else
                if ZDEV_IsModeEnabled("ZDEV_DEBUG_INTERACT") then
                    print("Interact Found", interact_type, found)
                end
            end
        end
    end, Interact_Check_Interval_ms)
end

function InteractAction(CheckNoPower, event_name, check_valid)
    if (not CheckNoPower or InteractThing ~= "NoPower") then
        if (not check_valid or InteractThing:IsValid()) then
            Events.CallRemote(event_name, InteractThing)
        end
    end
end

InteractCheck("MapDoor", nil, Doors_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    local Fwd = local_char:GetRotation():GetForwardVector()

    local trace_mode = TraceMode.ReturnEntity
    if ZDEV_IsModeEnabled("ZDEV_DEBUG_TRACES") then
        trace_mode = trace_mode | TraceMode.DrawDebug
    end

    local trace = Client.TraceLineSingle(local_char_location, local_char_location + Fwd * Doors_Interact_Check_Trace_Distance_Max, CollisionChannel.WorldStatic, trace_mode, {})
    if trace.Success then
        local v = trace.Entity
        if v then
            local door_id = v:GetValue("DoorID")
            if door_id then
                InteractType = "MapDoor"
                found = true

                local power_needed = false
                if not POWER_ON then
                    for i3, v3 in ipairs(MAP_DOORS[door_id].required_rooms) do
                        if v3 == -1 then
                            power_needed = true
                            break
                        end
                    end
                end
                if not power_needed then
                    BuyText("Door", tostring(MAP_DOORS[door_id].price))
                    InteractThing = door_id
                else
                    InteractText("Missing Power")
                    InteractThing = "NoPower"
                end
            end
        end
    end

    return found
end)

if VZ_GetFeatureValue("Barricades", "can_interact") then
    InteractCheck("MapBarricade", {LoopFunc = StaticMesh.GetPairs, check_is_valid = true}, Barricades_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
        local zspawn_id = v:GetValue("BarricadeSpawnID")
        if zspawn_id then
            if v:GetValue("BarricadeLife") < 5 then
                local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                if distance_sq <= Barricades_Interact_Check_Distance_Squared_Max then
                    if InteractThing ~= v then
                        if RepairBarricadeInterval then
                            Timer.ClearInterval(RepairBarricadeInterval)
                            RepairBarricadeInterval = nil
                        end
                        InteractText("Hold to Repair Barricade")
                        InteractType = "MapBarricade"
                        InteractThing = v
                    end
                    return true
                end
            end
        end
    end)
end

function RepairBarricadeIFunc()
    if (InteractThing and NanosUtils.IsA(InteractThing, StaticMesh) and InteractThing:IsValid() and InteractThing:GetValue("BarricadeLife") and InteractThing:GetValue("BarricadeLife") < 5) then
        local repair_sound = Sound(
            Vector(0, 0, 0),
            Barricade_Repair_Sound.asset,
            true,
            true,
            SoundType.SFX,
            Barricade_Repair_Sound.volume
        )
        Events.CallRemote("RepairBarricade", InteractThing:GetValue("BarricadeSpawnID"))
    elseif RepairBarricadeInterval then
        Timer.ClearInterval(RepairBarricadeInterval)
        RepairBarricadeInterval = nil
    end
end

if VZ_GetFeatureValue("Revive", "can_interact") then
    InteractCheck("RevivePlayer", {LoopFunc = Character.GetPairs, check_is_valid = true}, DownPlayer_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
        if not IsSelfCharacter(v) then
            local RevivingPlayer = v:GetValue("RevivingPlayer")
            if (v:GetValue("PlayerDown") and (not RevivingPlayer or RevivingPlayer == local_char:GetID())) then
                local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                if distance_sq <= DownPlayer_Interact_Check_Distance_Squared_Max then
                    if not RevivingPlayerData then
                        InteractText("Hold to Revive Player")
                        InteractType = "RevivePlayer"
                        InteractThing = v
                    end
                    return true
                end
            end
        end
    end)
end

if VZ_GetFeatureValue("MysteryBox", "can_interact") then
    InteractCheck("MapMBOX", {LoopFunc = StaticMesh.GetPairs, check_is_valid = true}, MBOX_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
        local can_buy_mbox = v:GetValue("CanBuyMysteryBox")
        if can_buy_mbox then
            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
            if distance_sq <= MBOX_Interact_Check_Distance_Squared_Max then
                InteractType = "MapMBOX"
                BuyText("Mystery Box", tostring(Mystery_box_price))
                InteractThing = v
                return true
            end
        end
    end)
end

InteractCheck("MapPower", {LoopFunc = StaticMesh.GetPairs, check_is_valid = true}, POWER_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
    if not POWER_ON then
        local is_Map_Power = v:GetValue("MapPower")
        if is_Map_Power then
            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
            if distance_sq <= POWER_Interact_Check_Distance_Squared_Max then
                InteractType = "MapPower"
                InteractText("Turn Power ON")
                InteractThing = v
                return true
            end
        end
    end
end)

if VZ_GetFeatureValue("Perks", "can_interact") then
    InteractCheck("MapPerk", {LoopFunc = StaticMesh.GetPairs, check_is_valid = true}, Perk_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
        local perk = v:GetValue("MapPerk")
        if (perk and not CurPerks[perk]) then
            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
            if distance_sq <= Perk_Interact_Check_Distance_Squared_Max then
                InteractType = "MapPerk"
                if POWER_ON then
                    InteractThing = v
                    BuyText(perk .. " Perk", tostring(PERKS_CONFIG[perk].price))
                else
                    InteractThing = "NoPower"
                    InteractText("Missing Power")
                end
                return true
            end
        end
    end)
end

if VZ_GetFeatureValue("Pack_a_punch", "can_interact") then
    InteractCheck("MapPAP", {LoopFunc = StaticMesh.GetPairs, check_is_valid = true}, PAP_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
        local can_buy_pap = v:GetValue("CanBuyPackAPunch")
        if can_buy_pap then
            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
            if distance_sq <= PAP_Interact_Check_Distance_Squared_Max then
                InteractType = "MapPAP"
                if POWER_ON then
                    InteractThing = v
                    BuyText("Weapon Upgrade", tostring(Pack_a_punch_price))
                else
                    InteractThing = "NoPower"
                    InteractText("Missing Power")
                end
                return true
            end
        end
    end)
end

if VZ_GetFeatureValue("Wunderfizz", "can_interact") then
    InteractCheck("MapWunder", {LoopFunc = StaticMesh.GetPairs, check_is_valid = true}, Wunderfizz_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
        if table_count(CurPerks) < table_count(PERKS_CONFIG) then
            local can_buy_wunder = v:GetValue("CanBuyWunder")
            if can_buy_wunder then
                local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                if distance_sq <= Wunderfizz_Interact_Check_Distance_Squared_Max then
                    InteractType = "MapWunder"

                    if POWER_ON then
                        BuyText("Wunderfizz", tostring(Wonderfizz_Price))
                        InteractThing = v
                    else
                        InteractText("Missing Power")
                        InteractThing = "NoPower"
                    end

                    return true
                end
            end
        end
    end)
end

InteractCheck("WunderBottle", {LoopFunc = Prop.GetPairs, check_is_valid = true}, Wunderfizz_Bottle_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
    if table_count(CurPerks) < table_count(PERKS_CONFIG) then
        local wunder_bottle = v:GetValue("RealBottleData")
        if wunder_bottle then
            if wunder_bottle[1] == local_char:GetID() then
                if (not CurPerks or not CurPerks[wunder_bottle[2]]) then
                    local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                    if distance_sq <= Wunderfizz_Bottle_Interact_Check_Distance_Squared_Max then
                        InteractType = "WunderBottle"

                        InteractText("Take " .. wunder_bottle[2] .. " Perk")
                        InteractThing = v

                        return true
                    end
                end
            end
        end
    end
end)

if MAP_INTERACT_TRIGGERS then
    InteractCheck("MapCustom", nil, Custom_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
        local found

        for k, v in pairs(MAP_INTERACT_TRIGGERS) do
            local distance_sq = local_char_location:DistanceSquared(v.location)
            if distance_sq <= v.distance_sq then
                InteractType = "MapCustom"
                InteractThing = v
                InteractText(v.interact_text)
                found = true
            end
        end

        return found
    end)
end

if MAP_TELEPORTERS then
    if VZ_GetFeatureValue("Teleporters", "can_interact") then
        InteractCheck("MapTeleporter", {LoopFunc = StaticMesh.GetPairs, check_is_valid = true}, Teleporters_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
            local found

            local can_teleport = v:GetValue("CanTeleport")
            if (can_teleport or can_teleport == false) then
                local teleporter_ID = v:GetValue("TeleporterID")
                if teleporter_ID then
                    local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                    if distance_sq <= MAP_TELEPORTERS[teleporter_ID].distance_sq then
                        InteractType = "MapTeleporter"
                        if POWER_ON then
                            if can_teleport == false then
                                InteractThing = "NoPower"
                                InteractText("Teleporter in cooldown")
                            else
                                InteractThing = v
                                InteractText("Teleport (" .. tostring(MAP_TELEPORTERS[teleporter_ID].price) .. "$)")
                            end
                        else
                            InteractThing = "NoPower"
                            InteractText("Missing Power")
                        end
                        found = true
                    end
                end
            end

            return found
        end)
    end
end

if Enemies_Gibs_Can_Pickup then
    InteractCheck("Gib", {LoopFunc = Prop.GetPairs, check_is_valid = true}, Gibs_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location, v)
        local found

        local gib_data = v:GetValue("GibData")
        if gib_data then
            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
            if distance_sq <= Gibs_Interact_Check_Distance_Squared_Max then
                if Get3DLocationOnScreen(v:GetLocation()) then
                    InteractType = "Gib"
                    InteractThing = v
                    InteractText("")

                    InteractThing:SetOutlineEnabled(true, 0)
                    InteractThing:SetValue("OutlinedInteract", true)

                    found = true
                end
            end
        end

        return found
    end)
end

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "RevivingPlayer" then
        if value then
            local ply = Client.GetLocalPlayer()
            local local_char = ply:GetControlledCharacter()
            if local_char then
                if value == local_char:GetID() then
                    if (InteractThing and InteractType == "RevivePlayer") then
                        local rev_time = ReviveTime_ms
                        local perks = local_char:GetValue("OwnedPerks")
                        if (perks and perks["quick_revive"]) then
                            rev_time = PERKS_CONFIG.quick_revive.ReviveTime_ms
                        end
                        --print(rev_time)
                        GUIStartRevive(rev_time)
                        RevivingPlayerData = {}
                        RevivingPlayerData.timeout = Timer.SetTimeout(function()
                            RevivingPlayerData = nil
                            Events.CallRemote("RevivePlayerFinished", char)
                        end, rev_time)
                        RevivingPlayerData.char = char
                    else
                        Events.CallRemote("RevivePlayerStopped", char)
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if RevivingPlayerData then
        if RevivingPlayerData.char == char then
            Timer.ClearTimeout(RevivingPlayerData.timeout)
            GUIStopRevive()
            RevivingPlayerData = nil
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "SetClientPowerON", function(is_on)
    POWER_ON = is_on
    if not is_on then
        for k, v in pairs(PerksAmbSounds) do
            if v:IsValid() then
                v:Destroy()
            end
        end
        PerksAmbSounds = {}

        if (PapAmbSound and PapAmbSound:IsValid()) then
            PapAmbSound:Destroy()
        end
        PapAmbSound = nil
    end
end)