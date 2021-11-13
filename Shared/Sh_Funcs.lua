

function table_count(ta)
    local count = 0
    for k, v in pairs(ta) do count = count + 1 end
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

