


function Buy(ply, price)
    local pmoney = ply:GetValue("ZMoney")
    if (pmoney and pmoney >= price) then
        ply:SetValue("ZMoney", pmoney - price, true)
        return true
    end
end

function AddMoney(ply, added)
    local pmoney = ply:GetValue("ZMoney")
    if pmoney then
        if ACTIVE_POWERUPS.x2 then
            added = added * 2
        end
        ply:SetValue("ZMoney", pmoney + added, true)
        return true
    end
end

Weapon.Subscribe("Interact", function(weapon, char)
    if weapon:IsValid() then
        local m_weap_id = weapon:GetValue("MapWeaponID")
        if m_weap_id then
            local ply = char:GetPlayer()
            if ply then
                if not char:GetValue("PlayerDown") then
                    local price = MAP_WEAPONS[m_weap_id].price
                    local ammo_id = false

                    local charInvID = GetCharacterInventory(char)
                    if charInvID then
                        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                            if v.weapon_name == MAP_WEAPONS[m_weap_id].weapon_name then
                                if not v.pap then
                                    price = math.floor(MAP_WEAPONS[m_weap_id].price * Weapons_Ammo_Price_Percentage / 100)
                                else
                                    price = Pack_a_punch_price
                                end
                                ammo_id = i
                                break
                            end
                        end
                    end

                    if Buy(ply, price) then
                        if not ammo_id then
                            AddCharacterWeapon(char, MAP_WEAPONS[m_weap_id].weapon_name, MAP_WEAPONS[m_weap_id].max_ammo, true)
                        else
                            PlayersCharactersWeapons[charInvID].weapons[ammo_id].ammo_bag = MAP_WEAPONS[m_weap_id].max_ammo
                            if PlayersCharactersWeapons[charInvID].weapons[ammo_id].weapon then
                                PlayersCharactersWeapons[charInvID].weapons[ammo_id].weapon:SetAmmoBag(MAP_WEAPONS[m_weap_id].max_ammo)
                                Events.CallRemote("UpdateAmmoText", ply)
                            end
                        end
                    end
                end
            end
            return false
        end
    end
end)

Events.Subscribe("BuyDoor", function(ply, door_id)
    --print("BuyDoor", ply, door_id)
    local map_door = GetMapDoorFromID(door_id)
    if map_door then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                local required_rooms_good = true
                for i, v in ipairs(MAP_DOORS[door_id].required_rooms) do
                    if not ROOMS_UNLOCKED[v] then
                        required_rooms_good = false
                        break
                    end
                end

                if required_rooms_good then
                    if Buy(ply, MAP_DOORS[door_id].price) then
                        map_door:Destroy()
                        for i, v in ipairs(MAP_DOORS[door_id].between_rooms) do
                            UnlockRoom(v)
                        end
                    end
                end
            end
        end
    end
end)

Events.Subscribe("BuyMBOX", function(ply, mbox)
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

Events.Subscribe("BuyPerk", function(ply, perk_sm)
    if (perk_sm and perk_sm:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                local perk_name = perk_sm:GetValue("MapPerk")
                if perk_name then
                    local char_perks = char:GetValue("OwnedPerks")
                    if not char_perks[perk_name] then
                        if Buy(ply, PERKS_CONFIG[perk_name].price) then
                            char_perks[perk_name] = true
                            char:SetValue("OwnedPerks", char_perks, true)
                            if perk_name == "juggernog" then
                                ClearRegenTimeouts(char)
                                char:SetHealth(1000 + PERKS_CONFIG.juggernog.PlayerHealth)
                                Events.CallRemote("UpdateGUIHealth", ply)
                            end
                        end
                    end
                end
            end
        end
    end
end)

PAP_Upgrade_Data = nil

function ResetPAP()
    if MAP_PAP_SM then
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

Events.Subscribe("UpgradeWeap", function(ply, pap_sm)
    if POWER_ON then
        if (pap_sm and pap_sm:IsValid()) then
            if pap_sm:GetValue("CanBuyPackAPunch") then
                local char = ply:GetControlledCharacter()
                if char then
                    if not char:GetValue("PlayerDown") then
                        local charInvID = GetCharacterInventory(char)
                        if charInvID then
                            local Inv = PlayersCharactersWeapons[charInvID]
                            if Inv.selected_slot then

                                local selected_weap
                                for i, v in ipairs(Inv.weapons) do
                                    if (v.slot == Inv.selected_slot and v.weapon) then
                                        if v.weapon:IsValid() then
                                            if not v.pap then
                                                selected_weap = v.weapon_name
                                            end
                                        end
                                        break
                                    end
                                end

                                if selected_weap then
                                    if Buy(ply, Pack_a_punch_price) then
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
                                            PAP_Upgrade_Data.upgraded_weapon:SetValue("PAPWeaponForCharacterID", {char:GetID(), selected_weap}, false)

                                            Events.BroadcastRemote("PAPReadySound")
                                            PAP_Upgrade_Data.del_timeout = Timer.SetTimeout(function()
                                                PAP_Upgrade_Data.upgraded_weapon:Destroy()
                                                PAP_Upgrade_Data = nil
                                                MAP_PAP_SM:SetValue("CanBuyPackAPunch", true, true)
                                            end, Pack_a_punch_destroy_weapon_time_ms)

                                        end, Pack_a_punch_upgrade_time_ms)

                                        Events.BroadcastRemote("PAPUpgradeSound")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)