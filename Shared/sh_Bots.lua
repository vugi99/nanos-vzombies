
Bots_ID = 0

VZBot = {}
VZBot.__index = VZBot
VZBot.prototype = {}
VZBot.prototype.__index = VZBot.prototype
VZBot.prototype.constructor = VZBot

ALL_BOTS = {}

Sub_Callbacks = {
    ValueChange = {},
}

function VZBot.Subscribe(event_name, callback)
    local t_l_c = table_last_count(Sub_Callbacks[event_name])
    Sub_Callbacks[event_name][t_l_c + 1] = callback
    return Sub_Callbacks[event_name][t_l_c + 1]
end

function VZBot.Unsubscribe(event_name, callback)
    if callback then
        for k, v in pairs(Sub_Callbacks[event_name]) do
            if v == callback then
                Sub_Callbacks[event_name][k] = nil
                return true
            end
        end
    else
        Sub_Callbacks[event_name] = {}
        return true
    end
    return false
end

function VZBot.GetPairs()
    local tbl = {}
    for k, v in pairs(ALL_BOTS) do
        if v:IsValid() then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function VZBot.prototype:IsValid(is_from_self)
    local valid = self.Valid
    if (not valid and is_from_self) then
        Package.Err() -- Throw real error
    end
    return valid
end

function VZBot.prototype:GetControlledCharacter()
    if self:IsValid(true) then
        return self.Stored.Possessed
    end
end

function VZBot.prototype:GetPing()
    if self:IsValid(true) then
        return 0
    end
end

function VZBot.prototype:GetValue(key)
    if self:IsValid(true) then
        if self.Stored.Values[key] then
            return self.Stored.Values[key]
        else
            return self.Stored.SyncedValues[key]
        end
    end
end

function VZBot.prototype:__eq(other)
    if other.ID then
        if other.ID == self.ID then
            return true
        end
    end
    return false
end

function VZBot.prototype:GetID()
    if self:IsValid(true) then
        return self.Stored.NanosID
    end
end

function VZBot.prototype:GetSteamID()
    if self:IsValid(true) then
        return tostring(self.ID)
    end
end

function VZBot.prototype:GetAccountName()
    if self:IsValid(true) then
        return self.Stored.Name
    end
end

function Character:GetPlayer()
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            local possessed = v.Stored.Possessed
            if possessed then
                if possessed == self then
                    return v
                end
            end
        end
    end

    return self:Super()
end

function Player.GetPairs()
    local def = Player.GetAll()
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            table.insert(def, v)
        end
    end

    return def
end

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    for k, v in pairs(ALL_BOTS) do
        if v.Valid then
            if v.Stored.Possessed then
                if v.Stored.Possessed == char then
                    v.Stored.Possessed = nil
                end
            end
        end
    end
end)