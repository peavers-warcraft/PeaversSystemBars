local addonName, PSB = ...

-- Check for PeaversCommons
local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons to work properly.")
    return
end

-- Check for required PeaversCommons modules
local requiredModules = {"Events", "SlashCommands", "Utils"}
for _, module in ipairs(requiredModules) do
    if not PeaversCommons[module] then
        print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons." .. module .. " which is missing.")
        return
    end
end

-- Initialize addon namespace and modules
PSB = PSB or {}

-- Module namespaces
PSB.Core = PSB.Core or {}
PSB.UI = PSB.UI or {}
PSB.Utils = PSB.Utils or {}
PSB.Config = PSB.Config or {}
PSB.SystemStats = PSB.SystemStats or {}

-- Version information
local function getAddOnMetadata(name, key)
    return C_AddOns.GetAddOnMetadata(name, key)
end

PSB.version = getAddOnMetadata(addonName, "Version") or "1.0.0"
PSB.addonName = addonName
PSB.name = addonName

-- Function to toggle the display
function ToggleSystemBarsDisplay()
    if PSB.Core.frame:IsShown() then
        PSB.Core.frame:Hide()
    else
        PSB.Core.frame:Show()
    end
end

-- Make the function globally accessible
_G.ToggleSystemBarsDisplay = ToggleSystemBarsDisplay

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "psb", {
    default = function()
        ToggleSystemBarsDisplay()
    end,
    config = function()
        if PSB.ConfigUI and PSB.ConfigUI.OpenOptions then
            PSB.ConfigUI:OpenOptions()
        end
    end,
    debug = function()
        PSB.Config.DEBUG_ENABLED = not PSB.Config.DEBUG_ENABLED
        if PSB.Utils and PSB.Utils.Print then
            if PSB.Config.DEBUG_ENABLED then
                PSB.Utils.Print("Debug mode ENABLED")
            else
                PSB.Utils.Print("Debug mode DISABLED")
            end
        end
        PSB.Config:Save()
    end
})

-- Initialize addon using the PeaversCommons Events module
PeaversCommons.Events:Init(addonName, function()
    -- Initialize Config
    if PSB.Config and PSB.Config.Initialize then
        PSB.Config:Initialize()
    end

    -- Initialize ConfigUI
    if PSB.ConfigUI and PSB.ConfigUI.Initialize then
        PSB.ConfigUI:Initialize()
    end

    -- Initialize core components
    PSB.Core:Initialize()

    -- Start the update handler
    if PSB.UpdateHandler and PSB.UpdateHandler.Start then
        PSB.UpdateHandler:Start()
    end

    -- Register event handlers
    PeaversCommons.Events:RegisterEvent("PLAYER_LOGOUT", function()
        PSB.Config:Save()
    end)

    -- Use the centralized SettingsUI system from PeaversCommons
    C_Timer.After(0.5, function()
        local mainPanel, settingsPanel = PeaversCommons.SettingsUI:CreateSettingsPages(
            PSB,
            "PeaversSystemBars",
            "Peavers System Bars",
            "Displays FPS and latency as visual status bars.",
            {
                "/psb - Toggle display",
                "/psb config - Open settings"
            }
        )

        -- Hook OnShow to refresh UI when settings panel is displayed
        if settingsPanel then
            settingsPanel:HookScript("OnShow", function()
                if PSB.ConfigUI and PSB.ConfigUI.RefreshUI then
                    PSB.ConfigUI:RefreshUI()
                end
            end)
        end
    end)
end, {
    suppressAnnouncement = true
})
