

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
VZ_EVENT_SUBSCRIBE_REMOTE("BuyPerk", BuyPerk)

function GiveCharacterPerk(char, perk_name)
    if PERKS_CONFIG[perk_name] then
        local ply = char:GetPlayer()
        local char_perks = char:GetValue("OwnedPerks")
        if not char_perks[perk_name] then
            char_perks[perk_name] = true
            char:SetValue("OwnedPerks", char_perks, true)
            if perk_name == "juggernog" then
                ClearRegenTimeouts(char)
                char:SetHealth(1000 + PERKS_CONFIG.juggernog.PlayerHealth)
                Events.CallRemote("UpdateGUIHealth", ply)
            elseif perk_name == "stamin_up" then
                char:SetSpeedMultiplier(PERKS_CONFIG.stamin_up.Speed_Multiplier)
            elseif perk_name == "speed_cola" then
                local weap = char:GetPicked()
                if weap then
                    if not weap:IsA(Grenade) and not weap:IsA(Melee) then
                        weap:ActivateSpeedReload(true)
                    end
                end
            end
        end
    end
end

if Prone_Perk_Config.enabled then
    VZ_EVENT_SUBSCRIBE("Character", "StanceModeChange", function(char, old_state, new_state)
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

function Weapon:ActivateSpeedReload(enable)
    --print(self:GetAnimationReload())
    if not self:GetAnimationReload() then
        return
    end

    local timescale = 1
    if enable then
        timescale = PERKS_CONFIG.speed_cola.Reload_Speed_Timescale
    end

    --print("Weapon:ActivateSpeedReload", enable, timescale)

    return self:SetAnimationReload(self:GetAnimationReload(), timescale)
end