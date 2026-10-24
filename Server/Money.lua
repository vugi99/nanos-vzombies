


function Buy(ply, price)
    if (price == 0) then
        return true
    end

    if ply:GetValue("MM_InfMoney") then
        return true
    end
    local pmoney = ply:GetValue("ZMoney")
    if (pmoney and pmoney >= price) then
        ply:SetValue("ZMoney", pmoney - price, true)
        return true
    else
        Events.CallRemote("AddNotification", ply, Reliability.Reliable, "Not Enough Money", 3000)
    end
end
Package.Export("Buy", Buy)

function AddMoney(ply, added, only_money)
    if (added == 0) then
        return true
    end

    local pmoney = ply:GetValue("ZMoney")
    if pmoney then
        if ACTIVE_POWERUPS.x2 then
            added = added * 2
        end
        ply:SetValue("ZMoney", pmoney + added, true)
        if (not only_money) then
            if VZ_GetFeatureValue("Levels", "script_loaded") then
                if AddPlayerXP then
                    AddPlayerXP(ply, math.floor(added*VZ_GetFeatureValue("Levels", "score_mult_into_xp")))
                end
            end
            ply:SetValue("ZScore", ply:GetValue("ZScore") + added, false)
        elseif VZ_GetFeatureValue("Levels", "script_loaded") then
            Events.CallRemote("PlayerLevelXPUpdate", ply, Reliability.Reliable, ply:GetValue("PlayerLevel"), ply:GetValue("PlayerXP")) -- Prevent xp desync
        end
        return true
    end
end
Package.Export("AddMoney", AddMoney)

function InteractMapWeapon(weapon, char)
    if ZDEV_IsModeEnabled("ZDEV_DEBUG_INTERACT") then
        print("InteractMapWeapon", weapon, char)
    end
    if weapon:IsValid() then
        local m_weap_id = weapon:GetValue("MapWeaponID")
        if m_weap_id then
            if VZ_GetFeatureValue("Map_Weapons", "can_interact") then
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
                                    Events.CallRemote("UpdateAmmoText", ply, Reliability.Reliable)
                                end
                            end
                        end
                    end
                end
            end
            return false
        end
    end
end
VZ_EVENT_SUBSCRIBE("Weapon", "Interact", InteractMapWeapon)


function BuyDoor(ply, map_door)
    --print("BuyDoor", ply, door_id)
    if type(map_door) ~= "userdata" then
        return
    end

    if IsValid(map_door) then
        local door_id = map_door:GetValue("DoorID")
        if (type(door_id) ~= "number") then return end
        if map_door:GetValue("PPG_Sabotaged") then
            return
        end

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
                        VZ_EVENT_CALL("Events", "VZ_DoorOpened", char, door_id)
                    end
                else
                    Events.CallRemote("AddNotification", ply, Reliability.Reliable, "Cannot Open The Door")
                end
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("BuyDoor", BuyDoor)