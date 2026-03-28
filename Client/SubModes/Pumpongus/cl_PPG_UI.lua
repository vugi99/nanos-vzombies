
PPG_UI = WebUI("PumpongUs GUI", "file://gui/pumpongus/index.html", WidgetVisibility.VisibleNotHitTestable, true, true)

PPG_UI:Subscribe("Ready", function()
    if ZDEV_IsModeEnabled("ZDEV_DEBUG_WEBUIS_DEVTOOLS") then
        PPG_UI:OpenDevTools()
    end
end)



local PPG_Voting_Showed = false

PPG_One_Time_Update_Data = {}

-- This canvas will be used for one time updates
PPG_One_Time_Updates_Canvas = Canvas(
    true,
    Color(0, 0, 0, 0),
    -1,
    true
)
PPG_One_Time_Updates_Canvas:Subscribe("Update", function(self, width, height)
    if PPG_One_Time_Update_Data.Role then
        local text = "You are " .. PPG_One_Time_Update_Data.Role

        local role_color
        if PPG_One_Time_Update_Data.Role == "Imposter" then
            role_color = Color.RED

            if Input.GetMappedKeys("Imposter Power") then
                if not PPG_CanActivateImposterPower() then
                    local min_activation_round = VZ_GetGamemodeConfigValue("Imposter_Min_Round_Activation")
                    text = text .. ", power unlocked at round " .. tostring(min_activation_round)
                else
                    if not PPG_One_Time_Update_Data.ImposterActivated then
                        text = text .. ", press '" .. Input.GetMappedKeys("Imposter Power")[1] .. "' to activate the Imposter Power"
                    end
                end
            end

            local x_offset = 30

            local start_cury = 300

            local cury = start_cury

            self:DrawText("Imposter Power Stats:", GUI_PositionScaling(Vector2D(math.floor(x_offset+5), math.floor(cury)), VZ_GUI_ANCHOR_MIDDLE_LEFT), 0, GUI_TextDrawnScalingSize(13), role_color, 0, false, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)

            local players_alive_wo_imposter = 0
            for k, v in pairs(Player.GetPairs()) do
                if v ~= Client.GetLocalPlayer() then
                    local vc = v:GetControlledCharacter()
                    if IsValid(vc) and (not vc:GetValue("PlayerDown")) then
                        players_alive_wo_imposter = players_alive_wo_imposter + 1
                    end
                end
            end

            local max_stext_len = 0

            for i, v in ipairs(VZ_GetGamemodeConfigValue("Imposter_Stats") or {}) do
                cury = cury + GUI_TextDrawnScalingSize(12)*2

                local stat_text = v.Name .. ": " .. string.format("%.2f", (v.Base + (v.Per_Pumpkin or 0)*(PPG_One_Time_Update_Data.Pumpkins_Collected or 0) + (v.Per_Bystander or 0)*players_alive_wo_imposter))

                max_stext_len = math.max(max_stext_len, string.len(stat_text))

                self:DrawText(stat_text, GUI_PositionScaling(Vector2D(math.floor(x_offset+10), math.floor(cury)), VZ_GUI_ANCHOR_MIDDLE_LEFT), 0, GUI_TextDrawnScalingSize(12), Color.WHITE, 0, false, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
            end

            self:DrawBox(GUI_PositionScaling(Vector2D(math.floor(x_offset), math.floor(start_cury-(5+GUI_TextDrawnScalingSize(12)))), VZ_GUI_ANCHOR_MIDDLE_LEFT), Vector2D(math.floor(15 + max_stext_len*GUI_TextDrawnScalingSize(12)/1.5), math.floor((cury-start_cury)+GUI_TextDrawnScalingSize(12)*2+10), VZ_GUI_ANCHOR_MIDDLE_LEFT), 2, Color(0.25, 0.25, 0.25))

            cury = cury + GUI_TextDrawnScalingSize(12)*5

            local Sabotage_Text = ""
            if Input.GetMappedKeys("Imposter Sabotage") then
                if not PPG_One_Time_Update_Data.ImposterActivated then
                    Sabotage_Text = "Press '" .. Input.GetMappedKeys("Imposter Sabotage")[1] .. "' to spawn sabotage entity."
                else
                    Sabotage_Text = "Press '" .. Input.GetMappedKeys("Imposter Sabotage")[1] .. "' to spawn dark tentacles entity."
                end
            end
            if PPG_One_Time_Update_Data.Sabotage_Cooldown then
                Sabotage_Text = "Sabotage in cooldown " .. tostring(PPG_One_Time_Update_Data.Sabotage_Cooldown) .. "s"
            end

            self:DrawText(Sabotage_Text, GUI_PositionScaling(Vector2D(math.floor(20), math.floor(cury)), VZ_GUI_ANCHOR_MIDDLE_LEFT), 0, GUI_TextDrawnScalingSize(14), Color(182/255, 3/255, 252/255), 0, false, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)

        elseif PPG_One_Time_Update_Data.Role == "Bystander" then
            role_color = Color.AZURE
        end

        self:DrawText(text, GUI_PositionScaling(Vector2D(math.floor(Viewport.GetViewportSize().X * 0.5), 30), VZ_GUI_ANCHOR_TOP_MIDDLE), 0, GUI_TextDrawnScalingSize(14), role_color, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
end)
PPG_One_Time_Updates_Canvas:Repaint()

function PPG_UI_ShowImposterImage(duration, dark_bg)
    PPG_UI:CallEvent("ImposterImageShow", duration, dark_bg)
end

function PPG_UI_Set_Role(role)
    PPG_One_Time_Update_Data.Role = role
    PPG_One_Time_Update_Data.Pumpkins_Collected = nil
    PPG_One_Time_Update_Data.Sabotage_Cooldown = nil
    PPG_One_Time_Updates_Canvas:Repaint()
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_WaveStarted", function(round_nb)
    PPG_One_Time_Updates_Canvas:Repaint()
end)

function PPG_UI_ShowVoting(show, window_in_good_state)
    if PPG_Voting_Showed ~= show then
        PPG_Voting_Showed = show
        --Input.SetInputEnabled(not show)
        Input.SetMouseEnabled(show)

        PPG_UI:SetVisibility((show and WidgetVisibility.Visible) or WidgetVisibility.VisibleNotHitTestable)
        if show then
            PPG_UI:BringToFront()
            --PPG_UI:SetFocus()
        end

        if (not window_in_good_state) then
            PPG_UI:CallEvent("ShowVotingWrap", show)
        end
    end
end

VZ_EVENT_SUBSCRIBE_REMOTE("UpdateClientPumpkins", function(nb)
    PPG_One_Time_Update_Data.Pumpkins_Collected = nb
    PPG_One_Time_Updates_Canvas:Repaint()
end)