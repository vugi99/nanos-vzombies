


CreateVZFrame(GUI, "Settings", "65%", "65%", "Settings", "Settings", true, true)
AddVZFrameTab("Settings", "HUD", "HUD")
AddVZFrameTab("Settings", "Other", "Other")



function Add_Canvas_Setting(item_name, setting_key, frozen, both)
    VZ_CL_Current_Settings[setting_key] = AddTabCheckbox("Settings", "HUD", item_name, function(checked)
        VZ_CL_Current_Settings[setting_key] = checked
        if not frozen then
            One_Time_Updates_Canvas:Repaint()
        else
            Frozen_Canvas:Repaint()
        end
        if both then
            Frozen_Canvas:Repaint()
            One_Time_Updates_Canvas:Repaint()
        end
    end, VZ_CL_Current_Settings[setting_key], true)
end

AddTabText("Settings", "HUD", "Canvas")
Add_Canvas_Setting("Enemies Remaining", "Zombies_Remaining_Showed")
Add_Canvas_Setting("Selected Submode", "Selected_Gamemode_Showed", true)
Add_Canvas_Setting("Spectating Player", "Spectating_Player_Showed")
Add_Canvas_Setting("Game Time", "Game_Time_Showed")
if Drawn_Text_Screen_Scaling then
    Add_Canvas_Setting("GUI Auto Scaling", "GUI_Auto_Scaling", nil, true)
end

Frozen_Canvas:Repaint()
One_Time_Updates_Canvas:Repaint()

local WebUI_Settings = {}

function Add_WebUI_Setting(item_name, setting_key, html_id)
    WebUI_Settings[setting_key] = html_id

    VZ_CL_Current_Settings[setting_key] = AddTabCheckbox("Settings", "HUD", item_name, function(checked)
        VZ_CL_Current_Settings[setting_key] = checked
        GUI:CallEvent("ShowElementByID", html_id, VZ_CL_Current_Settings[setting_key])
    end, VZ_CL_Current_Settings[setting_key], true)
    --print(html_id, VZ_CL_Current_Settings[setting_key])
    GUI:CallEvent("ShowElementByID", html_id, VZ_CL_Current_Settings[setting_key])
end

AddTabEmptySpace("Settings", "HUD", 35, true)
AddTabText("Settings", "HUD", "WebUI")

Add_WebUI_Setting("Ammo", "Ammo_Showed", "ammo")
Add_WebUI_Setting("Players Money", "Players_Money_Showed", "players_money")
Add_WebUI_Setting("Wave Number", "Wave_Number_Showed", "waves_text")
Add_WebUI_Setting("Player Perks", "Player_Perks_Showed", "player_perks")
Add_WebUI_Setting("Powerups", "Powerups_Showed", "powerups")
Add_WebUI_Setting("Grenades", "Grenades_Showed", "grenades_container")
Add_WebUI_Setting("Health Bar", "Health_Bar_Showed", "health-bar-container")
Add_WebUI_Setting("VOIP Indicators", "VOIP_Indicators_Showed", "VOIP-container")
if VZ_GetFeatureValue("Levels", "script_loaded") then
    Add_WebUI_Setting("Levels", "Levels_Showed", "lvls_container")
end
Add_WebUI_Setting("Notifications", "Notifications_Showed", "Notifications-container")

AddTabEmptySpace("Settings", "HUD", 35, true)
AddTabText("Settings", "HUD", "Game")

VZ_CL_Current_Settings["Chat_Visibility"] = AddTabCheckbox("Settings", "HUD", "Chat Visibility", function(checked)
    VZ_CL_Current_Settings["Chat_Visibility"] = checked
    Chat.SetVisibility(VZ_CL_Current_Settings["Chat_Visibility"])
end, VZ_CL_Current_Settings["Chat_Visibility"], true)
Chat.SetVisibility(VZ_CL_Current_Settings["Chat_Visibility"])


AddTabEmptySpace("Settings", "HUD", 35, true)
AddTabText("Settings", "HUD", "Technical")

local Canvas_Technical_Settings = {}

function Add_Technical_Canvas_Setting(setting_key)
    if Canvas_Technical_Settings[setting_key] then return end
    VZ_CL_Default_Settings[setting_key] = true
    VZ_CL_Current_Settings[setting_key] = true

    Canvas_Technical_Settings[setting_key] = setting_key
    local item_name = string.gsub(setting_key, "_", " ")

    local function Tech_Canvas_cback(checked)
        if IsValid(_ENV[setting_key]) then
            _ENV[setting_key]:SetVisibility(checked)
        else
            Console.Warn("Canvas Technical setting key '%s' not found in _ENV", setting_key)
        end
    end

    VZ_CL_Current_Settings[setting_key] = AddTabCheckbox("Settings", "HUD", item_name, Tech_Canvas_cback, VZ_CL_Current_Settings[setting_key], true)
    Tech_Canvas_cback(VZ_CL_Current_Settings[setting_key])
end


VZ_EVENT_SUBSCRIBE("Events", "VZ_CLIENTSIDE_LOADED", function()
    for setting_key, canvas in pairs(VZ_GetCanvases()) do
        Add_Technical_Canvas_Setting(setting_key)
    end

    VZ_EVENT_SUBSCRIBE("Events", "VZ_Canvas_Created", function(key, canvas)
        Add_Technical_Canvas_Setting(key)
    end)
end)


VZ_CL_Current_Settings["Clientside_Gibs"] = AddTabCheckbox("Settings", "Other", "Clientside Gibs", function(checked)
    VZ_CL_Current_Settings["Clientside_Gibs"] = checked
    if not checked then
        for k, v in pairs(Prop.GetAll()) do
            if v:GetValue("GibData") then
                if v:HasAuthority() then
                    --print("Destroy Gib")
                    v:Destroy()
                end
            end
        end
    end
end, VZ_CL_Current_Settings["Clientside_Gibs"], true)

VZ_CL_Current_Settings["Player_Names_On_Heads"] = AddTabCheckbox("Settings", "Other", "Player Names On Heads", function(checked)
    VZ_CL_Current_Settings["Player_Names_On_Heads"] = checked
    if not checked then
        CleanupText3Ds()
    else
        SpawnText3Ds()
    end
end, VZ_CL_Current_Settings["Clientside_Gibs"], true)
if not VZ_CL_Current_Settings["Player_Names_On_Heads"] then
    CleanupText3Ds()
end

-- TODO: Reset should call all settings callbacks with the correct checked value?
AddTabButton("Settings", "Other", "Reset Settings", function()
    ResetVZFrameSaved("Settings")
    VZ_CL_Current_Settings = TableDeepCopy(VZ_CL_Default_Settings)
    One_Time_Updates_Canvas:Repaint()
    Frozen_Canvas:Repaint()

    SpawnText3Ds()

    for k, v in pairs(WebUI_Settings) do
        --print(v, VZ_CL_Current_Settings[k])
        GUI:CallEvent("ShowElementByID", v, VZ_CL_Current_Settings[k])
    end
    Chat.SetVisibility(VZ_CL_Current_Settings["Chat_Visibility"])

    for k, v in pairs(Canvas_Technical_Settings) do
        if IsValid(v) then
            v:SetVisibility(true)
        end
    end
end, "Reset")