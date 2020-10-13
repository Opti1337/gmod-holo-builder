builder = {}
builder.Holos = {}
local scrW, scrH = ScrW(), ScrH()
local ply = LocalPlayer()

function CreateBuilder()
    local width, height = 400, 500
    local margin = 15

    builder.Frame = vgui.Create("DFrame")
    builder.Frame:SetTitle("Holo Builder")
    builder.Frame:SetSize(width, height)
    builder.Frame:SetPos(ScrW() - (width + margin), 0)
    builder.Frame:CenterVertical()
    builder.Frame:ShowCloseButton(false)
    builder.Frame:SetSizable(false)
    builder.Frame:SetScreenLock(true)

    local menuBar = vgui.Create("DMenuBar", builder.Frame)
    menuBar:DockMargin(-3, -6, -3, 6)

    local fileMenu = menuBar:AddMenu("Project")
    fileMenu:AddOption("New")
    fileMenu:AddOption("Open")

    fileMenu:AddSpacer()

    local exportSubMenu = fileMenu:AddSubMenu("Export")
    exportSubMenu:SetDeleteSelf(false)
    exportSubMenu:AddOption("To E2 holograms")

    fileMenu:AddSpacer()

    fileMenu:AddOption("Exit", function()
        builder.Frame:Close()
        gui.EnableScreenClicker(false)
    end)

    local createMenu = menuBar:AddMenu("Create")
    createMenu:AddOption("Cube", function()
        local holo = ents.CreateClientProp()
        holo:SetPos(ply:GetPos())
        holo:SetModel("models/props_borealis/bluebarrel001.mdl")
        holo:Spawn()
        table.insert(builder.Holos, holo:EntIndex(), holo)
    end)
    createMenu:AddOption("Delete all", function()
        for k, v in pairs(builder.Holos) do v:Remove() end

        table.Empty(builder.Holos)
    end)

    local tabs = vgui.Create("DPropertySheet", builder.Frame)
    tabs:Dock(FILL)

    local positioningTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Positioning", positioningTab)

    local label = vgui.Create("DLabel", positioningTab)
    label:SetText("Positioning")
    label:SetColor(Color(255,0,0))

    local clippingTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Clipping", clippingTab)

    vgui.Create("DLabel", clippingTab):SetText("Clipping")

    local mirroringTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Mirroring", mirroringTab)

    local visualsTab = vgui.Create("DPanel", tabs)
    tabs:AddSheet("Visuals", visualsTab)

    local holoList = vgui.Create("DListView", builder.Frame)
    holoList:Dock(BOTTOM)
    holoList:DockMargin(0, 3, 0, 0)
    holoList:SetMultiSelect(false)
    holoList:SetHeight(100)

    holoList:AddColumn("ID"):SetFixedWidth(30)
    holoList:AddColumn("Name")
end

concommand.Add("holo_builder", function()
    if IsValid(builder.Frame) then
        builder.Frame:ToggleVisible()

        gui.EnableScreenClicker(builder.Frame:IsVisible())

        local x, y, width, height = builder.Frame:GetBounds()
        input.SetCursorPos(x + width / 2, y + height / 2)
    else
        CreateBuilder()

        gui.EnableScreenClicker(true)

        local x, y, width, height = builder.Frame:GetBounds()
        input.SetCursorPos(x + width / 2, y + height / 2)
    end
end)

