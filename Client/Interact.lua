
POWER_ON = false

local InteractType = nil
local InteractThing = nil

local RepairBarricadeInterval

local RevivingPlayerData

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
                    Render.ClearItems(1)
                end
            end
        end
    end
end)

function InteractCheck(interact_type, Interact_Check_Interval_ms, CheckFunc)
    Timer.SetInterval(function()
        if (InteractType == nil or InteractType == interact_type) then
            local local_player = Client.GetLocalPlayer()
            local local_char = local_player:GetControlledCharacter()

            local found
            if local_char then
                local local_char_location = local_char:GetLocation()
                found = CheckFunc(local_player, local_char, local_char_location)
            end
            if not found then
                if InteractType == interact_type then
                    InteractType = nil
                    InteractThing = nil
                    Render.ClearItems(1)
                end
            end
        end
    end, Interact_Check_Interval_ms)
end

InteractCheck("MapDoor", Doors_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    --[[for k, v in pairs(StaticMesh.GetPairs()) do
        if v:IsValid() then
            local door_id = v:GetValue("DoorID")
            if door_id then
                local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                if distance_sq <= Doors_Interact_Check_Distance_Squared_Max then
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
    end]]--

    local Fwd = local_char:GetRotation():GetForwardVector()
    local trace = Client.Trace(local_char_location, local_char_location + Fwd * Doors_Interact_Check_Trace_Distance_Max, CollisionChannel.WorldStatic, true, true, false, {}, ZDEV_IsModeEnabled("ZDEV_DEBUG_TRACES"))
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

InteractCheck("MapBarricade", Barricades_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:IsValid() then
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
                        found = true
                    end
                end
            end
        end
    end

    return found
end)

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

InteractCheck("RevivePlayer", DownPlayer_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    for k, v in pairs(Character.GetPairs()) do
        if (v:IsValid() and not IsSelfCharacter(v)) then
            local RevivingPlayer = v:GetValue("RevivingPlayer")
            if (v:GetValue("PlayerDown") and (not RevivingPlayer or RevivingPlayer == local_char:GetID())) then
                local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                if distance_sq <= DownPlayer_Interact_Check_Distance_Squared_Max then
                    if not RevivingPlayerData then
                        InteractText("Hold to Revive Player")
                        InteractType = "RevivePlayer"
                        InteractThing = v
                    end
                    found = true
                end
            end
        end
    end

    return found
end)

InteractCheck("MapMBOX", MBOX_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:IsValid() then
            local can_buy_mbox = v:GetValue("CanBuyMysteryBox")
            if can_buy_mbox then
                local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                if distance_sq <= MBOX_Interact_Check_Distance_Squared_Max then
                    InteractType = "MapMBOX"
                    BuyText("Mystery Box", tostring(Mystery_box_price))
                    InteractThing = v
                    found = true
                end
            end
        end
    end

    return found
end)

InteractCheck("MapPower", POWER_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    if not POWER_ON then
        for k, v in pairs(StaticMesh.GetPairs()) do
            if v:IsValid() then
                local is_Map_Power = v:GetValue("MapPower")
                if is_Map_Power then
                    local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                    if distance_sq <= POWER_Interact_Check_Distance_Squared_Max then
                        InteractType = "MapPower"
                        InteractText("Turn Power ON")
                        InteractThing = v
                        found = true
                    end
                end
            end
        end
    end

    return found
end)

InteractCheck("MapPerk", Perk_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:IsValid() then
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
                    found = true
                end
            end
        end
    end

    return found
end)

InteractCheck("MapPAP", PAP_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:IsValid() then
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
                    found = true
                end
            end
        end
    end

    return found
end)

InteractCheck("MapWunder", Wunderfizz_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    if table_count(CurPerks) < table_count(PERKS_CONFIG) then
        for k, v in pairs(StaticMesh.GetPairs()) do
            if v:IsValid() then
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

                        found = true
                    end
                end
            end
        end
    end

    return found
end)

InteractCheck("WunderBottle", Wunderfizz_Bottle_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
    local found

    if table_count(CurPerks) < table_count(PERKS_CONFIG) then
        for k, v in pairs(Prop.GetPairs()) do
            if v:IsValid() then
                local wunder_bottle = v:GetValue("RealBottleData")
                if wunder_bottle then
                    if wunder_bottle[1] == local_char:GetID() then
                        if (not CurPerks or not CurPerks[wunder_bottle[2]]) then
                            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                            if distance_sq <= Wunderfizz_Bottle_Interact_Check_Distance_Squared_Max then
                                InteractType = "WunderBottle"

                                InteractText("Take " .. wunder_bottle[2] .. " Perk")
                                InteractThing = v

                                found = true
                            end
                        end
                    end
                end
            end
        end
    end

    return found
end)

if MAP_INTERACT_TRIGGERS then
    InteractCheck("MapCustom", Custom_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
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
    InteractCheck("MapTeleporter", Teleporters_Interact_Check_Interval_ms, function(local_player, local_char, local_char_location)
        local found

        for k, v in pairs(StaticMesh.GetPairs()) do
            if v:IsValid() then
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

VZ_BIND("Interact", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            if InteractType == "MapDoor" then
                if InteractThing ~= "NoPower" then
                    Events.CallRemote("BuyDoor", InteractThing)
                end
            elseif InteractType == "MapBarricade" then
                if RepairBarricadeInterval then
                    Timer.ClearInterval(RepairBarricadeInterval)
                    RepairBarricadeInterval = nil
                end
                PlayStartRepairBarricade()
                RepairBarricadeInterval = Timer.SetInterval(RepairBarricadeIFunc, Repair_Barricade_Interval_ms)
            elseif InteractType == "RevivePlayer" then
                Events.CallRemote("RevivePlayer", InteractThing)
            elseif InteractType == "MapMBOX" then
                Events.CallRemote("BuyMBOX", InteractThing)
            elseif InteractType == "MapPower" then
                Events.CallRemote("TurnPowerON", InteractThing)
            elseif InteractType == "MapPerk" then
                if InteractThing ~= "NoPower" then
                    Events.CallRemote("BuyPerk", InteractThing)
                end
            elseif InteractType == "MapPAP" then
                if InteractThing ~= "NoPower" then
                    Events.CallRemote("UpgradeWeap", InteractThing)
                end
            elseif InteractType == "MapWunder" then
                if InteractThing ~= "NoPower" then
                    Events.CallRemote("BuyWunderfizz", InteractThing)
                end
            elseif InteractType == "WunderBottle" then
                if InteractThing:IsValid() then
                    Events.CallRemote("TakeWunderfizzPerk", InteractThing)
                end
            elseif InteractType == "MapCustom" then
                Events.Call(InteractThing.event_name, InteractThing)
                Events.CallRemote("CustomMapInteract", InteractThing)
            elseif InteractType == "MapTeleporter" then
                if InteractThing ~= "NoPower" then
                    if InteractThing:IsValid() then
                        if InteractThing:GetValue("CanTeleport") then
                            Events.CallRemote("BuyTeleport", InteractThing)
                        end
                    end
                end
            end
        end
    end
end)

VZ_BIND("Interact", InputEvent.Released, function()
    if InteractType == "MapBarricade" then
        if RepairBarricadeInterval then
            Timer.ClearInterval(RepairBarricadeInterval)
            RepairBarricadeInterval = nil
        end
    elseif (InteractType == "RevivePlayer" and RevivingPlayerData) then
        Timer.ClearTimeout(RevivingPlayerData.timeout)
        GUIStopRevive()
        Events.CallRemote("RevivePlayerStopped", RevivingPlayerData.char)
        RevivingPlayerData = nil
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