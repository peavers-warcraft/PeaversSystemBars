local _, PSB = ...
local Config = PSB.Config
local UI = PSB.UI

-- Initialize ConfigUI namespace
local ConfigUI = {}
PSB.ConfigUI = ConfigUI

-- Storage for UI elements that need refreshing
ConfigUI.uiElements = {}

-- Access PeaversCommons utilities
local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r PeaversCommons not found.")
    return
end

local ConfigUIUtils = PeaversCommons.ConfigUIUtils
if not ConfigUIUtils then
    print("|cffff0000Error:|r PeaversCommons.ConfigUIUtils not found.")
    return
end

-- Localization helper
local function L(key, ...)
    if PSB.L and PSB.L.Get then
        return PSB.L:Get(key, ...)
    end
    return key
end

-- Utility functions wrapper
local Utils = {}

function Utils:CreateSlider(parent, name, label, min, max, step, defaultVal, width, callback)
    return ConfigUIUtils.CreateSlider(parent, name, label, min, max, step, defaultVal, width, callback)
end

function Utils:CreateDropdown(parent, name, label, options, defaultOption, width, callback)
    return ConfigUIUtils.CreateDropdown(parent, name, label, options, defaultOption, width, callback)
end

function Utils:CreateCheckbox(parent, name, label, x, y, checked, callback)
    return ConfigUIUtils.CreateCheckbox(parent, name, label, x, y, checked, callback)
end

function Utils:CreateSectionHeader(parent, text, indent, yPos, fontSize)
    return ConfigUIUtils.CreateSectionHeader(parent, text, indent, yPos, fontSize)
end

function Utils:CreateSubsectionLabel(parent, text, indent, y)
    return ConfigUIUtils.CreateSubsectionLabel(parent, text, indent, y)
end

-- Creates a color picker for a stat
function Utils:CreateStatColorPicker(parent, statType, y, indent)
    local color = PSB.SystemStats:GetColor(statType)
    local r, g, b = color.r, color.g, color.b

    -- Check for custom color
    if Config.customColors and Config.customColors[statType] then
        local customColor = Config.customColors[statType]
        r, g, b = customColor.r, customColor.g, customColor.b
    end

    local colorContainer, colorPicker, resetButton, newY = ConfigUIUtils.CreateColorPicker(
        parent,
        "PSBStat" .. statType .. "ColorPicker",
        L("CONFIG_BAR_COLOR"),
        indent,
        y,
        {r = r, g = g, b = b},
        -- Color change handler
        function(newR, newG, newB)
            Config.customColors = Config.customColors or {}
            Config.customColors[statType] = { r = newR, g = newG, b = newB }
            Config:Save()

            -- Update the bar if it exists
            if PSB.BarManager and PSB.BarManager.bars and PSB.BarManager.bars[statType] then
                local bar = PSB.BarManager.bars[statType]
                bar.statusBar:SetStatusBarColor(newR, newG, newB, Config.barAlpha or 1.0)
            end
        end,
        -- Reset handler
        function()
            if Config.customColors then
                Config.customColors[statType] = nil
            end
            Config:Save()

            local defaultColor = PSB.SystemStats:GetColor(statType)
            colorPicker:SetBackdropColor(defaultColor.r, defaultColor.g, defaultColor.b)

            if PSB.BarManager and PSB.BarManager.bars and PSB.BarManager.bars[statType] then
                local bar = PSB.BarManager.bars[statType]
                bar.statusBar:SetStatusBarColor(defaultColor.r, defaultColor.g, defaultColor.b, Config.barAlpha or 1.0)
            end
        end
    )

    return newY
end

-- Creates and initializes the options panel
function ConfigUI:InitializeOptions()
    if not UI then
        print("ERROR: UI module not loaded.")
        return
    end

    local panel = ConfigUIUtils.CreateSettingsPanel(
        "Settings",
        "Configuration options for the system bars display"
    )

    local content = panel.content
    local yPos = panel.yPos
    local baseSpacing = panel.baseSpacing
    local sectionSpacing = panel.sectionSpacing

    -- 1. DISPLAY SETTINGS SECTION
    yPos = self:CreateDisplayOptions(content, yPos, baseSpacing, sectionSpacing)

    -- Add separator
    local _, newY = UI:CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - baseSpacing

    -- 2. BAR APPEARANCE SECTION
    yPos = self:CreateBarAppearanceOptions(content, yPos, baseSpacing, sectionSpacing)

    -- Add separator
    local _, newY = UI:CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - baseSpacing

    -- 3. STAT COLORS SECTION
    yPos = self:CreateStatColorOptions(content, yPos, baseSpacing, sectionSpacing)

    -- Add separator
    local _, newY = UI:CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - baseSpacing

    -- 4. TEXT SETTINGS SECTION
    yPos = self:CreateTextOptions(content, yPos, baseSpacing, sectionSpacing)

    -- Update content height
    panel:UpdateContentHeight(yPos)

    return panel
end

-- 1. DISPLAY SETTINGS
function ConfigUI:CreateDisplayOptions(content, yPos, baseSpacing, sectionSpacing)
    baseSpacing = baseSpacing or 25
    sectionSpacing = sectionSpacing or 40
    local controlIndent = baseSpacing + 15
    local sliderWidth = 400

    -- Section header
    local header, newY = Utils:CreateSectionHeader(content, L("CONFIG_DISPLAY_SETTINGS"), baseSpacing, yPos)
    yPos = newY - 10

    -- Frame dimensions subsection
    local dimensionsLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_FRAME_DIMENSIONS"), controlIndent, yPos)
    yPos = newY - 8

    -- Frame width slider
    local widthContainer, widthSlider = Utils:CreateSlider(
        content, "PSBWidthSlider",
        L("CONFIG_FRAME_WIDTH"), 100, 400, 10,
        Config.frameWidth or 200, sliderWidth,
        function(value)
            Config.frameWidth = value
            Config:Save()
            if PSB.Core and PSB.Core.frame then
                PSB.Core.frame:SetWidth(value)
                if PSB.BarManager then
                    PSB.BarManager:ResizeBars()
                end
            end
        end
    )
    widthContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.widthSlider = widthSlider
    yPos = yPos - 55

    -- Background opacity slider
    local opacityContainer, opacitySlider = Utils:CreateSlider(
        content, "PSBOpacitySlider",
        L("CONFIG_BG_OPACITY"), 0, 1, 0.05,
        Config.bgAlpha or 0.8, sliderWidth,
        function(value)
            Config.bgAlpha = value
            Config:Save()
            if PSB.Core and PSB.Core.frame then
                PSB.Core.frame:SetBackdropColor(
                    Config.bgColor.r,
                    Config.bgColor.g,
                    Config.bgColor.b,
                    Config.bgAlpha
                )
                PSB.Core.frame:SetBackdropBorderColor(0, 0, 0, Config.bgAlpha)
            end
        end
    )
    opacityContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.opacitySlider = opacitySlider
    yPos = yPos - 65

    -- Add separator
    local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
    yPos = newY - 15

    -- Visibility options subsection
    local visibilityLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_VISIBILITY_OPTIONS"), controlIndent, yPos)
    yPos = newY - 8

    -- Show title bar checkbox
    local titleBarCheckbox, newY = Utils:CreateCheckbox(
        content, "PSBTitleBarCheckbox",
        L("CONFIG_SHOW_TITLE_BAR"), controlIndent, yPos,
        Config.showTitleBar ~= false,
        function(checked)
            Config.showTitleBar = checked
            Config:Save()
            if PSB.Core then
                PSB.Core:UpdateTitleBarVisibility()
            end
        end
    )
    self.uiElements.titleBarCheckbox = titleBarCheckbox
    yPos = newY - 8

    -- Lock position checkbox
    local lockPositionCheckbox, newY = Utils:CreateCheckbox(
        content, "PSBLockPositionCheckbox",
        L("CONFIG_LOCK_POSITION"), controlIndent, yPos,
        Config.lockPosition or false,
        function(checked)
            Config.lockPosition = checked
            Config:Save()
            if PSB.Core then
                PSB.Core:UpdateFrameLock()
            end
        end
    )
    self.uiElements.lockPositionCheckbox = lockPositionCheckbox
    yPos = newY - 8

    -- Show frame background checkbox
    local frameBackgroundCheckbox, newY = Utils:CreateCheckbox(
        content, "PSBFrameBackgroundCheckbox",
        L("CONFIG_SHOW_FRAME_BACKGROUND"), controlIndent, yPos,
        Config.showFrameBackground ~= false,
        function(checked)
            Config.showFrameBackground = checked
            Config:Save()
            if PSB.Core then
                PSB.Core:UpdateFrameBackground()
            end
        end
    )
    self.uiElements.frameBackgroundCheckbox = frameBackgroundCheckbox
    yPos = newY - 8

    -- Add separator
    local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
    yPos = newY - 15

    -- Update settings subsection
    local updateLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_UPDATE_SETTINGS"), controlIndent, yPos)
    yPos = newY - 8

    -- Update interval dropdown - use ordered table for consistent display
    local updateIntervalContainer = CreateFrame("Frame", nil, content)
    updateIntervalContainer:SetSize(sliderWidth, 60)
    updateIntervalContainer:SetPoint("TOPLEFT", controlIndent, yPos)

    local intervalLabel = updateIntervalContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    intervalLabel:SetPoint("TOPLEFT", 0, 0)
    intervalLabel:SetText(L("CONFIG_UPDATE_INTERVAL"))

    local intervalDropdown = CreateFrame("Frame", "PSBUpdateIntervalDropdown", updateIntervalContainer, "UIDropDownMenuTemplate")
    intervalDropdown:SetPoint("TOPLEFT", 0, -20)
    UIDropDownMenu_SetWidth(intervalDropdown, sliderWidth - 55)

    -- Ordered interval options
    local intervalOrder = { 0.5, 1, 2, 5, 10 }
    local intervalLabels = {
        [0.5] = "0.5s",
        [1] = "1s",
        [2] = "2s",
        [5] = "5s",
        [10] = "10s",
    }

    -- Set initial text
    local currentInterval = Config.updateInterval or 0.5
    UIDropDownMenu_SetText(intervalDropdown, intervalLabels[currentInterval] or "0.5s")

    UIDropDownMenu_Initialize(intervalDropdown, function(self, level)
        for _, intervalValue in ipairs(intervalOrder) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = intervalLabels[intervalValue]
            info.value = intervalValue
            info.checked = (intervalValue == Config.updateInterval)
            info.func = function()
                Config.updateInterval = intervalValue
                Config:Save()
                UIDropDownMenu_SetText(intervalDropdown, intervalLabels[intervalValue])
                if PSB.UpdateHandler and PSB.UpdateHandler.Restart then
                    PSB.UpdateHandler:Restart()
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    self.uiElements.intervalDropdown = intervalDropdown
    yPos = yPos - 65

    return yPos
end

-- 2. BAR APPEARANCE
function ConfigUI:CreateBarAppearanceOptions(content, yPos, baseSpacing, sectionSpacing)
    baseSpacing = baseSpacing or 25
    sectionSpacing = sectionSpacing or 40
    local controlIndent = baseSpacing + 15
    local sliderWidth = 400

    -- Section header
    local header, newY = Utils:CreateSectionHeader(content, L("CONFIG_BAR_APPEARANCE"), baseSpacing, yPos)
    yPos = newY - 10

    -- Bar dimensions subsection
    local dimensionsLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_BAR_DIMENSIONS"), controlIndent, yPos)
    yPos = newY - 8

    -- Bar height slider
    local heightContainer, heightSlider = Utils:CreateSlider(
        content, "PSBHeightSlider",
        L("CONFIG_BAR_HEIGHT"), 10, 40, 1,
        Config.barHeight or 20, sliderWidth,
        function(value)
            Config.barHeight = value
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    heightContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.heightSlider = heightSlider
    yPos = yPos - 55

    -- Bar spacing slider
    local spacingContainer, spacingSlider = Utils:CreateSlider(
        content, "PSBSpacingSlider",
        L("CONFIG_BAR_SPACING"), -5, 10, 1,
        Config.barSpacing or 2, sliderWidth,
        function(value)
            Config.barSpacing = value
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    spacingContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.spacingSlider = spacingSlider
    yPos = yPos - 65

    -- Bar background opacity slider
    local bgOpacityContainer, bgOpacitySlider = Utils:CreateSlider(
        content, "PSBBarBgAlphaSlider",
        L("CONFIG_BAR_BG_OPACITY"), 0, 1, 0.05,
        Config.barBgAlpha or 0.5, sliderWidth,
        function(value)
            Config.barBgAlpha = value
            Config:Save()
            if PSB.BarManager then
                PSB.BarManager:ResizeBars()
            end
        end
    )
    bgOpacityContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.bgOpacitySlider = bgOpacitySlider
    yPos = yPos - 65

    -- Bar fill opacity slider
    local barOpacityContainer, barOpacitySlider = Utils:CreateSlider(
        content, "PSBBarAlphaSlider",
        L("CONFIG_BAR_OPACITY"), 0, 1, 0.05,
        Config.barAlpha or 1.0, sliderWidth,
        function(value)
            Config.barAlpha = value
            Config:Save()
            if PSB.BarManager then
                PSB.BarManager:ResizeBars()
            end
        end
    )
    barOpacityContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.barOpacitySlider = barOpacitySlider
    yPos = yPos - 65

    -- Add separator
    local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
    yPos = newY - 15

    -- Bar style subsection
    local styleLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_BAR_STYLE"), controlIndent, yPos)
    yPos = newY - 8

    -- Texture dropdown
    local textures = Config:GetBarTextures()
    local currentTexture = textures[Config.barTexture] or "Default"

    local textureContainer, textureDropdown = Utils:CreateDropdown(
        content, "PSBTextureDropdown",
        L("CONFIG_BAR_TEXTURE"), textures,
        currentTexture, sliderWidth,
        function(value)
            Config.barTexture = value
            Config:Save()
            if PSB.BarManager then
                PSB.BarManager:ResizeBars()
            end
        end
    )
    textureContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.textureDropdown = textureDropdown
    yPos = yPos - 65

    return yPos
end

-- 3. STAT COLORS
function ConfigUI:CreateStatColorOptions(content, yPos, baseSpacing, sectionSpacing)
    baseSpacing = baseSpacing or 25
    sectionSpacing = sectionSpacing or 40
    local controlIndent = baseSpacing + 15

    -- Section header
    local header, newY = Utils:CreateSectionHeader(content, L("CONFIG_STAT_COLORS"), baseSpacing, yPos)
    yPos = newY - 10

    -- Create color pickers for each stat
    for i, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
        local statName = PSB.SystemStats:GetName(statType)

        -- Stat header
        local statHeader, newY = Utils:CreateSectionHeader(content, statName, baseSpacing + 25, yPos, 14)
        yPos = newY

        -- Color picker
        yPos = Utils:CreateStatColorPicker(content, statType, yPos, baseSpacing + 40)

        -- Add separator between stats (except last)
        if i < #PSB.SystemStats.STAT_ORDER then
            local _, newY = UI:CreateSeparator(content, baseSpacing + 30, yPos, 380)
            yPos = newY - 5
        end
    end

    return yPos - 15
end

-- 4. TEXT SETTINGS
function ConfigUI:CreateTextOptions(content, yPos, baseSpacing, sectionSpacing)
    baseSpacing = baseSpacing or 25
    sectionSpacing = sectionSpacing or 40
    local controlIndent = baseSpacing + 15
    local sliderWidth = 400

    -- Section header
    local header, newY = Utils:CreateSectionHeader(content, L("CONFIG_TEXT_SETTINGS"), baseSpacing, yPos)
    yPos = newY - 10

    -- Font selection subsection
    local fontSelectLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_FONT_SELECTION"), controlIndent, yPos)
    yPos = newY - 8

    -- Font dropdown
    local fonts = Config:GetFonts()
    local currentFont = fonts[Config.fontFace] or "Default"

    local fontContainer, fontDropdown = Utils:CreateDropdown(
        content, "PSBFontDropdown",
        L("CONFIG_FONT"), fonts,
        currentFont, sliderWidth,
        function(value)
            Config.fontFace = value
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    fontContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.fontDropdown = fontDropdown
    yPos = yPos - 65

    -- Font size slider
    local fontSizeContainer, fontSizeSlider = Utils:CreateSlider(
        content, "PSBFontSizeSlider",
        L("CONFIG_FONT_SIZE"), 6, 18, 1,
        Config.fontSize or 9, sliderWidth,
        function(value)
            Config.fontSize = value
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    fontSizeContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    self.uiElements.fontSizeSlider = fontSizeSlider
    yPos = yPos - 55

    -- Font style options
    local fontStyleLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_FONT_STYLE"), controlIndent, yPos)
    yPos = newY - 8

    -- Font outline checkbox
    local fontOutlineCheckbox, newY = Utils:CreateCheckbox(
        content, "PSBFontOutlineCheckbox",
        L("CONFIG_FONT_OUTLINE"), controlIndent, yPos,
        Config.fontOutline == "OUTLINE",
        function(checked)
            Config.fontOutline = checked and "OUTLINE" or ""
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    self.uiElements.fontOutlineCheckbox = fontOutlineCheckbox
    yPos = newY - 8

    -- Font shadow checkbox
    local fontShadowCheckbox, newY = Utils:CreateCheckbox(
        content, "PSBFontShadowCheckbox",
        L("CONFIG_FONT_SHADOW"), controlIndent, yPos,
        Config.fontShadow or false,
        function(checked)
            Config.fontShadow = checked
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    self.uiElements.fontShadowCheckbox = fontShadowCheckbox
    yPos = newY - 15

    -- Add separator
    local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
    yPos = newY - 15

    -- Text display subsection
    local textDisplayLabel, newY = Utils:CreateSubsectionLabel(content, L("CONFIG_TEXT_DISPLAY"), controlIndent, yPos)
    yPos = newY - 8

    -- Show stat names checkbox
    local showStatNamesCheckbox, newY = Utils:CreateCheckbox(
        content, "PSBShowStatNamesCheckbox",
        L("CONFIG_SHOW_STAT_NAMES"), controlIndent, yPos,
        Config.showStatNames ~= false,
        function(checked)
            Config.showStatNames = checked
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    self.uiElements.showStatNamesCheckbox = showStatNamesCheckbox
    yPos = newY - 8

    -- Show stat values checkbox
    local showStatValuesCheckbox, newY = Utils:CreateCheckbox(
        content, "PSBShowStatValuesCheckbox",
        L("CONFIG_SHOW_STAT_VALUES"), controlIndent, yPos,
        Config.showStatValues ~= false,
        function(checked)
            Config.showStatValues = checked
            Config:Save()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
        end
    )
    self.uiElements.showStatValuesCheckbox = showStatValuesCheckbox
    yPos = newY - 15

    return yPos
end

-- Refresh all UI elements
function ConfigUI:RefreshUI()
    if not self.uiElements then return end

    if self.uiElements.widthSlider then
        self.uiElements.widthSlider:SetValue(Config.frameWidth or 200)
    end
    if self.uiElements.opacitySlider then
        self.uiElements.opacitySlider:SetValue(Config.bgAlpha or 0.8)
    end
    if self.uiElements.heightSlider then
        self.uiElements.heightSlider:SetValue(Config.barHeight or 20)
    end
    if self.uiElements.spacingSlider then
        self.uiElements.spacingSlider:SetValue(Config.barSpacing or 2)
    end
    if self.uiElements.bgOpacitySlider then
        self.uiElements.bgOpacitySlider:SetValue(Config.barBgAlpha or 0.5)
    end
    if self.uiElements.barOpacitySlider then
        self.uiElements.barOpacitySlider:SetValue(Config.barAlpha or 1.0)
    end
    if self.uiElements.fontSizeSlider then
        self.uiElements.fontSizeSlider:SetValue(Config.fontSize or 9)
    end
    if self.uiElements.titleBarCheckbox then
        self.uiElements.titleBarCheckbox:SetChecked(Config.showTitleBar ~= false)
    end
    if self.uiElements.lockPositionCheckbox then
        self.uiElements.lockPositionCheckbox:SetChecked(Config.lockPosition or false)
    end
    if self.uiElements.frameBackgroundCheckbox then
        self.uiElements.frameBackgroundCheckbox:SetChecked(Config.showFrameBackground ~= false)
    end
    if self.uiElements.fontOutlineCheckbox then
        self.uiElements.fontOutlineCheckbox:SetChecked(Config.fontOutline == "OUTLINE")
    end
    if self.uiElements.fontShadowCheckbox then
        self.uiElements.fontShadowCheckbox:SetChecked(Config.fontShadow or false)
    end
    if self.uiElements.showStatNamesCheckbox then
        self.uiElements.showStatNamesCheckbox:SetChecked(Config.showStatNames ~= false)
    end
    if self.uiElements.showStatValuesCheckbox then
        self.uiElements.showStatValuesCheckbox:SetChecked(Config.showStatValues ~= false)
    end
end

-- Opens the configuration panel
function ConfigUI:OpenOptions()
    PSB.Config:Save()

    if Settings and Settings.OpenToCategory then
        if PSB.directSettingsCategoryID then
            local success = pcall(Settings.OpenToCategory, PSB.directSettingsCategoryID)
            if success then return end
        end
        if PSB.directCategoryID then
            local success = pcall(Settings.OpenToCategory, PSB.directCategoryID)
            if success then return end
        end
    end

    if SettingsPanel then
        ShowUIPanel(SettingsPanel)
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory("PeaversSystemBars")
        InterfaceOptionsFrame_OpenToCategory("PeaversSystemBars")
    end
end

-- Handler for the /psb config command
PSB.Config.OpenOptionsCommand = function()
    ConfigUI:OpenOptions()
end

-- Initialize the configuration UI
function ConfigUI:Initialize()
    self.panel = self:InitializeOptions()
end

return ConfigUI
