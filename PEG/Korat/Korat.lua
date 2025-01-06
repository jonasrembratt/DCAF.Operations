-- //////////////////////////////////////////////////////////////////////////////////
--                                     KORAT
--                                     *****
-------------------------------------------------------------------------------------
-- DEPENDENCIES
--   MOOSE
--   DCAF.Core
--   DCAF.CombatAirPatrol

local _name = "Korat"
Korat = DCAF.Story:New(_name)
if not Korat then return end

Korat.TigerCAP1 = getGroup(_name .. " RED CAP-1 Tiger-1")
Korat.TigerCAP2 = getGroup(_name .. " RED CAP-1 Tiger-2")

Korat.OuterCAP = {
    Name = "Outer CAP",
    CountUnits = 0,
    CountOriginalUnits = 0,
    CountLostUnits = 0,
    Coordinate = nil,
    Groups = {}
}
Korat.InnerCAP = {
    Name = "Inner CAP",
    CountUnits = 0,
    CountOriginalUnits = 0,
    CountLostUnits = 0,
    Coordinate = nil,
    Groups = {}
}

local setDetection = SET_GROUP:New():FilterPrefixes( "EWR" ):FilterOnce()
local _intel = INTEL:New(setDetection, coalition.side.RED, "Korat RED")
                    :SetFilterCategory(Group.Category.AIRPLANE, Group.Category.HELICOPTER)
                    :SetClusterAnalysis(true, true, true)
                    :SetVerbosity(2)
      _intel:__Start(2)

function Korat:OnStarted()
    self:InnerCAPMonitor()
    self:OuterCAPMonitor()
end

local function initialize(set, cap)
    set:ForEachGroup(function(group)
        if not group:IsActive() then group:Activate() end
        cap.CountUnits = cap.CountUnits + group:CountAliveUnits()
        cap.Groups[#cap.Groups+1] = group
        _intel:AddAgent(group)
    end)
    cap.CountOriginalUnits = cap.CountUnits
end

local function getMedianLocation(locations)
    if not isList(locations) or #locations == 0 then
-- Debug("nisse - getMedianCoordinate :: locations: " .. DumpPrettyDeep(locations, 2))
        return Error("getMedianCoordinate :: `locations` must be list of locations")
    end

    local function calculateMedian(numbers)
        table.sort(numbers)
        local count = #numbers
        if count % 2 == 0 then
            -- even number of elements...
            return (numbers[count / 2] + numbers[count / 2 + 1]) / 2
        else
            -- odd number of elements...
            return numbers[math.ceil(count / 2)]
        end
    end

    local xValues = {}
    local yValues = {}
    local zValues = {}

    for i, location in ipairs(locations) do
        local validLocation = DCAF.Location.Resolve(location)
        if not validLocation then return Error("getMedianCoordinate :: locations[" .. i .. "] cannot be resolved: " .. DumpPretty(location)) end
        local coord = validLocation:GetCoordinate()
        if coord then
            table.insert(xValues, coord.x)
            table.insert(yValues, coord.y)
            table.insert(zValues, coord.z)
        end
    end

    local medianX = calculateMedian(xValues)
    local medianY = calculateMedian(yValues)
    local medianZ = calculateMedian(zValues)

    return DCAF.Location:New(COORDINATE:New(medianX, medianY, medianZ))
end

local function refreshCAP(cap)
    local aliveUnits = {}

    local function count(group)
        -- seems MOOSE's :CountAliveUnits() / :IsAlive() aren't reliable we well rely on trying to get coordinates instead
        local units = group:GetUnits()
        if not units then return end
        for _, unit in ipairs(units) do
            local coord = unit:GetCoordinate()
            if coord then
                aliveUnits[#aliveUnits+1] = unit
            end
        end
    end
    for _, group in ipairs(cap.Groups) do
        count(group)
    end
    cap.CountUnits = #aliveUnits
    cap.CountLostUnits = cap.CountOriginalUnits - cap.CountUnits
    if cap.CountUnits > 0 then
        cap.Location = getMedianLocation(cap.Groups)
    else
        cap.Location = nil
    end
end

local _taskCAP = CONTROLLABLE:EnRouteTaskCAP()

local function monitorCAP(cap, triggerDistance, triggerConditionFunc)
    refreshCAP(cap)
    local contacts = _intel:GetContactTable()
    local coordCAP = cap.Location:GetCoordinate()
    local hostileUnits = {}

    local function processContact(contact)
        local group = contact.group
        for _, unit in ipairs(group:GetUnits()) do
            local coordUnit = unit:GetCoordinate()
            if coordUnit then
                local distance = coordUnit:Get2DDistance(coordCAP)
                if distance <= triggerDistance then
                    hostileUnits[#hostileUnits+1] = unit
                end
            end
        end
    end

    for _, contact in ipairs(contacts) do
        processContact(contact)
    end

    if #hostileUnits < 2 then return end
-- MessageTo(nil, "CAP activates :: " .. cap.Name)
    -- set to CAP tasking...
if cap._debug_trigger_range_markID then COORDINATE:RemoveMark(cap._debug_trigger_range_markID) end
    for _, group in ipairs(cap.Groups) do
        if not triggerConditionFunc or triggerConditionFunc(group) then
            group:PushTask(_taskCAP)
        end
    end
    local schedulerID = cap._schedulerID
    cap._schedulerID = nil
    pcall(function() DCAF.stopScheduler(schedulerID) end)
    return hostileUnits
end

local function getDetectedUnitsWithinDistance(coordinate, distance, breakOnCount)
    if not coordinate then return end
    local contacts = _intel:GetContactTable()
    if not isNumber(breakOnCount) then breakOnCount = 1 end
    local units = {}
    for _, contact in ipairs(contacts) do
        local group = contact.group
        for _, unit in ipairs(group:GetUnits()) do
            local coordUnit = unit:GetCoordinate()
            if coordUnit and coordUnit:Get2DDistance(coordinate) <= distance then
                units[#units+1] = unit
            end
        end
    end
    if #units > 0 then
        return units
    end
end

local function routeInWeeds(group, coordDestination, speed, triggerDistance)
-- Debug("nisse - routeInWeeds :: " .. group.GroupName .. " :: triggerDistance: " .. UTILS.MetersToNM(triggerDistance))
    local coordGroup = group:GetCoordinate()
    if not coordGroup then return end
    local lowAltitude = UTILS.FeetToMeters(150)
    local heading = coordGroup:HeadingTo(coordDestination)
    local coordWP1 = coordGroup:Translate(NauticalMiles(6), heading)
    local route = {
        coordWP1:SetAltitude(lowAltitude):WaypointAirFlyOverPoint("RADIO", speed),
        coordDestination:SetAltitude(lowAltitude):WaypointAirFlyOverPoint("RADIO", speed)
    }
-- Debug("nisse - routeInWeeds :: route: " .. DumpPrettyDeep(route, 2))
    setGroupRoute(group, route)
    group._runInSchedulerID = DCAF.startScheduler(function()

-- if group._nisse_range_marker_id then COORDINATE:RemoveMark(group._nisse_range_marker_id) end
        local coordGroup = group:GetCoordinate()
        if not coordGroup or group._isScramming then
-- Debug("nisse - routeInWeeds :: " .. group.GroupName .. " (ENDS monitor)")
            pcall(function() DCAF.stopScheduler(group._runInSchedulerID) end)
            return
        end
-- group._nisse_range_marker_id = coordGroup:CircleToAll(triggerDistance, nil, nil, .2)
        local hostileUnits = getDetectedUnitsWithinDistance(coordGroup, triggerDistance)
-- Debug("nisse - routeInWeeds :: " .. group.GroupName .. " :: hostileUnits: " .. DumpPretty(hostileUnits))
        if not hostileUnits then return end
-- Debug("nisse - routeInWeeds :: " .. group.GroupName .. " :: pushed CAP!")
-- if group._nisse_range_marker_id then COORDINATE:RemoveMark(group._nisse_range_marker_id) end
--         group:PushTask(_taskCAP)
--         pcall(function() DCAF.stopScheduler(group._runInSchedulerID) end)
    end, 4)
end

function Korat:OuterCAPMonitor()
    local set = SET_GROUP:New():FilterPrefixes(_name .. " RED CAP-1"):FilterOnce()
    initialize(set, self.OuterCAP)

    local function doNotTaskTigersWithCAP(group) return not string.find(group.GroupName, "Tiger") end

    self.OuterCAP._schedulerID = DCAF.startScheduler(function()
        local hostileUnits = monitorCAP(self.OuterCAP, NauticalMiles(50), doNotTaskTigersWithCAP)
        if not hostileUnits then return end
        -- CAP is engaging; monitor progress...
        local coordTgt = getMedianLocation(hostileUnits):GetCoordinate()
        local coordTigerCAP1 = self.TigerCAP1:GetCoordinate()
        local headingTigersRun = coordTigerCAP1:HeadingTo(coordTgt)
        local speedTigersRun = self.TigerCAP1:GetSpeedMax()

        local function tigerRunIn(tigerGroup)
            local coordTigerCAP = tigerGroup:GetCoordinate()
            local distance = coordTigerCAP:Get2DDistance(coordTgt)
            local tgtCoord = coordTigerCAP:Translate(distance, headingTigersRun)
            routeInWeeds(tigerGroup, tgtCoord, speedTigersRun, NauticalMiles(15))
        end

        tigerRunIn(self.TigerCAP1)
        tigerRunIn(self.TigerCAP2)

        self:OuterAttackMonitor()
    end, 5)
end

local _KermanAirbase = AIRBASE:FindByName(AIRBASE.PersianGulf.Kerman)
local _KermanAirbaseCoordinate = _KermanAirbase:GetCoordinate()

local function scramCAP(cap, conditionFunc)
-- nisse
-- MessageTo(nil, "SCRAM!!! " .. cap.Name)

    local function rtb(group)
        local coord = group:GetCoordinate()
        if not coord then return end
        local hdg = _KermanAirbaseCoordinate:HeadingTo(coord)
        local coordIP = _KermanAirbaseCoordinate:Translate(NauticalMiles(15), hdg):SetAltitude(Feet(5000))
-- coordIP:CircleToAll(NauticalMiles(5), nil, {1,1,1})
        local route = {
            coordIP:WaypointAirFlyOverPoint("RADIO", group:GetSpeedMax()),
            _KermanAirbaseCoordinate:WaypointAirLanding(nil, _KermanAirbase)
        }
        setGroupRoute(group, route)
    end

    for _, group in ipairs(cap.Groups) do
        if not conditionFunc or conditionFunc(group) then
            group._isScramming = true
            rtb(group)
        end
    end
end

function Korat:OuterAttackMonitor()
    self.OuterCAP._schedulerID = DCAF.startScheduler(function()
        local cap = self.OuterCAP
        refreshCAP(cap)
-- Debug("nisse - Korat:OuterAttackMonitor :: cap: " .. DumpPretty(cap))
        if cap.CountLostUnits < 1 then return end
        scramCAP(cap)
        pcall(function() DCAF.stopScheduler(cap._schedulerID) end)
        self:InnerCAPAttack()
    end, 5)
end

function Korat:InnerCAPMonitor()
    local set = SET_GROUP:New():FilterPrefixes(_name .. " RED CAP-2"):FilterOnce()
    initialize(set, self.InnerCAP)
    self.InnerCAP._schedulerID = DCAF.startScheduler(function()
        local hostileGroups = monitorCAP(self.InnerCAP, NauticalMiles(60))
        if not hostileGroups then return end
        -- CAP is engaging; monitor progress...
        self:InnerCAPAttack()
    end, 4)
end

function Korat:InnerCAPAttack()
    pcall(function() DCAF.stopScheduler(self.InnerCAP._schedulerID) end)
    for _, group in ipairs(self.InnerCAP.Groups) do
        group:PushTask(_taskCAP)
    end
    self:InnerAttackMonitor()
end

function Korat:InnerAttackMonitor()
    self.InnerCAP._schedulerID = DCAF.startScheduler(function()
        local cap = self.InnerCAP
        refreshCAP(cap)
        if cap.CountLostUnits < 2 then return end
        scramCAP(cap)
        pcall(function() DCAF.stopScheduler(cap._schedulerID) end)
    end, 4)
end

Korat:Start()

Trace("\\\\\\\\\\ Korat.lua was loaded //////////")