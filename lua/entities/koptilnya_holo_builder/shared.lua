local netLib = koptilnya_holo_builder_sh_lib.Net

ENT.Type = "anim"
ENT.Author = "Opti1337"
ENT.Contact = "wraker6@gmail.com"

cleanup.Register("koptilnya_holo_builder")

local function DoHologramCreated(controller)
    if not controller.OnHologramCreatedFunctions then
        return false
    end

    for k, v in pairs(controller.OnHologramCreatedFunctions) do
        if (v and v.Function) then
            v.Function(ent, unpack(v.Args))
        end
    end
end

local function DoProjectOpened(controller)
    if not controller.OnProjectOpenedFunctions then
        return false
    end

    for k, v in pairs(controller.OnProjectOpenedFunctions) do
        if (v and v.Function) then
            v.Function(ent, unpack(v.Args))
        end
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "HologramsData")
end

function ENT:CallOnHologramCreated(name, func, ...)
    self.OnHologramCreatedFunctions = self.OnHologramCreatedFunctions or {}
    self.OnHologramCreatedFunctions[name] = {Name = name, Function = func, Args = {...}}
end

function ENT:RemoveCallOnHologramCreated(name)
    self.OnHologramCreatedFunctions = self.OnHologramCreatedFunctions or {}
    self.OnHologramCreatedFunctions[name] = nil
end

function ENT:CallOnProjectOpened(name, func, ...)
    self.OnProjectOpenedFunctions = self.OnProjectOpenedFunctions or {}
    self.OnProjectOpenedFunctions[name] = {Name = name, Function = func, Args = {...}}
end

function ENT:RemoveCallOnProjectOpened(name)
    self.OnProjectOpenedFunctions = self.OnProjectOpenedFunctions or {}
    self.OnProjectOpenedFunctions[name] = nil
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

function ENT:NextIndex()
    return table.maxn(table.GetKeys(self.Holograms)) + 1
end

function ENT:CreateHologram(index, data)
    local dataToInsert = table.Merge(data, {index = index})

    if CLIENT then
        local holo = ents.CreateClientProp()
        holo:SetModel(data.model)
        holo:SetPos(self:GetPos())
        holo:SetParent(data.parent == 0 and self or data.parent)
        holo:Spawn()

        dataToInsert = table.Merge(dataToInsert, {entity = holo})
    end

    table.insert(self.Holograms, index, dataToInsert)
end

if SERVER then
    util.AddNetworkString(netLib.NetworkMessageName("create_holo"))
    util.AddNetworkString(netLib.NetworkMessageName("open_project"))
end

net.Receive(netLib.NetworkMessageName("create_holo"), function(len, ply)
    local controller = net.ReadEntity()
    local index = SERVER and controller:NextIndex() or net.ReadUInt(8)
    local size = net.ReadUInt(12)
    local compressedJson = net.ReadData(size)
    local holo = netLib.DeserializeHologram(compressedJson)

    controller:CreateHologram(index, holo)

    if SERVER then
        net.Start(netLib.NetworkMessageName("create_holo"))
        net.WriteEntity(controller)
        net.WriteUInt(index, 8)
        net.WriteUInt(size, 12)
        net.WriteData(compressedJson, size)
        net.Broadcast()
    end

    DoHologramCreated(controller)
end)

net.Receive(netLib.NetworkMessageName("open_project"), function(len, ply)
    local controller = net.ReadEntity()
    local size = net.ReadUInt(12)
    local compressedJson = net.ReadData(size)
    local project = netLib.DeserializeProject(compressedJson)

    for k, v in pairs(project) do
        controller:CreateHologram(v.index, v)
    end

    if SERVER then
        net.Start(netLib.NetworkMessageName("open_project"))
        net.WriteEntity(controller)
        net.WriteUInt(size, 12)
        net.WriteData(compressedJson, size)
        net.Broadcast()
    end

    DoProjectOpened(controller)
end)
