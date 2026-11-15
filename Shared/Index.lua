

function TableDeepCopy(tbl, parents)
    parents = parents or {}
    local newtbl = {}
    for k, v in pairs(tbl) do
        if (type(v) ~= "table" or v == tbl or parents[k] == v) then
            newtbl[k] = v
        else
            if getmetatable(v) == Vector then
                newtbl[k] = Vector(v.X, v.Y, v.Z)
            else
                parents[k] = v
                newtbl[k] = TableDeepCopy(v, parents)
                parents = {}
            end
        end
    end
    return newtbl
end