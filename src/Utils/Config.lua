local addonName, PSB = ...

-- Access PeaversCommons
local PeaversCommons = _G.PeaversCommons
local DefaultConfig = PeaversCommons and PeaversCommons.DefaultConfig

-- Get defaults from PeaversCommons preset or use fallback
local defaults
if DefaultConfig then
    defaults = DefaultConfig.FromPreset("SystemBars")
else
    -- Fallback defaults if PeaversCommons not loaded yet
    defaults = {
        frameWidth = 200,
        frameHeight = 100,
        framePoint = "RIGHT",
        frameX = -20,
        frameY = 0,
        lockPosition = false,
        barHeight = 20,
        barSpacing = 2,
        barBgAlpha = 0.5,
        barAlpha = 1.0,
        fontFace = nil,
        fontSize = 9,
        fontOutline = "OUTLINE",
        fontShadow = false,
        barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
        bgAlpha = 0.8,
        bgColor = { r = 0, g = 0, b = 0 },
        updateInterval = 0.5,
        showOnLogin = true,
        showTitleBar = true,
        showFrameBackground = true,
        showStatNames = true,
        showStatValues = true,
        DEBUG_ENABLED = false,
        customColors = {},
    }
end

-- Initialize Config namespace with default values from preset
PSB.Config = {}
for key, value in pairs(defaults) do
    if type(value) == "table" then
        PSB.Config[key] = {}
        for k, v in pairs(value) do
            PSB.Config[key][k] = v
        end
    else
        PSB.Config[key] = value
    end
end

-- Character identification
PSB.Config.currentCharacter = nil
PSB.Config.currentRealm = nil

local Config = PSB.Config

-- Functions to get player identification information
function Config:GetPlayerName()
    return UnitName("player")
end

function Config:GetRealmName()
    return GetRealmName()
end

function Config:GetCharacterKey()
    return self:GetPlayerName() .. "-" .. self:GetRealmName()
end

-- Get the appropriate default font based on client locale
function Config:GetDefaultFont()
    local PeaversCommons = _G.PeaversCommons
    if PeaversCommons and PeaversCommons.DefaultConfig then
        return PeaversCommons.DefaultConfig.GetDefaultFont()
    end

    -- Fallback
    local locale = GetLocale()
    if locale == "zhCN" then
        return "Fonts\\ARKai_T.ttf"
    elseif locale == "zhTW" then
        return "Fonts\\bLEI00D.ttf"
    elseif locale == "koKR" then
        return "Fonts\\2002.TTF"
    else
        return "Fonts\\FRIZQT__.TTF"
    end
end

function Config:UpdateCurrentIdentifiers()
    self.currentCharacter = self:GetPlayerName()
    self.currentRealm = self:GetRealmName()
end

-- Saves all configuration values to the SavedVariables database
function Config:Save()
    -- Initialize database structure if it doesn't exist
    if not PeaversSystemBarsDB then
        PeaversSystemBarsDB = {
            profiles = {},
            global = {}
        }
    end

    PeaversSystemBarsDB.profiles = PeaversSystemBarsDB.profiles or {}
    PeaversSystemBarsDB.global = PeaversSystemBarsDB.global or {}

    -- Update current identifiers
    self:UpdateCurrentIdentifiers()

    -- Get character key
    local charKey = self:GetCharacterKey()

    -- Initialize profile data if it doesn't exist
    if not PeaversSystemBarsDB.profiles[charKey] then
        PeaversSystemBarsDB.profiles[charKey] = {}
    end

    -- Save current settings to the profile
    local profile = PeaversSystemBarsDB.profiles[charKey]

    profile.fontFace = self.fontFace
    profile.fontSize = self.fontSize
    profile.fontOutline = self.fontOutline
    profile.fontShadow = self.fontShadow
    profile.framePoint = self.framePoint
    profile.frameX = self.frameX
    profile.frameY = self.frameY
    profile.frameWidth = self.frameWidth
    profile.barHeight = self.barHeight
    profile.barTexture = self.barTexture
    profile.barBgAlpha = self.barBgAlpha
    profile.barAlpha = self.barAlpha
    profile.bgAlpha = self.bgAlpha
    profile.bgColor = self.bgColor
    profile.barSpacing = self.barSpacing
    profile.showTitleBar = self.showTitleBar
    profile.lockPosition = self.lockPosition
    profile.showFrameBackground = self.showFrameBackground
    profile.showStatNames = self.showStatNames
    profile.showStatValues = self.showStatValues
    profile.updateInterval = self.updateInterval
    profile.DEBUG_ENABLED = self.DEBUG_ENABLED
    profile.customColors = self.customColors
end

-- Loads configuration values from the SavedVariables database
function Config:Load()
    -- If no saved data exists, initialize it
    if not PeaversSystemBarsDB then
        PeaversSystemBarsDB = {
            profiles = {},
            global = {}
        }
    end

    PeaversSystemBarsDB.profiles = PeaversSystemBarsDB.profiles or {}
    PeaversSystemBarsDB.global = PeaversSystemBarsDB.global or {}

    -- Update current identifiers
    self:UpdateCurrentIdentifiers()

    -- Get character key
    local charKey = self:GetCharacterKey()

    -- If we don't have a profile for this character, create one
    if not PeaversSystemBarsDB.profiles[charKey] then
        PeaversSystemBarsDB.profiles[charKey] = {}
    end

    -- Load settings from the profile
    local profile = PeaversSystemBarsDB.profiles[charKey]

    if profile.fontFace then
        self.fontFace = profile.fontFace
    else
        self.fontFace = self:GetDefaultFont()
    end
    if profile.fontSize then
        self.fontSize = profile.fontSize
    end
    if profile.fontOutline then
        self.fontOutline = profile.fontOutline
    end
    if profile.fontShadow ~= nil then
        self.fontShadow = profile.fontShadow
    end
    if profile.framePoint then
        self.framePoint = profile.framePoint
    end
    if profile.frameX then
        self.frameX = profile.frameX
    end
    if profile.frameY then
        self.frameY = profile.frameY
    end
    if profile.frameWidth then
        self.frameWidth = profile.frameWidth
    end
    if profile.barHeight then
        self.barHeight = profile.barHeight
    end
    if profile.barTexture then
        self.barTexture = profile.barTexture
    end
    if profile.barBgAlpha then
        self.barBgAlpha = profile.barBgAlpha
    end
    if profile.barAlpha then
        self.barAlpha = profile.barAlpha
    end
    if profile.bgAlpha then
        self.bgAlpha = profile.bgAlpha
    end
    if profile.bgColor then
        self.bgColor = profile.bgColor
    end
    if profile.barSpacing then
        self.barSpacing = profile.barSpacing
    end
    if profile.showTitleBar ~= nil then
        self.showTitleBar = profile.showTitleBar
    end
    if profile.lockPosition ~= nil then
        self.lockPosition = profile.lockPosition
    end
    if profile.showFrameBackground ~= nil then
        self.showFrameBackground = profile.showFrameBackground
    end
    if profile.showStatNames ~= nil then
        self.showStatNames = profile.showStatNames
    end
    if profile.showStatValues ~= nil then
        self.showStatValues = profile.showStatValues
    end
    if profile.updateInterval then
        self.updateInterval = profile.updateInterval
    end
    if profile.DEBUG_ENABLED ~= nil then
        self.DEBUG_ENABLED = profile.DEBUG_ENABLED
    end
    if profile.customColors then
        self.customColors = profile.customColors
    end
end

function Config:Initialize()
    -- Update current character, realm identifiers
    self:UpdateCurrentIdentifiers()

    -- Load settings for the current character
    self:Load()

    -- Ensure font is set
    if not self.fontFace then
        self.fontFace = self:GetDefaultFont()
    end

    -- Ensure customColors is initialized
    if not self.customColors then
        self.customColors = {}
    end

    -- Save settings after initialization
    self:Save()
end

-- Returns a sorted table of available fonts, including those from LibSharedMedia
function Config:GetFonts()
    local PeaversCommons = _G.PeaversCommons
    if PeaversCommons and PeaversCommons.DefaultConfig then
        return PeaversCommons.DefaultConfig.GetFonts()
    end

    -- Fallback
    local fonts = {
        ["Fonts\\ARIALN.TTF"] = "Arial Narrow",
        ["Fonts\\FRIZQT__.TTF"] = "Default",
        ["Fonts\\MORPHEUS.TTF"] = "Morpheus",
        ["Fonts\\SKURRI.TTF"] = "Skurri",
        ["Fonts\\ARKai_T.ttf"] = "ARKai (Simplified Chinese)",
        ["Fonts\\bLEI00D.ttf"] = "bLEI (Traditional Chinese)",
        ["Fonts\\2002.TTF"] = "2002 (Korean)"
    }
    return fonts
end

-- Returns a sorted table of available statusbar textures from various sources
function Config:GetBarTextures()
    local PeaversCommons = _G.PeaversCommons
    if PeaversCommons and PeaversCommons.DefaultConfig then
        return PeaversCommons.DefaultConfig.GetBarTextures()
    end

    -- Fallback
    local textures = {
        ["Interface\\TargetingFrame\\UI-StatusBar"] = "Default",
        ["Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"] = "Skill Bar",
        ["Interface\\PVPFrame\\UI-PVP-Progress-Bar"] = "PVP Bar",
        ["Interface\\RaidFrame\\Raid-Bar-Hp-Fill"] = "Raid"
    }
    return textures
end
