include("includes/language.lua")
include("includes/cl_lib.lua")
include("vgui/editor.lua")

local projectLib = koptilnya_holo_builder_cl_lib.Project

if not file.Exists(projectLib.PROJECTS_FOLDER, "DATA") then
    file.CreateDir(projectLib.Project.PROJECTS_FOLDER)
end
