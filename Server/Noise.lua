
VZ_Noise = {}
Package.Export("VZ_Noise", VZ_Noise)

VZ_Noise.ListeningEntities = {}
VZ_Noise.NoiseEvents = {}
VZ_Noise.InstigatorValues = {}
VZ_Noise.Instigator_LoopingNoises_Intervals = {}


function VZ_Noise.CanInstigatorMakeNoise(instigator)
    if not IsValid(instigator) then return false end
    --if not instigator:IsA(Player) then return false end
    if not instigator.GetControlledCharacter then return false end
    local char = instigator:GetControlledCharacter()
    if not IsValid(char) then return false end
    if char:GetValue("PlayerDown") then return false end
    return true
end

-- New entity listening to Noise system
-- Has a treshold which will be the limit when threshold callback is called with the instigator
-- reduce_interval_ms is time where the current amount of an instigator awareness is lowered (if it did not add awareness during reduce_interval_ms)
-- reduce_amount is the amount deduced when no sound is head from an instigator
-- hear_noise_callback will be called when a noise is heard
function VZ_Noise.NewListeningEntity(ent, threshold, threshold_callback, reduce_interval_ms, reduce_amount, hear_noise_callback)
    if not IsValid(ent) then return error("NewListeningEntity expects a valid entity") end
    if threshold < 0 then return error("Positive threshold expected") end
    if type(threshold_callback) ~= "function" then return error("threshold_callback function expected") end
    if reduce_interval_ms < 0 then return error("Positive reduce_interval_ms expected") end
    if reduce_amount < 0 then return error("Positive reduce_amount expected") end

    VZ_Noise.ListeningEntities[ent] = {
        Config = {
            threshold = threshold,
            threshold_callback = threshold_callback,
            reduce_interval_ms = reduce_interval_ms,
            reduce_amount = reduce_amount,
            hear_noise_callback = hear_noise_callback,
        },
        Current_Awarenesses = {},
        Reduce_Intervals = {},
    }

    if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
        print("NewListeningEntity " .. tostring(ent))
    end

    return true
end

function VZ_Noise.RemoveListeningEntity(ent)
    if VZ_Noise.ListeningEntities[ent] then
        if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
            print("RemoveListeningEntity " .. tostring(ent))
        end
    end
    VZ_Noise.ListeningEntities[ent] = nil
    return true
end


function VZ_Noise.HearNoise(instigator, ent, amount)
    local instigator_values = VZ_Noise.InstigatorValues[instigator]
    if instigator_values then
        if instigator_values.Noise_Multiplier then
            if instigator_values.Noise_Multiplier ~= 1 then
                local old_amount = amount
                amount = amount*instigator_values.Noise_Multiplier

                if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
                    print(ent, "HearNoise of " .. tostring(instigator) .. " amount changed from " .. tostring(old_amount) .. " to " .. tostring(amount) .. " with multiplier " .. string.format("%.2f", instigator_values.Noise_Multiplier))
                end
            end
        end
    end

    if amount < 0 then return false end

    local ent_listening = VZ_Noise.ListeningEntities[ent]
    if not ent_listening then return false end
    ent_listening.Current_Awarenesses[instigator] = clamp((ent_listening.Current_Awarenesses[instigator] or 0) + amount, 0, ent_listening.Config.threshold)

    if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
        print(ent, "HearNoise of " .. tostring(instigator) .. " with amount: " .. tostring(amount) .. ", new instig awareness: " .. tostring(ent_listening.Current_Awarenesses[instigator]))
    end

    if type(ent_listening.Config.hear_noise_callback) then
        ent_listening.Config.hear_noise_callback(ent, instigator, ent_listening.Current_Awarenesses[instigator], amount)
    end

    if ent_listening.Current_Awarenesses[instigator] >= ent_listening.Config.threshold then
        ent_listening.Config.threshold_callback(ent, instigator)
    end

    if ent_listening.Reduce_Intervals[instigator] and Timer.IsValid(ent_listening.Reduce_Intervals[instigator]) then
        Timer.ResetElapsedTime(ent_listening.Reduce_Intervals[instigator])
    else
        ent_listening.Reduce_Intervals[instigator] = Timer.SetInterval(function()
            if not IsValid(instigator) then return end
            local ri_ent_listening = VZ_Noise.ListeningEntities[ent]
            if not ri_ent_listening then return end
            if not ri_ent_listening.Current_Awarenesses[instigator] then return end
            ri_ent_listening.Current_Awarenesses[instigator] = clamp(ri_ent_listening.Current_Awarenesses[instigator] - ri_ent_listening.Config.reduce_amount, 0, ri_ent_listening.Config.threshold)

            if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
                print(ent, "Reduce Awareness of " .. tostring(instigator:GetAccountName()) .. " to : " .. tostring(ri_ent_listening.Current_Awarenesses[instigator]))
            end

            if ri_ent_listening.Current_Awarenesses[instigator] <= 0 then
                if ri_ent_listening.Reduce_Intervals[instigator] and Timer.IsValid(ri_ent_listening.Reduce_Intervals[instigator]) then
                    Timer.ClearInterval(ri_ent_listening.Reduce_Intervals[instigator])
                    ri_ent_listening.Reduce_Intervals[instigator] = nil

                    if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
                        print(ent, "Reduce Awareness of " .. tostring(instigator:GetAccountName()) .. " Interval cleared")
                    end
                else
                    error("Reduce Interval Callback: stored Listening Reduce Interval Invalid")
                end
            end
        end, ent_listening.Config.reduce_interval_ms)
        --Timer.Bind(ent_listening.Reduce_Intervals[instigator], instigator)
        Timer.Bind(ent_listening.Reduce_Intervals[instigator], ent)
    end

    return true
end

function VZ_Noise.MakeNoise(name, noise, instigator)
    if type(noise) ~= "table" then return error("MakeNoise noise is not a table") end
    if not VZ_Noise.CanInstigatorMakeNoise(instigator) then return end

    if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
        --print("MakeNoise '" .. tostring(name) .. "' instigator: " .. tostring(instigator:GetAccountName()))
    end

    local Amount = noise.Amount
    local Radius = noise.Radius
    local Falloff = noise.Falloff
    local Falloff_Func = noise.Falloff_Func

    local char = instigator:GetControlledCharacter()
    local char_loc = char:GetLocation()

    local marked_deletion = {}

    for ent, v in pairs(VZ_Noise.ListeningEntities) do
        if IsValid(ent) then
            local ent_loc = ent:GetLocation()
            local dist_sq = char_loc:DistanceSquared(ent_loc)
            if dist_sq <= noise.Radius^2 then
                VZ_Noise.HearNoise(instigator, ent, Amount)
            elseif dist_sq <= noise.Falloff^2 then
                local dist = math.sqrt(dist_sq)
                local dist_m_rad = dist - Radius
                local falloff_m_rad = Falloff - Radius
                local fact = clamp(Falloff_Func(dist_m_rad, falloff_m_rad), 0, 1)

                VZ_Noise.HearNoise(instigator, ent, Amount*fact)
            end
        else
            marked_deletion[ent] = true
        end
    end

    for ent, _ in pairs(marked_deletion) do
        VZ_Noise.RemoveListeningEntity(ent)
    end

    return true
end

function VZ_Noise.MakeLoopingNoise(name, noise_conf, instigator)
    if type(noise_conf) ~= "table" then return error("MakeLoopingNoise noise_conf is not a table") end

    noise_conf = noise_conf.LoopingNoise

    if not noise_conf then return error("MakeLoopingNoise Missing LoopingNoise in noisee_entry with name: " .. tostring(name)) end
    if not noise_conf.Noise then return error("MakeLoopingNoise No Noise inside LoopingNoise table with name: " .. tostring(name)) end
    if not noise_conf.Interval_ms then return error("MakeLoopingNoise Missing Interval_ms in LoopingNoise table with name: " .. tostring(name)) end
    if not IsValid(instigator) then return error("MakeLoopingNoise instigator is not Valid") end

    VZ_Noise.MakeNoise(name, noise_conf.Noise, instigator)

    local looping_noise_intervals = VZ_Noise.Instigator_LoopingNoises_Intervals[instigator]
    if not looping_noise_intervals then
        looping_noise_intervals = {}
        VZ_Noise.Instigator_LoopingNoises_Intervals[instigator] = looping_noise_intervals
    end

    if looping_noise_intervals[name] and Timer.IsValid(looping_noise_intervals[name]) then
        Timer.ClearInterval(looping_noise_intervals[name])
    end
    looping_noise_intervals[name] = Timer.SetInterval(function()
        if not IsValid(instigator) then return end
        VZ_Noise.MakeNoise(name, noise_conf.Noise, instigator)
    end, noise_conf.Interval_ms)
    --Timer.Bind(looping_noise_intervals[name], instigator)

    if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
        --print("MakeLoopingNoise '" .. tostring(name) .. "' with instigator: " .. tostring(instigator:GetAccountName()))
    end

    return true
end

function VZ_Noise.DoNoiseEvent(name, noise_conf, instigator)
    if type(noise_conf) ~= "table" then return error("DoNoiseEvent noise_conf is not a table") end

    if noise_conf.Noise then
        VZ_Noise.MakeNoise(name, noise_conf.Noise, instigator)
    end

    if noise_conf.LoopingNoise then
        VZ_Noise.MakeLoopingNoise(name, noise_conf, instigator)
    end

    if noise_conf.Set_Instigator_Values then
        if not VZ_Noise.InstigatorValues[instigator] then
            VZ_Noise.InstigatorValues[instigator] = {}
        end
        for k, v in pairs(noise_conf.Set_Instigator_Values) do
            VZ_Noise.InstigatorValues[instigator][k] = v
        end

        if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
            print("DoNoiseEvent '" .. tostring(name) .. "' of " .. tostring(instigator:GetAccountName()) ..  " Set_Instigator_Values: " .. tostring(NanosTable.Dump(VZ_Noise.InstigatorValues[instigator])))
        end
    end

    return true
end

function VZ_Noise.GetEventInstigator(noise_conf, args)
    local instigator
    if noise_conf.instigator_arg_index then
        instigator = args[noise_conf.instigator_arg_index]
    elseif noise_conf.causer_arg_index then
        local causer = args[noise_conf.causer_arg_index]
        if IsValid(causer) then
            if causer.GetPlayer then
                instigator = causer:GetPlayer()
            end
        end
    end

    return instigator
end

function VZ_Noise.IsNoiseEventTriggered(noise_conf, args)
    local conf_override = nil

    if noise_conf.new_value_index then
        if noise_conf.expected_new_value ~= nil then
            if noise_conf.expected_new_value ~= args[noise_conf.new_value_index] then return end
        end

        if noise_conf.expected_not_new_value ~= nil then
            if noise_conf.expected_not_new_value == args[noise_conf.new_value_index] then return end
        end

        if type(noise_conf.new_value_tables) == "table" then
            local val = args[noise_conf.new_value_index]
            if noise_conf.new_value_tables[val] ~= nil then
                return true, noise_conf.new_value_tables[val]
            end
        end
    end

    return true, conf_override
end

function VZ_Noise.MakeNoiseEventCallback(name)
    return function(...)
        local noisee_entry = VZ_Noise.NoiseEvents[name]
        if not noisee_entry then return end
        local noise_conf = noisee_entry.Config
        if not noise_conf then return end

        local args = table.pack(...)

        local instigator = VZ_Noise.GetEventInstigator(noise_conf, args)
        if not instigator then return end

        local is_triggered, conf_override = VZ_Noise.IsNoiseEventTriggered(noise_conf, args)
        if conf_override ~= nil then
            noise_conf = conf_override
        end
        if not is_triggered then
            if noise_conf.LoopingNoise then
                if noise_conf.LoopingNoise.Stop then
                    local looping_noise_intervals = VZ_Noise.Instigator_LoopingNoises_Intervals[instigator]
                    if looping_noise_intervals and looping_noise_intervals[name] and Timer.IsValid(looping_noise_intervals[name]) then
                        Timer.ClearInterval(looping_noise_intervals[name])
                        looping_noise_intervals[name] = nil

                        VZ_Noise.Instigator_LoopingNoises_Intervals[instigator] = looping_noise_intervals

                        if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
                            --print("Noise Event Callback '" .. tostring(name) .. "' cleared looping noise on : " .. tostring(instigator:GetAccountName()))
                        end
                    end
                end
            end

            return
        end

        if not VZ_Noise.CanInstigatorMakeNoise(instigator) then return end

        VZ_Noise.DoNoiseEvent(name, noise_conf, instigator)
    end
end

function VZ_Noise.AddNoiseEvent(name, v)
    if type(v) ~= "table" then return error("Cannot AddNoiseEvent without a config table, got: " .. tostring(v)) end
    if not VZ_Noise.NoiseEvents[name] then
        VZ_Noise.NoiseEvents[name] = {
            Config = v,
        }

        if v.classname and v.name then
            VZ_Noise.NoiseEvents[name].event_callbacks = {
                main = VZ_EVENT_SUBSCRIBE(v.classname, v.name, VZ_Noise.MakeNoiseEventCallback(name))
            }

            if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
                --print("Registered '" .. tostring(name) .. "' Noise Event " .. NanosTable.Dump(VZ_Noise.NoiseEvents[name]))
            end

            return true
        else
            return error(name .. " noise event doesn't have classname and name")
        end
    else
        warn("Trying to add " .. name .. " noise event but it already exists")
    end
    return false
end

function VZ_Noise.AddNoiseEvents(events)
    local good = true
    for k, v in pairs(events) do
        good = VZ_Noise.AddNoiseEvent(k, v) and good
    end
    return good
end
VZ_Noise.AddNoiseEvents(Noise_Config.Events)

function VZ_Noise.RemoveNoiseEvent(name)
    if VZ_Noise.NoiseEvents[name].event_callbacks then
        for _, v in pairs(VZ_Noise.NoiseEvents[name].event_callbacks) do
            VZ_EVENT_UNSUBSCRIBE(VZ_Noise.NoiseEvents[name].Config.classname, VZ_Noise.NoiseEvents[name].Config.name, v)
        end
    end
    VZ_Noise.NoiseEvents[name] = nil

    if ZDEV_IsModeEnabled("ZDEV_DEBUG_NOISE") then
        print("RemoveNoiseEvent " .. tostring(name))
    end

    return true
end


function VZ_Noise.ResetListeningAwarenessAboutInstigator(instigator)
    if not IsValid(instigator) then return end
    for k, v in pairs(VZ_Noise.ListeningEntities) do
        v.Current_Awarenesses[instigator] = nil
    end
    return true
end


function VZ_Noise.ClearLoopingNoiseIntervals(ply)
    if not IsValid(ply) then return end
    local looping_noise_intervals = VZ_Noise.Instigator_LoopingNoises_Intervals[ply]
    for name, v in pairs(looping_noise_intervals or {}) do
        if Timer.IsValid(v) then
            Timer.ClearInterval(v)
        end
    end
    VZ_Noise.Instigator_LoopingNoises_Intervals[ply] = nil
end

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    local ply = char:GetPlayer()
    if IsValid(ply) then
        VZ_Noise.ResetListeningAwarenessAboutInstigator(ply)
        VZ_Noise.InstigatorValues[ply] = nil
        VZ_Noise.ClearLoopingNoiseIntervals(ply)
    end
end)

VZ_EVENT_SUBSCRIBE("Package", "Unload", function()
    for _, v in pairs(Player.GetPairs()) do
        VZ_Noise.ClearLoopingNoiseIntervals(v)
    end
end)