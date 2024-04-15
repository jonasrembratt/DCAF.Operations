-- //////////////////////////////////////////////////////////////////////////////////
--                                     SWALLOW
--                                     *******
-- Transport aircraft arrives into Syria from the north west, with a mission to drop
-- supplies into the Rojava area. The aircraft needs escort before they can enter
-- Syrian airspace

-- TODO
-- More messages (top dog) -- Needs final approval
-- Complete isEscortNearby function

local _codeword = "Swallow"
Swallow = {
    Name = _codeword,
    Groups = {
        BLU = {
            Hercs_1 = getGroup("Swallow Hercs-1"),
            Vipers_1 = getGroup("Swallow F16-1"),
        },
        RED = {
            Gauntlet = getGroup("Swallow Gauntlet-1")
        }
    },
    -- after Hercs passes GoNogo point the SA-15 is activated, but in GREEN state until mission BLU aircraft types gets within the specified range...
    WakeGauntletTypes = {
        ENUMS.UnitType.C_130,
        ENUMS.UnitType.F16CM,
        ENUMS.UnitType.F15ESE,
        ENUMS.UnitType.AVN8B,
    },
    WakeGauntletRange = NauticalMiles(40),
    MSG = {
        Start =
            "[CALLSIGN], all stations. Priority mission. Operation " .. _codeword .. " is underway. Requst immediate escort tasking of " .. _codeword .. " one, " ..
            "to their destination in the no fly zone.",
        RequestEscort =
            "[CALLSIGN], all stations. Relaying urgent request from [CALLSIGN] actual! " .. _codeword .. " one is expected to enter the no fly zone at time plus seventeen " ..
            "and is requesting immediate escort. [CALLSIGN] actual would like to remind you that the ".. _codeword .. " one mission is critical to our objective. [CALLSIGN] out.",
        MissionComplete =
            "[CALLSIGN], all stations, " .. _codeword .. " has completed their mission and is RTB. [CALLSIGN] actual is pleased with your work. [CALLSIGN] out.",
        GauntletActive =
            "[CALLSIGN], all stations, urgent tasking. We are picking up emission from an active Gauntlet at grid p[EV 09], keypad one. " ..
            "The S A fifteen is an imminent threat toward " .. _codeword .. " one and must be eliminated or suppressed before the hercs "..
            "reaches the area in about nine minutes. Repeat. Request immediate destruction of Gauntlet vehicle in grid p[EV 09] keypad one, "..
            "to ensure safety for " .. _codeword .. " one supply drop mission. [CALLSIGN] out.",
        MissionAbortedNoEscort =
            "[CALLSIGN] with an update. Failure to provide security for the " .. _codeword .. " supply drop mission has forced it to cancel and "..
            "return to base. This is very unfortunate!",
        MissionAbortedGauntletAwake =
            "[CALLSIGN] with an update. The Gauntlet in grid p[EV 09] is still awake and represent an unacceptable threat to " .. _codeword .. " one. "..
            "The supply drop is therefore cancelled and " .. _codeword .. " one is now RTB. This is very unfortunate.",
        TDA_ScoldingNoEscort =
            "[CALLSIGN] here. Listen up! I'm disappointed to report that due to failure to meet mission" ..
            " criteria on time, " .. _codeword .. " mission has been scrapped. We operate on precise timelines for a reason. "..
            "Failure to adhere to these timelines jeopardizes not only the success of the mission, but the safety of every member of this unit. " ..
            "This lack of discipline is unacceptable. We cannot afford to make excuses or overlook the importance of our protocols. " ..
            "I expect better from each and every one of you. We will review our procedures and ensure that this does not happen again. " ..
            "Get your act together, pilots. Our reputation, and the lives of our comrades are at stake. Flight leads, expect a full debrief "..
            "and review tomorrow at oh eight hundred. [CALLSIGN] out.",
        TDA_ScoldingGauntletAwake =
            "[CALLSIGN] here. Listen up! I'm disappointed to report that due to failure to uphold security " .. _codeword .. " mission has been scrapped. "..
            "We need to do better! The inability to react to unexpected threats jeopardizes not only the success of the mission, but the safety of every member "..
            "of this unit. This is unacceptable. I expect better from each and every one of you. We will review our ability to prioritize and make proper decisions "..
            "to ensure that this does not repeated.  Our reputation, and the lives of our comrades are at stake. Flight leads, expect a full debrief "..
            "and review tomorrow at oh eight hundred. [CALLSIGN] out.",
    }
}

function Swallow:Start(tts)
    if self._is_started then return end
    self._is_started = true
    self._start_menu:Remove(true)
    self.TTS = tts
    self.Groups.BLU.Hercs_1:Activate()
    self.Groups.BLU.Vipers_1:Activate()
    self:Send(self.MSG.Start)
    self._is_escorted = nil
    self:_monitorForEscort()
end

function Swallow:Send(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:Send(msg)
end

function Swallow:SendActual(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:SendActual(msg)
end

function Swallow:_monitorForEscort()

    --[[ this is what we get back from ScanAirborneUnits function:
        DCAF.ClosestUnits = {
            ClassName = "DCAF.ClosestUnits",
            Count = 0,
            Units = { -- dictionary
                -- value = { Unit = #UNIT, Distance = #number (meters) }
            }
        }]]

    local hercs = self.Groups.BLU.Hercs_1
    if not hercs then return end
    local hercsLocation = DCAF.Location.Resolve(hercs)

    self._monitor_escort_scheduleID = DCAF.startScheduler(function()
        if not hercs:IsAlive() then
            self:_stopMonitorForEscort()
            return
        end
        local hercsHeading = hercs:GetHeading()
        local hercsSpeed = hercs:GetVelocityKNOTS()
        local closestUnits = hercsLocation:ScanAirborneUnits(NauticalMiles(3), Coalition.Blue, false, true)
Debug("sausage → _monitorForEscort :: " .. DumpPrettyDeep(closestUnits, 3))
        if not closestUnits:Any() then return end
        local function isWithinParameters(unit)
            local unitHeading = unit:GetHeading()
            if math.abs(unitHeading - hercsHeading) > 5 then return end
            local unitSpeed = unit:GetVelocityKNOTS()
            return math.abs(unitSpeed - hercsSpeed) < 20
        end

        for _, unitInfo in ipairs(closestUnits.Units) do
            if not isWithinParameters(unitInfo.Unit) then return end
            self._is_escorted = true
            self:_stopMonitorForEscort()
Debug("sausage → _monitorForEscort :: Hercs are now escorted :: ENDS SCHEDULING")
            return
        end
    end, 10)
end

function Swallow:_stopMonitorForEscort()
    if not self._monitor_escort_scheduleID then return end
    DCAF.stopScheduler(self._monitor_escort_scheduleID)
    self._monitor_escort_scheduleID = nil
end

function Swallow:RequestEscort()
    if self._is_escorted == true then return end
    self:Send(self.MSG.RequestEscort)
end

function Swallow:GoNoGoDecision()
    self:_stopMonitorForEscort()
    if self._is_escorted then
        self:ActivateGauntlet(self.WakeGauntletRange)
    else
        self:MissionAbortedNoEscort()
    end
end

function Swallow:ActivateGauntlet(wakeUpAtRangeMeters)
    self.Groups.RED.Gauntlet:Activate()
Debug("nisse - Swallow:ActivateGauntlet :: wakeUpAtRange: " .. Dump(wakeUpAtRangeMeters))
    if isNumber(wakeUpAtRangeMeters) then
Debug("nisse - Swallow:ActivateGauntlet :: gauntlet is in GREEN state until hostiles gets to " .. UTILS.MetersToNM(wakeUpAtRangeMeters) .. " nm")
        self.Groups.RED.Gauntlet:OptionAlarmStateGreen()
        local locGauntlet = DCAF.Location.Resolve(self.Groups.RED.Gauntlet)
        locGauntlet:OnUnitTypesInRange(self.WakeGauntletTypes, wakeUpAtRangeMeters, Coalition.Blue, function()
Debug("nisse - Swallow:ActivateGauntlet :: hostiles at ".. UTILS.MetersToNM(wakeUpAtRangeMeters) .. " nm...")
            Swallow:ActivateGauntlet()
        end)
        return self
    end
Debug("nisse - Swallow:ActivateGauntlet :: wakes up gauntlet!")
    self.Groups.RED.Gauntlet:OptionAlarmStateRed()
    DCAF.delay(function()
        if not self.Groups.RED.Gauntlet:IsAlive() then return end
        self:Send(self.MSG.GauntletActive)
    end, 30)
end

function Swallow:_topDogActualScolding(msg, delay)
    DCAF.delay(function()
        -- temporarily tunes Guard to give everyone a dress-down for failing the mission...
        self.TTS:Tune(Frequencies.Guard)
        self:SendActual(msg)
        self.TTS:Detune()
    end, delay or Minutes(2))
end

function Swallow:MissionAbortedNoEscort()
    self:Send(self.MSG.MissionAbortedNoEscort)
    self:_topDogActualScolding(self.MSG.TDA_ScoldingNoEscort, Minutes(2))
    RTBNow(self.Groups.BLU.Hercs_1, AIRBASE.Syria.Incirlik)
end

function Swallow:AbortOnGauntletActive()
    if not self.Groups.RED.Gauntlet:IsAlive() then return end
    Divert(self.Groups.BLU.Hercs_1)
    self:Send(self.MSG.MissionAbortedGauntletAwake)
    self:_topDogActualScolding(self.MSG.TDA_ScoldingGauntletAwake, Minutes(2))
end

function Swallow:MissionComplete()
    self:Send(self.MSG.MissionComplete)
end

function Swallow:CAS_Request()
    if not self.Groups.RED.Gauntlet:IsAlive() then return end
    self.Groups.RED.Gauntlet:GetUnit(1):Explode(1500, 10)
    self._CAS_menu:Remove(true)
end

Swallow._main_menu = GM_Menu:AddMenu(_codeword)
Swallow._start_menu = Swallow._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Swallow:Start(tts)
end)
Swallow._CAS_menu = Swallow._main_menu:AddCommand("Request CAS", function()
    Swallow:CAS_Request()
end)
Swallow._sim_escort_menu = Swallow._main_menu:AddCommand("Simulate escort", function()
    Swallow._is_escorted = true
    Swallow._sim_escort_menu:Remove()
end)

-- Debug("sausage →→ " .. DumpPrettyDeep(Swallow))