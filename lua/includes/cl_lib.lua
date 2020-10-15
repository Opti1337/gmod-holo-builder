koptilnya_holo_builder_cl_lib = {}
local lib = koptilnya_holo_builder_cl_lib

lib.Project = {
    PROJECTS_FOLDER = "koptilnya_holo_builder",
    PROJECTS_EXTENSION = ".json",
    ProjectExists = function(projectName)
        projectName = string.StripExtension(projectName)

        local projects = lib.Project.GetProjects(true)

        return table.HasValue(projects, projectName)
    end,
    GetProject = function(projectName)
        projectName = string.StripExtension(projectName)

        if lib.Project.ProjectExists(projectName) then
            local projectPath = string.format("%s/%s%s", lib.Project.PROJECTS_FOLDER, projectName, lib.Project.PROJECTS_EXTENSION)
            local json = file.Read(projectPath)

            return util.JSONToTable(json)
        end

        return nil
    end,
    SaveProject = function(projectName, data)
        projectName = string.StripExtension(projectName)
        data = data or {}

        local projectPath = string.format("%s/%s%s", lib.Project.PROJECTS_FOLDER, projectName, lib.Project.PROJECTS_EXTENSION)

        file.Write(projectPath, util.TableToJSON(data, true))
    end,
    GetProjects = function(stripExtension)
        stripExtension = stripExtension or false

        local files = file.Find(string.format("%s/*%s", lib.Project.PROJECTS_FOLDER, lib.Project.PROJECTS_EXTENSION), "DATA")

        if stripExtension == true then
            for i, v in ipairs(files) do
                files[i] = string.StripExtension(v)
            end
        end

        return files
    end
}

lib.Net = {
    MESSAGE_NAME_PREFIX = "koptilnya_holo_builder_",
    NetworkMessageName = function(name)
        return string.format("%s%s", lib.Net.MESSAGE_NAME_PREFIX, name)
    end
}

koptilnya_holo_builder_cl_lib = lib
