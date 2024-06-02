--[[//////////////////////////////////////////////////////////////////////////////////
    # OSPREY
                                       
    Eight miles north of Tabqa dam lies the town of Mahmudli. There is a large Kurdish refugee camp there, run by SDF and UN,
    and a small military outpost as well, guarding the road into Tabqa area from the north.

    The regional 'Militia' (replace with whatever suits the overarching plotline) attacks the outpost and attempts capturing the town.

    ## UNITS
    Unit Count: 99
    
    ### Required Modules:
    
    - SAM Sites Asset Pack

    ### Script Files:
    - MOOSE.lua
    - DCAF.Core.lua
    - DCAF.Story.lua
    - DCAF.GM_Menu.lua (optional)
    - DCAF.TTSChannel.lua (optional)
    - DCAF.MobileDefense.lua (optional)
   
    ## Story Mechanic / Starting
    Invoking the :Start function will activate all initial units at their starting location but nothing will happen until:

    - GM manually sends CAS request from GM menu
    - BLU air gets within a specified range of a *Militia* convoy sitting up north (default = 12nm; can be initialized with :InitTriggerRangeConvoy)

    If the GM manually sends a CAS report the *Militia* attack on the Outpost will commence witin 4-7 minutes.
    If BLU air comes within the specified range from the *Militia* convoy
    
    North of the story focal area a small *Militia* convoy is stationary 
]]

if not DCAF.Story then return Error("Story/Osprey cannot start because DCAF.Story is not loaded") end
local _name = "Osprey"
Osprey = DCAF.Story:New(_name)
if not Osprey then return end
local _refPoint = _name .. " REF"
local _target = "Mahmudli refugee camp"
Osprey.TriggerRangeConvoy = NauticalMiles(12)
Osprey.MSG = {
    TopDog = {
        CASRequest =
            "[CALLSIGN] relaying emergency request from UN commander at the ".._target..". Fifteen mikes ago the outpost reported hostile troop movements "..
            "in the treeline north of their position and they are now taking small arms fire from that position. This might be the start of a larger attack on the camp. "..
            "Request immediate air support for ".._target.." at kp[".._refPoint.."]. Repeat. Request air support at kp[".._refPoint.."]",
        IncomingMortar =
            "[CALLSIGN] with an update from ".._target..". The camp outpost is now taking mortar fire from the neighboring village to the north. "..
            "The local commander request we find and destroy the mortar position before it can target the refugee camp. "..
            "Request SCAR mission for kp[Osprey RED Mortar]. "..
            "Repeat. Request SCAR mission for kp[Osprey RED Mortar]. We really need that mortar position destroyed!"
    }
}
Osprey.FARPS = {
    Outpost = AIRBASE:FindByName("Osprey FARP")
}
Osprey.Groups = {
    BLU = {
        Outpost_1 = getGroup(Osprey.Name .. " Outpost-1"),
        Outpost_2 = getGroup(Osprey.Name .. " Outpost-2"),
        Outpost_3 = getGroup(Osprey.Name .. " Outpost-3"),
    },
    RED = {
        FootMobiles = getGroup(Osprey.Name .. " RED FootMobiles"),
        Mortar_Guns = getGroup(Osprey.Name .. " RED Mortar"),
        Mortar_Crew_1 = getGroup(Osprey.Name .. " RED Mortar-Crew-1"),
        Mortar_Crew_2 = getGroup(Osprey.Name .. " RED Mortar-Crew-2"),
        Mortar_Crew_3 = getGroup(Osprey.Name .. " RED Mortar-Crew-3"),
        Mortar_Crew_4 = getGroup(Osprey.Name .. " RED Mortar-Crew-4"),
        Mortar_Vehicles = getGroup(Osprey.Name .. " RED Mortar-Vehicles"),
        MechInf_Center_1 = getGroup(Osprey.Name .. " RED MechInf-Center-1"),
        MechInf_Center_2 = getGroup(Osprey.Name .. " RED MechInf-Center-2"),
        MechInf_Flank_1 = getGroup(Osprey.Name .. " RED Flank-1"),
        Convoy = getGroup(Osprey.Name .. " RED Convoy")
    },
    TEST = {
        MortarRetreat = getGroup("Osprey TEST Mortar Retreat")
    }
}
Osprey.Flags = {
    RedMortarRetreat = "osprey_mortar_retreat",
    RedCenter_1 = "osprey_red_center_1",
    RedCenter_2 = "osprey_red_center_2",
    RedFlank = "osprey_red_flank",
}

function Osprey:InitTriggerRangeConvoy(range)
    if isNumber(range) and range > 0 then
        self.TriggerRangeConvoy = range
    end
    return self
end

function Osprey:OnStarted()
    self:ActivateInitial()
    self:TriggerConvoyBegin()

end

function Osprey:ActivateInitial()
    self.Groups.BLU.Outpost_1:Activate()
    self.Groups.BLU.Outpost_2:Activate()
    self.Groups.BLU.Outpost_3:Activate()
    self.Groups.RED.MechInf_Center_1:Activate()
    self.Groups.RED.MechInf_Center_2:Activate()
    self.Groups.RED.MechInf_Flank_1:Activate()
    return self
end

function Osprey:TriggerConvoyBegin()
    self._monitorConvoyID = DCAF.startScheduler(function()
        local nearbyUnits = ScanAirborneUnits(self.Name .. " RED Convoy", self.TriggerRangeConvoy, Coalition.Blue, true)
        if nearbyUnits:Any() then
            Osprey:StartConvoy()
            return
        end
    end, 5)
    return self
end

function Osprey:TriggerConvoyEnd()
    if not self._monitorConvoyID then return end
    pcall(function()
        DCAF.stopScheduler(self._monitorConvoyID)
    end)
    self._monitorConvoyID = nil
end

function Osprey:StartConvoy(startAttack)
    local convoy = self.Groups.RED.Convoy
    if not convoy then return Error(self.Name .. ":StartConvoy :: convoy group was nil") end
    convoy:Activate()
    if DCAF.MobileDefence then
        DCAF.MobileDefence:New(convoy, 2, self.Name .. " RED MANPADS")
    end
    self:TriggerConvoyEnd()
    if not isBoolean(startAttack) then startAttack = true end
Debug("nisse - " .. self.Name .. ":StartConvoy :: startAttack: " .. Dump(startAttack) .. " :: ._is_attack_started: " .. Dump(self._is_attack_started))

    if startAttack and not self._is_attack_started then
        local delay = math.random(5, 15)
        Debug(self.Name .. ":StartConvoy :: will send CAS request in: " .. delay .. " mikes")
        DCAF.delay(function()
            Osprey:SendCasRequestMessage()
        end, Minutes(delay))
        DCAF.delay(function()
            Osprey:BeginAttack()
        end, Minutes(delay + 3))
    end
end

function Osprey:BeginAttack( mortarInterval, mechInfAttackDelay )
    if self._is_attack_started then return end
    self._is_attack_started = true
    self:RedFootMobilesAttack()
    self:RedMortarAttack( mortarInterval )
    self:SendCasRequestMessage()
    if not isNumber(mechInfAttackDelay) then mechInfAttackDelay = Minutes(5) end
    DCAF.delay(function()
        Osprey:MechInfAttack()
    end, mechInfAttackDelay)
    return self
end

function Osprey:RedMortarAttack( mortarInterval )
    local endTime = UTILS.SecondsOfToday() + Minutes(10)
    self.Groups.RED.Mortar_Guns:Activate()
    self.Groups.RED.Mortar_Crew_1:Activate()
    self.Groups.RED.Mortar_Crew_2:Activate()
    self.Groups.RED.Mortar_Crew_3:Activate()
    self.Groups.RED.Mortar_Crew_4:Activate()
    self.Groups.RED.Mortar_Vehicles:Activate()

    local mortar = self.Groups.RED.Mortar_Guns
    if not mortar then return Error(self.Name .. ":RedMortarAttack :: RED mortar group was nil", self) end
    local salvoCount = #mortar:GetUnits()
    if not isNumber(mortarInterval) then mortarInterval = 60 end
    if not mortar then return end
    local vec2tgt = self.Groups.BLU.Outpost_3:GetUnit(1):GetCoordinate():GetVec2()
    Debug(Osprey.Name .. ":BeginAttack :: salvoCount: " .. salvoCount .. " :: mortarInterval: " .. mortarInterval)
    self._mortarSchedulerID = DCAF.startScheduler(function()
        mortar:SetTask(mortar:TaskFireAtPoint( vec2tgt, Feet(400), salvoCount, nil, 50 ))
        if UTILS.SecondsOfToday() > endTime then
            DCAF.stopScheduler(self._mortarSchedulerID)
        end
    end, mortarInterval)
    mortar:HandleEvent(EVENTS.Hit, function(_, e)
        if e.TgtGroup == mortar then
            Debug(Osprey.Name .. ":BeginAttack :: RED mortar was hit")
            Osprey:RedMortarRetreat()
            mortar:UnHandleEvent(EVENTS.Hit)
        end
    end)
    DCAF.delay(function()
        Osprey:SendIncomingMortarMessage()
    end, Minutes(2))
    return self
end

function Osprey:RedFootMobilesAttack()
    if self._is_red_foot_mobiles_attacking then return end
    self._is_red_foot_mobiles_attacking = true
    self.Groups.RED.FootMobiles:Activate()
    return self
end

function Osprey:RedMortarRetreat()
    Debug(Osprey.Name .. ":BeginAttack :: RED mortar crew abandons guns")
    SetFlag(self.Flags.RedMortarRetreat)
    DCAF.stopScheduler(self._mortarSchedulerID)
    self:_onMortarRetreats()
    return self
end

function Osprey:_onMortarRetreats()
    if not self._onMortarRetreatsFuncs then return end
    for _, func in ipairs(self._onMortarRetreatsFuncs) do
        pcall(func)
    end
end

function Osprey:OnMortarRetreats(func)
    if not isFunction(func) then return Error(self.Name .. ":OnMortarRetreats :: `func` must be function, but was: " .. DumpPretty(func)) end
    self._onMortarRetreatsFuncs = self._onMortarRetreatsFuncs or {}
    self._onMortarRetreatsFuncs[#self._onMortarRetreatsFuncs+1] = func
    return self
end

function Osprey:_onCasRequestSent()
    if not self._onCasRequestSentFuncs then return end
    for _, func in ipairs(self._onCasRequestSentFuncs) do
        pcall(func)
    end
end

function Osprey:OnCasRequestSent(func)
    if not isFunction(func) then return Error(self.Name .. ":OnCasRequestSent :: `func` must be function, but was: " .. DumpPretty(func)) end
    self._onCasRequestSentFuncs = self._onCasRequestSentFuncs or {}
    self._onCasRequestSentFuncs[#self._onCasRequestSentFuncs+1] = func
    return self
end

function Osprey:MechInfAttack()
    Debug(Osprey.Name .. ":MechInfAttack :: RED mech-inf center 1 attacks")
    SetFlag(self.Flags.RedCenter_1)
    DCAF.delay(function()
        Debug(Osprey.Name .. ":MechInfAttack :: RED mech-inf center 2 attacks")
        SetFlag(self.Flags.RedCenter_2)
    end, 30)
    DCAF.delay(function()
        Debug(Osprey.Name .. ":MechInfAttack :: RED mech-inf flank attacks")
        SetFlag(self.Flags.RedFlank)
    end, Minutes(3))
end

function Osprey:CenterAttackOutpost()
    local center_1 = self.Groups.RED.MechInf_Center_1
    if center_1 then 
        local coordCenter_1 = self.FARPS.Outpost:GetCoordinate():Translate(50, 135)
        center_1:RouteGroundOnRoad(coordCenter_1, 40)
    end

    local center_2 = self.Groups.RED.MechInf_Center_2
    if center_2 then 
        local coordCenter_2 = self.FARPS.Outpost:GetCoordinate():Translate(50, 225)
        center_2:RouteGroundOnRoad(coordCenter_2, 40)
    end
end

function Osprey:GetGM_Menu()
    if not self.GM_Menu and GM_Menu then
        self.GM_Menu = GM_Menu:AddMenu(string.upper(self.Name))
    end
    return self.GM_Menu
end

function Osprey:InitTTS(ttsTopDog, receiverAgency, addMenu)
    if not isClass(ttsTopDog, DCAF.TTSChannel) then
        return Error(self.Name .. ":InitTTS :: `ttsTopDog` must be " .. DCAF.TTSChannel.ClassName .. ", but was: "..DumpPretty(ttsTopDog), self)
    end
    if receiverAgency ~= nil and not isAssignedString(receiverAgency) then
        return Error(self.Name .. ":InitTTS :: `receiverAgency` must be assigned string, but was: "..DumpPretty(receiverAgency) .. " :: IGNORES")
    end
    self.TTS_TopDog = ttsTopDog
    self.TTS_ReceiverAgency = receiverAgency
    local menu
    if addMenu == true then
        menu = self:GetGM_Menu()
        if not menu then
            return Error(self.Name .. ":InitTTS :: failed to create '" .. self.Name .. "' GM menu", self)
        else
            self.menu_cas_request = menu:AddCommand("Send CAS request (begins attack)", function()
                Osprey:SendCasRequestMessage()
            end)
        end
    end
    return self
end

function Osprey:SendCasRequestMessage()
    if self._is_cas_request_sent then return end
    self._is_cas_request_sent = true
    if self.menu_cas_request then
        self.menu_cas_request:Remove(true)
        self.menu_cas_request = nil
    end
    self:SendTopDog(self.MSG.TopDog.CASRequest)
    self:StartConvoy(false)
    self:RedFootMobilesAttack()
    self:_onCasRequestSent()
    if not self._is_attack_started then
        local delay = math.random(4, 7)
        Debug(self.Name .. ":SendCasRequestMessage :: will begin attack in " .. delay .. " mikes")
        DCAF.delay(function()
            Osprey:BeginAttack()
        end, Minutes(delay))
    end
end

function Osprey:SendIncomingMortarMessage()
    self:SendTopDog(self.MSG.TopDog.IncomingMortar)
end

function Osprey:SendTopDog(msg)
    if not self.TTS_TopDog then return Error(self.Name .. ":SendTopDog :: Top Dog (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendTopDog :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_ReceiverAgency then
        msg = self.TTS_ReceiverAgency .. ". " .. msg
    end
    self.TTS_TopDog:Send(msg .. ". [CALLSIGN] out.")
end

function Osprey:Test_MortarRetreat()
    local testGroup = self.Groups.TEST.MortarRetreat:Activate()
    self:OnMortarRetreats(function()
        testGroup:Destroy()
    end)
end


Trace([[\\\\\\\\\\ Story :: Osprey.lua was loaded //////////]])
