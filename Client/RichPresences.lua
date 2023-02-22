

if DRP_Enabled then
    if DRP_ClientID > 0 then
        Discord.Initialize(DRP_ClientID)
    end
end

function UpdateDiscordRichPresence()
    local NewDRP_Config = {}
    if DRP_Enabled then
        for k, v in pairs(DRP_CONFIG) do
            if k ~= large_image then
                NewDRP_Config[k] = v:gsub("{ROUND_NB}", tostring(ROUND_NB))
                local map_name = Client.GetMap()
                NewDRP_Config[k] = NewDRP_Config[k]:gsub("{MAP_NAME}", split_str(map_name, ":")[2])
            else
                NewDRP_Config[k] = v
            end
        end
        Discord.SetActivity(NewDRP_Config.state, NewDRP_Config.details, NewDRP_Config.large_image, NewDRP_Config.large_text)
    end
end

function UpdateSteamRichPresence()
    if Steam_Rich_Presence_Enabled then
        local new_rp = Steam_Rich_Presence_Text:gsub("{MAP_NAME}", split_str(Client.GetMap(), ":")[2])
        Steam.SetRichPresence(new_rp)
    end
end
UpdateSteamRichPresence()