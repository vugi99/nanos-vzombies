

DOORS_STATIC_MESHES = {}

SPAWNS_UNLOCKED = {}
ROOMS_UNLOCKED = {}

BARRICADES = {}

SM_MysteryBoxes = {}
Active_MysteryBox_ID = nil
OpenedMysteryBox_Data = nil

MAP_POWER_SM = nil
MAP_POWER_SM_HANDLE = nil

MAP_PAP_SM = nil

SM_Wunderfizzes = {}
Active_Wunderfizz_ID = nil
local Wunderfizz_Bought_Timeout
local Wunderfizz_Finished_Waiting_Timeout
local Wunderfizz_Fake_Bottles_Interval
local Wunderfizz_Particle_Ref

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

function CreatePackAPunch(location, rotation)
    local SM = StaticMesh(
        location,
        rotation,
        "vzombies-assets::pack_a_punch"
    )
    SM:SetScale(Vector(0.01, 0.01, 0.01))
    SM:SetValue("IsPackAPunch", true, true)
    SM:SetValue("CanBuyPackAPunch", true, true)

    MAP_PAP_SM = SM
end

if MAP_PACK_A_PUNCH then
    CreatePackAPunch(MAP_PACK_A_PUNCH.location, MAP_PACK_A_PUNCH.rotation)
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
VZ_EVENT_SUBSCRIBE("Events", "TurnPowerON", PlayerTurnPowerON)

function DestroyMapPerks()
    for k, v in pairs(StaticMesh.GetAll()) do
        if v:GetValue("MapPerk") then
            v:Destroy()
        end
    end
end

function SpawnPerk(perk_name, location, rotation)
    local SM = StaticMesh(
        location,
        rotation,
        PERKS_CONFIG[perk_name].Asset
    )
    SM:SetScale(PERKS_CONFIG[perk_name].scale)
    SM:SetValue("MapPerk", perk_name, true)
    SM:SetValue("ProneMoney", true, false)
    return SM
end
Package.Export("SpawnPerk", SpawnPerk)

function SpawnMapPerks()
    if MAP_PERKS then
        for k, v in pairs(MAP_PERKS) do
            SpawnPerk(k, v.location, v.rotation)
        end
    end
end

function SpawnBearForMBOX(SM)
    local Bear_SM = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "vzombies-assets::mystery_box_fake_bear"
    )
    Bear_SM:SetScale(Vector(0.01, 0.01, 0.01))
    Bear_SM:AttachTo(SM, AttachmentRule.SnapToTarget, "")
    Bear_SM:SetRelativeLocation(Vector(0, 0, 5000))
    Bear_SM:SetRelativeRotation(Rotator(0, 0, 0))
    Bear_SM:SetCollision(CollisionType.NoCollision)

    return Bear_SM
end

if MAP_MYSTERY_BOXES then
    for i, v in ipairs(MAP_MYSTERY_BOXES) do
        local SM = StaticMesh(
            v.location,
            v.rotation,
            "vzombies-assets::mystery_box"
        )
        SM:SetScale(Vector(0.01, 0.01, 0.01))

        table.insert(SM_MysteryBoxes, {
            mbox = SM,
            bear = SpawnBearForMBOX(SM),
        })
    end
end

function OpenedMBOXResetStage1()
    Timer.ClearTimeout(OpenedMysteryBox_Data.MoveTimeout)
    Timer.ClearInterval(OpenedMysteryBox_Data.FakeInterval)
    OpenedMysteryBox_Data.MoveTimeout = nil
    OpenedMysteryBox_Data.FakeInterval = nil
    if OpenedMysteryBox_Data.fweap then
        OpenedMysteryBox_Data.fweap:Destroy()
        OpenedMysteryBox_Data.fweap = nil
    end
end

function OpenedMBOXResetStage2()
    Timer.ClearTimeout(OpenedMysteryBox_Data.MoveTimeout)
    OpenedMysteryBox_Data.realweap:Destroy()
    OpenedMysteryBox_Data.SM_Attach:Destroy()
end

function OpenedMBOXResetStage3(real_reset)
    OpenedMysteryBox_Data.SM_Attach:Destroy()
    OpenedMysteryBox_Data.bear:Destroy()
    if real_reset then
        Timer.ClearTimeout(OpenedMysteryBox_Data.bearTimeout)
    end
end

function ResetMBOX(id)
    if OpenedMysteryBox_Data then
        if OpenedMysteryBox_Data.FakeInterval then
            OpenedMBOXResetStage1()
        elseif OpenedMysteryBox_Data.realweap then
            OpenedMBOXResetStage2()
        elseif OpenedMysteryBox_Data.bear then
            OpenedMBOXResetStage3(true)
        end
        OpenedMysteryBox_Data = nil
    end
    SM_MysteryBoxes[id].mbox:SetValue("CanBuyMysteryBox", nil, true)
    SM_MysteryBoxes[id].bear = SpawnBearForMBOX(SM_MysteryBoxes[id].mbox)
    if (SM_MysteryBoxes[id].active_particle and SM_MysteryBoxes[id].active_particle:IsValid()) then
        SM_MysteryBoxes[id].active_particle:Destroy()
    end
    Active_MysteryBox_ID = nil
end

function ResetMysteryBoxes()
    if Active_MysteryBox_ID then
        ResetMBOX(Active_MysteryBox_ID)
    end
end

function PickNewMysteryBox()
    local pick_tbl = {}
    for i, v in ipairs(SM_MysteryBoxes) do
        if v.bear then
            table.insert(pick_tbl, i)
        end
    end

    if table_count(pick_tbl) > 0 then -- If theres more than 1 box on the map
        local random_pick_id = math.random(table_count(pick_tbl))
        local random_pick = SM_MysteryBoxes[pick_tbl[random_pick_id]]

        if Active_MysteryBox_ID then
            ResetMBOX(Active_MysteryBox_ID)
        end

        random_pick.bear:Destroy()
        random_pick.bear = nil
        random_pick.mbox:SetValue("CanBuyMysteryBox", true, true)
        random_pick.active_particle = Particle(
            Vector(0, 0, 0),
            Rotator(0, 0, 0),
            Active_MysteryBox_Particle.path,
            false,
            true
        )
        random_pick.active_particle:SetScale(Active_MysteryBox_Particle.scale)
        random_pick.active_particle:AttachTo(random_pick.mbox, AttachmentRule.SnapToTarget, "", 0)
        random_pick.active_particle:SetRelativeLocation(Active_MysteryBox_Particle.relative_location)
        random_pick.active_particle:SetRotation(Rotator(0, random_pick.active_particle:GetRotation().Yaw, 0))

        Active_MysteryBox_ID = pick_tbl[random_pick_id]
    end
end

function OpenedMBoxNewFakeWeapon()
    if OpenedMysteryBox_Data.fweap then
        OpenedMysteryBox_Data.fweap:Destroy()
    end
    local random_weap = Mystery_box_weapons[math.random(table_count(Mystery_box_weapons))]
    --print(random_weap.weapon_name)
    OpenedMysteryBox_Data.fweap = NanosWorldWeapons[random_weap.weapon_name](Vector(0, 0, 0), Rotator(0, 0, 0))
    OpenedMysteryBox_Data.fweap:SetCollision(CollisionType.NoCollision)
    OpenedMysteryBox_Data.fweap:SetGravityEnabled(false)
    OpenedMysteryBox_Data.fweap:SetValue("MBOXFakeWeapon", true, false)
    OpenedMysteryBox_Data.fweap:AttachTo(OpenedMysteryBox_Data.SM_Attach, AttachmentRule.SnapToTarget, "")
end

function OpenActiveMysteryBox(char)
    SM_MysteryBoxes[Active_MysteryBox_ID].mbox:SetValue("CanBuyMysteryBox", false, true)
    local SM = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "nanos-world::SM_None"
    )
    SM:SetCollision(CollisionType.NoCollision)
    SM:AttachTo(SM_MysteryBoxes[Active_MysteryBox_ID].mbox, AttachmentRule.SnapToTarget, "")
    SM:Detach()
    SM:SetLocation(SM:GetLocation() + Vector(0, 0, Mystery_box_weapon_spawn_offset_z))
    local targetTranslateTo = SM:GetLocation() + Vector(0, 0, Mystery_box_weapon_target_offset_z)
    SM:TranslateTo(targetTranslateTo, Mystery_box_weapon_time, Mystery_box_translate_exp)
    OpenedMysteryBox_Data = {
        SM_Attach = SM,
        FakeInterval = Timer.SetInterval(function()
            OpenedMBoxNewFakeWeapon()
        end, Mystery_box_fake_weapon_interval_ms),
        MoveTimeout = Timer.SetTimeout(function()
            OpenedMBOXResetStage1()

            local mbox_weapons_count = table_count(Mystery_box_weapons)
            local random_weap_id = math.random(mbox_weapons_count + 1)
            if table_count(MAP_MYSTERY_BOXES) == 1 then
                random_weap_id = math.random(mbox_weapons_count)
            end
            if random_weap_id <= mbox_weapons_count then
                if char:IsValid() then
                    local random_weap = Mystery_box_weapons[random_weap_id]
                    OpenedMysteryBox_Data.realweap = NanosWorldWeapons[random_weap.weapon_name](Vector(0, 0, 0), Rotator(0, 0, 0))
                    OpenedMysteryBox_Data.realweap:SetCollision(CollisionType.NoCollision)
                    OpenedMysteryBox_Data.realweap:SetGravityEnabled(false)
                    OpenedMysteryBox_Data.realweap:SetValue("MBOXFinalWeaponForCharacterID", {char:GetID(), random_weap}, false)
                    OpenedMysteryBox_Data.realweap:AttachTo(OpenedMysteryBox_Data.SM_Attach, AttachmentRule.SnapToTarget, "")
                    OpenedMysteryBox_Data.SM_Attach:TranslateTo(SM_MysteryBoxes[Active_MysteryBox_ID].mbox:GetLocation() + Vector(0, 0, Mystery_box_weapon_spawn_offset_z), Mystery_box_weapon_time_reverse, Mystery_box_translate_exp)

                    OpenedMysteryBox_Data.MoveTimeout = Timer.SetTimeout(function()
                        OpenedMBOXResetStage2()
                        OpenedMysteryBox_Data = nil

                        SM_MysteryBoxes[Active_MysteryBox_ID].mbox:SetValue("CanBuyMysteryBox", true, true)
                    end, Mystery_box_weapon_time_reverse * 1000)
                end
            else
                local Bear_SM = StaticMesh(
                    Vector(0, 0, 0),
                    Rotator(0, 0, 0),
                    "vzombies-assets::mystery_box_fake_bear"
                )
                Bear_SM:SetScale(Vector(0.01, 0.01, 0.01))
                Bear_SM:AttachTo(OpenedMysteryBox_Data.SM_Attach, AttachmentRule.SnapToTarget, "")
                Bear_SM:SetCollision(CollisionType.NoCollision)

                OpenedMysteryBox_Data.bear = Bear_SM
                OpenedMysteryBox_Data.bearTimeout = Timer.SetTimeout(function()
                    OpenedMBOXResetStage3()
                    OpenedMysteryBox_Data = nil
                    PickNewMysteryBox()
                end, NewMysteryBox_Timeout_ms)

                Events.BroadcastRemote("MBOXChangedSound")
            end
        end, Mystery_box_weapon_time * 1000),
    }
    OpenedMBoxNewFakeWeapon()
    Events.BroadcastRemote("OpenMBOXSound", SM_MysteryBoxes[Active_MysteryBox_ID].mbox:GetLocation())
end

function UnlockRoom(id)
    if not ROOMS_UNLOCKED[id] then
        ROOMS_UNLOCKED[id] = true
        for k, v in pairs(MAP_ROOMS[id]) do
            if v.type == "ground" then
                table.insert(SPAWNS_UNLOCKED, {
                    location = v.location,
                    rotation = v.rotation,
                    zspawnid = v.zspawnid
                })
            else
                for k2, v2 in pairs(v.z_spawns) do
                    table.insert(SPAWNS_UNLOCKED, v2)
                end
            end
        end
        Events.Call("VZ_RoomUnlocked", id)
    end
end

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

function ApplySMBarricadeOptions(SM)
    SM:SetScale(Vector(2, 0.1, 0.025))
    SM:SetCollision(CollisionType.NoCollision)
    SM:SetMaterial("vzombies-assets::M_Plank")
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

    local SM_Barricade_1 = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "nanos-world::SM_Cube"
    )
    SM_Barricade_1:AttachTo(SM_Root, AttachmentRule.KeepWorld, "")
    SM_Barricade_1:SetRelativeLocation(Barricades_Config.top[1].rlocation)
    SM_Barricade_1:SetRelativeRotation(Barricades_Config.top[1].rrotation)

    local SM_Barricade_2 = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "nanos-world::SM_Cube"
    )
    SM_Barricade_2:AttachTo(SM_Root, AttachmentRule.KeepWorld, "")
    SM_Barricade_2:SetRelativeLocation(Barricades_Config.top[2].rlocation)
    SM_Barricade_2:SetRelativeRotation(Barricades_Config.top[2].rrotation)

    local SM_Barricade_3 = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "nanos-world::SM_Cube"
    )
    SM_Barricade_3:AttachTo(SM_Root, AttachmentRule.KeepWorld, "")
    SM_Barricade_3:SetRelativeLocation(Barricades_Config.top[3].rlocation)
    SM_Barricade_3:SetRelativeRotation(Barricades_Config.top[3].rrotation)

    local SM_Barricade_4 = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "nanos-world::SM_Cube"
    )
    SM_Barricade_4:AttachTo(SM_Root, AttachmentRule.KeepWorld, "")
    SM_Barricade_4:SetRelativeLocation(Barricades_Config.top[4].rlocation)
    SM_Barricade_4:SetRelativeRotation(Barricades_Config.top[4].rrotation)

    local SM_Barricade_5 = StaticMesh(
        Vector(0, 0, 0),
        Rotator(0, 0, 0),
        "nanos-world::SM_Cube"
    )
    SM_Barricade_5:AttachTo(SM_Root, AttachmentRule.KeepWorld, "")
    SM_Barricade_5:SetRelativeLocation(Barricades_Config.top[5].rlocation)
    SM_Barricade_5:SetRelativeRotation(Barricades_Config.top[5].rrotation)

    table.insert(BARRICADES, {
        zspawnid = zspawnid,
        top = {
            root = SM_Root,
            barricades = {
                SM_Barricade_1,
                SM_Barricade_2,
                SM_Barricade_3,
                SM_Barricade_4,
                SM_Barricade_5,
            },
        },
        ground = {
            root = SM_Root_Ground,
            barricades = {},
        }
    })

    for k, v in pairs(BARRICADES) do
        if v.top.root == SM_Root then
            for i2, v2 in ipairs(v.top.barricades) do
                ApplySMBarricadeOptions(v2)
            end
        end
    end
end

function DamageBarricade(barricade, zombie)
    local top_barricades = table_count(barricade.top.barricades)
    local ground_barricades = table_count(barricade.ground.barricades)

    if top_barricades > 0  then
        local destroyed_loc = barricade.top.barricades[top_barricades]:GetLocation()
        barricade.top.barricades[top_barricades]:Destroy()
        barricade.top.barricades[top_barricades] = nil

        barricade.top.root:SetValue("BarricadeLife", top_barricades - 1, true)

        local SM_Barricade = StaticMesh(
            Vector(0, 0, 0),
            Rotator(0, 0, 0),
            "nanos-world::SM_Cube"
        )
        SM_Barricade:AttachTo(barricade.ground.root, AttachmentRule.KeepWorld, "")
        SM_Barricade:SetRelativeLocation(Barricades_Config.ground[ground_barricades + 1].rlocation)
        SM_Barricade:SetRelativeRotation(Barricades_Config.ground[ground_barricades + 1].rrotation)

        local play_sound_for_players = GetPlayersInRadius(destroyed_loc, RANDOM_SOUNDS.barricade_break.falloff_distance)
        for i, v in ipairs(play_sound_for_players) do
            Events.CallRemote("DamageBarricadeSound", v, VZ_RandomSound(RANDOM_SOUNDS.barricade_break), destroyed_loc)
        end

        ApplySMBarricadeOptions(SM_Barricade)
        table.insert(barricade.ground.barricades, SM_Barricade)
    end
end

function RepairBarricade(barricade)
    local top_barricades = table_count(barricade.top.barricades)
    local ground_barricades = table_count(barricade.ground.barricades)

    if ground_barricades > 0  then
        barricade.ground.barricades[ground_barricades]:Destroy()
        barricade.ground.barricades[ground_barricades] = nil

        barricade.top.root:SetValue("BarricadeLife", top_barricades + 1, true)

        local SM_Barricade = StaticMesh(
            Vector(0, 0, 0),
            Rotator(0, 0, 0),
            "nanos-world::SM_Cube"
        )
        SM_Barricade:AttachTo(barricade.top.root, AttachmentRule.KeepWorld, "")
        SM_Barricade:SetRelativeLocation(Barricades_Config.top[top_barricades + 1].rlocation)
        SM_Barricade:SetRelativeRotation(Barricades_Config.top[top_barricades + 1].rrotation)

        local repaired_loc = barricade.top.root:GetLocation()

        local play_sound_for_players = GetPlayersInRadius(repaired_loc, RANDOM_SOUNDS.barricade_slam.falloff_distance)
        for i, v in ipairs(play_sound_for_players) do
            Events.CallRemote("RepairBarricadeSound", v, VZ_RandomSound(RANDOM_SOUNDS.barricade_slam), repaired_loc)
        end

        ApplySMBarricadeOptions(SM_Barricade)
        table.insert(barricade.top.barricades, SM_Barricade)
    end
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

if MAP_WUNDERFIZZ then
    for k, v in pairs(MAP_WUNDERFIZZ) do
        local Wunder_SM = StaticMesh(
            v.location,
            v.rotation,
            "vzombies-assets::wunderfizz_body"
        )
        table.insert(SM_Wunderfizzes, {body = Wunder_SM})
    end
end

function ResetRunningWunderfizzStage1()
    if SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle then
        SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:Destroy()
        SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle = nil
    end

    if (Wunderfizz_Particle_Ref and Wunderfizz_Particle_Ref:IsValid()) then
        Wunderfizz_Particle_Ref:Destroy()
    end
    Wunderfizz_Particle_Ref = nil

    Timer.ClearTimeout(Wunderfizz_Bought_Timeout)
    Wunderfizz_Bought_Timeout = nil

    Timer.ClearInterval(Wunderfizz_Fake_Bottles_Interval)
    Wunderfizz_Fake_Bottles_Interval = nil
end

function ResetRunningWunderfizzStage2()
    if SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle then
        SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:Destroy()
        SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle = nil
    end

    SM_Wunderfizzes[Active_Wunderfizz_ID].body:SetValue("CanBuyWunder", true, true)

    Timer.ClearTimeout(Wunderfizz_Finished_Waiting_Timeout)
    Wunderfizz_Finished_Waiting_Timeout = nil
end

function ResetWunderfizz(id)
    SM_Wunderfizzes[id].body:SetValue("CanBuyWunder", nil, true)
    SM_Wunderfizzes[id].ball:Destroy()
    SM_Wunderfizzes[id].ball = nil

    if Wunderfizz_Bought_Timeout then
        ResetRunningWunderfizzStage1()
    elseif Wunderfizz_Finished_Waiting_Timeout then
        ResetRunningWunderfizzStage2()
    end

    Active_Wunderfizz_ID = nil
end

function ResetWunderfizzes()
    if Active_Wunderfizz_ID then
        ResetWunderfizz(Active_Wunderfizz_ID)
    end
end

function PickNewWunderfizz()
    local pick_tbl = {}
    for i, v in ipairs(SM_Wunderfizzes) do
        if not v.ball then
            table.insert(pick_tbl, i)
        end
    end

    if table_count(pick_tbl) > 0 then -- If theres more than 1 wunder on the map
        local random_pick_id = math.random(table_count(pick_tbl))
        local random_pick = SM_Wunderfizzes[pick_tbl[random_pick_id]]

        if Active_Wunderfizz_ID then
            ResetWunderfizz(Active_Wunderfizz_ID)
        end

        random_pick.ball = StaticMesh(
            random_pick.body:GetLocation(),
            random_pick.body:GetRotation(),
            "vzombies-assets::wunderfizz_ball"
        )
        random_pick.ball:SetCollision(CollisionType.NoCollision)
        random_pick.body:SetValue("CanBuyWunder", true, true)

        Active_Wunderfizz_ID = pick_tbl[random_pick_id]
    end
end

function FakeBottleInterval()
    if SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle then
        SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:Destroy()
    end
    local random_pick_id = math.random(table_count(PERKS_CONFIG))
    local random_pick
    local count = 0
    for k, v in pairs(PERKS_CONFIG) do
        count = count + 1
        if random_pick_id == count then
            random_pick = v
            break
        end
    end
    SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle = StaticMesh(
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset,
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetRotation(),
        random_pick.bottle_asset
    )
    SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:SetCollision(CollisionType.NoCollision)
    SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:SetScale(Vector(0.01, 0.01, 0.01))
end

function OpenActiveWunderfizz(char)
    SM_Wunderfizzes[Active_Wunderfizz_ID].body:SetValue("CanBuyWunder", false, true)

    Wunderfizz_Particle_Ref = Particle(
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Particle_Offset,
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetRotation(),
        Wonderfizz_Particle,
        false,
        true -- Auto Activate?
    )

    Wunderfizz_Bought_Timeout = Timer.SetTimeout(function()
        ResetRunningWunderfizzStage1()

        local random_move = math.random(100)
        if (random_move <= Wonderfizz_Move_Percentage and table_count(SM_Wunderfizzes) > 1) then
            local players_sound = GetPlayersInRadius(SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset, Wunderfizz_leave_Sound.falloff_distance)
            for k, v in pairs(players_sound) do
                Events.CallRemote("PlayWunderLeaveSound", v, SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset)
            end

            PickNewWunderfizz()
        else
            local pick_tbl = {}
            local char_perks = char:GetValue("OwnedPerks")

            for k, v in pairs(PERKS_CONFIG) do
                if not char_perks[k] then
                    table.insert(pick_tbl, k)
                end
            end

            if table_count(pick_tbl) > 0 then
                local perk_selected = pick_tbl[math.random(table_count(pick_tbl))]
                
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle = Prop(
                    SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset,
                    SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetRotation(),
                    PERKS_CONFIG[perk_selected].bottle_asset
                )
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetCollision(CollisionType.NoCollision)
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetScale(Vector(0.01, 0.01, 0.01))
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetGravityEnabled(false)
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetGrabbable(false)
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetValue("RealBottleData", {char:GetID(), perk_selected}, true)

                Wunderfizz_Finished_Waiting_Timeout = Timer.SetTimeout(function()
                    ResetRunningWunderfizzStage2()
                end, Wonderfizz_Real_Bottle_Destroyed_After_ms)
            end
        end
    end, Wonderfizz_Real_Bottle_After_ms)

    Wunderfizz_Fake_Bottles_Interval = Timer.SetInterval(function()
        FakeBottleInterval()
    end, Wonderfizz_Fake_Bottle_Interval_ms)
    FakeBottleInterval()
end

VZ_EVENT_SUBSCRIBE("Events", "TakeWunderfizzPerk", function(ply, bottle)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                if bottle then
                    if bottle:IsValid() then
                        local wunder_bottle = bottle:GetValue("RealBottleData")
                        if wunder_bottle then
                            if wunder_bottle[1] == char:GetID() then
                                local char_perks = char:GetValue("OwnedPerks")
                                if not char_perks[wunder_bottle[2]] then
                                    ResetRunningWunderfizzStage2()

                                    GiveCharacterPerk(char, wunder_bottle[2])
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

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
            --print(i, v.price)
            local teleporter = StaticMesh(
                v.location,
                Rotator(0, 0, 0),
                "nanos-world::SM_None"
            )
            teleporter:SetCollision(CollisionType.NoCollision)
            teleporter:SetValue("TeleporterID", i, true)
            teleporter:SetValue("CanTeleport", true, true)
        end
    end
end

if MAP_LIGHT_ZONES then
    for i, v in ipairs(MAP_LIGHT_ZONES) do
        local trigger = Trigger(v.location, v.rotation, v.scale * 31.5, TriggerType.Box, ZDEV_IsModeEnabled("ZDEV_DEBUG_TRIGGERS"), Color.RED)

        VZ_ENT_EVENT_SUBSCRIBE(trigger, "BeginOverlap", function(self, triggered_by)
            if NanosUtils.IsA(triggered_by, Character) then
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
            if NanosUtils.IsA(triggered_by, Character) then
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
                                if NanosUtils.IsA(picked_thing, Weapon) then
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