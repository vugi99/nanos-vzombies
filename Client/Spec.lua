

Spectating_Player = nil
Free_Cam = nil

function GetResetPlyID(old_ply_id, prev_ply)
    local selected_ply_id
    local selected_ply
    for k, v in pairs(Player.GetPairs()) do
        if not v.BOT then
            if v ~= Client.GetLocalPlayer() then
                if (v:GetID() ~= old_ply_id or Free_Cam) then
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

function IsSpectatingPlayerCharacter(char)
    if Spectating_Player then
        local spec_char = Spectating_Player:GetControlledCharacter()
        --print("IsSpectatingPlayerCharacter", spec_char, char, Spectating_Player:GetID())
        if spec_char == char then
            return true
        end
    end
end

function SpectatePlayer(to_spec)
    --print("SpectatePlayer", to_spec)
    if to_spec then
        Client.GetLocalPlayer():Spectate(to_spec)
        Spectating_Player = to_spec

        local char = Spectating_Player:GetControlledCharacter()
        local picked = char:GetPicked()
        if picked then
            NeedToUpdateAmmoText(char, picked)
        end

        One_Time_Updates_Canvas:Repaint()
    end
end

function StopSpectate()
    --print("StopSpectate")
    Client.GetLocalPlayer():ResetCamera()
    Spectating_Player = nil
    One_Time_Updates_Canvas:Repaint()
    Free_Cam = nil
end

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    --print("Player Possess", ply:GetID(), char:GetID(), ply:GetClass(), char:GetClass())
    --print("Client.GetLocalPlayer()", Client.GetLocalPlayer(), Client.GetLocalPlayer():GetID(), Client.GetLocalPlayer():GetClass())
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