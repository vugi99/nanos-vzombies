


BARRICADES = {}

function DestroyBarricades()
    for i, v in ipairs(BARRICADES) do
        if v.top then
            for k2, v2 in pairs(v.top.barricades or {}) do
                if IsValid(v2) then
                    v2:Destroy()
                end
            end
        end
        if v.ground then
            for k2, v2 in pairs(v.ground.barricades or {}) do
                if IsValid(v2) then
                    v2:Destroy()
                end
            end
        end
        if v.top and IsValid(v.top.root) then
            v.top.root:Destroy()
        end
        if v.ground and IsValid(v.ground.root) then
            v.ground.root:Destroy()
        end
    end
    BARRICADES = {}
end

function SpawnBarricadePart(root, barricade_config, index)
    local barricade_part = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "nanos-world::SM_Cube"
    )
    barricade_part:AttachTo(root, AttachmentRule.KeepWorld, "")
    barricade_part:SetRelativeLocation(barricade_config[index].rlocation)
    barricade_part:SetRelativeRotation(barricade_config[index].rrotation)

    --print("SpawnBarricadePart", index, barricade_config[index].rlocation)

    barricade_part:SetScale(Vector(2, 0.1, 0.025))
    barricade_part:SetCollision(CollisionType.NoCollision)
    barricade_part:SetMaterial("nanos-world::M_NanosMasked")
    barricade_part:SetMaterialColorParameter("Tint", Color(0.545098, 0.352941, 0.168627))

    return barricade_part
end

function SpawnBarricade(zspawn, zspawnid)
    local SM_Root = StaticMesh(
        zspawn.barricade_location,
        zspawn.barricade_rotation,
        "nanos-world::SM_None"
    )
    SM_Root:SetValue("BarricadeSpawnID", zspawnid, true)
    SM_Root:SetValue("BarricadeLife", 5, true)
    SM_Root:SetCollision(CollisionType.NoCollision)

    local SM_Root_Ground = StaticMesh(
        zspawn.z_ground_debris_location,
        Rotator(0, 0, 0),
        "nanos-world::SM_None"
    )
    SM_Root_Ground:AttachTo(SM_Root, AttachmentRule.KeepWorld, "")
    SM_Root_Ground:SetRelativeRotation(Barricades_Config.ground_root.rrotation)
    SM_Root_Ground:SetCollision(CollisionType.NoCollision)

    local barricades_parts = {}
    for i = 1, 5 do
        table.insert(barricades_parts, SpawnBarricadePart(SM_Root, Barricades_Config.top, i))
    end

    table.insert(BARRICADES, {
        zspawnid = zspawnid,
        top = {
            root = SM_Root,
            barricades = barricades_parts,
        },
        ground = {
            root = SM_Root_Ground,
            barricades = {},
        }
    })
end

function BarricadeAction(barricade, action)
    local top_count = #barricade.top.barricades
    local ground_count = #barricade.ground.barricades

    if action == "damage" and top_count > 0 then
        local rem_barr = table.remove(barricade.top.barricades)
        local action_loc = barricade.top.root:GetLocation()
        if IsValid(rem_barr) then
            action_loc = rem_barr:GetLocation()
            rem_barr:Destroy()
        end

        local new_top_count = #barricade.top.barricades
        barricade.top.root:SetValue("BarricadeLife", new_top_count, true)

        if #barricade.ground.barricades < 5 then
            local spawn_index = math.min(#barricade.ground.barricades + 1, 5)
            local SM_Barricade = SpawnBarricadePart(barricade.ground.root, Barricades_Config.ground, spawn_index)
            table.insert(barricade.ground.barricades, SM_Barricade)
        end

        local sound_tbl = RANDOM_SOUNDS["barricade_break"]
        Events.BroadcastRemoteInRadius(
            "PlayVZSound",
            action_loc,
            sound_tbl.falloff_distance,
            Reliability.Unreliable,
            { random_sound_tbl = sound_tbl, random_sound_selected = VZ_RandomSound(sound_tbl) },
            action_loc
        )

    elseif action == "repair" and top_count < 5 then
        -- Clean up cosmetic debris if any exists
        if ground_count > 0 then
            local rem_barr = table.remove(barricade.ground.barricades)
            if IsValid(rem_barr) then
                rem_barr:Destroy()
            end
        end

        -- Spawn next missing plank slot
        local spawn_index = math.min(top_count + 1, 5)
        local SM_Barricade = SpawnBarricadePart(barricade.top.root, Barricades_Config.top, spawn_index)
        table.insert(barricade.top.barricades, SM_Barricade)

        local new_top_count = #barricade.top.barricades
        barricade.top.root:SetValue("BarricadeLife", new_top_count, true)

        local action_loc = barricade.top.root:GetLocation()
        local sound_tbl = RANDOM_SOUNDS["barricade_slam"]
        Events.BroadcastRemoteInRadius(
            "PlayVZSound",
            action_loc,
            sound_tbl.falloff_distance,
            Reliability.Unreliable,
            { random_sound_tbl = sound_tbl, random_sound_selected = VZ_RandomSound(sound_tbl) },
            action_loc
        )
    end
end

function DamageBarricade(barricade)
    BarricadeAction(barricade, "damage")
end

function RepairBarricade(barricade)
    BarricadeAction(barricade, "repair")
end

function SpawnMapBarricades()
    for i, v in ipairs(MAP_ROOMS) do
        for k2, v2 in pairs(v) do
            if v2.type == "barricade" then
                SpawnBarricade(MAP_ROOMS[i][k2], v2.zspawnid)
            end
        end
    end
end

local curspawn_id = 1
for i, v in ipairs(MAP_ROOMS) do
    for k2, v2 in pairs(v) do
        MAP_ROOMS[i][k2].zspawnid = curspawn_id
        if v2.z_spawns then
            for k3, v3 in pairs(v2.z_spawns) do
                v3.zspawnid = curspawn_id
            end
        end
        curspawn_id = curspawn_id + 1
    end
end

function GetBarricadeFromZSpawnID(zspawnid)
    for k, v in pairs(BARRICADES) do
        if v.zspawnid == zspawnid then
            return k, v
        end
    end
end

function GetSpawnTargetFromZSpawnID(zspawnid)
    for k, v in pairs(MAP_ROOMS) do
        for k2, v2 in pairs(v) do
            if v2.zspawnid == zspawnid then
                return v2
            end
        end
    end
end

function GetSpawnFromZSpawnID(zspawnid)
    for k, v in pairs(SPAWNS_UNLOCKED) do
        if v.zspawnid == zspawnid then
            return v
        end
    end
end

VZ_EVENT_SUBSCRIBE_REMOTE("RepairBarricade", function(ply, zspawnid)
    if ply:GetValue("ZMoney") ~= -666 then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                local bid, barricade = GetBarricadeFromZSpawnID(zspawnid)
                if bid then
                    if barricade.top.root:GetValue("BarricadeLife") < 5 then
                        RepairBarricade(barricade)
                        AddMoney(ply, Player_Repair_Barricade_Money)
                    end
                end
            end
        end
    end
end)