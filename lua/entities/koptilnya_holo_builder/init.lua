AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/cheeze/beta/white_button.mdl")
    self:DrawShadow(false)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.Holograms = {}
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end
