local addonName, PSB = ...

-- Initialize UpdateHandler namespace
PSB.UpdateHandler = {}
local UpdateHandler = PSB.UpdateHandler

-- Store the ticker reference
UpdateHandler.ticker = nil
UpdateHandler.isRunning = false

-- Start the update ticker
function UpdateHandler:Start()
    if self.isRunning then
        return
    end

    local interval = PSB.Config.updateInterval or 0.5

    self.ticker = C_Timer.NewTicker(interval, function()
        if PSB.BarManager then
            PSB.BarManager:UpdateAllBars()
        end
    end)

    self.isRunning = true
end

-- Stop the update ticker
function UpdateHandler:Stop()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    self.isRunning = false
end

-- Restart with new interval (if config changes)
function UpdateHandler:Restart()
    self:Stop()
    self:Start()
end
