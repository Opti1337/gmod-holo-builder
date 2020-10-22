local netLib = koptilnya_holo_builder_sh_lib.Net

ENT.Type = "anim"
ENT.Author = "Opti1337"
ENT.Contact = "wraker6@gmail.com"

cleanup.Register("koptilnya_holo_builder")

local function CreateClientHologram(self, data)
    if SERVER then
        return
    end

    local parent = data.parent == 0 and self or select(3, self:HologramExists(data.parent)).entity
    local positionRelativeTo = data.position_relative_to == 0 and self or select(3, self:HologramExists(data.position_relative_to)).entity
    local rotationRelativeTo = data.rotation_relative_to == 0 and self or select(3, self:HologramExists(data.rotation_relative_to)).entity
    local scaleMatrix = Matrix()
    scaleMatrix:Scale(data.scale)

    local entity = ClientsideModel(data.model)
    entity:DrawShadow(false)
    entity:SetRenderMode(RENDERMODE_TRANSCOLOR)
    entity:SetSolid(SOLID_NONE)
    entity:SetColor(data.color)
    entity:SetMaterial(data.material)
    entity:SetPos(positionRelativeTo:LocalToWorld(data.position))
    entity:SetAngles(rotationRelativeTo:LocalToWorldAngles(data.rotation))
    entity:EnableMatrix("RenderMultiply", scaleMatrix)
    entity:SetParent(parent)
    entity:Spawn()

    return entity
end

local function UpdateClientHologram(self, index, data)
    if SERVER then
        return
    end

    local bool, _, hologram = self:HologramExists(index)

    if bool then
        local entity = hologram.entity

        for k, v in pairs(data) do
            if k == "model" then
                entity:SetModel(v)
            elseif k == "position" then
                local positionRelativeTo = hologram.position_relative_to == 0 and self or select(3, self:HologramExists(hologram.position_relative_to)).entity

                entity:SetPos(positionRelativeTo:LocalToWorld(v))
            elseif k == "rotation" then
                local rotationRelativeTo = hologram.rotation_relative_to == 0 and self or select(3, self:HologramExists(hologram.rotation_relative_to)).entity

                entity:SetAngles(rotationRelativeTo:LocalToWorldAngles(v))
            elseif k == "scale" then
                local scaleMatrix = Matrix()

                scaleMatrix:Scale(v)
                entity:EnableMatrix("RenderMultiply", scaleMatrix)
            elseif k == "color" then
                entity:SetColor(v)
            elseif k == "material" then
                entity:SetMaterial(v)
            elseif k == "position_relative_to" then
            elseif k == "rotation_relative_to" then
            elseif k == "parent" then
                local parent = v == 0 and self or select(3, self:HologramExists(v)).entity

                if parent then
                    entity:SetParent(v)
                end
            end
        end
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "HologramsData")
end

function ENT:HologramExists(index)
    if not self.Holograms or #self.Holograms == 0 then
        return false
    end

    for k, v in pairs(self.Holograms) do
        if v.index == index then
            return true, k, v
        end
    end

    return false
end

function ENT:UsedIndexes()
    return table.Map(self.Holograms, function(hologram)
        return hologram.index
    end)
end

function ENT:NextIndex()
    local usedIndexes = self:UsedIndexes()

    if #usedIndexes == 0 then
        return 1
    end

    table.sort(usedIndexes)

    return usedIndexes[#usedIndexes] + 1
end

function ENT:CreateHologram(data)
    if CLIENT then
        local holo = CreateClientHologram(self, data)

        data = table.Merge(data, {entity = holo})
    end

    table.insert(self.Holograms, data)
end

function ENT:RemoveHologram(index)
    local bool, hologramKey, hologram = self:HologramExists(index)

    if bool then
        if CLIENT then
            hologram.entity:Remove()
        end

        table.remove(self.Holograms, hologramKey)
    end
end

function ENT:UpdateHologram(index, data)
    local bool, _, hologram = self:HologramExists(index)

    if bool then
        for k, v in pairs(data) do
            if hologram[k] ~= nil and hologram[k] ~= v then
                hologram[k] = v

                if CLIENT then
                    UpdateClientHologram(self, index, data)
                end
            end
        end
    end
end

function ENT:Clear()
    if CLIENT then
        for _, hologram in pairs(self.Holograms) do
            hologram.entity:Remove()
        end
    end

    self.Holograms = {}
end

function ENT:BuildProject(project)
    self:Clear()

    for _, hologram in pairs(project.holograms) do
        self:CreateHologram(hologram)
    end

    -- local function getHologram(index)
    --     for _, v in pairs(project.holograms) do
    --         if v.index == index then
    --             return v
    --         end
    --     end

    --     return nil
    -- end

    -- for _, hologram in pairs(project.holograms) do
    --     local indexesToCheck = {hologram.parent, hologram.position_relative_to, rotation_relative_to}

    --     for _, index in pairs(indexesToCheck) do
    --         if not self:HologramExists(index) then

    --         end
    --     end

    --     self:CreateHologram(hologram)
    -- end

    -- if specificHologramIndex ~= nil then
    --     for hologramKey, hologram in pairs(project) do
    --         if hologram.index == specificHologramIndex then
    --             -- make holo
    --         end
    --     end
    -- else
    --     for hologramKey, hologram in pairs(project) do
    --         if not self:HologramExist(hologram) then
    --             local indexesToCheck = {hologram.parent, hologram.position_relative_to, rotation_relative_to}

    --             for indexKey, index in pairs(indexesToCheck) do
    --                 if not self:HologramExists(index) then
    --                     self:BuildProject(project, index)
    --                 else
    --                     -- make holo
    --                 end
    --             end
    --         end

    --         -- controller:CreateHologram(v.index, v)
    --     end
    -- end
end

if SERVER then
    util.AddNetworkString(netLib.NetworkMessageName("create_holo"))
    util.AddNetworkString(netLib.NetworkMessageName("remove_holo"))
    util.AddNetworkString(netLib.NetworkMessageName("update_holo"))
    util.AddNetworkString(netLib.NetworkMessageName("open_project"))
end

net.Receive(netLib.NetworkMessageName("open_project"), function(len, ply)
    local controller = net.ReadEntity()
    local size = net.ReadUInt(16)
    local compressedJson = net.ReadData(size)
    local project = netLib.DeserializeProject(compressedJson)

    controller:BuildProject(project)

    if SERVER then
        net.Start(netLib.NetworkMessageName("open_project"))
        net.WriteEntity(controller)
        net.WriteUInt(size, 16)
        net.WriteData(compressedJson, size)
        net.Broadcast()
    end

    hook.Run("koptilnya_holo_builder_project_opened", controller, project)
end)

net.Receive(netLib.NetworkMessageName("create_holo"), function(len, ply)
    local controller = net.ReadEntity()
    local index = SERVER and controller:NextIndex() or net.ReadUInt(12)
    local size = net.ReadUInt(16)
    local compressedJson = net.ReadData(size)
    local holo = netLib.DeserializeHologram(compressedJson)
    holo = table.Merge(holo, {index = index})

    controller:CreateHologram(holo)

    if SERVER then
        net.Start(netLib.NetworkMessageName("create_holo"))
        net.WriteEntity(controller)
        net.WriteUInt(index, 12)
        net.WriteUInt(size, 16)
        net.WriteData(compressedJson, size)
        net.Broadcast()
    end

    hook.Run("koptilnya_holo_builder_hologram_created", controller, index)
end)

net.Receive(netLib.NetworkMessageName("remove_holo"), function(len, ply)
    local controller = net.ReadEntity()
    local index = net.ReadUInt(12)

    controller:RemoveHologram(index)

    if SERVER then
        net.Start(netLib.NetworkMessageName("remove_holo"))
        net.WriteEntity(controller)
        net.WriteUInt(index, 12)
        net.Broadcast()
    end

    hook.Run("koptilnya_holo_builder_hologram_removed", controller, index)
end)

net.Receive(netLib.NetworkMessageName("update_holo"), function(len, ply)
    local controller = net.ReadEntity()
    local index = net.ReadUInt(12)
    local size = net.ReadUInt(16)
    local compressedJson = net.ReadData(size)
    local json = util.Decompress(compressedJson)
    local data = util.JSONToTable(json)

    controller:UpdateHologram(index, data)

    if SERVER then
        net.Start(netLib.NetworkMessageName("update_holo"))
        net.WriteEntity(controller)
        net.WriteUInt(index, 12)
        net.WriteUInt(size, 16)
        net.WriteData(compressedJson, size)
        net.Broadcast()
    end

    hook.Run("koptilnya_holo_builder_hologram_updated", controller, index)
end)
