local PANEL = {}

local function OnTextEntryValueChange(self, entry, value, scratch)
    if not entry:IsEditing() then
        return
    end

    value = tonumber(value) or 0

    local _value = math.Clamp(value, self:GetMin(), self:GetMax())
    _value = math.Round(_value, self:GetDecimals())

    if value ~= _value then
        entry:SetText(_value)
    end

    scratch:SetValue(_value)
    self:OnValueChanged(self:GetValue())
end

local function OnScratchValueChanged(self, scratch, value, entry)
    if not scratch:IsEditing() then
        return
    end

    entry:SetValue(math.Round(value, self:GetDecimals()))
    self:OnValueChanged(self:GetValue())
end

function PANEL:Init()
    self:SetBackgroundColor(Color(0, 0, 0, 0))
    self:SetTall(37)
    self:DockMargin(0, 3, 0, 3)

    -- Label

    self.Label = vgui.Create("DLabel", self)
    self.Label:Dock(FILL)
    self.Label:SetTextColor(Color(255, 255, 255, 255))
    self.Label:SetContentAlignment(4)

    -- Z
    local zPanel = vgui.Create("DPanel", self)
    zPanel:Dock(RIGHT)
    zPanel:SetBackgroundColor(Color(0, 0, 0, 0))

    self.ZLabel = vgui.Create("DLabel", zPanel)
    self.ZLabel:Dock(TOP)
    self.ZLabel:DockMargin(0, 0, 0, -3)
    self.ZLabel:SetMouseInputEnabled(true)
    self.ZLabel:SetContentAlignment(8)
    self.ZLabel:SetTextColor(Color(255, 255, 255, 255))

    self.ZTextEntry = vgui.Create("DTextEntry", zPanel)
    self.ZTextEntry:Dock(TOP)
    self.ZTextEntry:SetNumeric(true)
    self.ZTextEntry.OnValueChange = function(entry, value)
        OnTextEntryValueChange(self, entry, value, self.ZScratch)
    end

    self.ZScratch = vgui.Create("DNumberScratch", self.ZLabel)
    self.ZScratch:Dock(FILL)
    self.ZScratch:SetImageVisible(false)
    self.ZScratch:SetValue(0)
    self.ZScratch.OnValueChanged = function(scratch, value)
        OnScratchValueChanged(self, scratch, value, self.ZTextEntry)
    end

    -- Y
    local yPanel = vgui.Create("DPanel", self)
    yPanel:Dock(RIGHT)
    yPanel:DockMargin(6, 0, 6, 0)
    yPanel:SetBackgroundColor(Color(0, 0, 0, 0))

    self.YLabel = vgui.Create("DLabel", yPanel)
    self.YLabel:Dock(TOP)
    self.YLabel:DockMargin(0, 0, 0, -3)
    self.YLabel:SetMouseInputEnabled(true)
    self.YLabel:SetContentAlignment(8)
    self.YLabel:SetTextColor(Color(255, 255, 255, 255))

    self.YTextEntry = vgui.Create("DTextEntry", yPanel)
    self.YTextEntry:Dock(TOP)
    self.YTextEntry:SetNumeric(true)
    self.YTextEntry.OnValueChange = function(entry, value)
        OnTextEntryValueChange(self, entry, value, self.YScratch)
    end

    self.YScratch = vgui.Create("DNumberScratch", self.YLabel)
    self.YScratch:Dock(FILL)
    self.YScratch:SetImageVisible(false)
    self.YScratch:SetValue(0)
    self.YScratch.OnValueChanged = function(scratch, value)
        OnScratchValueChanged(self, scratch, value, self.YTextEntry)
    end

    -- X
    local xPanel = vgui.Create("DPanel", self)
    xPanel:Dock(RIGHT)
    xPanel:SetTall(300)
    xPanel:SetBackgroundColor(Color(0, 0, 0, 0))

    self.XLabel = vgui.Create("DLabel", xPanel)
    self.XLabel:Dock(TOP)
    self.XLabel:DockMargin(0, 0, 0, -3)
    self.XLabel:SetMouseInputEnabled(true)
    self.XLabel:SetContentAlignment(8)
    self.XLabel:SetTextColor(Color(255, 255, 255, 255))

    self.XTextEntry = vgui.Create("DTextEntry", xPanel)
    self.XTextEntry:Dock(TOP)
    self.XTextEntry:SetNumeric(true)
    self.XTextEntry.OnValueChange = function(entry, value)
        OnTextEntryValueChange(self, entry, value, self.XScratch)
    end

    self.XScratch = vgui.Create("DNumberScratch", self.XLabel)
    self.XScratch:Dock(FILL)
    self.XScratch:SetImageVisible(false)
    self.XScratch:SetValue(0)
    self.XScratch.OnValueChanged = function(scratch, value)
        OnScratchValueChanged(self, scratch, value, self.XTextEntry)
    end

    self:SetText("Vector")
    self:SetXText("X")
    self:SetYText("Y")
    self:SetZText("Z")
    self:SetMin(-500)
    self:SetMax(500)
    self:SetDecimals(2)
    self:SetValue(0, 0, 0)
end

function PANEL:SetText(text)
    self.Label:SetText(text)
end

function PANEL:GetText()
    return self.Label:GetText()
end

function PANEL:SetXText(text)
    self.XLabel:SetText(text)
end

function PANEL:GetXText()
    return self.XLabel:GetText()
end

function PANEL:SetYText(text)
    self.YLabel:SetText(text)
end

function PANEL:GetYText()
    return self.YLabel:GetText()
end

function PANEL:SetZText(text)
    self.ZLabel:SetText(text)
end

function PANEL:GetZText()
    return self.ZLabel:GetText()
end

function PANEL:SetMin(value)
    self.XScratch:SetMin(value)
    self.YScratch:SetMin(value)
    self.ZScratch:SetMin(value)
end

function PANEL:GetMin()
    return (self.XScratch:GetMin() + self.YScratch:GetMin() + self.ZScratch:GetMin()) / 3
end

function PANEL:SetMax(value)
    self.XScratch:SetMax(value)
    self.YScratch:SetMax(value)
    self.ZScratch:SetMax(value)
end

function PANEL:GetMax()
    return (self.XScratch:GetMax() + self.YScratch:GetMax() + self.ZScratch:GetMax()) / 3
end

function PANEL:IsEditing()
    return self.XScratch:IsEditing() or self.YScratch:IsEditing() or self.ZScratch:IsEditing() or self.XTextEntry:IsEditing() or self.YTextEntry:IsEditing() or
               self.ZTextEntry:IsEditing()
end

function PANEL:SetDecimals(num)
    self.XScratch:SetDecimals(num)
    self.YScratch:SetDecimals(num)
    self.ZScratch:SetDecimals(num)
end

function PANEL:GetDecimals()
    return (self.XScratch:GetDecimals() + self.YScratch:GetDecimals() + self.ZScratch:GetDecimals()) / 3
end

function PANEL:SetValue(x, y, z)
    x = math.Clamp(tonumber(x) or 0, self:GetMin(), self:GetMax())
    y = math.Clamp(tonumber(y) or 0, self:GetMin(), self:GetMax())
    z = math.Clamp(tonumber(z) or 0, self:GetMin(), self:GetMax())

    x = math.Round(x, self:GetDecimals())
    y = math.Round(y, self:GetDecimals())
    z = math.Round(z, self:GetDecimals())

    self.XScratch:SetValue(x)
    self.XTextEntry:SetText(x)
    self.YScratch:SetValue(y)
    self.YTextEntry:SetText(y)
    self.ZScratch:SetValue(z)
    self.ZTextEntry:SetText(z)
end

function PANEL:GetValue()
    return self.XTextEntry:GetValue(), self.YTextEntry:GetValue(), self.ZTextEntry:GetValue()
end

function PANEL:SetXValue(value)
    value = math.Clamp(tonumber(value) or 0, self:GetMin(), self:GetMax())
    value = math.Round(value, self:GetDecimals())

    self.XScratch:SetValue(value)
    self.XTextEntry:SetValue(value)
end

function PANEL:SetYValue(value)
    value = math.Clamp(tonumber(value) or 0, self:GetMin(), self:GetMax())
    value = math.Round(value, self:GetDecimals())

    self.YScratch:SetValue(value)
    self.YTextEntry:SetValue(value)
end

function PANEL:SetZValue(value)
    value = math.Clamp(tonumber(value) or 0, self:GetMin(), self:GetMax())
    value = math.Round(value, self:GetDecimals())

    self.ZScratch:SetValue(value)
    self.ZTextEntry:SetValue(value)
end

function PANEL:OnValueChanged(x, y, z)
    -- For override
end

derma.DefineControl("DVector", "Vector control", PANEL, "DPanel")
