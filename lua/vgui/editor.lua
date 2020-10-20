local scrW, scrH = ScrW(), ScrH()
local ply = LocalPlayer()
local projectLib = koptilnya_holo_builder_cl_lib.Project
local ShowError = koptilnya_holo_builder_cl_lib.ShowError
local netLib = koptilnya_holo_builder_sh_lib.Net
local IsValidKHB = koptilnya_holo_builder_sh_lib.IsValidKHB

local PANEL = {}

PANEL.Holograms = {}
PANEL.ProjectName = nil
PANEL.Project = nil
PANEL.SelectedHologram = nil

local function SendCreateHologram(controller, model)
    local serializedHolo = netLib.SerializeHologram({
        model = model,
        position = controller:GetPos(),
        angle = Angle(0, 0, 0),
        scale = Vector(1, 1, 1),
        color = Color(255, 255, 255)
    })

    net.Start(netLib.NetworkMessageName("create_holo"))
    net.WriteEntity(controller)
    net.WriteUInt(#serializedHolo, 12)
    net.WriteData(serializedHolo, #serializedHolo)
    net.SendToServer()
end

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

    self:InitHologramList()
end

function PANEL:InitMenuBar()
    local menuBar = vgui.Create("DMenuBar", self)
    menuBar:DockMargin(-3, -6, -3, 6)

    -- Project menu
    local fileMenu = menuBar:AddMenu("Project")
    fileMenu:AddOption("New..."):SetIcon("icon16/page_add.png")
    fileMenu:AddOption("Save...", function()
        Derma_StringRequest("Save project...", "Enter project name", self.ProjectName or "", function(projectName)
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

            self:OpenProject(projectName)
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
    local models = {Cube = "models/holograms/cube.mdl", Cylinder = "models/holograms/hq_cylinder.mdl"}

    createMenu:AddOption("Custom...", function()
        Derma_StringRequest("Create custom hologram...", "Enter model path", "", function(modelPath)
            if modelPath ~= "" then
                SendCreateHologram(self.Controller, modelPath)
            end
        end)
    end)

    for k, v in pairs(models) do
        createMenu:AddOption(k, function()
            SendCreateHologram(self.Controller, v)
        end)
    end
end

function PANEL:InitHologramList()
    self.HologramList = vgui.Create("DListView", self)
    self.HologramList:Dock(BOTTOM)
    self.HologramList:DockMargin(0, 3, 0, 0)
    self.HologramList:SetMultiSelect(false)
    self.HologramList:SetHeight(100)

    self.HologramList:AddColumn("ID"):SetFixedWidth(30)
    self.HologramList:AddColumn("Name")
end

function PANEL:PopulateHologramList()
    self.HologramList:Clear()

    if not self.Controller then
        return
    end

    for k, v in pairs(self.Controller.Holograms) do
        self.HologramList:AddLine(v.index, v.name == "" and v.model or v.name)
    end
end

function PANEL:OnClose()
    if IsValid(self.Controller) then
        self.Controller:RemoveCallOnRemove("remove_holo_builder")
    end
end

function PANEL:SetController(controller)
    if not IsValidKHB(controller) then
        return
    end

    self.Controller = controller

    controller:CallOnRemove("remove_holo_builder", function()
        self:Close()
    end)

    controller:CallOnProjectOpened("holobuilder_update", function()
        self:PopulateHologramList()
    end)

    controller:CallOnHologramCreated("holobuilder_update", function()
        self:PopulateHologramList()
    end)

    self:PopulateHologramList()
end

function PANEL:OpenProject(projectName)
    local project = projectLib.GetProject(projectName)

    if project then
        self.ProjectName = projectName
        self.Controller:OpenProject(projectName, project)
    else
        ShowError("Project is broken!")
    end
end

vgui.Register("koptilnya_holo_builder_editor", PANEL, "DFrame")
