


function DestroyMapTeleporters()
    for k, v in pairs(StaticMesh.GetAll()) do
        if v:GetValue("TeleporterID") then
            v:Destroy()
        end
    end
end

function CreateMapTeleporters()
    if MAP_TELEPORTERS then
        for i, v in ipairs(MAP_TELEPORTERS) do
            local teleporter
            if not v.instant_teleporter then
                --print(i, v.price)
                teleporter = StaticMesh(
                    v.location,
                    Rotator(0, 0, 0),
                    "nanos-world::SM_None"
                )
                teleporter:SetCollision(CollisionType.NoCollision)
                teleporter:SetValue("TeleporterID", i, true)
                teleporter:SetValue("CanTeleport", true, true)
            else
                teleporter = Trigger(v.location, Rotator(0, 0, 0), Vector(math.sqrt(v.distance_sq), 0, 0), TriggerType.Sphere, ZDEV_IsModeEnabled("ZDEV_DEBUG_TRIGGERS"), Color.Yellow, {"Character"})
                teleporter:SetValue("TeleporterID", i, false)
                teleporter:SetValue("CanTeleport", true, false)
            end
        end
    end
end

function BuyTeleport(ply, teleporter)
    if (teleporter and teleporter:IsValid()) then
        if teleporter:GetValue("CanTeleport") then
            local char = ply:GetControlledCharacter()
            if char then
                if (not char:GetValue("PlayerDown") and not char:GetVehicle()) then
                    local teleporter_ID = teleporter:GetValue("TeleporterID")
                    if (MAP_TELEPORTERS[teleporter_ID].bots_allowed or not ply.BOT) then
                        if Buy(ply, MAP_TELEPORTERS[teleporter_ID].price) then
                            local teleport_table = {
                                ply,
                            }
                            local in_tbl = 1

                            local Destination_Spawns_Count = table_count(MAP_TELEPORTERS[teleporter_ID].teleport_to)

                            if Destination_Spawns_Count > 1 then
                                local players_in_radius = GetPlayersInRadius_ToTeleport(ply, MAP_TELEPORTERS[teleporter_ID].location, MAP_TELEPORTERS[teleporter_ID].distance_sq)
                                for k, v in pairs(players_in_radius) do
                                    if (MAP_TELEPORTERS[teleporter_ID].bots_allowed or not v.BOT) then
                                        local _char = v:GetControlledCharacter()
                                        if _char then
                                            if not _char:GetVehicle() then
                                                if in_tbl < Destination_Spawns_Count then
                                                    table.insert(teleport_table, v)
                                                    in_tbl = in_tbl + 1
                                                end
                                            end
                                        end
                                    end
                                end
                            elseif Destination_Spawns_Count == 0 then
                                Package.Error("vzombies : A teleporter doesn't have any destination, teleporter " .. tostring(teleporter_ID))
                                return
                            end

                            for i, v in ipairs(teleport_table) do
                                local char_to_tp = v:GetControlledCharacter()
                                char_to_tp:SetLocation(MAP_TELEPORTERS[teleporter_ID].teleport_to[i].location + Vector(0, 0, 100))
                                char_to_tp:SetRotation(MAP_TELEPORTERS[teleporter_ID].teleport_to[i].rotation)
                                v:SetCameraRotation(MAP_TELEPORTERS[teleporter_ID].teleport_to[i].rotation)


                                Events.CallRemote("PlayVZSound", v, {basic_sound_tbl=Player_Teleport_Sound})
                            end

                            if MAP_TELEPORTERS[teleporter_ID].teleport_back_ms > 0 then
                                local TeleportBackCount = table_count(MAP_TELEPORTERS[teleporter_ID].teleport_back)
                                if TeleportBackCount ~= Destination_Spawns_Count then
                                    Package.Error("vzombies : Missing back destinations (spawns) for the teleporter " .. tostring(teleporter_ID))
                                    return
                                end

                                local teleport_back_timeout = Timer.SetTimeout(function()
                                    if teleporter:IsValid() then
                                        for i, v in ipairs(teleport_table) do
                                            if v:IsValid() then
                                                local char_to_tp = v:GetControlledCharacter()
                                                if char_to_tp then
                                                    char_to_tp:SetLocation(MAP_TELEPORTERS[teleporter_ID].teleport_back[i].location + Vector(0, 0, 100))
                                                    char_to_tp:SetRotation(MAP_TELEPORTERS[teleporter_ID].teleport_back[i].rotation)
                                                    v:SetCameraRotation(MAP_TELEPORTERS[teleporter_ID].teleport_back[i].rotation)

                                                    Events.CallRemote("PlayVZSound", v, {basic_sound_tbl=Player_Teleport_Sound})
                                                end
                                            end
                                        end
                                    end
                                end, MAP_TELEPORTERS[teleporter_ID].teleport_back_ms)
                            end

                            if MAP_TELEPORTERS[teleporter_ID].teleporter_cooldown_ms > 0 then
                                teleporter:SetValue("CanTeleport", false, true)
                                Timer.SetTimeout(function()
                                    if teleporter:IsValid() then
                                        teleporter:SetValue("CanTeleport", true, true)
                                    end
                                end, MAP_TELEPORTERS[teleporter_ID].teleporter_cooldown_ms)
                            end
                        end
                    end
                end
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("BuyTeleport", BuyTeleport)

VZ_EVENT_SUBSCRIBE("Trigger", "BeginOverlap", function(trigger, char)
    if trigger:GetValue("TeleporterID") then
        local ply = char:GetPlayer()
        if ply then
            BuyTeleport(ply, trigger)
        end
    end
end)