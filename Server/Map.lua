

DOORS_STATIC_MESHES = {}

SPAWNS_UNLOCKED = {}
SPAWNS_ENABLED = {}
ROOMS_UNLOCKED = {}
ROOMS_SPAWNS_DISABLED = {}

MAP_POWER_SM = nil
MAP_POWER_SM_HANDLE = nil


function DestroyMapDoors()
    for k, v in pairs(StaticMesh.GetAll()) do
        if v:GetValue("DoorID") then
            v:Destroy()
        end
    end
end

function SpawnMapDoors()
    for i, v in ipairs(MAP_DOORS) do
        local SM = StaticMesh(
            v.location,
            v.rotation,
            v.model
        )
        SM:SetScale(v.scale)
        SM:SetValue("DoorID", i, true)
        table.insert(DOORS_STATIC_MESHES, SM)
    end
end

function GetMapDoorFromID(door_id)
    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:GetValue("DoorID") == door_id then
            return v
        end
    end
    return false
end

if MAP_POWER then
    local SM = StaticMesh(
        MAP_POWER.location,
        MAP_POWER.rotation,
        "vzombies-assets::power_base"
    )
    SM:SetScale(Vector(0.01, 0.01, 0.01))
    SM:SetValue("MapPower", true, true)

    MAP_POWER_SM = SM

    local SM_Handle = StaticMesh(
        MAP_POWER.handle_location,
        MAP_POWER.handle_rotation,
        "vzombies-assets::power_handle"
    )
    SM_Handle:SetScale(Vector(0.01, 0.01, 0.01))
    SM_Handle:SetCollision(CollisionType.NoCollision)
    SM_Handle:SetValue("MapPowerHANDLE", true, true)

    MAP_POWER_SM_HANDLE = SM_Handle
else
    POWER_ON = true
end

function ResetMapPower()
    if MAP_POWER then
        POWER_ON = false
        Events.BroadcastRemote("SetClientPowerON", false)
        MAP_POWER_SM_HANDLE:SetRotation(MAP_POWER.handle_rotation)
    end
end

function PlayerTurnPowerON(ply, power_sm)
    --print(ply, power_sm)
    if not POWER_ON then
        if power_sm:IsValid() then
            if power_sm == MAP_POWER_SM then
                if ply:GetValue("ZMoney") ~= -666 then -- Means that they shouldn't do anything
                    local char = ply:GetControlledCharacter()
                    if char then
                        if not char:GetValue("PlayerDown") then
                            POWER_ON = true
                            ROOMS_UNLOCKED[-1] = true
                            MAP_POWER_SM_HANDLE:RotateTo(MAP_POWER.rotation, 2, 0)
                            Events.BroadcastRemote("PowerONSound")

                            for i, v in ipairs(MAP_DOORS) do
                                if v.price == 0 then
                                    local good_needed_power = false
                                    for i2, v2 in ipairs(v.required_rooms) do
                                        if v2 == -1 then
                                            good_needed_power = true
                                            break
                                        end
                                    end
                                    if good_needed_power then
                                        local good_required_all = true
                                        for i2, v2 in ipairs(v.required_rooms) do
                                            if not ROOMS_UNLOCKED[v2] then
                                                good_required_all = false
                                                break
                                            end
                                        end

                                        if good_required_all then
                                            local map_door = GetMapDoorFromID(i)

                                            if map_door then
                                                map_door:Destroy()
                                                for i2, v2 in ipairs(v.between_rooms) do
                                                    UnlockRoom(v2)
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
        end
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("TurnPowerON", PlayerTurnPowerON)

function UnlockRoom(id)
    if not ROOMS_UNLOCKED[id] then
        ROOMS_UNLOCKED[id] = true
        for k, v in pairs(MAP_ROOMS[id]) do
            if v.type == "ground" then
                local t_Insert = {
                    location = v.location,
                    rotation = v.rotation,
                    zspawnid = v.zspawnid,
                    room_id = id,
                }
                table.insert(SPAWNS_UNLOCKED, t_Insert)
                if not ROOMS_SPAWNS_DISABLED[id] then
                    table.insert(SPAWNS_ENABLED, t_Insert)
                end
            else
                for k2, v2 in pairs(v.z_spawns) do
                    table.insert(SPAWNS_UNLOCKED, v2)
                    if not ROOMS_SPAWNS_DISABLED[id] then
                        table.insert(SPAWNS_ENABLED, v2)
                    end
                end
            end
        end
        Events.Call("VZ_RoomUnlocked", id)
    end
end

function DisableRoomSpawns(id)
    ROOMS_SPAWNS_DISABLED[id] = true
    local spawns_to_remove = {}
    for i, v in ipairs(SPAWNS_ENABLED) do
        if v.room_id == id then
            table.insert(spawns_to_remove, i)
        end
    end
    for i, v in ipairs(spawns_to_remove) do
        table.remove(SPAWNS_ENABLED, v - i + 1)
    end
end
Package.Export("DisableRoomSpawns", DisableRoomSpawns)

function EnableRoomSpawns(id)
    if ROOMS_SPAWNS_DISABLED[id] then
        ROOMS_SPAWNS_DISABLED[id] = nil
        for i, v in ipairs(SPAWNS_UNLOCKED) do
            if v.room_id == id then
                table.insert(SPAWNS_ENABLED, v)
            end
        end
    end
end
Package.Export("EnableRoomSpawns", EnableRoomSpawns)

if VZ_GetFeatureValue("Map_Weapons", "spawned") then
    for i, v in ipairs(MAP_WEAPONS) do
        if NanosWorldWeapons[v.weapon_name] then
            local weapon = NanosWorldWeapons[v.weapon_name](v.location, v.rotation)
            weapon:SetValue("MapWeaponID", i, true)
            weapon:SetGravityEnabled(false)
            weapon:SetCollision(CollisionType.NoCollision)
        else
            Package.Error("vzombies : Invalid weapon name '" .. v.weapon_name .. "' in zombie map config (MAP_WEAPONS[" .. tostring(i) .. "])")
        end
    end
end

if MAP_LIGHT_ZONES then
    for i, v in ipairs(MAP_LIGHT_ZONES) do
        --print(ZDEV_IsModeEnabled("ZDEV_DEBUG_TRIGGERS"))
        local trigger = Trigger(v.location, v.rotation, v.scale * 31.5, TriggerType.Box, ZDEV_IsModeEnabled("ZDEV_DEBUG_TRIGGERS"), Color.RED)

        VZ_ENT_EVENT_SUBSCRIBE(trigger, "BeginOverlap", function(self, triggered_by)
            if triggered_by:IsA(Character) then
                local ply = triggered_by:GetPlayer()
                if ply then
                    --print("FL Zone BeginOverlap")

                    local FLZones = triggered_by:GetValue("InFlashlightZones")
                    table.insert(FLZones, i)
                    triggered_by:SetValue("InFlashlightZones", FLZones, false)

                    if table_count(FLZones) == 1 then
                        AttachFlashLightToCurWeapon(triggered_by)
                    end
                end
            end
        end)

        VZ_ENT_EVENT_SUBSCRIBE(trigger, "EndOverlap", function(self, triggered_by)
            if triggered_by:IsA(Character) then
                local ply = triggered_by:GetPlayer()
                if ply then
                    --print("FL Zone EndOverlap")

                    local Was_in_zone
                    local FLZones = triggered_by:GetValue("InFlashlightZones")
                    for i2, v2 in ipairs(FLZones) do
                        if v2 == i then
                            table.remove(FLZones, i2)
                            Was_in_zone = true
                            break
                        end
                    end

                    if Was_in_zone then
                        triggered_by:SetValue("InFlashlightZones", FLZones, false)
                        if table_count(FLZones) == 0 then
                            local picked_thing = triggered_by:GetPicked()
                            if picked_thing then
                                if picked_thing:IsA(Weapon) then
                                    DetachFlashLightFromWeapon(picked_thing)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

if MAP_STATIC_MESHES then
    for i, v in ipairs(MAP_STATIC_MESHES) do
        local SM = StaticMesh(
            v.location,
            v.rotation,
            v.model
        )
        SM:SetScale(v.scale)
        SM:SetValue("MapSMID", i, false)
    end
end

function OpenMapDoor(door_id)
    local map_door = GetMapDoorFromID(door_id)
    if map_door then
        local required_rooms_good = true
        for i, v in ipairs(MAP_DOORS[door_id].required_rooms) do
            if not ROOMS_UNLOCKED[v] then
                required_rooms_good = false
                break
            end
        end

        if required_rooms_good then
            map_door:Destroy()
            for i, v in ipairs(MAP_DOORS[door_id].between_rooms) do
                UnlockRoom(v)
            end
            Events.Call("VZ_DoorOpened", char, door_id)

            return true
        end
    end
end