local addonName, PSB = ...
local Core = {}
PSB.Core = Core

-- Check for PeaversCommons TitleBar
local PeaversCommons = _G.PeaversCommons

function Core:Initialize()
    local config = PSB.Config

    -- Create main frame
    self.frame = CreateFrame("Frame", "PeaversSystemBarsFrame", UIParent, "BackdropTemplate")
    self.frame:SetSize(config.frameWidth, 100) -- Height will be adjusted
    self.frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
    })
    self.frame:SetBackdropColor(config.bgColor.r, config.bgColor.g, config.bgColor.b, config.bgAlpha)
    self.frame:SetBackdropBorderColor(0, 0, 0, config.bgAlpha)

    -- Create title bar using PeaversCommons if available
    if PeaversCommons and PeaversCommons.TitleBar then
        self.titleBar = PeaversCommons.TitleBar:Create(self.frame, PSB)
    else
        -- Create a simple title bar fallback
        self:CreateSimpleTitleBar()
    end

    -- Create content frame for bars
    self.contentFrame = CreateFrame("Frame", nil, self.frame)
    local titleBarHeight = config.showTitleBar and 20 or 0
    self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -titleBarHeight)
    self.contentFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)

    -- Update title bar visibility
    self:UpdateTitleBarVisibility()

    -- Create the bars
    PSB.BarManager:CreateBars(self.contentFrame)

    -- Adjust frame height based on bars
    self:AdjustFrameHeight()

    -- Set frame position
    self.frame:SetPoint(config.framePoint, config.frameX, config.frameY)

    -- Set up dragging
    self:UpdateFrameLock()

    -- Show frame if configured
    if config.showOnLogin then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

-- Create a simple title bar if PeaversCommons.TitleBar is not available
function Core:CreateSimpleTitleBar()
    local config = PSB.Config

    local titleBar = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    titleBar:SetHeight(20)
    titleBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = nil,
    })
    titleBar:SetBackdropColor(0.15, 0.15, 0.15, 1)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    titleText:SetText("|cff3abdf7Peavers|rSystemBars")
    titleText:SetTextColor(1, 1, 1)

    local versionText = titleBar:CreateFontString(nil, "OVERLAY")
    versionText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    versionText:SetPoint("RIGHT", titleBar, "RIGHT", -5, 0)
    versionText:SetText("v" .. (PSB.version or "1.0.0"))
    versionText:SetTextColor(0.7, 0.7, 0.7)

    self.titleBar = titleBar
end

function Core:AdjustFrameHeight()
    PSB.BarManager:AdjustFrameHeight(self.frame, self.contentFrame, PSB.Config.showTitleBar)
end

function Core:UpdateFrameLock()
    local config = PSB.Config

    if config.lockPosition then
        self.frame:SetMovable(false)
        self.frame:EnableMouse(true)
        self.frame:RegisterForDrag("")
        self.frame:SetScript("OnDragStart", nil)
        self.frame:SetScript("OnDragStop", nil)

        self.contentFrame:SetMovable(false)
        self.contentFrame:EnableMouse(true)
        self.contentFrame:RegisterForDrag("")
        self.contentFrame:SetScript("OnDragStart", nil)
        self.contentFrame:SetScript("OnDragStop", nil)
    else
        self.frame:SetMovable(true)
        self.frame:EnableMouse(true)
        self.frame:RegisterForDrag("LeftButton")
        self.frame:SetScript("OnDragStart", self.frame.StartMoving)
        self.frame:SetScript("OnDragStop", function(frame)
            frame:StopMovingOrSizing()

            local point, _, _, x, y = frame:GetPoint()
            config.framePoint = point
            config.frameX = x
            config.frameY = y
            config:Save()
        end)

        self.contentFrame:SetMovable(true)
        self.contentFrame:EnableMouse(true)
        self.contentFrame:RegisterForDrag("LeftButton")
        self.contentFrame:SetScript("OnDragStart", function()
            self.frame:StartMoving()
        end)
        self.contentFrame:SetScript("OnDragStop", function()
            self.frame:StopMovingOrSizing()

            local point, _, _, x, y = self.frame:GetPoint()
            config.framePoint = point
            config.frameX = x
            config.frameY = y
            config:Save()
        end)
    end
end

function Core:UpdateTitleBarVisibility()
    local config = PSB.Config

    if self.titleBar then
        if config.showTitleBar then
            self.titleBar:Show()
        else
            self.titleBar:Hide()
        end

        -- Update content frame position
        local titleBarHeight = config.showTitleBar and 20 or 0
        self.contentFrame:ClearAllPoints()
        self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -titleBarHeight)
        self.contentFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)

        self:AdjustFrameHeight()
        self:UpdateFrameLock()
    end
end

-- Apply frame position from config (useful after loading)
function Core:ApplyFramePosition()
    if self.frame and PSB.Config then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(
            PSB.Config.framePoint or "CENTER",
            PSB.Config.frameX or 0,
            PSB.Config.frameY or 0
        )
    end
end

return Core
