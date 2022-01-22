

Spectating_Player = nil

Spectating_Render_ItemID = nil

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

function SpectatePlayer(to_spec)
    if to_spec then
        Client.GetLocalPlayer():Spectate(to_spec)
        Spectating_Player = to_spec

        local text = "Spectating : " .. to_spec:GetAccountName()

        if Spectating_Render_ItemID then
            Render.UpdateItemText(7, Spectating_Render_ItemID, text)
        else
            Spectating_Render_ItemID = Render.AddText(7, text, Vector2D(math.floor(Render.GetViewportSize().X * 0.5), 30), 0, 14, Color.WHITE, 0, true, true, false, Vector2D(0, 0), Color.WHITE, false, Color.WHITE)
        end
    end
end

function StopSpectate()
    Client.GetLocalPlayer():ResetCamera()
    Spectating_Player = nil
    Render.ClearItems(7)
    Spectating_Render_ItemID = nil
end

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    --print("Player Possess")
    if ply == Client.GetLocalPlayer() then
        StopSpectate()
    elseif (not Spectating_Player and not Client.GetLocalPlayer():GetControlledCharacter()) then
        local new_spec = GetNewPlayerToSpec()
        SpectatePlayer(new_spec)
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "UnPossess", function(ply, char)
    --print("Player UnPossess", ply, char)
    if ply == Client.GetLocalPlayer() then
        local new_spec = GetNewPlayerToSpec()
        --print("new_spec, unpossess", new_spec)
        SpectatePlayer(new_spec)
    elseif ply == Spectating_Player then
        local new_spec = GetNewPlayerToSpec()
        if new_spec then
            SpectatePlayer(new_spec)
        else
            StopSpectate()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "Destroy", function(ply)
    --print("Player Destroy")
    if ply == Spectating_Player then
        local new_spec = GetNewPlayerToSpec()
        if new_spec then
            SpectatePlayer(new_spec)
        else
            StopSpectate()
        end
    end
end)


if not Client.GetLocalPlayer():GetControlledCharacter() then
    local new_spec = GetNewPlayerToSpec()
    --print("new_spec", new_spec)
    SpectatePlayer(new_spec)
end


Input.Register("SpectatePrev", "Left")
Input.Register("SpectateNext", "Right")

VZ_BIND("SpectatePrev", InputEvent.Pressed, function()
    if Spectating_Player then
        local new_spec = GetNewPlayerToSpec(Spectating_Player:GetID(), true)
        SpectatePlayer(new_spec)
    end
end)

VZ_BIND("SpectateNext", InputEvent.Pressed, function()
    if Spectating_Player then
        local new_spec = GetNewPlayerToSpec(Spectating_Player:GetID())
        SpectatePlayer(new_spec)
    end
end)