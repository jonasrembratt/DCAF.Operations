local _name = "Cuckoo"
local _codeword = _name
local _insertionVillage = "Zamzam"
Cuckoo = DCAF.Story:New(_name)
if not Cuckoo then return end

Cuckoo._redLossThreshold = 0.7 -- red looses at 70% losses
Cuckoo._redVictoryTimeout = Minutes(20) -- if RED hasn't succeeded after this time, BLU wins
Cuckoo.Groups = {
    BLU = {
        InfantryZamzam = getGroup(_name .. " BLU INF Zamzam-1"),
        InfantryDam_1 = getGroup(_name .. " BLU INF Dam-1"),
        APC_1 = getGroup(_name .. " BLU APC-1"),
        Shilka = getGroup(_name .. " BLU Shilka"),
        Truck_1 = getGroup(_name .. " BLU Truck-1"),
        JTAC_1 = getGroup(_name .. " BLU JTAC-1"),
        JTAC_2 = getGroup(_name .. " BLU JTAC-2"),
        JTAC_3 = getGroup(_name .. " BLU JTAC RANGER 2"),
    },
    RED = {
        HeloCAS_1 = getGroup(_name .. " SYR Mi24 CAS-1"),
        HeloGhost_1 = getGroup(_name .. " SYR Mi24 CAS-Ghost-1"),
        HeloInsertion_1 = getGroup(_name .. " SYR Mi8 Infil-1"),
        HeloInsertion_2 = getGroup(_name .. " SYR Mi8 Infil-2"),
        HeloInsertion_3 = getGroup(_name .. " SYR Mi8 Infil-3"),
        InfantryDam_1 = getGroup(_name .. " RED INF Dam-1"),
        InfantryDam_2 = getGroup(_name .. " RED INF Dam-2"),
        InfantryZamzam_1 = getGroup(_name .. " RED INF Zamzam-1"),
        SpeedBoats_1 = getGroup(_name .. " RED Fast Boat-1"),
        SpeedBoats_2 = getGroup(_name .. " RED Fast Boat-2"),
        SpeedBoats_3 = getGroup(_name .. " RED Fast Boat-3"),
        SpeedBoatSquad_1 = getGroup(_name .. " RED INF DamAttack-1"),
        SpeedBoatSquad_2 = getGroup(_name .. " RED INF DamAttack-2"),
        SpeedBoatSquad_3 = getGroup(_name .. " RED INF DamAttack-3"),
        SpeedBoatSquad_4 = getGroup(_name .. " RED INF DamAttack-4"),
        MortarTransport = getGroup(_name .. " RED Mortar Transport"),
        Mortar = getGroup(_name .. " RED Mortar"),
        MortarCrew = {
            getGroup(_name .. " RED Mortar Crew-1"),
            getGroup(_name .. " RED Mortar Crew-2"),
            getGroup(_name .. " RED Mortar Crew-3"),
            getGroup(_name .. " RED Mortar Crew-4"),
            getGroup(_name .. " RED Mortar MANPADS"),
        },
        MANPADS_Template = getGroup(_name .. " RED MANPADS_Template")
    },
}

Cuckoo.MSG = {
    BLU_Wins =
        "[CALLSIGN]. We have word from Tabqa dam. The enemy assault on the dam has been successfully defeated. All attackers have been incapacitated or captured. "..
        "Outstanding work everyone! [CALLSIGN] out",

    TopDog = {
        RedChoppersDeparting =
            "[CALLSIGN]. We have report from [CALLSIGN_RECON_2]. Enemy helicopters have departed [RED_AIRBASE] and continued south. Very low level. They might be en route to Raqqa or Tabqa area. [CALLSIGN] out",
        SpeedBoatsSpotted =
            "[CALLSIGN]. We have request from Tabqa dam defenders. They report multiple speed boats heading straight for the dam. "..
            "request anti-ship interdiction. Speed boats are heading east at kp["..Cuckoo.Groups.RED.SpeedBoats_1.GroupName.."]. [CALLSIGN] out",
        SpeedBoatsDisembarked =
            "[CALLSIGN]. Be advised. We have report from the Tabqa dam. The enemy speedboats have landed and disembarked troops north of their position. "..
            "Multiple foot-mobiles are now advancing toward the dam defensive positions. You might want someone to make a few strafing passes if possible. [CALLSIGN] out",
        RedMortarBarrage =
            "[CALLSIGN]. Tabqa dam is taking heavy mortar fire, south of the dam complex, preventing reinforcements and resupplies to reach the defenders. "..
            "Recommend cee-sar tasking to deal with the enemy mortar position, likely around kp["..Cuckoo.Groups.RED.Mortar.GroupName.."]. [CALLSIGN] out",
        BLU_Wins =
            "[CALLSIGN]. We have word from Tabqa dam. The enemy assault on the dam has been successfully defeated. All attackers have been incapacitated or captured. "..
            "Outstanding work everyone! [CALLSIGN] out",
        },
    Recon1 = {
        InsertionVillageAttacked =
            "[CALLSIGN]. Enemy rotary units are conducting rocket attacks on the village of ".._insertionVillage..". Looks like Hind attack helicopters. "..
            "Village of ".._insertionVillage.." is kp["..Cuckoo.Groups.BLU.InfantryZamzam.GroupName.."]. Repeat ".._insertionVillage.." is kp["..Cuckoo.Groups.BLU.InfantryZamzam.GroupName.."]. [CALLSIGN] out",
        InsertionHipsInbound =
            "[CALLSIGN]. We have three additional enemy Hip choppers heading our way, very low level. Below tree tops. Probably troop transports. "..
            "One Hip is heading towards the village of ".._insertionVillage..". "..
            "The other two are diverting south. Looks like they are headed for the dam. [CALLSIGN] out",
        InsertionVillageDisamberked =
            "[CALLSIGN]. Be advised. Enemy troops are now disembarkinging single Hip at ".._insertionVillage..". [CALLSIGN] out",
        InsertionVillageLost =
            "[CALLSIGN]. Be advised. We get no response from the SDF forces in the village of ".._insertionVillage..". The village has probaboy fallen into enemy hands. [CALLSIGN] out",
        MortarTransportSpotted =
            "[CALLSIGN]. Spotted enemy militia group outside village of ".._insertionVillage..". Three vehicles. On road. Leed vehicle is machine gun. "..
            "Trailing vehicles are transports. Heading south. [CALLSIGN] out",
        RedMortarDeployed =
            "[CALLSIGN]. Enemy militia has deployed mortar platoon and commenced firing toward the dam area. Position is kp["..Cuckoo.Groups.RED.Mortar.GroupName.."]. "..
            "Repeat. Enemy mortar platton is firing toward dam area at kp["..Cuckoo.Groups.RED.Mortar.GroupName.."]. [CALLSIGN] out",
        RedMortarBreaks =
            "[CALLSIGN]. Enemy militia mortar seems to have been successfully destroyed. I see no more firing from that position at this time. [CALLSIGN] out",
    },
    Recon2 = {
        Introduction =
            "This is [CALLSIGN], checking in! We on our way up to the dam. The defenders up there expect an immediate attack and we're on our way to assist. "..
            "We are currently in the northern outskirts of the city but we'll report back when we're in position. [CALLSIGN] out",
        InsertionDamDisambarked =
            "[CALLSIGN]. We're at the dam position now and it's about to get messy up here. Enemy has disembarked troops outside the dam complex. Foot-mobiles are now in the trees, heading our way. "..
            "Request immediate interdiction, area suppression weapons. Will mark area with red and green smoke. "..
            "Repeat. Request area suppression on enemy foot-mobiles moving through trees, toward the dam. Marking area with red and green smoke in sixty seconds! [CALLSIGN] out",
        SpeedBoatsSpotted =
            "[CALLSIGN]. We see multiple speed boats heading straight for the dam. Counting six boats at high speed. "..
            "We need those taken out before they can join the fight! Speed boats are heading east at kp["..Cuckoo.Groups.RED.SpeedBoats_1.GroupName.."]. "..
            "Repeat. Request anti-ship interdiction. Multiple speed boats. kp["..Cuckoo.Groups.RED.SpeedBoats_1.GroupName.."]. [CALLSIGN] out",
        SpeedBoatsDisembarked =
            "[CALLSIGN]. The enemy speedboats have landed and disembarked troops north of our position. Seven hundred meters. "..
            "Multiple foot mobiles are advancing in protection along the western concrete bank. Can we get a few strafing runs on these buggers before they get any closer? [CALLSIGN] out",
        RedMortarBarrage =
            "[CALLSIGN]. The enemy is laying down a heavy mortar barrage south of the dam. We need to get reinforcements and more ammunition up here but it's impossible as long as that is going on. "..
            "The mortar accuracy also isn't too great and we fear the dam itself will start taking hits soon. Any chance you can get some airpower to find those clowns and stop them? [CALLSIGN] out",
        RedChoppersAttackingDam =
            "[CALLSIGN]. Those bloody helicopters are starting to get on our nerves up here. These do-dos are conducting rocket runs on the dam defenders but the precision is all over "..
            "the place and the dam structure is taking a beating too. Do you think you can of your merry airmen over to shoo them off? [CALLSIGN] out",
        AttackDam_Phase3 =
            "[CALLSIGN]. We have enemy foot mobiles advancing toward dam structure, from treeline north of defensive positions. [CALLSIGN] out",
        BluReinforcementsEnroute =
            "[CALLSIGN]. Be advised. The reinforcements are now arriving at the dam. [CALLSIGN] out",
        BLU_Wins =
            "This is [CALLSIGN]. Seems we managed to pull through. The enemy assault on our position has been successfully defeated and the dam is once again secure. "..
            "All attackers have been incapacitated or captured. Thanks for all the help! Outstanding work everyone! [CALLSIGN] out",
    },
    ReconSpotter2 = {
        Introduction = nil,
        InsertionDamDisambarked =
            "I can see foot-mobiles moving in the trees to our north east. One thousand five hundred meters. Advancing toward the dam now!",
        SpeedBoatsSpotted =
            "Hey! There are multiple speed boats heading toward the dam, from the west! Just north of that island..",
        SpeedBoatsDisembarked =
            "Seems those speedboats have landed and disembarked troops north of the dam position. About seven hundred meters. "..
            "I can see multiple foot mobiles advancing in protection along the western concrete berm. Would be great if we could get some straefing runs on these buggers!",
        RedMortarBarrage =
            "I just heard from staff. They're trying to get reinforcements and ammo up to the dam but it's impossible as long as that mortar barrage is going on. "..
            "Seems the mortar accuracy also isn't too great and I think the dam itself will start taking hits soon. Any chance you can get some airpower to find those clowns and stop them?",
        RedChoppersAttackingDam =
            "Those bloody helicopters are starting to get on my nerves! I think they're trying to hit the dam defensive positions but the precision is all over "..
            "the bloody place, and the dam structure is taking a beating too! Do you think you can get any of those merry airmen over to shoo them off for us?",
        AttackDam_Phase3 =
            "Heads up. Enemy foot mobiles are advancing from the treeline toward dam structure now! Here comes the attack! We need reinforcements up there now!",
        BluReinforcementsEnroute =
            "Looks like those reinforcements finally managed to pull through. About time!",
        BLU_Wins =
            "Nice! Seems we managed to pull through. I hear the enemy assault on the dam has been successfully beaten back, and the dam should be secure again. "..
            "All attackers have been incapacitated or captured. Great work everyone!",
    }

}

Cuckoo.Flags = {
    Cuckoo_RED_Hind_Phase_2 = "Cuckoo_RED_Hind_Phase_2",
    Cuckoo_RED_Hind_Phase_3 = "Cuckoo_RED_Hind_Phase_3",
    Cuckoo_RED_HeloInserted_Dam_Attack = "Cuckoo RED HeloInserted Dam Attack"
}

Cuckoo.Locations = {
    -- MortarRTB = DCAF.Location.Resolve(_name .. " Mortar RTB"),
    -- ArmorRetreat = DCAF.Location.Resolve(_name .. " Armor Retreat"),
}

function Cuckoo:ActivateGroups()
    -- BLU
    self:ActivateStaggered(self.Groups.BLU, 1, false, function(key, group)
        Debug(self.Name .. ":ActivateGroups :: activates group: " .. group.GroupName)
        if group == self.Groups.BLU.APC_1 then
            self._dam_destination = group:GetCoordinate()
        end
    end)

    -- RED
    local mortarTransport = self.Groups.RED.MortarTransport
    local red = {
        mortarTransport
    }

    -- TODO - the following is written to easily allow more RED groups. If we end up only with the mortar transport, just simplify it
    self:ActivateStaggered(red, 1, false, function(_, group)
        DCAF.delay(function()
            if group == mortarTransport then
                group:CommandSetInvisible(true)
                group:SetAIOff()
            end
        end, 1)
    end)
end

function Cuckoo:InitTTSTopDog(tts, receiver, callsignRecon2, redAirbase)
    if not isAssignedString(callsignRecon2) then return Error(self.Name .. ":InitTTSTopDog :: `callsignRecon2` must be assigned string, but was: " .. DumpPretty(callsignRecon2)) end
    if not isAssignedString(redAirbase) then return Error(self.Name .. ":InitTTSTopDog :: `redAirbase` must be assigned string, but was: " .. DumpPretty(redAirbase)) end
    self.TTS_TopDog = tts
    self.TTS_TopDogReceiver = receiver
    tts:InitVariable("CALLSIGN_RECON_2", callsignRecon2)
    tts:InitVariable("RED_AIRBASE", redAirbase)
end

function Cuckoo:SendTopDog(msg)
    if not self.TTS_TopDog then return Error(self.Name .. ":SendTopDog :: Top Dog (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendTopDog :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_TopDogReceiver then
        msg = self.TTS_TopDogReceiver .. ". " .. msg
    end
    self.TTS_TopDog:Send(msg)
    return self
end

function Cuckoo:InitTTSRecon1(tts, receiver)
    self.TTS_Recon1 = tts
    self.TTS_Recon1Receiver = receiver
end

function Cuckoo:SendRecon1(msg)
    if not self.TTS_Recon1 then return Error(self.Name .. ":SendRecon1 :: Recon (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendRecon1 :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_Recon1Receiver then
        msg = self.TTS_Recon1Receiver .. ". " .. msg
    end
    self.TTS_Recon1:Send(msg)
    return self
end

function Cuckoo:InitTTSRecon2(tts, receiver)
    self.TTS_Recon2 = tts
    self.TTS_Recon2Receiver = receiver
end

local function findSpotter2msg(msg)
    for key, message in pairs(Cuckoo.MSG.Recon2) do
        if message == msg then
            return Cuckoo.MSG.ReconSpotter2[key]
        end
    end
end

function Cuckoo:SendRecon2(msg)
    if self.TTS_ReconSpotter2 then
        self:SendReconSpotter2(findSpotter2msg(msg))
        return self
    end

    if not self.TTS_Recon2 then return Error(self.Name .. ":SendRecon2 :: Recon (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendRecon2 :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_Recon2Receiver then
        msg = self.TTS_Recon2Receiver .. ". " .. msg
    end
    self.TTS_Recon2:Send(msg)
    return self
end

function Cuckoo:InitTTSReconSpotter2(tts)
    self.TTS_ReconSpotter2 = tts
end

function Cuckoo:SendReconSpotter2(msg)
    if not self.TTS_ReconSpotter2 then return Error(self.Name .. ":SendReconSpotter2 :: Recon spotter 2 (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendReconSpotter2 :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_ReconSpotter2Receiver then
        msg = self.TTS_ReconSpotter2Receiver .. ". " .. msg
    end
    self.TTS_ReconSpotter2:Send(msg)
    return self
end

function Cuckoo:OnStarted()
    if self._menuStart then self._menuStart:Remove(true) end
    if self:SendTopDog(self.MSG.TopDog.RedChoppersDeparting) then
        DCAF.delay(function()
            self:GhostHelo1Start(40)
        end, Minutes(6))
        DCAF.delay(function()
            Cuckoo:StartREDHeloInsertion()
        end, Minutes(12))
    else
        Cuckoo:StartREDHeloInsertion()
    end
    self:AddGMMenusAfterStart()
end

function Cuckoo:GhostHelo1Start(timeout)
    if self.Groups.RED.HeloGhost_1 then
        self.Groups.RED.HeloGhost_1:Activate()
        if isNumber(timeout) then
            DCAF.delay(function()
                self:GhostHelo1End()
            end, timeout)
        end
    end
end

function Cuckoo:GhostHelo1End()
    self.Groups.RED.HeloGhost_1:Destroy()
end

function Cuckoo:IsActive()
    return self._isStarted and not self._winner
end

function Cuckoo:GetGM_Menu()
    if not self.GM_Menu then
        self.GM_Menu = GM_Menu:AddMenu(string.upper(self.Name))
    end
    return self.GM_Menu
end

function Cuckoo:_redGroupDisembarks(group)
    self._countDisembarked = self._countDisembarked or 0
    self._countDisembarked = self._countDisembarked + 1
end

function Cuckoo:_redGroupBreaks(group)
    self._countDisembarkedBroken = self._countDisembarkedBroken or 0
    self._countDisembarkedBroken = self._countDisembarkedBroken + 1
    local relLosses = self._countDisembarkedBroken / self._countDisembarked
    if relLosses > self._redLossThreshold then
        self:BLU_Wins()
    end
end

-- ///////////////////////////////////// Syria SF Helo Insertion /////////////////////////////////////
-- These groups job is to take and secure the road to the dam, from the north, so ensure Militia can
-- get in and set up their mortar platoon

function Cuckoo:StartREDHeloInsertion()
    self.Groups.RED.HeloCAS_1:Activate()

    self.Groups.RED.InfantryDam_1:Activate()
    self.Groups.RED.InfantryDam_2:Activate()
    self.Groups.RED.InfantryZamzam_1:Activate()

    self.Groups.RED.HeloInsertion_1:Activate()
    self.Groups.RED.HeloInsertion_2:Activate()
    self.Groups.RED.HeloInsertion_3:Activate()

    -- DCAF.delay(function()
    -- end, 0.5)
end

function Cuckoo:REDHeloInsertionAttack(delay)
    Debug(_name .. ":REDHeloInsertionAttack() :: delay: " .. Dump(delay))
    local function sendMessage()
        if self._isRedInsertionAttackReported then return end
        self._isRedInsertionAttackReported = true
        self:SendRecon1(self.MSG.Recon1.InsertionVillageAttacked)
    end

    self.Groups.RED.HeloCAS_1:HandleEvent(EVENTS.Shot, function(_, e)
        if e.IniGroup ~= Cuckoo.Groups.RED.HeloCAS_1 then return end
        sendMessage()
        Cuckoo.Groups.RED.HeloCAS_1:UnHandleEvent(EVENTS.Shot)
        DCAF.delay(function()
            self.Groups.BLU.InfantryZamzam:Destroy()
        end, Minutes(1))
    end)

    DCAF.delay(function()
        sendMessage()
    end, delay or 30)

    local victoryTimeout = self._redVictoryTimeout or Minutes(20)
    DCAF.delay(function()
        if self._winner then return end
        self:BLU_Wins()
    end, victoryTimeout)
end

function Cuckoo:REDHeloInsertionInboundVillage()
    Debug(_name .. ":REDHeloInsertionInboundVillage()")
    if self._reHeloInsertionInboundVillage then return end
    self._reHeloInsertionInboundVillage = true
    DCAF.delay(function()
        self:SendRecon1(self.MSG.Recon1.InsertionHipsInbound)
        DCAF.delay(function()
            self:SendRecon2(self.MSG.Recon2.Introduction)
        end, Minutes(1))
    end, 10)
end

function Cuckoo:REDHeloInsertionDisembarkVillage()
    Debug(_name .. ":REDHeloInsertionDisembarkVillage()")
    self.Groups.BLU.InfantryZamzam:SetAIOn()
    self.Groups.BLU.InfantryZamzam:CommandSetImmortal(false)
    self:RouteMortarTransport()
    DCAF.delay(function()
        self:SendRecon1(self.MSG.Recon1.InsertionVillageDisamberked)
    end, 40)
    DCAF.delay(function()
        DCAF.delay(function()
            self:RouteShilkaToDam()
        end, Minutes(2))
    end, Minutes(3))
end

--- Fallback mechanism. If this function is called, no fallback group needs to be activated
function Cuckoo:HeloInsertDisembarkMonitorFallback(groupSuffix, timeout)
    self._disembarkFallback = self._disembarkFallback or {}
    self._disembarkFallback[groupSuffix] = _name .. " " .. groupSuffix .. "-fallback"
    DCAF.delay(function()
        self:HeloInsertDisembarkTriggerFallback(groupSuffix)
    end, timeout)
end

--- Fallback mechanism. If this function is called, no fallback group needs to be activated
function Cuckoo:HeloInsertDisembarkTriggerFallback(groupSuffix)
    local fallbackGroupName = self._disembarkFallback[groupSuffix]
    if fallbackGroupName then
        local group = getGroup(_name .. " " .. groupSuffix)
        -- if group and group:IsActive() then return end
        getGroup(fallbackGroupName):Activate()
        self._disembarkFallback[groupSuffix] = nil
    end
end

--- Fallback mechanism. If this function is called, no fallback group needs to be activated
function Cuckoo:HeloInsertDisembarkOK(groupSuffix)
    self._disembarkFallback[groupSuffix] = nil
end

function Cuckoo:InsertionVillageLost()
    if self._is_InsertionVillageLost then return end
    self._is_InsertionVillageLost = true
    Debug(_name .. ":InsertionVillageLost()")
    self:SendRecon1(self.MSG.Recon1.InsertionVillageLost)
    self:OnInsertionVillageLost()
end

function Cuckoo:OnInsertionVillageLost()
end

function Cuckoo:REDHeloInsertionDisembarkDam()
    Debug(_name .. ":REDHeloInsertionDisembarkDam() :: ._isREDHeloInsertionDisembarkDam: " .. Dump(self._isREDHeloInsertionDisembarkDam))
    self:_redGroupDisembarks()
    if self._isREDHeloInsertionDisembarkDam then return end
    self._isREDHeloInsertionDisembarkDam = true

    local function markSmoke()
        if self.TTS_ReconSpotter2 then return end -- we're set up so that the JTAC is a human player. He can drop smoke himself
        local wps = FindWaypointsByName(self.Groups.RED.InfantryDam_2, "_ref1", "_ref2")
Debug("nisse - Cuckoo:REDHeloInsertionDisembarkDam_markSmoke :: wps: " .. DumpPretty(wps))
        if not wps then return end
        if wps[1] then
            COORDINATE_FromWaypoint(wps[1].data):SmokeRed()
        end
        if wps[2] then
            COORDINATE_FromWaypoint(wps[2].data):SmokeGreen()
        end
    end

    DCAF.delay(function()
        self:SendRecon2(self.MSG.Recon2.InsertionDamDisambarked)
        DCAF.delay(function()
            markSmoke()
        end, Minutes(1))
    end, 30)

    DCAF.delay(function()
        self:RedChoppersAttackingDam()
    end, Minutes(7))
end

function Cuckoo:REDHeloInsertedDamAttack()
    Debug(_name .. ":REDHeloInsertedDamAttack() :: ._is_REDHeloInsertedDamAttack: " .. Dump(self._is_REDHeloInsertedDamAttack))
    if self._is_REDHeloInsertedDamAttack then return end
    self._is_REDHeloInsertedDamAttack = true
    Debug(_name .. ":REDHeloInsertedDamAttack")
    SetFlag(self.Flags.Cuckoo_RED_HeloInserted_Dam_Attack)
end

function Cuckoo:AttackDam_Phase2()
    Debug(_name .. ":AttackDam_Phase2() :: ._is_AttackDam_Phase2: " .. Dump(self._is_AttackDam_Phase2))
    if self._is_AttackDam_Phase2 then return end
    self._is_AttackDam_Phase2 = true
    SetFlag(self.Flags.Cuckoo_RED_Hind_Phase_2)
    self:StartSpeedBoats()
end

function Cuckoo:AttackDam_Phase3()
    Debug(_name .. ":AttackDam_Phase3() :: ._is_AttackDam_Phase3: " .. Dump(self._is_AttackDam_Phase3))
    if self._is_AttackDam_Phase3 then return end
    self._is_AttackDam_Phase3 = true
    Debug(_name .. ":ReeHeloCAS_Phase3()")
    SetFlag(self.Flags.Cuckoo_RED_Hind_Phase_3)
    self:SendRecon2(self.MSG.Recon2.AttackDam_Phase3)
end

function Cuckoo:RedHelicoptersRTB()
    Debug(_name .. ":RedHelicoptersRTB()")
    tableIterate({
        self.Groups.RED.HeloCAS_1,
        self.Groups.RED.HeloInsertion_1,
        self.Groups.RED.HeloInsertion_2,
        self.Groups.RED.HeloInsertion_3,
    }, function(_, group)
        RouteDirectTo( group, "_rtb", true )
    end)
end

function Cuckoo:RedChoppersAttackingDam()
    Debug(_name .. ":RedChoppersAttackingDam()")
    local count = 0
    tableIterate({
        self.Groups.RED.HeloCAS_1,
        self.Groups.RED.HeloInsertion_1,
        self.Groups.RED.HeloInsertion_2,
        self.Groups.RED.HeloInsertion_3,
    }, function(_, group)
        if group:IsAlive() then count = count+1 end
    end)
    if count > 1 then
        self:SendRecon2(self.MSG.Recon2.RedChoppersAttackingDam)
    end
end

-- ///////////////////////////////////// BLU troop movements /////////////////////////////////////

function Cuckoo:RouteTruckToDam()
    if self._is_RouteTruckToDam then return end
    self._is_RouteTruckToDam = true
    Debug(_name .. ":RouteTruckToDam() :: ._dam_destination: " .. DumpPretty(self._dam_destination))
    if self._dam_destination then
        local coord = COORDINATE:NewFromVec2(self._dam_destination:GetRandomVec2InRadius(60))
        self.Groups.BLU.Truck_1:RouteGroundOnRoad(coord, 40)
    end
end

function Cuckoo:RouteShilkaToDam()
    if self._is_RouteShilkaToDam then return end
    self._is_RouteShilkaToDam = true
    Debug(_name .. ":RouteShilkaToDam() :: ._dam_destination: " .. DumpPretty(self._dam_destination))
    if self._dam_destination then
        local coord = COORDINATE:NewFromVec2(self._dam_destination:GetRandomVec2InRadius(60))
        self.Groups.BLU.Shilka:RouteGroundOnRoad(coord, 40)
    end
end

-- ///////////////////////////////////// Syria SF Speed Boats  /////////////////////////////////////
-- The speed boats will disembark north of the dam, and then proceed in cover to attack and take it


function Cuckoo:StartSpeedBoats()
    self.Groups.RED.SpeedBoats_1:Activate()
    self.Groups.RED.SpeedBoats_2:Activate()
    self.Groups.RED.SpeedBoats_3:Activate()
end

function Cuckoo:SpeedBoatsSpotted()
    Debug(_name .. ":SpeedBoatsSpotted()")
    if self._is_SpeedBoatsSpotted then return end
    self._is_SpeedBoatsSpotted = true
    if not self:SendRecon2(self.MSG.Recon2.SpeedBoatsSpotted) then
        self:SendTopDog(self.MSG.TopDog.SpeedBoatsSpotted)
    end
end

function Cuckoo:LandSpeedBoatSquad_1()
    Debug(_name .. ":LandSpeedBoatSquad_1()")
    local group = self.Groups.RED.SpeedBoatSquad_1
    if not group then return end
    local mortal = DCAF.Mortal:New(group:Activate(), .35)
    function mortal:OnBreaks()
        Cuckoo:_redGroupBreaks(group)
    end
    self.Groups.RED.SpeedBoatSquad_4:Activate()
    self:SpeedBoatsDisembarked()
end

function Cuckoo:LandSpeedBoatSquad_2()
    Debug(_name .. ":LandSpeedBoatSquad_2()")
    local group = self.Groups.RED.SpeedBoatSquad_2
    if not group then return end
    local mortal = DCAF.Mortal:New(group:Activate(), .35)
    function mortal:OnBreaks()
        Cuckoo:_redGroupBreaks(group)
    end
    self:SpeedBoatsDisembarked()
end

function Cuckoo:LandSpeedBoatSquad_3()
    Debug(_name .. ":LandSpeedBoatSquad_3()")
    local group = self.Groups.RED.SpeedBoatSquad_3
    if not group then return end
    local mortal = DCAF.Mortal:New(group:Activate(), .35)
    function mortal:OnBreaks()
        Cuckoo:_redGroupBreaks(group)
    end
    self:SpeedBoatsDisembarked()
end

function Cuckoo:SpeedBoatsDisembarked()
    Debug(_name .. ":SpeedBoatsDisembarked()")
    if self._is_SpeedBoatsDisembarked then return end
    self._is_SpeedBoatsDisembarked = true
    if not self:SendRecon2(self.MSG.Recon2.SpeedBoatsDisembarked) then
        self:SendTopDog(self.MSG.TopDog.SpeedBoatsDisembarked)
    end
end

function Cuckoo:RedSpeedBoatsRTB()
    Debug(_name .. ":RedSpeedBoatsRTB()")
    tableIterate({
        self.Groups.RED.SpeedBoats_1,
        self.Groups.RED.SpeedBoats_2,
        self.Groups.RED.SpeedBoats_3,
    }, function(_, group)
        RouteDirectTo( group, "_rtb", true )
    end)
end

-- ///////////////////////////////////// Militia Mortar Platoon /////////////////////////////////////
-- These guys job is to lay barrage fire south of dam to prevent BLU reinforcements from reaching it

function Cuckoo:RouteMortarTransport()
    self.Groups.RED.MortarTransport:SetAIOn():CommandSetInvisible(false)
end

function Cuckoo:MortarTransportSpotted()
    self:SendRecon1(self.MSG.Recon1.MortarTransportSpotted)
end

function Cuckoo:DeployREDMortar()
    local mortar = self.Groups.RED.Mortar
    if not mortar then return end
    mortar:Activate()

-- nisse - test destroying mortar..
local hog_1 = getGroup("111 Test Hog-1")
if hog_1 then hog_1:Activate() end

    for _, group in pairs(self.Groups.RED.MortarCrew) do
        group:Activate()
    end
    DCAF.delay(function()
        self:SendRecon1(self.MSG.Recon1.RedMortarDeployed)
    end, 30)
    mortar:HandleEvent(EVENTS.Shot, function(_, e)
Debug("nisse - Mortar SHOT event :: e: " .. DumpPretty(e))
        if e.IniGroup ~= mortar then return end
        if Cuckoo._isMortarBroken then 
            mortar:UnHandleEvent(EVENTS.Shot)
            return
        end
        DCAF.delay(function()
            if not Cuckoo:SendRecon2(Cuckoo.MSG.Recon2.RedMortarBarrage) then
                Cuckoo:SendTopDog(Cuckoo.MSG.TopDog.RedMortarBarrage)
            end
        end, Minutes(1.5))
        mortar:UnHandleEvent(EVENTS.Shot)
    end)

    local mortalMortar = DCAF.Mortal:New(mortar)
Debug("nisse - Cuckoo:DeployREDMortar :: mortar is mortal")
    function mortalMortar:OnBreaks()
Debug("nisse - Cuckoo:DeployREDMortar :: mortar breaks")
        self._isMortarBroken = true
        pcall(function()
            Cuckoo:OnMortarBreaks()
        end)
    end
end

function Cuckoo:RedMortarBarrage()
    if not self:SendRecon2(self.MSG.Recon2.RedMortarBarrage) then
        self:SendTopDog(self.MSG.TopDog.RedMortarBarrage)
    end
end

function Cuckoo:OnMortarBreaks()
    Debug(_name .. ":OnMortarBreaks")
    DCAF.delay(function()
        self:SendBluReinforcements()
        self:SendRecon1(self.MSG.Recon1.RedMortarBreaks)
    end, Minutes(2))
end

function Cuckoo:SendBluReinforcements()
    local group = getGroup(_name .. " BLU Reinforcements")
    if not group then return end
    group:Activate()
end

function Cuckoo:BluReinforcementsEnroute()
    self:SendRecon2(self.MSG.Recon2.BluReinforcementsEnroute)
end

function Cuckoo:BluReinforcementsArrive()
end

-- ///////////////////////////////////// Story Winner /////////////////////////////////////

function Cuckoo:_setWinner(coalition)
    if self._winner then return end
    self._winner = coalition
    pcall(function() self:OnWinner(coalition) end)
    self:End()
    return true
end

function Cuckoo:RED_Wins()
    self:_setWinner(Coalition.Red)
end

function Cuckoo:BLU_Wins()
    Debug(_name .. ":BLU_Wins()")
    if not self:_setWinner(Coalition.Blue) then return end
    self:RedHelicoptersRTB()
    self:RedSpeedBoatsRTB()

    DCAF.delay(function()
        if not self:SendRecon2(self.MSG.Recon2.BLU_Wins) then
            self:SendTopDog(self.MSG.TopDog.BLU_Wins)
        end
    end, Minutes(2))
end

function Cuckoo:OnWinner(coalition)
    -- to be overridden
end

-- //////////////////// GM Menu ////////////////////

Cuckoo._menuStart = Cuckoo:GetGM_Menu():AddCommand("Start", function()
    Cuckoo:Start()
end)

function Cuckoo:AddGMMenusAfterStart()
end

-- ///////////////////   Add All Groups To Map   ///////////////////
Cuckoo:ActivateGroups()

Trace("////////// Story_Peacock was loaded //////////")
