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
-- "both" is anything you decide by looking at the bars while you drag a slider.
-- "config" is anything picked off a list once and then forgotten - display
-- modes, update rates, fonts - which the settings page has room to explain and
-- the dialog does not. Locking the position is config-only for a plainer
-- reason: in Edit Mode, moving the frame is the entire point.
--------------------------------------------------------------------------------

EditMode.SECTIONS = {
    { key = "frame", label = "Frame" },
    { key = "bars", label = "Bars" },
    { key = "text", label = "Text" },
    { key = "behaviour", label = "Behaviour" },
}

EditMode.ENTRIES = {
    -- Frame
    { key = "frameWidth", section = "frame", surface = "both" },
    { key = "showTitleBar", section = "frame", surface = "both" },
    {
        key = "showFrameBackground", section = "frame", surface = "both",
        label = "Show Frame Background", kind = "checkbox", default = true,
    },
    { key = "bgColor", section = "frame", surface = "both" },
    { key = "bgAlpha", section = "frame", surface = "both" },
    { key = "lockPosition", section = "frame", surface = "config" },

    -- Bars
    { key = "barHeight", section = "bars", surface = "both" },
    { key = "barSpacing", section = "bars", surface = "both" },
    { key = "barAlpha", section = "bars", surface = "both" },
    { key = "barBgAlpha", section = "bars", surface = "both" },
    { key = "barTexture", section = "bars", surface = "config", height = 300 },

    -- Text
    {
        key = "showStatNames", section = "text", surface = "both",
        label = "Show Stat Names", kind = "checkbox", default = true,
    },
    {
        key = "showStatValues", section = "text", surface = "both",
        label = "Show Stat Values", kind = "checkbox", default = true,
    },
    { key = "fontSize", section = "text", surface = "both" },
    { key = "textAlpha", section = "text", surface = "both" },
    { key = "fontFace", section = "text", surface = "config", height = 300 },
    { key = "fontOutline", section = "text", surface = "config" },
    { key = "fontShadow", section = "text", surface = "config" },

    -- Behaviour. None of it belongs in a dialog you open to move things.
    { key = "showOnLogin", section = "behaviour", surface = "config" },
    { key = "hideOutOfCombat", section = "behaviour", surface = "config" },
    { key = "displayMode", section = "behaviour", surface = "config" },
    { key = "updateInterval", section = "behaviour", surface = "config" },
}

function EditMode:BuildSchema()
    if self.schema then return self.schema end

    self.schema = PeaversCommons.SettingsSchema:New({
        config = PSB.Config,
        sections = self.SECTIONS,
        entries = self.ENTRIES,
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
