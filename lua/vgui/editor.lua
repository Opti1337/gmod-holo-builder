local scrW, scrH = ScrW(), ScrH()
local ply = LocalPlayer()
local projectLib = koptilnya_holo_builder_cl_lib.Project
local ShowError = koptilnya_holo_builder_cl_lib.ShowError
local netLib = koptilnya_holo_builder_sh_lib.Net
local IsValidKHB = koptilnya_holo_builder_sh_lib.IsValidKHB

local PANEL = {}

PANEL.ProjectName = nil
PANEL.Elements = {}
PANEL.SelectedHologramIndex = nil
PANEL.SelectedHologram = nil
PANEL.SelectedHologramLine = nil

local function CreateHologram(controller, data)
    local serializedHologram = netLib.SerializeHologram({
        index = 0,
        name = data.name or "",
        model = data.model or "models/holograms/cube.mdl",
        position = data.position or Vector(0, 0, 0),
        rotation = data.rotation or Angle(0, 0, 0),
        scale = data.scale or Vector(1, 1, 1),
        color = data.color or Color(255, 255, 255),
        material = data.material or "",
        position_relative_to = data.position_relative_to or 0,
        rotation_relative_to = data.rotation_relative_to or 0,
        parent = data.parent or 0
    })

    net.Start(netLib.NetworkMessageName("create_holo"))
    net.WriteEntity(controller)
    net.WriteUInt(#serializedHologram, 16)
    net.WriteData(serializedHologram, #serializedHologram)
    net.SendToServer()
end

local function DuplicateHologram(controller, index)
    local bool, k, v = controller:HologramExists(index)

    if bool then
        local hologram = table.Copy(v)
        hologram.index = 0
        hologram.name = hologram.name ~= "" and hologram.name .. "_copy" or ""
        local serializedHologram = netLib.SerializeHologram(hologram)

        net.Start(netLib.NetworkMessageName("create_holo"))
        net.WriteEntity(controller)
        net.WriteUInt(#serializedHologram, 16)
        net.WriteData(serializedHologram, #serializedHologram)
        net.SendToServer()
    end
end

local function RemoveHologram(controller, index)
    local bool, k, v = controller:HologramExists(index)

    if bool then
        net.Start(netLib.NetworkMessageName("remove_holo"))
        net.WriteEntity(controller)
        net.WriteUInt(index, 12)
        net.SendToServer()
    end
end

local function UpdateHologram(controller, index, data)
    local bool, k, v = controller:HologramExists(index)

    if bool then
        local json = util.TableToJSON(data)
        local compressedJson = util.Compress(json)

        net.Start(netLib.NetworkMessageName("update_holo"))
        net.WriteEntity(controller)
        net.WriteUInt(index, 12)
        net.WriteUInt(#compressedJson, 16)
        net.WriteData(compressedJson, #compressedJson)
        net.SendToServer()
    end
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

    self:InitTabs()

    self:InitHologramList()

    hook.Add("koptilnya_holo_builder_hologram_created", self, function(editor, controller)
        editor:PopulateHologramList()
    end)

    hook.Add("koptilnya_holo_builder_hologram_removed", self, function(editor, controller)
        editor:PopulateHologramList()
    end)

    hook.Add("koptilnya_holo_builder_hologram_updated", self, function(editor, controller)
        editor:PopulateHologramList()
    end)

    hook.Add("koptilnya_holo_builder_project_opened", self, function(editor, controller)
        editor:PopulateHologramList()
    end)

    hook.Add("OnTextEntryGetFocus", self, function(editor)
        editor:SetKeyBoardInputEnabled(true)
    end)

    hook.Add("OnTextEntryLoseFocus", self, function(editor)
        editor:SetKeyBoardInputEnabled(false)
    end)
end

function PANEL:InitMenuBar()
    local menuBar = vgui.Create("DMenuBar", self)
    menuBar:DockMargin(-3, -6, -3, 6)

    -- Project
    local fileMenu = menuBar:AddMenu("Project")
    fileMenu:AddOption("New", function()
        self.Controller:Clear()
    end):SetIcon("icon16/page_add.png")

    -- Project -> Save...
    fileMenu:AddOption("Save...", function()
        Derma_StringRequest("Save project...", "Enter project name", self.ProjectName or "", function(projectName)
            local data = {holograms = self.Controller.Holograms}

            projectLib.SaveProject(projectName, data)
        end)
    end):SetIcon("icon16/page_save.png")

    -- Project -> Open...
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

    -- Project -> Export
    local exportSubMenu = fileMenu:AddSubMenu("Export")
    exportSubMenu:SetDeleteSelf(false)

    -- Project -> Export -> E2
    exportSubMenu:AddOption("To Expression 2"):SetIcon("icon16/page_go.png")

    fileMenu:AddSpacer()

    -- Project -> Exit
    fileMenu:AddOption("Exit", function()
        self:Close()
    end):SetIcon("icon16/door_open.png")

    -- Create
    local createMenu = menuBar:AddMenu("Create")

    -- Create -> Custom...
    createMenu:AddOption("Custom...", function()
        Derma_StringRequest("Create custom hologram...", "Enter model path", "", function(modelPath)
            if modelPath ~= "" then
                CreateHologram(self.Controller, {model = modelPath})
            end
        end)
    end)

    -- Create -> [Basic models]
    local models = {Cube = "models/holograms/cube.mdl", Cylinder = "models/holograms/hq_cylinder.mdl"}
    for k, v in pairs(models) do
        createMenu:AddOption(k, function()
            CreateHologram(self.Controller, {model = v})
        end)
    end
end

function PANEL:InitTabs()
    self.Elements.Tabs = vgui.Create("DPropertySheet", self)
    self.Elements.Tabs:Dock(FILL)
    self.Elements.Tabs:Hide()

    self.Elements.Banner = vgui.Create("DLabel", self)
    self.Elements.Banner:Dock(FILL)
    self.Elements.Banner:SetContentAlignment(5)
    self.Elements.Banner:SetText("Add a hologram or open the project")

    self:InitTransformTab()
    self:InitVisualsTab()
    self:InitClippingTab()
    self:InitMirroringTab()
end

function PANEL:InitTransformTab()
    local tab = vgui.Create("DPanel", self.Elements.Tabs)
    tab:SetBackgroundColor(Color(0, 0, 0, 0))
    self.Elements.Tabs:AddSheet("Transform", tab)

    self.Elements.TransformPosition = vgui.Create("DVector", tab)
    self.Elements.TransformPosition:Dock(TOP)
    self.Elements.TransformPosition:SetText("Position")
    self.Elements.TransformPosition.OnValueChanged = function(obj, x, y, z)
        UpdateHologram(self.Controller, self.SelectedHologramIndex, {position = Vector(x, y, z)})
    end

    self.Elements.TransformRotation = vgui.Create("DVector", tab)
    self.Elements.TransformRotation:Dock(TOP)
    self.Elements.TransformRotation:SetText("Rotation")
    self.Elements.TransformRotation:SetXText("Pitch")
    self.Elements.TransformRotation:SetYText("Yaw")
    self.Elements.TransformRotation:SetZText("Roll")
    self.Elements.TransformRotation.OnValueChanged = function(obj, x, y, z)
        UpdateHologram(self.Controller, self.SelectedHologramIndex, {rotation = Angle(x, y, z)})
    end

    self.Elements.TransformScale = vgui.Create("DVector", tab)
    self.Elements.TransformScale:Dock(TOP)
    self.Elements.TransformScale:SetText("Scale")
    self.Elements.TransformScale.OnValueChanged = function(obj, x, y, z)
        UpdateHologram(self.Controller, self.SelectedHologramIndex, {scale = Vector(x, y, z)})
    end
end

function PANEL:InitVisualsTab()
    local tab = vgui.Create("DPanel", self.Elements.Tabs)
    self.Elements.Tabs:AddSheet("Visuals", tab)
end

function PANEL:InitClippingTab()
    local tab = vgui.Create("DPanel", self.Elements.Tabs)
    self.Elements.Tabs:AddSheet("Clipping", tab)
end

function PANEL:InitMirroringTab()
    local tab = vgui.Create("DPanel", self.Elements.Tabs)
    self.Elements.Tabs:AddSheet("Mirroring", tab)
end

function PANEL:InitHologramList()
    self.Elements.HologramList = vgui.Create("DListView", self)
    self.Elements.HologramList:Dock(BOTTOM)
    self.Elements.HologramList:DockMargin(0, 3, 0, 0)
    self.Elements.HologramList:SetMultiSelect(false)
    self.Elements.HologramList:SetHeight(100)

    self.Elements.HologramList:AddColumn("ID"):SetFixedWidth(30)
    self.Elements.HologramList:AddColumn("Name")

    self.Elements.HologramList.OnRowSelected = function(list, index, line)
        local hologramIndex = line:GetColumnText(1)
        local _, _, hologram = self.Controller:HologramExists(hologramIndex)

        self.SelectedHologramIndex = hologramIndex
        self.SelectedHologram = hologram
        self.SelectedHologramLine = line

        self:UpdateData()
    end

    self.Elements.HologramList.OnRowRightClick = function(list, index, line)
        local hologramIndex = line:GetColumnText(1)

        local menu = DermaMenu()
        menu:AddOption("Rename...", function()
            local _, _, hologram = self.Controller:HologramExists(hologramIndex)

            Derma_StringRequest("Rename hologram...", "Enter new hologram name", hologram.name, function(newHologramName)
                UpdateHologram(self.Controller, hologramIndex, {name = newHologramName})
            end)
        end)
        menu:AddOption("Duplicate", function()
            DuplicateHologram(self.Controller, hologramIndex)
        end)
        menu:AddOption("Remove", function()
            RemoveHologram(self.Controller, hologramIndex)
        end)
        menu:Open()
    end
end

function PANEL:PopulateHologramList()
    self.Elements.HologramList:Clear()

    if not self.Controller then
        return
    end

    self.SelectedHologramLine = nil

    for k, v in pairs(self.Controller.Holograms) do
        local line = self.Elements.HologramList:AddLine(v.index, v.name == "" and v.model or v.name)

        if self.SelectedHologramIndex == v.index then
            self.SelectedHologramLine = line
        end
    end

    if self.SelectedHologramLine ~= nil then
        self.Elements.HologramList:SelectItem(self.SelectedHologramLine)
    else
        self.Elements.HologramList:SelectFirstItem()
    end

    if #self.Controller.Holograms > 0 then
        self.Elements.Banner:Hide()
        self.Elements.Tabs:Show()
    end
end

function PANEL:UpdateData()
    self.Elements.TransformPosition:SetValue(self.SelectedHologram.position.x, self.SelectedHologram.position.y, self.SelectedHologram.position.z)
    self.Elements.TransformRotation:SetValue(self.SelectedHologram.rotation.x, self.SelectedHologram.rotation.y, self.SelectedHologram.rotation.z)
    self.Elements.TransformScale:SetValue(self.SelectedHologram.scale.x, self.SelectedHologram.scale.y, self.SelectedHologram.scale.z)
end

function PANEL:OnClose()
    if IsValidKHB(self.Controller) then
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
