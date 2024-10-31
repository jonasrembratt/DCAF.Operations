local _name = "Mockingbird"

Mockingbird = DCAF.Story:New(_name)

DCAF.Air.ElusiveOperation = {
    ClassName = "OutOfRangeDiversion",
    ----
    HotAzumith = 25

}

Direction = {
    Left = "Left",
    Right = "Right"
}

DCAF.Air.StayOutOfRangeBehavior = {
    Hot = "Hot",        -- 
    Beam = "Beam",      -- ~
    Notch = "Notch",
    Drag = "Drag",
    Cold = "Cold"
}

function DCAF.Air.StayOutOfRangeBehavior.IsValid(value)
    for k, v in pairs(DCAF.Air.StayOutOfRangeBehavior) do
        if value == v then return true end
    end
end

function Direction.IsValid(value)
    return value == Direction.Left or value == Direction.Right
end

function DCAF.Air.ElusiveOperation:New(group, range, direction, climbAltitude)
    if not isNumber(range) then return Error("DCAF.Air.DiversionOutOfRange:New :: `range` must be #number, but was: " .. DumpPretty(range)) end
    if not Direction.IsValid(direction) then return Error("DCAF.Air.DiversionOutOfRange:New :: `direction` must be #Direction (enum), but was: " .. DumpPretty(direction)) end
    local validGroup = getGroup(group)
    if not validGroup then return Error("DCAF.Air.DiversionOutOfRange:New :: cannot resolve `group` from: " .. DumpPretty(group)) end
    if not validGroup:IsAir() then return Error("DCAF.Air.DiversionOutOfRange:New :: group is not anAIR group: " .. DumpPretty(group.GroupName)) end

    local diversion = DCAF.clone(DCAF.Air.ElusiveOperation)
    diversion.Group = validGroup
    diversion.Range = range
    diversion.GroupName = validGroup.GroupName
    diversion.Behavior = DCAF.Air.StayOutOfRangeBehavior.Hot
    diversion.Name = validGroup.GroupName .. " (" .. direction .. ")"
    diversion.HostileCoalition = GetHostileCoalition(Coalition.Resolve(validGroup:GetCoalition()))
    if isNumber(climbAltitude) then
        diversion.MaxAltitude = climbAltitude
    end
    validGroup:OptionROEHoldFire()
    diversion._monitorScheduleID = DCAF.startScheduler(function()
        diversion:_monitor()
    end, 5)
    return diversion
end

function DCAF.Air.ElusiveOperation:InitBehavior(behavior)
    if not DCAF.Air.StayOutOfRangeBehavior.IsValid(behavior) then 
        return Error("DCAF.Air.StayOutOfRange:Initbehavior :: `behavior` must be #DCAF.Air.StayOutOfRangeBehavior (enum), but was: " .. DumpPretty(behavior)) 
    end
    self.Behavior = behavior
    return self
end

function DCAF.Air.ElusiveOperation:InitDistances(beam, notch, drag, cold)
    if not isNumber(beam) then return Error("DCAF.Air.ElusiveOperation:InitDistances :: `beam` must be number, but was: " .. DumpPretty(beam)) end
    self._beamDistance = beam
    self._notchDistance = notch
    self._dragDistance = drag
    self._coldDistance = cold
    return self
end

function DCAF.Air.ElusiveOperation:_endMonitoring()
    pcall(function()
        DCAF.stopScheduler(self._monitorScheduleID)
        self._monitorScheduleID = nil
    end)
end

function DCAF.Air.ElusiveOperation:_isHot(unit)
    local coordUnit = unit:GetCoordinate()
    if not coordUnit then return end
    local bearing = coordUnit:HeadingTo(self._coordOwn)
    local heading = unit:GetHeading()
    local azimuth = (heading - bearing) % 360
    return azimuth <= self.HotAzumith
end

 function DCAF.Air.ElusiveOperation:_getClosestHostileHotUnit()
    local nearby = ScanAirborneUnits(self.Group, self.Range, self.HostileCoalition, false, true)
    if not nearby:Any() then return end
    local closestUnit
    local closestDistance = NauticalMiles(9999)
    for _, unitInfo in nearby.Units do
        if unitInfo.Distance < closestDistance and self:_isHot(unitInfo.Unit) then
            closestUnit = unitInfo.Unit
            closestDistance = unitInfo.Distance
        end
    end
    return closestUnit, closestDistance
end

function DCAF.Air.ElusiveOperation:_monitor()
    self._coordOwn = self.Group:GetCoordinate()
    if not self._coordOwn then
        return self:_endMonitoring()
    end

    local function adjustBehavior(unit, distance)
        if distance < self:GetColdDistance() then
            self:GoCold(unit, distance)
        elseif distance < self:GetDragDistance() then
            self:GoDrag(unit, distance)
        elseif distance < self:GetNotchDistance() then
            self:GoNotch(unit, distance)
        elseif distance < self:GetBeamDistance() then
            self:GoBeam(unit, distance)
        else
            self:GoHot(unit, distance)
        end
    end

    local unit, distance = self:_getClosestHostileHotUnit()
    if not unit then return end
    if distance > self:GetBeamDistance() then return end
    adjustBehavior(unit, distance)
end

function DCAF.Air.ElusiveOperation:GoBeam(unit, distance)

end