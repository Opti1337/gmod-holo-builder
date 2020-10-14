AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/cheeze/beta/white_button.mdl")
    self:DrawShadow(false)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
end

util.AddNetworkString("koptilnya_holo_builder_create_holo")

net.Receive("koptilnya_holo_builder_create_holo", function(len, ply)
    local controller = net.ReadEntity()
    local model = net.ReadString()

    controller:SetHologramsData(controller:GetHologramsData() .. ", " .. model)
    
    print(controller:GetHologramsData())
end)
