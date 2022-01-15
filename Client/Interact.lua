
POWER_ON = false

local InteractType = nil
local InteractThing = nil

local RepairBarricadeInterval

local RevivingPlayerData

Character.Subscribe("Highlight", function(char, Highlight, ent)
    if IsSelfCharacter(char) then
        if ent then -- error when highlight ground weapons :thinking:
            local m_weap_id = ent:GetValue("MapWeaponID")
            if m_weap_id then
                if Highlight then
                    BuyText(MAP_WEAPONS[m_weap_id].weapon_name .. "/ Ammo", tostring(MAP_WEAPONS[m_weap_id].price) .. "$ / " .. tostring(math.floor(MAP_WEAPONS[m_weap_id].price * Weapons_Ammo_Price_Percentage / 100)) .. " $ / " .. tostring(Pack_a_punch_price))
                    InteractType = "MapWeapon"
                    InteractThing = m_weap_id
                elseif (InteractType == "MapWeapon" and InteractThing == m_weap_id) then
                    InteractType = nil
                    InteractThing = nil
                    Render.ClearItems(1)
                end
            end
        end
    end
end)

Timer.SetInterval(function()
    if (InteractType == nil or InteractType == "MapDoor") then
        local local_player = Client.GetLocalPlayer()
        local local_char = local_player:GetControlledCharacter()

        local found_door
        if local_char then
            local local_char_location = local_char:GetLocation()
            for k, v in pairs(StaticMesh.GetPairs()) do
                if v:IsValid() then
                    local door_id = v:GetValue("DoorID")
                    if door_id then
                        local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                        if distance_sq <= Doors_Interact_Check_Distance_Squared_Max then
                            BuyText("Door", tostring(MAP_DOORS[door_id].price))
                            InteractType = "MapDoor"
                            InteractThing = door_id
                            found_door = true
                        end
                    end
                end
            end
        end
        if not found_door then
            if InteractType == "MapDoor" then
                InteractType = nil
                InteractThing = nil
                Render.ClearItems(1)
            end
        end
    end
end, Doors_Interact_Check_Interval_ms)

Timer.SetInterval(function()
    if (InteractType == nil or InteractType == "MapBarricade") then
        local local_player = Client.GetLocalPlayer()
        local local_char = local_player:GetControlledCharacter()

        local found_barricade
        if local_char then
            local local_char_location = local_char:GetLocation()
            for k, v in pairs(StaticMesh.GetPairs()) do
                if v:IsValid() then
                    local zspawn_id = v:GetValue("BarricadeSpawnID")
                    if zspawn_id then
                        if v:GetValue("BarricadeLife") < 5 then
                            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                            if distance_sq <= Barricades_Interact_Check_Distance_Squared_Max then
                                if InteractThing ~= v then
                                    if RepairBarricadeInterval then
                                        Timer.ClearInterval(RepairBarricadeInterval)
                                        RepairBarricadeInterval = nil
                                    end
                                    InteractText("Repair Barricade")
                                    InteractType = "MapBarricade"
                                    InteractThing = v
                                end
                                found_barricade = true
                            end
                        end
                    end
                end
            end
        end
        if not found_barricade then
            if InteractType == "MapBarricade" then
                if RepairBarricadeInterval then
                    Timer.ClearInterval(RepairBarricadeInterval)
                    RepairBarricadeInterval = nil
                end
                InteractType = nil
                InteractThing = nil
                Render.ClearItems(1)
            end
        end
    end
end, Barricades_Interact_Check_Interval_ms)

function RepairBarricadeIFunc()
    if (InteractThing and InteractThing ~= "NoPower" and InteractThing:IsValid() and InteractThing:GetValue("BarricadeLife") < 5) then
        local repair_sound = Sound(
            Vector(0, 0, 0),
            Barricade_Repair_Sound.asset,
            true,
            true,
            SoundType.SFX,
            Barricade_Repair_Sound.volume
        )
        Events.CallRemote("RepairBarricade", InteractThing:GetValue("BarricadeSpawnID"))
    elseif RepairBarricadeInterval then
        Timer.ClearInterval(RepairBarricadeInterval)
        RepairBarricadeInterval = nil
    end
end

Timer.SetInterval(function()
    if (InteractType == nil or InteractType == "RevivePlayer") then
        local local_player = Client.GetLocalPlayer()
        local local_char = local_player:GetControlledCharacter()

        local found_downplayer
        if local_char then
            local local_char_location = local_char:GetLocation()
            for k, v in pairs(Character.GetPairs()) do
                if (v:IsValid() and not IsSelfCharacter(v)) then
                    local RevivingPlayer = v:GetValue("RevivingPlayer")
                    if (v:GetValue("PlayerDown") and (not RevivingPlayer or RevivingPlayer == local_char:GetID())) then
                        local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                        if distance_sq <= DownPlayer_Interact_Check_Distance_Squared_Max then
                            if not RevivingPlayerData then
                                InteractText("Hold to Revive Player")
                                InteractType = "RevivePlayer"
                                InteractThing = v
                            end
                            found_downplayer = true
                        end
                    end
                end
            end
        end
        if not found_downplayer then
            if InteractType == "RevivePlayer" then
                InteractType = nil
                InteractThing = nil
                Render.ClearItems(1)
            end
        end
    end
end, DownPlayer_Interact_Check_Interval_ms)

Timer.SetInterval(function()
    if (InteractType == nil or InteractType == "MapMBOX") then
        local local_player = Client.GetLocalPlayer()
        local local_char = local_player:GetControlledCharacter()

        local found_MBOX
        if local_char then
            local local_char_location = local_char:GetLocation()
            for k, v in pairs(StaticMesh.GetPairs()) do
                if v:IsValid() then
                    local can_buy_mbox = v:GetValue("CanBuyMysteryBox")
                    if can_buy_mbox then
                        local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                        if distance_sq <= MBOX_Interact_Check_Distance_Squared_Max then
                            InteractType = "MapMBOX"
                            BuyText("Mystery Box", tostring(Mystery_box_price))
                            InteractThing = v
                            found_MBOX = true
                        end
                    end
                end
            end
        end
        if not found_MBOX then
            if InteractType == "MapMBOX" then
                InteractType = nil
                InteractThing = nil
                Render.ClearItems(1)
            end
        end
    end
end, MBOX_Interact_Check_Interval_ms)

Timer.SetInterval(function()
    if (InteractType == nil or InteractType == "MapPower") then
        local local_player = Client.GetLocalPlayer()
        local local_char = local_player:GetControlledCharacter()

        local found_POW
        if local_char then
            if not POWER_ON then
                local local_char_location = local_char:GetLocation()
                for k, v in pairs(StaticMesh.GetPairs()) do
                    if v:IsValid() then
                        local is_Map_Power = v:GetValue("MapPower")
                        if is_Map_Power then
                            local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                            if distance_sq <= POWER_Interact_Check_Distance_Squared_Max then
                                InteractType = "MapPower"
                                InteractText("Turn Power ON")
                                InteractThing = v
                                found_POW = true
                            end
                        end
                    end
                end
            end
        end
        if not found_POW then
            if InteractType == "MapPower" then
                InteractType = nil
                InteractThing = nil
                Render.ClearItems(1)
            end
        end
    end
end, POWER_Interact_Check_Interval_ms)

Timer.SetInterval(function()
    if (InteractType == nil or InteractType == "MapPerk") then
        local local_player = Client.GetLocalPlayer()
        local local_char = local_player:GetControlledCharacter()

        local found_Perk
        if local_char then
            local local_char_location = local_char:GetLocation()
            for k, v in pairs(StaticMesh.GetPairs()) do
                if v:IsValid() then
                    local perk = v:GetValue("MapPerk")
                    if (perk and not CurPerks[perk]) then
                        local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                        if distance_sq <= Perk_Interact_Check_Distance_Squared_Max then
                            InteractType = "MapPerk"
                            if (POWER_ON and perk ~= "three_gun") then
                                InteractThing = v
                                BuyText(perk .. " Perk", tostring(PERKS_CONFIG[perk].price))
                            else
                                InteractThing = "NoPower"
                                if perk == "three_gun" then
                                    InteractText("SOON")
                                else
                                    InteractText("Missing Power")
                                end
                            end
                            found_Perk = true
                        end
                    end
                end
            end
        end
        if not found_Perk then
            if InteractType == "MapPerk" then
                InteractType = nil
                InteractThing = nil
                Render.ClearItems(1)
            end
        end
    end
end, Perk_Interact_Check_Interval_ms)

Timer.SetInterval(function()
    if (InteractType == nil or InteractType == "MapPAP") then
        local local_player = Client.GetLocalPlayer()
        local local_char = local_player:GetControlledCharacter()

        local found_PAP
        if local_char then
            local local_char_location = local_char:GetLocation()
            for k, v in pairs(StaticMesh.GetPairs()) do
                if v:IsValid() then
                    local can_buy_pap = v:GetValue("CanBuyPackAPunch")
                    if can_buy_pap then
                        local distance_sq = local_char_location:DistanceSquared(v:GetLocation())
                        if distance_sq <= PAP_Interact_Check_Distance_Squared_Max then
                            InteractType = "MapPAP"
                            if POWER_ON then
                                InteractThing = v
                                BuyText("Weapon Upgrade", tostring(Pack_a_punch_price))
                            else
                                InteractThing = "NoPower"
                                InteractText("Missing Power")
                            end
                            found_PAP = true
                        end
                    end
                end
            end
        end
        if not found_PAP then
            if InteractType == "MapPAP" then
                InteractType = nil
                InteractThing = nil
                Render.ClearItems(1)
            end
        end
    end
end, PAP_Interact_Check_Interval_ms)

Character.Subscribe("ValueChange", function(char, key, value)
    if key == "RevivingPlayer" then
        if value then
            local ply = Client.GetLocalPlayer()
            local local_char = ply:GetControlledCharacter()
            if local_char then
                if value == local_char:GetID() then
                    if (InteractThing and InteractType == "RevivePlayer") then
                        local rev_time = ReviveTime_ms
                        local perks = local_char:GetValue("OwnedPerks")
                        if (perks and perks["quick_revive"]) then
                            rev_time = PERKS_CONFIG.quick_revive.ReviveTime_ms
                        end
                        GUIStartRevive(rev_time)
                        RevivingPlayerData = {}
                        RevivingPlayerData.timeout = Timer.SetTimeout(function()
                            RevivingPlayerData = nil
                            Events.CallRemote("RevivePlayerFinished", char)
                        end, rev_time)
                        RevivingPlayerData.char = char
                    else
                        Events.CallRemote("RevivePlayerStopped", char)
                    end
                end
            end
        end
    end
end)

Character.Subscribe("Destroy", function(char)
    if RevivingPlayerData then
        if RevivingPlayerData.char == char then
            Timer.ClearTimeout(RevivingPlayerData.timeout)
            GUIStopRevive()
            RevivingPlayerData = nil
        end
    end
end)

Input.Bind("Interact", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            if InteractType == "MapDoor" then
                Events.CallRemote("BuyDoor", InteractThing)
            elseif InteractType == "MapBarricade" then
                RepairBarricadeInterval = Timer.SetInterval(RepairBarricadeIFunc, Repair_Barricade_Interval_ms)
            elseif InteractType == "RevivePlayer" then
                Events.CallRemote("RevivePlayer", InteractThing)
            elseif InteractType == "MapMBOX" then
                Events.CallRemote("BuyMBOX", InteractThing)
            elseif InteractType == "MapPower" then
                Events.CallRemote("TurnPowerON", InteractThing)
            elseif InteractType == "MapPerk" then
                if InteractThing ~= "NoPower" then
                    Events.CallRemote("BuyPerk", InteractThing)
                end
            elseif InteractType == "MapPAP" then
                if InteractThing ~= "NoPower" then
                    Events.CallRemote("UpgradeWeap", InteractThing)
                end
            end
        end
    end
end)

Input.Bind("Interact", InputEvent.Released, function()
    if InteractType == "MapBarricade" then
        if RepairBarricadeInterval then
            Timer.ClearInterval(RepairBarricadeInterval)
            RepairBarricadeInterval = nil
        end
    elseif (InteractType == "RevivePlayer" and RevivingPlayerData) then
        Timer.ClearTimeout(RevivingPlayerData.timeout)
        GUIStopRevive()
        Events.CallRemote("RevivePlayerStopped", RevivingPlayerData.char)
        RevivingPlayerData = nil
    end
end)

Events.Subscribe("SetClientPowerON", function(is_on)
    POWER_ON = is_on
end)