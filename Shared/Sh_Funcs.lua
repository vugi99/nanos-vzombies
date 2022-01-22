

function table_count(ta)
    local count = 0
    for k, v in pairs(ta) do count = count + 1 end
    return count
end

function table_last_count(ta)
    local count = 0
    for i, v in ipairs(ta) do
        if v then
            count = count + 1
        end
    end
    return count
end

function GetCharacterFromId(id)
    for k, v in pairs(Character.GetPairs()) do
        if v:GetID() == id then
            return v
        end
    end
end

function RelRot1(r, r2)
    local val = r2 - r
    if val > 180 then
       val = -180 + (val - 180)
    elseif val < -180 then
       val = 180 + (val + 180)
    end
    return val
end

function split_str(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function VZ_RandomSound(random_sound_tbl)
    local random_s_id = math.random(random_sound_tbl.random_start, random_sound_tbl.random_to)
    local random_s_id_str = tostring(random_s_id)
    if random_sound_tbl.always_digits then
        if string.len(random_s_id_str) ~= random_sound_tbl.always_digits then
            local add_x_0 = ""
            for i = 1, random_sound_tbl.always_digits - string.len(random_s_id_str) do
                add_x_0 = add_x_0 .. "0"
            end
            random_s_id_str = add_x_0 .. random_s_id_str
        end
    end
    return random_sound_tbl.base_ref .. random_s_id_str
end

if VZ_SUBSCRIBED_EVENTS then
    for i, v in ipairs(VZ_SUBSCRIBED_EVENTS) do
        _ENV[v.class].Subscribe(table.unpack(v.params))
    end
else
    VZ_SUBSCRIBED_EVENTS = {}
end

function VZ_EVENT_SUBSCRIBE(class, ...)
    table.insert(VZ_SUBSCRIBED_EVENTS, {class = class, params = {...}})
    return _ENV[class].Subscribe(...)
end



if VZ_SUBSCRIBED_ENT_EVENTS then
    for i, v in ipairs(VZ_SUBSCRIBED_ENT_EVENTS) do
        v.ent:Subscribe(table.unpack(v.params))
    end
else
    VZ_SUBSCRIBED_ENT_EVENTS = {}
end

function VZ_ENT_EVENT_SUBSCRIBE(ent, ...)
    table.insert(VZ_SUBSCRIBED_ENT_EVENTS, {ent = ent, params = {...}})
    return ent:Subscribe(...)
end

function GetENV_Value(key)
    if _ENV[key] then
        return _ENV[key]
    end
end
Package.Export("GetENV_Value", GetENV_Value)

function SetENV_Value(key, value)
    if key then
        _ENV[key] = value
        return true
    end
end
Package.Export("SetENV_Value", SetENV_Value)

function ZDEV_IsModeEnabled(mode)
    if ZDEV_CONFIG.ENABLED then
        return ZDEV_CONFIG.DEV_CHEAT_MODES[mode]
    else
        return false
    end
end