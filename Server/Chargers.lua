

MAP_CHARGERS_SMs = {}

function SpawnMapChargers()
    if MAP_CHARGERS then
        if table_count(MAP_CHARGERS_SMs) > 0 then
            Console.Warn("MAP_CHARGERS_SMs not empty when creating new Chargers, destroying them first")
            DestroyMapChargers()
        end

        local charger_scale = VZ_GetFeatureValue("Chargers", "charger_scale")
        for id, v in ipairs(MAP_CHARGERS) do
            local charger_sm = StaticMesh(v.location, v.rotation, VZ_GetFeatureValue("Chargers", "charger_asset"), CollisionType.Normal)
            if charger_scale then
                charger_sm:SetScale(charger_scale)
            end

            local charger_emissive_key = VZ_GetFeatureValue("Chargers", "charger_emissive_key")
            if charger_emissive_key then
                local mat_index = VZ_GetFeatureValue("Chargers", "charger_emissive_material_index") or -1
               charger_sm:SetMaterialScalarParameter(charger_emissive_key, 0.0, mat_index)

               --print("Charger SetMaterialScalarParameter", charger_emissive_key, mat_index)
            end

            charger_sm:SetValue("MapChargerAttemptPrice", v.attempt_price, true)
            charger_sm:SetValue("MapChargerChargeTime", v.charge_time_ms, true)
            charger_sm:SetValue("MapChargerID", id, true)
            --print("SpawnMapChargers", "MapChargerID", charger_sm:GetValue("MapChargerID"))

            MAP_CHARGERS_SMs[id] = charger_sm
        end
    end
end
SpawnMapChargers()

function DestroyMapChargers()
    for _, v in pairs(MAP_CHARGERS_SMs) do
        if IsValid(v) then
            v:Destroy()
        end
    end
    MAP_CHARGERS_SMs = {}
end

function ResetMapCharger(sm)
    if not IsValid(sm) then return end

    local timeout = sm:GetValue("ChargingTimeout")
    if timeout and Timer.IsValid(timeout) then
        Timer.ClearTimeout(timeout)
    end

    local sphere_trigger = sm:GetValue("ChargingTrigger")
    if IsValid(sphere_trigger) then
        sphere_trigger:Destroy()
    end
    sm:SetValue("ChargingTrigger", nil, false)

    local cooldown_timeout = sm:GetValue("CooldownTimeout")
    if cooldown_timeout and Timer.IsValid(cooldown_timeout) then
        Timer.ClearTimeout(cooldown_timeout)
    end
    sm:SetValue("CooldownTimeout", nil, false)

    local update_players_pos_interval = sm:GetValue("ChargingUpdateValidPlayerPosInterval")
    if update_players_pos_interval and Timer.IsValid(update_players_pos_interval) then
        Timer.ClearInterval(update_players_pos_interval)
    end
    sm:SetValue("ChargingUpdateValidPlayerPosInterval", nil, false)

    sm:SetValue("Charged", true, true)
    sm:SetValue("Charging", nil, true)

    sm:SetValue("Charged", nil, true)
    sm:SetValue("Charging", nil, true)
end

function ResetMapChargers()
    for _, v in pairs(MAP_CHARGERS_SMs) do
        ResetMapCharger(v)
    end
end
VZ_EVENT_SUBSCRIBE("Events", "VZ_GameEnding", ResetMapChargers)

function CanChargeModule(ply, sm)
    if not IsValid(ply) then return end
    if not IsValid(sm) then return end

    local char = ply:GetControlledCharacter()
    if not IsValid(char) then return end
    if char:GetValue("PlayerDown") then return end

    local charger_id = sm:GetValue("MapChargerID")
    if not charger_id then return end
    local charger_data = MAP_CHARGERS[charger_id]
    if not charger_data then return end

    if sm:GetValue("Charged") then return Events.CallRemote("AddNotification", ply, "Module already charged") end
    if sm:GetValue("Charging") then return Events.CallRemote("AddNotification", ply, "Module is already charging") end
    if sm:GetValue("InCooldown") then return Events.CallRemote("AddNotification", ply, "Module is in cooldown") end

    local charger_sphere_loc = charger_data.location + charger_data.sphere_offset

    local players_characters_in_zone = {}
    for _, v in pairs(PLAYING_PLAYERS) do
        local zone_char = v:GetControlledCharacter()
        if IsValid(zone_char) and (not char:GetValue("PlayerDown")) then
            if not zone_char:GetValue("ChargingChargerID") then
                if charger_sphere_loc:DistanceSquared(zone_char:GetLocation()) <= charger_data.zone_distance^2 then
                    table.insert(players_characters_in_zone, zone_char)
                end
            end
        end
    end

    --print("players_characters_in_zone", NanosTable.Dump(players_characters_in_zone))
    if #players_characters_in_zone == 0 then
        Console.Warn("CanChargeModule called without any player inside the blocking zone? (ID: " .. tostring(charger_id) .. ")")
        return
    end

    if charger_data.wait_all_alive_players and #players_characters_in_zone < GetPlayersAliveNB() then return Events.CallRemote("AddNotification", ply, "All Players need to be here to charge this module") end

    return charger_data, players_characters_in_zone
end

local function UpdatePlayersInZoneSavedPos(sm)
    if not IsValid(sm) then return end
    local charger_id = sm:GetValue("MapChargerID")
    if not charger_id then return end
    local charger_data = MAP_CHARGERS[charger_id]
    if not charger_data then return end

    local sphere_loc = sm:GetLocation() + charger_data.sphere_offset
    local substracted = PlayerSpeedMultiplier*(380/1.5)
    local dist_check_sq = math.max((charger_data.zone_distance-substracted), 0)^2
    if dist_check_sq <= 0 then
        Console.Warn("Charger ID " .. tostring(charger_id) .. " has a zone_distance that is too small (" .. tostring(charger_data.zone_distance) .. ") to force_keep_players_inside, should be at least greater than " .. string.format("%.2f", substracted))
        return
    end

    local i_players_in_zone = sm:GetValue("ChargingPlayers")
    if i_players_in_zone then
        for _, v in pairs(i_players_in_zone) do
            if IsValid(v) and (not v:GetValue("PlayerDown")) then
                local dist_sq = v:GetLocation():DistanceSquared(sphere_loc)
                if dist_sq <= dist_check_sq then
                    v:SetValue("ChargingLastSavedPos", v:GetLocation(), false)
                elseif dist_sq > charger_data.zone_distance^2 then
                    -- Player somehow got out of the zone, maybe grenades...
                    CheckChargerModuleLosePlayer(v)
                end
            end
        end
    else
        error("ChargingPlayers is not valid in update_players_pos_interval, forgot to clear interval")
    end
end

function SetCharacterChargingID(char, charging_id, abort_no_error)
    if not IsValid(char) then return end

    char:SetValue("ChargingChargerID", charging_id, false)

    local ply = char:GetPlayer()
    if not IsValid(ply) then
        if not abort_no_error then
            Console.Error("SetCharacterChargingID char is not possessed")
        end
        return
    end

    Events.CallRemote("ClientSetChargingID", ply, charging_id, GAME_TIMER_SECONDS)
end

function ChargeModule(sm, players_characters_in_zone)
    local charger_id = sm:GetValue("MapChargerID")
    if not charger_id then return end
    local charger_data = MAP_CHARGERS[charger_id]
    if not charger_data then return end

    if sm:GetValue("Charged") then return end
    if sm:GetValue("Charging") then return end
    if type(players_characters_in_zone) ~= "table" then return error("ChargeModule players_characters_in_zone is not a table") end
    for i, v in pairs(players_characters_in_zone) do
        if IsValid(v) then
            SetCharacterChargingID(v, charger_id)
        else
            players_characters_in_zone[i] = nil
        end
    end

    if table_count(players_characters_in_zone) <= 0 then return error("ChargeModule empty players_characters_in_zone after checks and removing Invalid entities") end

    sm:SetValue("Charging", true, true)

    -- TODO: better trigger visualisation as only debug can be used for now to see the zone
    local sphere_trigger = Trigger(sm:GetLocation() + charger_data.sphere_offset, Rotator(), Vector(charger_data.zone_distance), TriggerType.Sphere, true, Color.RED, {"Character"})
    sphere_trigger:AttachTo(sm, AttachmentRule.KeepWorld, nil, 0)
    sphere_trigger:ForceOverlapChecking()

    sphere_trigger:Subscribe("EndOverlap", function(trigger, char)
        if charger_data.force_keep_players_inside then
            if char:GetValue("ChargingChargerID") == charger_id then
                local last_inside_pos = char:GetValue("ChargingLastSavedPos")
                if last_inside_pos then
                    char:SetLocation(last_inside_pos)
                    return
                end
            end
        end
        CheckChargerModuleLosePlayer(char)
    end)

    local charging_timeout = Timer.SetTimeout(function()
        if IsValid(sm) then
            sm:SetValue("ChargingTimeout", nil, false)

            local t_charging_players = sm:GetValue("ChargingPlayers")
            if type(t_charging_players) == "table" then
                for _, v in pairs(t_charging_players) do
                    if IsValid(v) then
                        SetCharacterChargingID(v, nil)
                        v:SetValue("ChargingLastSavedPos", nil, false)
                    end
                end
            end

            sm:SetValue("ChargingPlayers", nil, false)
            if IsValid(sphere_trigger) then
                sphere_trigger:Destroy()
            end
            sm:SetValue("ChargingTrigger", nil, false)

            local update_players_pos_interval = sm:GetValue("ChargingUpdateValidPlayerPosInterval")
            if update_players_pos_interval and Timer.IsValid(update_players_pos_interval) then
                Timer.ClearInterval(update_players_pos_interval)
            end
            sm:SetValue("ChargingUpdateValidPlayerPosInterval", nil, false)

            sm:SetValue("Charged", true, true)
            sm:SetValue("Charging", nil, true)

            local charger_emissive_key = VZ_GetFeatureValue("Chargers", "charger_emissive_key")
            local charger_emissive_target = VZ_GetFeatureValue("Chargers", "charger_emissive_target")
            if charger_emissive_key and charger_emissive_target then
               sm:SetMaterialScalarParameter(charger_emissive_key, charger_emissive_target, VZ_GetFeatureValue("Chargers", "charger_emissive_material_index") or -1)
            end

            VZ_EVENT_CALL("Events", "VZ_ChargerChargeSuccessful", sm, charger_id)
        end
    end, charger_data.charge_time_ms)
    Timer.Bind(charging_timeout, sm)
    sm:SetValue("ChargingTimeout", charging_timeout, false)
    sm:SetValue("ChargingPlayers", players_characters_in_zone, false)
    sm:SetValue("ChargingTrigger", sphere_trigger, false)

    if charger_data.force_keep_players_inside then
        local update_players_pos_interval = Timer.SetInterval(UpdatePlayersInZoneSavedPos, 2500, sm)
        Timer.Bind(update_players_pos_interval, sm)
        UpdatePlayersInZoneSavedPos(sm)

        sm:SetValue("ChargingUpdateValidPlayerPosInterval", update_players_pos_interval, false)
    end

    VZ_EVENT_CALL("Events", "VZ_ChargerBeganCharge", sm, charger_id, players_characters_in_zone)

    return true
end

function AttemptChargeModule(ply, sm)
    local charger_data, players_characters_in_zone = CanChargeModule(ply, sm)
    if charger_data then
        local price = charger_data.attempt_price or 0
        if price <= 0 or Buy(ply, price) then
            return ChargeModule(sm, players_characters_in_zone)
        end
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("ChargerChargeModule", AttemptChargeModule)


function ChargerFailed(sm)
    if not IsValid(sm) then return end
    local charger_id = sm:GetValue("MapChargerID")
    if not charger_id then return end
    local charger_data = MAP_CHARGERS[charger_id]
    if not charger_data then return end

    local timeout = sm:GetValue("ChargingTimeout")
    if timeout and Timer.IsValid(timeout) then
        Timer.ClearTimeout(timeout)
    end

    local players_characters_in_zone = sm:GetValue("ChargingPlayers")
    if players_characters_in_zone then
        for k, v in pairs(players_characters_in_zone) do
            if IsValid(v) then
                SetCharacterChargingID(v, nil)
                v:SetValue("ChargingLastSavedPos", nil, false)
            end
        end
    end

    local sphere_trigger = sm:GetValue("ChargingTrigger")
    if IsValid(sphere_trigger) then
        sphere_trigger:Destroy()
    end
    sm:SetValue("ChargingTrigger", nil, false)

    if charger_data.cooldown_attempt_ms and charger_data.cooldown_attempt_ms > 0 then
        sm:SetValue("InCooldown", true, true)
        local cooldown_timeout = Timer.SetTimeout(function()
            sm:SetValue("CooldownTimeout", nil, false)
            sm:SetValue("InCooldown", nil, true)

            VZ_EVENT_CALL("Events", "VZ_ChargerCooldownFinished", sm, charger_id)
        end, charger_data.cooldown_attempt_ms)
        Timer.Bind(cooldown_timeout, sm)
        sm:SetValue("CooldownTimeout", cooldown_timeout, false)
    end

    local update_players_pos_interval = sm:GetValue("ChargingUpdateValidPlayerPosInterval")
    if update_players_pos_interval and Timer.IsValid(update_players_pos_interval) then
        Timer.ClearInterval(update_players_pos_interval)
    end
    sm:SetValue("ChargingUpdateValidPlayerPosInterval", nil, false)

    --sm:SetValue("Charged", nil, true)
    sm:SetValue("Charging", nil, true)

    VZ_EVENT_CALL("Events", "VZ_ChargerChargeFailed", sm, charger_id)

    return true
end

function CheckChargerFailed(sm)
    if not IsValid(sm) then return end

    local players_characters_in_zone = sm:GetValue("ChargingPlayers")

    if table_count(players_characters_in_zone) <= 0 then
        return ChargerFailed(sm)
    end
end

function CheckChargerModuleLosePlayer(char)
    if not IsValid(char) then return end
    local charging_module = char:GetValue("ChargingChargerID")
    if not charging_module then return end
    if MAP_CHARGERS_SMs[charging_module] and IsValid(MAP_CHARGERS_SMs[charging_module]) then
        local players_characters_in_zone = MAP_CHARGERS_SMs[charging_module]:GetValue("ChargingPlayers")
        if type(players_characters_in_zone) == "table" then
            local changed
            for k, v in pairs(players_characters_in_zone) do
                if v == char then
                    players_characters_in_zone[k] = nil
                    changed = true
                end
            end

            if changed then
                MAP_CHARGERS_SMs[charging_module]:SetValue("ChargingPlayers", players_characters_in_zone, false)

                CheckChargerFailed(MAP_CHARGERS_SMs[charging_module])
            end
        end
    end

    SetCharacterChargingID(char, nil, true)
    char:SetValue("ChargingLastSavedPos", nil, false)
end
VZ_EVENT_SUBSCRIBE("Character", "Destroy", CheckChargerModuleLosePlayer)
VZ_EVENT_SUBSCRIBE("Events", "VZ_CharacterDown", CheckChargerModuleLosePlayer)