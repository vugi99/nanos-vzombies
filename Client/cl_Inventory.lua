


Input.Register("VZ Switch Weapon", "X")

Input.Bind("VZ Switch Weapon", InputEvent.Pressed, function()
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        Events.CallRemote("VZ_Switch_Weapon")
    end
end)