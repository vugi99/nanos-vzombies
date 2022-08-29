


BARRICADES = {}

function DestroyBarricades()
    for i, v in ipairs(BARRICADES) do
        for k2, v2 in pairs(v.top.barricades) do
            v2:Destroy()
        end
        for k2, v2 in pairs(v.ground.barricades) do
            v2:Destroy()
        end
        v.top.root:Destroy()
        v.ground.root:Destroy()
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
    barricade_part:SetMaterial("vzombies-assets::M_Plank")

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
    local top_barricades = table_count(barricade.top.barricades)
    local ground_barricades = table_count(barricade.ground.barricades)

    if ((action == "damage" and top_barricades > 0) or (action == "repair" and ground_barricades > 0))  then
        local removed_name = "top"
        local added_name = "ground"
        local removed_barricade_count = top_barricades

        local random_sounds_name = "barricade_break"

        if action == "repair" then
            removed_name = "ground"
            added_name = "top"
            removed_barricade_count = ground_barricades
            random_sounds_name = "barricade_slam"
        end

        local removed_barricade_table = barricade[removed_name]
        local added_barricade_table = barricade[added_name]

        local action_loc
        if action == "damage" then
            action_loc = removed_barricade_table.barricades[removed_barricade_count]:GetLocation()
        end
        removed_barricade_table.barricades[removed_barricade_count]:Destroy()
        removed_barricade_table.barricades[removed_barricade_count] = nil

        local new_life = top_barricades - 1
        local new_index = ground_barricades + 1
        if action == "repair" then
            new_life = top_barricades + 1
            new_index = top_barricades + 1
        end

        barricade.top.root:SetValue("BarricadeLife", new_life, true)

        local SM_Barricade = SpawnBarricadePart(added_barricade_table.root, Barricades_Config[added_name], new_index)

        if action == "repair" then
            action_loc = barricade.top.root:GetLocation()
        end

        local random_sounds_table = RANDOM_SOUNDS[random_sounds_name]

        local play_sound_for_players = GetPlayersInRadius(action_loc, random_sounds_table.falloff_distance)
        for i, v in ipairs(play_sound_for_players) do
            Events.CallRemote("PlayVZSound", v, {random_sound_tbl=random_sounds_table, random_sound_selected=VZ_RandomSound(random_sounds_table)}, action_loc)
        end

        table.insert(added_barricade_table.barricades, SM_Barricade)
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

VZ_EVENT_SUBSCRIBE("Events", "RepairBarricade", function(ply, zspawnid)
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

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Server", "Chat", function(text, ply)
        if text == "/breakb" then
            for k, v in pairs(BARRICADES) do
                for i = 1, 5 do
                    DamageBarricade(v)
                end
            end
        end
    end)
end