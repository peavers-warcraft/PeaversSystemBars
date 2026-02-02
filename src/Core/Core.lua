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

    -- Apply background based on showFrameBackground setting
    if config.showFrameBackground then
        self.frame:SetBackdrop({
            bgFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeFile = "Interface\\BUTTONS\\WHITE8X8",
            tile = true, tileSize = 16, edgeSize = 1,
        })
        self.frame:SetBackdropColor(config.bgColor.r, config.bgColor.g, config.bgColor.b, config.bgAlpha)
        self.frame:SetBackdropBorderColor(0, 0, 0, config.bgAlpha)
    else
        -- No backdrop when background is disabled
        self.frame:SetBackdrop(nil)
    end

    -- Create title bar using PeaversCommons
    self.titleBar = PeaversCommons.TitleBar:Create(self.frame, PSB.Config, {
        title = "PSB",
        version = PSB.version or "1.0.0",
        leftPadding = 5
    })

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

function Core:AdjustFrameHeight()
    PSB.BarManager:AdjustFrameHeight(self.frame, self.contentFrame, PSB.Config.showTitleBar)
end

function Core:UpdateFrameLock()
	PeaversCommons.FrameLock:ApplyFromConfig(
		self.frame,
		self.contentFrame,
		PSB.Config,
		function() PSB.Config:Save() end
	)
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

function Core:UpdateFrameBackground()
    local config = PSB.Config

    if self.frame then
        if config.showFrameBackground then
            -- Show background with border
            self.frame:SetBackdrop({
                bgFile = "Interface\\BUTTONS\\WHITE8X8",
                edgeFile = "Interface\\BUTTONS\\WHITE8X8",
                tile = true, tileSize = 16, edgeSize = 1,
            })
            self.frame:SetBackdropColor(config.bgColor.r, config.bgColor.g, config.bgColor.b, config.bgAlpha)
            self.frame:SetBackdropBorderColor(0, 0, 0, config.bgAlpha)
        else
            -- Remove backdrop entirely (no background, no border)
            self.frame:SetBackdrop(nil)
        end

        -- Recreate bars to update positioning
        if PSB.BarManager and self.contentFrame then
            PSB.BarManager:CreateBars(self.contentFrame)
            self:AdjustFrameHeight()
        end
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
