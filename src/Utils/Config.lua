--------------------------------------------------------------------------------
-- PeaversSystemBars Configuration
-- Uses PeaversCommons.ConfigManager with AceDB-3.0 for profile management
--------------------------------------------------------------------------------

local addonName, PSB = ...

local PeaversCommons = _G.PeaversCommons
local ConfigManager = PeaversCommons.ConfigManager

-- PSB-specific defaults (these extend the common defaults from ConfigManager)
local PSB_DEFAULTS = {
    -- Frame position defaults
    framePoint = "RIGHT",
    frameX = -20,
    frameY = 0,

    -- PSB-specific settings
    showFrameBackground = true,
    showStatNames = true,
    showStatValues = true,
}

-- Create the AceDB-backed config
PSB.Config = ConfigManager:NewWithAceDB(
    PSB,
    PSB_DEFAULTS,
    {
        savedVariablesName = "PeaversSystemBarsDB",
        profileType = "character",
        onProfileChanged = function()
            if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
                PSB.BarManager:CreateBars(PSB.Core.contentFrame)
                PSB.Core:AdjustFrameHeight()
            end
            if PSB.Core and PSB.Core.UpdateFrameBackground then
                PSB.Core:UpdateFrameBackground()
            end
        end,
    }
)

return PSB.Config
