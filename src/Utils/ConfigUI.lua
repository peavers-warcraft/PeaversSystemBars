local _, PSB = ...
local Config = PSB.Config

local ConfigUI = {}
PSB.ConfigUI = ConfigUI

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r PeaversCommons not found.")
    return
end

local ConfigUIUtils = PeaversCommons.ConfigUIUtils

--------------------------------------------------------------------------------
-- Where the settings went
--
-- Every setting the bars have is in Blizzard's Edit Mode now: select the frame
-- and the dialog holds its width and whether the title bar and background show,
-- with a button per group for the rest.
--
-- This page is deliberately not a second copy of them. Two places to change one
-- setting is worse than one place that takes a moment to find. What is left is
-- what a settings page is actually for - explaining what the thing does.
--------------------------------------------------------------------------------

-- Applying a setting lives with the addon's schema, so the settings page and the
-- Edit Mode panel cannot disagree about what a change should do.
function ConfigUI:BuildInfoPage(parentFrame)
    ConfigUIUtils.BuildInfoPage(parentFrame, "System Bars", {
        "Shows your FPS and latency as small, movable status bars: green for " ..
            "frames per second, blue for home latency, orange for world latency.",
        { command = "/psb", desc = "toggle the bars" },

        { header = "Settings are in Edit Mode" },
        "Open Edit Mode from the game menu, select the bars, and their settings " ..
            "open beside the Edit Mode dialog: width, bar height and spacing, " ..
            "fonts, stat colours, visibility and update rate, and typed position " ..
            "offsets. Drag to place them, or nudge a pixel at a time with the " ..
            "arrow keys and ten at a time with Shift held.",

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

--------------------------------------------------------------------------------
-- Pages
--------------------------------------------------------------------------------

function ConfigUI:GetPages()
    return {
        { key = "info", label = "Information", builder = function(f) ConfigUI:BuildInfoPage(f) end },
    }
end

function ConfigUI:BuildIntoFrame(parentFrame)
    self:BuildInfoPage(parentFrame)
    return parentFrame
end

function ConfigUI:InitializeOptions()
    local panel = ConfigUIUtils.CreateSettingsPanel(
        "System Bars",
        "The bars are configured in Blizzard's Edit Mode"
    )
    local content = panel.content
    self:BuildIntoFrame(content)
    panel:UpdateContentHeight(content:GetHeight())
    return panel
end

function ConfigUI:OpenOptions()
    Config:Save()

    if _G.PeaversConfig and _G.PeaversConfig.MainFrame then
        _G.PeaversConfig.MainFrame:Show()
        _G.PeaversConfig.MainFrame:SelectAddon("PeaversSystemBars")
        return
    end

    if Settings and Settings.OpenToCategory then
        if PSB.directSettingsCategoryID then
            local ok = pcall(Settings.OpenToCategory, PSB.directSettingsCategoryID)
            if ok then return end
        end
        if PSB.directCategoryID then
            local ok = pcall(Settings.OpenToCategory, PSB.directCategoryID)
            if ok then return end
        end
    end

    if SettingsPanel then
        ShowUIPanel(SettingsPanel)
    end
end

Config.OpenOptionsCommand = function()
    ConfigUI:OpenOptions()
end

function ConfigUI:Initialize()
    self.panel = self:InitializeOptions()
end

return ConfigUI
