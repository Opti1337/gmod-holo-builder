local scrW, scrH = ScrW(), ScrH()
local ply = LocalPlayer()

local PANEL = {}

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

    -- Project
    local fileMenu = menuBar:AddMenu("Project")
    fileMenu:AddOption("New..."):SetIcon("icon16/page_add.png")
    fileMenu:AddOption("Save...", function()
        Derma_StringRequest("Save project...", "Enter project name", "",
                            function(text)
            file.Write(string.format("koptilnya_holo_builder/%s.json", text),
                       "Чел, ты...")
        end)
    end):SetIcon("icon16/page_save.png")
    fileMenu:AddOption("Open...", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Open project...")
        frame:SetSize(300, 500)
        frame:Center()
        frame:MakePopup()
        frame:SetBackgroundBlur(true)

        local tree = vgui.Create("DTree", frame)
        tree:Dock(FILL)
        tree.DoClick = function(tree, node)
            self:OpenProject(node:GetFileName())
            frame:Close()
        end

        local projectsNode = tree:AddNode("Projects")
        projectsNode:MakeFolder("koptilnya_holo_builder", "DATA", true,
                                "*.json", false)
        projectsNode:SetExpanded(true)
    end):SetIcon("icon16/page_edit.png")

    fileMenu:AddSpacer()

    local exportSubMenu = fileMenu:AddSubMenu("Export")
    exportSubMenu:SetDeleteSelf(false)
    exportSubMenu:AddOption("To E2 holograms"):SetIcon("icon16/page_go.png")

    fileMenu:AddSpacer()

    fileMenu:AddOption("Exit", function() self:Close() end):SetIcon(
        "icon16/door_open.png")

    -- Create
    local createMenu = menuBar:AddMenu("Create")
    createMenu:AddOption("Cube", function()
        -- net.Start("koptilnya_holo_builder_create_holo")
        -- net.WriteString("models/holograms/cube.mdl")
        -- net.SendToServer()
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
    if controller:GetClass() ~= "koptilnya_holo_builder" then return end

    self.controller = controller

    controller:CallOnRemove("remove_holo_builder", function() self:Close() end)
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
