local _, PSB = ...
local Config = PSB.Config

local ConfigUI = {}
PSB.ConfigUI = ConfigUI

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r PeaversCommons not found.")
    return
end

local SettingsObjects = PeaversCommons.SettingsObjects
local W = PeaversCommons.Widgets
local ConfigUIUtils = PeaversCommons.ConfigUIUtils

local function RefreshBars()
    if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
        PSB.BarManager:CreateBars(PSB.Core.contentFrame)
        PSB.Core:AdjustFrameHeight()
    end
end

local function OnSettingChanged(key, value)
    if key == "frameWidth" then
        if PSB.Core and PSB.Core.frame then
            PSB.Core.frame:SetWidth(value)
            if PSB.BarManager then PSB.BarManager:ResizeBars() end
        end
    elseif key == "bgAlpha" or key == "bgColor" then
        if PSB.Core and PSB.Core.frame then
            local color = Config.bgColor or { r = 0, g = 0, b = 0 }
            PSB.Core.frame:SetBackdropColor(color.r, color.g, color.b, Config.bgAlpha or 0.8)
            PSB.Core.frame:SetBackdropBorderColor(0, 0, 0, Config.bgAlpha or 0.8)
        end
    elseif key == "lockPosition" then
        if PSB.Core then PSB.Core:UpdateFrameLock() end
    elseif key == "showTitleBar" then
        if PSB.Core then PSB.Core:UpdateTitleBarVisibility() end
    elseif key == "barAlpha" or key == "barBgAlpha" or key == "barTexture" then
        if PSB.BarManager then PSB.BarManager:ResizeBars() end
    elseif key == "barHeight" or key == "barSpacing" then
        RefreshBars()
    elseif key == "fontFace" or key == "fontSize" or key == "fontOutline" or key == "fontShadow" then
        RefreshBars()
    elseif key == "updateInterval" then
        if PSB.UpdateHandler and PSB.UpdateHandler.Restart then
            PSB.UpdateHandler:Restart()
        end
    elseif key == "displayMode" or key == "hideOutOfCombat" or key == "showOnLogin" then
        if PSB.Core and PSB.Core.UpdateVisibility then
            PSB.Core:UpdateVisibility()
        end
    end
end

local pageOpts = {
    indent = 25,
    width = 360,
    onChanged = OnSettingChanged,
}

local function GetPageOpts(parentFrame)
    local opts = {}
    for k, v in pairs(pageOpts) do opts[k] = v end
    local frameWidth = parentFrame:GetWidth()
    if frameWidth and frameWidth > 100 then
        opts.width = frameWidth - (opts.indent * 2) - 10
    end
    return opts
end

function ConfigUI:BuildGeneralPage(parentFrame)
    local y = -10
    local opts = GetPageOpts(parentFrame)

    y = SettingsObjects.FrameSettings(parentFrame, Config, y, opts)

    local _, newY = W:CreateSectionHeader(parentFrame, "Display", opts.indent, y)
    y = newY - 8

    local toggle1 = W:CreateCheckbox(parentFrame, "Show Frame Background", {
        checked = Config.showFrameBackground ~= false,
        width = opts.width,
        onChange = function(checked)
            Config.showFrameBackground = checked
            Config:Save()
            if PSB.Core then PSB.Core:UpdateFrameBackground() end
        end,
    })
    toggle1:SetPoint("TOPLEFT", opts.indent, y)
    y = y - 30

    local toggle2 = W:CreateCheckbox(parentFrame, "Show Stat Names", {
        checked = Config.showStatNames ~= false,
        width = opts.width,
        onChange = function(checked)
            Config.showStatNames = checked
            Config:Save()
            RefreshBars()
        end,
    })
    toggle2:SetPoint("TOPLEFT", opts.indent, y)
    y = y - 30

    local toggle3 = W:CreateCheckbox(parentFrame, "Show Stat Values", {
        checked = Config.showStatValues ~= false,
        width = opts.width,
        onChange = function(checked)
            Config.showStatValues = checked
            Config:Save()
            RefreshBars()
        end,
    })
    toggle3:SetPoint("TOPLEFT", opts.indent, y)
    y = y - 30

    y = y - 10
    y = SettingsObjects.Visibility(parentFrame, Config, y, opts)
    y = SettingsObjects.UpdateInterval(parentFrame, Config, y, opts)

    parentFrame:SetHeight(math.abs(y) + 30)
end

function ConfigUI:BuildBarsPage(parentFrame)
    local y = -10
    local opts = GetPageOpts(parentFrame)

    y = SettingsObjects.BarAppearance(parentFrame, Config, y, opts)
    y = SettingsObjects.FontSettings(parentFrame, Config, y, opts)

    parentFrame:SetHeight(math.abs(y) + 30)
end

function ConfigUI:BuildColorsPage(parentFrame)
    local y = -10
    local opts = GetPageOpts(parentFrame)
    local indent = opts.indent
    local width = opts.width

    local _, newY = W:CreateSectionHeader(parentFrame, "Stat Colors", indent, y)
    y = newY - 8

    if PSB.SystemStats and PSB.SystemStats.STAT_ORDER then
        for _, statType in ipairs(PSB.SystemStats.STAT_ORDER) do
            local statName = PSB.SystemStats:GetName(statType)
            local color = PSB.SystemStats:GetColor(statType)
            local r, g, b = color.r, color.g, color.b

            if Config.customColors and Config.customColors[statType] then
                local custom = Config.customColors[statType]
                r, g, b = custom.r, custom.g, custom.b
            end

            local colorPicker = W:CreateColorPicker(parentFrame, statName, {
                r = r, g = g, b = b,
                width = width,
                onChange = function(newR, newG, newB)
                    Config.customColors = Config.customColors or {}
                    Config.customColors[statType] = { r = newR, g = newG, b = newB }
                    Config:Save()
                    if PSB.BarManager and PSB.BarManager.bars and PSB.BarManager.bars[statType] then
                        local bar = PSB.BarManager.bars[statType]
                        bar.statusBar:SetColor(newR, newG, newB, Config.barAlpha or 1.0)
                    end
                end,
            })
            colorPicker:SetPoint("TOPLEFT", indent, y)
            y = y - 30
        end
    end

    parentFrame:SetHeight(math.abs(y) + 30)
end

function ConfigUI:BuildInfoPage(parentFrame)
    PeaversCommons.ConfigUIUtils.BuildInfoPage(parentFrame, "System Bars", {
        "Shows your FPS and latency as small, movable status bars: green for " ..
            "frames per second, blue for home latency, orange for world latency.",
        { command = "/psb", desc = "toggle the bars" },
        { command = "/psb config", desc = "open the configuration panel" },

        { header = "Home versus world latency" },
        "Home latency is your connection to the realm server - chat, guild, " ..
            "and auction house. World latency is the server actually running " ..
            "combat, movement, and spells; it is the number that matters when " ..
            "the game feels laggy.",

        { header = "How the bars scale" },
        "Each bar sizes itself against the highest value seen in the last 30 " ..
            "seconds rather than a fixed maximum, so it stays readable whether " ..
            "you sit at 40 FPS or 200. Values refresh every half second.",
    })
end

function ConfigUI:GetPages()
    return {
        { key = "info", label = "Information", builder = function(f) ConfigUI:BuildInfoPage(f) end },
        { key = "general", label = "General", builder = function(f) ConfigUI:BuildGeneralPage(f) end },
        { key = "bars", label = "Bars & Text", builder = function(f) ConfigUI:BuildBarsPage(f) end },
        { key = "colors", label = "Colors", builder = function(f) ConfigUI:BuildColorsPage(f) end },
    }
end

function ConfigUI:BuildIntoFrame(parentFrame)
    local y = -10
    y = SettingsObjects.FrameSettings(parentFrame, Config, y, pageOpts)
    y = SettingsObjects.BarAppearance(parentFrame, Config, y, pageOpts)
    y = SettingsObjects.FontSettings(parentFrame, Config, y, pageOpts)
    y = SettingsObjects.Visibility(parentFrame, Config, y, pageOpts)
    y = SettingsObjects.UpdateInterval(parentFrame, Config, y, pageOpts)
    parentFrame:SetHeight(math.abs(y) + 30)
    return parentFrame
end

function ConfigUI:InitializeOptions()
    local panel = ConfigUIUtils.CreateSettingsPanel(
        "Settings",
        "Configuration options for the system bars display"
    )
    local content = panel.content
    self:BuildIntoFrame(content)
    panel:UpdateContentHeight(content:GetHeight())
    return panel
end

function ConfigUI:OpenOptions()
    PSB.Config:Save()

    if _G.PeaversConfig and _G.PeaversConfig.MainFrame then
        _G.PeaversConfig.MainFrame:Show()
        _G.PeaversConfig.MainFrame:SelectAddon("PeaversSystemBars")
        return
    end

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

PSB.Config.OpenOptionsCommand = function()
    ConfigUI:OpenOptions()
end

function ConfigUI:Initialize()
    self.panel = self:InitializeOptions()
end

return ConfigUI
