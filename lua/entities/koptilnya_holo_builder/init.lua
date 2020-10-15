AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local netLib = koptilnya_holo_builder_sh_lib.Net

function ENT:Initialize()
    self:SetModel("models/cheeze/beta/white_button.mdl")
    self:DrawShadow(false)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
end

util.AddNetworkString(netLib.NetworkMessageName("create_holo"))

net.Receive(netLib.NetworkMessageName("create_holo"), function(len, ply)
    local controller = net.ReadEntity()
    local size = net.ReadUInt(12)
    local compressedJson = net.ReadData(size)
    local json = util.Decompress(compressedJson)
    local holo = util.JSONToTable(json)

    PrintTable(holo)
end)
