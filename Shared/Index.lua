

function TableDeepCopy(tbl, parents)
    parents = parents or {}
    local newtbl = {}
    for k, v in pairs(tbl) do
        if (type(v) ~= "table" or v == tbl or parents[k] == v) then
            newtbl[k] = v
        else
            parents[k] = v
            newtbl[k] = TableDeepCopy(v, parents)
            parents = {}
        end
    end
    return newtbl
end