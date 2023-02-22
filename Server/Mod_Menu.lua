
local _Weapons_Names = {}

for k, v in pairs(NanosWorldWeapons) do
    table.insert(_Weapons_Names, k)
end

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_GodMode", function(ply, enable)
    ply:SetValue("MM_GodMode", enable, false)
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_Noclip", function(ply)
    local char = ply:GetControlledCharacter()
    if char then
        local noclip = char:GetValue("NoClip")
        if noclip then
            char:SetFlyingMode(false)
            char:SetCollision(CollisionType.Normal)
        else
            char:SetFlyingMode(true)
            char:SetCollision(CollisionType.NoCollision)
        end
        char:SetValue("NoClip", not noclip, false)
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerJoined", function(ply)
    Events.CallRemote("Send_Weapons_Names", ply, _Weapons_Names)
    ply:SetValue("MM_GodMode", true, false)
    ply:SetValue("MM_InfMoney", true, false)
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_GiveWeap", function(ply, selected)
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            AddCharacterWeapon(char, selected, GetWeaponNameMaxAmmo(selected), true)
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_GivePowerup", function(ply, selected)
    local char = ply:GetControlledCharacter()
    if char then
        PowerupGrabbed(selected, char)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_GivePerk", function(ply, selected)
    local char = ply:GetControlledCharacter()
    if char then
        GiveCharacterPerk(char, selected)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_InfGrenades", function(ply, checked)
    ply:SetValue("MM_InfGrenades", true, false)
    local char = ply:GetControlledCharacter()
    if (char and checked) then
        char:SetValue("ZGrenadesNB", Max_Grenades_NB, true)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_PAP", function(ply, repack_effect)
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            local charInvID = GetCharacterInventory(char)
            if charInvID then
                local Inv = PlayersCharactersWeapons[charInvID]
                if Inv.selected_slot then

                    for i, v in ipairs(Inv.weapons) do
                        if (v.slot == Inv.selected_slot and v.weapon) then
                            if v.weapon:IsValid() then
                                if v.weapon:IsA(Weapon) then
                                    if repack_effect then
                                        v.pap = true
                                    else
                                        v.pap = not v.pap
                                    end
                                    v.pap_repack_effect = repack_effect
                                    v.weapon:SetValue("PAPRepackEffect", v.pap_repack_effect, true)
                                    if v.pap then
                                        --selected_weap = v.weapon_name
                                        v.weapon:SetMaterial(Pack_a_punch_weapon_material, Pack_a_punch_weapon_material_index)
                                    else
                                        v.weapon:ResetMaterial(-1)
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_SetRound", function(ply, r_nb)
    if ply then
        ROUND_NB = r_nb - 1
        --print("ROUND_NB set to", ROUND_NB + 1)

        REMAINING_ENEMIES_TO_SPAWN = 0
        local killed
        for k, v in pairs(GetEnemiesCharsCopy()) do
            v:SetHealth(0)
            killed = true
        end

        if not killed then
            if (table_count(ENEMY_CHARACTERS) == 0 and REMAINING_ENEMIES_TO_SPAWN == 0 and not WaitingNewRound_Timer) then
                RoundFinished()
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_SetPM", function(ply, selected)
    if ply then
        local PM_Data = ply:GetValue("PM_Data")
        if PM_Data then
            PM_Data.Parameters = {}
            PM_Data.Model = selected
        end
    end

    local char = ply:GetControlledCharacter()
    if char then
        char:SetMesh(selected)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_SetCamMode", function(ply, selected)
    ply:SetValue("MM_CamMode", CameraMode[selected], false)
    local char = ply:GetControlledCharacter()
    if char then
        char:SetCameraMode(CameraMode[selected])
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_OpenAllDoors", function(ply)
    if ply:IsValid() then
        local _opened_door = true
        while _opened_door do
            _opened_door = false
            for i, v in ipairs(MAP_DOORS) do
                local required_rooms_good = true
                for i2, v2 in ipairs(MAP_DOORS[i].required_rooms) do
                    if not ROOMS_UNLOCKED[v2] then
                        required_rooms_good = false
                        break
                    end
                end

                if required_rooms_good then
                    _opened_door = _opened_door or OpenMapDoor(i)
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_SetMoney", function(ply, money)
    ply:SetValue("ZMoney", money, true)
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_InfiniteMoney", function(ply, enable)
    ply:SetValue("MM_InfMoney", enable, false)
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_Power", function(ply)
    if not POWER_ON then
        PlayerTurnPowerON(ply, MAP_POWER_SM)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZMM_SpawnVehicle", function(ply, selected)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetVehicle() then
                if not char:GetValue("PlayerDown") then
                    if SpawnVehicle then
                        local veh = SpawnVehicle(selected, char:GetLocation() + Vector(0, 0, 100), char:GetRotation())
                        char:EnterVehicle(veh, 0)
                    end
                end
            end
        end
    end
end)