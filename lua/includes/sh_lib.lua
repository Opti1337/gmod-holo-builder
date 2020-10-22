function table.Map(tbl, f)
    local t = {}

    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    
    return t
end

koptilnya_holo_builder_sh_lib = {}

local lib = koptilnya_holo_builder_sh_lib

local function convertHologramToArray(holo)
    return {
        holo.index,
        holo.name,
        holo.model,
        tostring(holo.position),
        tostring(holo.rotation),
        tostring(holo.scale),
        tostring(holo.color),
        holo.material,
        holo.position_relative_to,
        holo.rotation_relative_to,
        holo.parent
    }
end

local function convertArrayToHologram(data)

    local explodedColor = string.Explode(" ", data[7])
    local color = Color(explodedColor[1], explodedColor[2], explodedColor[3], explodedColor[4] or 255)

    return {
        index = data[1],
        name = data[2],
        model = data[3],
        position = Vector(data[4]),
        rotation = Angle(data[5]),
        scale = Vector(data[6]),
        color = color,
        material = data[8],
        position_relative_to = data[9],
        rotation_relative_to = data[10],
        parent = data[11]
    }
end

lib.Net = {
    MESSAGE_NAME_PREFIX = "koptilnya_holo_builder_",
    NetworkMessageName = function(name)
        return string.format("%s%s", lib.Net.MESSAGE_NAME_PREFIX, name)
    end,
    SerializeProject = function(project)
        local result = {h = table.Map(project.holograms or {}, convertHologramToArray)}
        local json = util.TableToJSON(result)
        local compressedJson = util.Compress(json)

        return compressedJson
    end,
    DeserializeProject = function(compressedJson)
        local json = util.Decompress(compressedJson)
        local data = util.JSONToTable(json)

        return {holograms = table.Map(data.h, convertArrayToHologram)}
    end,
    SerializeHologram = function(holo)
        local data = convertHologramToArray(holo)
        local json = util.TableToJSON(data)
        local compressedJson = util.Compress(json)

        return compressedJson
    end,
    DeserializeHologram = function(compressedJson)
        local json = util.Decompress(compressedJson)
        local data = util.JSONToTable(json)

        return convertArrayToHologram(data)
    end
}

lib.IsValidKHB = function(entity)
    return IsValid(entity) and entity:GetClass() == "koptilnya_holo_builder"
end

koptilnya_holo_builder_sh_lib = lib
