--[[
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
                                                                    BLOODY SATURDAY
                                                                    ---------------
Pro-democratic protesters in Repo-Etseri encounter a sudden pro-Russian counter-demonstration from the neighbouring village or Humeni-Natopuri [GH12]. 
The initially peaceful protest quickly turns bloody when sudden gunfire erupts. UN troops are quickly sent to enforce order but local militia starts 
arriving to support the pro-Russian side. Players are called in to monitor and conduct SoF passes. These seem to have initial effect but the violence 
soon breaks out again and UN forces come under sniper fire. Players are finally called in to destroy two sniper positions, allowing the UN forces to 
secure order and retreat without losses.
]]


local _name = "BloodySaturday"

BloodySaturday = DCAF.Story:New(_name)
local story = BloodySaturday

BloodySaturday.Settings = {
    VoiceUnCommander = "",
    VillageProtest = "Repo-Etseri",
    VillageMilitia = "",
    TimeFromStartToShotsFired = Minutes(1),         -- ;;; TODO increase to more realistic/balanced delay once tested ;;;
    AlertSocialMediaSpread = true,                  -- when set Top Dog will advise controllers the chaotic protests, now with fatalities, are spreading on social media
    MinimumTimeBetweenActiveSnipers = Minutes(1),   -- ;;; TODO set to 4 mins ;;;  minimum time before the first sniper opens fire until the second one
    ReconMarkerSniper_Tolerance = 500,              -- max distance from actual location for map marker when players tasked with locating sniper 1
    TimeAfterBombToAttack = Minutes(1)              -- the time after bomb run on road until commander requests a gun-run on TANGO BRAVO position
    -- etc.
}

local snipers = {
    TangoAlpha = _name.." Sniper-1",
    TangoBravo = _name.." Sniper-2",
}

BloodySaturday.Groups = {
    BLU = {
        UN_1 = getGroup(_name.." UN-1"),
        UN_2 = getGroup(_name.." UN-2"),
        SomeAgentGroup = getGroup("someAgent"),
        Police = getGroup(_name.." UN Police"),
        Ambulances = {
            Ambulance_1 = getGroup(_name.." UN Ambulance-1"),
            Ambulance_2 = getGroup(_name.." UN Ambulance-2"),
        },
        Demonstrators_Group = getGroup(_name.." Protesters-Group"),
        Demonstrators = {
            getStatic(_name.." Protesters-1"),
            getStatic(_name.." Protesters-2"),
            getStatic(_name.." Protesters-3"),
            getStatic(_name.." Protesters-4"),
            getStatic(_name.." Protesters-5"),
            getStatic(_name.." Protesters-6"),
            getStatic(_name.." Protesters-7"),
            getStatic(_name.." Protesters-8"),
            getStatic(_name.." Protesters-9"),
            getStatic(_name.." Protesters-10"),
            getStatic(_name.." Protesters-11"),
            getStatic(_name.." Protesters-12"),
            getStatic(_name.." Protesters-13"),
            getStatic(_name.." Protesters-14"),
            getStatic(_name.." Protesters-15"),
            getStatic(_name.." Protesters-16"),
        },
    },
    RED = {
        CounterProtesters_Group = getGroup(_name.." C-Protesters-Group"),
        CounterProtesters = {
            getStatic(_name.." C-Protesters-A-1"),
            getStatic(_name.." C-Protesters-A-2"),
            getStatic(_name.." C-Protesters-A-3"),
            getStatic(_name.." C-Protesters-A-4"),
            getStatic(_name.." C-Protesters-A-5"),
            getStatic(_name.." C-Protesters-A-6"),
            getStatic(_name.." C-Protesters-A-7"),
            getStatic(_name.." C-Protesters-A-8"),
        },
        Technicals = {
            Technicals_1 = getGroup(_name.." MIL Technicals-1"),
            Technicals_2 = getGroup(_name.." MIL Technicals-2"),
        },
        Sniper_1 = getGroup(snipers.TangoAlpha),
        Sniper_2 = getGroup(snipers.TangoBravo),
        CivilianVehicles = getGroup(_name.." MIL Civilian Vehicles")
    }
}



BloodySaturday.Coordinates = {
    HumeniNatopuri = story:GetRefLoc(_name.." UN-1", false),
    CounterProtestersDispersed =
    {
        story:GetRefLoc(_name.." C-Protesters-B-1"),
        story:GetRefLoc(_name.." C-Protesters-B-2"),
        story:GetRefLoc(_name.." C-Protesters-B-3"),
        story:GetRefLoc(_name.." C-Protesters-B-4"),
        story:GetRefLoc(_name.." C-Protesters-B-5"),
        story:GetRefLoc(_name.." C-Protesters-B-6"),
        story:GetRefLoc(_name.." C-Protesters-B-7"),
        story:GetRefLoc(_name.." C-Protesters-B-8"),
    },
    Weapon_SOF_1 = story:GetRefLoc(_name.." RefLoc-Weapon-SOF-1")
}

local cs = {
    unCommander = "Nebula One",
}

local tts_UN_commander = DCAF.TTSChannel:New(cs.unCommander, FREQ.UN_Orion, nil, nil)
                                        :InitVoice(BloodySaturday.Settings.VoiceUnCommander)

BloodySaturday.Messages = {
    CounterProtestForming = "This is [CALLSIGN]. Be advised, the demonstration in "..story.Settings.VillageProtest.. " are underway as of 1300 local. Crowd size estimated at approximately "..
        "500 and growing. Demonstrators appear peaceful at this time. We've received reports of a pro-Russian counter-demonstration forming in "..story.Settings.VillageMilitia..
        ". Counter protestors are marching toward "..story.Settings.VillageProtest.." but no hostilities observed yet. "..
        "The UN has a patrol present, and the commander on site request we maintain situational awareness and be prepared for further updates. [CALLSIGN] out",
    ShotsFired = "This is [CALLSIGN]. Situation in "..story.Settings.VillageProtest.." has deteriorated. Reports indicate shots fired in the demonstration area; "..
        "casualties unconfirmed at this time. The UN Commander on site is "..cs.unCommander..", and needs immediate aerial support to deter further hostilities. "..
        "Requesting you prioritize tasking and assign a flight to "..story.Settings.VillageProtest.." to help de-escalate. Direct engagement is not authorized unless "..
        "explicitly cleared. Be advised, militia activity has been reported in the vicinity of that location. Maintain situational awareness. Advise assigned flight to "..
        "make contact with "..cs.unCommander.." on Orion frequency. "..FREQ.UN_Orion:PhoneticText()..". [CALLSIGN] out",
    FlightArrive = "[FLIGHT], this is [CALLSIGN]. Thank you for showing up. Say when ready for sit-rep!",
    SitRep = "Situation as follow: The protest in Repo-Etseri has turned violent. Counter-protesters originating from Humeni-Natopuri are armed and initiating "..
        "hostilities against civilians and UN personnel. Several gunshots but no injuries. Seems they are mostly shooting in the air, to cause terror. "..
        "Tensions remain very high. We need you to execute show-of-force passes over the counter-protesters' positions to disrupt and disperse their activities. "..
        "I will mark our position with willie-pete. Counter protesters are [DISTANCE] meters to [DIRECTION]. Rules of engagement remain: no direct engagement "..
        "unless fired upon. Advise when ready to proceed. [CALLSIGN] out",
    ShowOfForce_1 = "[FLIGHT]. [CALLSIGN]. You are cleared to proceed with show-of-force passes over the counter-protesters' positions. "..
        "Ensure your passes are low and loud to maximize disruption but maintain safe altitude above small-arms fire range. Stay sharp up there. [CALLSIGN] out.”",
    ShowOfForce_2 = "[FLIGHT], this is [CALLSIGN]. Your initial pass were effective. Counter-protesters are dispersing, but the situation remains unstable. "..
        "We're seeing regrouping efforts, and some individuals appear to be rallying others to re-engage. I need you to conduct another series of show-of-force passes "..
        "to reinforce the deterrent effect. Same parameters as before: low and loud, but be cautious of small arms fire. Be advised, our observers report increased "..
        "militia presence nearby, so stay vigilant. You are cleared to conduct a second show of force. [CALLSIGN] out",
    FirstFatalities = "[FLIGHT], this is [CALLSIGN] with a situation update: We still hear a bit of shooting and one more demonstrator is down to gunfire. "..
        "Two ambulances are on their way to assist the injured. Additional police units are deploying to help stabilize the situation. Maintain overwatch and stand by for "..
        "updates. Please monitor the road leading out of town. We don't want the militia to add more weapons to this situation. [CALLSIGN] out",
    MilitiaReinforcementsInbound = "[FLIGHT], this is [CALLSIGN]. Be advised, militia reinforcements are inbound from the [DIRECTION] along the main road leading into Repo-Etseri. We’re seeing two "..
        "technicals and one unmarked civilian vehicle. Request you focus your sensors on these guys, to monitor their movements. This doesn't look good. "..
        "Stand by for further updates. [CALLSIGN] out.",
    Sniper = {
        {
            Start = "[FLIGHT], this is [CALLSIGN]. Shots fired! Sniper fire reported from the [DIRECTION]. Repeat. We have confirmed sniper fire from the [DIRECTION]! "..
                "Demonstrators have scattered. They're panicking and hiding wherever they can. At least one fatality confirmed. Situation is rapidly deteriorating. "..
                "I need you to try and locate that shooter immediately. Focus your sensors on the [DIRECTION] area and report back as soon as you have eyes on. "..
                "We cannot stabilize the situation with this active threat. [CALLSIGN] out.",
            Request_SOF = "[FLIGHT]. [CALLSIGN]. Sniper location confirmed. Target reference is TANGO ALPHA. Repeat. Reference is TANGO ALPHA. Mark it for now. "..
                "We're still constrained by ROE, so no direct engagement is authorized at this time. For now, I need you to execute a show of force over that position. "..
                "Let them know we mean business and disrupt their activity. You are cleared to proceed. [CALLSIGN] out."
        },
        {
            Start = "[FLIGHT], this is [CALLSIGN]! We have more sniper fire—repeat, more shots fired! This time from the [DIRECTION]! We're pinned down! UN personnel "..
                "and demonstrators are completely exposed, and the crowd is in total chaos! Civilians are running in all directions, we've lost visual control of key areas, "..
                "and I'm getting reports of multiple fatalities. We cannot hold this position under current conditions. Time is critical. lives are at stake! "..
                "I need you to locate that sniper immediately! Acknowledge and report as soon as you have eyes on! [CALLSIGN] out",
            Request_SOF = "[FLIGHT]. [CALLSIGN]. Target confirmed. Sniper position identified! Mark location. Designation is TANGO BRAVO. Repeat. Designated TANGO BRAVO. "..
                "Situation is critical; we've sustained multiple casualties. I want you to escalate by dropping ordnance on the road outside the village, to the [DIRECTION]. "..
                "Make it loud and visible. Send a clear message. Type three in effect. Drop on own discretion. Ingress and egress at own discretion. Precision is key; "..
                "no collateral damage allowed. You are cleared hot!",
        }
    },
    Sniper_RequestAttack = "[FLIGHT], this is [CALLSIGN]. We've exhausted all other options, the emergency personnel cannot reach the injured and killed, and TANGO BRAVO "..
        "remains active. This ends now. Type two in effect. Five-line as follows. "..
        "Target is TANGO BRAVO, active sniper position. "..
        "gd["..snipers.TangoBravo.."]. "..
        "[DISTANCE]. [MARK] "..
        "Egress at own discretion. "..
        "Civilians are danger-close. Use guns. Shoot for effect. "..
        "You have already confirmed target location. Cleared hot! Go get those bastards!",
    TangoBravo_GoodEffect = "[FLIGHT]. [CALLSIGN]. Good effect! Resume overwatch and monitor the area while we assess the situation. Stand by for further instructions.",
    TangoBravo_Down = "[FLIGHT]. [CALLSIGN]. Tango Bravo is confirmed neutralized. Outstanding work, [FLIGHT]. We desperately needed this the breathing room. Thak you! "..
        "Emergency services are moving in to assist the wounded, and we’re regaining control on the ground. Maintain overwatch until further notice. [CALLSIGN] out.",
    BlueWins = "[FLIGHT], this is [CALLSIGN]. Militia forces are retreating and the situation down here is stabilizing. Outstanding effort—your presence and precision "..
        "strikes were decisive in saving lives! Emergency services are fully engaged, and UN forces are consolidating control of the area. Your mission is complete. "..
        "You are cleared to depart. Thank you for your support today, [FLIGHT]. [CALLSIGN] out."
}

do  -- ||||||||||||||||||||||||||||||||||||    Act 1: The Gathering Storm    ||||||||||||||||||||||||||||||||||||
function BloodySaturday:OnStarted()
    self:Activate(self.Groups.BLU.UN_1)
    self:Activate(self.Groups.BLU.UN_2)
    self:Activate(self.Groups.BLU.Demonstrators_Group)
    self:Activate(self.Groups.RED.CivilianVehicles)
    self:Activate(self.Groups.RED.CounterProtesters_Group)
    self:CounterProtestForming()
end

function BloodySaturday:CounterProtestForming()
    if self:IsFunctionDone() then return end
    self:Send(TTS_Top_Dog, self.Messages.CounterProtestForming)
    self:Delay(self.Settings.TimeFromStartToShotsFired, function() self:ShotsFired() end)
end
end -- (Act 1: The Gathering Storm)

do  -- ||||||||||||||||||||||||||||||||||||    Act 2: The First Shot    ||||||||||||||||||||||||||||||||||||
function BloodySaturday:ShotsFired()
    if self:IsFunctionDone() then return end
    self:Send(TTS_Top_Dog, self.Messages.ShotsFired)
end

function BloodySaturday:OnAssignedFlight(flight)
    tts_UN_commander:InitFlightVariable(flight.CallSignPhonetic)
    self:WhenIn2DRange(NauticalMiles(12), self.Coordinates.HumeniNatopuri, flight.Group, function() self:FlightArrive() end)

-- NISSE
if self:IsDebug() then
    self:Start()
    self:Delay(2, function() self:StartMilitiaReinforcements() end)
end
end

function BloodySaturday:FlightArrive()
    if self:IsFunctionDone() then return end
    self:SendSyntheticController(self.Messages.FlightArrive)
    self:AddFlightCommand("Ready for situation report", function(menu)
        menu:Remove()
        self:SitRep()
    end)
end

function BloodySaturday:SitRep()
    if self:IsFunctionDone() then return end
    local counterProtesters = self.Groups.RED.CounterProtesters_Group
    local unPatrol = self.Groups.BLU.UN_1
    local distanceToCounterProtesters = self:Get2DDistance(unPatrol, counterProtesters)
    local direction = self:GetCardinalDirection(unPatrol, counterProtesters)
    local message = self:SubstMessage(self.Messages.SitRep, escapePattern("[DIRECTION]"), direction)
    message = self:SubstMessageDistance(message, distanceToCounterProtesters)
    self:SendSyntheticController(message)
    self:AddFlightCommand("Contact counter-protesters; ready to proceed", function(menu)
        self:ShowOfForce()
        menu:Remove()
    end)
    -- throw white smoke...
    local coordWilliePete = self.Coordinates.HumeniNatopuri:Translate(40, math.random(360))
    coordWilliePete:SmokeWhite()
end

function BloodySaturday:ShowOfForce()
    if self:IsFunctionDone() then return end
    self:SendSyntheticController(self.Messages.ShowOfForce_1)
    local sof = DCAF.ShowOfForce.React(self.Groups.RED.CounterProtesters_Group, function(sof, event)
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        if sof.BuzzCount == 1 then
            self:CounterProtestersDisperse()
            self:SendSyntheticController(self.Messages.ShowOfForce_2, 20)
        else
            -- no point doing more than 2 SOFs...
            self:StartMilitiaReinforcements()
            self:Delay(60, function() self:FirstFatalities() end)
            sof:End()
        end
    end)
    if self:IsDebug() then
        local count = 0
        self:AddDebugCommand("Trigger SOF", function(menu)
            count = count+1
            sof:DebugTriggerBuzz(self.AssignedFlight.Group)
            if count == 2 then menu:Remove(false) end
        end)
    end
end

function BloodySaturday:FirstFatalities()
    if self:IsFunctionDone() then return end
    self:SendSyntheticController(self.Messages.FirstFatalities)
    self:Activate(self.Groups.BLU.Police)
    self:Activate(self.Groups.BLU.Ambulances)
end

function BloodySaturday:CounterProtestersDisperse()
    if self:IsFunctionDone() then return end
    local delay = 3
    local counterProtestersReGathering
    self.CounterProtesters = {}

    local function disperse(static, index)
        local coordNew = self.Coordinates.CounterProtestersDispersed[index]
        local hdg = static:GetHeading()
        local spawnStatic = SPAWNSTATIC:NewFromStatic(static.StaticName)
        static:Destroy()
        spawnStatic:InitCoordinate(coordNew)
        local staticDispersed = spawnStatic:Spawn(hdg)
        self.CounterProtesters[#self.CounterProtesters+1] = staticDispersed
        if index == 8 then
            counterProtestersReGathering = staticDispersed
            -- move the c-protester group (infantry) to the back, for second SOF...
            local coordReGathering = counterProtestersReGathering:GetCoordinate()
            if not coordReGathering then return Error("BloodySaturday:CounterProtestersDisperse :: could not get coordinate for c-protesters re-gathering") end
            self.Groups.RED.CounterProtesters_Group:RouteGroundTo(coordReGathering, 10)
        end
    end

    for i = #self.Groups.RED.CounterProtesters, 1, -1 do
        local static = self.Groups.RED.CounterProtesters[i]
        self:Delay(delay, function() disperse(static, i) end)
        delay = delay + 3
    end
end

end -- (Act 2: The First Shot)

do -- ||||||||||||||||||||||||||||||||||||    Act 3: Reinforcements and Escalation    ||||||||||||||||||||||||||||||||||||
function BloodySaturday:StartMilitiaReinforcements()
    if self:IsFunctionDone() then return end
    self:Activate(self.Groups.RED.Technicals)
    self:Delay(1, function() self.Coordinates.MilitiaOrigin = self.Groups.RED.Technicals.Technicals_2:GetCoordinate() end)
end

function BloodySaturday:MilitiaReinforcementsInbound() -- triggered by 'MIL Technicals-1', waypoint 1
    if self:IsFunctionDone() then return end
    local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, self.Groups.RED.Technicals.Technicals_1)
    local message = DCAF.Story:SubstMessage(self.Messages.MilitiaReinforcementsInbound, escapePattern("[DIRECTION]"), direction)
    self:SendSyntheticController(message)
end

function BloodySaturday:StartSniper(groupName, delay) -- triggered by 'MIL Technicals-1', waypoint 1
    Debug(_name..":StartSniper :: groupName: "..Dump(groupName).." :: delay: "..Dump(delay))
    if not isAssignedString(groupName) then return Error(_name..":StartSniper :: `groupName` must be assigned string, but was: "..Dump(groupName)) end
    if not stringStartsWith(groupName, _name) then groupName = trimSurplusWhitespace(_name.." "..groupName) end
    local sniperNumber = self:_getSniperNumber()
    local now = UTILS.SecondsOfToday()
    if not isNumber(delay) then delay = 0 end
    if sniperNumber == 1 then
        self._sniper2enabledTime = now + self.Settings.MinimumTimeBetweenActiveSnipers
    elseif sniperNumber == 2 then
        if self:IsSyntheticController() and not self._isSniper_1_located then
            function self:OnSniper1Located()
                Debug("nisse - BloodySaturday:OnSniper1Located :: postponing starting sniper 2 until sniper 1 located")
                -- postponing activating sniper 2 until after sniper 1 was located
                self:StartSniper(groupName, delay)
            end
            return
        elseif now + delay < self._sniper2enabledTime then
            local rolex = self._sniper2enabledTime - (now + delay)
            delay = delay + rolex
        end
    end
    local sniperGroup = getGroup(groupName)
    if not sniperGroup then return Error(_name..":StartSniper :: cannot resolve group: "..groupName) end
    self:Activate(sniperGroup, nil, function()
        self:SniperShooting(sniperGroup, sniperNumber)
    end, delay)
end

function BloodySaturday:OnSniper1Located()
    Debug("BloodySaturday:OnSniper1Located :: (empty)")
    -- to be overridden when sniper 2 is started and sniper 1 hasn't been located (with synthetic controller mode)
end

function BloodySaturday:SniperShooting(sniperGroup, sniperNumber)
    if not self:IsSyntheticController() then return end
    Debug(_name..":SniperShooting :: sniperGroup: "..sniperGroup.GroupName.." :: sniperNumber: "..sniperNumber)
    self:DemonstratorsDisperse()
    local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, sniperGroup)
    local messages = self.Messages.Sniper[sniperNumber]
    local message = self:SubstMessage(messages.Start, escapePattern("[DIRECTION]"), direction)
    self:SendSyntheticController(message)
    self:EnableRecon_Sniper(sniperGroup, messages, sniperNumber)
end

function BloodySaturday:_getSniperNumber()
    self._sniperCount = (self._sniperCount or 0) + 1
    return self._sniperCount
end

function BloodySaturday:EnableRecon_Sniper(sniperGroup, messages, sniperNumber)
    if not self.AssignedFlight then return Error(_name..":EnableRecon_Sniper :: no Flight has been assigned") end
    Debug(_name..":EnableRecon_Sniper :: sniperGroup: "..sniperGroup.GroupName.." :: messages: "..DumpPretty(messages))
    self:EnableReconLocationWithMapMarker(sniperGroup, self.Settings.ReconMarkerSniper_Tolerance, function(task, _)
        Debug(_name..":EnableRecon_Sniper :: mark added to map (sniper = "..sniperGroup.GroupName..")")
        self:DebugMessage("EnableRecon_Sniper :: mark added")
        if sniperNumber == 1 then
            self._isSniper_1_located = true
            self:OnSniper1Located()
        end
        self:Request_SOF_Sniper(sniperGroup, messages, sniperNumber)
        task:End()
    end)
end

function BloodySaturday:Request_SOF_Sniper(sniperGroup, messages, sniperNumber)
    Debug(_name..":Request_SOF_Sniper :: sniperGroup: "..sniperGroup.GroupName.." :: messages: "..DumpPretty(messages))
    if not self:IsSyntheticController() then return end
    local message = messages.Request_SOF
    if sniperNumber == 2 then
        local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, self.Coordinates.Weapon_SOF_1)
        message = DCAF.Story:SubstMessage(message, escapePattern("[DIRECTION]"), direction)
    end
    self:SendSyntheticController(message)

    local function sofHandler(sof, event)
        -- buzz or bomb ...
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        sof:End()
        if sniperNumber == 2 and event.Type == DCAF.ShowOfForceEventType.WeaponImpact then
            -- bomb on road; tango alpha stops shooting
            self.Groups.RED.Sniper_1:OptionROEHoldFire()
            self:Delay(self.Settings.TimeAfterBombToAttack, function() self:Sniper_RequestAttack() end)
        end
    end

    local options = DCAF.ShowOfForceOptions:New():InitWeapon(300)
    local sof = DCAF.ShowOfForce.React(sniperGroup, sofHandler, options)
    if self:IsDebug() then
        self:AddDebugCommand("Trigger SOF", function(menu)
            sof:DebugTriggerBuzz(self.AssignedFlight.Group)
            menu:Remove()
        end)

    end
end

function BloodySaturday:DemonstratorsDisperse()
    if self:IsFunctionDone() then return end
    local demonstrators = self.Groups.BLU.Demonstrators
    local delay = 0
    while #demonstrators > 0 do
        local static, index = listRandomItem(demonstrators)
        if static then
            self:Delay(delay, function() static:Destroy() end)
            delay = delay + 6
            table.remove(demonstrators, index)
        end
    end
end
end -- (Act 3: Reinforcements and Escalation)

do -- ||||||||||||||||||||||||||||||||||||    Phase 4: Neutralizing the Threat    ||||||||||||||||||||||||||||||||||||
function BloodySaturday:Sniper_RequestAttack()
    if self:IsFunctionDone() then return end
    local distance = self:Get2DDistance(self.Groups.BLU.UN_1, self.Groups.RED.Sniper_2)
    local message = self:SubstMessage(self.Messages.Sniper_RequestAttack, escapePattern("[DISTANCE]"), distance)
    local coordUN_1 = self.Groups.BLU.UN_1:GetCoordinate()
    if coordUN_1 then
        message = DCAF.Story:SubstMessage(message, escapePattern("[MARK]"), "Marked by willie-pete. ")
        coordUN_1:SmokeWhite()
    end
    self:SendSyntheticController(message)
    local groupFlight = self.AssignedFlight.Group
    local groupSniper = self.Groups.RED.Sniper_2
    local isSniperHit

    if not groupSniper then
        isSniperHit = true
    else
        groupSniper:HandleEvent(EVENTS.Hit, function(_, e)
            isSniperHit = isSniperHit or e.TgtGroup == groupSniper
            if isSniperHit then
                groupSniper:UnHandleEvent(EVENTS.Hit)
                groupSniper:OptionROEHoldFire()
            end
        end)
    end
    groupFlight:HandleEvent(EVENTS.ShootingEnd, function()
        if isSniperHit then
            story:TangoBravoDown()
        else
        end
    end)

end

function BloodySaturday:TangoBravo_GoodEffect()
    if self:IsFunctionDone() then return end
    self:SendDelayed(10, self.Messages.TangoBravo_GoodEffect)
    self:Delay(Minutes(1), function() self:MilitiaRTB() end)
    self:Delay(Minutes(2), function() self:CounterProtestRTB() end)
    self:Delay(Minutes(3), function() self:TangoBravoDown() end)
end

function BloodySaturday:CounterProtestRTB()
    if self:IsFunctionDone() then return end
    local delay = 0
    local protesters = self.CounterProtesters
    while #protesters > 0 do
        local static, index = listRandomItem(protesters)
        if static then
            self:Delay(delay, function()
                table.remove(protesters, index)
                if #protesters == 0 then
                    -- send the buses and cars back...
                    self.Groups.RED.CivilianVehicles:RouteGroundOnRoad(self.Coordinates.MilitiaOrigin, 60)
                end
            end)
            delay = delay + math.random(10, 60)
        end
    end
end

function BloodySaturday:MilitiaRTB()
    if self:IsFunctionDone() then return end
    for _, group in pairs(self.Groups.RED.Technicals) do
        group:RouteGroundOnRoad(self.Coordinates.MilitiaOrigin, 80)
    end
end

function BloodySaturday:TangoBravoDown()
    if self:IsFunctionDone() then return end
    DCAF.Story:Send(self.Messages.TangoBravo_Down)
    self:Delay(Minutes(2), function() self:BlueWins("Militia is RTB - rescuers can treat demonstrators") end)
end
end -- (Phase 4: Neutralizing the Threat)

do  -- ||||||||||||||||||||||||||||||||||||    GM Menus    ||||||||||||||||||||||||||||||||||||

function BloodySaturday:BlueWins(resolution)
    self:End()
    self:DebugMessage(_name.." :: BLU WINS :: "..Dump(resolution), 40)
end

function BloodySaturday:RedWins()
    self:End()
    self:DebugMessage(_name.." :: RED WINS", 40)
end

BloodySaturday:AddStartMenu()
BloodySaturday:EnableSyntheticController(tts_UN_commander, true)
BloodySaturday:EnableAssignFlight()

end

Trace("\\\\\\\\\\ CAU_WinterRoses_StoryTemplate.lua was loaded //////////")
