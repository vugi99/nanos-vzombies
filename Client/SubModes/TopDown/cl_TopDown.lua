

VZ_EVENT_SUBSCRIBE("Character", "Highlight", function(char, is_highlighted, ent)
    if IsSelfCharacter(char) then
        if ent then -- error when highlight ground weapons :thinking:
            local m_weap_id = ent:GetValue("MapWeaponID")
            if (not m_weap_id and ent:IsA(Weapon)) then
                if is_highlighted then
                    local asset = ent:GetMesh()
                    local asset_split = split_str(asset, ":")
                    if asset_split[2] then
                        InteractText(asset_split[2])
                        InteractType = "TopDownWeapon"
                        InteractThing = ent
                    end
                elseif (InteractType == "TopDownWeapon" and InteractThing == ent) then
                    ResetInteractState()
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "PickUp", function(char, ent)
    if IsSelfCharacter(char) then
        if ent then
            local m_weap_id = ent:GetValue("MapWeaponID")
            if (not m_weap_id and ent:IsA(Weapon)) then
                if (InteractType == "TopDownWeapon" and InteractThing == ent) then
                    ResetInteractState()
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Weapon", "Destroy", function(weap)
    if (InteractType == "TopDownWeapon" and InteractThing == weap) then
        ResetInteractState()
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "UnPossess", function(ply, char)
    if ply == Client.GetLocalPlayer() then
        if (InteractType == "TopDownWeapon") then
            ResetInteractState()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "PlayerDown" then
        if IsSelfCharacter(char) then
            if (InteractType == "TopDownWeapon") then
                ResetInteractState()
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Input", "MouseScroll", function(mouse_x, mouse_y, delta)
    --print("MouseScroll", mouse_x, mouse_y, delta)
    local ply = Client.GetLocalPlayer()
    if ply then
        local char = ply:GetControlledCharacter()
        if char then
            local arm_length = ply:GetCameraArmLength(true)
            --print("arm_length", arm_length)
            local target = arm_length + (VZ_GetGamemodeConfigValue("Scroll_Mult") * -1 * delta)
            --print(target)
            if ((target >= VZ_GetGamemodeConfigValue("Min_Arm_Length")) and (target <= VZ_GetGamemodeConfigValue("Max_Arm_Length"))) then
                --print("target", target)
                ply:SetCameraArmLength(target, true)
            end
        end
    end
end)