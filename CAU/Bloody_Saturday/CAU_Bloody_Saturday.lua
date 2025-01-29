--[[
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
                                                                    BLOODY SATURDAY
                                                                    ---------------
Pro-democratic protesters in Repo-Etseri encounter a sudden pro-Russian counter-demonstration from the neighbouring village or Humeni-Natopuri [GH12]. 
The initially peaceful protest quickly turns bloody when sudden gunfire erupts. UN troops are quickly sent to enforce order but local militia starts 
arriving to support the pro-Russian side. Players are called in to monitor and conduct SoF passes. These seem to have initial effect but the violence 
soon breaks out again and UN forces come under small arms fire. Players are finally called in to destroy a fire position, allowing the UN forces to 
secure order and retreat without losses.
]]


local _name = "BloodySaturday"

BloodySaturday = DCAF.Story:New(_name)
local story = BloodySaturday

local names = {
    TangoAlpha = _name.." Shooter-1",
    TangoBravo = _name.." Shooter-2",
    MilitiaArmor = _name.." MIL Armor"
}

BloodySaturday.Settings = {
    VoiceUnCommander = "en-GB-News-L",
    VoiceUnAssistant = "en-GB-News-L",
    VoiceUAV = "en-US-Neural2-E",
    VillageProtest = "Repo-Etseri",
    VillageMilitia = "Humeni-Natopuri",
    TimeFromStartToShotsFired = Minutes(1),         -- ;;; TODO increase to more realistic/balanced delay once tested ;;;
    AlertSocialMediaSpread = true,                  -- when set Top Dog will advise controllers the chaotic protests, now with fatalities, are spreading on social media
    MinimumTimeBetweenActiveShooters = Minutes(1),  -- ;;; TODO set to 4 mins ;;;  minimum time before the first shooter opens fire until the second one
    TimeAfterBombToAttack = Minutes(1),             -- the time after bomb run on road until commander requests a gun-run on TANGO BRAVO position
    ReconMarkerShooter_Tolerance = 150,             -- max distance from actual location for map marker when players tasked with locating shooter 1
    MilitiaArmor = true,                            -- when set, Militia will also send a group of armor to fight off the UN forces
    TimeControllerReactAfterKill = Minutes(2),      -- if/when players kill inbound militia groups (technicals/armor), this is the time before controller reacts
    ShooterDescription = {
        {
            Designation = "TANGO ALPHA",
            Initial = "East side of village. South east of tee junction, one hundred and fifty meters. On the roof of building.",
            Target = "" -- this shooter retreats after proximity bomb, so won't be targeted
        },
        {
            Designation = "TANGO BRAVO",
            Initial = "North side of village. There are three large tanks on north side of a large warehouse. Shooters are positioned on the eastern-most one.",
            Target = "on top of eastern-most tank, behind large warehouse. "
        },
    },
    -- etc.
}

local ptn = {
    Direction = escapePattern("[DIRECTION]"),
    Distance = escapePattern("[DISTANCE]"),
    Ingress = escapePattern("[INGRESS]"),
    Egress = escapePattern("[EGRESS]"),
    Mark = escapePattern("[MARK]"),
    Description = escapePattern("[DESCRIPTION]"),
    Designation = escapePattern("[DESIGNATION]")
}

local cs = {
    unCommander = "Nebula One",
    unAssistant = "Nebula Two",
    UAV = "Shadow Two"
}

BloodySaturday.Groups = {
    BLU = {
        UN_1 = getGroup(_name.." UN-1"),
        UN_2 = getGroup(_name.." UN-2"),
        UAV = getGroup(_name.." UAV"),
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
        Shooter_1 = getGroup(names.TangoAlpha),
        Shooter_2 = getGroup(names.TangoBravo),
        Armor = getGroup(_name.." MIL Armor"),
        CivilianVehicles = getGroup(_name.." MIL Civilian Vehicles")
    }
}

BloodySaturday.InboundMilitiaTypes = {
    TechnicalsTruckAndCivilian = "5 x vehicles: 3 technicals, 1 truck, and 1 civilian car",
    ApcAndTruck = "1 APC and 1 transport",
    MbtAndTruck = "1 T-72 and 2 transport",
    TwoApcAndAAA = "2 APC and 1 truck-mounted AAA",
    TechnicalsAndAAA = "4 technicals and 1 truck-mounted AAA",
    ApcAndShilka = "1 MTLB and 1 Shilka"
}

BloodySaturday.InboundMilitiaRoads = {                       -- recon options when players are asked to monitor all roads into the village
    -- there's four technicals, single APC and one truck coming in from the south...
    West = { Desc = "Western road, from the ocean", Group = story.Groups.RED.Technicals, Score = {
        [story.InboundMilitiaTypes.TechnicalsTruckAndCivilian] = 100,
        [story.InboundMilitiaTypes.ApcAndTruck] = 20,
        [story.InboundMilitiaTypes.MbtAndTruck] = 5,
        [story.InboundMilitiaTypes.TwoApcAndAAA] = 5,
        [story.InboundMilitiaTypes.TechnicalsAndAAA] = 20,
        [story.InboundMilitiaTypes.ApcAndShilka] = 5,
    }},
    -- there's a single APC and one truck coming in from the south...
    South = { Desc = "Southern road, from Sashamugio", Group = story.Groups.RED.Armor, Score = {
        [story.InboundMilitiaTypes.TechnicalsTruckAndCivilian] = 5,
        [story.InboundMilitiaTypes.ApcAndTruck] = 100,
        [story.InboundMilitiaTypes.MbtAndTruck] = 40,
        [story.InboundMilitiaTypes.TwoApcAndAAA] = 20,
        [story.InboundMilitiaTypes.TechnicalsAndAAA] = 5,
        [story.InboundMilitiaTypes.ApcAndShilka] = 20,
    }},
    -- there are no inbound militia units from eastern road (just emergency vehicles)...
    East = { Desc = "Eastern road, from Gali", Score = {
        [story.InboundMilitiaTypes.TechnicalsTruckAndCivilian] = 1,
        [story.InboundMilitiaTypes.ApcAndTruck] = 1,
        [story.InboundMilitiaTypes.MbtAndTruck] = 1,
        [story.InboundMilitiaTypes.TwoApcAndAAA] = 1,
        [story.InboundMilitiaTypes.TechnicalsAndAAA] = 1,
        [story.InboundMilitiaTypes.ApcAndShilka] = 1,
    }}
}

BloodySaturday.Flags = {
    UAV_Assigned = _name.." UAV Assigned"
}

BloodySaturday.Coordinates = {
    HumeniNatopuri = story:GetRefLoc(_name.." UN-1", false),
    Gali = story:GetRefLoc(_name.." UN Ambulance-2", false),
    UAV = story:GetRefLoc(_name.." RefLoc-UAV"),
    Ingress = story:GetRefLoc(_name.." RefLoc-Ingress"), -- use to specify ingress for attack on TANGO BRAVO
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

local tts_UN_commander = DCAF.TTSChannel:New(cs.unCommander, FREQ.UN_Orion, nil, nil)
                                        :InitVoice(BloodySaturday.Settings.VoiceUnCommander)
                                        :InitLocation(story.Groups.BLU.UN_1)
local tts_assistant = DCAF.TTSChannel:New(cs.unAssistant, FREQ.UN_Orion_Assistant, nil, nil)
                                        :InitVoice(BloodySaturday.Settings.VoiceUnCommander)
                                        :InitVariable("[COMMANDER]", cs.unCommander)
                                        :InitLocation(story.Groups.BLU.UN_1)
local tts_uav = DCAF.TTSChannel:New(cs.UAV, FREQ.UN_Orion_Assistant, nil, nil)
                                        :InitVoice(BloodySaturday.Settings.VoiceUAV)
                                        :InitVariable("[COMMANDER]", cs.unCommander)
                                        :InitLocation(story.Groups.BLU.UAV)

BloodySaturday.Messages = {
    Top_Dog = {
        CounterProtestForming = "This is [CALLSIGN]. Be advised, the demonstration in "..story.Settings.VillageProtest.. " are underway as of 1300 local. Crowd size estimated at approximately "..
            "500 and growing. Demonstrators appear peaceful at this time. We've received reports of a pro-Russian counter-demonstration forming in "..story.Settings.VillageMilitia..
            ". Counter protestors are marching toward "..story.Settings.VillageProtest.." but no hostilities observed yet. "..
            "The UN has a patrol present, and the commander on site request we maintain situational awareness and be prepared for further updates. [CALLSIGN] out",
        ShotsFired = "This is [CALLSIGN]. The demonstrations in "..story.Settings.VillageProtest.." has deteriorated. Reports indicate shots fired in that area but "..
            "casualties are unconfirmed at this time. The UN Commander on site is "..cs.unCommander..", and needs immediate aerial support to help de-escalate the situation. "..
            "Request you prioritize tasking and assign a flight to "..story.Settings.VillageProtest.." to assist. Be advised, militia activity has been reported "..
            "in the vicinity of that location. Maintain situational awareness. Advise assigned flight to make contact with "..cs.unCommander.." on Orion frequency. "..
            FREQ.UN_Orion:PhoneticText()..". [CALLSIGN] out",
        UAV_Assigned = "[FLIGHT], this is [CALLSIGN]. Be advised we have re-assigned a UAV - callSign "..cs.UAV.." - to help monitor the situation at "..story.Settings.VillageProtest..
            ". "..cs.UAV.." will remain feet wet and it will be operating just under cloud base, [DIRECTION] of the area. Ensure you maintain deconfliction with the UAV. [CALLSIGN] out.",
        UAV_Assigned_Assistant = "[COMMANDER], this is [CALLSIGN]. Be advised. I'm have been re-assigned to assist. My a UAV is currently en-route to help monitor the situation at "..story.Settings.VillageProtest..
            ". I will remain over the water, and it will be operating just under cloud base, [DIRECTION] of the area. Ensure your flight maintain deconfliction with the UAV please. [CALLSIGN] out.",
    },
    FlightArrive = "[FLIGHT], this is [CALLSIGN]. Thank you for showing up. Say when ready for situation report!",
    SitRep = "Situation as follow: The protest in "..story.Settings.VillageProtest.." has turned violent. Counter-protesters originating from Humeni-Natopuri are armed "..
        "and initiating hostilities against civilians and UN personnel. Several gunshots so far, but no injuries. Seems they are mostly shouting and firing into the air, "..
        "to cause terror. Tensions is very high. I need you to execute a show-of-force pass over the counter-protesters' positions to make NATO's presence known. "..
        "Hopefully, that will disrupt their intentions, and cool them down. I will mark our position with white smoke. Counter protesters are [DISTANCE] "..
        "meters to [DIRECTION]. Rules of engagement remain: no direct engagement unless fired upon. Advise when visually aquiredready to proceed. [CALLSIGN] out",
    ShowOfForce_1 = "[FLIGHT]. [CALLSIGN]. You are cleared to proceed with show-of-force passes over the counter-protesters. Ensure your passes are as low and loud you "..
        "dare make it, to maximize disruption. Recommend ingress from east to west. Be advised. There are high power cables on western side of village, "..
        "and some counter protesters carry small arms. Be careful. [CALLSIGN] out.",
    ShowOfForce_2 = "[FLIGHT], this is [CALLSIGN]. Your initial pass were effective. Counter-protesters are dispersing, but the situation remains unstable. "..
        "We're seeing regrouping efforts, and some individuals appear to be rallying others to re-engage. I need you to conduct another series of show-of-force passes "..
        "to reinforce the deterrent effect. Same parameters as before: low and loud, but be cautious of small arms fire. Be advised, "..cs.UAV.." report increased "..
        "militia presence nearby, so stay vigilant. You are cleared to conduct a second show of force. [CALLSIGN] out",
    ShowOfForce_2_Assistant = "[COMMANDER]. [CALLSIGN]. That initial show of force pass was effective. Counter-protesters are dispersing, but the situation remains unstable. "..
        "We're seeing regrouping efforts, and some individuals appear to be rallying others to re-engage. Might be a good idea to ask for additional passes "..
        "to reinforce the deterrent effect. There are still a few counter-protesters that are just shooting straight up in the air. Could be dangerous to the jets, "..
        "if they're unlucky. [CALLSIGN] out",

    FirstFatalities = "[FLIGHT], this is [CALLSIGN] with a situation update: We still hear a bit of shooting and one demonstrator was just hit. "..
        "Rescue services are on their way to assist the injured. Additional police units are deploying to help stabilize the situation. Maintain overwatch and stand by for "..
        "updates. Please monitor all roads leading into "..story.Settings.VillageProtest..". We don't want the militia to add more weapons to this situation. [CALLSIGN] out",
    FirstFatalities_Assistant = "[COMMANDER]. [CALLSIGN]. We still hear a bit of shooting and one demonstrator was just hit and rescue services are on their way to assist the injured. "..
        "Additional police units are also deploying to help stabilize the situation. Consider asking [FLIGHT] to monitor all roads leading into "..story.Settings.VillageProtest..
        ". We don't want the militia to add more weapons to this situation.",

    MilitiaTechnicalsInbound = "[FLIGHT], this is [CALLSIGN]. Be advised, militia reinforcements are inbound from the [DIRECTION] along the main road leading into "..story.Settings.VillageProtest..
        ". We're seeing two technicals, a truck and one unmarked civilian vehicle. Request you perform a show of force to try and deter these guys from getting involved. This doesn't look good. "..
        "Should they not comply, your are cleared to use live munitions for proximity impact only. We cannot risk fatalities or collateral damage. You are cleared show of force. "..
        "[CALLSIGN] out.",
    MilitiaTechnicalsInbound_Assistant = "[COMMANDER], this is [CALLSIGN]. Be advised, militia reinforcements are inbound from the [DIRECTION] along the main road leading into "..
        story.Settings.VillageProtest..". We're seeing two technicals, a truck and one unmarked civilian vehicle. This doesn't look good. [CALLSIGN] out.",

    MilitiaArmorInbound = "[FLIGHT], this is [CALLSIGN]. "..cs.UAV.." reports a group of militia units — one APC and one truck — moving to threaten our rear. "..
        "They're approaching along the main road, leading into the village from the [DIRECTION]. I need you to conduct a show of force in their vicinity to disrupt and "..
        "deter their advance. The units are reported kp["..names.MilitiaArmor.."]. Repeat. Look for approaching militia units in "..
        "kp["..names.MilitiaArmor.."], and prevent them from approaching further. If they do not comply, you may escalate and perform an intimidation strike in their vicinity."..
        "Report back when you have more information. [CALLSIGN] out",
    MilitiaArmorInbound_UAV = "[COMMANDER], this is [CALLSIGN]. I see a small group of militia units — one APC and one truck — moving to threaten your rear. "..
        "They're approaching along the main road, leading into the village from the [DIRECTION]. The units are currently in kp["..names.MilitiaArmor.."]. Repeat. "..
        "kp["..names.MilitiaArmor.."] [CALLSIGN] out",

    MilitiaTechnicalsRTB = "[FLIGHT]. [CALLSIGN]. Copy that! Militia forces has turned back. Very good! I'm sure those lads where up to no good!. Much appreciated! [CALLSIGN] out",

    MilitiaArmorRTB = "[FLIGHT]. [CALLSIGN]. Copy that! Militia armored forces has turned back. Outstanding work! We don't have the personnel or weapons here to withstand "..
        "handle heavy like that. Thank's a lot! [CALLSIGN] out",
    MilitiaArmorRTB_UAV = "[COMMANDER]. [CALLSIGN]. Be advised. Is seems [FLIGHT] did it! The militia armored forces are now retreating. Seems your rear is now secure. [CALLSIGN] out",

    MilitiaArmorRTB_Close = "[FLIGHT], [CALLSIGN]. Confirmed. The armor has turned back. That was a last minute call! We were seconds away from packing up and "..
        "leave this situation to be handled by the local police, and that would have been pretty bad. Wonderful news! [CALLSIGN] out",
    MilitiaArmorRTB_Close_UAV = "[COMMANDER], [CALLSIGN]. Be advised. The militia armor is finally turning back, but that was close! Your rear should now be secure. [CALLSIGN] out",

    MilitiaArmorGettingClose = "[FLIGHT]. [CALLSIGN]. The militia armored group approaching from the [DIRECTION] is getting dangerously close. We cannot fight heavy armor "..
        "but if we disengage from here we fear we might leave a massacre behind. If it gets closer than one mile you are cleared to engage.",
    MilitiaArmorGettingClose_UAV = "[COMMANDER]. [CALLSIGN]. The militia armored group approaching from the [DIRECTION] is getting dangerously close. Estimated distance from "..
        "your location is [DISTANCE]",

    MilitiaArmorCriticallyClose = "[FLIGHT]. [CALLSIGN]. The militia armored group approaching from the [DIRECTION] is within one mile! We're out of options. You are cleared "..
        "to engage the APC and truck by any means necessary. Take them out before they reach the village. Ensure you confirm egress and mission status once the targets are "..
        "neutralized. We're counting on you. [CALLSIGN] out.",
    MilitiaArmorCriticallyClose_UAV = "[COMMANDER]. [CALLSIGN]. Be advised. The militia armored group approaching from the [DIRECTION] is within a mile from your position! "..
        "[CALLSIGN] out.",

    MilitiaTechnicalsDestroyed = "[FLIGHT]. [CALLSIGN]. I have word from "..cs.UAV.." that militia vehicles have been destroyed. I did not authorize lethal force "..
        "and I cannot give evidence to the legality of this action, should there be a trial. [CALLSIGN] out!",

    MilitiaTecnicalsDestroyed_UAV = "[COMMANDER]. This is [CALLSIGN]. Be advised. I see militia vehicles burning to your [DIRECTION]. I don't know if you authorized "..
        "it but those guys aren't going anywhere, ever. Good luck if there's an investigation! [CALLSIGN] out.",

    MilitiaArmorDestroyed = "[FLIGHT]. [CALLSIGN]. I have word from "..cs.UAV.." the armored threat is neutralized. This was very unfortunate, and I'm sure there will be "..
        "an investigation, and possible a trial, but don't worry. The kill was in accordance with our Ar-O-E. Good work, [CALLSIGN] out!",
    MilitiaArmorDestroyed_Unauthorized = "[FLIGHT]. [CALLSIGN]. I have word from "..cs.UAV.." the armored threat is destroyed. I did not authorize lethal force! I'm sure "..
        "there will be an investigation, and likely a trial. I appreciate your protection but I'm afraid I cannot in good conscience defend your actions or have your "..
        "back for this event. [CALLSIGN] out!",

    MilitiaArmorDestroyed_UAV = "[COMMANDER]. This is [CALLSIGN]. Be advised. The militia armored group to your [DIRECTION] has been neutralized. I don't know if you authorized "..
        "it but that was a pretty brutal kill from [FLIGHT]. I hope the investigation will clear you guys. Good luck! [CALLSIGN] out.",

    MilitiaArmorTooClose = "[FLIGHT], this is [CALLSIGN]. The armored militia group from the [DIRECTION] is too close — we cannot hold our position any longer. We are "..
        "now pulling back to prevent loss of UN personnel. Maintain overwatch and cover our withdrawal as best you can, but do not engage unless absolutely necessary. "..
        "We appreciate your work here, but this situation is beyond recovery. [CALLSIGN] out.",
    MilitiaArmorTooClose_UAV = "[COMMANDER]. [CALLSIGN]. Be advised. The militia armor is about to enter your village and you should expect them rolling up you rear"..
        "in a few minutes now. If you wanna get out of there this might be your last chance. [CALLSIGN] out.",

    Shooter = {
        {
            Initial = "[FLIGHT], this is [CALLSIGN]. Shots fired! We have small arms fire coming from the [DIRECTION]. Repeat. We have confirmed small arms fire from the [DIRECTION]! "..
                "Demonstrators have scattered. They're panicking and hiding wherever they can. At least one fatality confirmed. Situation is rapidly deteriorating. "..
                "[DESCRIPTION]. Position designation is [DESIGNATION]. Call contact!",
            Initial_Assistant = "[COMMANDER]. [CALLSIGN]. Shots fired! We have small arms fire coming from the [DIRECTION]. Repeat. We have confirmed small arms fire from the [DIRECTION]! "..
                "Demonstrators are scattering and panicking, hiding wherever they can. At least one fatality confirmed. Situation is rapidly deteriorating. "..
                "Shooter spotted [DESCRIPTION]",
            Request_SOF = "[FLIGHT]. [CALLSIGN]. Shooter location [DESIGNATION] confirmed. Mark it for now. "..
                "We're still constrained by the rules of engagement, so no direct engagement is authorized at this time. For now, I need you to execute a show of force over that position. "..
                "Let them know we mean business and disrupt their activity. You are cleared to proceed. [CALLSIGN] out.",
            Assess_SOF = "[FLIGHT], this is [CALLSIGN]. Your show of force over Tango Alpha silenced him for a while, but the shooter resumed fire once you were off. "..
                "Civilians and UN personnel remain in immediate danger. We can't sustain this under current conditions. I need you to stay on station while I run this up the chain, "..
                "and get clearance for more decisive actions. Stand by for further instructions. [CALLSIGN] out",
            Assess_SOF_Assistant = "[COMMANDER]. [CALLSIGN]. That show of force over Tango Alpha silenced him for a while, but the shooter resumed fire once he was off. "..
                "[CALLSIGN] out",
        },
        {
            Initial = "[FLIGHT], this is [CALLSIGN]! We have more small arms fire. Repeat, more shots fired! This time from the [DIRECTION]! [DESCRIPTION] "..
                "Position is designated is [DESIGNATION]. We're returning fire, trying to suppress, but UN personnel and demonstrators are very exposed. We've lost visual "..
                "control of key areas, and I'm getting reports of multiple fatalities. Call contact [DESIGNATION] and stand by for new target designation.",
            Request_SOF = "[FLIGHT]. [CALLSIGN]. Target confirmed. Shooter position [DESIGNATION] identified! Mark location."..
                "Situation is critical; we've sustained multiple casualties. I want you to escalate by dropping ordnance on the road outside the village, to the [DIRECTION]. "..
                "Make it loud and visible. Send a clear message. Type three in effect. Drop on own discretion. Ingress from [INGRESS]. Egress at own discretion. "..
                "Precision is key; no collateral damage allowed. You are cleared hot!",
            Request_SOF_Assistant = "[COMMANDER]. This is [CALLSIGN]. Situation is getting critical!. We've sustained multiple casualties. Recommend we escalate by requesting "..
                "an intimidation strike, on the road just outside the village, to the [DIRECTION]. If [FLIGHT] can make it loud and smoky, it should send a clear warning "..
                "without risking collateral damage. We need to save lives now. [CALLSIGN] out",
            Assess_SOF = "[FLIGHT], this is [CALLSIGN]. Your strike on the road was effective. The tango alpha position ceased fire and has remained silent. The militia "..
                "that shooter appears to be disengaging for now, and the immediate threat is neutralized. Maintain overwatch while we secure the area and confirm no "..
                "further hostile activity. Stand by for additional updates. [CALLSIGN] out.",
            Assess_SOF_Assistant = "[COMMANDER]. [CALLSIGN]. That intimidation strike was effective. The tango alpha position has ceased fire and seems to be disengaging. "..
                "[CALLSIGN] out.",
            Assess_SOF_TooFarAway = "[FLIGHT]. [CALLSIGN]. Your intimidation strike was too far out. Try dropping closer to the road leading into the village. "..
                "You are clear tro re-attack. [CALLSIGN] out.",
            Assess_SOF_TooFarAway_Assistant = "[COMMANDER]. [CALLSIGN]. That intimidation strike was too far out. They need to be dropping closer to the road leading into "..
                "the village. [CALLSIGN] out."
        }
    },
    Shooter_RequestAttack = "[FLIGHT], this is [CALLSIGN]. Tango bravo has resumed firing and we have now exhausted all other options, the emergency personnel cannot "..
        "reach the injured and killed. This ends now. Type two in effect. Five-line as follows. "..
        "Target is TANGO BRAVO, active shooters. [DESCRIPTION]"..
        "Contact confirmed. "..
        "[DISTANCE]. [MARK] "..
        "[INGRESS]. [EGRESS]. "..
        "Use guns, for effect. "..
        "Be advised. Civilians are danger-close. High power cables on egress. "..
        "Do no read back - you know where these bastard are. Cleared hot!",
    TangoBravo_GoodEffect = "[FLIGHT]. [CALLSIGN]. Good effect! Resume overwatch and monitor the area while we assess the situation. Stand by for assessment.",
    TangoBravo_Down = "[FLIGHT]. [CALLSIGN]. Tango Bravo is confirmed neutralized. Outstanding work, [FLIGHT]. We desperately needed this breathing room. Thank you! "..
        "Emergency services are moving in to assist the wounded, and we're regaining control on the ground. Maintain overwatch until further notice. [CALLSIGN] out.",
    BlueWins = "[FLIGHT], this is [CALLSIGN]. Militia forces are retreating, the counter-protesters have started to depart, and the situation down here is stabilizing. "..
        "Outstanding effort—your presence and precision strikes were decisive in saving lives! Emergency services are fully engaged, and UN forces are consolidating "..
        "control of the area. Your mission is complete and you are cleared to depart. Thank you for your support today, [FLIGHT]. [CALLSIGN] out.",
}

do  -- ||||||||||||||||||||||||||||||||||||    Act 1: The Gathering Storm    ||||||||||||||||||||||||||||||||||||
function BloodySaturday:OnStarted()
    self:Activate(self.Groups.BLU.UN_1)
    self:Activate(self.Groups.BLU.UN_2)
    self:Activate(self.Groups.BLU.Demonstrators_Group)
    self:Activate(self.Groups.RED.CivilianVehicles)
    self:Activate(self.Groups.RED.CounterProtesters_Group)
    self:CounterProtestForming()
    SetFlag(self.Flags.UAV_Assigned) -- the UAV 'Shadow 2' gets re-assigned to help monitor 

-- NISSE
if self:IsDebug() then
    -- self:Debug_WeaponTracking_1()
end
end

function BloodySaturday:Debug_WeaponTracking_1()
    self:StartMilitiaReinforcements()
    local group = self.Groups.RED.Armor
    local sofOptions = DCAF.ShowOfForceOptions:New():InitWeapon(700)
    self:AddShowOfForce(DCAF.ShowOfForce.React(group, function(sof, event)
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        if sof.Severity < 60 and event.Type ~= DCAF.ShowOfForceEventType.WeaponImpact then return end
        sof:End()
        self:MilitiaGroupRTB(group)
        self:Delay(2, function() self:Debug_WeaponTracking_2() end)
    end, sofOptions))
end

function BloodySaturday:Debug_WeaponTracking_2()
    local messages = self.Messages.Shooter[2]
    local options = DCAF.ShowOfForceOptions:New():InitWeapon(700, 2000)
    self:AddShowOfForce(DCAF.ShowOfForce.React(self.Groups.RED.CivilianVehicles, function(sof, event)
        if event.Type ~= DCAF.ShowOfForceEventType.WeaponImpact then return end
        sof:End()
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        if not event.IsInsideRange then
            -- bomb was outside the required range...
            if self:IsSyntheticController() then
                self:SendSyntheticController(messages.Assess_SOF_TooFarAway, 5)
            else
                self:SendAssistant(messages.Assess_SOF_TooFarAway_Assistant, 5)
            end
            return
        end
        -- bomb on road(-ish) - tango alpha stops shooting...
        self.Groups.RED.Shooter_1:OptionROEHoldFire()
        self:SendSyntheticController(messages.Assess_SOF, 25)
        self:Delay(self.Settings.TimeAfterBombToAttack, function() self:Shooter_RequestAttack() end)
    end, options))
end

function BloodySaturday:CounterProtestForming()
    if self:IsFunctionDone() then return end
    self:Send(TTS_Top_Dog, self.Messages.Top_Dog.CounterProtestForming)
    self:Delay(self.Settings.TimeFromStartToShotsFired, function() self:ShotsFired() end)
end
end -- (Act 1: The Gathering Storm)

do  -- ||||||||||||||||||||||||||||||||||||    Act 2: The First Shot    ||||||||||||||||||||||||||||||||||||
function BloodySaturday:ShotsFired()
    if self:IsFunctionDone() then return end
    self:Send(TTS_Top_Dog, self.Messages.Top_Dog.ShotsFired)
end

function BloodySaturday:SendAssistant(message, delay)
    if isNumber(delay) then
        DCAF.Story:SendDelayed(delay, message)
    else
        DCAF.Story:Send(tts_assistant, message)
    end
end

function BloodySaturday:OnAssignedFlight(flight)
    tts_UN_commander:InitFlightVariable(flight.CallSignPhonetic)
    tts_assistant:InitFlightVariable(flight.CallSignPhonetic)
    tts_uav:InitFlightVariable(flight.CallSignPhonetic)
    self:WhenIn2DRange(NauticalMiles(12), self.Coordinates.HumeniNatopuri, flight.Group, function() self:FlightArrive() end)
    self:Delay(30, function()
        TTS_Top_Dog:Tune(FREQ.UN_Orion)
        local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, self.Coordinates.UAV)
        local message = DCAF.Story:SubstMessage(self.Messages.Top_Dog.UAV_Assigned, ptn.Direction, direction)
        self:Send(TTS_Top_Dog, message)
        TTS_Top_Dog:Detune()
        if not self:IsSyntheticController() then
            message = DCAF.Story:SubstMessage(self.Messages.Top_Dog.UAV_Assigned_Assistant, ptn.Direction, direction)
            self:Send(tts_uav, message)
        end
    end)

-- NISSE
-- if self:IsDebug() then
--     self:Start()
--     self:Delay(2, function()
--         self:StartMilitiaReinforcements()
--         self:RequestInterdict("Make that armor go away", self.Groups.RED.Armor, DCAF.ShowOfForceOptions:New():InitWeapon(700))
--         self:Delay(20, self:MilitiaArmorCriticallyClose())
--         -- self:Activate(self.Groups.RED.Shooter_2)
--         -- self:Shooter_RequestAttack()
--         -- self:Request_SOF_Shooter(self.Groups.RED.Shooter_2, self.Messages.Shooter[2], 2)
--         -- self:FirstFatalities()
--     end)
-- end
end

function BloodySaturday:AddShowOfForce(sof)
    -- self._sofList = self._sofList or {} -- NISSE test removing this, to see if this is why a second SOF never seems to detect a weapons drop
    -- if #self._sofList == 2 then
    --     Debug(_name..":AddShowOfForce :: ends ongoing SOF")
    --     local oldestSof = self._sofList[1]
    --     oldestSof:End()
    --     table.remove(self._sofList, 1)
    -- end
    -- table.add(self._sofList, sof)
    return sof
end

function BloodySaturday:FlightArrive()
    if self:IsFunctionDone() or not self:IsSyntheticController() then return end
    self:SendSyntheticController(self.Messages.FlightArrive)
    self:AddFlightCommand("Ready for sit-rep", function(menu)
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
    local message = self:SubstMessage(self.Messages.SitRep, ptn.Direction, direction)
    message = self:SubstMessageDistance(message, distanceToCounterProtesters)
    self:SendSyntheticController(message)
    self:AddFlightCommand("Contact counter-protesters; ready to proceed", function(menu)
        self:ShowOfForce_CounterProtesters()
        menu:Remove()
    end)
    -- throw white smoke...
    local coordWilliePete = self.Coordinates.HumeniNatopuri:Translate(40, math.random(360))
    coordWilliePete:SmokeWhite()
end

function BloodySaturday:ShowOfForce_CounterProtesters()
    if self:IsFunctionDone() then return end
    self:SendSyntheticController(self.Messages.ShowOfForce_1)
    local sof = self:AddShowOfForce(DCAF.ShowOfForce.React(self.Groups.RED.CounterProtesters_Group, function(sof, event)
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        if sof.BuzzCount == 1 and event.Type == DCAF.ShowOfForceEventType.Buzz then
            self:CounterProtestersDisperse()
            if self:IsSyntheticController() then
                self:SendSyntheticController(self.Messages.ShowOfForce_2, 20)
            else
                self:SendAssistant(self.Messages.ShowOfForce_2_Assistant, 20)
            end
        else
            -- no point doing more than 2 SOFs...
            self:StartMilitiaReinforcements()
            self:Delay(20, function() self:FirstFatalities() end)
            sof:End()
        end
    end))
    if self:IsDebug() then
        local count = 0
        self:AddDebugCommand("Trigger SOF", function(menu)
            count = count+1
            sof:DebugTriggerBuzz(self.AssignedFlight.Group)
            if count > 1 then menu:Remove(false) end
        end)
    end
end

function BloodySaturday:FirstFatalities()
    if self:IsFunctionDone() then return end
    if self:IsSyntheticController() then
        self:SendSyntheticController(self.Messages.FirstFatalities)
    else
        self:SendAssistant(self.Messages.FirstFatalities_Assistant)
    end
    self:Activate(self.Groups.BLU.Police)
    self:Activate(self.Groups.BLU.Ambulances)
    self:AddReconReportMenu_InboundMilitia()
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
    self._eventSinkUnitDead = BASE:New()
    self._monitorHitGroups = {}

    local function isMonitoredGroup(group)
        if not group then return end
        return self._monitorHitGroups[group.GroupName]
    end

    local function stopMonitorGroup(group)
        self._monitorHitGroups[group.GroupName] = nil
        self._eventSinkUnitDead:UnHandleEvent(EVENTS.Hit)
    end

    self._eventSinkUnitDead:HandleEvent(EVENTS.Hit, function(_, e)
        Debug(_name..":StartMilitiaReinforcements_Hit :: unit: "..DumpPretty(e.TgtUnitName))
        local group = e.TgtGroup
        if not group and e.TgtUnit and e.GetGroup then group = e.TgtUnit:GetGroup() end
        local unit = e.TgtUnit
        if not unit or not unit.GetLife then return end
        local relLife = unit:GetLife() / unit:GetLife0()
        story:DebugMessage("Unit hit: "..Dump(e.TgtUnitName.." :: relLife: "..UTILS.Round(relLife, 2)))
        if relLife > .6 then return end
        if not isMonitoredGroup(group) then return end
        stopMonitorGroup(group)
        story:MilitiaUnitDead(unit)
    end)

    local function monitorDead(group)
        self._monitorHitGroups[group.GroupName] = group
        return group
    end

    monitorDead(self:Activate(self.Groups.RED.Technicals.Technicals_1))
    monitorDead(self:Activate(self.Groups.RED.Technicals.Technicals_2, nil, nil, Minutes(3)))
    if self.Settings.MilitiaArmor then
        local group = self:Activate(self.Groups.RED.Armor)
        monitorDead(group)
        self:Delay(1, function()
            self.Coordinates.MilitiaArmorOrigin = group:GetCoordinate()
        end)
    end
    self:Delay(1, function() self.Coordinates.MilitiaOrigin = self.Groups.RED.Technicals.Technicals_2:GetCoordinate() end)
end

function BloodySaturday:MilitiaUnitDead(unit)
    self:DebugMessage("Unit dead: "..unit.UnitName)
    local group = unit:GetGroup()
    local message
    local delay = self.Settings.TimeControllerReactAfterKill
    if group == self.Groups.RED.Armor then
        if self:IsSyntheticController() then
            message = group._isKillAuthorized and self.Messages.MilitiaArmorDestroyed or self.Messages.MilitiaArmorDestroyed_Unauthorized
            self:Delay(delay, function() self:SendAssistant(message) end)
        else
            self:Delay(delay, self:Send(tts_uav, self.Messages.MilitiaArmorDestroyed_UAV))
        end
    elseif group == self.Groups.RED.Technicals.Technicals_1 or group == self.Groups.RED.Technicals.Technicals_2 then
        if self:IsSyntheticController() then
            self:Delay(delay, function() self:SendAssistant(self.Messages.MilitiaTechnicalsDestroyed) end)
        else
            local groupUN = self.Groups.BLU.UN_1
            local direction = self:GetCardinalDirection(groupUN, group)
            local message = self:SubstMessage(self.Messages.MilitiaArmorDestroyed_UAV, ptn.Direction, direction)
            self:Delay(delay, function() self:Send(tts_uav, message) end)
        end
    end   
end

function BloodySaturday:MilitiaReinforcementsInbound() -- triggered by 'MIL Technicals-1', waypoint 1
    if self:IsFunctionDone() then return end
    local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, self.Groups.RED.Technicals.Technicals_1)
    if self:IsSyntheticController() then
        local message = self:SubstMessage(self.Messages.MilitiaTechnicalsInbound, ptn.Direction, direction)
        self:SendSyntheticController(message)
    else
        local message = self:SubstMessage(self.Messages.MilitiaTechnicalsInbound_Assistant, ptn.Direction, direction)
        self:SendAssistant(message)
    end
end

function BloodySaturday:TechnicalsArrive()
    -- too late for show of force now...
    for _, group in pairs(self.Groups.RED.Technicals) do
        if group._showOfForce then group._showOfForce:End() end
    end
end

function BloodySaturday:MilitiaArmorInbound() -- triggered by 'MIL Armor', waypoint 1
    if self:IsFunctionDone() then return end
    local groupArmor = self.Groups.RED.Armor
    if not groupArmor then return end
    if groupArmor._isReported or groupArmor._isRTB then return end
    local groupUN = self.Groups.BLU.UN_1
    local groupArmor = self.Groups.RED.Armor
    local direction = self:GetCardinalDirection(groupUN, groupArmor)
    if not self:IsSyntheticController() then
        local message = DCAF.Story:SubstMessage(self.Messages.MilitiaArmorInbound_UAV, ptn.Direction, direction)
        self:Send(tts_uav, message)
        self:RequestInterdict(nil, groupArmor, DCAF.ShowOfForceOptions:New():InitWeapon(700))
        return
    end
    local message = DCAF.Story:SubstMessage(self.Messages.MilitiaArmorInbound, ptn.Direction, direction)
    self:RequestInterdict(message, groupArmor, DCAF.ShowOfForceOptions:New():InitWeapon(700))
end

function BloodySaturday:AddFlightCommand_ArmorRTB()
    if self:IsFunctionDone() then return end
    local groupUN = self.Groups.BLU.UN_1
    local groupArmor = self.Groups.RED.Armor
    if not groupArmor then return end
    self._menuReportArmorRTB = self:AddFlightCommand("Report Militia Armor is RTB", function(menu)
        if groupArmor._isRTB then return end
        groupArmor._isRTB = true
        menu:Remove()
        local distanceFromUN_1 = DCAF.Story:Get2DDistance(groupUN, groupArmor)
        local message = distanceFromUN_1 > NauticalMiles(1.5)
                            and self.Messages.MilitiaArmorRTB
                             or self.Messages.MilitiaArmorRTB_Close
        self:SendSyntheticController(message)
    end)
end

function BloodySaturday:MilitiaArmorGettingClose()
    if self:IsFunctionDone() then return end
    local un1 = self.Groups.BLU.UN_1
    local armor = self.Groups.RED.Armor
    local direction = self:GetCardinalDirection(un1, armor)
    if self:IsSyntheticController() then
        local message = DCAF.Story:SubstMessage(self.Messages.MilitiaArmorGettingClose, ptn.Direction, direction)
        self:SendSyntheticController(message)
        return
    end

    local distance = math.floor((self:Get2DDistance(un1, armor) + 250) / 500) * 500 -- rounds to nearest 500 meters
    local message = self:SubstMessage(self.Messages.MilitiaArmorGettingClose_UAV, ptn.Direction, direction)
    message = self:SubstMessage(message, ptn.Distance, distance.." meters")
    self:Send(tts_uav, message)
end

function BloodySaturday:MilitiaArmorCriticallyClose()
    if self:IsFunctionDone() then return end
    local groupArmor = self.Groups.RED.Armor
    if not groupArmor then return end
    local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, self.Groups.RED.Armor)
    if not self:IsSyntheticController() then
        local message =  DCAF.Story:SubstMessage(self.Messages.MilitiaArmorCriticallyClose_UAV, ptn.Direction, direction)
        self:Send(tts_uav, message)
        return
     end
    groupArmor._isKillAuthorized = true
    local message =  DCAF.Story:SubstMessage(self.Messages.MilitiaArmorCriticallyClose, ptn.Direction, direction)
    self:SendSyntheticController(message)
    if self._menuReportArmorRTB then
        self._menuReportArmorRTB:Remove()
        self._menuReportArmorRTB = nil
    end
end

function BloodySaturday:MilitiaArmorTooClose()
    if self:IsFunctionDone() then return end
    if self:IsSyntheticController() then
        self:SendSyntheticController(self.Messages.MilitiaArmorTooClose)
    else
        self:Send(tts_uav, self.Messages.MilitiaArmorTooClose_UAV)
    end
    self:RedWins("militia successfully surround UN patrol and take control over the village")
end

function BloodySaturday:StartShooter(groupName, delay) -- triggered by 'MIL Technicals-1', waypoint 1
    Debug(_name..":StartShooter :: groupName: "..Dump(groupName).." :: delay: "..Dump(delay))
    if not isAssignedString(groupName) then return Error(_name..":StartShooter :: `groupName` must be assigned string, but was: "..Dump(groupName)) end
    if not stringStartsWith(groupName, _name) then groupName = trimSurplusWhitespace(_name.." "..groupName) end
    local shooterNumber = self:_getShooterNumber()
    local now = UTILS.SecondsOfToday()
    if not isNumber(delay) then delay = 0 end
    if shooterNumber == 1 then
        self._shooter2enabledTime = now + self.Settings.MinimumTimeBetweenActiveShooters
    else
        if self:IsSyntheticController() and not self._isShooter_1_located then
            function self:OnShooter1Located()
                self:StartShooter(groupName, delay)
            end
            return
        elseif now + delay < self._shooter2enabledTime then
            local rolex = self._shooter2enabledTime - (now + delay)
            delay = delay + rolex
        end
    end
    local shooterGroup = getGroup(groupName)
    if not shooterGroup then return Error(_name..":StartShooter :: cannot resolve group: "..groupName) end
    self:Activate(shooterGroup, nil, function()
        self:ShooterShooting(shooterGroup, shooterNumber)
    end, delay)
end

function BloodySaturday:OnShooter1Located()
    Debug("BloodySaturday:OnShooter1Located :: (empty)")
    -- to be overridden when shooter 2 is started and shooter 1 hasn't been located (with synthetic controller mode)
end

function BloodySaturday:ShooterShooting(shooterGroup, shooterNumber)
    Debug(_name..":ShooterShooting :: shooterGroup: "..shooterGroup.GroupName.." :: shooterNumber: "..shooterNumber)
    self:DemonstratorsDisperse()
    local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, shooterGroup)
    if shooterNumber > 1 then
        self.Groups.RED.CounterProtesters_Group:Destroy() -- avoid having UN suppress this guy (also, we no longer need him)
    end
    local messages = self.Messages.Shooter[shooterNumber]

    if not self:IsSyntheticController() then
        local message = self:SubstMessage(messages.Initial_Assistant, ptn.Direction, direction)
        self:SendAssistant(message)
        return
    end

    if shooterNumber > 1 then self.Groups.BLU.UN_2:OptionROEOpenFire() end
    local designation = self:_getShooterTargetDesignation(shooterNumber)
    local message = self:SubstMessage(messages.Initial, ptn.Direction, direction)
    message = self:SubstMessage(message, ptn.Designation, designation)
    local description = self.Settings.ShooterDescription[shooterNumber]
    if description and isAssignedString(description.Initial) then
        message = self:SubstMessage(message, ptn.Description, description.Initial)
    else
        message = self:SubstMessage(message, ptn.Description, "")
    end

    local designation = self:_getShooterTargetDesignation(shooterNumber)
    self:AddFlightCommand_RequestLocation(designation, shooterGroup)

    self:SendSyntheticController(message)
    local textContactShooter = "Contact "..designation.."!"
    self:AddFlightCommand(textContactShooter, function(menu)
        menu:Remove()
        self:Request_SOF_Shooter(shooterGroup, messages, shooterNumber)
        if shooterNumber == 1 then
            self._isShooter_1_located = true
            self:OnShooter1Located()
        end
    end)

end

function BloodySaturday:_getShooterNumber()
    self._shooterCount = (self._shooterCount or 0) + 1
    return math.min(2, self._shooterCount)
end

function BloodySaturday:_getShooterTargetDesignation(shooterNumber)
    local shooterDescription = self.Settings.ShooterDescription[shooterNumber]
    if shooterDescription and isAssignedString(shooterDescription.Designation) then
        return shooterDescription.Designation
    end
    return shooterNumber == 1 and "TANGO ALPHA" or "TANGO BRAVO"
end

function BloodySaturday:Request_SOF_Shooter(shooterGroup, messages, shooterNumber)

    Debug(_name..":Request_SOF_Shooter :: shooterGroup: "..shooterGroup.GroupName.." :: messages: "..DumpPretty(messages).." :: shooterNumber: "..Dump(shooterNumber))
    if not self:IsSyntheticController() then
        self:Execute_SOF_Shooter(shooterGroup, messages, shooterNumber)
        return
    end

    local message = messages.Request_SOF
    local designation = self:_getShooterTargetDesignation(shooterNumber)
    local message = self:SubstMessage(message, ptn.Designation, designation)
    if shooterNumber > 1 then
        local direction = self:GetCardinalDirection(self.Groups.BLU.UN_1, self.Coordinates.Weapon_SOF_1)
        local ingress = self:GetCardinalDirection(self.Coordinates.Weapon_SOF_1, self.Groups.BLU.UN_1)
        message = self:SubstMessage(message, ptn.Direction, direction)
        message = self:SubstMessage(message, ptn.Ingress, ingress)
    end
    self:SendSyntheticController(message)
    self:Execute_SOF_Shooter(shooterGroup, messages, shooterNumber)
end

function BloodySaturday:Execute_SOF_Shooter(shooterGroup, messages, shooterNumber)
    local function sofHandlerBuzz(sof, event)
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        if UTILS.SecondsOfToday() > sof._expires then
            sof:End()
            return
        end
        sof:End()
        -- buzz only...
        if event.Type == DCAF.ShowOfForceEventType.Buzz then
            if self:IsSyntheticController() then
                self:SendSyntheticController(messages.Assess_SOF, 25)
            else
                self:SendAssistant(messages.Assess_SOF_Assistant, 15)
            end
        end
    end

    if shooterNumber > 1 then
        self:RequestDeterrentDropOutsideVillage(messages)
        return
    end

    local sof = self:AddShowOfForce(DCAF.ShowOfForce.React(shooterGroup, sofHandlerBuzz))
    sof._expires = UTILS.SecondsOfToday() + Minutes(4)
    if self:IsDebug() then
        self:AddDebugCommand("Trigger SOF Shooter #"..shooterNumber, function(menu)
            menu:Remove()
            sof:DebugTriggerBuzz(self.AssignedFlight.Group)
        end)
    end
end

function BloodySaturday:RequestDeterrentDropOutsideVillage(messages)
    self:DebugMessage("Deterrent Drop Outside Village...")

    if self:IsFunctionDone() then return end
    -- request proximity weapon (use MIL CIV vehicles as 'target')...
    local options = DCAF.ShowOfForceOptions:New():InitWeapon(700, 2000)
    self:AddShowOfForce(DCAF.ShowOfForce.React(self.Groups.RED.CivilianVehicles, function(sof, event)
        if event.Type ~= DCAF.ShowOfForceEventType.WeaponImpact then return end
        sof:End() 
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        if not event.IsInsideRange then
            -- bomb was outside the required range...
            if self:IsSyntheticController() then
                self:SendSyntheticController(messages.Assess_SOF_TooFarAway, 5)
            else
                self:SendAssistant(messages.Assess_SOF_TooFarAway_Assistant, 5)
            end
            return
        end
        -- bomb on road(-ish) - tango alpha stops shooting...
        self.Groups.RED.Shooter_1:OptionROEHoldFire()
        self:SendSyntheticController(messages.Assess_SOF, 25)
        self:Delay(self.Settings.TimeAfterBombToAttack, function() self:Shooter_RequestAttack() end)
    end, options))
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

function BloodySaturday:MilitiaGroupRTB(group)
    if group == self.Groups.RED.Armor then
        self:MilitiaArmorRTB()
    elseif group == self.Groups.RED.Technicals then
        self:TechnicalsRTB()
    end
end

function BloodySaturday:MilitiaArmorRTB()
    if self:IsFunctionDone() then return end
    local armor = self.Groups.RED.Armor
    if not armor then return end
    armor._isRTB = true
    if not armor then return end -- just keeping lua linter happy
    armor:RouteGroundOnRoad(self.Coordinates.MilitiaArmorOrigin, 20)
    if self:IsSyntheticController() then return end
    local distanceFromUN_1 = DCAF.Story:Get2DDistance(self.Groups.BLU.UN_1, armor)
    local message
    if distanceFromUN_1 < NauticalMiles(1.5) then
        message = self.Messages.MilitiaArmorRTB_UAV
    else
        message = self.Messages.MilitiaArmorRTB_Close_UAV
    end
    self:Send(tts_uav, message)
end

function BloodySaturday:TechnicalsRTB()
    if self:IsFunctionDone() then return end
    Debug("nisse - BloodySaturday:TechnicalsRTB :: self.Groups.RED.Technicals: "..DumpPretty(self.Groups.RED.Technicals)) -- logs indicate there are booleans instead of groups in that list
    for _, group in pairs(self.Groups.RED.Technicals) do
        group:RouteGroundOnRoad(self.Coordinates.MilitiaOrigin, 80)
    end
    -- shooters won't spawn from waypoints now, so we'll need to spawn them delayed...
    DCAF.delay(function()
        self:StartShooter(names.TangoAlpha)
    end, Minutes(5))
    DCAF.delay(function()
        self:StartShooter(names.TangoBravo)
    end, Minutes(10))
end

function BloodySaturday:RequestInterdict(message, group, sofOptions)
    local key = isClass(group, GROUP) and group.GroupName or nil
    if self:IsFunctionDone(key) then return end
    if group then Debug(self.Name..":RequestInterdict :: group: "..group.GroupName)
    else Debug(self.Name..":RequestInterdict (no group)") end
    if isAssignedString(message) then
        self:SendSyntheticController(message)
    end
    if not group then return end -- players have reported something that isn't there; so now they can waste some time on a wild goose chase
    if group ~= self.Group.Armor then return end -- only the armored group will react to SOF'es
    self:AddShowOfForce(DCAF.ShowOfForce.React(group, function(sof, event)
        -- these guys are pretty hard core and will only turn around after three buzzes, or one proximity bomb...
        if self:IsDebug() then
            self:MessageToAssignedFlight(event:DebugText())
        end
        if sof.Severity < 60 and event.Type ~= DCAF.ShowOfForceEventType.WeaponImpact then return end
        sof:End()
        self:MilitiaGroupRTB(group)
    end, sofOptions))
    self:AddFlightCommand_ArmorRTB()
end

function BloodySaturday:UnCommanderReceiveReconReport_InboundMilitia(road, types, score)
    if not self:IsSyntheticController() then return end
    local reaction = {
        Confirm = "Copy that [FLIGHT]. Please confirm we have inbound millets on [ROAD]? That is a very unexpected route for the militia.",
        Interdict = {
            "Copy that [FLIGHT]. Acknowledge inbound vehicles on [ROAD]. [TYPES]. Request you try and conduct show of force pass to deter them. "..
            "You are authorized to escalate if needed. Use of weapons is authorized for intimidation if they do no comply. Do not drop for effect!",
            "Copy that [FLIGHT]. Acknowledge inbound vehicles on [ROAD]. [TYPES]. Can you please conduct show of force pass to deter them? "..
            "If they keep advancing you are authorized to perform a deterrent drop in their vicinity. Do not use lethal force at this time!",
            "Copy that [FLIGHT]. Acknowledge inbound vehicles on [ROAD]. [TYPES]. I need you to try and deter them and ensure they halt their advance. "..
            "You are clear to use show of force passes and if that doesn't work, you are cleared to escalate with an intimidation strike. Just ensure they do "..
            "not take any serious damage. We do not want to start a shooting war in this situation.",
        },
        ConfirmInvalidatedReport = {
            "Copy that [FLIGHT]. Disregarding previous report.",
            "Copy that [FLIGHT]. Thanks for looking anyway.",
            "Copy that [FLIGHT]. Keep looking.",
        }
    }

    local roadPattern = escapePattern("[ROAD]")
    local typesPattern = escapePattern("[TYPES]")

    if not road.Group then
        local message = DCAF.Story:SubstMessage(reaction.Confirm, roadPattern, road.Desc)
        self:SendSyntheticController(message)
        self:AddFlightCommand("Confirm report: "..types, function(menu)
            menu:Remove()
            local message = listRandomItem(reaction.Interdict)
            message = self:SubstMessage(message, roadPattern, road.Desc)
            message = self:SubstMessage(message, typesPattern, types)
            self:RequestInterdict(message)
        end)
        self:AddFlightCommand("Invalidate report: "..types, function(menu)
            menu:Remove()
            local message = listRandomItem(reaction.ConfirmInvalidatedReport)
            self:SendSyntheticController(message)
        end)
    else
        local message = listRandomItem(reaction.Interdict)
        message = self:SubstMessage(message, roadPattern, road.Desc)
        message = self:SubstMessage(message, typesPattern, types)
        self:RequestInterdict(message, road.Group, DCAF.ShowOfForceOptions:New():InitWeapon(700))
    end
end

function BloodySaturday:AddReconReportMenu_InboundMilitia()
    if not self:IsSyntheticController() or self:IsFunctionDone() then return end
    local menu = self:AddFlightMenu("Report inbound militia")

    local function sendReport(menuType, road, types, score)
        local group = road.Group
        if group then group._isReported = true end
        menuType:Remove(true)
        self:UnCommanderReceiveReconReport_InboundMilitia(road, types, score)
    end

    for _, road in pairs(self.InboundMilitiaRoads) do
        local menuRoad = menu:New(road.Desc)
        for types, score in pairs(road.Score) do
            menuRoad:NewCommand(types, function(menu) sendReport(menu, road, types, score) end)
        end
    end
end
end -- (Act 3: Reinforcements and Escalation)

do -- ||||||||||||||||||||||||||||||||||||    Phase 4: Neutralizing the Threat    ||||||||||||||||||||||||||||||||||||
function BloodySaturday:Shooter_RequestAttack()
    if self:IsFunctionDone() then return end
    local distance = math.floor(self:Get2DDistance(self.Groups.BLU.UN_1, self.Groups.RED.Shooter_2))
    local message = self:SubstMessageDistance(self.Messages.Shooter_RequestAttack, distance)
    local shooterDescription = self.Settings.ShooterDescription[2]
    local refLocIngress = self.Coordinates.Ingress
    local groupShooter_2 = self.Groups.RED.Shooter_2
    if not groupShooter_2 then
        message = DCAF.Story:SubstMessage(message, ptn.Ingress, "Ingress and egress at own discretion")
    else
        local ingress = self:GetCardinalDirection(groupShooter_2, refLocIngress)
        message = DCAF.Story:SubstMessage(message, ptn.Ingress, ingress)
        message = DCAF.Story:SubstMessage(message, ptn.Egress, "Egress at own discretion")
    end

    if shooterDescription and isAssignedString(shooterDescription.Target) then
        message = self:SubstMessage(message, ptn.Description, shooterDescription.Target)
    end
    local groupUN_1 = self.Groups.BLU.UN_1
    if groupUN_1 then
        local coordUN_1 = groupUN_1:GetCoordinate()
        if coordUN_1 then
            message = DCAF.Story:SubstMessage(message, ptn.Mark, "Marked by willie-pete. ")
            coordUN_1:SmokeWhite()
        end
    end
    self:SendSyntheticController(message)
    local groupFlight = self.AssignedFlight.Group
    local groupShooter = self.Groups.RED.Shooter_2
    local isShooterHit
    local schedulerID

    if not groupShooter then
        isShooterHit = true
    else
        local function stopMonitorShooterHealth()
            if schedulerID then
                pcall(function() DCAF.stopScheduler(schedulerID) end)
                schedulerID = nil
                groupShooter:UnHandleEvent(EVENTS.Hit)
                groupFlight:UnHandleEvent(EVENTS.ShootingEnd)
            end
        end

        schedulerID = DCAF.startScheduler(function()
            if groupShooter:GetLife()  < groupShooter:GetLife0() then
Debug("nisse - shooter health deteriorated")
                stopMonitorShooterHealth()
                story:TangoBravo_GoodEffect()
            end
        end, 1)
        groupShooter:HandleEvent(EVENTS.Hit, function(_, e)
            isShooterHit = isShooterHit or e.TgtGroup == groupShooter
Debug("nisse - ".._name.." :: HIT event :: isShooterHit: "..Dump(isShooterHit))
            if isShooterHit then
                stopMonitorShooterHealth()
                groupShooter:UnHandleEvent(EVENTS.Hit)
                groupShooter:OptionROEHoldFire()
                story:TangoBravo_GoodEffect()
            end
        end)
        groupFlight:HandleEvent(EVENTS.ShootingEnd, function()
            self:Delay(10, function()
    Debug("nisse - ".._name.." :: ShootingEnd event :: isShooterHit: "..Dump(isShooterHit))
                if isShooterHit then
                    stopMonitorShooterHealth()
                    story:TangoBravo_GoodEffect()
                end
            end)
        end)
    end
end

function BloodySaturday:TangoBravo_GoodEffect(delay)
    if self:IsFunctionDone() then return end
    if not isNumber(delay) then delay = 3 end
    self:Delay(delay, function()
        -- just mopping up now...
        self:SendSyntheticController(self.Messages.TangoBravo_GoodEffect)
        self:Delay(Minutes(1), function() self:TechnicalsRTB() end)
        self:Delay(Minutes(2), function() self:CounterProtestRTB() end)
        self:Delay(Minutes(3), function() self:TangoBravoDown() end)
    end)
end

function BloodySaturday:CounterProtestRTB()
    if self:IsFunctionDone() then return end
    for _, static in pairs(self.CounterProtesters) do
        static:Destroy()
    end
    self.Groups.RED.CivilianVehicles:RouteGroundOnRoad(self.Coordinates.MilitiaOrigin, 60)
end

function BloodySaturday:TangoBravoDown()
    if self:IsFunctionDone() then return end
    self:SendSyntheticController(self.Messages.TangoBravo_Down)
    self:Delay(Minutes(2), function() self:BlueWins("Militia is RTB - rescuers can treat demonstrators") end)
end
end -- (Phase 4: Neutralizing the Threat)

do  -- ||||||||||||||||||||||||||||||||||||    GM Menus    ||||||||||||||||||||||||||||||||||||

function BloodySaturday:BlueWins(resolution)
    self:SendSyntheticController(self.Messages.BlueWins)
    self:End()
    self:DebugMessage(_name.." :: BLU WINS :: "..Dump(resolution), 40)
end

function BloodySaturday:RedWins(resolution)
    self:End()
    self:DebugMessage(_name.." :: RED WINS :: "..Dump(resolution), 40)
end

BloodySaturday:AddStartMenu()
BloodySaturday:EnableSyntheticController(tts_UN_commander, true)
BloodySaturday:EnableAssignFlight()

end

Trace("\\\\\\\\\\ CAU_WinterRoses_StoryTemplate.lua was loaded //////////")
