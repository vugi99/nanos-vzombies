


local VZA_MutedChatPlayers = {}
VZA_MutedVOIPPlayers = {}

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_SkipRound", function(ply)
    if VZ_IsAdmin(ply) then
        REMAINING_ENEMIES_TO_SPAWN = 0
        for k, v in pairs(GetEnemiesCharsCopy()) do
            v:SetHealth(0)
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_Ban", function(ply, a_target_ply, a_reason)
    if (a_target_ply and a_target_ply:IsValid()) then
        if VZ_IsAdmin(ply) then
            if not VZ_IsAdmin(a_target_ply) then
                print("[Admin]", ply:GetAccountName(), "Banned " .. a_target_ply:GetAccountName() .. " (nanos account id : " .. tostring(a_target_ply:GetAccountID()) .. ")")
                a_target_ply:Ban(a_reason)
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_Kick", function(ply, a_target_ply, a_reason)
    if (a_target_ply and a_target_ply:IsValid()) then
        if VZ_IsAdmin(ply) then
            print("[Admin]", ply:GetAccountName(), "Kicked " .. a_target_ply:GetAccountName())
            a_target_ply:Kick(a_reason)
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_MuteChat", function(ply, a_target_ply)
    if (a_target_ply and a_target_ply:IsValid()) then
        if VZ_IsAdmin(ply) then
            VZA_MutedChatPlayers[a_target_ply:GetSteamID()] = true
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_MuteVOIP", function(ply, a_target_ply)
    if (a_target_ply and a_target_ply:IsValid()) then
        if VZ_IsAdmin(ply) then
            a_target_ply:SetVOIPSetting(VOIPSetting.Muted)
            VZA_MutedVOIPPlayers[a_target_ply:GetSteamID()] = true
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_UnMuteChat", function(ply, a_target_ply)
    if (a_target_ply and a_target_ply:IsValid()) then
        if VZ_IsAdmin(ply) then
            if VZA_MutedChatPlayers[a_target_ply:GetSteamID()] then
                VZA_MutedChatPlayers[a_target_ply:GetSteamID()] = nil
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_UnMuteVOIP", function(ply, a_target_ply)
    if (a_target_ply and a_target_ply:IsValid()) then
        if VZ_IsAdmin(ply) then
            if VZA_MutedVOIPPlayers[a_target_ply:GetSteamID()] then
                VZA_MutedVOIPPlayers[a_target_ply:GetSteamID()] = nil
                local char = a_target_ply:GetControlledCharacter()
                if char then
                    a_target_ply:SetVOIPSetting(Player_VOIP_Setting_Alive)
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_Unban", function(ply, nanos_a_id)
    if VZ_IsAdmin(ply) then
        Server.Unban(nanos_a_id)
        print("[Admin]", ply:GetAccountName(), "Unbanned " .. nanos_a_id .. " nanos account id")
    end
end)

VZ_EVENT_SUBSCRIBE("Chat", "PlayerSubmit", function(text, ply)
    if VZA_MutedChatPlayers[ply:GetSteamID()] then
        return false
    end
end)


VZ_EVENT_SUBSCRIBE("Player", "Destroy", function(ply)
    if VZA_MutedChatPlayers[ply:GetSteamID()] then
        VZA_MutedChatPlayers[ply:GetSteamID()] = nil
    end
    if VZA_MutedVOIPPlayers[ply:GetSteamID()] then
        VZA_MutedVOIPPlayers[ply:GetSteamID()] = nil
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("VZAM_Mapvote", function(ply)
    if VZ_IsAdmin(ply) then
        if WaitingMapvote == nil then
            if StartMapVote then
                WaitingMapvote = StartMapVote(Mapvote_tbl)
            else
                Events.CallRemote("AddNotification", ply, "mapvote package not started", 10000)
            end
        end
    end
end)