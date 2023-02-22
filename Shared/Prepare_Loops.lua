

PreparedLoops = {}

function RegisterPreparedLoop(key, class, looking_for_value)
    PreparedLoops[key] = {}
    for k, v in pairs(class.GetPairs()) do
        if v:GetValue(looking_for_value) then
            PreparedLoops[key][v] = v
        end
    end

    class.Subscribe("Spawn", function(self)
        if self:GetValue(looking_for_value) then
            if not PreparedLoops[key][self] then
                PreparedLoops[key][self] = self
            end
        end
    end)

    class.Subscribe("ValueChange", function(self, key_v_change, value)
        if key_v_change == looking_for_value then
            if not PreparedLoops[key][self] then
                PreparedLoops[key][self] = self
            end
        end
    end)

    class.Subscribe("Destroy", function(self)
        if PreparedLoops[key][self] then
            PreparedLoops[key][self] = nil
        end
    end)
end