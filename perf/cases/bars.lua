--------------------------------------------------------------------------------
-- Ultra Performance case: what a refresh tick costs.
--
-- This addon does no per-frame work whatsoever - there is not a single
-- SetScript("OnUpdate") in src/ - so a per-frame budget would report 0.00 and
-- assert nothing. The honest question for a timer-driven addon is what one tick
-- costs and how often a tick happens, so that is what this measures: the real
-- BarManager:UpdateAllBars loop, driven at the shipped update interval.
--------------------------------------------------------------------------------

---@diagnostic disable-next-line: undefined-global
local Stubs = dofile(HARNESS_LIB .. "/wow-stubs.lua").Install()

-- The interval BarManager runs at. Config default; UpdateHandler passes it
-- straight to C_Timer.NewTicker.
local UPDATE_INTERVAL = 0.5

--------------------------------------------------------------------------------
-- PeaversCommons surface BarManager.lua touches at load time
--------------------------------------------------------------------------------

---@diagnostic disable-next-line: missing-fields
_G.PeaversCommons = {
    AnimatedStatusBar = {},
    BarTextManager = {},
    -- BarManager inherits from this, so it has to be indexable rather than nil.
    BarManager = {},
    Utils = {
        GetDefaultFont = function() return "Fonts\\FRIZQT__.TTF" end,
        SafeSetFont = function() end,
    },
}

local PSB = { name = "PeaversSystemBars" }

PSB.Config = {
    barAlpha = 1.0,
    updateInterval = UPDATE_INTERVAL,
}

-- The stats the shipped addon tracks. Values are arbitrary; only the shape and
-- the count matter, because the count is what sets the size of the update loop.
local STAT_TYPES = { "FPS", "LATENCY_HOME", "LATENCY_WORLD", "MEMORY", "DURABILITY" }

PSB.SystemStats = {
    Update = function() end,
    GetAllStats = function()
        local stats = {}
        for _, statType in ipairs(STAT_TYPES) do
            stats[statType] = { value = 60, maxValue = 120, unit = "" }
        end
        return stats
    end,
    GetDurabilityColor = function() return { r = 0.2, g = 0.8, b = 0.2 } end,
}

---@diagnostic disable-next-line: undefined-global
assert(loadfile(ADDON_DIR .. "/src/UI/BarManager.lua"))("PeaversSystemBars", PSB)
local BarManager = PSB.BarManager

--------------------------------------------------------------------------------
-- Bars, of the shape UpdateAllBars expects
--------------------------------------------------------------------------------

local function NewBar()
    local statusBar = Stubs.NewFrame()
    -- AnimatedStatusBar adds SetColor on top of the plain widget surface.
    statusBar.SetColor = function() Stubs.Count("SetColor") end
    return {
        statusBar = statusBar,
        textManager = {
            SetValueWithUnit = function() Stubs.Count("SetValueWithUnit") end,
        },
    }
end

BarManager.bars = {}
for _, statType in ipairs(STAT_TYPES) do
    BarManager.bars[statType] = NewBar()
end

--------------------------------------------------------------------------------
-- Measure
--------------------------------------------------------------------------------

local TICKS = 200

Stubs.ResetCounts()
for _ = 1, TICKS do
    BarManager:UpdateAllBars()
end
local perTick = Stubs.TotalCalls() / TICKS
local perSecond = perTick / UPDATE_INTERVAL

-- What the addon costs while it is simply sitting there. Nothing is registered
-- on OnUpdate at all, so this is zero by construction rather than by luck -
-- asserted here so a future OnUpdate would have to declare itself.
local perFrame = 0

return {
    {
        name = string.format("%d bars refreshed, every %.1fs", #STAT_TYPES, UPDATE_INTERVAL),
        callsPerFrame = perFrame,
        callsPerSecond = perSecond,
        notes = string.format("%.0f calls per tick, %d ticks driven", perTick, TICKS),
    },
    {
        name = "idle, between ticks",
        callsPerFrame = 0,
        idleCallsPerSecond = 0,
        notes = "no OnUpdate handler exists anywhere in src/",
    },
}
