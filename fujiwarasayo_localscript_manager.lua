-- LocalScript Manager
-- Manages and monitors all LocalScripts in the game

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Script tracking
local trackedScripts = {}
local scriptConnections = {}

-- Logging function (can be customized)
local function log(message, scriptObj)
    if scriptObj then
        print(string.format("[LocalScript Manager] %s: %s", scriptObj:GetFullName(), message))
    else
        print(string.format("[LocalScript Manager] %s", message))
    end
end

-- Get all LocalScripts in the game
local function getAllLocalScripts()
    local scripts = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") then
            table.insert(scripts, obj)
        end
    end
    return scripts
end

-- Track a LocalScript
local function trackScript(script)
    if trackedScripts[script] then return end
    
    trackedScripts[script] = {
        name = script.Name,
        fullName = script:GetFullName(),
        enabled = script.Enabled,
        parent = script.Parent,
        addedTime = os.time()
    }
    
    -- Monitor Enabled property changes
    local enabledConn = script:GetPropertyChangedSignal("Enabled"):Connect(function()
        trackedScripts[script].enabled = script.Enabled
        log(string.format("Enabled changed to %s", tostring(script.Enabled)), script)
    end)
    
    -- Monitor Parent changes
    local ancestryConn = script.AncestryChanged:Connect(function()
        trackedScripts[script].parent = script.Parent
        log(string.format("Parent changed to %s", tostring(script.Parent)), script)
    end)
    
    scriptConnections[script] = {enabledConn, ancestryConn}
    log("Now tracking", script)
end

-- Untrack a LocalScript
local function untrackScript(script)
    if not trackedScripts[script] then return end
    
    -- Disconnect all connections for this script
    if scriptConnections[script] then
        for _, conn in ipairs(scriptConnections[script]) do
            conn:Disconnect()
        end
        scriptConnections[script] = nil
    end
    
    trackedScripts[script] = nil
    log("Stopped tracking", script)
end

-- Start monitoring all LocalScripts
local function startMonitoring()
    log("Starting LocalScript monitoring...")
    
    -- Track existing scripts
    for _, script in ipairs(getAllLocalScripts()) do
        trackScript(script)
    end
    
    -- Monitor for new scripts
    local addedConn = game.DescendantAdded:Connect(function(obj)
        if obj:IsA("LocalScript") then
            trackScript(obj)
            log("New LocalScript detected", obj)
        end
    end)
    
    -- Monitor for removed scripts
    local removedConn = game.DescendantRemoving:Connect(function(obj)
        if obj:IsA("LocalScript") then
            log("LocalScript being removed", obj)
            untrackScript(obj)
        end
    end)
    
    return {addedConn, removedConn}
end

-- Stop monitoring
local mainConnections = {}
local function stopMonitoring()
    log("Stopping LocalScript monitoring...")
    
    -- Disconnect main connections
    for _, conn in ipairs(mainConnections) do
        conn:Disconnect()
    end
    mainConnections = {}
    
    -- Untrack all scripts
    for script, _ in pairs(trackedScripts) do
        untrackScript(script)
    end
end

-- Get script information
local function getScriptInfo(script)
    return trackedScripts[script]
end

-- List all tracked scripts
local function listAllScripts()
    local scripts = {}
    for script, data in pairs(trackedScripts) do
        table.insert(scripts, {
            object = script,
            data = data
        })
    end
    return scripts
end

-- Disable a LocalScript
local function disableScript(script)
    if script and script:IsA("LocalScript") then
        script.Enabled = false
        log("Disabled", script)
        return true
    end
    return false
end

-- Enable a LocalScript
local function enableScript(script)
    if script and script:IsA("LocalScript") then
        script.Enabled = true
        log("Enabled", script)
        return true
    end
    return false
end

-- Disable all LocalScripts except specified ones
local function disableAllExcept(exceptions)
    exceptions = exceptions or {}
    local exceptionsSet = {}
    for _, script in ipairs(exceptions) do
        exceptionsSet[script] = true
    end
    
    local count = 0
    for script, _ in pairs(trackedScripts) do
        if not exceptionsSet[script] and script.Enabled then
            disableScript(script)
            count = count + 1
        end
    end
    
    log(string.format("Disabled %d LocalScripts", count))
    return count
end

-- Enable all LocalScripts
local function enableAll()
    local count = 0
    for script, _ in pairs(trackedScripts) do
        if not script.Enabled then
            enableScript(script)
            count = count + 1
        end
    end
    
    log(string.format("Enabled %d LocalScripts", count))
    return count
end

-- Find scripts by name pattern
local function findScriptsByName(pattern)
    local results = {}
    pattern = pattern:lower()
    
    for script, data in pairs(trackedScripts) do
        if data.name:lower():find(pattern) then
            table.insert(results, script)
        end
    end
    
    return results
end

-- Find scripts by parent
local function findScriptsByParent(parent)
    local results = {}
    
    for script, data in pairs(trackedScripts) do
        if script:IsDescendantOf(parent) then
            table.insert(results, script)
        end
    end
    
    return results
end

-- Get script statistics
local function getStatistics()
    local total = 0
    local enabled = 0
    local disabled = 0
    
    for script, data in pairs(trackedScripts) do
        total = total + 1
        if data.enabled then
            enabled = enabled + 1
        else
            disabled = disabled + 1
        end
    end
    
    return {
        total = total,
        enabled = enabled,
        disabled = disabled
    }
end

-- Initialize monitoring
mainConnections = startMonitoring()

-- Public API
return {
    -- Monitoring
    StartMonitoring = startMonitoring,
    StopMonitoring = stopMonitoring,
    
    -- Script Management
    DisableScript = disableScript,
    EnableScript = enableScript,
    DisableAllExcept = disableAllExcept,
    EnableAll = enableAll,
    
    -- Query Functions
    GetAllScripts = getAllLocalScripts,
    ListTrackedScripts = listAllScripts,
    GetScriptInfo = getScriptInfo,
    FindByName = findScriptsByName,
    FindByParent = findScriptsByParent,
    GetStatistics = getStatistics,
    
    -- Direct Access
    TrackedScripts = trackedScripts
}
