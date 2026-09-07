local addonName, PSB = ...

--------------------------------------------------------------------------------
-- Edit Mode
--
-- Everything that makes this work lives in PeaversCommons: the schema layer, the
-- LibEditMode registration, the dialog's grid. What is left here is the list of
-- settings this addon has and how to apply one after it changes.
--
-- Most entries are a key, a section and where they should appear. The label,
-- kind, range and default all come from ConfigSchema.Common, which has described
-- the standard Peavers settings for a long time - SettingsObjects was just the
-- only thing reading it. Only the three settings this addon invents need
-- spelling out.
--------------------------------------------------------------------------------

local PeaversCommons = _G.PeaversCommons

local EditMode = {}
PSB.EditMode = EditMode

--------------------------------------------------------------------------------
-- Applying a change
--
-- This used to be a local inside ConfigUI, which meant the settings page was the
-- only thing that could apply a setting. It is the addon's, not the page's.
--------------------------------------------------------------------------------

local function RefreshBars()
    if PSB.BarManager and PSB.Core and PSB.Core.contentFrame then
        PSB.BarManager:CreateBars(PSB.Core.contentFrame)
        PSB.Core:AdjustFrameHeight()
    end
end

function PSB.ApplySetting(key, value)
    local Config = PSB.Config

    -- Stat colours are keyed by stat, so they are matched by prefix. Only the
    -- one bar that changed is repainted.
    local statType = key:match("^statColor%.(.+)$")
    if statType then
        local bars = PSB.BarManager and PSB.BarManager.bars
        local bar = bars and bars[statType]
        if bar and bar.statusBar and value then
            bar.statusBar:SetColor(value.r, value.g, value.b, Config.barAlpha or 1.0)
        end
        return
    end

    if key == "frameX" or key == "frameY" then
        if PSB.Core and PSB.Core.ApplyFramePosition then
            PSB.Core:ApplyFramePosition()
        end
        return
    end

    if key == "frameWidth" then
        if PSB.Core and PSB.Core.frame then
            PSB.Core.frame:SetWidth(value)
            if PSB.BarManager then PSB.BarManager:ResizeBars() end
        end
    elseif key == "bgAlpha" or key == "bgColor" or key == "showFrameBackground" then
        if PSB.Core and PSB.Core.UpdateFrameBackground then
            PSB.Core:UpdateFrameBackground()
        end
    elseif key == "lockPosition" then
        if PSB.Core then PSB.Core:UpdateFrameLock() end
    elseif key == "showTitleBar" then
        if PSB.Core then PSB.Core:UpdateTitleBarVisibility() end
    elseif key == "barAlpha" or key == "barBgAlpha" or key == "barTexture" or key == "textAlpha" then
        if PSB.BarManager then PSB.BarManager:ResizeBars() end
    elseif key == "barHeight" or key == "barSpacing"
        or key == "showStatNames" or key == "showStatValues"
        or key == "fontFace" or key == "fontSize"
        or key == "fontOutline" or key == "fontShadow" then
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

--------------------------------------------------------------------------------
-- The settings
--
-- All of them, in groups. The dialog itself shows only the first; the rest are
-- buttons that open the settings panel beside it, which scrolls and has room to
-- explain what it is offering.
--------------------------------------------------------------------------------

EditMode.SECTIONS = {
    { key = "frame", label = "Frame" },
    { key = "position", label = "Position" },
    { key = "bars", label = "Bars" },
    { key = "text", label = "Text" },
    { key = "colors", label = "Colours" },
    { key = "behaviour", label = "Behaviour" },
}

EditMode.ENTRIES = {
    -- Frame
    { key = "frameWidth", section = "frame" },
    { key = "showTitleBar", section = "frame" },
    {
        key = "showFrameBackground", section = "frame",
        label = "Show Frame Background", kind = "checkbox", default = true,
    },
    { key = "bgColor", section = "frame" },
    { key = "bgAlpha", section = "frame" },
    { key = "lockPosition", section = "frame" },

    -- Position. Dragging in Edit Mode sets the anchor point as well as the
    -- offset, so these two are the fine adjustment rather than the whole story;
    -- the anchor they are measured from is whichever edge the frame was last
    -- dropped nearest.
    { key = "frameX", section = "position", kind = "number" },
    { key = "frameY", section = "position", kind = "number" },

    -- Bars
    { key = "barHeight", section = "bars" },
    { key = "barSpacing", section = "bars" },
    { key = "barAlpha", section = "bars" },
    { key = "barBgAlpha", section = "bars" },
    { key = "barTexture", section = "bars", height = 300 },

    -- Text
    {
        key = "showStatNames", section = "text",
        label = "Show Stat Names", kind = "checkbox", default = true,
    },
    {
        key = "showStatValues", section = "text",
        label = "Show Stat Values", kind = "checkbox", default = true,
    },
    { key = "fontSize", section = "text" },
    { key = "textAlpha", section = "text" },
    { key = "fontFace", section = "text", height = 300 },
    { key = "fontOutline", section = "text" },
    { key = "fontShadow", section = "text" },

    -- Behaviour. None of it belongs in a dialog you open to move things.
    { key = "showOnLogin", section = "behaviour" },
    { key = "hideOutOfCombat", section = "behaviour" },
    { key = "displayMode", section = "behaviour" },
    { key = "updateInterval", section = "behaviour" },
}

-- One colour per stat, built from whatever SystemStats is tracking rather than
-- listed here, so a new stat brings its own colour picker with it. Each is
-- stored inside a table keyed by stat rather than in a field of its own, which
-- is what the getValue/setValue pair is for.
local function ColourEntries()
    local entries = {}

    local Stats = PSB.SystemStats
    if not (Stats and Stats.STAT_ORDER) then return entries end

    for _, statType in ipairs(Stats.STAT_ORDER) do
        entries[#entries + 1] = {
            key = "statColor." .. statType,
            label = Stats:GetName(statType),
            kind = "color",
            section = "colors",
            default = Stats:GetColor(statType),
            getValue = function(config)
                local custom = config.customColors and config.customColors[statType]
                return custom or Stats:GetColor(statType)
            end,
            setValue = function(config, _, value)
                config.customColors = config.customColors or {}
                config.customColors[statType] = value
            end,
        }
    end

    return entries
end

function EditMode:BuildSchema()
    if self.schema then return self.schema end

    local entries = {}
    for _, entry in ipairs(self.ENTRIES) do entries[#entries + 1] = entry end
    for _, entry in ipairs(ColourEntries()) do entries[#entries + 1] = entry end

    self.schema = PeaversCommons.SettingsSchema:New({
        config = PSB.Config,
        sections = self.SECTIONS,
        entries = entries,
        apply = function(entry, _, value) PSB.ApplySetting(entry.key, value) end,
    })

    return self.schema
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

-- Edit Mode reports a position as an anchor point and an offset from it, which
-- is exactly how every FrameLock-based Peavers addon already stores one. There
-- is nothing to convert and nothing to migrate.
local function SavePosition(_, point, x, y)
    PSB.Config.framePoint = point
    PSB.Config.frameX = x
    PSB.Config.frameY = y
    PSB.Config:Save()
end

-- The frame drags itself when unlocked, and Edit Mode drags it through its own
-- overlay. Both at once means two systems answering one drag, so the frame's own
-- handlers come off for the duration and the normal lock state is restored on
-- the way out.
local function ReleaseDragging(frame)
    for _, target in ipairs({ frame, PSB.Core.contentFrame }) do
        if target then
            target:RegisterForDrag()
            target:SetScript("OnDragStart", nil)
            target:SetScript("OnDragStop", nil)
        end
    end
end

function EditMode:Register()
    if not PeaversCommons.EditMode or not PeaversCommons.EditMode.available then
        return false
    end
    if not PSB.Core or not PSB.Core.frame then return false end

    PeaversCommons.EditMode:Register({
        frame = PSB.Core.frame,
        name = "Peavers System Bars",
        schema = self:BuildSchema(),
        default = {
            point = PSB.Config.defaults and PSB.Config.defaults.framePoint or "RIGHT",
            x = PSB.Config.defaults and PSB.Config.defaults.frameX or -20,
            y = PSB.Config.defaults and PSB.Config.defaults.frameY or 0,
        },
        onPositionChanged = SavePosition,
        onEnter = function(frame)
            ReleaseDragging(frame)
            -- The bars can be hidden by the visibility rules, and a hidden frame
            -- takes its own Edit Mode handle down with it.
            frame:Show()
        end,
        onExit = function()
            if PSB.Core.UpdateFrameLock then PSB.Core:UpdateFrameLock() end
            if PSB.Core.UpdateVisibility then PSB.Core:UpdateVisibility() end
        end,
    })

    return true
end

return EditMode
