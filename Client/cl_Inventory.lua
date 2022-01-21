


Input.Register("VZ Switch Weapon", "X")

VZ_BIND("VZ Switch Weapon", InputEvent.Pressed, function()
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        Events.CallRemote("VZ_Switch_Weapon")
    end
end)



Input.Register("Grenade", "A")

VZ_BIND("Grenade", InputEvent.Pressed, function()
    --print("Grenade Pressed")
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            local grenades = char:GetValue("ZGrenadesNB")
            if (grenades and grenades > 0) then
                if (not char:GetPicked() or not NanosUtils.IsA(char:GetPicked(), Grenade)) then
                    Events.CallRemote("PickupGrenade")
                end
            end
        end
    end
end)

VZ_BIND("Grenade", InputEvent.Released, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if (char:GetPicked() and NanosUtils.IsA(char:GetPicked(), Grenade)) then
            Events.CallRemote("ThrowGrenade")
        end
    end
end)

Input.Register("Knife", "V")

VZ_BIND("Knife", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            if char:GetValue("CanUseKnife") then
                Events.CallRemote("UseKnife")
            end
        end
    end
end)