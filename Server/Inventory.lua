

PlayersCharactersWeapons = {}


function GetCharacterInventory(char)
    for i, v in ipairs(PlayersCharactersWeapons) do
        if v.char == char then
            return i
        end
    end
    return false
end

function GetPlayerInventoryTable(ply)
    local char = ply:GetControlledCharacter()
    if char then
        for i, v in ipairs(PlayersCharactersWeapons) do
            if v.char == char then
                return v
            end
        end
    end
end

function GenerateWeaponToInsert(weapon_name, ammo_bag, slot, ammo_clip, pap, pap_repack_effect)
    return {
        ammo_bag = ammo_bag,
        ammo_clip = ammo_clip,
        weapon_name = weapon_name,
        slot = slot,
        pap = pap,
        pap_repack_effect = pap_repack_effect,
    }
end

function GetWeaponNameMaxAmmo(weapon_name)
    if Player_Start_Weapon.weapon_name == weapon_name then
        return Player_Start_Weapon.ammo
    end
    for i, v in ipairs(MAP_WEAPONS) do
        if v.weapon_name == weapon_name then
            return v.max_ammo
        end
    end
    for i, v in ipairs(Mystery_box_weapons) do
        if v.weapon_name == weapon_name then
            return v.max_ammo
        end
    end
    return 10666
end

function GetInsertSlot(char, Inv)
    local has_three_gun = char:GetValue("OwnedPerks").three_gun
    if (Inv.weapons[1] and not has_three_gun) then
        if Inv.weapons[1].slot == 1 then
            return 2
        elseif Inv.weapons[1].slot == 2 then
            return 1
        end
    elseif has_three_gun then
        local empty_slots = {
            [1] = true,
            [2] = true,
            [3] = true,
        }
        for k, v in pairs(Inv.weapons) do
            empty_slots[v.slot] = false
        end
        for k, v in pairs(empty_slots) do
            if v then
                return tonumber(k)
            end
        end
    end
    return Inv.selected_slot
end

local function CreateWeaponToGiveToPlayer(char, charInvID, i, v, loc, rot)
    loc = loc or Vector()
    rot = rot or Rotator()
    local weapon = NanosWorldWeapons[v.weapon_name](loc, rot)
    weapon:SetValue("WeaponName", v.weapon_name, true)
    weapon:SetAmmoBag(v.ammo_bag)
    if v.ammo_clip then
        weapon:SetAmmoClip(v.ammo_clip)
    else
        PlayersCharactersWeapons[charInvID].weapons[i].ammo_clip = weapon:GetAmmoClip()
    end
    --print("b", PlayersCharactersWeapons[charInvID].weapons[i])
    --print("holding", char:GetPicked())
    if v.pap then
        weapon:SetMaterial(Pack_a_punch_weapon_material, Pack_a_punch_weapon_material_index)
    end

    if v.pap_repack_effect then
        weapon:SetValue("PAPRepackEffect", v.pap_repack_effect, true)
    end

    local has_speed_cola = char:GetValue("OwnedPerks").speed_cola
    if has_speed_cola then
        weapon:ActivateSpeedReload(true)
    end

    return weapon
end

local function GiveInventoryPlayerWeapon(char, charInvID, i, v)
    --print("GiveInventoryPlayerWeapon", char, charInvID, i, NanosUtils.Dump(v))
    local weapon = CreateWeaponToGiveToPlayer(char, charInvID, i, v)

    local ply = char:GetPlayer()
    if ply then
        if ply.BOT then
            weapon:SetValue("RealRecoil", weapon:GetRecoil(), false)
            weapon:SetValue("RealSpread", weapon:GetSpread(), false)
            -- Remove for bots, consider calculated inaccuracy instead
            weapon:SetRecoil(0)
            weapon:SetSpread(0)
        end
    end

    char:PickUp(weapon)

    if ply then
        if not ply.BOT then
            if ply:GetValue("AimLocked") then
                char:SetWeaponAimMode(AimMode.ZoomedFar)
            end
        end
    end

    local FLZones = char:GetValue("InFlashlightZones")
    if table_count(FLZones) > 0 then
        AttachFlashLightToCurWeapon(char)
    end

    --print("a", PlayersCharactersWeapons[charInvID].weapons[i])
    PlayersCharactersWeapons[charInvID].weapons[i].weapon = weapon
end

function EquipSlot(char, slot)
    --print("EquipSlot", char:GetID(), slot)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        local Inv = PlayersCharactersWeapons[charInvID]
        --print(NanosUtils.Dump(Inv.weapons))
        local picked_thing = char:GetPicked()
        if (not picked_thing or (not picked_thing:IsA(Grenade) and not picked_thing:IsA(Melee))) then
            if slot ~= Inv.selected_slot then
                local found_weapon_slot = false

                for i, v in ipairs(Inv.weapons) do
                    if (v.slot == Inv.selected_slot and v.weapon) then
                        if v.weapon:IsValid() then
                            v.ammo_bag = v.weapon:GetAmmoBag()
                            v.ammo_clip = v.weapon:GetAmmoClip()

                            --print("Before:", v, PlayersCharactersWeapons[charInvID].weapons[i])
                            v.destroying = true
                            v.weapon:Destroy()
                            --print("holding WEAPON DESTROYED", char:GetPicked())
                            --print("After:", v, PlayersCharactersWeapons[charInvID].weapons[i])
                        end
                        v.weapon = nil
                        v.destroying = nil
                        found_weapon_slot = true
                        break
                    end
                end
                if not found_weapon_slot then
                    if (picked_thing and picked_thing:IsValid()) then
                        char:Drop()
                    end
                end
                for i, v in ipairs(Inv.weapons) do
                    if v.slot == slot then
                        GiveInventoryPlayerWeapon(char, charInvID, i, v)
                        break
                    end
                end
                Inv.selected_slot = slot
            else
                local weapon_given = false

                for i, v in ipairs(Inv.weapons) do
                    if (v.slot == Inv.selected_slot) then
                        if not v.weapon then
                            GiveInventoryPlayerWeapon(char, charInvID, i, v)
                            weapon_given = true
                            break
                        elseif v.weapon:IsValid() then
                            v.ammo_bag = v.weapon:GetAmmoBag()
                            v.ammo_clip = v.weapon:GetAmmoClip()
                            v.destroying = true
                            v.weapon:Destroy()
                            v.destroying = nil

                            GiveInventoryPlayerWeapon(char, charInvID, i, v)
                            weapon_given = true
                            break
                        end
                    end
                end
                if not weapon_given then
                    if (picked_thing and picked_thing:IsValid()) then
                        char:Drop()
                    end
                end
            end
            Events.Call("VZ_EquippedInventorySlot", char, slot)
        else
            Inv.selected_slot = slot
            --print("EquipSlot Locked Because He has Grenade")
        end
    end
end

function DropSlot(charInvID, char, i, v)
    if v.weapon then
        --print("bef char:Drop()")
        --print("Dropping Weapon Because Slots Full", char:GetPicked())
        if not v.just_dropped then
            if char:GetPicked() then
                v.Dropping = true
                char:Drop()
                v.Dropping = nil
            else
                table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
            end
        else
            table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
        end
        --print("Dropped ? ", char:GetPicked())
        --print("after char:Drop()")
    else

        -- Fix holding other weapon not in inv when buying weapon (knife, grenade, death_machine, ...)
        --[[local picked = char:GetPicked()
        if picked then
            picked:Destroy()
        end]]--

        local weapon = CreateWeaponToGiveToPlayer(char, charInvID, i, v, char:GetLocation(), char:GetRotation())
        WeaponDropLogic(v, weapon)

        table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
    end
end

function AddCharacterWeapon(char, weapon_name, ammo_bag, equip, ammo_clip, pap, pap_repack_effect)
    --print("AddCharacterWeapon", char, weapon_name, ammo_bag, equip, ammo_clip, char:GetPicked())
    local charInvID = GetCharacterInventory(char)
    local insert_sl = 1
    if charInvID then
        --print(NanosUtils.Dump(PlayersCharactersWeapons[charInvID].weapons))

        -- If the player already have this weapon, drop the current one
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if v.weapon_name == weapon_name then
                DropSlot(charInvID, char, i, v)
                break
            end
        end


        local inv_w_count = table_count(PlayersCharactersWeapons[charInvID].weapons)
        --print("inv_w_count", inv_w_count)

        -- If the player slots are full, drop the weapon in the selected slot
        local has_three_gun = char:GetValue("OwnedPerks").three_gun
        if ((inv_w_count >= 2 and not has_three_gun) or (inv_w_count >= 3 and has_three_gun)) then
            for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                if v.slot == PlayersCharactersWeapons[charInvID].selected_slot then
                    DropSlot(charInvID, char, i, v)
                    break
                end
            end
        else
            for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                if v.slot == PlayersCharactersWeapons[charInvID].selected_slot then
                    if v.weapon then
                        v.just_dropped = nil
                    end
                    break
                end
            end
        end

        insert_sl = GetInsertSlot(char, PlayersCharactersWeapons[charInvID])
        --print("GetInsertSlot", insert_sl)

        table.insert(PlayersCharactersWeapons[charInvID].weapons, GenerateWeaponToInsert(weapon_name, ammo_bag, insert_sl, ammo_clip, pap, pap_repack_effect))
        if equip then
            EquipSlot(char, insert_sl)
        else
            EquipSlot(char, PlayersCharactersWeapons[charInvID].selected_slot)
        end

        --print(NanosTable.Dump(PlayersCharactersWeapons[charInvID]))
    else
        table.insert(PlayersCharactersWeapons, {
            char = char,
            selected_slot = insert_sl,
            weapons = {
                GenerateWeaponToInsert(weapon_name, ammo_bag, insert_sl, ammo_clip, pap, pap_repack_effect),
            },
        })
        EquipSlot(char, insert_sl)
    end
end

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if (v.weapon and v.weapon:IsValid()) then
                v.destroying = true
                v.weapon:Destroy()
            end
        end
        table.remove(PlayersCharactersWeapons, charInvID)
    end
end)

function WeaponDropLogic(v, weapon)
    DetachFlashLightFromWeapon(weapon)
    weapon:SetValue("DroppedWeaponName", v.weapon_name, false)
    weapon:SetValue("DroppedWeaponPAP", {v.pap, v.pap_repack_effect}, false)
    weapon:SetValue("DroppedWeaponDTimeout", Timer.SetTimeout(function()
        if weapon:IsValid() then
            weapon:Destroy()
        end
    end, Weapons_Dropped_Destroyed_After_ms), false)
end

VZ_EVENT_SUBSCRIBE("Weapon", "Drop", function(weapon, char, was_triggered_by_player)
    --print("Drop", weapon, char, was_triggered_by_player, weapon:GetMesh())


    -- Repair bot weapons before dropping
    if weapon:GetValue("RealRecoil") then
        weapon:SetRecoil(weapon:GetValue("RealRecoil"))
    end

    if weapon:GetValue("RealSpread") then
        weapon:SetSpread(weapon:GetValue("RealSpread"))
    end

    local charInvID = GetCharacterInventory(char)
    if charInvID then
        --print(NanosUtils.Dump(PlayersCharactersWeapons[charInvID]))
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if (v.weapon and v.weapon == weapon) then
                if not v.destroying then
                    WeaponDropLogic(v, weapon)
                    --print("Drop Weapon")
                    if (was_triggered_by_player or v.Dropping) then
                        table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
                    end
                    v.just_dropped = true
                    --print("After Drop Weapon, weapon[1]", PlayersCharactersWeapons[charInvID].weapons[1])
                else
                    v.destroying = nil
                end
                break
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Weapon", "PickUp", function(weapon, char)
    local d_weap_name = weapon:GetValue("DroppedWeaponName")
    if d_weap_name then
        Timer.ClearTimeout(weapon:GetValue("DroppedWeaponDTimeout"))
        local ammo_bag = weapon:GetAmmoBag()
        local ammo_clip = weapon:GetAmmoClip()
        local pap = weapon:GetValue("DroppedWeaponPAP")
        --print("Pickup_Exec", weapon:GetValue("DroppedWeaponName"), char:GetPicked())
        weapon:Destroy()
        --print("Pickup_2", char:GetPicked())
        AddCharacterWeapon(char, d_weap_name, ammo_bag, true, ammo_clip, pap[1], pap[2])
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZ_Switch_Weapon", function(ply)
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            if not char:GetVehicle() then
                local charInvID = GetCharacterInventory(char)
                if charInvID then
                    local has_three_gun = char:GetValue("OwnedPerks").three_gun
                    if PlayersCharactersWeapons[charInvID].selected_slot == 1 then
                        EquipSlot(char, 2)
                    elseif (PlayersCharactersWeapons[charInvID].selected_slot == 2 and not has_three_gun) then
                        EquipSlot(char, 1)
                    elseif (PlayersCharactersWeapons[charInvID].selected_slot == 2 and has_three_gun) then
                        EquipSlot(char, 3)
                    elseif PlayersCharactersWeapons[charInvID].selected_slot == 3 then
                        EquipSlot(char, 1)
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PickupGrenade", function(ply)
    if ply:IsValid() then
        if not GAME_PAUSED then
            local char = ply:GetControlledCharacter()
            if char then
                if (not char:GetValue("PlayerDown") and not char:GetVehicle()) then
                    if not char:IsInRagdollMode() then
                        local grenades = char:GetValue("ZGrenadesNB")
                        if (grenades and grenades > 0) then
                            local grenade = Grenade(
                                Vector(0, 0, 0),
                                Rotator(0, 0, 0),
                                "nanos-world::SM_Grenade_G67",
                                "nanos-world::P_Grenade_Special",
                                "nanos-world::A_Explosion_Large",
                                CollisionType.IgnoreOnlyPawn
                            )
                            grenade:SetDamage(table.unpack(Grenade_Damage_Config))
                            grenade:SetTimeToExplode(Grenade_TimeToExplode)
                            grenade:SetValue("GrenadeOwner", char:GetID(), false)

                            local charInvID = GetCharacterInventory(char)
                            if charInvID then
                                local Inv = PlayersCharactersWeapons[charInvID]

                                for i, v in ipairs(Inv.weapons) do
                                    if (v.slot == Inv.selected_slot and v.weapon) then
                                        if v.weapon:IsValid() then
                                            v.ammo_bag = v.weapon:GetAmmoBag()
                                            v.ammo_clip = v.weapon:GetAmmoClip()

                                            v.destroying = true
                                            v.weapon:Destroy()
                                        end
                                        v.weapon = nil
                                        v.destroying = nil
                                        break
                                    end
                                end
                            end

                            char:PickUp(grenade)

                            char:SetCanDrop(false)

                            grenade:PullUse()
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Grenade", "Throw", function(grenade)
    if not grenade:GetValue("GibData") then
        local char_id = grenade:GetValue("GrenadeOwner")
        if char_id then
            local char = GetCharacterFromId(char_id)
            if char then
                if (not char:GetValue("PlayerDown") and not GAME_PAUSED) then
                    if not char:GetPlayer():GetValue("MM_InfGrenades") then
                        char:SetValue("ZGrenadesNB", char:GetValue("ZGrenadesNB") - 1, true)
                    end

                    local charInvID = GetCharacterInventory(char)
                    if charInvID then
                        local Inv = PlayersCharactersWeapons[charInvID]

                        EquipSlot(char, Inv.selected_slot)
                    end
                else
                    grenade:Destroy()
                end
            end
        end
    else
        -- Destroy unused because grenade explode, could be uncommented if it's broken somehow
        --[[Timer.SetTimeout(function()
            if grenade:IsValid() then
                grenade:Destroy()
            end
        end, Enemies_Gibs_Destroy_Timeout_ms)]]--

        local char_id = grenade:GetValue("GrenadeOwner")
        if char_id then
            local char = GetCharacterFromId(char_id)
            if char then
                if not char:GetValue("PlayerDown") then
                    local charInvID = GetCharacterInventory(char)
                    if charInvID then
                        local Inv = PlayersCharactersWeapons[charInvID]

                        EquipSlot(char, Inv.selected_slot)
                    end
                end
            end
        end

        grenade:SetPickable(true)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("ThrowGrenade", function(ply)
    if ply:IsValid() then
        if not GAME_PAUSED then
            local char = ply:GetControlledCharacter()
            if char then
                local grenade = char:GetPicked()
                if (grenade and grenade:IsA(Grenade)) then
                    grenade:ReleaseUse()
                end
                char:SetCanDrop(true)
            end
        end
    end
end)


VZ_EVENT_SUBSCRIBE("Grenade", "Interact", function(grenade, char)
    if not grenade:GetValue("GibData") then
        return false
    else
        PickupGib(char, grenade:GetValue("GibData"))
        grenade:Destroy()
    end
end)

function DestroyMapGrenades()
    for k, v in pairs(Grenade.GetPairs()) do
        if not v:GetHandler() then
            v:Destroy()
        end
    end
end

function SpawnKnife(location, rotation)
	local melee = Melee(location or Vector(), rotation or Rotator(), "nanos-world::SM_M9", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
	melee:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Stab_Attack", 1, AnimationSlotType.UpperBody)
	melee:SetDamageSettings(0.3, 0.3)
	melee:SetCooldown(Knife_Cooldown_ms / 1000)
	melee:SetBaseDamage(Knife_Base_Damage)

	return melee
end

VZ_EVENT_SUBSCRIBE_REMOTE("UseKnife", function(ply)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if char then
            if (not char:GetValue("PlayerDown") and not char:GetVehicle()) then
                if char:GetValue("CanUseKnife") then

                    local charInvID = GetCharacterInventory(char)
                    if charInvID then
                        local Inv = PlayersCharactersWeapons[charInvID]

                        for i, v in ipairs(Inv.weapons) do
                            if (v.slot == Inv.selected_slot and v.weapon) then
                                if v.weapon:IsValid() then
                                    v.ammo_bag = v.weapon:GetAmmoBag()
                                    v.ammo_clip = v.weapon:GetAmmoClip()

                                    v.destroying = true
                                    v.weapon:Destroy()
                                end
                                v.weapon = nil
                                v.destroying = nil
                                break
                            end
                        end
                    end

                    local knife = SpawnKnife()

                    char:SetCanDrop(false)
                    char:PickUp(knife)

                    knife:PullUse()

                    char:SetValue("CanUseKnife", false, true)

                    Timer.SetTimeout(function()
                        if knife:IsValid() then
                            if char:IsValid() then
                                knife:Destroy()

                                local charInvID = GetCharacterInventory(char)
                                if charInvID then
                                    local Inv = PlayersCharactersWeapons[charInvID]

                                    EquipSlot(char, Inv.selected_slot)
                                end
                            end
                        end
                        char:SetCanDrop(true)
                    end, Knife_Switch_ms)

                    Timer.SetTimeout(function()
                        if char:IsValid() then
                            char:SetValue("CanUseKnife", true, true)
                        end
                    end, Knife_Cooldown_ms)
                end
            end
        end
    end
end)

function AttachFlashLightToCurWeapon(char)
    local picked_thing = char:GetPicked()
    if picked_thing then
        if picked_thing:IsA(Weapon) then
            local flashlight = Light(
                Vector(0, 0, 0),
                Rotator(0, 0, 0),
                Color(1, 1, 1),
                LightType.Spot,
                table.unpack(FLight_Config)
            )
            flashlight:AttachTo(picked_thing, AttachmentRule.SnapToTarget, "muzzle", 0)
            flashlight:SetTextureLightProfile(FLight_Profile)
            picked_thing:SetValue("FlashLightID", flashlight:GetID(), false)
        end
    end
end

function DetachFlashLightFromWeapon(weapon)
    local FLID = weapon:GetValue("FlashLightID")
    if FLID then
        for k2, v2 in pairs(Light.GetPairs()) do
            if v2:GetID() == FLID then
                v2:Destroy()
                weapon:SetValue("FlashLightID", nil, false)
                break
            end
        end
    end
end

VZ_EVENT_SUBSCRIBE("Character", "WeaponAimModeChange", function(char, old_state, new_state)
    --print("WeaponAimModeChange", new_state)
    local ply = char:GetPlayer()
    if ply then
        if not ply.BOT then
            if ply:GetValue("AimLocked") then
                if new_state == AimMode.None then
                    if (not char:GetValue("PlayerDown") and not char:GetVehicle()) then
                        char:SetWeaponAimMode(AimMode.ZoomedFar)
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("ToggleLockAim", function(ply)
    local char = ply:GetControlledCharacter()
    if char then
        if (not char:GetVehicle() and not char:GetValue("PlayerDown")) then
            ply:SetValue("AimLocked", not ply:GetValue("AimLocked"), false)
            if ply:GetValue("AimLocked") then
                if char:GetWeaponAimMode() == AimMode.None then
                    char:SetWeaponAimMode(AimMode.ZoomedFar)
                end
            end
        end
    end
end)

function PickupGib(char, gib_data)
    if gib_data then
        if (not char:GetValue("PlayerDown") and not char:GetVehicle()) then
            if not char:IsInRagdollMode() then
                local enemy_table = Enemies_Config[gib_data[1]]
                if enemy_table then
                    if Enemies_Config[gib_data[1]].Gibs then
                        if Enemies_Config[gib_data[1]].Gibs[gib_data[2]] then
                            local gib_grenade = Grenade(
                                Vector(0, 0, 0),
                                Rotator(0, 0, 0),
                                gib_data[4],
                                "",
                                "",
                                CollisionType.IgnoreOnlyPawn
                            )
                            gib_grenade:SetValue("GibData", gib_data, false)
                            gib_grenade:SetValue("GrenadeOwner", char:GetID(), false)
                            gib_grenade:SetDamage(0, 0, 0, 0, 0)
                            gib_grenade:SetTimeToExplode(Enemies_Gibs_Destroy_Timeout_ms / 1000)

                            if gib_data[3] then
                                SetGibMaterials(gib_grenade, gib_data[2], enemy_table, gib_data[3])
                            end

                            if gib_data[2] == enemy_table.Gibs_heart_bone then
                                gib_grenade:SetMaterialScalarParameter("Emissive_value", 0.0)
                            end

                            local charInvID = GetCharacterInventory(char)
                            if charInvID then
                                local Inv = PlayersCharactersWeapons[charInvID]

                                for i, v in ipairs(Inv.weapons) do
                                    if (v.slot == Inv.selected_slot and v.weapon) then
                                        if v.weapon:IsValid() then
                                            v.ammo_bag = v.weapon:GetAmmoBag()
                                            v.ammo_clip = v.weapon:GetAmmoClip()

                                            v.destroying = true
                                            v.weapon:Destroy()
                                        end
                                        v.weapon = nil
                                        v.destroying = nil
                                        break
                                    end
                                end
                            end

                            char:PickUp(gib_grenade)
                        end
                    end
                end
            end
        end
    end
end

VZ_EVENT_SUBSCRIBE_REMOTE("PickupGib", function(ply, gib_data)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if char then
            PickupGib(char, gib_data)
        end
    end
end)