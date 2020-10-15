local scrW, scrH = ScrW(), ScrH()
local ply = LocalPlayer()
local projectLib = koptilnya_holo_builder_cl_lib.Project
local netLib = koptilnya_holo_builder_sh_lib.Net

local PANEL = {}

PANEL.projectName = nil
PANEL.project = nil
PANEL.selectedHologram = nil

function PANEL:Init()
    local width, height = 400, 500
    local margin = 15

    self:SetTitle("Holo Builder")
    self:SetSize(width, height)
    self:SetPos(ScrW() - (width + margin), 0)
    self:CenterVertical()
    self:ShowCloseButton(false)
    self:SetSizable(false)
    self:SetScreenLock(true)
    self:MakePopup(true)
    self:SetKeyBoardInputEnabled(false)

    self:InitMenuBar()

    local tabs = vgui.Create("DPropertySheet", self)
    tabs:Dock(FILL)

    local positioningTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Positioning", positioningTab)

    local label = vgui.Create("DLabel", positioningTab)
    label:SetText("Positioning")
    label:SetColor(Color(255, 0, 0))

    local clippingTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Clipping", clippingTab)

    vgui.Create("DLabel", clippingTab):SetText("Clipping")

    local mirroringTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Mirroring", mirroringTab)

    local visualsTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Visuals", visualsTab)

    self.holoList = vgui.Create("DListView", self)
    self.holoList:Dock(BOTTOM)
    self.holoList:DockMargin(0, 3, 0, 0)
    self.holoList:SetMultiSelect(false)
    self.holoList:SetHeight(100)

    self.holoList:AddColumn("ID"):SetFixedWidth(30)
    self.holoList:AddColumn("Name")
end

function PANEL:InitMenuBar()
    local menuBar = vgui.Create("DMenuBar", self)
    menuBar:DockMargin(-3, -6, -3, 6)

    -- Project menu
    local fileMenu = menuBar:AddMenu("Project")
    fileMenu:AddOption("New..."):SetIcon("icon16/page_add.png")
    fileMenu:AddOption("Save...", function()
        Derma_StringRequest("Save project...", "Enter project name", self.projectName or "", function(projectName)
            projectLib.SaveProject(projectName, {[1] = {model = "models/holograms/hq_sphere.mdl"}})
        end)
    end):SetIcon("icon16/page_save.png")
    fileMenu:AddOption("Open...", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Open project...")
        frame:SetSize(300, 400)
        frame:Center()
        frame:MakePopup()
        frame:SetBackgroundBlur(true)

        local projectList = vgui.Create("DListView", frame)
        projectList:Dock(FILL)
        projectList:SetMultiSelect(false)
        projectList:AddColumn("Projects")
        projectList.DoDoubleClick = function(list, index, line)
            local projectName = line:GetColumnText(1)
            local project = projectLib.GetProject(projectName)

            if project ~= nil then
                self.projectName = projectName
                self.project = project
            end

            frame:Close()
        end

        for i, v in ipairs(projectLib.GetProjects(true)) do
            projectList:AddLine(v)
        end
    end):SetIcon("icon16/page_edit.png")

    fileMenu:AddSpacer()

    local exportSubMenu = fileMenu:AddSubMenu("Export")
    exportSubMenu:SetDeleteSelf(false)
    exportSubMenu:AddOption("To Expression 2"):SetIcon("icon16/page_go.png")

    fileMenu:AddSpacer()

    fileMenu:AddOption("Exit", function()
        self:Close()
    end):SetIcon("icon16/door_open.png")

    -- Create menu
    local createMenu = menuBar:AddMenu("Create")
    createMenu:AddOption("Cube", function()
        local holo = {
            "models/holograms/cube.mdl",
            tostring(self.controller:GetPos()),
            tostring(Angle(0, 0, 0)),
            tostring(Vector(1, 1, 1)),
            tostring(Color(255, 255, 255))
        }

        PrintTable(holo)

        local json = util.TableToJSON(holo)
        local compressedJson = util.Compress(json)

        net.Start(netLib.NetworkMessageName("create_holo"))
        net.WriteEntity(self.controller)
        net.WriteUInt(#compressedJson, 12)
        net.WriteData(compressedJson, #compressedJson)
        net.SendToServer()
    end)
    createMenu:AddOption("Cylinder", function()
        -- net.Start("koptilnya_holo_builder_create_holo")
        -- net.WriteEntity(self.controller)
        -- net.WriteString("models/holograms/hq_cylinder.mdl")
        -- net.SendToServer()
    end)
end

function PANEL:OnClose()
    if IsValid(self.controller) then
        self.controller:RemoveCallOnRemove("remove_holo_builder")
    end
end

function PANEL:SetController(controller)
    if controller:GetClass() ~= "koptilnya_holo_builder" then
        return
    end

    self.controller = controller

    controller:CallOnRemove("remove_holo_builder", function()
        self:Close()
    end)
end

function PANEL:OpenProject(projectPath)
    local project = util.JSONToTable(file.Read(projectPath))

    if project then
        self.projectPath = projectPath
        self.project = project
    else
        notification.AddLegacy("Project is broken!", NOTIFY_ERROR, 3)
        surface.PlaySound("buttons/button10.wav")
    end
end

vgui.Register("koptilnya_holo_builder_editor", PANEL, "DFrame")
