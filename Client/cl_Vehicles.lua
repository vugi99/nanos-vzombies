


function BuildVehiclePadUI(frame_id, pad_id)
    AddVZFrameTab(frame_id, "Vehicles", "Vehicles")

    for k, v in pairs(VZVehicles) do
        AddTabImage(frame_id, "Vehicles", v.image, "25%", "16%")
        AddTabButton(frame_id, "Vehicles", "Buy " .. k, function()
            if not pad_id then
                ShowVZFrame(frame_id, false)
                Input.SetMouseEnabled(false)
                if InteractType == "MapVPad" then
                    Events.CallRemote("BuyVehicle", InteractThing, k)
                end
            else
                Events.CallRemote("BuyVehicle", pad_id, k)
            end
        end, "Buy " .. k .. " (" .. tostring(v.price) .. "$)")
        AddTabEmptySpace(frame_id, "Vehicles", 35, true)
    end
end


if VEHICLES_PADS then
    if not WebUI3d2d then
        Console.Warn("WebUI3d2d lib not found, running in compatibility mode")
        for k, v in pairs(VEHICLES_PADS) do
            local veh_pad_screen = StaticMesh(v.location + v.rotation:GetRightVector() * 252, v.rotation, "vzombies-assets::ecran1")
        end

        VZ_EVENT_SUBSCRIBE("Events", "VZOMBIES_CLIENT_GAMEMODE_LOADED", function()
            CreateVZFrame(GUI, "Vehicle_Spawn", "65%", "65%", "Vehicle Spawn", nil, true)
            BuildVehiclePadUI("Vehicle_Spawn")
        end)
    else
        for i, v in ipairs(VEHICLES_PADS) do
            local veh_pad_screen_webui = WebUI3d2d(
                "file://"..Package.GetName().."/Client/gui/veh_pad.html",
                true,
                800,
                580,
                Vector(0.8, 0.58, 1),
                false
            )
            local sm = veh_pad_screen_webui:GetStaticMesh()
            sm:SetLocation(v.screen_location)
            sm:SetRotation(v.screen_rotation)
            veh_pad_screen_webui:AddMouseAliasKey(Input.GetMappedKeys("Interact")[1], "LeftMouseButton")
            veh_pad_screen_webui:SetKeyboardEventsEnabled(true)
            CreateVZFrame(veh_pad_screen_webui, "Vehicle_Spawn_" .. tostring(i), "100%", "100%", "Vehicle Spawn", nil, true)
            BuildVehiclePadUI("Vehicle_Spawn_" .. tostring(i), i)
            ShowVZFrame("Vehicle_Spawn_" .. tostring(i), true)
        end
    end
end


VZ_EVENT_SUBSCRIBE("Character", "EnterVehicle", function(char, veh, seat)
    local local_char = Client.GetLocalPlayer():GetControlledCharacter()
    if local_char then
        if local_char == char then
            ResetInteractState()
            if IsVZFrameOpened("Vehicle_Spawn") then
                ShowVZFrame("Vehicle_Spawn", false)
                Input.SetMouseEnabled(false)
            end
        end
    end
end)