local _name = "Peacock"
local _codeword = _name
Peacock = DCAF.Story:New(_name)
if not Peacock then return end

local _artyAimTime = 15 -- Minutes(2) + 50
local _artyFlyTime = 40
local _armor = _name .. " RED MBT T72"

Peacock.Groups = {
    BLU = {
        Recon1 = getGroup(_name .. " BLU Recon-1", 1),
        Recon2 = getGroup(_name .. " BLU Recon-2", 2),
        Lead = getGroup(_name .. " BLU Lead", 3),
        Center = getGroup(_name .. " BLU Center", 4),
        Rear = getGroup(_name .. " BLU Rear", 5),
    },
    RED = {
        Recon1 = getGroup(_name .. " RED Recon-1"),
        Helicopters = getGroup(_name .. " SYR Gazelles"),
        Mortar1 = getGroup(_name .. " RED Mortar-1"),
        Mortar2 = getGroup(_name .. " RED Mortar-2"),
        MortarTransport_Truck = getGroup(_name .. " RED Mortar Transport-Truck"),
        MortarTransport_MG = getGroup(_name .. " RED Mortar Transport-MG"),
        MANPADS_1 = getGroup(_name .. " RED MANPADS-1"),
        MANPADS_2 = getGroup(_name .. " RED MANPADS-2"),
        MANPADS_3 = getGroup(_name .. " RED MANPADS-3"),
        Spotter1 = getGroup(_name .. " RED Mortar Spotter-1"),
        Spotter2 = getGroup(_name .. " RED Mortar Spotter-2"),
        Spotter3 = getGroup(_name .. " RED Mortar Spotter-3"),
        Ambush1 = getGroup("Peacock RED Ambush-1"),
        Ambush2 = getGroup("Peacock RED Ambush-2"),
        AmbushMANPADS = getGroup("Peacock RED Ambush-MANPADS"),
        Armor = getGroup(_armor)
    },
}

Peacock.MSG = {
    TopDog = {
        Start = "[CALLSIGN]. Be adviced. Word is " .. _codeword .. ". Word is " .. _codeword
    },
    Recon1 = {
        CautionRedRecon =
            "This is [CALLSIGN] One. We have word from Lead. They think they saw a fishy looking vehicle to their left, about two clicks south of Reference Charlie. Looked like a technical. Can you check it out?. [CALLSIGN] One out",
        TakingFireFromSouth =
            "[CALLSIGN] One. We are taking small arms fire from multiple vehicles moving toward us from the south. Stand by for tasking.",
        AmbushBegin =
            "This is [CALLSIGN] One. Requesting emergency close air support. South of highway. rp[Delta // ".._name.." RED Ambush-2]. Target is infantry in treeline, with small arms and RPG. Mark by smoke. "..
            "Request area suppression weapons, on your discretion. Ingress from west or east. Expect triple A and manpads. [CALLSIGN] One out",
        AmbushDefeated =
            "This is sergeant Cole from [CALLSIGN] One. Captain Bennet will have to ar tee bee for medical care so you'll be hearing my voice from now on. "..
            "We seems to have had good effect and we're making good progress again! [CALLSIGN] One out",
        AmbushDefeatedMoppingUp =
            "This is sergeant Cole from [CALLSIGN] One. Captain Bennet will have to ar tee bee for medical care so you'll be hearing my voice from now on. "..
            "We seems to have had good effect so we'll mop up here and move on. Might take a bit as some vehicles will have to be destroyed to speed up the progress. "..
            "Thanks for your help guys! [CALLSIGN] One out",
    },
    Recon2 = {
        Start =
            "[CALLSIGN] Two. Glad to see you guys! So, here's the plan. We're at rp[Bravo // ".._name.." BLU Recon-1]. "..
            "We are the point recon unit. Two humvees. Behind us is a three-vehicle SDF recon group and the main convoy is about two clicks further back. "..
            "Main convoy is three groups: Lead, Center, and Rear. ".._codeword.." is riding Center. [CALLSIGN] One is riding Rear. [CALLSIGN] Two out",
        Mortar1 =
            "[CALLSIGN] Two. We are rp[Delta // ".._name.." BLU Recon-1]. Taking heavy mortar fire from the north, probably from the other side of the river. See if you can make them stop!. [CALLSIGN] Two out",
        Mortar2 =
            "[CALLSIGN] Two. That mortar is active again. It's laying down barrage fire on the road between us and the convoy. We got word the convoy is stopping, waiting for you guys to take care of the bastards.. [CALLSIGN] Two out",
        Mortar2Dead =
            "[CALLSIGN] Two. Thanks for dealing with those assholes. The convoy is now moving out again!. [CALLSIGN] Two out",
        Mortar2StillAlive =
            "This is [CALLSIGN] Two. Seems that mortar never runs out of ammo but we need to press on.  [CALLSIGN] Two out",
        LeavingHighway =
            "[CALLSIGN] Two. Be advised. We are at Hotel. Heading north. " .. _codeword .. " is rp[Hotel // ".._name.." BLU Center]. [CALLSIGN] Two out",
        CautionHelicopters =
            "[CALLSIGN] Two. We see a pair of choppers over at the northern dam. Can you check if they are coalition or hostile?. [CALLSIGN] Two out",
        RedArmor = 
            "[CALLSIGN] Two. Requesting immediate interdiction! We have enemy armor heading east on the highway, just east of the forest. Platoon strength. Reference rp[Juliet // ".._armor.."]. "..
            "Repeat. Request immediate interdiction for armored platoon on highway. Reference rp[Juliet // ".._armor.."]. [CALLSIGN] Two out",
        RedArmorGoodHit =
            "Good hits! Strikem down with vengeance and fire!",
        RedArmorBreaks =
            "[CALLSIGN] Two. Looks like you've made short work of the armor. We can see the crews are abandoning their tanks. Outstanding work guys! Our SDF buddies request you leave the surviving tanks as a war price for Rojava. [CALLSIGN] Two out",
        RedArmorDestroyed =
            "[CALLSIGN] Two. Looks like you've made short work of the armored platoon. They all looks to be burning from what is looks like! Outstanding work guys! [CALLSIGN] Two out",
        Success =
            "[CALLSIGN] Two. Alright. " .. _codeword .. " has arrived at uniform. Thanks for looking out for us. Beer is on us when we bump into you guys! [CALLSIGN] Two out"
    }
}

Peacock.Locations = {
    MortarRTB = DCAF.Location.Resolve(_name .. " Mortar RTB"),
    ArmorRetreat = DCAF.Location.Resolve(_name .. " Armor Retreat"),
}

function Peacock:InitTTSTopDog(tts, receiver)
    self.TTS_TopDog = tts
    self.TTS_TopDogReceiver = receiver
end

function Peacock:SendTopDog(msg)
    if not self.TTS_TopDog then return Error(self.Name .. ":SendTopDog :: Top Dog (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendTopDog :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_TopDogReceiver then
        msg = self.TTS_TopDogReceiver .. ". " .. msg
    end
    self.TTS_TopDog:Send(msg .. ". [CALLSIGN] out.")
end

function Peacock:InitTTSRecon1(tts, receiver)
    self.TTS_Recon1 = tts
    self.TTS_Recon1Receiver = receiver
end

local _rp_messages = {
    "We are passing reference",
    "We are passing",
    "Passing reference",
    "Passing reference point",
    "We're at reference point",
    "Now at reference",
    "Now passing reference",
}

function Peacock:SendRecon1PassingRP(rp)
    local msg = listRandomItem(_rp_messages)
    self:SendRecon1("[CALLSIGN] One. " .. msg .. " " .. rp)
end

function Peacock:SendRecon2PassingRP(rp)
    local msg = listRandomItem(_rp_messages)
    self:SendRecon2("[CALLSIGN] Two. " .. msg .. " " .. rp)
end

function Peacock:SendRecon1(msg)
    if not self.TTS_Recon1 then return Error(self.Name .. ":SendRecon :: Recon (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendRecon :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_Recon1Receiver then
        msg = self.TTS_Recon1Receiver .. ". " .. msg
    end
    self.TTS_Recon1:Send(msg) -- .. ". [CALLSIGN] out.")
end

function Peacock:InitTTSRecon2(tts, receiver)
    self.TTS_Recon2 = tts
    self.TTS_Recon2Receiver = receiver
end

function Peacock:SendRecon2(msg)
    if not self.TTS_Recon2 then return Error(self.Name .. ":SendRecon :: Recon (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendRecon :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_Recon2Receiver then
        msg = self.TTS_Recon2Receiver .. ". " .. msg
    end
    self.TTS_Recon2:Send(msg) -- .. ". [CALLSIGN] out.")
end

function Peacock:ActivateAndLobotomizeGroups()
    -- BLU
    self:ActivateStaggered(self.Groups.BLU, 1, true, function(key, group)
        DCAF.delay(function()
            Debug(self.Name .. ":Peacock:ActivateAndLobotomizeGroups :: lobotomizes group: " .. group.GroupName)
            group:SetAIOff()
        end, 1)
    end)

    -- RED
    local red = {
        self.Groups.RED.Recon1,
        -- self.Groups.RED.Ambush1,
        self.Groups.RED.Mortar1,
        self.Groups.RED.MortarTransport_Truck,
        self.Groups.RED.MortarTransport_MG,
        self.Groups.RED.MANPADS_1,
        self.Groups.RED.MANPADS_2,
        self.Groups.RED.Armor
    }
    local mortar = self.Groups.RED.Mortar1
    local armor = self.Groups.RED.Armor
    self:ActivateStaggered(red, 1, false, function(_, group)
        DCAF.delay(function()
            Debug(self.Name .. ":Peacock:ActivateAndLobotomizeGroups :: lobotomizes group: " .. group.GroupName)
            group:SetAIOff()
            if group == mortar then
                group:CommandSetInvisible(true)
                local mortal = DCAF.Mortal:New(mortar, .5)
                function mortal:OnBreaks()
                    Debug(_name .. " :: RED mortar is broken")
                    self.isMortarBroken = true
                    self:Move_mortar_or_RTB()
                end
                self._mortalMortar = mortal
            elseif group == armor then
                self.AmbushArmor = DCAF.Ambush:New(armor)
            else
                group:CommandSetInvisible(true)
            end
        end, 1)
    end)
end

function Peacock:OnStarted()
    if self._menuStart then self._menuStart:Remove(true) end
    self.Groups.BLU.Recon1:SetAIOn()
    self.Groups.BLU.Recon2:SetAIOn()
    self.Groups.BLU.Lead:SetAIOn()
    DCAF.delay(function()
        self.Groups.BLU.Center:SetAIOn()
        self.Groups.BLU.Rear:SetAIOn()
        self._recon1_start_coordinatee = self.Groups.BLU.Rear:GetCoordinate()
    end, Minutes(1.2))
    self:SendRecon2(self.MSG.Recon2.Start)
    DCAF.delay(function()
        self:SendTopDog(self.MSG.TopDog.Start)
    end, Minutes(1))
    self:AddGMMenusAfterStart()
end

function Peacock:GetGM_Menu()
    if not self.GM_Menu then
        self.GM_Menu = GM_Menu:AddMenu(string.upper(self.Name))
    end
    return self.GM_Menu
end

function Peacock:CautionRedRecon()
    self:SendRecon1(self.MSG.Recon1.CautionRedRecon)
    DCAF.delay(function()
        DCAF.MobileDefence:New(self.Groups.RED.Recon1:SetAIOn(), 1, self.Groups.RED.MANPADS_1.GroupName)
    end, 25)
    DCAF.delay(function()
        self.Groups.RED.Recon1:CommandSetInvisible(false)
        -- self.Groups.RED.Ambush1:CommandSetInvisible(false)
    end, Minutes(2))
end

function Peacock:DeployMortar1() -- triggered from convoy (Lead) WP
    Debug(self.Name .. ":DeployMortar1 :: RED mortar attacks")
    self.Groups.RED.MANPADS_1:SetAIOn()
    self.Groups.RED.MANPADS_2:SetAIOn()
    local mortar = self.Groups.RED.Mortar1:SetAIOn()

    DCAF.delay(function()
        local spotter = self.Groups.RED.Spotter1:Activate()
        local coordTarget = spotter:GetCoordinate():Translate(Feet(1200), 180)
        mortar:SetTask(mortar:TaskFireAtPoint(coordTarget:GetVec2(), 200))
        mortar:HandleEvent(EVENTS.Shot, function(_, e)
            if e.IniGroup ~= mortar then return end
            Debug(_name .. " :: Mortar 1 fires opens fire")
            mortar:UnHandleEvent(EVENTS.Shot)
            DCAF.delay(function()
                self:SendRecon2(self.MSG.Recon2.Mortar1)
                DCAF.delay(function()
                    -- after some time other AI units can spot the mortars, after they've started firing...
                    self.Groups.RED.MortarTransport_MG:CommandSetInvisible(false)
                    self.Groups.RED.MortarTransport_Truck:CommandSetInvisible(false)
                    mortar:CommandSetInvisible(false)
                    Debug(_name .. " :: Mortar and vehicles 1 is now AI-visible")
                end, 60)
            end, Minutes(1))
            DCAF.delay(function()
                local spotter = self.Groups.RED.Spotter2:Activate()
                local coordTarget = spotter:GetCoordinate():Translate(Feet(1300), 360)
                mortar:SetTask(mortar:TaskFireAtPoint(coordTarget:GetVec2(), 200))
                DCAF.delay(function()
                    self:Move_mortar_or_RTB()
                end, Minutes(5.15))
            end, Minutes(1))
        end)
    end, 1)
end

function Peacock:Move_mortar_or_RTB()
    Debug(self.Name .. ":Move_mortar_or_RTB...")
    if self._mortalMortar then self._mortalMortar:End() end
    if not self.isMortarBroken then
        self.Groups.RED.Mortar1:Destroy()
    end
    self.Groups.RED.MANPADS_1:Destroy()
    self.Groups.RED.MANPADS_2:Destroy()
    DCAF.delay(function()
        DCAF.MobileDefence:New(self.Groups.RED.MortarTransport_Truck:SetAIOn(), 1, self.Groups.RED.MANPADS_1.GroupName)
        DCAF.MobileDefence:New(self.Groups.RED.MortarTransport_MG:SetAIOn(), 1, self.Groups.RED.MANPADS_1.GroupName)
        if self.isMortarBroken then
            self:MortarRTB()
        end
    end, 30)
end

function Peacock:MortarRTB()
    local coordRTB = self.Locations.MortarRTB:GetCoordinate()
    self.Groups.RED.MortarTransport_Truck:RouteGroundOnRoad(coordRTB, 60)
    self.Groups.RED.MortarTransport_MG:RouteGroundOnRoad(coordRTB, 60)
end

function Peacock:StopForMortarBarrage()
    for _, group in pairs(self.Groups.BLU) do
        group:RouteStop()
    end
    self:SendRecon2(self.MSG.Recon2.Mortar2)
end

function Peacock:ResumeAfterMortarBarrage(isMortarAlive)
    DCAF.delay(function()
        for _, group in pairs(self.Groups.BLU) do
            group:RouteResume()
        end
        if isMortarAlive then
            self:SendRecon2(self.MSG.Recon2.Mortar2StillAlive)
        else
            self:SendRecon2(self.MSG.Recon2.Mortar2Dead)
        end
    end, Minutes(1))
end

function Peacock:DeployMortar2()
    self.Groups.RED.MANPADS_3:Activate()
    self.Groups.RED.Spotter3:Activate()
    local mortar = self.Groups.RED.Mortar2:Activate()
    DCAF.delay(function()
        self:StopForMortarBarrage()
-- nisse - debug killing mortar...
local hog = getGroup("111 TEST Hog-1")
if hog then hog:Activate() end
    end, Minutes(1.3))

    local mortalMortar = DCAF.Mortal:New(mortar)
    local function proceed()
        if Peacock.isMortarBroken then return end
        Peacock.isMortarBroken = true
        Peacock:MortarRTB()
        DCAF.delay(function()
            Peacock:ResumeAfterMortarBarrage(mortalMortar:IsAlive())
        end, Minutes(1.5))
    end

    function mortalMortar:OnBreaks()
        proceed()
    end
    -- fallback, to ensure convoy proceeds...
    DCAF.delay(function()
        proceed()
    end, Minutes(5))
end

function Peacock:StartAmbushVehicles()
    self.Groups.RED.Ambush1:Activate()
end

function Peacock:PrepareRedAmbush()
    self.Groups.RED.AmbushMANPADS:Activate()
    Peacock:SendRecon1(Peacock.MSG.Recon1.TakingFireFromSouth)
end

function Peacock:SpringRedAmbush()
    self.Groups.RED.Recon1:CommandSetInvisible(false)
    local infantry = self.Groups.RED.Ambush2:Activate()
    infantry:CommandSetImmortal(true)
    local mortalInfantry = DCAF.Mortal:New(infantry)
    local mortalVehicles = DCAF.Mortal:New(self.Groups.RED.Ambush1)--:InitRetreat("WP:_retreat")
    local mortalRecon = DCAF.Mortal:New(self.Groups.RED.Recon1)--:InitRetreat("WP:_retreat")

    local function getBadlyDamaged(group)
        local lowLife = 99999
        local lowLifeUnit
        for _, unit in ipairs(group:GetUnits()) do
            local life = unit:GetLife()
            if life < lowLife then
                lowLife = life
                lowLifeUnit = unit
            end
        end
        return lowLifeUnit
    end

    local function mopUp(group, targetSpeedKnots) -- destroys most badly damaged units until convoy is making target speed
        local iterate
        local function _iterate(delay)
            group._mopUpSchedulerID = DCAF.delay(function()
                if group:GetVelocityKNOTS() >= targetSpeedKnots then return end
                local badlyDamaged = getBadlyDamaged(group)
                if not badlyDamaged then return end
                badlyDamaged:Explode(300)
                iterate(math.random(40,70))
            end, delay)
        end
        iterate = _iterate
        iterate(0)
    end

    local function cptBennetRTB()
        -- todo (despawn one HMMWV and respawn it to return to original location)
        -- local humvee = getUnit("Peacock BLU Rear-HMMWV-1")
        -- if not humvee or not humvee:IsAlive() then
        --     humvee = getUnit("Peacock BLU Rear-HMMWV-2")
        -- end
        -- if not humvee then return end
        -- local coord = humvee:GetCoordinate()
        -- if not coord then return end
        -- local hdg = UNIT:GetHeading()
        -- local spawn = getSpawn(self.Groups.BLU.Rear)
        -- self._recon1_start_coordinate
    end

    local function ambushDefeated()
        Debug(_name .. " RED ambush defeated")
        if infantry._isDefeated then return end
        infantry._isDefeated = true
        local targetSpeedKnots = 16
        DCAF.delay(function()
            local isSlowCenter = self.Groups.BLU.Center:GetVelocityKNOTS() < targetSpeedKnots
            local isSlowRear = self.Groups.BLU.Rear:GetVelocityKNOTS() < targetSpeedKnots
            cptBennetRTB()
            if isSlowCenter or isSlowRear then
                self:SendRecon1(Peacock.MSG.Recon1.AmbushDefeatedMoppingUp)
                if isSlowCenter then mopUp(self.Groups.BLU.Center, 16) end
                if isSlowRear then mopUp(self.Groups.BLU.Rear, 16) end
            else
                self:SendRecon1(Peacock.MSG.Recon1.AmbushDefeated)
            end
        end, 60)
    end

    -- ambush mortality/retreat behavior
    function mortalInfantry:OnBreaks()
        ambushDefeated()
        infantry:SetAIOff()
        mortalRecon:Break()
        mortalVehicles:Break()
    end

    local function requestSuppression()
        Debug(_name .. ":SpringRedAmbush_requestSuppression")
        if Peacock._isSuppressionRequested then return end
        Peacock._isSuppressionRequested = true
        Peacock:SendRecon1(Peacock.MSG.Recon1.AmbushBegin)
        DCAF.delay(function()
            Peacock.Groups.RED.Ambush2:GetCoordinate():SmokeRed()
-- nisse - debug killing ambush infantry...
local hog = getGroup("111 TEST Hog-3")
if hog then hog:Activate() end
        end, 30)
        pcall(function() self:OnRequestSuppression() end)
    end

    local timeout = UTILS.SecondsOfToday() + Minutes(4)
    infantry._scheduleID = DCAF.startScheduler(function()
        if not Peacock._isSuppressionRequested then return end
        local function infantryMortal()
            Debug(_name .. " RED ambush infantry is now mortal")
            infantry:UnHandleEvent(EVENTS.Shot)
            DCAF.stopScheduler(infantry._scheduleID)
            infantry:CommandSetImmortal(false)
        end

        if UTILS.SecondsOfToday() > timeout then
            infantryMortal()
        else
            local aircraft = ScanAirborneUnits(infantry, NauticalMiles(1.5), Coalition.Blue, true)
            if aircraft:Any() then
                infantryMortal()
            end
        end
    end, 3)

    -- BLU requests...
    infantry:HandleEvent(EVENTS.Shot, function(_, e)
        -- make infantry immortal until air attacks them...
-- Debug(_name .. " RED ambush/EVENTS.Shot :: e: " .. DumpPretty(e))
        if e.IniGroup ~= infantry then return end
        Debug(_name .. " RED ambush begins")
        DCAF.delay(function()
            requestSuppression()
        end, 5)
    end)
    DCAF.delay(function()
        -- fallback (seems relying on EVENTs aren't a 100% sure way to get here)
        Debug(_name .. " requests suppression after timeout")
        requestSuppression()
    end, 20)
end

function Peacock:OnRequestSuppression()
end

function Peacock:StartREDHelicopters()
    self.Groups.RED.Helicopters:Activate()
end

function Peacock:LeaveHighway()
    self:SendRecon2(self.MSG.Recon2.LeavingHighway)
end

function Peacock:CautionHelicopters()
    self:SendRecon2(self.MSG.Recon2.CautionHelicopters)
end

function Peacock:RedHelicoptersAttack()
    self.Groups.RED.Helicopters:SetTask(CONTROLLABLE:TaskAttackGroup(self.Groups.BLU.Center))
end

function Peacock:StartREDArmor()
    local armor = self.Groups.RED.Armor:SetAIOn()
    self.AmbushArmor:Reveal()
    DCAF.delay(function()
        -- monitor hits to armor
        local mortal = DCAF.Mortal:New(armor)
        function mortal:OnLoss(countLoss)
            if countLoss == 1 then
                Peacock:SendRecon2(Peacock.MSG.Recon2.RedArmorGoodHit)
            end
        end
        function mortal:OnBreaks()
            if armor:IsAlive() then
                armor:OptionROEHoldFire()
                DCAF.delay(function()
                    armor:RouteStop()
                    DCAF.delay(function()
                        armor:SetAIOff()
                    end, 5)
                end, 5)
                DCAF.delay(function()
                    Peacock:SendRecon2(Peacock.MSG.Recon2.RedArmorBreaks)
                end, 40)
            else
                DCAF.delay(function()
                    Peacock:SendRecon2(Peacock.MSG.Recon2.RedArmorBreaks)
                end, 40)
            end
        end
    end, 1)
    DCAF.delay(function()
        self:SendRecon2(self.MSG.Recon2.RedArmor)
-- nisse - debug killing armor...
local hog = getGroup("111 TEST Hog-2")
if hog then hog:Activate() end
    end, 60)
end

function Peacock:Success()
    self:SendRecon2(self.MSG.Recon2.Success)
end

-- //////////////////// GM Menu ////////////////////

Peacock._menuStart = Peacock:GetGM_Menu():AddCommand("Start", function()
    Peacock:Start()
end)

function Peacock:AddGMMenusAfterStart()
    
end

-- ///////////////////   Add All Groups To Map   ///////////////////
Peacock:ActivateAndLobotomizeGroups()

Trace("////////// Story_Peacock was loaded //////////")
