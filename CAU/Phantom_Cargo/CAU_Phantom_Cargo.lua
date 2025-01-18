do -- ||||||||||||||||||    The Freedom of Press   ||||||||||||||||||
--[[  ==== REQUIREMENTS
    - DCAF.Recon
    - DCAF.Convoy
    - CAU_WinterRoses_Frequencies
    - miz should allow user Marks if TTS UN commander is enabled
]]
end

local _name = "PhantomCargo"
local _displayName = "Phantom Cargo"

PhantomCargo = DCAF.Story:New(_displayName)
if not PhantomCargo then return Error(_name .. " :: could not create story") end
local story = PhantomCargo

local cs = {
    NATO_C = "Sentinel",
    candid = "RA 78810",
    candidShort = "RA 810",
    rostov_C = "Rostov Control"
}

local flightLevel = 210

local tts_NATO_Center = DCAF.TTSChannel:New(cs.NATO_C, FREQ.NATO_Center, nil, nil):InitVoice("en-US-Casual-K")
                                                                                  :InitVariable("PC_CANDID", PhoneticAlphabet:Convert(cs.candid))
                                                                                  :InitVariable("PC_CANDID_SHORT", PhoneticAlphabet:Convert(cs.candidShort))
                                                                                  :InitVariable("ROSTOV", cs.rostov_C)

local tts_Candid = DCAF.TTSChannel:New(PhoneticAlphabet:Convert(cs.candid), FREQ.NATO_Center, nil, nil):InitVoice("ru-RU-Wavenet-B")
                                                                             :InitVariable("PC_CANDID", PhoneticAlphabet:Convert(cs.candid))
                                                                             :InitVariable("PC_CANDID_SHORT", PhoneticAlphabet:Convert(cs.candidShort))
                                                                             :InitVariable("NATO_CENTER", cs.NATO_C)

local tts_Rostov_Control = DCAF.TTSChannel:New(cs.rostov_C, FREQ.NATO_Center, nil, nil):InitVoice("ru-RU-Wavenet-D")
                                                                                       :InitVariable("PC_CANDID", PhoneticAlphabet:Convert(cs.candid))
                                                                                       :InitVariable("PC_CANDID_SHORT", PhoneticAlphabet:Convert(cs.candidShort))
                                                                                       :InitVariable("NATO_CENTER", cs.NATO_C)

PhantomCargo.Settings = {
    -- CallContactEchoCacheTolerance = 200,
    -- ReconMarkerConvoyDistanceTolerance = NauticalMiles(1),
    -- ReconMarkerIronPeakDistanceTolerance = NauticalMiles(4),
    -- MilitiaConvoySoFSeverityTolerance = 15,      -- TODO (this value is for testing; increase it) once this severity is reached the convoy RTB's
    -- MilitiaHelicoptersSoFSeverityTolerance = 15, -- TODO (this value is for testing; increase it) once this severity is reached the helicopters RTB's
    -- IsStrikeInSukhumiComplete = false,           -- (dependency) was a strike in Sukhumi has completed?
    -- VoiceUnCommander = "en-GB-Studio-B" -- "da-DK-Wavenet-C"
}

function PhantomCargo:IsStoryAutomated()
    return self.TTS_Controller
end

PhantomCargo.Coordinates = {
    DivertTbilisi = PhantomCargo:GetRefLoc(_name.." RefLoc-1"),
    StartDescent = PhantomCargo:GetRefLoc(_name.." RefLoc-2"),
    ApproachTbilisi = PhantomCargo:GetRefLoc(_name.." RefLoc-3"),
}

PhantomCargo.Groups = {
    Russia = {
        CargoPlane = getGroup(_name.." CargoPlane")
    },
    Militia = {
        Sa6_1 = getGroup(_name.." SA6-1"),
        Sa6_2 = getGroup(_name.." SA6-2"),
    },
    UN = {
        -- any?
    },
    Civilian = {
        -- any?
    },
}

PhantomCargo.Statics = {
    -- any?
}

PhantomCargo.Airbases = {
}

-- local freq_unCommander = FREQ.NATO_Center:PhoneticText(3)
-- Debug("nisse - PhantomCargo // freq_NATO_center: "..Dump(freq_unCommander))

PhantomCargo.Messages = {
    TopDog = {
        Start = "",
    },
    CargoPlane = {
        NATO_C_1 = "[NATO_CENTER]. [CALLSIGN]. We have already been cleared to divert Sukhumi. Be advised, we are critically low on fuel. "..
            "Sukhumi is our only viable option.",
        NATO_C_2 = "[NATO_CENTER]. [CALLSIGN]. Be advised, we are critically low on fuel. We have to go to Sukhumi.",
        -- long silence before...
        NATO_C_3 = "Turn heading [HEADING]. [CLIMB_OR_DESCEND]. [PC_CANDID_SHORT]",
        Acknowledge_Signal = "NATO aircraft, [CALLSIGN]. Acknowledging signal. Adjusting course as to follow.",
        StartDescent = "Expect ILS approach. Runway p[13] right. [PC_CANDID_SHORT]"
    },
    NatoCenter = {
        FlightInitialTasking = "[FLIGHT], this is [CALLSIGN]. Turn to heading [HEADING], [CLIMB_OR_DESCEND] and go to [CALLSIGN] on frequency "..
            FREQ.NATO_Center:PhoneticText().." to monitor and await further instruction. Repeat. Turn heading [HEADING]. "..
            "[CLIMB_OR_DESCEND] and go to [CALLSIGN] on frequency "..FREQ.NATO_Center:PhoneticText()..". [CALLSIGN] out.",
        FlightTaskBriefing = "[FLIGHT], this is [CALLSIGN]. Rostov Control has advised that an Aeroflot Candid headed for Sochi has been "..
            "diverted to Sukhumi. Flight identity is [PC_CANDID]. This diversion is irregular and unapproved by NATO protocols. We will try to understand the reason "..
            "for the divert but the IL-76 will not be allowed to land at Sukhumi. Ensure compliance and redirect the the Candid to Kutaisi for inspection. Repeat. "..
            "Intercept Aeroflot Candid - with number [PC_CANDID] - before it gets established for approach to Sukhumi. Then divert toward Kutaisi for now. [CALLSIGN] out.",
        Flight_3 = "[FLIGHT], this is [CALLSIGN] with an update. Rostov Control cited some runway incident at Sochi. The tower confirmed the claim but we suspect "..
            "the Russians are just trying to get that Candid to where they need it to go. Your order stands. Intercept and ensure compliance. "..
            "Then divert to Kutaisi. [CALLSIGN] out.",
        Candid_1 = "[PC_CANDID], this is [CALLSIGN] - NATO Center - good afternoon. You are operating within a NATO-enforced No-Fly Zone. Turn to heading [HEADING] "..
            "and [CLIMB_OR_DESCEND], for diversion to Kutaisi. Expect NATO military aircraft to intercept and provide escort to a safe landing. Acknowledge.",
        Candid_2 = "[PC_CANDID], [CALLSIGN]. Consider that clearance cancelled. I repeat. You are operating within a NATO-enforced No-Fly Zone. Turn immediately. Heading [HEADING] "..
            "and [CLIMB_OR_DESCEND]. Your escort will be with you shortly. Acknowledge.",
        Candid_3 = "[PC_CANDID], [CALLSIGN]. Be advised, per ICAO regulations, all aircraft operating within controlled airspace are required to carry sufficient reserve "..
            "fuel for at least one hour of flight and Kutaisi is well within that range. Sukhumi is currently unsafe for landing and I can not approve any landings at that "..
            "airport. I repeat. Turn heading [HEADING] and [CLIMB_OR_DESCEND]. Then follow your escort to Kutaisi. Now, please acknowledge.",
        Rostov_C_1 = "[ROSTOV], this is [CALLSIGN]. [PC_CANDID_SHORT] entered the NATO-enforced No-Fly Zone and has been redirected in accordance with UN Security "..
            "Council Resolution p[2141]. Sukhumi is unsafe for landing due to regional instability. [PC_CANDID] will remain under NATO escort to Kutaisi",
        Rostov_C_2 = "[ROSTOV], this is [CALLSIGN]. The No-Fly Zone is internationally recognized under UN Security Council Resolution p[2141]. "..
            "The flight path of [PC_CANDID_SHORT] is noncompliant and presents a clear violation. We advise against any escalation. [CALLSIGN] out.",
        DivertTbilisi = "[FLIGHT]. [CALLSIGN]. Turn heading [HEADING] and [CLIMB_OR_DESCEND]. New destination is Tbilisi-Lochini. Repeat. "..
            "Cancel destination Kutaisi. You are to escort [PC_CANDID] to Tbilisi-Lochini. Turn heading [HEADING] and maintain "..flightLevel.."",
        StartDescent = "[FLIGHT]. [CALLSIGN]. Turn heading [HEADING] and descend and maintain p[5000] feet. [PC_CANDID_SHORT]. Expect ILS approach. Runway p[13] right."
    },
    RostovControl = {
        NATO_C_1 = "[NATO_CENTER], this is [CALLSIGN]. [PC_CANDID] is under Russian jurisdiction. Your interference is a violation of international norms. "..
            "Release the aircraft immediately.",
        NATO_C_2 = "[NATO_CENTER], [CALLSIGN]. Your actions are a direct violation of Russian sovereignty. Any further interference with Russian aircraft will lead to "..
            "a reassessment of operational security measures in the region. Stand down immediately."
    }
}

local syntheticConversation = {
    [1] = { TTS = tts_Candid, Msg = story.Messages.CargoPlane.NATO_C_1, Text = "Candid: 'is cleared Sukhumi'" },
    [2] = { TTS = tts_Candid, Msg = story.Messages.CargoPlane.NATO_C_2, Text = "Candid: 'is low on fuel'" },
    [3] = { TTS = tts_Candid, Msg = story.Messages.CargoPlane.NATO_C_3, Text = "Candid: complies" },
    [4] = { TTS = tts_Rostov_Control, Msg = story.Messages.RostovControl.NATO_C_1, Text = "Rostov C: protest 1" },
    [5] = { TTS = tts_Rostov_Control, Msg = story.Messages.RostovControl.NATO_C_1, Text = "Rostov C: protest 2" }
}

function PhantomCargo:OnStarted()
    Debug(_name..":OnStarted")
    self:Activate(self.Groups.Russia.CargoPlane)
    self:Activate(self.Groups.Militia)
    self._candid = self.Groups.Russia.CargoPlane:GetUnit(1)
    self:_initSyntheticControllerWithAssignedFlight()
end

function PhantomCargo:DivertCargoPlaneToSukhumi()
    if self:IsFunctionDone() then return end
    if self.AssignedFlight then self:FlightInitialTasking() end
end

function PhantomCargo:FlightInitialTasking()
    if self:IsFunctionDone() then return end
    if self:IsSyntheticController() then
        if not self.OnAssignedFlight then
            Error(_name..":FlightInitialTasking :: flight was not assigned in time :: story ends")
            self:End()
        end
        local coordCandid = self._candid:GetCoordinate()
        local flight = self.AssignedFlight.Group
        self:SendSyntheticController(self:_substAtcDirectives(self.Messages.NatoCenter.FlightInitialTasking, flight, flightLevel, coordCandid))
        self:SendSyntheticController(self.Messages.NatoCenter.FlightTaskBriefing, 40)
        DCAF.delay(function()
Debug("nisse - calls PhantomCargo:PlayConversation")
            self:PlayConversation()
        end, 80)
    else
        self:EnableHumanControllerSyntheticConversation()
    end
end

function PhantomCargo:PlayConversation()
    if self:IsFunctionDone() then return end
    local candid = self._candid
    local hdg = self:_getHeadingTo(self.Coordinates.DivertTbilisi, candid)

    local function atcDirectives(call)
        local message = call.Message
        call.Message = self:_substAtcDirectives(call.Message, candid, flightLevel, hdg)
        if message == self.Messages.CargoPlane.NATO_C_3 then
            self:CargoPlaneReroute_Sukhumi(hdg)
        end
    end

    self:SrsCalls(
        self:Call(self.TTS_Controller, self.Messages.NatoCenter.Candid_1, 10, atcDirectives),
        self:Call(tts_Candid, self.Messages.CargoPlane.NATO_C_1, 10),
        self:Call(self.TTS_Controller, self.Messages.NatoCenter.Candid_2, 10, atcDirectives),
        self:Call(tts_Candid, self.Messages.CargoPlane.NATO_C_2, 10),
        self:Call(self.TTS_Controller, self.Messages.NatoCenter.Candid_3, 30, atcDirectives),
        self:Call(tts_Candid, self.Messages.CargoPlane.NATO_C_3, 10, atcDirectives),
        self:Call(tts_Rostov_Control, self.Messages.RostovControl.NATO_C_1, 20),
        self:Call(self.TTS_Controller, self.Messages.NatoCenter.Rostov_C_1, 20),
        self:Call(tts_Rostov_Control, self.Messages.RostovControl.NATO_C_2, 20),
        self:Call(self.TTS_Controller, self.Messages.NatoCenter.Rostov_C_2, 20)
    )
end

function PhantomCargo:CargoPlaneReroute_Sukhumi(hdg)
    if self:IsFunctionDone() then return end
    local group = self._candid
    local speed = group:GetVelocityKMH()
    local coord0 = group:GetCoordinate()
    local coord1 = self.Coordinates.DivertTbilisi
    local distance = coord0:Get2DDistance(coord1)
    coord1 = coord0:Translate(distance, hdg)
    coord1:SetAltitude(UTILS.FeetToMeters(flightLevel*100))
    local waypoints = {
        coord0:WaypointAirFlyOverPoint("BARO", speed),
        coord1:WaypointAirFlyOverPoint("BARO", speed)
    }
    setGroupRoute(group, waypoints)
    if DCAF.GBAD then
        local options = DCAF.GBAD.AmbushOptions:New():AttackOnlyTarget():EnsureHit(4000)
        self:SetupSamAmbushForTarget(self.Groups.Militia.Sa6_1, self._candid, options):Debug(self:IsDebug())
    end
end

function PhantomCargo:EnableHumanControllerSyntheticConversation()
    local storyMenu = self:GetMenu()
    self._syntheticConversation = {
        nextCallIndex = 1,
        menu = storyMenu:AddMenu("Conversation")
    }

    local nextCall
    local function _nextCall()
        local isConversationComplete = self._syntheticConversation.nextCallIndex > #syntheticConversation
        if self._syntheticConversation.menu then self._syntheticConversation.menu:Remove(isConversationComplete) end
        if isConversationComplete then return end
        local call = syntheticConversation[self._syntheticConversation.nextCallIndex]
        self._syntheticConversation.nextCallIndex = self._syntheticConversation.nextCallIndex + 1
        self._syntheticConversation.menu:AddCommand(call.Text, function()
            self:Send(call.TTS, call.Msg)
            nextCall()
        end)
    end
    nextCall = _nextCall
end

function PhantomCargo:OnAssignedFlight(flight)
    Debug(_name..":OnAssignedFlight :: flight: " .. DumpPretty(flight))

    local function isAssignedFlight(scan)
        return true -- nisse - speeding up testing. TODO: Ensure we only react to assigned flight
    end

    local locCargoPlane = DCAF.Location.Resolve(self.Groups.Russia.CargoPlane)
    locCargoPlane:WhenAirInRange(NauticalMiles(4), function(scan)
        if not isAssignedFlight(scan) then
            scan.EndScan = false
            return
        end
        scan.EndScan = true
        self:InitiateIntercept()
    end)
    if TTS_Top_Dog then TTS_Top_Dog:InitVariable("PC_FLIGHT", flight.CallSignPhonetic) end
    self:AddFlightSettingsMenu()
    self:_initSyntheticControllerWithAssignedFlight()
end

function PhantomCargo:AddFlightSettingsMenu()
    if self._menuFlightSettings then
        self._menuFlightSettings:RemoveChildren()
    else
        self._menuFlightSettings = self:AddFlightMenu("Task Settings")
        self._flightSettings = {
            ShowTranscript = false,
            SoundOnFlightMenu = true
        }
    end

    local function getText(value, textOn, textOff)
        if value then return textOn end
        return textOff
    end

    local text = getText(self._flightSettings.ShowTranscript, "Hide", "Show").." radio transcript"
    self._menuFlightSettings:NewCommand(text, function(menu)
        self._flightSettings.ShowTranscript = not self._flightSettings.ShowTranscript
        self:AddFlightSettingsMenu()
    end)

    text = getText(self._flightSettings.SoundOnFlightMenu, "Silence", "Enable").." task option sound"
    self._menuFlightSettings:NewCommand(text, function()
        self._flightSettings.SoundOnFlightMenu = not self._flightSettings.SoundOnFlightMenu
        self:AddFlightSettingsMenu()
    end)
end

function PhantomCargo:_initSyntheticControllerWithAssignedFlight()
    if not self.AssignedFlight or self._isSyntheticControllerInitiatedWithAssignedFlight then return end
    self._isSyntheticControllerInitiatedWithAssignedFlight = true
    self.TTS_Controller:InitFlightVariable(self.AssignedFlight.CallSignPhonetic)
end

function PhantomCargo:InitiateIntercept(group)
    if self:IsFunctionDone() then return end
    self._interceptors = {}
    local units
    if isGroup(group) then
        units = group:GetUnits()
    else
        units = self.AssignedFlight.Group:GetUnits()
    end
    for _, unit in ipairs(units) do
        local interceptor = DCAF.Interceptor:New(unit)
                                            :InitTargetUnit(self._candid)
                                            :InitRestartInterception(false)
                                            :InitLandRoute(Feet(6000), "RADIO")
                                            :Debug(self:IsDebug())
                                            :Start()

-- nisse - speed up testing the intercept so we don't actually have to set it up properly 
-- DCAF.Interceptor:OnApproaching(function(nearbyUnits)
    
-- end)
        self._interceptors[#self._interceptors+1] = interceptor
        self:_init(interceptor)
    end

end

function PhantomCargo:_init(interceptor)

    function interceptor:OnSignalIntercept(unit, signal)
        self:Intercept(unit, signal)
    end

    function interceptor:OnLeading(unit)
        if unit ~= self._candid then return end
        self._candid._isIntercepted = true
        Debug(_name..":InitiateIntercept_OnLeading :: unit: " .. unit.UnitName)
        self:CandidIsIntercepted()
        self:_end_interception_other_units(unit)
        -- -- wait one minute before making the aircraft mortal...
        -- DCAF.delay(function()
        --     self._candid:SetCommandImmortal(false)
        -- end, Minutes(1))
    end
end

function PhantomCargo:_end_interception_other_units(unit)
    for _, otherInterceptorUnit in ipairs(self._interceptors) do
        if otherInterceptorUnit ~= unit then
            otherInterceptorUnit:Stop(false)
        end
    end
end

function PhantomCargo:CandidIsIntercepted()
    self:Send(tts_Candid, self.Messages.CargoPlane.Acknowledge_Signal)
end

function PhantomCargo:DivertTbilisi()
    self:Send(tts_NATO_Center, self.Messages.NatoCenter.DivertTbilisi)
end

function PhantomCargo:_getHeadingTo(coordDestination, group)
    local coordFlight = (group or self.AssignedFlight.Group):GetCoordinate()
    if not coordFlight then return Error(_name..":_getHeadingTo :: cannot get assigned FLIGHT coordinate") end
    return roundToNearest(coordFlight:GetBearingTo(coordDestination), 5)
end

function PhantomCargo:_substHeading(text, group, destinationOrHeading)
    local hdg
    if isCoordinate(destinationOrHeading) then
        hdg = self:_getHeadingTo(destinationOrHeading, group)
    else
        hdg = destinationOrHeading
    end
    if hdg < 100 then hdg = "0"..hdg else hdg = tostring(hdg) end
    return string.gsub(text, "%[HEADING%]", "p["..hdg.."]")
end

function PhantomCargo:_substClimbOrDescentToFlightLevel(text, group, flightLevel)
    local currentAltitude = group:GetAltitude(false)
    local newAltitude = UTILS.FeetToMeters(flightLevel*100)
    local phrase
    if math.abs(newAltitude - currentAltitude) < 300 then
        phrase = "maintain current altitude"
    elseif newAltitude > currentAltitude then
        phrase = "climb and maintain flight level p["..flightLevel.."]"
    else
        phrase = "descend and maintain flight level p["..flightLevel.."]"
    end
    return string.gsub(text, "%[CLIMB_OR_DESCEND%]", phrase)
end

function PhantomCargo:_substAtcDirectives(text, group, flightLevel, destinationOrHeading)
    text = self:_substClimbOrDescentToFlightLevel(text, group, flightLevel)
    return self:_substHeading(text, group, destinationOrHeading)
end

function PhantomCargo:StartDescent()
    local startDescent = self._substHeading(self.Coordinates.ApproachTbilisi, self.Messages.NatoCenter.StartDescent)
    local response = self.Messages.CargoPlane.StartDescent
    DCAF.Story:SrsCalls(
        DCAF.Story:Call(tts_NATO_Center, startDescent, 10),
        DCAF.Story:Call(tts_NATO_Center, startDescent, 10)
    )

    self:Send(tts_NATO_Center, startDescent)
end

function PhantomCargo:ApproachTbilisi()
end

function PhantomCargo:BlueWins(resolution)
    self:End()
    self:DebugMessage(_name.." :: BLU WINS")
end

function PhantomCargo:RedWins()
    self:End()
    self:DebugMessage(_name.." :: RED WINS", 40)
end

PhantomCargo:AddStartMenu()

PhantomCargo:EnableSyntheticController(tts_NATO_Center, true)
PhantomCargo:EnableAssignFlight()

function PhantomCargo:OnDebug(value)
    if value then
        self._menuDebugActivateTestViper_1 = self:AddDebugCommand("Activate TEST Viper-1", function()
            local viper_1 = getGroup("_TEST Viper-1")
            if viper_1 and not viper_1:IsActive() then viper_1:Activate() end
        end)
    else
        if self._menuDebugActivateTestViper_1 then self._menuDebugActivateTestViper_1:Remove() end
    end
end

Trace([[\\\\\\\\ PhantomCargo.lua was loaded //////////]])