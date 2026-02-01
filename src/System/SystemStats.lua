local addonName, PSB = ...

-- Initialize SystemStats namespace
PSB.SystemStats = {}
local SystemStats = PSB.SystemStats

-- Stat type definitions
SystemStats.STAT_TYPES = {
    FPS = "FPS",
    HOME_LATENCY = "HOME_LATENCY",
    WORLD_LATENCY = "WORLD_LATENCY",
}

-- Order in which stats should be displayed
SystemStats.STAT_ORDER = {
    "FPS",
    "HOME_LATENCY",
    "WORLD_LATENCY",
}

-- Stat colors (matching the plan: FPS=green, HOME=blue, WORLD=orange)
SystemStats.STAT_COLORS = {
    FPS = { r = 0.4, g = 0.9, b = 0.4 },           -- Green
    HOME_LATENCY = { r = 0.4, g = 0.6, b = 0.9 },  -- Blue
    WORLD_LATENCY = { r = 0.9, g = 0.6, b = 0.3 }, -- Orange
}

-- Rolling max tracking for dynamic bar scaling
-- Keep 60 samples (0.5s * 60 = 30 second window)
local MAX_SAMPLES = 60
local samples = {
    FPS = {},
    HOME_LATENCY = {},
    WORLD_LATENCY = {},
}
local sampleIndex = {
    FPS = 1,
    HOME_LATENCY = 1,
    WORLD_LATENCY = 1,
}

-- Minimum max values
local MIN_MAX_VALUES = {
    FPS = 60,
    HOME_LATENCY = 100,
    WORLD_LATENCY = 100,
}

-- Get the current value for a stat type
function SystemStats:GetValue(statType)
    if statType == "FPS" then
        return math.floor(GetFramerate())
    elseif statType == "HOME_LATENCY" or statType == "WORLD_LATENCY" then
        local _, _, latencyHome, latencyWorld = GetNetStats()
        if statType == "HOME_LATENCY" then
            return latencyHome or 0
        else
            return latencyWorld or 0
        end
    end
    return 0
end

-- Record a sample for rolling max calculation
function SystemStats:RecordSample(statType, value)
    local idx = sampleIndex[statType]
    samples[statType][idx] = value
    sampleIndex[statType] = (idx % MAX_SAMPLES) + 1
end

-- Get the maximum value for a stat type (for bar scaling)
-- Uses a rolling max over the last 30 seconds
function SystemStats:GetMaxValue(statType)
    local statSamples = samples[statType]
    local maxVal = MIN_MAX_VALUES[statType]

    for _, val in pairs(statSamples) do
        if val and val > maxVal then
            maxVal = val
        end
    end

    -- Add some headroom (10%) to prevent bars from always being at 100%
    return math.ceil(maxVal * 1.1)
end

-- Get the localized display name for a stat type
function SystemStats:GetName(statType)
    if PSB.L then
        if statType == "FPS" then
            return PSB.L["STAT_FPS"]
        elseif statType == "HOME_LATENCY" then
            return PSB.L["STAT_HOME"]
        elseif statType == "WORLD_LATENCY" then
            return PSB.L["STAT_WORLD"]
        end
    end

    -- Fallback to simple names
    if statType == "FPS" then
        return "FPS"
    elseif statType == "HOME_LATENCY" then
        return "Home"
    elseif statType == "WORLD_LATENCY" then
        return "World"
    end

    return statType
end

-- Get the unit suffix for a stat type
function SystemStats:GetUnit(statType)
    if PSB.L then
        if statType == "FPS" then
            return PSB.L["UNIT_FPS"]
        else
            return PSB.L["UNIT_MS"]
        end
    end

    -- Fallback
    if statType == "FPS" then
        return "fps"
    else
        return "ms"
    end
end

-- Get the color for a stat type
function SystemStats:GetColor(statType)
    return self.STAT_COLORS[statType] or { r = 1, g = 1, b = 1 }
end

-- Update all stats and record samples
function SystemStats:Update()
    for _, statType in ipairs(self.STAT_ORDER) do
        local value = self:GetValue(statType)
        self:RecordSample(statType, value)
    end
end

-- Get all stats data for UI updates
function SystemStats:GetAllStats()
    local stats = {}
    for _, statType in ipairs(self.STAT_ORDER) do
        local value = self:GetValue(statType)
        stats[statType] = {
            value = value,
            maxValue = self:GetMaxValue(statType),
            name = self:GetName(statType),
            unit = self:GetUnit(statType),
            color = self:GetColor(statType),
        }
    end
    return stats
end
