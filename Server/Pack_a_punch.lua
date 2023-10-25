

MAP_PAP_SM = nil

PAP_Upgrade_Data = nil

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


function ResetPAP()
    if (MAP_PAP_SM and MAP_PAP_SM:IsValid()) then
        if PAP_Upgrade_Data then
            if PAP_Upgrade_Data.up_timeout then
                Timer.ClearTimeout(PAP_Upgrade_Data.up_timeout)
            elseif PAP_Upgrade_Data.del_timeout then
                Timer.ClearTimeout(PAP_Upgrade_Data.del_timeout)
                PAP_Upgrade_Data.upgraded_weapon:Destroy()
            end
        end
        PAP_Upgrade_Data = nil
        MAP_PAP_SM:SetValue("CanBuyPackAPunch", true, true)
    end
end

function UpgradeWeapon(ply, pap_sm)
    if POWER_ON then
        if (pap_sm and pap_sm:IsValid()) then
            if pap_sm:GetValue("CanBuyPackAPunch") then
                local char = ply:GetControlledCharacter()
                if char then
                    if not char:GetValue("PlayerDown") then
                        if not char:GetValue("DeathMachineTimer") then
                            local charInvID = GetCharacterInventory(char)
                            if charInvID then
                                local Inv = PlayersCharactersWeapons[charInvID]
                                if Inv.selected_slot then

                                    local selected_weap
                                    local is_pap
                                    local repack_effect
                                    for i, v in ipairs(Inv.weapons) do
                                        if (v.slot == Inv.selected_slot and v.weapon) then
                                            if v.weapon:IsValid() then
                                                selected_weap = v.weapon_name
                                                is_pap = v.pap
                                                repack_effect = v.pap_repack_effect
                                            end
                                            break
                                        end
                                    end

                                    if selected_weap then
                                        if (not is_pap and Buy(ply, Pack_a_punch_price)) or (is_pap and Buy(ply, Pack_a_punch_repack_price)) then
                                            pap_sm:SetValue("CanBuyPackAPunch", false, true)

                                            for i, v in ipairs(Inv.weapons) do
                                                if (v.slot == Inv.selected_slot and v.weapon) then
                                                    v.destroying = true
                                                    v.weapon:Destroy()
                                                    v.weapon = nil
                                                    table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
                                                    break
                                                end
                                            end

                                            PAP_Upgrade_Data = {}
                                            PAP_Upgrade_Data.up_timeout = Timer.SetTimeout(function()
                                                PAP_Upgrade_Data.up_timeout = nil

                                                PAP_Upgrade_Data.upgraded_weapon = NanosWorldWeapons[selected_weap](MAP_PACK_A_PUNCH.weapon_location, MAP_PACK_A_PUNCH.weapon_rotation)
                                                PAP_Upgrade_Data.upgraded_weapon:SetCollision(CollisionType.NoCollision)
                                                PAP_Upgrade_Data.upgraded_weapon:SetGravityEnabled(false)
                                                PAP_Upgrade_Data.upgraded_weapon:SetMaterial(Pack_a_punch_weapon_material, Pack_a_punch_weapon_material_index)
                                                PAP_Upgrade_Data.upgraded_weapon:SetValue("PAPWeaponForCharacterID", {char:GetID(), selected_weap, is_pap, repack_effect}, false)

                                                Events.BroadcastRemote("PlayVZSound", {basic_sound_tbl=PAP_Ready_Sound}, MAP_PACK_A_PUNCH.location)
                                                PAP_Upgrade_Data.del_timeout = Timer.SetTimeout(function()
                                                    if PAP_Upgrade_Data.upgraded_weapon:IsValid() then
                                                        PAP_Upgrade_Data.upgraded_weapon:Destroy()
                                                    end
                                                    PAP_Upgrade_Data = nil
                                                    MAP_PAP_SM:SetValue("CanBuyPackAPunch", true, true)
                                                end, Pack_a_punch_destroy_weapon_time_ms)

                                                Events.Call("VZ_PAPUpgradedWeapon")
                                            end, Pack_a_punch_upgrade_time_ms)

                                            Events.BroadcastRemote("PlayVZSound", {basic_sound_tbl=PAP_Upgrade_Sound}, MAP_PACK_A_PUNCH.location)
                                            return true
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
VZ_EVENT_SUBSCRIBE_REMOTE("UpgradeWeap", UpgradeWeapon)

function InteractPAPWeapon(weapon, char)
    if (weapon and weapon:IsValid()) then
        local pap_weapon_for_char = weapon:GetValue("PAPWeaponForCharacterID")
        if pap_weapon_for_char then
            if pap_weapon_for_char[1] == char:GetID() then
                local max_ammo = GetWeaponNameMaxAmmo(pap_weapon_for_char[2])
                if max_ammo then
                    weapon:Destroy()
                    local repack_effect
                    if pap_weapon_for_char[3] then
                        local CanSelectEffects = {}
                        for k, v in pairs(PAP_Repack_Config) do
                            if k ~= tostring(pap_weapon_for_char[4]) then
                                table.insert(CanSelectEffects, k)
                            end
                        end
                        repack_effect = CanSelectEffects[math.random(table_count(CanSelectEffects))]
                    end

                    AddCharacterWeapon(char, pap_weapon_for_char[2], max_ammo, true, nil, true, repack_effect)
                    Timer.ClearTimeout(PAP_Upgrade_Data.del_timeout)
                    PAP_Upgrade_Data = nil
                    MAP_PAP_SM:SetValue("CanBuyPackAPunch", true, true)
                else
                    Console.Error("max_ammo not found : Interact pack a punch weapon : " .. tostring(pap_weapon_for_char[2]))
                end
            end
            return false
        end
    end
end
VZ_EVENT_SUBSCRIBE("Weapon", "Interact", InteractPAPWeapon)