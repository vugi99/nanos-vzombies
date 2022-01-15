

PlayersCharactersWeapons = {}


function GetCharacterInventory(char)
    for i, v in ipairs(PlayersCharactersWeapons) do
        if v.char == char then
            return i
        end
    end
    return false
end

function GenerateWeaponToInsert(weapon_name, ammo_bag, slot, ammo_clip, pap)
    return {
        ammo_bag = ammo_bag,
        ammo_clip = ammo_clip,
        weapon_name = weapon_name,
        slot = slot,
        pap = pap,
    }
end

function GetInsertSlot(Inv)
    if Inv.weapons[1] then
        --print("GetInsertSlot", "weapons[1]")
        if Inv.weapons[1].slot == 1 then
            return 2
        elseif Inv.weapons[1].slot == 2 then
            return 1
        end
    end
    return Inv.selected_slot
end

local function GiveInventoryPlayerWeapon(char, charInvID, i, v)
    --print("GiveInventoryPlayerWeapon", char, charInvID, i, v)
    local weapon = NanosWorldWeapons[v.weapon_name](Vector(), Rotator())
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
    char:PickUp(weapon)
    --print("a", PlayersCharactersWeapons[charInvID].weapons[i])
    PlayersCharactersWeapons[charInvID].weapons[i].weapon = weapon
end

function EquipSlot(char, slot)
    --print("EquipSlot", char:GetID(), slot)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        local Inv = PlayersCharactersWeapons[charInvID]
        if slot ~= Inv.selected_slot then
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
                    break
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
            for i, v in ipairs(Inv.weapons) do
                if (v.slot == Inv.selected_slot) then
                    if not v.weapon then
                        GiveInventoryPlayerWeapon(char, charInvID, i, v)
                        break
                    elseif v.weapon:IsValid() then
                        v.ammo_bag = v.weapon:GetAmmoBag()
                        v.ammo_clip = v.weapon:GetAmmoClip()
                        v.destroying = true
                        v.weapon:Destroy()

                        GiveInventoryPlayerWeapon(char, charInvID, i, v)
                        break
                    end
                end
            end
        end
    end
end

function AddCharacterWeapon(char, weapon_name, ammo_bag, equip, ammo_clip, pap)
    --print("AddCharacterWeapon", char, weapon_name, ammo_bag, equip, ammo_clip)
    local charInvID = GetCharacterInventory(char)
    local insert_sl = 1
    if charInvID then

        -- If the player already have this weapon, don't give a new one
        local already_have = false
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if v.weapon_name == weapon_name then
                already_have = true
            end
        end
        if already_have then
            EquipSlot(char, PlayersCharactersWeapons[charInvID].selected_slot)
            return false
        end


        local inv_w_count = table_count(PlayersCharactersWeapons[charInvID].weapons)
        --print("inv_w_count", inv_w_count)

        -- If the player slots are full, drop the weapon in the selected slot
        if inv_w_count == 2 then
            for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                if v.slot == PlayersCharactersWeapons[charInvID].selected_slot then
                    if v.weapon then
                        --print("bef char:Drop()")
                        --print("Dropping Weapon Because Slots Full", char:GetPicked())
                        if not v.just_dropped then
                            v.Dropping = true
                            char:Drop()
                            v.Dropping = nil
                        else
                            table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
                        end
                        --print("Dropped ? ", char:GetPicked())
                        --print("after char:Drop()")
                    end
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

        insert_sl = GetInsertSlot(PlayersCharactersWeapons[charInvID])
        table.insert(PlayersCharactersWeapons[charInvID].weapons, GenerateWeaponToInsert(weapon_name, ammo_bag, insert_sl, ammo_clip, pap))
        if equip then
            EquipSlot(char, insert_sl)
        else
            EquipSlot(char, PlayersCharactersWeapons[charInvID].selected_slot)
        end
    else
        table.insert(PlayersCharactersWeapons, {
            char = char,
            selected_slot = insert_sl,
            weapons = {
                GenerateWeaponToInsert(weapon_name, ammo_bag, insert_sl, ammo_clip, pap),
            },
        })
        EquipSlot(char, insert_sl)
    end
end

Character.Subscribe("Destroy", function(char)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if v.weapon then
                v.destroying = true
                v.weapon:Destroy()
            end
        end
        table.remove(PlayersCharactersWeapons, charInvID)
    end
end)

Weapon.Subscribe("Drop", function(weapon, char, was_triggered_by_player)
    --print("Drop", weapon, char, was_triggered_by_player, weapon:GetAssetName())
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if (v.weapon and v.weapon == weapon) then
                if not v.destroying then
                    weapon:SetValue("DroppedWeaponName", v.weapon_name, false)
                    weapon:SetValue("DroppedWeaponPAP", v.pap, false)
                    weapon:SetValue("DroppedWeaponDTimeout", Timer.SetTimeout(function()
                        if weapon:IsValid() then
                            weapon:Destroy()
                        end
                    end, Weapons_Dropped_Destroyed_After_ms), false)
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

Weapon.Subscribe("PickUp", function(weapon, char)
    --print("PickUp Event")
    local d_weap_name = weapon:GetValue("DroppedWeaponName")
    if d_weap_name then
        Timer.ClearTimeout(weapon:GetValue("DroppedWeaponDTimeout"))
        --print("Pickup_Exec")
        local ammo_bag = weapon:GetAmmoBag()
        local ammo_clip = weapon:GetAmmoClip()
        local pap = weapon:GetValue("DroppedWeaponPAP")
        weapon:Destroy()
        AddCharacterWeapon(char, d_weap_name, ammo_bag, true, ammo_clip, pap)
    end
end)

Events.Subscribe("VZ_Switch_Weapon", function(ply)
    local char = ply:GetControlledCharacter()
    if char then
        local charInvID = GetCharacterInventory(char)
        if charInvID then
            if PlayersCharactersWeapons[charInvID].selected_slot == 1 then
                EquipSlot(char, 2)
            elseif PlayersCharactersWeapons[charInvID].selected_slot == 2 then
                EquipSlot(char, 1)
            end
        end
    end
end)

Weapon.Subscribe("Interact", function(weapon, char)
    if weapon:IsValid() then
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

Weapon.Subscribe("Interact", function(weapon, char)
    if weapon:IsValid() then
        local pap_weapon_for_char = weapon:GetValue("PAPWeaponForCharacterID")
        if pap_weapon_for_char then
            if pap_weapon_for_char[1] == char:GetID() then
                local max_ammo = GetWeaponNameMaxAmmo(pap_weapon_for_char[2])
                if max_ammo then
                    weapon:Destroy()
                    AddCharacterWeapon(char, pap_weapon_for_char[2], max_ammo, true, nil, true)
                    Timer.ClearTimeout(PAP_Upgrade_Data.del_timeout)
                    PAP_Upgrade_Data = nil
                    MAP_PAP_SM:SetValue("CanBuyPackAPunch", true, true)
                else
                    Package.Error("max_ammo not found : Interact pack a punch weapon : " .. tostring(pap_weapon_for_char[2]))
                end
            end
            return false
        end
    end
end)