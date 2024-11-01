Trace([[////////// Loads: Story_Ostrich_M9.lua... //////////"]])

local _name = "Ostrich"
Ostrich_M9 = DCAF.Story:New(_name)
if not Ostrich_M9 then return Error("Could not create Story: " .. _name) end
Ostrich_M9.Location_DibsiAfnan = DCAF.Location.Resolve("Ostrich STC Trucks-6")
Ostrich_M9.Patrol = getGroup("Ostrich Scout Patrol-1")
Ostrich_M9.BattalionAreaName = "Maskanah"
Ostrich_M9.GBAD = {
        AAA_1 = getGroup("Ostrich STC AAA HQ"),
        MANPADS_1 = getGroup("Ostrich STC MANPADS HQ"),
        Shilka = getGroup("Ostrich STC Shilka HQ"),
        Gaskin_1 = getGroup("Ostrich STC Gaskin HQ"),
        AAA_2 = getGroup("Ostrich STC AAA North"),
        MANPADS_2 = getGroup("Ostrich STC MANPADS North"),
        AAA_3 = getGroup("Ostrich STC AAA East"),
        MANPADS_3 = getGroup("Ostrich STC MANPADS East"),
        Gaskin_2 = getGroup("Ostrich STC Gaskin East")
    -- Gauntlet = getGroup("Ostrich STC Gauntlet"),
}

Ostrich_M9.MSG = {
    TopDog = {
        -- RelayReconSpotting =
        --     "[CALLSIGN]. We have report from Jackal p[91], scouting south of " .. Ostrich_M9.BattalionAreaName .. "." ..
        --     "They have spotted multiple enemy patrols in that area so we need sensors there to see what is going on. " ..
        --     "Area is be[Ostrich Scout Patrol-1]. Repeat. Request airborn sensors to scout area for hostile ground "..
        --     "activities around be[Ostrich Scout Patrol-1]"
    }
}
Ostrich_M9.TriggerDistanceGBAD = NauticalMiles(3)
-- Ostrich_M9.TriggerDistanceCouriers = NauticalMiles(15)

function Ostrich_M9:OnStarted()
    Debug(self.Name .. ":OnStarted...")
    self:ActivateGroups()
    self:MonitorHostilesWakeGBAD()
    -- self:MonitorHostilesWakeCouriers()
end

function Ostrich_M9:ActivateGroups()
    local set = SET_GROUP:New():FilterCoalitions({"red"}):FilterPrefixes(self.Name):FilterOnce()
    self._lobotomize = {}
    set:ForEachGroup(function(group)
        group:Activate()
        Debug(self.Name .. ":ActivateGroups :: activates group: " .. group.GroupName)
        if string.find(group.GroupName, " STC ") then
            self._lobotomize[#self._lobotomize+1] = group
        end
    end)
    DCAF.delay(function()
        for _, group in ipairs(self._lobotomize) do
            Debug(self.Name .. ":ActivateGroups :: lobotomizes group: " .. group.GroupName)
            group:SetAIOff()
        end
    end, 1)
end

function Ostrich_M9:Attack()
    for _, group in ipairs(self._lobotomize) do
        group:SetAIOn()
    end
end

function Ostrich_M9:MonitorHostilesWakeGBAD()
    local function monitorAndWake(location, listGroups, name)
        self._monitorGBAD[name] = DCAF.startScheduler(function()
            local nearbyUnits = ScanAirborneUnits(location, self.TriggerDistanceGBAD, Coalition.Blue, true)
            if not nearbyUnits:Any() then return end
            Debug(self.Name .. ":MonitorHostilesWakeGBAD :: wakes up air defenses: " .. name)
            Ostrich_M9:WakeGroups(listGroups, true)
            -- Ostrich_M9:Wake_Gauntlet()
            DCAF.stopScheduler(self._monitorGBAD[name])
        end, 5)
    end

    self._monitorGBAD = {}
    monitorAndWake(self.Name .. " STC Shilka HQ", Ostrich_M9.GBAD, "BATTALION")
    -- monitorAndWake(self.Name .. " STC MANPADS North", Ostrich_M9.GBAD.North, "NORTH")
    -- monitorAndWake(self.Name .. " STC MANPADS East", Ostrich_M9.GBAD.East, "EAST")
end

-- function Ostrich_M9:MonitorHostilesWakeCouriers()
--     local function wakeCouriers()
--         local set = SET_GROUP:New():FilterCoalitions({"red"}):FilterPrefixes(self.Name .. " STC Courier"):FilterOnce()
--         local groups = {}
--         set:ForEachGroup(function(group)
--             groups[#groups+1] = group
--         end)
--         local delay = 0
--         local group, idx = listRandomItem(groups)
--         local queue = { group }
--         while group do
--             DCAF.delay(function()
--                 local g = queue[1]
--                 if not g then return end
--                 table.remove(queue, 1)
--                 Debug(Ostrich_M9.Name .. ":MonitorHostilesWakeCouriers :: wakes up " .. g.GroupName)
--                 g:SetAIOn()
--             end, delay)
--             table.remove(groups, idx)
--             if #groups > 0 then
--                 group, idx = listRandomItem(groups)
--                 delay = delay + math.random(Minutes(1), Minutes(5))
--                 queue[#queue+1] = group
--             else
--                 group = nil
--             end
--         end
--     end

--     self._monitorCouriersID = DCAF.startScheduler(function()
--         local nearbyUnits = ScanAirborneUnits(self.Name .. " STC Gauntlet", self.TriggerDistanceCouriers, Coalition.Blue, true)
--         if nearbyUnits:Any() then
--             wakeCouriers()
--             DCAF.stopScheduler(self._monitorCouriersID)
--         return end
--     end, 5)
-- end

function Ostrich_M9:WakeGroups(listGroups, value)
    for _, group in pairs(listGroups) do
        Debug(self.Name .. ":WakeGroups :: group: " .. group.GroupName)
        group:SetAIOnOff(value)
    end
end

-- function Ostrich_M9:Wake_Gauntlet()
--     if self.GBAD.Gauntlet._is_active then return end
--     self.GBAD.Gauntlet._is_active = true
--     self.GBAD.Gauntlet:SetAIOn()
--     Debug(self.Name .. ":Wake_Gauntlet :: SA-15 Gauntlet was AI-activated")
-- end

function Ostrich_M9:GetGM_Menu()
    if not self.GM_Menu then
        self.GM_Menu = GM_Menu:AddMenu(string.upper(self.Name))
    end
    return self.GM_Menu
end

function Ostrich_M9:InitTopDog(ttsTopDog, receiverAgency)
    if not isClass(ttsTopDog, DCAF.TTSChannel) then
        return Error(self.Name .. ":InitTopDog :: `ttsTopDog` must be " .. DCAF.TTSChannel.ClassName .. ", but was: "..DumpPretty(ttsTopDog), self)
    end
    if receiverAgency ~= nil and not isAssignedString(receiverAgency) then
        return Error(self.Name .. ":InitTopDog :: `receiverAgency` must be assigned string, but was: "..DumpPretty(receiverAgency) .. " :: IGNORES")
    end
    self.TTS_TopDog = ttsTopDog
    self.TTS_ReceiverAgency = receiverAgency
    local menu = self:GetGM_Menu()
    self.menu_recon_message =  menu:AddCommand("Start", function()
        self.menu_recon_message:Remove(true)
        -- self:SendTopDog(self.MSG.TopDog.RelayReconSpotting)
    end)
end

function Ostrich_M9:SendTopDog(msg)
    if not self.TTS_TopDog then return Error(self.Name .. ":SendTopDog :: Top Dog (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name ..
        ":SendTopDog :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_ReceiverAgency then
        msg = self.TTS_ReceiverAgency .. ". " .. msg
    end
    self.TTS_TopDog:Send(msg .. ". [CALLSIGN] out.")
end

Ostrich_M9._startMenu = Ostrich_M9:GetGM_Menu():AddCommand("Attack", function()
    Ostrich_M9:Attack()
end)

Trace([[////////// Story_Ostrich_M9.lua was loaded //////////"]])
