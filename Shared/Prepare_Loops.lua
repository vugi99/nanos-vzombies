

PreparedLoops = {}

function RegisterPreparedLoop(key, class, looking_for_value)
    if PreparedLoops[key] then
        error("Key " .. tostring(key) .. " already exists in PreparedLoops table")
    end
    PreparedLoops[key] = {}
    if ZDEV_IsModeEnabled("ZDEV_DEBUG_PREPARED_LOOPS") then
        print("PLoops Init", key, class, looking_for_value)
    end
    for k, v in pairs(class.GetPairs()) do
        if v:GetValue(looking_for_value) then
            PreparedLoops[key][v] = v
            if ZDEV_IsModeEnabled("ZDEV_DEBUG_PREPARED_LOOPS") then
                print("PLoops", key, "GetPairs", v)
            end
        end
    end

    class.Subscribe("Spawn", function(self)
        if self:GetValue(looking_for_value) then
            if not PreparedLoops[key][self] then
                PreparedLoops[key][self] = self
                if ZDEV_IsModeEnabled("ZDEV_DEBUG_PREPARED_LOOPS") then
                    print("PLoops", key, "Spawn", self)
                end
            end
        end
    end)

    class.Subscribe("ValueChange", function(self, key_v_change, value)
        if key_v_change == looking_for_value then
            if not PreparedLoops[key][self] then
                PreparedLoops[key][self] = self
                if ZDEV_IsModeEnabled("ZDEV_DEBUG_PREPARED_LOOPS") then
                    print("PLoops", key, "ValueChange", self)
                end
            end
        end
    end)

    class.Subscribe("Destroy", function(self)
        if PreparedLoops[key][self] then
            PreparedLoops[key][self] = nil
            if ZDEV_IsModeEnabled("ZDEV_DEBUG_PREPARED_LOOPS") then
                print("PLoops", key, "Destroy", self)
            end
        end
    end)
end