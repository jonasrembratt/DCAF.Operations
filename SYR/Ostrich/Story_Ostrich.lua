Ostrich = DCAF.Story:New("Ostrich")
Ostrich.HQLocation = DCAF.Location.Resolve("Ostrich STC HQ")
Ostrich.Patrol = getGroup("Ostrich Scout Patrol-1")
Ostrich.BattalionAreaName = "Maskanah"
Ostrich.RedScout = getGroup("Ostrich STC Scout Patrol-1")
Ostrich.GBAD = {
    Gauntlet = getGroup("Ostrich STC Gauntlet"),
    Gaskin = getGroup("Ostrich STC Gaskin"),
    AAA = getGroup("Ostrich STC AAA"),
    MANPADS = getGroup("Ostrich STC MANPADS")
}
Ostrich.MSG = {
    TopDog = {
        RelayReconSpotting =
            "[CALLSIGN]. We have report from Jackal p[91], scouting south of " .. Ostrich.BattalionAreaName .. "." ..
            "They have spotted multiple enemy patrols in that area so we need sensors there to see what is going on. " ..
            "Area is be[Ostrich Scout Patrol-1]. Repeat. Request airborn sensors to scout area for hostile ground "..
            "activities around be[Ostrich Scout Patrol-1]"
    }
}
Ostrich.TriggerDistance = NauticalMiles(12)

if not Ostrich then return end

function Ostrich:OnStarted()
    self:ActivateGroups()
    self:MonitorHostilesApproaching()
end

function Ostrich:ActivateGroups()
    local set = SET_GROUP:New():FilterCoalitions({"red"}):FilterPrefixes(self.Name):FilterOnce()
    local groups = {}
    set:ForEachGroup(function(group)
        if not group:IsActive() then
            groups[#groups+1] = group
        end
    end)

    activateGroupsStaggered(groups, nil, function(_, group)
        Debug(self.Name .. ":Start :: activates group: " .. group.GroupName)
        if string.find(group.GroupName, " STC ") then
            DCAF.delay(function()
                Debug(self.Name .. ":Start :: lobotomizes group: " .. group.GroupName)
                group:SetAIOff()
            end, 1)
        end
    end)
end

function Ostrich:MonitorHostilesApproaching()
    self._schedulerID = DCAF.startScheduler(function()
        local nearbyUnits = ScanAirborneUnits(self.HQLocation, self.TriggerDistance, Coalition.Blue, true)
        if not nearbyUnits:Any() then return end
        DCAF.stopScheduler(self._schedulerID)
        self:TriggerDefenses()
    end, 5)
end

function Ostrich:TriggerDefenses()
    Debug(self.Name .. ":TriggerDefenses")
    self:Activate_AAA()
    self:Activate_MANPADS()
    -- DCAF.delay(function()
        self:Activate_Gaskin()
    -- end, Minutes(5))
end

function Ostrich:Activate_Gaskin()
    if self.GBAD.Gaskin._is_active then return end
    self.GBAD.Gaskin._is_active = true
    self.GBAD.Gaskin:SetAIOn()
    Debug(self.Name .. ":Activate_Gaskin :: SA-9 Gaskin was AI-activated")
    self.GBAD.Gaskin:HandleEvent(EVENTS.Hit, function(_, e)
        if e.TgtGroupName ~= self.GBAD.Gaskin.GroupName then return end
        Ostrich.GBAD.Gaskin:UnHandleEvent(EVENTS.Hit)
        Ostrich:Activate_Gauntlet()
    end)
end

function Ostrich:Activate_Gauntlet()
    if self.GBAD.Gauntlet._is_active then return end
    self.GBAD.Gauntlet._is_active = true
    self.GBAD.Gauntlet:SetAIOn()
    Debug(self.Name .. ":Activate_Gauntlet :: SA-15 Gauntlet was AI-activated")
end

function Ostrich:Activate_AAA()
    if self.GBAD.AAA._is_active then return end
    self.GBAD.AAA._is_active = true
    self.GBAD.AAA:SetAIOn()
    Debug(self.Name .. ":Activate_AAA :: All AAA units were AI-activated")
end

function Ostrich:Activate_MANPADS()
    if self.GBAD.MANPADS._is_active then return end
    self.GBAD.MANPADS._is_active = true
    self.GBAD.MANPADS:SetAIOn()
    Debug(self.Name .. ":Activate_MANPADS :: All MANPADS units were AI-activated")
end

function Ostrich:GetGM_Menu()
    if not self.GM_Menu then
        self.GM_Menu = GM_Menu:AddMenu(string.upper(self.Name))
    end
    return self.GM_Menu
end

function Ostrich:InitTopDog(ttsTopDog, receiverAgency)
    if not isClass(ttsTopDog, DCAF.TTSChannel) then
        return Error(self.Name .. ":InitTopDog :: `ttsTopDog` must be " .. DCAF.TTSChannel.ClassName .. ", but was: "..DumpPretty(ttsTopDog), self)
    end
    if receiverAgency ~= nil and not isAssignedString(receiverAgency) then
        return Error(self.Name .. ":InitTopDog :: `receiverAgency` must be assigned string, but was: "..DumpPretty(receiverAgency) .. " :: IGNORES")
    end
    self.TTS_TopDog = ttsTopDog
    self.TTS_ReceiverAgency = receiverAgency
    local menu = self:GetGM_Menu()
    self.menu_recon_message =  menu:AddCommand("Send JACKAL 9-1 report", function()
        self.menu_recon_message:Remove(true)
        self:SendTopDog(self.MSG.TopDog.RelayReconSpotting)
    end)
end

function Ostrich:SendTopDog(msg)
    if not self.TTS_TopDog then return Error(self.Name .. ":SendTopDog :: Top Dog (TTS) has not been initialized") end
    if not isAssignedString(msg) then return Error(self.Name .. ":SendTopDog :: `msg` must be assigned string, but was: " .. DumpPretty(msg)) end
    if self.TTS_ReceiverAgency then
        msg = self.TTS_ReceiverAgency .. ". " .. msg
    end
    self.TTS_TopDog:Send(msg .. ". [CALLSIGN] out.")
end