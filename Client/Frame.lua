


VZFrames = {}

function CreateVZFrame(webui, frame_id, width, height, header_text, bind_name, main_frame)
    --Package.Log("CreateVZFrame " .. frame_id .. ", " .. tostring(width) .. ", " .. tostring(height) .. ", " .. tostring(header_text) .. ", " .. tostring(bind_name) .. ", " .. tostring(main_frame))

    webui:CallEvent("CreateVZFrame", frame_id, width, height, header_text)

    VZFrames[frame_id] = {
        Open = false,
        main_frame = main_frame,
        _saved_event_names = {},
        webui = webui,
    }

    if bind_name then
        VZ_BIND(bind_name, InputEvent.Pressed, function()
            if not GAME_PAUSED then
                --print("Open Frame", frame_id, bind_name)
                ShowVZFrame(frame_id, not VZFrames[frame_id].Open)

                if VZFrames[frame_id].Open then

                    for k, v in pairs(VZFrames) do
                        if k ~= frame_id then
                            if v.main_frame then
                                if v.webui == webui then
                                    if v.Open then
                                        ShowVZFrame(k, false)
                                    end
                                end
                            end
                        end
                    end

                    --webui:BringToFront()
                    --webui:SetFocus()
                end
                if main_frame then
                    Input.SetMouseEnabled(VZFrames[frame_id].Open)
                else
                    Input.SetMouseEnabled(false)
                end
            end
        end)

        if not main_frame then
            VZ_BIND(bind_name, InputEvent.Released, function()
                ShowVZFrame(frame_id, false)
            end)
        end
    end

    return webui
end
Package.Export("CreateVZFrame", CreateVZFrame)

function ShowVZFrame(frame_id, show)
    if show ~= VZFrames[frame_id].Open then
        VZFrames[frame_id].Open = show
        VZFrames[frame_id].webui:CallEvent("ShowVZFrame", frame_id, show)
    end
end
Package.Export("ShowVZFrame", ShowVZFrame)

function IsVZFrameOpened(frame_id)
    if VZFrames[frame_id] then
        return VZFrames[frame_id].Open
    end
end
Package.Export("IsVZFrameOpened", IsVZFrameOpened)

function AddVZFrameTab(frame_id, tab_id, tab_name)
    VZFrames[frame_id].webui:CallEvent("AddVZFrameTab", frame_id, tab_id, tab_name)
    return VZFrames[frame_id].webui
end
Package.Export("AddVZFrameTab", AddVZFrameTab)

function RetrieveSavedOrGetStored(frame_id, event_name, default)
    local d_key = event_name
    local data = Package.GetPersistentData(d_key)

    --print(event_name)

    table.insert(VZFrames[frame_id]._saved_event_names, event_name)

    --print(data)

    if (data ~= nil) then
        return data
    else
        Package.SetPersistentData(d_key, default)
        return default
    end
end

function ResetVZFrameSaved(frame_id)
    if VZFrames[frame_id] then
        for i, v in ipairs(VZFrames[frame_id]._saved_event_names) do
            --print(v)
            Package.SetPersistentData(v, nil)
        end
    end
end
Package.Export("ResetVZFrameSaved", ResetVZFrameSaved)

function ClearVZFrameTab(frame_id, tab_id)
    if VZFrames[frame_id] then
        VZFrames[frame_id].webui:CallEvent("ClearFrameTab", frame_id, tab_id)
    end
end
Package.Export("ClearVZFrameTab", ClearVZFrameTab)

function AddTabCheckbox(frame_id, tab_id, item_name, func, checked, saved)
    local event_name = frame_id .. "_-" .. tab_id .. "_-" .. ReplaceLetterInString(item_name, " ", "_-")

    if saved then
        --print(item_name, event_name)
        checked = RetrieveSavedOrGetStored(frame_id, event_name, checked)
    end

    VZFrames[frame_id].webui:CallEvent("AddTabCheckbox", frame_id, tab_id, item_name, event_name, checked)

    VZFrames[frame_id].webui:Subscribe(event_name, function(...)
        if saved then
            local tbl = {...}
            --print(tbl[1])
            if (tbl[1] ~= nil) then
                Package.SetPersistentData(event_name, tbl[1])
            end
        end
        func(...)
    end)

    return checked
end
Package.Export("AddTabCheckbox", AddTabCheckbox)

function AddTabTextInput(frame_id, tab_id, item_name, func, placeholder, saved)
    local event_name = frame_id .. "_-" .. tab_id .. "_-" .. ReplaceLetterInString(item_name, " ", "_-")

    local value = ""
    if saved then
        value = RetrieveSavedOrGetStored(frame_id, event_name, "")
    end

    VZFrames[frame_id].webui:CallEvent("AddTabTextInput", frame_id, tab_id, item_name, event_name, placeholder, value)

    VZFrames[frame_id].webui:Subscribe(event_name, function(...)
        if saved then
            local tbl = {...}
            if (tbl[1] ~= nil) then
                Package.SetPersistentData(event_name, tbl[1])
            end
        end
        func(...)
    end)

    return value
end
Package.Export("AddTabTextInput", AddTabTextInput)

function AddTabSelect(frame_id, tab_id, item_name, func, options, selected_option, saved)
    local event_name = frame_id .. "_-" .. tab_id .. "_-" .. ReplaceLetterInString(item_name, " ", "_-")

    if saved then
        selected_option = RetrieveSavedOrGetStored(frame_id, event_name, selected_option)
    end

    VZFrames[frame_id].webui:CallEvent("AddTabSelect", frame_id, tab_id, item_name, event_name, options, selected_option)

    VZFrames[frame_id].webui:Subscribe(event_name, function(...)
        if saved then
            local tbl = {...}
            if (tbl[1] ~= nil) then
                Package.SetPersistentData(event_name, tbl[1])
            end
        end
        func(...)
    end)

    return selected_option
end
Package.Export("AddTabSelect", AddTabSelect)

function AddTabButton(frame_id, tab_id, item_name, func, button_text)
    local event_name = frame_id .. "_-" .. tab_id .. "_-" .. ReplaceLetterInString(item_name, " ", "_-")

    VZFrames[frame_id].webui:CallEvent("AddTabButton", frame_id, tab_id, item_name, event_name, button_text)

    VZFrames[frame_id].webui:Subscribe(event_name, func)
end
Package.Export("AddTabButton", AddTabButton)

function AddTabText(frame_id, tab_id, text, bottom_disabled)
    VZFrames[frame_id].webui:CallEvent("AddTabText", frame_id, tab_id, text, bottom_disabled)
end
Package.Export("AddTabText", AddTabText)

function AddTabImage(frame_id, tab_id, image, width, height)
    VZFrames[frame_id].webui:CallEvent("AddTabImage", frame_id, tab_id, image, width, height)
end
Package.Export("AddTabImage", AddTabImage)