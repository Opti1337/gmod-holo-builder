TOOL.Name = "#tool.koptilnya_holo_builder.name"
TOOL.Category = "Koptilnya"
TOOL.Command = nil
TOOL.Information = {{name = "left_spawn", stage = 0}}

if SERVER then

    util.AddNetworkString("koptilnya_holo_builder_open_editor")

    function TOOL:LeftClick(trace)
        ent = ents.Create("koptilnya_holo_builder")

        ent:SetPos(trace.HitPos)
        ent:Spawn()

        undo.Create("Holo Builder")
        undo.AddEntity(ent)
        undo.SetPlayer(self:GetOwner())
        undo.Finish()

        cleanup.Add(self:GetOwner(), "koptilnya_holo_builder", ent)

        return true
    end

    function TOOL:RightClick(trace)
        if trace.Entity:GetClass() ~= "koptilnya_holo_builder" then
            return false
        end

        net.Start("koptilnya_holo_builder_open_editor")
        net.WriteEntity(trace.Entity)
        net.Send(self:GetOwner())

        return true
    end

elseif CLIENT then

    net.Receive("koptilnya_holo_builder_open_editor", function()
        local controller = net.ReadEntity()

        if controller:GetClass() ~= "koptilnya_holo_builder" then return end

        if IsValid(koptilnya_holo_builder_editor) then koptilnya_holo_builder_editor:Close() end

        koptilnya_holo_builder_editor = vgui.Create("koptilnya_holo_builder_editor")
        koptilnya_holo_builder_editor:SetController(controller)
    end)

    concommand.Add("koptilnya_holo_builder_toggle", function()
        if IsValid(koptilnya_holo_builder_editor) then koptilnya_holo_builder_editor:ToggleVisible() end
    end)

end
