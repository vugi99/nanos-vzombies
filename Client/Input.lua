

Input.Register("Scoreboard", "Tab")
Input.Register("SpectatePrev", "Left")
Input.Register("SpectateNext", "Right")
Input.Register("VZ Switch Weapon", "X")
Input.Register("Grenade", "A")
Input.Register("Knife", "V")
Input.Register("Lock Aim", "L")
Input.Register("How to play", "H")
Input.Register("Pause", "P")
Input.Register("Bot Order", "B")
Input.Register("Suicide", "K")
Input.Register("Ping", "F")


local PlayerCanPause
GAME_PAUSED = false

Bot_Order_Menu_Showed = false
Selected_Bot_For_Order = nil


VZ_BIND("Scoreboard", InputEvent.Pressed, function()
    if (not RequestedTabData and not Tab_Open) then
        RequestedTabData = true
        Events.CallRemote("RequestTabData")
    end
end)

VZ_BIND("Scoreboard", InputEvent.Released, function()
    if Tab_Open then
        GUI:CallEvent("HideTab")
        Tab_Open = false
    end
end)

VZ_BIND("Interact", InputEvent.Pressed, function()
    --print("Interact Called")

    if not Client.IsKeyDown("LeftAlt") then
        local ply = Client.GetLocalPlayer()
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                if ZDEV_IsModeEnabled("ZDEV_DEBUG_INTERACT") then
                    print("Interact", InteractType)
                end

                local tbl_value = switch(InteractType, {
                    MapDoor = {true, "BuyDoor"},
                    MapBarricade = function()
                        if RepairBarricadeInterval then
                            Timer.ClearInterval(RepairBarricadeInterval)
                            RepairBarricadeInterval = nil
                        end
                        PlayStartRepairBarricade()
                        RepairBarricadeInterval = Timer.SetInterval(RepairBarricadeIFunc, Repair_Barricade_Interval_ms)
                    end,
                    RevivePlayer = {false, "RevivePlayer"},
                    MapMBOX = {false, "BuyMBOX"},
                    MapPower = {false, "TurnPowerON"},
                    MapPerk = {true, "BuyPerk"},
                    MapPAP = {true, "UpgradeWeap"},
                    MapWunder = {true, "BuyWunderfizz"},
                    WunderBottle = {false, "TakeWunderfizzPerk", true}, -- CheckNoPower, event_name, check_valid
                    MapCustom = function()
                        Events.Call(InteractThing.event_name, InteractThing)
                        Events.CallRemote("CustomMapInteract", InteractThing)
                    end,
                    MapTeleporter = function()
                        if InteractThing ~= "NoPower" then
                            if InteractThing:IsValid() then
                                if InteractThing:GetValue("CanTeleport") then
                                    Events.CallRemote("BuyTeleport", InteractThing)
                                end
                            end
                        end
                    end,
                    Gib = function()
                        if InteractThing:IsValid() then
                            Events.CallRemote("PickupGib", InteractThing:GetValue("GibData"))
                            InteractThing:Destroy()
                        end
                    end
                })
                if tbl_value then
                    if type(tbl_value) == "function" then
                        tbl_value()
                    else
                        InteractAction(table.unpack(tbl_value))
                    end
                end
            end
        end
    else
        local local_char = Client.GetLocalPlayer():GetControlledCharacter()
        if local_char then
            local found = false

            for k, v in pairs(Character.GetPairs()) do
                if v:IsValid() then
                    local ply = v:GetPlayer()
                    if (ply and ply.BOT) then
                        if (not v:IsInRagdollMode() and not v:GetValue("PlayerDown")) then
                            local project = Client.ProjectWorldToScreen(v:GetLocation())
                            if (project and project ~= Vector2D(-1, -1)) then

                                local dist_sq = local_char:GetLocation():DistanceSquared(v:GetLocation())
                                if dist_sq <= Bot_Select_At_Distance_sq then
                                    if (Selected_Bot_For_Order and Selected_Bot_For_Order:IsValid()) then
                                        Selected_Bot_For_Order:SetOutlineEnabled(false, 0)
                                        --print("Disable select outline")
                                    end
                                    EnableCharOutline(v, false)
                                    Selected_Bot_For_Order = v
                                    v:SetOutlineEnabled(true, 0)
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                end
            end

            if not found then
                if Selected_Bot_For_Order then
                    if Selected_Bot_For_Order:IsValid() then
                        Selected_Bot_For_Order:SetOutlineEnabled(false, 0)
                    end
                    Selected_Bot_For_Order = nil
                end
            end
        end
    end
end)

VZ_BIND("Interact", InputEvent.Released, function()
    if InteractType == "MapBarricade" then
        if RepairBarricadeInterval then
            Timer.ClearInterval(RepairBarricadeInterval)
            RepairBarricadeInterval = nil
        end
    elseif (InteractType == "RevivePlayer" and RevivingPlayerData) then
        Timer.ClearTimeout(RevivingPlayerData.timeout)
        GUIStopRevive()
        Events.CallRemote("RevivePlayerStopped", RevivingPlayerData.char)
        RevivingPlayerData = nil
    end
end)


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





VZ_BIND("VZ Switch Weapon", InputEvent.Pressed, function()
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        Events.CallRemote("VZ_Switch_Weapon")
    end
end)





VZ_BIND("Grenade", InputEvent.Pressed, function()
    --print("Grenade Pressed")
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            if not char:IsInRagdollMode() then
                local grenades = char:GetValue("ZGrenadesNB")
                if (grenades and grenades > 0) then
                    if (not char:GetPicked() or not NanosUtils.IsA(char:GetPicked(), Grenade)) then
                        Events.CallRemote("PickupGrenade")
                    end
                end
            end
        end
    end
end)

VZ_BIND("Grenade", InputEvent.Released, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if (char:GetPicked() and NanosUtils.IsA(char:GetPicked(), Grenade)) then
            Events.CallRemote("ThrowGrenade")
        end
    end
end)


VZ_BIND("Knife", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            if char:GetValue("CanUseKnife") then
                Events.CallRemote("UseKnife")
            end
        end
    end
end)


VZ_BIND("Lock Aim", InputEvent.Pressed, function()
    Events.CallRemote("ToggleLockAim")
end)


VZ_BIND("How to play", InputEvent.Pressed, function()
    HTP_Showed = not HTP_Showed
    Client.SetMouseEnabled(HTP_Showed)
    if not GAME_PAUSED then
        Client.SetInputEnabled(not HTP_Showed)
    end
    if HTP_Showed then
        GUI:CallEvent("ShowHTPFrame")
        GUI:BringToFront()
        --GUI:SetFocus()
    else
        GUI:CallEvent("HideHTPFrame")
    end
end)


VZ_EVENT_SUBSCRIBE("Events", "PlayerCanPause", function(can_pause)
    PlayerCanPause = can_pause
end)

VZ_BIND("Pause", InputEvent.Pressed, function()
    if PlayerCanPause then
        Events.CallRemote("TogglePauseGame")
    end
end)


VZ_EVENT_SUBSCRIBE("Events", "ClientPauseGame", function(pause_game)
    GAME_PAUSED = pause_game
    if GAME_PAUSED then
        Client.SetInputEnabled(false)
    else
        Client.SetInputEnabled(not HTP_Showed)
    end
    One_Time_Updates_Canvas:Repaint()
end)

VZ_BIND("Bot Order", InputEvent.Pressed, function()
    if ((not Bot_Order_Menu_Showed and Selected_Bot_For_Order and Selected_Bot_For_Order:IsValid() and not Selected_Bot_For_Order:GetValue("PlayerDown") and not Selected_Bot_For_Order:IsInRagdollMode()) or Bot_Order_Menu_Showed) then
        Bot_Order_Menu_Showed = not Bot_Order_Menu_Showed
        if not GAME_PAUSED then
            Client.SetMouseEnabled(Bot_Order_Menu_Showed)
            --Client.SetInputEnabled(not Bot_Order_Menu_Showed)

            if Bot_Order_Menu_Showed then
                GUI:CallEvent("ShowBotOrderWheel", table_count(Bots_Orders))
                GUI:BringToFront()
                --GUI:SetFocus()
            else
                GUI:CallEvent("HideBotOrderWheel")
            end
        end
    end
end)

VZ_ENT_EVENT_SUBSCRIBE(GUI, "BotOrderSelect", function(order_index)
    order_index = order_index + 1
    --print(Bots_Orders[order_index])
    Bot_Order_Menu_Showed = false
    Client.SetMouseEnabled(Bot_Order_Menu_Showed)
    GUI:CallEvent("HideBotOrderWheel")

    local order = Bots_Orders[order_index]
    BotOrder(Selected_Bot_For_Order, order)
    if Selected_Bot_For_Order:IsValid() then
        Selected_Bot_For_Order:SetOutlineEnabled(false, 0)
    end
    Selected_Bot_For_Order = nil
end)

VZ_BIND("Suicide", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        if not char:GetValue("PlayerDown") then
            Events.CallRemote("ServerSuicide")
        end
    end
end)

if Ping_Enabled then
    VZ_BIND("Ping", InputEvent.Pressed, function()
        local ply = Client.GetLocalPlayer()
        local char = ply:GetControlledCharacter()
        if char then
            if not char:GetValue("PlayerDown") then
                local cam_rot = ply:GetCameraRotation()
                local forward = cam_rot:GetForwardVector()

                local trace_mode = TraceMode.ReturnEntity
                if ZDEV_IsModeEnabled("ZDEV_DEBUG_TRACES") then
                    trace_mode = trace_mode | TraceMode.DrawDebug
                end

                local trace = Client.TraceLineSingle(char:GetBoneTransform("head").Location, char:GetBoneTransform("head").Location + forward * Ping_Max_Distance, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.Pawn | CollisionChannel.PhysicsBody, trace_mode, {char})
                if trace.Success then
                    if trace.Entity then
                        if trace.Entity:GetID() > 0 then -- Check if serverside entity
                            Events.CallRemote("ServerPing", trace.Location, trace.Entity)
                        else
                            Events.CallRemote("ServerPing", trace.Location)
                        end
                    else
                        Events.CallRemote("ServerPing", trace.Location)
                    end
                end
            end
        end
    end)
end