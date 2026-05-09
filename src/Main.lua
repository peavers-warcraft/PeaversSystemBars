local addonName, PSB = ...

-- Check for PeaversCommons
local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons to work properly.")
    return
end

local AddonInit = PeaversCommons.AddonInit

-- Setup addon using AddonInit helper
local success = AddonInit:Setup(PSB, addonName, {
    modules = {"Core", "UI", "Utils", "Config", "SystemStats"},
    slashCommand = "psb",
    toggleFunctionName = "ToggleSystemBarsDisplay",
    extraSlashCommands = {}
})

if not success then return end

-- Expose addon namespace globally for PeaversUISetup integration
_G.PeaversSystemBars = PSB

-- Initialize addon using the PeaversCommons Events module
PeaversCommons.Events:Init(addonName, function()
    -- Initialize Config
    if PSB.Config and PSB.Config.Initialize then
        PSB.Config:Initialize()
    end

    -- Register with GlobalAppearance if using global appearance
    if PSB.Config.useGlobalAppearance and PeaversCommons.GlobalAppearance then
        PeaversCommons.GlobalAppearance:RegisterAddon("PeaversSystemBars", PSB.Config, function(key, value)
            -- Refresh UI when global appearance changes
            if PSB.BarManager then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
            if PSB.Core and PSB.Core.UpdateFrameBackground then
                PSB.Core:UpdateFrameBackground()
            end
        end)
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

    -- Register common events (logout save, combat visibility, group updates)
    AddonInit:RegisterCommonEvents(PSB)

    C_Timer.After(0.5, function()
        PeaversCommons.SettingsUI:CreateRedirectPage(PSB, "PeaversSystemBars", "Peavers System Bars")
    end)

    -- Register with PeaversConfig registry
    if PeaversCommons.ConfigRegistry then
        PeaversCommons.ConfigRegistry:Register({
            name = "PeaversSystemBars",
            displayName = "System Bars",
            description = "FPS and latency as visual status bars",
            addonRef = PSB,
            config = PSB.Config,
            pages = PSB.ConfigUI:GetPages(),
            order = 5,
        })
    end
end, {
    suppressAnnouncement = true
})
