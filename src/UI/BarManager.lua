local addonName, PSB = ...

-- Initialize BarManager namespace
PSB.BarManager = {}
local BarManager = PSB.BarManager

-- Store references to created bars
BarManager.bars = {}

-- Enable smooth animation
BarManager.smoothAnimation = true
BarManager.animationDuration = 0.3

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

    -- Bars are always flush with frame edges (no padding)
    local barWidth = config.frameWidth
    local barHeight = config.barHeight
    local spacing = config.barSpacing

    local yOffset = 0 -- Start at top edge

    for i, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
        local color = PSB.SystemStats:GetColor(statType)
        local name = PSB.SystemStats:GetName(statType)

        -- Create bar frame
        local barFrame = CreateFrame("Frame", "PSBBar_" .. statType, contentFrame, "BackdropTemplate")
        barFrame:SetSize(barWidth, barHeight)
        barFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)

        -- Bar background (unfilled portion)
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

        -- Label text (left side - stat name) - only create if showStatNames is enabled
        local labelText = nil
        if config.showStatNames then
            labelText = statusBar:CreateFontString(nil, "OVERLAY")
            labelText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)
            labelText:SetPoint("LEFT", statusBar, "LEFT", 4, 0)
            labelText:SetText(name)
            labelText:SetTextColor(1, 1, 1)
            if config.fontShadow then
                labelText:SetShadowOffset(1, -1)
            end
        end

        -- Value text (right side - current value) - only create if showStatValues is enabled
        local valueText = nil
        if config.showStatValues then
            valueText = statusBar:CreateFontString(nil, "OVERLAY")
            valueText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)
            valueText:SetPoint("RIGHT", statusBar, "RIGHT", -4, 0)
            valueText:SetText("0")
            valueText:SetTextColor(1, 1, 1)
            if config.fontShadow then
                valueText:SetShadowOffset(1, -1)
            end
        end

        -- Store bar reference
        local bar = {
            frame = barFrame,
            statusBar = statusBar,
            labelText = labelText,
            valueText = valueText,
            statType = statType,
            currentValue = 0,
            targetValue = 0,
        }

        -- Initialize animation system for this bar
        self:InitBarAnimation(bar)

        self.bars[statType] = bar

        yOffset = yOffset - (barHeight + spacing)
    end
end

-- Initialize animation system for a bar
function BarManager:InitBarAnimation(bar)
    bar.animationGroup = bar.statusBar:CreateAnimationGroup()
    bar.valueAnimation = bar.animationGroup:CreateAnimation("Progress")
    bar.valueAnimation:SetDuration(self.animationDuration)
    bar.valueAnimation:SetSmoothing("OUT")

    bar.valueAnimation:SetScript("OnUpdate", function(anim)
        local progress = anim:GetProgress()
        local startValue = anim.startValue or 0
        local changeValue = anim.changeValue or 0
        local currentValue = startValue + (changeValue * progress)

        bar.statusBar:SetValue(currentValue)
    end)
end

-- Animate bar to a new value
function BarManager:AnimateBarToValue(bar, newValue)
    if not bar.animationGroup then
        bar.statusBar:SetValue(newValue)
        return
    end

    bar.animationGroup:Stop()

    local currentValue = bar.statusBar:GetValue()

    if math.abs(newValue - currentValue) >= 0.5 then
        bar.valueAnimation.startValue = currentValue
        bar.valueAnimation.changeValue = newValue - currentValue
        bar.animationGroup:Play()
    else
        bar.statusBar:SetValue(newValue)
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
            -- Update status bar min/max
            bar.statusBar:SetMinMaxValues(0, data.maxValue)

            -- Use smooth animation if enabled, otherwise set directly
            if self.smoothAnimation then
                self:AnimateBarToValue(bar, data.value)
            else
                bar.statusBar:SetValue(data.value)
            end

            -- Update value text with unit (only if it exists)
            if bar.valueText then
                bar.valueText:SetText(data.value .. " " .. data.unit)
            end
        end
    end
end

-- Resize bars when config changes
function BarManager:ResizeBars()
    local config = PSB.Config

    -- Bars are always flush with frame edges (no padding)
    local barWidth = config.frameWidth
    local barHeight = config.barHeight
    local spacing = config.barSpacing

    local yOffset = 0

    for _, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
        local bar = self.bars[statType]
        if bar then
            bar.frame:SetSize(barWidth, barHeight)
            bar.frame:SetPoint("TOPLEFT", bar.frame:GetParent(), "TOPLEFT", 0, yOffset)

            -- Update bar background alpha
            bar.frame:SetBackdropColor(0.1, 0.1, 0.1, config.barBgAlpha)

            -- Update status bar texture and alpha
            bar.statusBar:SetStatusBarTexture(config.barTexture)
            local color = PSB.SystemStats:GetColor(statType)
            bar.statusBar:SetStatusBarColor(color.r, color.g, color.b, config.barAlpha)

            -- Update font (only if text elements exist)
            if bar.labelText then
                bar.labelText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)
                if config.fontShadow then
                    bar.labelText:SetShadowOffset(1, -1)
                else
                    bar.labelText:SetShadowOffset(0, 0)
                end
            end

            if bar.valueText then
                bar.valueText:SetFont(config.fontFace or "Fonts\\FRIZQT__.TTF", config.fontSize, config.fontOutline)
                if config.fontShadow then
                    bar.valueText:SetShadowOffset(1, -1)
                else
                    bar.valueText:SetShadowOffset(0, 0)
                end
            end

            yOffset = yOffset - (barHeight + spacing)
        end
    end
end

-- Calculate the total height needed for all bars
function BarManager:GetTotalBarsHeight()
    local config = PSB.Config
    local barCount = #PSB.SystemStats.STAT_ORDER

    -- No padding - bars are flush with edges
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
