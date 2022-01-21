


function Buy(ply, price)
    local pmoney = ply:GetValue("ZMoney")
    if (pmoney and pmoney >= price) then
        ply:SetValue("ZMoney", pmoney - price, true)
        return true
    end
end
Package.Export("Buy", Buy)

function AddMoney(ply, added)
    local pmoney = ply:GetValue("ZMoney")
    if pmoney then
        if ACTIVE_POWERUPS.x2 then
            added = added * 2
        end
        ply:SetValue("ZMoney", pmoney + added, true)
        ply:SetValue("ZScore", ply:GetValue("ZScore") + added, false)
        return true
    end
end
Package.Export("AddMoney", AddMoney)

function InteractMapWeapon(weapon, char)
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
end

VZ_EVENT_SUBSCRIBE("Weapon", "Interact", InteractMapWeapon)


function BuyDoor(ply, door_id)
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
                        Events.Call("VZ_DoorOpened", char, door_id)
                    end
                end
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "BuyDoor", BuyDoor)

VZ_EVENT_SUBSCRIBE("Events", "BuyMBOX", function(ply, mbox)
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

function BuyPerk(ply, perk_sm)
    if (perk_sm and perk_sm:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                local perk_name = perk_sm:GetValue("MapPerk")
                if perk_name then
                    local char_perks = char:GetValue("OwnedPerks")
                    if not char_perks[perk_name] then
                        if Buy(ply, PERKS_CONFIG[perk_name].price) then
                            GiveCharacterPerk(char, perk_name)
                        end
                    end
                end
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "BuyPerk", BuyPerk)

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

function UpgradeWeapon(ply, pap_sm)
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

                                            Events.Call("VZ_PAPUpgradedWeapon")
                                        end, Pack_a_punch_upgrade_time_ms)

                                        Events.BroadcastRemote("PAPUpgradeSound")
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
VZ_EVENT_SUBSCRIBE("Events", "UpgradeWeap", UpgradeWeapon)

VZ_EVENT_SUBSCRIBE("Events", "BuyWunderfizz", function(ply, SM_Wunder)
    if (SM_Wunder and SM_Wunder:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                local can_buy_wunder = SM_Wunder:GetValue("CanBuyWunder")
                if can_buy_wunder then
                    if Active_Wunderfizz_ID then
                        if table_count(char:GetValue("OwnedPerks")) < table_count(PERKS_CONFIG) then
                            if Buy(ply, Wonderfizz_Price) then
                                OpenActiveWunderfizz(char)
                            end
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "BuyTeleport", function(ply, teleporter)
    if (teleporter and teleporter:IsValid()) then
        if teleporter:GetValue("CanTeleport") then
            local char = ply:GetControlledCharacter()
            if char then
                if not char:GetValue("PlayerDown") then
                    local teleporter_ID = teleporter:GetValue("TeleporterID")
                    if Buy(ply, MAP_TELEPORTERS[teleporter_ID].price) then
                        local teleport_table = {
                            ply,
                        }
                        local in_tbl = 1

                        local Destination_Spawns_Count = table_count(MAP_TELEPORTERS[teleporter_ID].teleport_to)

                        if Destination_Spawns_Count > 1 then
                            local players_in_radius = GetPlayersInRadius_ToTeleport(ply, MAP_TELEPORTERS[teleporter_ID].location, MAP_TELEPORTERS[teleporter_ID].distance_sq)
                            for k, v in pairs(players_in_radius) do
                                if in_tbl < Destination_Spawns_Count then
                                    table.insert(teleport_table, v)
                                    in_tbl = in_tbl + 1
                                end
                            end
                        elseif Destination_Spawns_Count == 0 then
                            Package.Error("vzombies : A teleporter doesn't have any destination, teleporter " .. tostring(teleporter_ID))
                            return
                        end

                        for i, v in ipairs(teleport_table) do
                            local char_to_tp = v:GetControlledCharacter()
                            char_to_tp:SetLocation(MAP_TELEPORTERS[teleporter_ID].teleport_to[i].location + Vector(0, 0, 100))
                            char_to_tp:SetRotation(MAP_TELEPORTERS[teleporter_ID].teleport_to[i].rotation)

                            Events.CallRemote("PlayerTeleportedSound", v)
                        end

                        if MAP_TELEPORTERS[teleporter_ID].teleport_back_ms > 0 then
                            local TeleportBackCount = table_count(MAP_TELEPORTERS[teleporter_ID].teleport_back)
                            if TeleportBackCount ~= Destination_Spawns_Count then
                                Package.Error("vzombies : Missing back destinations (spawns) for the teleporter " .. tostring(teleporter_ID))
                                return
                            end

                            local teleport_back_timeout = Timer.SetTimeout(function()
                                if teleporter:IsValid() then
                                    for i, v in ipairs(teleport_table) do
                                        if v:IsValid() then
                                            local char_to_tp = v:GetControlledCharacter()
                                            if char_to_tp then
                                                char_to_tp:SetLocation(MAP_TELEPORTERS[teleporter_ID].teleport_back[i].location + Vector(0, 0, 100))
                                                char_to_tp:SetRotation(MAP_TELEPORTERS[teleporter_ID].teleport_back[i].rotation)

                                                Events.CallRemote("PlayerTeleportedSound", v)
                                            end
                                        end
                                    end
                                end
                            end, MAP_TELEPORTERS[teleporter_ID].teleport_back_ms)
                        end

                        if MAP_TELEPORTERS[teleporter_ID].teleporter_cooldown_ms > 0 then
                            teleporter:SetValue("CanTeleport", false, true)
                            Timer.SetTimeout(function()
                                if teleporter:IsValid() then
                                    teleporter:SetValue("CanTeleport", true, true)
                                end
                            end, MAP_TELEPORTERS[teleporter_ID].teleporter_cooldown_ms)
                        end
                    end
                end
            end
        end
    end
end)

if Prone_Perk_Config.enabled then
    VZ_EVENT_SUBSCRIBE("Character", "StanceModeChanged", function(char, old_state, new_state)
        local ply = char:GetPlayer()
        if ply then
            if not char:GetValue("PlayerDown") then
                if new_state == StanceMode.Proning then
                    local char_loc = char:GetLocation()
                    local char_rot = char:GetRotation()
                    for k, v in pairs(StaticMesh.GetPairs()) do
                        if v:GetValue("ProneMoney") then
                            local perk_loc = v:GetLocation()
                            if char_loc:DistanceSquared(perk_loc) <= Prone_Perk_Config.Max_Distance_sq then
                                local perk_rot = v:GetRotation()
                                local rel_yaw = RelRot1(char_rot.Yaw, perk_rot.Yaw)
                                if (rel_yaw >= Prone_Perk_Config.Rel_Rot_Between[1] and rel_yaw <= Prone_Perk_Config.Rel_Rot_Between[2]) then
                                    v:SetValue("ProneMoney", nil, false)
                                    AddMoney(ply, Prone_Perk_Config.money)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end