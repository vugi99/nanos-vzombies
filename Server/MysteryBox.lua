


SM_MysteryBoxes = {}
Active_MysteryBox_ID = nil
OpenedMysteryBox_Data = nil


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

                Events.BroadcastRemote("PlayVZSound", {basic_sound_tbl=Mbox_Changed_Sound})
            end
        end, Mystery_box_weapon_time * 1000),
    }
    OpenedMBoxNewFakeWeapon()
    Events.BroadcastRemote("OpenMBOXSound", SM_MysteryBoxes[Active_MysteryBox_ID].mbox:GetLocation())
end

VZ_EVENT_SUBSCRIBE_REMOTE("BuyMBOX", function(ply, mbox)
    if (mbox and mbox:IsValid()) then
        local mbox_can_buy = mbox:GetValue("CanBuyMysteryBox")
        if mbox_can_buy then
            if Active_MysteryBox_ID then
                local char = ply:GetControlledCharacter()
                if char then
                    if not char:GetValue("PlayerDown") then
                        if Buy(ply, Mystery_box_price) then
                            OpenActiveMysteryBox(char)
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Weapon", "Interact", function(weapon, char)
    if (weapon and weapon:IsValid()) then
        local mbox_fake_weapon = weapon:GetValue("MBOXFakeWeapon")
        if mbox_fake_weapon then
            return false
        end
        local mbox_real_weapon_for_char = weapon:GetValue("MBOXFinalWeaponForCharacterID")
        if mbox_real_weapon_for_char then
            if mbox_real_weapon_for_char[1] == char:GetID() then
                AddCharacterWeapon(char, mbox_real_weapon_for_char[2].weapon_name, mbox_real_weapon_for_char[2].max_ammo, true)
                OpenedMBOXResetStage2()
                OpenedMysteryBox_Data = nil
                SM_MysteryBoxes[Active_MysteryBox_ID].mbox:SetValue("CanBuyMysteryBox", true, true)
            end
            return false
        end
    end
end)