do -- ||||||||||||||||||    The Freedom of Press   ||||||||||||||||||
--[[  ==== REQUIREMENTS
    - DCAF.Recon
    - DCAF.Convoy
    - CAU_WinterRoses_Frequencies
    - miz should allow user Marks if TTS UN commander is enabled
]]
end

local _name = "FreedomOfPress"
local _displayName = "Freedom of Press"
local _checkPoint = "Garnet"
local cs = {
    unCommander = "Nebula Actual"
}

FreedomOfPress = DCAF.Story:New(_displayName)
if not FreedomOfPress then return Error(_name .. " :: could not create story") end

FreedomOfPress.Settings = {
    CallContactEchoCacheTolerance = 200,
    ReconMarkerConvoyDistanceTolerance = NauticalMiles(1),
    ReconMarkerIronPeakDistanceTolerance = NauticalMiles(4),
    MilitiaConvoySoFSeverityTolerance = 15,      -- TODO (this value is for testing; increase it) once this severity is reached the convoy RTB's
    MilitiaHelicoptersSoFSeverityTolerance = 15, -- TODO (this value is for testing; increase it) once this severity is reached the helicopters RTB's
    IsStrikeInSukhumiComplete = false,           -- (dependency) was a strike in Sukhumi has completed?
    VoiceUnCommander = "en-GB-Studio-B" -- "da-DK-Wavenet-C"
}

if TTS_Top_Dog then TTS_Top_Dog:InitVariable("FOP_UN_COMMANDER", cs.unCommander) end
local tts_UN_commander = DCAF.TTSChannel:New(cs.unCommander, FREQ.UN_Orion, nil, nil):InitVoice(FreedomOfPress.Settings.VoiceUnCommander)

function FreedomOfPress:IsStoryAutomated()
    return self.TTS_Controller and self.AssignedFlight
end

FreedomOfPress.Coordinates = {
    CheckPoint = FreedomOfPress:GetRefLoc(_name.." MIL Checkpoint Vehicles-Tigr", false),
    IronPeak = FreedomOfPress:GetRefLoc(_name .. " RefLoc IronPeak"),
    MilitiaConvoy_2 = FreedomOfPress:GetRefLoc(_name .. " RefLoc Convoy-2"),
    SukhumiAirport = FreedomOfPress:GetRefLoc(_name.." RefLoc Sukhumi Airport"),
    CivilianBusDestination = FreedomOfPress:GetRefLoc(_name.." RefLoc Civilian Bus Destination"),
    CivilianVehiclesDestination = FreedomOfPress:GetRefLoc(_name.." RefLoc CIV Vehicles Destination"),
    UN_CheckPoint_Vega = FreedomOfPress:GetRefLoc(_name.." RefLoc UN Vega")
}


FreedomOfPress.Groups = {
    Militia = {
        CheckPoint = {
            Vehicles = getGroup(_name.." MIL Checkpoint Vehicles"),
            Tigr = getGroup(_name.." MIL Checkpoint Vehicles-Tigr"),
            Troops = getGroup(_name.." MIL Checkpoint Infantry-1"),
            ParkedVan = getGroup(_name.." MIL Parked Van"),
            -- ParkedHelicopter = getGroup(_name.." MIL Parked Helicopter"),
        },
        Convoy = {
            Armor = getGroup(_name.." MIL Convoy Armor"),
            Trucks = getGroup(_name.." MIL Convoy Trucks")
        },
        Helicopters = {
            Helicopter_1 = getGroup(_name.." MIL Hip-1"),
            Helicopter_2 = getGroup(_name.." MIL Hip-2"),
        },
        AirborneTroops = {
            AirborneTroops_1 = getGroup(_name.." MIL Disembarking-1"),
            AirborneTroops_2 = getGroup(_name.." MIL Disembarking-2")
        }
    },
    UN = {
        CheckpointVehicles = getGroup(_name.." UN Vehicles")
    },
    Civilian = {
        Bus = getGroup(_name .. " CIV Bus"),
        StoppedVehicles = getGroup(_name.." CIV Vehicles")
    },
}

if not FreedomOfPress.Groups.Militia.CheckPoint.Vehicles then return Error("WTF?!") end

FreedomOfPress.Statics = {
    Militia = {
        CheckPoint = {
            Camouflage = getStatic(_name.." MIL EchoCache-Camouflage"),
            PortableToilet = getStatic(_name.." MIL EchoCache-Portapot")
        }
    }
}

local ironPeak = _name.." MIL FARP-IronPeak-1"

FreedomOfPress.Airbases = {
    IronPeak = {
        AIRBASE:FindByName(ironPeak),
        AIRBASE:FindByName(_name.." MIL FARP-IronPeak-2"),
    }
}

local freq_unCommander = FREQ.UN_Orion:PhoneticText(3)
FreedomOfPress.Messages = {
    TopDog = {
        Start = "This is [CALLSIGN]. We have a request from a local UN commander, call sign [FOP_UN_COMMANDER], close to checkpoint Garnet. "..
            "The commander reports rising tensions with the checkpoint militia and requests immediate aerial presence to ensure safety and deter "..
            "further escalation. The UN commander is available on frequency " ..freq_unCommander..". "..
            "Repeat. Request a flight to assist local UN commander near checkpoint Garnet. Callsign is [FOP_UN_COMMANDER], on frequency "..
            freq_unCommander..". [CALLSIGN] out",
        RequestRecon_MilitiaBase = "[FOP_UN_COMMANDER]. This is [CALLSIGN]. Good work turning back those militia reinforcements. Your actions seems to have been crucial to that situation. "..
            "However, command needs to know where these reinforcements are coming from. We need to borrow some of those pilots for a quick recon tasking. [FOP_FLIGHT], request you try locate the "..
            "retreating rotaries, and see if you can find their base of operation. Identify any facilities, supply points, or staging areas they're using to support these movements. Do not engage! "..
            "We need intelligence, not fireworks. Stay sharp, and report back with your findings. [CALLSIGN] out.",
        RequestRecon_MilitiaBase_PostOp_Helos = "[FOP_UN_COMMANDER]. This is [CALLSIGN]. Good work handling that situation. Your actions seems to have been crucial to that situation. "..
            "However, command needs to know where these reinforcements are coming from so we need [FOP_FLIGHT] for a quick reconnaissance tasking. [FOP_FLIGHT], request you try locate the "..
            "retreating rotaries, and see if you can find their base of operation. Identify any facilities, supply points, or staging areas they're using to support these movements. Do not engage! "..
            "We need intelligence, not fireworks. Stay sharp, and report back with your findings. [CALLSIGN] out.",
        Acknowledge_Report_IronPeak = "Copy that, [FLIGHT]. We have received your report on the militia base. Excellent work! Your intel is being relayed to command for immediate analysis. "..
            "Your task here is complete. Return to the checkpoint and resume coordination with [FOP_UN_COMMANDER]. TopDog out.",
        Success_IronPeak_Detected = "This is [CALLSIGN] with an operational update. Bravo Zulu to [FOP_FLIGHT] flight for successfully identifying a previously unknown militia base of operations. "..
            "The facility is assessed to be battalion-sized, with significant logistical and staging capabilities. Located at kp["..ironPeak.."], this base appears to be a critical "..
            "node for the militia's operations in the region, supporting reinforcements and supply routes. This discovery provides us with valuable intelligence for future planning and "..
            "greatly enhances our situational awareness. Stand by for further tasking as we integrate this new information into our mission objectives. [CALLSIGN] out.",
    },
    UN_Commander = {
        Start = "[FLIGHT]. This is [CALLSIGN]. We are a UN response team, operating out of Orion. We are currently at check point Garnet to deal with a situation and it's not looking great."..
            "My negotiator is talking to the local militia forces right now. They have stopped a civilian regional bus carrying "..
            "fifteen non-combatants, including two journalists. Three of the passengers urgently need to reach Georgian territory for medical and family emergencies. "..
            "Negotiations are ongoing, but the militia is refusing to release anyone, claiming the journalists are spies. "..
            "We need your flight overhead to monitor the area and ensure there are no other militia forces in the vicinity. Also, look out for possible air defense units, "..
            "and be prepared for low-altitude shows of force to help de-escalate if required. Weapons use is not authorized unless explicitly requested. I'll provide updates "..
            "as the situation evolves. [CALLSIGN] out.",
        RequestRecon_AzureStrand = "[FLIGHT]. This is [CALLSIGN] again. Are you able to scout Azure Strand for us, all the way up to the Sukhumi airport? "..
            "My negotiator thinks the millets here are waiting for reinforcements from the north and we need to know what we're dealing with here. Repeat. "..
            "Please look for possible inbound militia reinforcements on Azure Strand, up to Sukhumi airport, and report back. [CALLSIGN] out",
        AdviceCaution = "[FLIGHT]. This is [CALLSIGN]. Be advised. We have reports from other flights. That NATO strike in Sukhumi earlier really kicked over their Jenga tower. "..
            "The militia seems to be real eager to flip the table now, and might be looking for blood. Recommend you keep your distance from the Abkhazian shore if possible.",
        AdviceEchoCache = "[FLIGHT]. this is [CALLSIGN]. Be advised, the millets have a storage facility [DISTANCE] meters west of the checkpoint, partially concealed under a camo net "..
            "near the forest line. I think they use it for storage, and eating. And shitting, and such. We're designating this location as 'Echo Cache' for reference. At this time, "..
            "it is not an active target. However, if negotiations fail and escalation becomes unavoidable, this site may be considered a valid option for a precision strike to "..
            "demonstrate UN's resolve. For now, just locate it and call contact. When you have it, ensure you can strike fast when requested, but let's hope it doesn't come to that. "..
            "Repeat. Target is storage facility, called Echo Cache, [DISTANCE] meters west of the checkpoint, south of road, near treeline. Call contact. ",
        ReconSuccess_EchoPoint = "Copy that [FLIGHT]. That is your target, should everything else fail. Thanks for advising on the yellow van next to the portable toilet. It should be a no-factor. "..
            "Please we advised the millets also have a parked helicopter just north of the road. An old army Gazelle I'm told. Should we need a strike on Echo Cache, that rotary is "..
            "not to be touched. That is another bargaining chip, codename 'Alpha Rotary' we can use if situations turns critical. Ok, mates, good to have you here. "..
            "Stay sharp up there and stand by for updates. [CALLSIGN] out",
        ConvoyNear = "[FLIGHT]. [CALLSIGN]. My interpreter overheard a millet, saying the reinforcements are just [DISTANCE] kilometers out and should arrive soon. "..
            "See if you can find them closer to our position. "..
            "Apparently, some commander rides in that convoy and he seems to freak these millets out. They probably would prefer if he didn't make it. "..
            "When you see the convoy, you're cleared to perform a show of force. Buzz them good! We really can't afford for these guys "..
            "to get the upper hand right now.",
        ConvoyVeryNear = "[FLIGHT]. [CALLSIGN]. My interpreter just called and said he heard that the militia reinforcements are less than a kilometer out and should be here "..
            "any minute now. Please find them and get them to turn around. You're cleared to perform a show of force. We really can't afford for these guys "..
            "to get the upper hand right now. Buzz them and get them out of here!",
        RequestSoF_MilitiaConvoy = "[FLIGHT]. [CALLSIGN]. Good job finding that militia convoy! If it gets here the situation will almost certainly escalate beyond control. "..
            "We have a father here that needs to get to the hospital in Batumi, in person, to consent to a critical medical procedure for his daughter, and time is running out "..
            "so he's getting desperate. Request you intercept the convoy and turn it around with a show of force. A visible demonstration of NATO's presence might pressure the "..
            "militia to back down and resume talks. Avoid any direct engagement! Our priority remains a peaceful resolution. Good luck, and stand by for updates. [CALLSIGN] out.",
        MilitiaConvoyRTBNearby = "Excellent work, [FLIGHT]. Without reinforcements coming, we might be able to pressure the millets here, and reduce the tension. "..
            "Your timing couldn't have been better. This might give us the leverage we need to salvage the negotiations. Maintain your current position and continue monitoring for any further militia "..
            "movements. I'll keep you updated as the situation progresses. Thank's guys. [CALLSIGN] out",
        MilitiaConvoyRTB = "Outstanding work, [FLIGHT]. Without those reinforcements coming, we might be able to pressure the millets here, and reduce the tension. "..
            "My negotiator think they were afraid of someone in that convoy and he say they sounded almost relieved to hear he's not coming after all. "..
            "Maintain your current position and continue monitoring for any further militia "..
            "movements. I'll keep you updated as the situation progresses. Thank's guys. [CALLSIGN] out",
        RequestSoF_Helicopters = "[FLIGHT]. [CALLSIGN]. Be advised: the militia is escalating. We just learned one or two rotary-wing contacts are inbound, likely carrying reinforcements. "..
            "They might also have picked up that commander these local millets were fearing. We don't know, but we suspect if he arrives none of the civilians here will go home again for a long time, if ever. "..
                "You are authorized to intercept the helicopter. Conduct a low pass show of force and make your presence known, but do not engage unless directly threatened. We can't afford this to spiral further. [CALLSIGN] out",
        Report_MilitiaHelicoptersRTB = "Another solid intervention, [FLIGHT]. The local millets weren't happy to hear you turned their choppers around, so negotiations are still tense, but this "..
            "gave us a chance to regain control of this situation. Stand by for further instructions. [CALLSIGN] out.",
        Request_Strike_EchoCache = "[FLIGHT]. This is [CALLSIGN]. We've reached the end of our patience here. The checkpoint millets are still refusing to release the civilians despite every effort to de-escalate. "..
            "We need to show them we're not bluffing, so it's time they loose their cache and porta-pot. You are cleared hot on 'Echo Cache' target. Type three in effect. "..
            "Ingress from the north. Egress at own discretion. Keep it precise and clean, and do not hit the parked helicopter on the other side of the road. Give em hell! [CALLSIGN] out.",
        MilitiaConvoyReachesCheckPoint_Request_Strike_EchoCache = "[FLIGHT]. This is [CALLSIGN]. It's getting critical! The militia reinforcements just arrived and the commander is a nasty piece of work that "..
            "flatly refuses any further talks with us, and even threatens with violence. They have started pulling people from the bus and are getting ready to pack them into those trucks. "..
            "Let's play our ace now! You are cleared hot on Echo Cache target. Type three in effect. Ingress from the north. Egress at own discretion. Keep it precise and clean, and do not hit "..
            "the parked helicopter on the other side of the road. Give em hell! [CALLSIGN] out.",
        MilitiaHelicoptersReachesCheckPoint_Request_Strike_EchoCache = "[FLIGHT]. This is [CALLSIGN]. It's getting critical! We hear the militia choppers to our west so they are almost here and "..
            "the civilians are being brought out of the bus! If the millets get these people on board those rotaries we fear the worst for them. "..
            "It's time to play nasty! You are cleared hot on Echo Cache target. Ingress from the north. Egress at own discretion. Keep it precise and clean, and do not hit "..
            "the parked helicopter on the other side of the road. Give em hell! [CALLSIGN] out.",
        Outcome_Strike_EchoPoint_ConfirmedHit = "[FLIGHT]. this is [CALLSIGN]. Good show! That blast shook the forest good, and it the millets sound like they "..
            "understand we're not fooling around. Thanks a lot. ",
        Outcome_Strike_EchoPoint_ConfirmedHit_HelicoptersRTB = "Also, it sounds like the helicopters decided it's not safe to stick around. I can hear them rev up again and leave right now.",
        Outcome_Strike_EchoPoint_Success = "[FLIGHT]. [CALLSIGN]. The strike got their attention and when we threatened to take away that parked helicopter they backed down and agreed to "..
            "release the civilians. The non-combatants are now moving toward Georgian territory. Your precision and restraint were critical in achieving this outcome without further escalation. "..
            "Excellent work up there. Your flight have likely saved lives today. Stand by for further instructions as we wrap up operations at the checkpoint. [CALLSIGN] out.",
        Outcome_Strike_EchoPoint_Collateral = "[FLIGHT]. This is [CALLSIGN]. Your strike was effective, and the militia has agreed to release the civilians, and they're now moving "..
            "toward Georgian territory. However, there's been an unexpected consequence. The blast caused some collateral, and the militia is already trying to spin this as an "..
            "attack on non-combatants. Command will handle the fallout, but this may complicate things diplomatically. That said, your actions achieved the primary objective and "..
            "prevented further escalation here at the checkpoint. Stand by for further instructions while we assess the next steps. [CALLSIGN] out.",
        BlueWins = "[FLIGHT]. [CALLSIGN] here. The civilians are safely en route to Georgian territory, thanks to your efforts. We've achieved a critical outcome here today. "..
            "Your assistance here has been invaluable. ",
        BlueWinsJournalistsDetained = "The bad news is the journalists were not on the bus. One of my guys say he saw a Russian Tigr leave [TIME] minutes go, and headed east. "..
            "We suspect the two journalists where in it. If you're able, feel free to look for it and see if you can figure out where they take them. "..
            "Command is analyzing the situation but there's not much we can do at this time so we're heading back to base. For now, you're cleared to depart the area, or go "..
            "jeep-hunting, it's up to you. Again, well done, and safe travels. [CALLSIGN] out.",
        RedWins = "[FLIGHT]. This is [CALLSIGN]. The negotiations have completely broken down here. The militia has refused all attempts to de-escalate and has moved the civilians, "..
            "along with the journalists, further back into Abkhazia. This is a significant setback, and Command will need to reassess our approach moving forward. Despite the outcome, "..
            "your presence here was critical in preventing an immediate escalation. We're heading back to base now and you're cleared to depart. Thank you for your efforts. [CALLSIGN] out."
    }
}

function FreedomOfPress:OnStarted()
    Debug(_name..":OnStarted")
    self:Activate(self.Groups.UN.CheckpointVehicles)
    self:Activate(self.Groups.Militia.CheckPoint)
    self:Activate(self.Groups.Civilian)
    self:Send(TTS_Top_Dog, self.Messages.TopDog.Start)
    self:StartMilitiaConvoy()
end

function FreedomOfPress:OnAssignedFlight(flight)
    Debug(_name..":OnAssignedFlight :: flight: " .. DumpPretty(flight))
    self:WhenIn2DRange(NauticalMiles(8), flight.Group, self.Groups.Militia.CheckPoint.Vehicles, function()
        self:OnFlightArrive()
    end)
    if TTS_Top_Dog then TTS_Top_Dog:InitVariable("FOP_FLIGHT", flight.CallSignPhonetic) end

-- nisse
-- self:RequestRecon_AzureStrand()
-- self:StartMilitiaHelicopters()
-- self:RequestRecon_MilitiaBase()
-- self:Request_Strike_EchoCache()
end

function FreedomOfPress:OnFlightArrive()
    if self:IsFunctionDone() or not self:IsStoryAutomated() or self:IsFunctionDone("RequestRecon_AzureStrand") then return end
    Debug(_name..":OnFlightArrive :: assigned flight: "..DumpPretty(self.AssignedFlight))
    self:Send(self.TTS_Controller, self.Messages.UN_Commander.Start)
    DCAF.delay(function()
        self:AdviceEchoCache()
    end, Minutes(2))
    DCAF.delay(function()
        self:RequestRecon_AzureStrand()
    end, Minutes(5))
end

function FreedomOfPress:AdviceEchoCache()
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    local distance = self:Get2DDistance(self.Coordinates.CheckPoint, self.Groups.Militia.CheckPoint.ParkedVan)
    local distanceText
    if distance then
        distance = UTILS.Round(distance, -2)
        distanceText = PhoneticAlphabet:ConvertNumber(distance)
    else
        distanceText = "a few hundred"
    end
    local message = string.gsub(self.Messages.UN_Commander.AdviceEchoCache, "%[DISTANCE%]", distanceText)
    self:Send(self.TTS_Controller, message)
    self:EnableRecon_EchoCache()
end

function FreedomOfPress:EnableRecon_EchoCache()
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    self._reconTask_echoPoint = self:EnableFlightMarkerRecon(self.Groups.Militia.CheckPoint.ParkedVan, self.Settings.CallContactEchoCacheTolerance, function(task, _)
        Debug(_name..":EnableRecon_EchoCache :: mark added to map")
        self:DebugMessage("EnableRecon_EchoCache :: mark added")
        self:ReconSuccess_EchoPoint()
        task:End()
    end)
end

function FreedomOfPress:ReconSuccess_EchoPoint()
    if self:IsFunctionDone() then return end
    self:SendDelayed(6, self.TTS_Controller, self.Messages.UN_Commander.ReconSuccess_EchoPoint)
    -- we need to ensure recon request for azure strand won't step over...
    self._isTTS_ControllerBlocking = true
    DCAF.delay(function()
        self._isTTS_ControllerBlocking = nil
    end, Minutes(1))
    DCAF.delay(function() self:RequestRecon_AzureStrand() end, Minutes(2))
end

do -- ||||||||||||||||||||||||||||    Militia Convoy    ||||||||||||||||||||||||||||

function FreedomOfPress:StartMilitiaConvoy()
    if self:IsFunctionDone() then return end
    -- if self._menuMilitiaConvoy then self._menuMilitiaConvoy:Remove(false) end
    local severityTolerance = self.Settings.MilitiaConvoySoFSeverityTolerance

    local function sofReact(sof, event)
        self:DebugMessage(event:DebugText(), 10)
        if not self._militiaConvoyOpenFire then
            self._militiaConvoyOpenFire = true
            self:MilitiaConvoyOpenFire()
        end
        Debug(_name..":StartMilitiaConvoy_sofReact :: severityTolerance: "..severityTolerance.." :: event: " .. DumpPretty(event))
        if event.Severity >= severityTolerance then
            sof:End()
            self:MilitiaConvoyRTB()
        end
    end

    local sofOptions = DCAF.ShowOfForceOptions:InitBuzz(200)
    local groups = self:Activate(self.Groups.Militia.Convoy, nil, function(group)
        group._sof = DCAF.ShowOfForce.React(group, sofReact, sofOptions)
    end)
    self._militiaConvoy = DCAF.Convoy:New(groups, "Militia Convoy", 60):OptionROEHoldFire()
end

function FreedomOfPress:MilitiaConvoyOpenFire()
    Debug(_name..":MilitiaConvoyOpenFire")
    self._militiaConvoy:OptionROEOpenFire()
end

--- Requests players scout the Azure Strand" road, looking for possible militia reinforcements south, possibly to reinforce the checkpoint
function FreedomOfPress:RequestRecon_AzureStrand()
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    if self._isTTS_ControllerBlocking then
        DCAF.delay(function()
            self:RequestRecon_AzureStrand()
        end, Minutes(1))
        return
    end
    self:Send(self.TTS_Controller, self.Messages.UN_Commander.RequestRecon_AzureStrand)
    self:EnableRecon_AzureStrand()
    DCAF.delay(function()
        if self:IsFunctionDone("RequestSoF_MilitiaConvoy") or not self.Settings.IsStrikeInSukhumiComplete then return end
        self:Send(self.TTS_Controller, self.Messages.UN_Commander.AdviceCaution)
    end, Minutes(2))
end

--- The militia convoy (traveling along Azure Strand) has reached the check point
function FreedomOfPress:MilitiaConvoyReachesCheckPoint()
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    self._militiaConvoy:Dissolve()
    local trucks = self.Groups.Militia.Convoy.Trucks
    if not trucks then return Error("FreedomOfPress:MilitiaConvoyReachesCheckPoint :: cannot get 2nd convoy group") end
    local coord = self.Coordinates.MilitiaConvoy_2
    trucks:RouteGroundTo(coord)
    DCAF.delay(function()
        self:Request_Strike_EchoCache(self.Messages.UN_Commander.MilitiaConvoyReachesCheckPoint_Request_Strike_EchoCache)
    end, Minutes(1))
    DCAF.delay(function()
        self:MilitiaSendsDetaineesNorth()
    end, Minutes(5))
end

function FreedomOfPress:MilitiaSendsDetaineesNorth()
    if self:IsFunctionDone() or self:IsFunctionDone("Outcome_Strike_EchoPoint") then return end
    self.Groups.Militia.Convoy.Trucks:RouteGroundOnRoad(self.Coordinates.SukhumiAirport, 80)
    self:RedWins()
end

function FreedomOfPress:EnableRecon_AzureStrand()
    if self:IsFunctionDone() or not self.TTS_Controller then return end
    if not self.AssignedFlight then return Error(_name..":EnableRecon_AzureStrand :: no Flight has been assigned") end
    self._reconTask_convoy = self:EnableFlightMarkerRecon(self._militiaConvoy, self.Settings.ReconMarkerConvoyDistanceTolerance, function(task, event)
        Debug("FreedomOfPress:EnableRecon_AzureStrand :: mark added to map")
        self:DebugMessage("EnableRecon_AzureStrand :: mark added")
        self:ReconSuccess_AzureStrand()
        task:End()
    end)
end

function FreedomOfPress:ReconSuccess_AzureStrand()
    self:IsFunctionDone()
    DCAF.delay(function()
        self:RequestSoF_MilitiaConvoy()
    end, 10)
end

function FreedomOfPress:EnableFlightMenu_ReportMilitiaConvoyRTB()
    self:IsFunctionDone()
    self._menuReportConvoyRTB = MENU_GROUP_COMMAND:New(self.AssignedFlight.Group, "Report: Convoy is RTB", nil, function()
        if not self:IsFunctionDone("MilitiaConvoyRTB") then return end
        self:Report_MilitiaConvoyRTB()
        self._menuReportConvoyRTB:Remove()
    end)
    if self:IsDebug() then
        self:DebugMessage("DEBUG menu added", 10)
        self:AddDebugCommand("Militia Convoy RTB", function(menu)
            self:MilitiaConvoyRTB()
            menu:Remove(false)
        end)
    end
end

function FreedomOfPress:RequestSoF_MilitiaConvoy()
    if self:IsFunctionDone() then return end
    self:Send(self.TTS_Controller, self.Messages.UN_Commander.RequestSoF_MilitiaConvoy)
    self:EnableFlightMenu_ReportMilitiaConvoyRTB()
end

function FreedomOfPress:MilitiaConvoyRTB()
    if self:IsFunctionDone() then return end
    self._militiaConvoy:RouteGroundOnRoad(self.Coordinates.IronPeak)
    -- if self._menuConvoyRTB then self._menuConvoyRTB:Remove(false) end
    DCAF.delay(function()
        self:StartMilitiaHelicopters()
    end, Minutes(4))
end

function FreedomOfPress:Report_MilitiaConvoyRTB()
    Debug(_name..":Report_MilitiaConvoyRTB :: .IsMilitiaConvoyRTB: " .. Dump(self:IsFunctionDone("MilitiaConvoyRTB")))
    if not self:IsFunctionDone("MilitiaConvoyRTB") then return end
    local message
    if self:IsFunctionDone("MilitiaConvoyNearby") then
        message = self.Messages.UN_Commander.MilitiaConvoyRTBNearby
    else
        message = self.Messages.UN_Commander.MilitiaConvoyRTB
    end
    self:SendDelayed(25, self.TTS_Controller, message)
end

function FreedomOfPress:MilitiaConvoyNearby()
  --[[
        Cancel background recon tasking and inform the flight the reinforcements are getting close. 
        Request the flight finds it and performs a Show of Force to get it to turn around
    ]]
    if self:IsFunctionDone() then return end
    if self._reconTask_convoy then
        self._reconTask_convoy:End()
    end
    local distance = self:Get2DDistance(self.Coordinates.CheckPoint, self._militiaConvoy)
    if not distance or distance < 500 then return end
    if distance < 1000 then
        self:Send(self.TTS_Controller, self.Messages.UN_Commander.ConvoyVeryNear)
    else
        local distanceKm = UTILS.Round(distance/1000)
        local message = string.gsub(self.Messages.UN_Commander.ConvoyNear, "%[DISTANCE%]", "p["..tostring(distanceKm).."]")
        self:Send(self.TTS_Controller, message)
    end
    self:EnableFlightMenu_ReportMilitiaConvoyRTB()
end

end  -- (Militia Convoy)

do -- ||||||||||||||||||||||||||||    Militia Helicopters    ||||||||||||||||||||||||||||
function FreedomOfPress:StartMilitiaHelicopters()
  --[[
        Militia sends two Mi-8 choppers from the Iron Peak camp, with troops to reinforce the Garnet checkpoint, and assist
        against the local UN force. On success they plan to get the journalists, and a few of the civilians back to the camp
    ]]
    if self:IsFunctionDone() then return end
    self:Activate(self.Groups.Militia.AirborneTroops)
    self:Activate(self.Groups.Militia.Helicopters)
    local severityTolerance = self.Settings.MilitiaHelicoptersSoFSeverityTolerance

    local function sofReact(sof, event)
        self:DebugMessage(event:DebugText(), 10)
        if not self._militiaConvoyOpenFire then
            self._militiaConvoyOpenFire = true
            self:MilitiaConvoyOpenFire()
        end
        Debug(_name..":StartMilitiaConvoy_sofReact :: severityTolerance: "..severityTolerance.." :: event: " .. DumpPretty(event))
        if event.Severity >= severityTolerance then
            sof:End()
            self:MilitiaHelicoptersRTB()
        end
    end

    for _, helicopter in pairs(self.Groups.Militia.Helicopters) do
        DCAF.ShowOfForce.React(helicopter, sofReact)
    end
    DCAF.delay(function()
        self:RequestSoF_Helicopters()
    end, Minutes(3))

    if self:IsDebug() then
        self:DebugMessage("DEBUG menu added")
        self:AddDebugCommand("Militia Helicopters RTB", function(menu)
            self:MilitiaHelicoptersRTB()
            menu:Remove(false)
        end)
    end
end

function FreedomOfPress:RequestSoF_Helicopters()
    if self:IsFunctionDone() or self:IsFunctionDone("MilitiaHelicoptersRTB") or not self:IsStoryAutomated() then return end
    self:Send(self.TTS_Controller, self.Messages.UN_Commander.RequestSoF_Helicopters)
    self:Enable_Report_MilitiaHelicoptersRTB()
end

function FreedomOfPress:Enable_Report_MilitiaHelicoptersRTB()
    if self:IsFunctionDone() then return end
    self._menuReportHelicoptersRTB = MENU_GROUP_COMMAND:New(self.AssignedFlight.Group, "Report: Militia helicopters RTB", nil, function()
        self:Report_MilitiaHelicoptersRTB()
        self._menuReportHelicoptersRTB:Remove()
    end)
end

function FreedomOfPress:Report_MilitiaHelicoptersRTB()
    if self:IsFunctionDone() then return end
    self:SendDelayed(10, self.TTS_Controller, self.Messages.UN_Commander.Report_MilitiaHelicoptersRTB)
    local delayRequestWeaponizedSoF = Minutes(4)
    DCAF.delay(function()
        self:RequestRecon_MilitiaBase()
    end, Minutes(1.5))
    if self:CountAssignedPlayers() < 3 then
        -- allow more time to complete recon tasking if flight is just an element or singleton...
        delayRequestWeaponizedSoF = delayRequestWeaponizedSoF + Minutes(5)
    end
    DCAF.delay(function()
        self:Request_Strike_EchoCache()
    end, delayRequestWeaponizedSoF)
end

function FreedomOfPress:MilitiaHelicoptersRTB()
    if self:IsFunctionDone() then return end
    -- if self._menuHelicoptersRTB then self._menuHelicoptersRTB:Remove(false) end
    local airbases = self.Airbases.IronPeak
    local speed = UTILS.KnotsToKmph(70)
    local i = 1
    for _, helicopter in pairs(self.Groups.Militia.Helicopters) do
        local airbase = airbases[i]
        local coordHelicopter = helicopter:GetCoordinate()
        if coordHelicopter then
            local coordLanding = airbase:GetCoordinate()
            setGroupRoute(helicopter, {
                coordHelicopter:WaypointAirTurningPoint("RADIO", speed),
                coordLanding:WaypointAirLanding(speed, airbase)
            })
        end
    end
    DCAF.delay(function()
        self:MilitiaDetainsJournalists()
    end, Minutes(2))
    self:DebugMessage("RED helicopters RTB")
end

function FreedomOfPress:MilitiaHelicoptersReachesCheckPoint()
    self:DebugMessage("Helicopters reach checkpoint")
    if self:IsFunctionDone() then return end
    self:Request_Strike_EchoCache(self.Messages.UN_Commander.MilitiaHelicoptersReachesCheckPoint_Request_Strike_EchoCache)
end

end -- (Militia Helicopters)

do -- |||||||||||||||||||||||||    UN Commander loses Patience - Requests SoF - Destroy nearby Militia assets    |||||||||||||||||||||||||

function FreedomOfPress:Request_Strike_EchoCache(message)
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    self:Send(self.TTS_Controller, message or self.Messages.UN_Commander.Request_Strike_EchoCache)

    -- monitor destruction of target...
    local eventSink = BASE:New()
    local parkedVan = self.Groups.Militia.CheckPoint.ParkedVan:GetUnit(1).UnitName
    local camouflageNet
    if self.Statics.Militia.CheckPoint.Camouflage then
        camouflageNet = self.Statics.Militia.CheckPoint.Camouflage.StaticName
    end
    local toilet
    if self.Statics.Militia.CheckPoint.PortableToilet then
        toilet = self.Statics.Militia.CheckPoint.PortableToilet.StaticName
    end
    local countSuccess = 0
    local countCollateral = 0

    local function outcome()
        if countSuccess > 1 or countCollateral > 1 then return end
        if self:IsFunctionDone("StartMilitiaHelicopters") and not self:IsFunctionDone("MilitiaHelicoptersRTB") then
            self._isWeaponsNearHelicopters = true
        end
        DCAF.delay(function()
            eventSink:UnHandleEvent(EVENTS.Hit)
            self:Outcome_Strike_EchoPoint(countSuccess, countCollateral)
        end, 2)
    end

    local function isAssignedFlightInitiator(e)
        local assignedUnits = self:GetAssignedUnits()
        if not assignedUnits then return end
        for _, unit in ipairs(assignedUnits) do
            if unit.UnitName == e.IniUnitName then return true end
        end
    end

    eventSink:HandleEvent(EVENTS.Hit, function(_, e)
        if not self._debug and not isAssignedFlightInitiator(e) then return end
        if e.TgtUnitName == parkedVan or e.TgtUnitName == camouflageNet or e.TgtUnitName == toilet then
            countSuccess = countSuccess + 1
        else
            countCollateral = countCollateral + 1
        end
        outcome()
    end)

-- NISSE
    if self:IsDebug() then
    end
-- getGroup("_TEST Viper-1"):Activate() -- speeds up testing 
end

function FreedomOfPress:Outcome_Strike_EchoPoint(countSuccess, countCollateral)
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    Debug(_name..":Outcome_Strike_EchoPoint :: countSuccess: "..countSuccess.." :: countCollateral: "..countCollateral)
    local message = self.Messages.UN_Commander.Outcome_Strike_EchoPoint_ConfirmedHit
    if self._isWeaponsNearHelicopters then
        message = message..self.Messages.UN_Commander.Outcome_Strike_EchoPoint_ConfirmedHit_HelicoptersRTB
    end
    message = message.."Please stay put and stand by for an update. [CALLSIGN] out."
    self:SendDelayed(5, self.TTS_Controller, message)
    if countCollateral == 0 then
        self:SendDelayed(Minutes(3), self.TTS_Controller, self.Messages.UN_Commander.Outcome_Strike_EchoPoint_Success)
    else
        self:SendDelayed(Minutes(3), self.TTS_Controller, self.Messages.UN_Commander.Outcome_Strike_EchoPoint_Collateral)
    end
    if not self._MilitiaHelicoptersRTB then
       self:MilitiaHelicoptersRTB()
    end
    DCAF.delay(function() self:CivilianBusReleased() end, Minutes(2))
    DCAF.delay(function() self:CivilianVehiclesReleased() end, Minutes(3))
    if not self._MilitiaDetainsJournalists then
        -- this should happen when helicopters RTB, but this is to ensure it happens...
        self:MilitiaDetainsJournalists()
    end
    DCAF.delay(function()
        self:BlueWins("Civilians released to safety")
    end, Minutes(5))
end

function FreedomOfPress:MilitiaDetainsJournalists()
    if self:IsFunctionDone() then return end
    local coord = self.Coordinates.SukhumiAirport
    self.Groups.Militia.CheckPoint.Tigr:RouteGroundOnRoad(coord, 70)
    self._timeTigrLeavesCheckpoint = UTILS.SecondsOfToday()
end
end -- (UN Commander loses Patience...)

do -- |||||||||||||||||||||||||    Top Dog Request Recon for Militia Base    |||||||||||||||||||||||||

function FreedomOfPress:RequestRecon_MilitiaBase(postOp)
    --[[
    Requests players go up north to investigate where the helicopter came from (on success they will find the "Iron Peak" militia base)
    needs to happen after
    ]]
    if self:IsFunctionDone() or not TTS_Top_Dog or not self:IsStoryAutomated() then return end
    TTS_Top_Dog:Tune(self.TTS_Controller.Frequency)
    if not postOp then
        self:Send(TTS_Top_Dog, self.Messages.TopDog.RequestRecon_MilitiaBase)
    else
        self:Send(TTS_Top_Dog, self.Messages.TopDog.RequestRecon_MilitiaBase_PostOp_Helos)
    end
    TTS_Top_Dog:Detune()
    self:EnableRecon_IronPeak(postOp)
end

function FreedomOfPress:EnableRecon_IronPeak(postOp)
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    Debug(_name..":EnableRecon_IronPeak")
    if not self.AssignedFlight then return Error(_name..":EnableRecon_IronPeak :: no Flight has been assigned") end
    self:EnableFlightMarkerRecon(self.Airbases.IronPeak[1], self.Settings.ReconMarkerIronPeakDistanceTolerance, function(task, event)
        self:ReconSuccess_IronPeak()
        task:End()
        if postOp then
            self:End()
            self:DebugMessage(_name.." :: BLU WINS")
        end
    end)
end

function FreedomOfPress:ReconSuccess_IronPeak()
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    self:SendDelayed(10, TTS_Top_Dog, self.Messages.TopDog.Acknowledge_Report_IronPeak)
    self:SendDelayed(Minutes(3), TTS_Top_Dog, self.Messages.TopDog.Success_IronPeak_Detected)
end
end -- (Top Dog Request Recon for Militia Base)

function FreedomOfPress:CivilianBusReleased()
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    local coord = self.Coordinates.CivilianBusDestination
    self.Groups.Civilian.Bus:RouteGroundOnRoad(coord, 70)
end

function FreedomOfPress:CivilianVehiclesReleased()
    if self:IsFunctionDone() or not self:IsStoryAutomated() then return end
    local coord = self.Coordinates.CivilianVehiclesDestination
    self.Groups.Civilian.StoppedVehicles:RouteGroundOnRoad(coord, 70)
end

function FreedomOfPress:UNVehiclesRTB()
    if self:IsFunctionDone() then return end
    local coord = self.Coordinates.UN_CheckPoint_Vega
    self.Groups.UN.CheckpointVehicles:RouteGroundOnRoad(coord, 50)
end

function FreedomOfPress:BlueWins(resolution)
    if self:IsFunctionDone() then return end
    Trace(_name .. " :: BLUE WINS: " .. resolution)
    local info = self:IsFunctionDone("MilitiaDetainsJournalists")
    local timeSinceTigrLeft = UTILS.Round((UTILS.SecondsOfToday() - info.Time) / 60)
    local textTime
    if timeSinceTigrLeft < 3 then
        textTime = "a few"
    else
        textTime = PhoneticAlphabet:ConvertNumber(timeSinceTigrLeft-1).." or "..PhoneticAlphabet:ConvertNumber(timeSinceTigrLeft)
    end
    local message = self.Messages.UN_Commander.BlueWins..string.gsub(self.Messages.UN_Commander.BlueWinsJournalistsDetained, "%[TIME%]", textTime)
    self:Send(self.TTS_Controller, message)
    self:UNVehiclesRTB()
    if not self:IsFunctionDone("RequestRecon_MilitiaBase") and self:IsFunctionDone("MilitiaHelicoptersRTB") then
        DCAF.delay(function()
            self:RequestRecon_MilitiaBase(true)
        end, Minutes(2))
        return
    end
    self:End()
    self:DebugMessage(_name.." :: BLU WINS")
end

function FreedomOfPress:RedWins()
    if self:IsFunctionDone() then return end
    Trace(_name .. " :: RED WINS: " .. "Militia manages to send all non-combatants north from checkpoint " .. _checkPoint)
    self:Send(self.TTS_Controller, self.Messages.UN_Commander.RedWins)
    self:UNVehiclesRTB()
    self:End()
    self:DebugMessage(_name.." :: RED WINS", 40)
end

local nisse_options = DumpPrettyOptions:New():IncludeFunctions(true)
Debug("nisse - WTF?! - where is AddStartMenu??? :: DCAF.Story: " .. DumpPretty(DCAF.Story, nisse_options))

FreedomOfPress:AddStartMenu()
FreedomOfPress:EnableSyntheticController(tts_UN_commander, true)
FreedomOfPress:EnableAssignFlight()

Trace([[\\\\\\\\ FreedomOfPress.lua was loaded //////////]])