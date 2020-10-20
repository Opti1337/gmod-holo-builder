function table.map(tbl, f)
    local t = {}

    for k, v in pairs(tbl) do
        t[k] = f(v)
    end

    return t
end

function pairs_map(tbl, f)
    local iter, state, k = pairs(tbl)

    return function(state, k)
        local v
        k, v = iter(state, k)
        if k == nil then
            return nil
        end
        return k, f(v)
    end, state, k
end

include("includes/sh_lib.lua")