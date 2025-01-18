local _name = "Timur"
Timur = DCAF.Story:New(_name)
if not Timur then return Error(_name .. " :: could not create story") end

Timur.Groups = {
    AmmoTruck = getUnit(_name .. " Vehicles-Ammo"),
    SetEmergencyVehicles = SET_GROUP:New():FilterPrefixes(_name .. " Emergency"):FilterOnce(),
    AirDefenses = {
        AAA = getGroup("Timur AAA")
    }
}
Timur.Distances = {
    -- key   = unit or static name
    -- value = #COORDINATE
}
Timur.Messages = {
    IncidentReported = "This is [CALLSIGN] with important information. Sukhumi local fire department is reporting a fifteen story residential building "..
                       "has just been struck by coalition air units! The local fire department is now en route on a rescue mission to the site. "..
                       "Be aware! If friendly air units have mistakenly hit a civilian building the regional situation might quickly deteriorate, "..
                       "and we can expect increased risk when operating in the north western area. Stay alert!",
    RequestSensors = "[CALLSIGN] with top priority tasking. We need sensors on the target in Sukhumi as soon as possible, to verify "..
                     "whether we have indeed struck a civilian building by mistake. The building is reported as a fifteen story residential structure in gd[".._name .. " RP]."..
                     "Repeat. Request immediate sensor tasking at gd[".._name .. " RP]. Please investigate to make sure we have not mistakenly hit that building!"
}

--- Flags story to behave like a JTAC is controlling the strike. When true, TOP DOG will not require sensor tasking if civilian building is struck (JTAC can verify)
--- @return self
function Timur:InitJTAC()
    self._isJTAC = true
    return self
end

function Timur:OnStarted()
    self:_onHitsToStaticsOrGroups()
    local staticHouse = getStatic(_name .. " Static House")
    if staticHouse then
        local coordStaticHouse = staticHouse:GetCoordinate()
        self._staticHouseCoordinate = coordStaticHouse:SetAltitude(coordStaticHouse:GetLandHeight())
        staticHouse:Destroy()
    end
end

function Timur:_onHitsToStaticsOrGroups()
    self._ammoTruckCoordinate = self.Groups.AmmoTruck:GetCoordinate()
    local timur = self
    -- units...
    local setUnits = SET_UNIT:New():FilterPrefixes(_name):FilterOnce()
    setUnits:ForEachUnit(function(unit)
        self:ActivateMilitiaAirDefence()
        local coord = unit:GetCoordinate()
        local distance = coord:Get2DDistance(timur._ammoTruckCoordinate)
        timur.Distances[unit.UnitName] = distance
        unit:HandleEvent(EVENTS.Hit, function(_, e)
            timur:_explodeAmmoTruckIfInRange(e.TgtUnit)
        end)
    end)

    -- statics...
    local setStatics = SET_STATIC:New():FilterPrefixes(_name):FilterOnce()
    setStatics:ForEachStatic(function(static)
        self:ActivateMilitiaAirDefence()
        timur.Distances[static.StaticName] = static:GetCoordinate():Get2DDistance(timur._ammoTruckCoordinate)
        static:HandleEvent(EVENTS.Hit, function(_, e)
            timur:_explodeAmmoTruckIfInRange(e.TgtUnit)
        end)
    end)
end

function Timur:_explodeAmmoTruckIfInRange(target)
    if self._isIncident then return end
    local distanceMin = Feet(100)
    local key
    if isUnit(target) then
        key = target.UnitName
    elseif isStatic(target) then
        key = target.StaticName
    else
        return Error("Timur:_explodeAmmoTruckIfInRange :: unexpected target: " .. DumpPretty(target))
    end

    local distance = self.Distances[key]
    if distance > distanceMin then return end

    -- INCIDENT (civilian house gets severely damaged by secondary explosion)
    self._isIncident = true
    self.Groups.AmmoTruck:Explode(500)
    if self._staticHouseCoordinate then
        self._staticHouseCoordinate:BigSmokeAndFireMedium()
    end
    self:_spawnEmergencyVehicles()
    self:_broadcastIncident()
    self:_onIncidentEvent()
    self:End()
end

function Timur:_spawnEmergencyVehicles()
    if not self.Groups.SetEmergencyVehicles then return end
    local delay = 0
    self.Groups.SetEmergencyVehicles:ForEachGroup(function(group)
        DCAF.delay(function()
            group:Activate()
        end, delay)
        delay = delay + math.random(2, 5)
    end)
end

function Timur:_broadcastIncident()
    if not TTS_Top_Dog then return Error("Timur:_broadcastIncident :: TTS_Top_Dog not available") end

    DCAF.delay(function()
        TTS_Top_Dog:Send(self.Messages.IncidentReported)
    end, Minutes(1))
    if self._isJTAC then return end
    DCAF.delay(function()
        TTS_Top_Dog:Send(self.Messages.RequestSensors)
    end, Minutes(2.5))
end

function Timur:HandleIncidentEvent(handler)
    Debug("Timur:HandleIncidentEvent :: handler: " .. DumpPretty(handler))
    if not isFunction(handler) then return Error("Timur:HandleIncident :: `handler` must be function, but was: " .. DumpPretty(handler)) end
    self._incidentHandlers = self._incidentHandlers or {}
    self._incidentHandlers[#self._incidentHandlers+1] = handler
end

function Timur:_onIncidentEvent()
    if not self._incidentHandlers then return end
    for _, handler in ipairs(self._incidentHandlers) do
        pcall(function()
            handler(self)
        end)
    end
end

function Timur:ActivateMilitiaAirDefence()
    if self._isMilitiaAirDefenceActive then return end
    Debug("Timur:ActivateMilitiaAirDefence")
    self._isMilitiaAirDefenceActive = true
    DCAF.delay(function()
        self.Groups.AirDefenses.AAA:Activate()
    end, 60)
end

Timur:Start()

Trace([[\\\\\\\\ Timur.lua was loaded //////////]])