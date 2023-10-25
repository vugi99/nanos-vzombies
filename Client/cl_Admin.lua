

VZ_Register_Input("VZ Admin Menu", "U")

CreateVZFrame(GUI, "Admin_Menu", "65%", "65%", "Admin Menu", "VZ Admin Menu", true)
AddVZFrameTab("Admin_Menu", "Admin", "Admin")

AddTabButton("Admin_Menu", "Admin", "Skip Round", function()
    Events.CallRemote("VZAM_SkipRound")
end, "Skip Round")

AddTabTextInput("Admin_Menu", "Admin", "Unban", function(text)
    if (text and text ~= "") then
        Events.CallRemote("VZAM_Unban", text)
    end
end, "nanos account id", false)

AddTabButton("Admin_Menu", "Admin", "Start Mapvote", function()
    Events.CallRemote("VZAM_Mapvote")
end, "Start Mapvote")

AddTabText("Admin_Menu", "Admin", "", true)
AddTabText("Admin_Menu", "Admin", "Player")


local a_target_ply
local a_reason = ""

AddTabTextInput("Admin_Menu", "Admin", "Player Name", function(text)
    if (text and text ~= "") then
        local splited_text = split_str(text, " ")
        if (splited_text[1]) then
            local name = splited_text[1]
            if splited_text[2] then
                for i = 2, table_count(splited_text) do
                    name = name .. " " .. splited_text[i]
                end
            end
            for k, v in pairs(Player.GetPairs()) do
                if not v.BOT then
                    if v ~= Client.GetLocalPlayer() then
                        if v:GetAccountName() == name then
                            a_target_ply = v
                            break
                        end
                    end
                end
            end
        end
    end
end, "player name", false)

AddTabTextInput("Admin_Menu", "Admin", "Reason", function(text)
    if text then
        a_reason = text
    end
end, "reason", false)

AddTabButton("Admin_Menu", "Admin", "Ban", function()
    if (a_target_ply and a_target_ply:IsValid()) then
        Events.CallRemote("VZAM_Ban", a_target_ply, a_reason)
    end
end, "Ban")

AddTabButton("Admin_Menu", "Admin", "Kick", function()
    if (a_target_ply and a_target_ply:IsValid()) then
        Events.CallRemote("VZAM_Kick", a_target_ply, a_reason)
    end
end, "Kick")

AddTabButton("Admin_Menu", "Admin", "Mute (chat)", function()
    if (a_target_ply and a_target_ply:IsValid()) then
        Events.CallRemote("VZAM_MuteChat", a_target_ply)
    end
end, "Mute (chat)")

AddTabButton("Admin_Menu", "Admin", "Mute (VOIP)", function()
    if (a_target_ply and a_target_ply:IsValid()) then
        Events.CallRemote("VZAM_MuteVOIP", a_target_ply)
    end
end, "Mute (VOIP)")

AddTabButton("Admin_Menu", "Admin", "UnMute (chat)", function()
    if (a_target_ply and a_target_ply:IsValid()) then
        Events.CallRemote("VZAM_UnMuteChat", a_target_ply)
    end
end, "UnMute (chat)")

AddTabButton("Admin_Menu", "Admin", "UnMute (VOIP)", function()
    if (a_target_ply and a_target_ply:IsValid()) then
        Events.CallRemote("VZAM_UnMuteVOIP", a_target_ply)
    end
end, "UnMute (VOIP)")