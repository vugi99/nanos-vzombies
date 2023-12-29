


CreateVZFrame(GUI, "Settings", "65%", "65%", "Settings", "Settings", true)
AddVZFrameTab("Settings", "HUD", "HUD")
AddVZFrameTab("Settings", "Other", "Other")



function Add_Canvas_Setting(item_name, setting_key, frozen)
    VZ_CL_Current_Settings[setting_key] = AddTabCheckbox("Settings", "HUD", item_name, function(checked)
        VZ_CL_Current_Settings[setting_key] = checked
        if not frozen then
            One_Time_Updates_Canvas:Repaint()
        else
            Frozen_Canvas:Repaint()
        end
    end, VZ_CL_Current_Settings[setting_key], true)
end

AddTabText("Settings", "HUD", "Canvas")
Add_Canvas_Setting("Enemies Remaining", "Zombies_Remaining_Showed")
Add_Canvas_Setting("Selected Submode", "Selected_Gamemode_Showed", true)
Add_Canvas_Setting("Spectating Player", "Spectating_Player_Showed")
Add_Canvas_Setting("Game Time", "Game_Time_Showed")
--Add_Canvas_Setting("Player Names On Heads", "Player_Names_On_Heads")

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


AddTabButton("Settings", "Other", "Reset Settings", function()
    ResetVZFrameSaved("Settings")
    VZ_CL_Current_Settings = TableDeepCopy(VZ_CL_Default_Settings)
    One_Time_Updates_Canvas:Repaint()
    Frozen_Canvas:Repaint()

    for k, v in pairs(WebUI_Settings) do
        --print(v, VZ_CL_Current_Settings[k])
        GUI:CallEvent("ShowElementByID", v, VZ_CL_Current_Settings[k])
    end
    Chat.SetVisibility(VZ_CL_Current_Settings["Chat_Visibility"])
end, "Reset")