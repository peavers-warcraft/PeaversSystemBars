local addonName, PSB = ...

-- Initialize BarManager namespace
PSB.BarManager = {}
local BarManager = PSB.BarManager

-- Store references to created bars
BarManager.bars = {}

-- Create all bars in the content frame
function BarManager:CreateBars(contentFrame)
    -- Clear existing bars
    for _, bar in pairs(self.bars) do
        if bar and bar.frame then
            bar.frame:Hide()
            bar.frame:SetParent(nil)
        end
    end
    self.bars = {}

    local config = PSB.Config
    local barWidth = config.frameWidth - 10 -- 5px padding on each side
    local barHeight = config.barHeight
    local spacing = config.barSpacing

    local yOffset = -5 -- Start with some padding from top

    for i, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
        local color = PSB.SystemStats:GetColor(statType)
        local name = PSB.SystemStats:GetName(statType)

        -- Create bar frame
        local barFrame = CreateFrame("Frame", "PSBBar_" .. statType, contentFrame, "BackdropTemplate")
        barFrame:SetSize(barWidth, barHeight)
        barFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 5, yOffset)

        -- Background
        barFrame:SetBackdrop({
            bgFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeFile = nil,
            tile = true, tileSize = 16, edgeSize = 0,
        })
        barFrame:SetBackdropColor(0.1, 0.1, 0.1, config.barBgAlpha)

        -- Status bar (the fill)
        local statusBar = CreateFrame("StatusBar", nil, barFrame)
        statusBar:SetStatusBarTexture(config.barTexture)
        statusBar:SetStatusBarColor(color.r, color.g, color.b, config.barAlpha)
        statusBar:SetAllPoints(barFrame)
        statusBar:SetMinMaxValues(0, 100)
        statusBar:SetValue(0)

        -- Label text (left side - stat name)
        local labelText = statusBar:CreateFontString(nil, "OVERLAY")
        labelText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)
        labelText:SetPoint("LEFT", statusBar, "LEFT", 4, 0)
        labelText:SetText(name)
        labelText:SetTextColor(1, 1, 1)
        if config.fontShadow then
            labelText:SetShadowOffset(1, -1)
        end

        -- Value text (right side - current value)
        local valueText = statusBar:CreateFontString(nil, "OVERLAY")
        valueText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)
        valueText:SetPoint("RIGHT", statusBar, "RIGHT", -4, 0)
        valueText:SetText("0")
        valueText:SetTextColor(1, 1, 1)
        if config.fontShadow then
            valueText:SetShadowOffset(1, -1)
        end

        -- Store bar reference
        self.bars[statType] = {
            frame = barFrame,
            statusBar = statusBar,
            labelText = labelText,
            valueText = valueText,
            statType = statType,
        }

        yOffset = yOffset - (barHeight + spacing)
    end
end

-- Update all bars with current values
function BarManager:UpdateAllBars()
    -- First update the stats (record samples)
    PSB.SystemStats:Update()

    -- Then get all current values
    local stats = PSB.SystemStats:GetAllStats()

    for statType, data in pairs(stats) do
        local bar = self.bars[statType]
        if bar then
            -- Update status bar
            bar.statusBar:SetMinMaxValues(0, data.maxValue)
            bar.statusBar:SetValue(data.value)

            -- Update value text with unit
            bar.valueText:SetText(data.value .. " " .. data.unit)
        end
    end
end

-- Resize bars when config changes
function BarManager:ResizeBars()
    local config = PSB.Config
    local barWidth = config.frameWidth - 10
    local barHeight = config.barHeight
    local spacing = config.barSpacing

    local yOffset = -5

    for _, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
        local bar = self.bars[statType]
        if bar then
            bar.frame:SetSize(barWidth, barHeight)
            bar.frame:SetPoint("TOPLEFT", bar.frame:GetParent(), "TOPLEFT", 5, yOffset)

            -- Update backdrop alpha
            bar.frame:SetBackdropColor(0.1, 0.1, 0.1, config.barBgAlpha)

            -- Update status bar texture and alpha
            bar.statusBar:SetStatusBarTexture(config.barTexture)
            local color = PSB.SystemStats:GetColor(statType)
            bar.statusBar:SetStatusBarColor(color.r, color.g, color.b, config.barAlpha)

            -- Update font
            bar.labelText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)
            bar.valueText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)

            if config.fontShadow then
                bar.labelText:SetShadowOffset(1, -1)
                bar.valueText:SetShadowOffset(1, -1)
            else
                bar.labelText:SetShadowOffset(0, 0)
                bar.valueText:SetShadowOffset(0, 0)
            end

            yOffset = yOffset - (barHeight + spacing)
        end
    end
end

-- Calculate the total height needed for all bars
function BarManager:GetTotalBarsHeight()
    local config = PSB.Config
    local barCount = #PSB.SystemStats.STAT_ORDER
    local totalHeight = 5 -- Initial padding
    totalHeight = totalHeight + (barCount * config.barHeight)
    totalHeight = totalHeight + ((barCount - 1) * config.barSpacing)
    totalHeight = totalHeight + 5 -- Bottom padding
    return totalHeight
end

-- Adjust the parent frame height based on bar count
function BarManager:AdjustFrameHeight(mainFrame, contentFrame, showTitleBar)
    local barsHeight = self:GetTotalBarsHeight()
    local titleBarHeight = showTitleBar and 20 or 0
    local totalHeight = barsHeight + titleBarHeight

    mainFrame:SetHeight(totalHeight)
end
