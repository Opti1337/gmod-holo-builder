ENT.Type = "anim"
ENT.Author = "Opti1337"
ENT.Contact = "wraker6@gmail.com"

cleanup.Register("koptilnya_holo_builder")

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "HologramsData")
end
