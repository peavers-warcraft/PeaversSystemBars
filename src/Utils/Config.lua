--------------------------------------------------------------------------------
-- PeaversSystemBars Configuration
-- Uses PeaversCommons.ConfigManager for character-based profile management
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

-- Create the character-based config using ConfigManager
PSB.Config = ConfigManager:NewCharacterBased(
    PSB,
    PSB_DEFAULTS,
    { savedVariablesName = "PeaversSystemBarsDB" }
)

return PSB.Config
