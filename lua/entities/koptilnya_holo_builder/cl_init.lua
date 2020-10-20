include("shared.lua")

local netLib = koptilnya_holo_builder_sh_lib.Net

function ENT:Initialize()
    self.ProjectName = nil
    self.Holograms = {}
end

function ENT:OnRemove()
    for k, v in pairs(self.Holograms or {}) do
        if IsValid(v.entity) then
            v.entity:Remove()
        end
    end
end

function ENT:OpenProject(projectName, project)
    local serializedProject = netLib.SerializeProject(project)

    self.ProjectName = projectName

    net.Start(netLib.NetworkMessageName("open_project"))
    net.WriteEntity(self)
    net.WriteUInt(#serializedProject, 12)
    net.WriteData(serializedProject, #serializedProject)
    net.SendToServer()
end
