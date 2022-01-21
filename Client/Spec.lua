

Spectating_Player = nil

function GetResetPlyID(old_ply_id, prev_ply)
    local selected_ply_id
    local selected_ply
    for k, v in pairs(Player.GetPairs()) do
        if not v.BOT then
            if v ~= Client.GetLocalPlayer() then
                if v:GetID() ~= old_ply_id then
                    local char = v:GetControlledCharacter()
                    if char then
                        if (not selected_ply_id or ((v:GetID() < selected_ply_id and not prev_ply) or (v:GetID() > selected_ply_id and prev_ply))) then
                            selected_ply_id = v:GetID()
                            selected_ply = v
                        end
                    end
                end
            end
        end
    end
    return selected_ply
end

function GetNewPlayerToSpec(old_ply_id, prev_ply)
    old_ply_id = old_ply_id or 0
    local new_ply
    local new_ply_id
    for k, v in pairs(Player.GetPairs()) do
        if not v.BOT then
            if v ~= Client.GetLocalPlayer() then
                local char = v:GetControlledCharacter()
                if char then
                    if (((v:GetID() > old_ply_id and not new_ply_id and not prev_ply) or (v:GetID() < old_ply_id and not new_ply_id and prev_ply)) or (((v:GetID() > old_ply_id and not prev_ply) or (v:GetID() < old_ply_id and prev_ply)) and ((new_ply_id > v:GetID() and not prev_ply) or (new_ply_id < v:GetID() and prev_ply)))) then
                        new_ply = v
                        new_ply_id = v:GetID()
                    end
                end
            end
        end
    end
    if not new_ply then
        new_ply = GetResetPlyID(old_ply_id, prev_ply)
    end
    return new_ply
end

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    --print("Player Possess")
    if ply == Client.GetLocalPlayer() then
        Spectating_Player = nil
    elseif (not Spectating_Player and not Client.GetLocalPlayer():GetControlledCharacter()) then
        local new_spec = GetNewPlayerToSpec()
        if new_spec then
            Client.GetLocalPlayer():Spectate(new_spec)
            Spectating_Player = new_spec
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "UnPossess", function(ply, char)
    --print("Player UnPossess", ply, char)
    if ply == Client.GetLocalPlayer() then
        local new_spec = GetNewPlayerToSpec()
        --print("new_spec, unpossess", new_spec)
        if new_spec then
            Client.GetLocalPlayer():Spectate(new_spec)
            Spectating_Player = new_spec
        end
    elseif ply == Spectating_Player then
        local new_spec = GetNewPlayerToSpec()
        if new_spec then
            Client.GetLocalPlayer():Spectate(new_spec)
            Spectating_Player = new_spec
        else
            Client.GetLocalPlayer():ResetCamera()
            Spectating_Player = nil
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "Destroy", function(ply)
    --print("Player Destroy")
    if ply == Spectating_Player then
        local new_spec = GetNewPlayerToSpec()
        if new_spec then
            Client.GetLocalPlayer():Spectate(new_spec)
            Spectating_Player = new_spec
        else
            Client.GetLocalPlayer():ResetCamera()
            Spectating_Player = nil
        end
    end
end)


if not Client.GetLocalPlayer():GetControlledCharacter() then
    local new_spec = GetNewPlayerToSpec()
    --print("new_spec", new_spec)
    if new_spec then
        Client.GetLocalPlayer():Spectate(new_spec)
        Spectating_Player = new_spec
    end
end


Input.Register("SpectatePrev", "Left")
Input.Register("SpectateNext", "Right")

VZ_BIND("SpectatePrev", InputEvent.Pressed, function()
    if Spectating_Player then
        local new_spec = GetNewPlayerToSpec(Spectating_Player:GetID(), true)
        if new_spec then
            Client.GetLocalPlayer():Spectate(new_spec)
            Spectating_Player = new_spec
        end
    end
end)

VZ_BIND("SpectateNext", InputEvent.Pressed, function()
    if Spectating_Player then
        local new_spec = GetNewPlayerToSpec(Spectating_Player:GetID())
        if new_spec then
            Client.GetLocalPlayer():Spectate(new_spec)
            Spectating_Player = new_spec
        end
    end
end)