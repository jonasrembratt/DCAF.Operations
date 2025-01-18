--- https://en.wikipedia.org/wiki/HMS_Leeds_Castle_(P258)
--- https://en.wikipedia.org/wiki/Russian_frigate_Yaroslav_Mudry


local _name = "Silent Guard"
local Phases = {
    PreHail = "Pre Hailed",
    Hailed = "Hailed",
    HelicopterDeployed = "Helicopter Deployed"
}

SilentGuard = DCAF.Story:New(_name)
if not SilentGuard then return Error(_name .. " :: could not create story") end
SilentGuard.Phase = Phases.PreHail

local unVessel = "SilentGuard UN Container Ship"

SilentGuard.Groups = {
    BLU = {
        ContainerShip = getGroup(unVessel),
        LeedsCastle = getGroup("SilentGuard HMS Leeds Castle")
    },
    RED = {
        NavyVessels = getGroup("SilentGuard RUS Navy"),
        Helicopter = getGroup("SilentGuard RUS Ka27"),
        HelicopterStatic = getStatic("SilentGuard RUS Ka27 Static"),
        RefRTB = getGroup("SilentGuard RUS Ref RTB")
    },
}

local maritime = DCAF.Frequencies:GetSystem("maritime")
local navy12 = maritime:Get("12")
local navy16 = maritime:Get("16")
local navy18 = maritime:Get("18")

local cs = {
    unShip = "COSCO Panama",
    unEscort = "Leeds Castle",
    rusNavy  = "Yaroslav Mudry"
}

SilentGuard.TTS_Top_Dog = TTS_Top_Dog

SilentGuard.Messages = {
    Start = "[CALLSIGN]. We have a report from the HMS " .. cs.unEscort .. ", currently escorting the container ship 'Cosco Panama' in kp["..unVessel.."], en route to Batumi "..
        "under UN charter. The vessel is carrying UN personnel and material for the peacekeeper mission. "..
        cs.unEscort .. " report a Russian naval force appears to be on an intercept course from the north. The escort commander request air units be dispatched to assist and provide security. "..
        "Repeat. Please dispatch air units to provide security for UN vessel Cosco Panama and HMS ".. cs.unEscort .. ", currently en route to Batumi, kp["..unVessel.."]."..
        "Please advice the assigned flight to tune maritime channel p[18] and await instructions from the escort vessel. Repeat. Flight is to tune maritime channel p[18] and await instructions from HMS " .. cs.unEscort .. ". [CALLSIGN] out",

    Escort = {
        Hail_1_Response = "Warship " .. cs.rusNavy .. ", this is warship " .. cs.unEscort .. ". I read you loud and clear. Go ahead, over.",
        Hail_2_Response = cs.rusNavy .. ", this is HMS " .. cs.unEscort .. ". Switching to Channel p[12]. Out.",
        Hail_2_AdviseFlightChannelShift = "[FLIGHT], this is " .. cs.unEscort .. ". Please monitor channel p[12]. Out.",
        Hail_3_Response = cs.rusNavy .. ". HMS [CALLSIGN]. We are conducting lawful freedom of navigation in international waters, "..
            "escorting a UN vessel which is exempt from inspection under international law. Be advised NATO aircraft is observing "..
            "your actions and will be called upon to assist, if necessary. I recommend you withdraw immediately! ",
        Hail_4_Response = cs.rusNavy .. ". HMS [CALLSIGN]. Your demand to board a UN humanitarian vessel is unlawful and unacceptable. The United Nations mission "..
            "is internationally sanctioned, and your actions constitute interference in a protected operation. We advise you to cease this provocation immediately and allow "..
            "the vessel to proceed unimpeded. Any further attempts to obstruct this mission will be reported to NATO command and the UN Security Council.",
        FlightArrivesPreHail = "[FLIGHT]. This is Commander Markham of the HMS [CALLSIGN]. We are on an escort mission, bringing the UN chartered ship '".. cs.unShip .."' to Batumi, and we are very glad you "..
            "could join us out here! The Russian group is to our north, on an intercept course. Please find and identify the individual vessels to get an idea what we are up against, but keep your distance for now, "..
            "and don't provoke them. We expect them to hail us on channel p[16] soon. When they do, we plan to put on our best diplomatic show. But we might need you lads to show them the fury of NATO air should they be "..
            "uncooperative. Please stay safe up there, and monitor channel p[16] with us. [CALLSIGN] out",
        FlightArrivesPostHail = "[FLIGHT]. This is Commander Markham of the HMS [CALLSIGN]. We are on an escort mission, bringing the UN chartered ship '".. cs.unShip .."' to Batumi, and we are very glad you "..
            "could join us out here! The Russian group is to our north, still heading to intercept. Please find and identify the individual vessels to get an idea what we are up against, but keep your distance for now, and don't provoke them. "..
            "Please monitor channel p[12] where we are currently playing the diplomatic game. Request you stand by to show them the fury of NATO air forces, should they be uncooperative. "..
            "Welcome lads! Stay sharp up there, and monitor channel p[12] with us. [CALLSIGN] out",
        FlightArrivesHelicopterDeployed = "[FLIGHT]. This is Commander Markham of the HMS [CALLSIGN]. We are in trouble here and need you lads to make the Russians back down! "..
            "We are escorting the UN chartered container ship ".. cs.unShip .." - the big girl sailing behind us."..
            "The Russian group is following us, port side, two frigates and two patrol boats. The lead frigate - "..cs.rusNavy.." - has already deployed a helicopter and we suspect it will attempt a boarding operation. "..
            "Request immediate show of force to get it to back off! Please monitor channel p[12] where we've been playing the diplomatic game, so far to no avail. We now need you to show them the fury of NATO air force! "..
            "Don't hurt the helicopter but show we mean business if it doesn't back down! [CALLSIGN] out",
        RedNavyShootsAAA = "[FLIGHT]!. [CALLSIGN]! Watch our for Russian triple-A! They might just be warning shots but I wouldn't trust the aim of the Russian sailors!",
        RussianHelicopterStartingUp = "[FLIGHT]. [CALLSIGN] here. We can see the Russian frigate - ".. cs.rusNavy .. " - is preparing to launch its helicopter now. " ..
            "We will try to dissuade them from actually sending it over but stand by for a show of force if needed",
        RussianHelicopterDeployed = cs.rusNavy .. ", this is HMS [CALLSIGN]. I repeat. UN vessels are exempt from inspection under international law. "..
            "Withdraw your helicopter immediately, or NATO aircraft will be forced to intercept.",
        RussianHelicopterEnRoute_1 = "[FLIGHT]. [CALLSIGN]. The Russian helicopter is airborne but it cannot be allowed to reach the UN container ship, or us. Request an immediate Show of Force! See if you can get them to turn back.",
        RussianHelicopterEnRoute_2 = "[FLIGHT]. [CALLSIGN]. The helicopter is maneuvering after your show of force. But it's now en route again, for the "..cs.unShip..". Please give it another show of force. Try to be more aggressive, but don't cause an accident please?",
        RussianHelicopterAttemptsBoarding = "[FLIGHT]. [CALLSIGN]. The helicopter is preparing to board the UN ship! Try a final show of force against the Russian warships. You are cleared to drop ordnance near any of the vessels to demonstrate we mean business!",
        AdviceFlightOnRedNavyBehavior = "[FLIGHT], [CALLSIGN] again. Be advised, Russian naval forces in this region have a history of provocative behavior. "..
            "They may lock targeting radars on nearby aircraft as a warning, and in some cases, have fired missiles deliberately neutralized shortly after launch. "..
            "Maintain a distance of at least six or seven miles, and exercise caution, unless otherwise requested. And remember, your presence is critical to deterring further escalation. Stay sharp out there! [CALLSIGN] out",
        RussiansDepart = "[FLIGHT]. This is [CALLSIGN]. The Russian warships are withdrawing and the helicopter has been called back so "..
            "we should be able to handle it from here. Excellent work lads! You are cleared to depart. The Royal Navy thank you for your service. God speed!",
        RussiansSuccessfullyBoards = "[FLIGHT]. This is [CALLSIGN]. We got a call from the UN ship. The Russians have successfully boarded and are now in control of the ship. "..
            "We assume they will force it to return to Sochi or Sevastopol and there's not much else we can do without escalating this conflict into a shooting war. "..
            "Maybe we should have been more aggressive in our Shows of Force? "..
            "We will follow and monitor, to see if we can resolve the situation via diplomatic channels now. You may depart. Thank you for trying. [CALLSIGN] out."
    },

    RussianFrigate = {
        Hail_1 = "Warship HMS ".. cs.unEscort.. ", this is the warship "..cs.rusNavy..", on Channel p[16]. Over.",
        Hail_2 = "HMS ".. cs.unEscort.. ", this is the "..cs.rusNavy.." of Russian navy. Switch to Channel p[12], over.",
        Hail_3 = "Attention NATO escort ship, this is [CALLSIGN] of Russian Navy. Your vessel is escorting a ship suspected of carrying unauthorized materials "..
            "through our region. For the sake of regional stability, you are ordered to prepare for inspection and allow a boarding party to conduct a thorough search. "..
            "Noncompliance will be viewed as a hostile act and an obstruction to lawful operations.",
        Hail_4 = cs.unEscort ..  ", this is [CALLSIGN]. Your assertion of a UN mandate is irrelevant. The so-called mission is not recognized by "..
            "the Russian Federation and is therefore unlawful within our region. We will proceed with our inspection to ensure compliance with international stability efforts. "..
            "Prepare to comply, or we will take further necessary measures to enforce this action.",
        RussianHelicopterRTB = cs.unEscort .. ", this is [CALLSIGN]. Your actions have been noted. The helicopter has withdrawn, but we will continue to observe this "..
            "region to ensure stability and compliance with international protocols. Any further provocations will not be tolerated. I strongly advise reconsidering the aggressive "..
            "posture of NATO forces in these waters.",
        RussiansWithdrawAfterWeaponImpact = cs.unEscort ..  ". this is [CALLSIGN]. Your reckless display has been noted and will not go unanswered. We are withdrawing to avoid "..
            "unnecessary escalation, but let it be clear — NATO's provocations will have consequences. Consider this your warning."
    }
}

local unEscortVoice = "en-GB-News-H"
local TTS_Escort_Flight = DCAF.TTSChannel:New(cs.unEscort, navy18, AM, nil):InitVoice(unEscortVoice):InitFlightVariable("NATO flight")

function SilentGuard:InitTTSFrequencies(navyHail, navyComms, navyFlight, navyOpenModulation, navyFlightModulation)
    local rusNavyVoice = "ru-RU-Wavenet-D"
    self.TTS_Escort_Hail = DCAF.TTSChannel:New(cs.unEscort, navyHail, navyOpenModulation or "AM", nil):InitVoice(unEscortVoice)
    self.TTS_Escort_Comms = DCAF.TTSChannel:New(cs.unEscort, navyComms, navyOpenModulation or "AM", nil):InitVoice(unEscortVoice)
    self.TTS_RusNavy_Hail = DCAF.TTSChannel:New(cs.rusNavy, navyHail, navyOpenModulation or "AM", nil):InitVoice(rusNavyVoice)
    self.TTS_RusNavy_Comms = DCAF.TTSChannel:New(cs.rusNavy, navyComms, navyOpenModulation or "AM", nil):InitVoice(rusNavyVoice)
    -- flight should listen to Escort of CHANNEL 4 (154.250)...
    local escortFlight = self.TTS_Escort_Flight or TTS_Escort_Flight
    escortFlight:Tune(navyFlight, navyFlightModulation)
end

-- use channels 18 and 52 for hail and subsequent inter-ship comms...
SilentGuard:InitTTSFrequencies(navy16, navy12, navy18)

function SilentGuard:OnStarted()
    Debug("SilentGuard:OnStarted")
    self._menuStart:Remove(false)
    self.Groups.BLU.ContainerShip:Activate()
    self.Groups.BLU.LeedsCastle:Activate()
    self.Groups.RED.NavyVessels:Activate()
    self:Send_TopDog(self.Messages.Start)

    self._allowMissileAirTime = .1
    -- when BLU air gets within short range, RED navy will start issuing warnings by locking radar and fire warning shots
    self.Groups.RED.RefRTB:Activate()
    self._coordRussianNavyRTB = self.Groups.RED.RefRTB:GetCoordinate()
    self._russianFrigate = self.Groups.RED.NavyVessels:GetUnit(1)
    self:_monitorPlayerFlightArrival()
end

function SilentGuard:_monitorPlayerFlightArrival()
    Debug("SilentGuard:_monitorFlightArrival")
    self._monitorFlightArrivalSchedulerID = DCAF.startScheduler(function()
        local friendlyAir = ScanAirborneUnits(self.Groups.BLU.ContainerShip, NauticalMiles(18), Coalition.Blue, false)
        if friendlyAir:AnyPlayer() then
            self:FriendlyAirArrives()
            pcall(function() DCAF.stopScheduler(self._monitorFlightArrivalSchedulerID) end)
            self._monitorFlightArrivalSchedulerID = nil
        end
    end, 10)
end

function SilentGuard:FriendlyAirArrives()
    Debug("SilentGuard:FriendlyAirArrives")
    self:_redNavyShowOfForceBegin()
    self._isFlightArrived = true
    if not self.TTS_Escort_Flight then return Error("SilentGuard:FriendlyAirArrives :: a flight channel has not been set") end
    if self.Phase == Phases.PreHail then
        self:Send(self.TTS_Escort_Flight, self.Messages.Escort.FlightArrivesPreHail)
    elseif self.Phase == Phases.Hailed then
        self:Send(self.TTS_Escort_Flight, self.Messages.Escort.FlightArrivesPostHail)
    elseif self.Phase == Phases.HelicopterDeployed then
        self:Send(self.TTS_Escort_Flight, self.Messages.Escort.FlightArrivesHelicopterDeployed)
        self._isHeliCopterSoFInitiated = true
    end
    self:SendDelayed(Minutes(2), self.TTS_Escort_Flight, self.Messages.Escort.AdviceFlightOnRedNavyBehavior)
end

function SilentGuard:_redNavyShowOfForceBegin()
    self._redNavySOF = DCAF.ShowOfForce.React(self.Groups.RED.NavyVessels, function(sof, event)
        self._hasWeaponBeenDeployed = self._hasWeaponBeenDeployed or event:IsWeaponImpact()
        if self._debug then
            MessageTo(nil, event:DebugText(), 20)
        end
        if sof.Severity >= 100 then
            self:RussianNavyLoses()
        else
            -- Russian navy will use radar locks etc. to dissuade NATO air from further Shows of Force
            self:_redNavyFeintAttack(Minutes(1))
        end
    end, DCAF.ShowOfForceOptions:New():InitBuzz(400))
end

function SilentGuard:_redNavyShowOfForceEnd()
    self._redNavySOF:End()
end

function SilentGuard:_redNavyFeintAttack(delay, maxShots)
    if not self._handleRedNavyAAA then
        self._handleRedNavyAAA = BASE:New():HandleEvent(EVENTS.ShootingStart, function(_, e)
            self:OnRedNavyFirstAAA()
        end)
    end
    DCAF.delay(function()
        FeintAttack(self.Groups.RED.NavyVessels, maxShots, self._allowMissileAirTime, -1, function()  -- allow vessels to fire two warning shots
            -- each new "feint attack session", vessels increase flight time for missiles (up to 4 seconds), making each warning more severe
            -- once two warning shots are fired, vessels step down for two minutes; then initiates more warnings
            self._allowMissileAirTime = math.min(4, self._allowMissileAirTime --[[+ .5]])
            self:_redNavyFeintAttack(Minutes(1), maxShots)
        end, ignore)
    end, delay or 1)
end

function SilentGuard:OnRedNavyFirstAAA()
    Debug("SilentGuard:RedNavyShootsAAA")
    self._handleRedNavyAAA:UnHandleEvent(EVENTS.ShootingStart)
    self:SendDelayed(20, self.TTS_Escort_Flight, self.Messages.Escort.RedNavyShootsAAA)
end

function SilentGuard:Send_TopDog(msg)
    Debug("SilentGuard:Send_TopDog :: msg: " .. Dump(msg))
    if not self.TTS_Top_Dog or not isAssignedString(msg) then return Error("SilentGuard:Send_TopDog :: TTS_TopDog was not assigned, or message was nil") end
    self.TTS_Top_Dog:Send(msg)
end

function SilentGuard:Hail()
    self:EnableRussianHelicopter()
    self.Phase = Phases.Hailed
    self:SrsCalls(
        self:Call(self.TTS_RusNavy_Hail, self.Messages.RussianFrigate.Hail_1, 20),
        self:Call(self.TTS_Escort_Hail, self.Messages.Escort.Hail_1_Response, 20),
        self:Call(self.TTS_RusNavy_Hail, self.Messages.RussianFrigate.Hail_2, 20),
        self:Call(self.TTS_Escort_Hail, self.Messages.Escort.Hail_2_Response, 5, function()
            self._isChannel_Comms = true
        end),
        self:Call(self.TTS_Escort_Flight, self.Messages.Escort.Hail_2_AdviseFlightChannelShift, 15),
        self:Call(self.TTS_RusNavy_Comms, self.Messages.RussianFrigate.Hail_3, 40),
        self:Call(self.TTS_Escort_Comms, self.Messages.Escort.Hail_3_Response, 40),
        self:Call(self.TTS_RusNavy_Comms, self.Messages.RussianFrigate.Hail_4, 40),
        self:Call(self.TTS_Escort_Comms, self.Messages.Escort.Hail_4_Response, 40)
    )
end

function SilentGuard:EnableRussianHelicopter()
    self._menuStartRussianHelicopter = self._menu:AddCommand("Start Russian Helicopter", function() self:StartRussianHelicopter() end)
end

function SilentGuard:StartRussianHelicopter()
    Debug("SilentGuard:StartRussianHelicopter")
    if self.Phase == Phases.HelicopterDeployed then return end
    self.Phase = Phases.HelicopterDeployed
    self._menuStartRussianHelicopter:Remove(false)
    self.Groups.RED.HelicopterStatic:Destroy()
    self.Groups.RED.Helicopter:Activate()
    self._russianHelicopter = self.Groups.RED.Helicopter:GetUnit(1)
    DCAF.delay(function()
        self:_setRussianHelicopterBehavior(self._russianHelicopter)
    end, 1)
    if self._isFlightArrived then
        self:SendDelayed(Minutes(1), self.TTS_Escort_Flight, self.Messages.Escort.RussianHelicopterStartingUp) -- escort advices players helicopter is getting deployed
    end
    self:_redNavyFeintAttack(Minutes(2), 2)
    self:WhenIn2DRange(NauticalMiles(2), self.Groups.BLU.ContainerShip, self._russianHelicopter, function()
        local callHelicopterEnRoute
        if self._isFlightArrived and not self._isHeliCopterSoFInitiated then
            callHelicopterEnRoute = self:Call(self.TTS_Escort_Flight, self.Messages.Escort.RussianHelicopterEnRoute_1, 5)
        end
        self:SrsCalls(
            self:Call(self.TTS_Escort_Comms, self.Messages.Escort.RussianHelicopterDeployed, 15),
            callHelicopterEnRoute
        )
    end)
end

function SilentGuard:_setRussianHelicopterBehavior(helicopter)
    Debug("SilentGuard:_setRussianHelicopterBehavior")
    local coordHelicopter = helicopter:GetCoordinate()
    if not coordHelicopter then return Error("SilentGuard:_setRussianHelicopterBehavior :: cannot get coordinates for RUS helicopter :: WTF") end
    local ship = self.Groups.BLU.ContainerShip:GetUnit(1)

    local function getShipCoordinates(offsetLongitudinal)
        if not ship then return Error("SilentGuard:_setRussianHelicopterBehavior :: no ship :: WTF") end
        local coordShip = ship:GetCoordinate()
        if not coordShip then return Error("SilentGuard:_setRussianHelicopterBehavior :: cannot get coordinates for UN container ship") end
        if not isNumber(offsetLongitudinal) then return coordShip end
        local hdgShip = ship:GetHeading()
        return coordShip:Translate(offsetLongitudinal, hdgShip)
    end

    local coordShip = getShipCoordinates(NauticalMiles(2.2))


    if not coordShip then return end
    local coordDest = getShipCoordinates(NauticalMiles(20))

    local route = {
        coordHelicopter:WaypointAirTakeOffParking("RADIO"),
        coordShip:WaypointAirTurningPoint("RADIO", 80),
        coordDest:WaypointAirTurningPoint("RADIO", 80),
    }
    setGroupRoute(helicopter, route)

    -- fly to position aft of container ship superstructure, then hover
    local schedulerID
    local function stopScheduler()
        Debug("SilentGuard:_setRussianHelicopterBehavior :: stops scheduler")
        pcall(function() DCAF.stopScheduler(schedulerID) end)
    end


    local interval = 1
    local minDistance = NauticalMiles(999)
    -- local isReactingToSOF = false

    DCAF.ShowOfForce.React(self.Groups.RED.Helicopter, function(sof, event)
        if self._debug then MessageTo(nil, event:DebugText(), 20) end
        self:OnRussianHelicopterReactToShowOfForce(sof, event)
        if self:IsEnded() then stopScheduler() end
    end, DCAF.ShowOfForceOptions:New():InitBuzz(200))

    schedulerID = DCAF.startScheduler(function()

        if self._russianHelicopterHoverTime then
            -- descend slowly
            self._russianHelicopterHoverTime = self._russianHelicopterHoverTime + interval
-- Debug("nisse - RUS helo hover :: time: " .. self._russianHelicopterHoverTime)
            if self._russianHelicopterBoardingTime then
                self._russianHelicopterBoardingTime = self._russianHelicopterBoardingTime+interval
                if self._russianHelicopterBoardingTime > Minutes(4) then
                    stopScheduler()
                    self:OnRussianHelicopterCompletesBoarding()
                end
            elseif self._russianHelicopterHoverTime > 30 then
                self._russianHelicopterBoardingTime = 1
                self:OnRussianHelicopterAttemptsBoarding()
            end
            local altitude = helicopter:GetAltitude()
-- Debug("nisse - RUS helo hover :: altitude: " .. altitude)
            helicopter:SetAltitude(altitude - .5)
            return
        end

        local coordShip = getShipCoordinates(-30)
        local coordHelicopter = helicopter:GetCoordinate()
        if not coordHelicopter or not coordShip then return stopScheduler() end
        local distance = coordShip:Get2DDistance(coordHelicopter)
-- Debug("nisse - RUS helo hover :: distance: " .. distance)

        if distance < minDistance then
            minDistance = distance
        end
        if distance < 100 and distance > minDistance then
            -- helicopter has passed shortest distance; match ship's speed...
            self._russianHelicopterHoverTime = 1
            self:OnRussianHelicopterEntersHover()
            local speedShip = ship:GetVelocityKMH()
            local coordWP1 = getShipCoordinates(200)
            local wp1 = coordWP1:WaypointAirFlyOverPoint("RADIO", speedShip)
            wp1.alt = 10
            local coordWP2 = coordShip:Translate(NauticalMiles(2), ship:GetHeading())
            local wp2 = coordWP2:WaypointAirTurningPoint("RADIO", speedShip)
if self._debug then
    coordWP1:CircleToAll(30)
    coordWP2:CircleToAll(30)
end
            wp2.alt = 10
            local route = {
                coordHelicopter:WaypointAirTurningPoint("RADIO"),
                wp1,
                wp2
            }
            setGroupRoute(helicopter, route)
-- Debug("nisse - RUS helo hover :: hovering... :: speed: " .. UTILS.KmphToKnots(speedShip).." kt")
        end

    end, interval, Minutes(3))

    SilentGuard._menuHelicopterRTB = SilentGuard._menu:AddCommand("RUS helo RTB", function()
        stopScheduler()
        self:RussianHelicopterRTB()
    end)
end

function SilentGuard:Debug()
    Debug("SilentGuard:Debug")
    self._debug = true
end

function SilentGuard:OnRussianHelicopterEntersHover()
    Debug("SilentGuard:OnRussianHelicopterEntersHover")
    if self._debug then
        MessageTo(nil, "RUS helo enters hover...", 40)
    end
end

function SilentGuard:OnRussianHelicopterAttemptsBoarding()
    Debug("SilentGuard:OnRussianHelicopterAttemptsBoarding")
    if self._debug then
        MessageTo(nil, "RUS helo attempts boarding...", 40)
    end
    self:Send(self.TTS_Escort_Flight, self.Messages.Escort.RussianHelicopterAttemptsBoarding)
end

function SilentGuard:OnRussianHelicopterCompletesBoarding()
    Debug("SilentGuard:OnRussianHelicopterCompletesBoarding")
    if self._debug then
        MessageTo(nil, "RUS helo completes boarding...", 40)
    end
    self:RussianNavyWins(Minutes(1.5))
    self:RussianHelicopterRTB()
end

function SilentGuard:OnRussianHelicopterReactToShowOfForce(sof, event)
    Debug("SilentGuard:OnRussianHelicopterReactToShowOfForce")
    self._isHeliCopterSoFInitiated = true
    if sof.Severity >= 60 then
        self._hasWeaponBeenDeployed = self._hasWeaponBeenDeployed or event:IsWeaponImpact()
        self:RussianNavyLoses()
        self:RussianHelicopterRTB()
        return
    end
    if sof.BuzzCount == 1 then
        self:SendDelayed(25, self.TTS_Escort_Flight, self.Messages.Escort.RussianHelicopterEnRoute_2)
    end
end

function SilentGuard:RussianHelicopterRTB()
    Debug("SilentGuard:RussianHelicopterRTB")
    SilentGuard._menuHelicopterRTB:Remove(false)
    local helicopter = self._russianHelicopter
    local coordHelicopter = helicopter:GetCoordinate()
    if not coordHelicopter then return Error("SilentGuard:RussianHelicopterRTB :: cannot get coordinates for helicopter :: WTF") end
    local russianFrigate = self._russianFrigate
    local airbase = AIRBASE:FindByName(russianFrigate.UnitName)
    local coordAirbase = russianFrigate:GetCoordinate()
    if not coordAirbase then
        Debug("SilentGuard:RussianHelicopterRTB :: cannot get coordinates for RUS frigate :: switches to Sochi")
        airbase = AIRBASE:FindByName(AIRBASE.Caucasus.Sochi_Adler)
        coordAirbase = airbase:GetCoordinate()
    end
    local route = {
        coordHelicopter:WaypointAirTurningPoint("RADIO", 80),
        coordAirbase:WaypointAirTurningPoint("RADIO", 80)
    }
    setGroupRoute(helicopter, route)
    -- local wp = route[#route]
    -- WaypointCallback(wp, function()
    --     coordAirbase = russianFrigate:GetCoordinate()
    --     local route = {
    --         coordHelicopter:WaypointAirTurningPoint("RADIO", 80),
    --         coordAirbase:WaypointAirLanding(UTILS.KnotsToKmph(50), airbase)
    --     }
    --     setGroupRoute(helicopter, route)
    -- end)
    self:OnRussianHelicopterRTB()
end

function SilentGuard:StopRussianVessels()
    self.Groups.RED.NavyVessels:SetSpeed(0)
end

function SilentGuard:StopAllVessels()
    self.Groups.BLU.ContainerShip:SetSpeed(0)
    self.Groups.BLU.LeedsCastle:SetSpeed(0)
    self:StopRussianVessels()
end

-- function SilentGuard:_getRussianNavyRTBRoute(group, speed, offsetHeading, offsetDistance)
--     local coordStart = group:GetCoordinate()
--     if not coordStart then return end
--     local hdg = group:GetHeading()
--     if offsetDistance then
--         coordStart = coordStart:Translate(offsetDistance, offsetHeading)
--     end
--     local waypoints = {
--         coordStart:WaypointNaval(speed)
--         -- coordStart:Translate(NauticalMiles(6), (hdg + 40) % 360):WaypointNaval(speed)
--     }
--     -- local wp0 = coordStart:WaypointNaval(speed)
--     local arcCoordinates = getArcCoordinates(coordStart, 0, NauticalMiles(7))
--     for _, coord in ipairs(arcCoordinates) do
--         waypoints[#waypoints+1] = coord:WaypointNaval(speed)
--     end
--     waypoints[#waypoints+1] = self._coordRussianNavyRTB:WaypointNaval(speed)
--     -- local wp2 = self._coordRussianNavyRTB:WaypointNaval(speed)
--     return waypoints
-- end

function SilentGuard:OnRussianHelicopterRTB()
    Debug("SilentGuard:OnRussianHelicopterRTB")
end

function SilentGuard:RussianNavyRTB(speed)
    speed = speed or UTILS.KnotsToKmph(25)
    local coordStart = self.Groups.RED.NavyVessels:GetCoordinate()
    if not coordStart then return Error("SilentGuard:RussianNavyRTB :: cannot get Russian navy coordinates") end
    local route = self:_getRussianNavyRTBRoute(coordStart, speed)
    setGroupRoute(self.Groups.RED.NavyVessels, route)
    self:_redNavyShowOfForceEnd()
end

function SilentGuard:RussianNavyWins(delay)
    Debug("SilentGuard:RussianNavyWins")
    if self:IsEnded() then return self end
    DCAF.delay(function()
        self:OnRussianNavyWins()
    end, delay or 0)
end

function SilentGuard:RussianNavyLoses()
    Debug("SilentGuard:RussianNavyLoses")
    if self:IsEnded() then return self end
    self:OnRussianNavyLoses()
end

function SilentGuard:OnRussianNavyWins()
    Debug("SilentGuard:OnRussianNavyWins")
    self:End()
    if self._debug then
        MessageTo(nil, "RUS navy wins story. Is now RTB with UN ships...", 40)
    end
    self:Send(self.TTS_Escort_Flight, self.Messages.Escort.RussiansSuccessfullyBoards)
    self:StopAllVessels()
    -- self:UnShipsFollowRussianNavyRTB()
end

function SilentGuard:OnRussianNavyLoses()
    Debug("SilentGuard:OnRussianNavyLoses")
    self:End()
    if self._debug then
        MessageTo(nil, "RUS navy loses story. Is now RTB at high speed...", 40)
    end
    self:SendDelayed(30, self.TTS_Escort_Flight, self.Messages.Escort.RussiansDepart)
    local msgRusNavy
    if self._hasWeaponBeenDeployed then
        msgRusNavy = self.Messages.RussianFrigate.RussiansWithdrawAfterWeaponImpact
    else
        msgRusNavy = self.Messages.RussianFrigate.RussianHelicopterRTB
    end
    self:SendDelayed(Minutes(1), self.TTS_RusNavy_Comms, msgRusNavy)
    self:StopRussianVessels()
end

function SilentGuard:EnableTTS_EscortFlight(ttsChannel)
    Debug(_name .. ":EnableTTS_EscortFlight :: ttsChannel: " .. Dump(ttsChannel))
    if ttsChannel == false then
        self.TTS_Escort_Flight = nil
    else
        self.TTS_Escort_Flight = ttsChannel or TTS_Escort_Flight
    end
    if self.TTS_Escort_Flight then
        self:EnableSelectFlight(function(callSign, callSignPhonetic, group)  -- requires DCAF.Story.CallSign.lua
Debug("nisse - SilentGuard:EnableTTS_EscortFlight :: callSign: "..callSign.." :: callSignPhonetic: "..callSignPhonetic)
            self.TTS_Escort_Flight:InitFlightVariable(callSignPhonetic)
            self.Flight = { Group = group, CallSign = callSign }
            -- TODO also add custom menus for selected group, to report convoy etc.
        end)
    else
        self:DisableSelectFlight()
    end
end

SilentGuard._menu = GM_Menu:AddMenu(_name)
SilentGuard._menuStart = SilentGuard._menu:AddCommand("Start", function()
    SilentGuard:Start()
end)

local refreshEnableTTS_EscortFlight
local function enableTTS_EscortFlight()
    if SilentGuard._menuEnableTTS_SomeAgent then
        SilentGuard._menuEnableTTS_SomeAgent:Remove(false)
    end
    local text
    if SilentGuard.TTS_Escort_Flight then
        text = "Disable Escort Vessel TTS"
    else
        text = "Enable Escort Vessel TTS"
    end
    SilentGuard._menuEnableTTS_SomeAgent = SilentGuard._menu:AddCommand(text, function()
        if SilentGuard.TTS_Escort_Flight then
            SilentGuard:EnableTTS_EscortFlight(false)
        else
            SilentGuard:EnableTTS_EscortFlight()
        end
        refreshEnableTTS_EscortFlight()
    end)
end
refreshEnableTTS_EscortFlight = enableTTS_EscortFlight
enableTTS_EscortFlight()


Trace("\\\\\\\\\\ SilentGuard.lua was loaded //////////")