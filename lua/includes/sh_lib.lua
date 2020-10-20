koptilnya_holo_builder_sh_lib = {}

local lib = koptilnya_holo_builder_sh_lib
local table = table

lib.Net = {
    MESSAGE_NAME_PREFIX = "koptilnya_holo_builder_",
    NetworkMessageName = function(name)
        return string.format("%s%s", lib.Net.MESSAGE_NAME_PREFIX, name)
    end,
    SerializeProject = function(project)
        local holograms = project.holograms or {}
        local function convert_holo(holo)
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

        holograms = table.map(holograms, convert_holo)

        local json = util.TableToJSON(holograms)
        local compressedJson = util.Compress(json)

        return compressedJson
    end,
    DeserializeProject = function(compressedJson)
        local json = util.Decompress(compressedJson)
        local data = util.JSONToTable(json)
        local function convert_data(data)
            local explodedColor = string.Explode(" ", data[7])
            local color = Color(explodedColor[1], explodedColor[2], explodedColor[3], explodedColor[4] or 0)

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

        return table.map(data, convert_data)
    end,
    SerializeHologram = function(holo)
        local data = {holo.model, tostring(holo.position), tostring(holo.angle), tostring(holo.scale), tostring(holo.color)}
        local json = util.TableToJSON(data)
        local compressedJson = util.Compress(json)

        return compressedJson
    end,
    DeserializeHologram = function(compressedJson)
        local json = util.Decompress(compressedJson)
        local data = util.JSONToTable(json)
        local explodedColor = string.Explode(" ", data[5])
        local color = Color(explodedColor[1], explodedColor[2], explodedColor[3], explodedColor[4] or 0)

        return {model = data[1], position = Vector(data[2]), angle = Angle(data[3]), scale = Vector(data[4]), color = color}
    end
}

lib.IsValidKHB = function(entity)
    return IsValid(entity) and entity:GetClass() == "koptilnya_holo_builder"
end

koptilnya_holo_builder_sh_lib = lib
