local addonName, PSB = ...

--------------------------------------------------------------------------------
-- PSB BarManager - Manages system stat bars (FPS, latency)
-- Uses AnimatedStatusBar and BarTextManager for clean composition
--------------------------------------------------------------------------------

local PeaversCommons = _G.PeaversCommons
local AnimatedStatusBar = PeaversCommons.AnimatedStatusBar
local BarTextManager = PeaversCommons.BarTextManager
local BaseBarManager = PeaversCommons.BarManager

-- Initialize BarManager namespace
PSB.BarManager = {}
local BarManager = PSB.BarManager

-- Inherit from base BarManager for common methods
setmetatable(BarManager, { __index = BaseBarManager })

-- Store references to created bars
BarManager.bars = {}
BarManager.barList = {}

--------------------------------------------------------------------------------
-- Bar Creation
--------------------------------------------------------------------------------

-- Create all bars in the content frame
function BarManager:CreateBars(contentFrame)
    -- Clear existing bars
    for _, bar in pairs(self.bars) do
        if bar.statusBar then
            bar.statusBar:Destroy()
        end
        if bar.textManager then
            bar.textManager:Destroy()
        end
    end
    self.bars = {}
    self.barList = {}

    local config = PSB.Config
    local barHeight = config.barHeight
    local spacing = config.barSpacing

    local yOffset = 0

    for i, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
        local color = PSB.SystemStats:GetColor(statType)
        local name = PSB.SystemStats:GetName(statType)

        -- Create container frame
        local container = CreateFrame("Frame", "PSBBar_" .. statType, contentFrame)
        container:SetHeight(barHeight)
        container:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
        container:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", 0, yOffset)

        -- Create animated status bar
        local statusBar = AnimatedStatusBar:New(container, {
            texture = config.barTexture,
            bgAlpha = config.barBgAlpha,
            barAlpha = config.barAlpha,
            color = color,
            minValue = 0,
            maxValue = 100,
            showBackground = true,
        })
        statusBar:SetAllPoints(container)

        -- Create text manager (only if text is enabled)
        local textManager = nil
        if config.showStatNames or config.showStatValues then
            textManager = BarTextManager:New(statusBar:GetStatusBar(), {
                showName = config.showStatNames,
                showValue = config.showStatValues,
                showChange = false,
                fontFace = config.fontFace,
                fontSize = config.fontSize,
                fontOutline = config.fontOutline,
                fontShadow = config.fontShadow,
                name = name,
            })
        end

        -- Store bar reference
        local bar = {
            container = container,
            statusBar = statusBar,
            textManager = textManager,
            statType = statType,
            color = color,
        }

        self.bars[statType] = bar
        table.insert(self.barList, bar)

        yOffset = yOffset - (barHeight + spacing)
    end
end

--------------------------------------------------------------------------------
-- Bar Updates
--------------------------------------------------------------------------------

-- Update all bars with current values
function BarManager:UpdateAllBars()
    -- First update the stats (record samples)
    PSB.SystemStats:Update()

    -- Then get all current values
    local stats = PSB.SystemStats:GetAllStats()

    for statType, data in pairs(stats) do
        local bar = self.bars[statType]
        if bar then
            -- Update status bar min/max and value
            bar.statusBar:SetMinMaxValues(0, data.maxValue)
            bar.statusBar:SetValue(data.value)

            -- Update value text with unit (e.g., "60 FPS")
            if bar.textManager then
                bar.textManager:SetValueWithUnit(data.value, data.unit)
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Bar Resizing
--------------------------------------------------------------------------------

-- Resize bars when config changes
function BarManager:ResizeBars()
    local config = PSB.Config
    local barHeight = config.barHeight
    local spacing = config.barSpacing

    local yOffset = 0

    for _, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
        local bar = self.bars[statType]
        if bar then
            -- Update container size and position
            bar.container:SetHeight(barHeight)
            bar.container:ClearAllPoints()
            bar.container:SetPoint("TOPLEFT", bar.container:GetParent(), "TOPLEFT", 0, yOffset)
            bar.container:SetPoint("TOPRIGHT", bar.container:GetParent(), "TOPRIGHT", 0, yOffset)

            -- Update status bar appearance
            bar.statusBar:SetTexture(config.barTexture)
            bar.statusBar:SetBackgroundAlpha(config.barBgAlpha)
            bar.statusBar:SetBarAlpha(config.barAlpha)

            -- Reapply color
            local color = PSB.SystemStats:GetColor(statType)
            bar.statusBar:SetColor(color.r, color.g, color.b, config.barAlpha)

            -- Update text manager if it exists
            if bar.textManager then
                bar.textManager:UpdateFont(
                    config.fontFace,
                    config.fontSize,
                    config.fontOutline,
                    config.fontShadow
                )
            end

            yOffset = yOffset - (barHeight + spacing)
        end
    end
end

--------------------------------------------------------------------------------
-- Height Calculation
--------------------------------------------------------------------------------

-- Calculate the total height needed for all bars
function BarManager:GetTotalBarsHeight()
    local config = PSB.Config
    local barCount = #PSB.SystemStats.STAT_ORDER

    local totalHeight = (barCount * config.barHeight)
    totalHeight = totalHeight + ((barCount - 1) * config.barSpacing)
    return totalHeight
end

-- Adjust the parent frame height based on bar count
function BarManager:AdjustFrameHeight(mainFrame, contentFrame, showTitleBar)
    local barsHeight = self:GetTotalBarsHeight()
    local titleBarHeight = showTitleBar and 20 or 0
    local totalHeight = barsHeight + titleBarHeight

    mainFrame:SetHeight(totalHeight)
end

-- Get bar count
function BarManager:GetBarCount()
    return #self.barList
end

return BarManager
