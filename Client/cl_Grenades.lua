

Input.Register("Grenade", "A")


Input.Bind("Grenade", InputEvent.Pressed, function()
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


Input.Bind("Grenade", InputEvent.Released, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if (char:GetPicked() and NanosUtils.IsA(char:GetPicked(), Grenade)) then
            Events.CallRemote("ThrowGrenade")
        end
    end
end)