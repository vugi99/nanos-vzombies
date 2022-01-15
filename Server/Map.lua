

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

if MAP_PACK_A_PUNCH then
    local SM = StaticMesh(
        MAP_PACK_A_PUNCH.location,
        MAP_PACK_A_PUNCH.rotation,
        "vzombies-assets::pack_a_punch"
    )
    SM:SetScale(Vector(0.01, 0.01, 0.01))
    SM:SetValue("CanBuyPackAPunch", true, true)

    MAP_PAP_SM = SM
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
        MAP_POWER.location + Vector(0, 19, 117),
        MAP_POWER.rotation + Rotator(0, 0, 90),
        "vzombies-assets::power_handle"
    )
    SM_Handle:SetScale(Vector(0.01, 0.01, 0.01))
    SM_Handle:SetCollision(CollisionType.NoCollision)
    SM_Handle:SetValue("MapPowerHANDLE", true, true)

    MAP_POWER_SM_HANDLE = SM_Handle
end

function ResetMapPower()
    if MAP_POWER then
        POWER_ON = false
        Events.BroadcastRemote("SetClientPowerON", false)
        MAP_POWER_SM_HANDLE:SetRotation(MAP_POWER.rotation + Rotator(0, 0, 90))
    end
end

Events.Subscribe("TurnPowerON", function(ply, power_sm)
    if not POWER_ON then
        if power_sm:IsValid() then
            if ply:GetValue("ZMoney") ~= -666 then -- Means that they shouldn't do anything
                local char = ply:GetControlledCharacter()
                if char then
                    if not char:GetValue("PlayerDown") then
                        POWER_ON = true
                        ROOMS_UNLOCKED[-1] = true
                        MAP_POWER_SM_HANDLE:RotateTo(MAP_POWER.rotation, 1, false)
                        Events.BroadcastRemote("PowerONSound")
                    end
                end
            end
        end
    end
end)

if MAP_PERKS then
    for k, v in pairs(MAP_PERKS) do
        local SM = StaticMesh(
            v.location,
            v.rotation,
            PERKS_CONFIG[k].Asset
        )
        SM:SetScale(PERKS_CONFIG[k].scale)
        SM:SetValue("MapPerk", k, true)
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

function OpenedMBOXResetStage1()
    Timer.ClearInterval(OpenedMysteryBox_Data.CheckTranslateToInterval)
    Timer.ClearInterval(OpenedMysteryBox_Data.FakeInterval)
    OpenedMysteryBox_Data.CheckTranslateToInterval = nil
    OpenedMysteryBox_Data.FakeInterval = nil
    if OpenedMysteryBox_Data.fweap then
        OpenedMysteryBox_Data.fweap:Destroy()
        OpenedMysteryBox_Data.fweap = nil
    end
end

function OpenedMBOXResetStage2()
    Timer.ClearInterval(OpenedMysteryBox_Data.CheckTranslateToInterval)
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

    local random_pick_id = math.random(table_count(pick_tbl))
    local random_pick = SM_MysteryBoxes[pick_tbl[random_pick_id]]

    if Active_MysteryBox_ID then
        ResetMBOX(Active_MysteryBox_ID)
    end

    random_pick.bear:Destroy()
    random_pick.bear = nil
    random_pick.mbox:SetValue("CanBuyMysteryBox", true, true)

    Active_MysteryBox_ID = pick_tbl[random_pick_id]
end

function OpenedMBoxNewFakeWeapon()
    if OpenedMysteryBox_Data.fweap then
        OpenedMysteryBox_Data.fweap:Destroy()
    end
    local random_weap = Mystery_box_weapons[math.random(table_count(Mystery_box_weapons))]
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
    SM:TranslateTo(targetTranslateTo, Mystery_box_weapon_speed, false, false)
    OpenedMysteryBox_Data = {
        SM_Attach = SM,
        FakeInterval = Timer.SetInterval(function()
            OpenedMBoxNewFakeWeapon()
        end, Mystery_box_fake_weapon_interval_ms),
        CheckTranslateToInterval = Timer.SetInterval(function()
            if OpenedMysteryBox_Data.SM_Attach:GetLocation():DistanceSquared(targetTranslateTo) <= 4 then
                OpenedMBOXResetStage1()

                local mbox_weapons_count = table_count(Mystery_box_weapons)
                local random_weap_id = math.random(mbox_weapons_count + 1)
                if random_weap_id <= mbox_weapons_count then
                    if char:IsValid() then
                        local random_weap = Mystery_box_weapons[random_weap_id]
                        OpenedMysteryBox_Data.realweap = NanosWorldWeapons[random_weap.weapon_name](Vector(0, 0, 0), Rotator(0, 0, 0))
                        OpenedMysteryBox_Data.realweap:SetCollision(CollisionType.NoCollision)
                        OpenedMysteryBox_Data.realweap:SetGravityEnabled(false)
                        OpenedMysteryBox_Data.realweap:SetValue("MBOXFinalWeaponForCharacterID", {char:GetID(), random_weap}, false)
                        OpenedMysteryBox_Data.realweap:AttachTo(OpenedMysteryBox_Data.SM_Attach, AttachmentRule.SnapToTarget, "")
                        OpenedMysteryBox_Data.SM_Attach:TranslateTo(SM_MysteryBoxes[Active_MysteryBox_ID].mbox:GetLocation() + Vector(0, 0, Mystery_box_weapon_spawn_offset_z), Mystery_box_weapon_speed_reverse, false, false)

                        OpenedMysteryBox_Data.CheckTranslateToInterval = Timer.SetInterval(function()
                            if OpenedMysteryBox_Data.SM_Attach:GetLocation():DistanceSquared(SM_MysteryBoxes[Active_MysteryBox_ID].mbox:GetLocation() + Vector(0, 0, Mystery_box_weapon_spawn_offset_z)) <= 4 then
                                OpenedMBOXResetStage2()
                                OpenedMysteryBox_Data = nil

                                SM_MysteryBoxes[Active_MysteryBox_ID].mbox:SetValue("CanBuyMysteryBox", true, true)
                            end
                        end, 100)
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
            end
        end, 100),
    }
    OpenedMBoxNewFakeWeapon()
    Events.BroadcastRemote("OpenMBOXSound", SM_MysteryBoxes[Active_MysteryBox_ID].mbox:GetLocation())
end

function UnlockRoom(id)
    if not ROOMS_UNLOCKED[id] then
        ROOMS_UNLOCKED[id] = true
        for k, v in pairs(MAP_ROOMS[id]) do
            table.insert(SPAWNS_UNLOCKED, v)
        end
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

    local SM_Root_Ground = StaticMesh(
        zspawn.z_ground_debris_location,
        Rotator(0, 0, 0),
        "nanos-world::SM_None"
    )
    SM_Root_Ground:AttachTo(SM_Root, AttachmentRule.KeepWorld, "")
    SM_Root_Ground:SetRelativeRotation(Barricades_Config.ground_root.rrotation)

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

        local zombie_loc = zombie:GetLocation()
        local play_sound_for_players = GetPlayersInRadius(destroyed_loc, RANDOM_SOUNDS.barricade_slam.falloff_distance)
        for i, v in ipairs(play_sound_for_players) do
            Events.CallRemote("DamageBarricadeSound", v, VZ_RandomSound(RANDOM_SOUNDS.barricade_slam), VZ_RandomSound(RANDOM_SOUNDS.zombie_attack), destroyed_loc, zombie_loc)
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

        ApplySMBarricadeOptions(SM_Barricade)
        table.insert(barricade.top.barricades, SM_Barricade)
    end
end

function SpawnMapBarricades()
    for i, v in ipairs(MAP_ROOMS) do
        for k2, v2 in pairs(v) do
            SpawnBarricade(MAP_ROOMS[i][k2], v2.zspawnid)
        end
    end
end

local id = 1
for i, v in ipairs(MAP_ROOMS) do
    for k2, v2 in pairs(v) do
        MAP_ROOMS[i][k2].zspawnid = id
        id = id + 1
    end
end

function GetBarricadeFromZSpawnID(zspawnid)
    for k, v in pairs(BARRICADES) do
        if v.zspawnid == zspawnid then
            return k, v
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

Events.Subscribe("RepairBarricade", function(ply, zspawnid)
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
    local weapon = NanosWorldWeapons[v.weapon_name](v.location, v.rotation)
    weapon:SetValue("MapWeaponID", i, true)
    weapon:SetGravityEnabled(false)
    weapon:SetCollision(CollisionType.NoCollision)
end