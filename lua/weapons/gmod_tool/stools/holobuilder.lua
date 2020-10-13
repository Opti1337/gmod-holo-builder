TOOL.Name = "#tool.holobuilder.name"
TOOL.Category = "Koptilnya"
TOOL.Command = nil
TOOL.Information = {{name = "left_spawn", stage = 0}}

function TOOL:LeftClick(trace)
    ent = ents.Create("gmod_ent_holobuilder")

    ent:SetPos(trace.HitPos)
    ent:Spawn()

    undo.Create("Holo Builder")
    undo.AddEntity(ent)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    self:GetOwner():AddCleanup("gmod_ent_holobuilder", ent)

    return true
end

if CLIENT then
    language.Add("tool.holobuilder.name", "Holo Builder")
    language.Add("tool.holobuilder.desc", "Build anything with holograms")
    language.Add("tool.holobuilder.left_spawn",
                 "Left click to spawn a controller")
    language.Add("Undone_gmod_ent_holobuilder", "Undone Holo Builder")
    language.Add("Undone_Holo Builder", "Undone Holo Builder")
end
