if SERVER then
    -- Shared
    AddCSLuaFile("includes/sh_lib.lua")

    -- Client
    AddCSLuaFile("includes/cl_lib.lua")
    AddCSLuaFile("includes/language.lua")
    AddCSLuaFile("vgui/editor.lua")
    AddCSLuaFile("vgui/controls/dvector.lua")
end

-- Shared includes
include("includes/sh_lib.lua")

if CLIENT then
    -- Client includes
    include("includes/cl_lib.lua")
    include("includes/language.lua")
    include("vgui/editor.lua")
    include("vgui/controls/dvector.lua")

    local projectLib = koptilnya_holo_builder_cl_lib.Project

    if not file.Exists(projectLib.PROJECTS_FOLDER, "DATA") then
        file.CreateDir(projectLib.Project.PROJECTS_FOLDER)
    end
end
