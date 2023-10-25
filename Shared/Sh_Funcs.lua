

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

function clamp(val, minval, maxval, valadded)
    if val + valadded <= maxval then
        if val + valadded >= minval then
            val = val + valadded
        else
            val = minval
        end
    else
        val = maxval
    end
    return val
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
    if random_sound_tbl.base_ref then
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
    elseif random_sound_tbl.unique_sound then
        return random_sound_tbl.unique_sound
    end
end

if VZ_SUBSCRIBED_EVENTS then
    for i, v in ipairs(VZ_SUBSCRIBED_EVENTS) do
        _ENV[v.class].Subscribe(table.unpack(v.params))
    end
    for i, v in ipairs(VZ_REMOTE_SUBSCRIBED_EVENTS) do
        Events.SubscribeRemote(table.unpack(v.params))
    end
else
    VZ_SUBSCRIBED_EVENTS = {}
    VZ_REMOTE_SUBSCRIBED_EVENTS = {}
end

function VZ_EVENT_SUBSCRIBE(class, ...)
    table.insert(VZ_SUBSCRIBED_EVENTS, {class = class, params = {...}})
    return _ENV[class].Subscribe(...)
end

function VZ_EVENT_SUBSCRIBE_REMOTE(...)
    table.insert(VZ_REMOTE_SUBSCRIBED_EVENTS, {params = {...}})
    return Events.SubscribeRemote(...)
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
        return ZDEV_CONFIG.DEV_MODES[mode]
    else
        return false
    end
end
Package.Export("ZDEV_IsModeEnabled", ZDEV_IsModeEnabled)

function switch(key, tbl)
    if tbl[key] then
        return tbl[key]
    end
end

function CalculateMiddle(...)
    local middle = Vector(0, 0, 0)
    for i, v in ipairs({...}) do
        middle = middle + v
    end
    return middle / table_count({...})
end

function CalculateMiddlePonderedByDistanceSq(from_loc, ...)
    local middle = Vector(0, 0, 0)
    local pondered_sum = 0
    local tbl = {...}
    for i, v in ipairs(tbl) do
        local dist_sq = from_loc:DistanceSquared(v)
        middle = middle + v*dist_sq
        pondered_sum = pondered_sum + dist_sq
    end
    return middle / pondered_sum
end

function CallENVFunc_NoError(name, ...)
    if _ENV[name] then
        return _ENV[name](...)
    end
end

function VZ_GetFeatureValue(feature_name, key)
    if VZ_GLOBAL_FEATURES[feature_name] then
        return VZ_GLOBAL_FEATURES[feature_name][key]
    end
end
Package.Export("VZ_GetFeatureValue", VZ_GetFeatureValue)


function VZ_GetGamemodeConfigValue(key)
    if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Config then
        return VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Config[key]
    end
end
Package.Export("VZ_GetGamemodeConfigValue", VZ_GetGamemodeConfigValue)

function ContainsString(str, search_str)
    local wo_search_str, is_str = str:gsub(search_str, "")
    if is_str > 0 then
        return true, wo_search_str
    end
    return false, str
end

function ReplaceLetterInString(str, letter, replace_letter)
    local str_new = str:gsub(letter, replace_letter)
    return str_new
end

function GetEnemyTable(char)
    local EnemyName = char:GetValue("EnemyName")
    return Enemies_Config[EnemyName]
end

function IsEnemyDisabled(EnemyName)
    if MAP_SETTINGS then
        if MAP_SETTINGS.disabled_enemies then
            for i, v in ipairs(MAP_SETTINGS.disabled_enemies) do
                if v == EnemyName then
                    return true
                end
            end
        end
    end
end

function VectorGetLookAt(vec1, to)
    return (to - vec1):Rotation()
end

function IsPointInRectangle(entity_location, trigger_loc, trigger_rot, extent)

    -- Check if the entity location is in the box, the center of the box is the trigger location, the rectangle size is the extent and the rectangle rotation is the trigger rotation
    local box_center = trigger_loc
    local box_size = extent
    local box_rot = trigger_rot

    local entity_location_to_box_center = Vector(box_center.X - entity_location.X, box_center.Y - entity_location.Y, box_center.Z - entity_location.Z)
    local entity_location_to_box_center_rotated = box_rot:RotateVector(entity_location_to_box_center)

    return math.abs(entity_location_to_box_center_rotated.X) <= box_size.X and math.abs(entity_location_to_box_center_rotated.Y) <= box_size.Y and math.abs(entity_location_to_box_center_rotated.Z) <= box_size.Z
end

function CheckIfEntityInRectangle(class, trigger_loc, trigger_rot, extent)
    for k, v in pairs(class.GetPairs()) do
        if v:IsValid() then
            local ret = IsPointInRectangle(v:GetLocation(), trigger_loc, trigger_rot, extent)
            if ret then return true end
        end
    end
    return false
end

function VZ_IsAdmin(ply)
    if ply then
        if ply.BOT then
            return false
        end
        if Server_Admins_Steamid then
            for i, v in ipairs(Server_Admins_Steamid) do
                if v == ply:GetSteamID() then
                    return true
                end
            end
        end
    end
    return false
end
Package.Export("VZ_IsAdmin", VZ_IsAdmin)


function DebugFullPrint(txt)
    local step = 1000

    local len = string.len(txt)
    local chunks = {}
    local cur = 1
    while cur < len do
        table.insert(chunks, string.sub(txt, cur, cur + step))
        cur = cur + step + 1
    end

    for i, v in ipairs(chunks) do
        print(v)
    end
end


function IsAVehicle(entity)
    return (entity:IsA(VehicleWheeled) or entity:IsA(VehicleWater))
end


if ZDEV_IsModeEnabled("ZDEV_DEBUG_FUNCTION_CALLS") then
    debug.sethook(function()
        local info = debug.getinfo(2)

        if info.what == "Lua" then
            if (info.name and info.name ~= "__callback") then
                --print(info.source)

                local source_contains_slash = ContainsString(info.source, "/")
                if source_contains_slash then

                    local args_str = ""
                    for i = 1, info.nparams do
                        if i == 1 then
                            args_str = debug.getlocal(info.func, i)
                        else
                            args_str = args_str .. ", " .. debug.getlocal(info.func, i)
                        end
                    end
                    if info.isvararg then
                        if args_str == "" then
                            args_str = "..."
                        else
                            args_str = args_str .. ", ..."
                        end
                    end

                    Console.Log("[Function Call]\n " .. info.name .. "(" .. args_str .. ")\n line : " .. tostring(info.linedefined) .. "\n source : " .. tostring(info.source))
                end
            end
        end
    end, "c")
end