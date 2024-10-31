-- //////////////////////////////////////////////////////////////////////////////////
--                                     ROBIN
--                                     *****
-- Syria has positioned a mechanized battalion and is patrolling the surroundings. 
-- The battalion is protected from the air by one SA-9, one SA-19, as well as AAA. 
-- Story contains a ROZ for A-G players to perform SCAR
-------------------------------------------------------------------------------------
-- DEPENDENCIES
--   DCAF.Core
--   DCAF.GBAD
--   DCAF.GBAD.Regiment

local function getZoneVec3(zoneName)
    local zone = ZONE:FindByName(zoneName)
    if zone then return zone:GetCoordinate():GetVec3() end
end

Ragdoll = DCAF.Story:New("Robin")
if not Ragdoll then return end
Ragdoll.Groups = {
    RED = {
        Tents_1 = getGroup("Robin Tents-1"),
        Tents_2 = getGroup("Robin Tents-2"),
        Logistics_1 = getGroup("Robin Logistics-1"),
        Logistics_2 = getGroup("Robin Logistics-2"),
        AAA = getGroup("Robin AAA-1"),
        MechInf_1 = getGroup("Robin Mechinf-1"),
        IFV_1 = getGroup("Robin IFV-1"),
        IFV_2 = getGroup("Robin IFV-2"),
        MBT_1 = getGroup("Robin MBT-1"),
        MBT_2 = getGroup("Robin MBT-2"),
    },
}
Ragdoll.PatrolsSpeed = 40 -- Km/h
Ragdoll.Vec3SmokeSources = {
    Random_1 = getZoneVec3("Robin ZN RND-1"),
    Random_2 = getZoneVec3("Robin ZN RND-2"),
    Random_3 = getZoneVec3("Robin ZN RND-3"),
    Random_4 = getZoneVec3("Robin ZN RND-4"),
    Random_5 = getZoneVec3("Robin ZN RND-5"),
}
Ragdoll.Vec3Smokes = {
    ["Random_1"] = {
        ["y"] = 329.75576782227,
        ["x"] = 81052.3046875,
        ["z"] = 223218.96875
        },
    ["Random_5"] = {
        ["y"] = 343.42758178711,
        ["x"] = 74452.671875,
        ["z"] = 223261.421875
        },
    ["Random_3"] = {
        ["y"] = 328.97280883789,
        ["x"] = 77430.53125,
        ["z"] = 223516.9375
        },
    ["Random_2"] = {
        ["y"] = 300.82061767578,
        ["x"] = 79625.8203125,
        ["z"] = 225418.046875
        },
    ["Random_4"] = {
        ["y"] = 332.9111328125,
        ["x"] = 76987.3203125,
        ["z"] = 219587.15625
     }
}

local countVec3Sources = dictCount(Ragdoll.Vec3SmokeSources)
local countVec3 = dictCount(Ragdoll.Vec3Smokes)
if countVec3Sources > 0 and countVec3Sources ~= countVec3 then
    -- we have no Vec3s at this point; generate from ZONE sources so we can just copy/paste into the file (remove all Battle.Vec3 items to re-generate)
    Ragdoll.Vec3Smokes = Ragdoll.Vec3SmokeSources
    Debug("|||||||||||||||||||||||||||||||||||||| " .. Ragdoll.Name .. " Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Ragdoll.Vec3SmokeSources, 2))
    error(Ragdoll.Name .. " please re-inject Vec3s into the story")
end

function Ragdoll:OnStarted()
    if Ragdoll._start_menu then Ragdoll._start_menu:Remove(true) end
    DCAF.Story:ActivateStaggered({
        self.Groups.RED.AAA,
        self.Groups.RED.Logistics_1,
        self.Groups.RED.Logistics_2,
        self.Groups.RED.MechInf_1,
        self.Groups.RED.Tents_1,
        self.Groups.RED.Tents_2,
        self.Groups.RED.MBT_2
    }, 10)

    self:_activateStaggeredRandomLocation(10,
        self.Groups.RED.IFV_1,
        self.Groups.RED.IFV_2,
        self.Groups.RED.MBT_1)
end

function Ragdoll:_activateAtRandomLocation(group)
    local spawn = getSpawn(group.GroupName)
    if not spawn then return Error("Robin:_activateAtRandomLocation :: cannot resolve SPAWN from: " .. group.GroupName) end
    self._randomStartLocations = self._randomStartLocations or {}
    local randomVec3Key = dictRandomKey(self.Vec3Smokes)
    local retry = 5
    while self._randomStartLocations[randomVec3Key] and retry > 0 do
        randomVec3Key = dictRandomKey(self.Vec3Smokes)
        retry = retry - 1
    end
    self._randomStartLocations[randomVec3Key] = true
    local randomVec3 = self.Vec3Smokes[randomVec3Key]
    local group = spawn:SpawnFromVec3(randomVec3)
    randomVec3 = self.Vec3Smokes[dictRandomKey(self.Vec3Smokes)]
    group:RouteGroundOnRoad(COORDINATE:NewFromVec3(randomVec3), self.PatrolsSpeed)
    self:_randomReroute(group)
    return self
end

--- Reroutes group to a different random location
function Ragdoll:_randomReroute(group)
    local delay = math.random(10, 30) -- minutes
    DCAF.delay(function()
        local coord = group:GetCoordinate()
        if not coord then return end
        local randomVec3 = self.Vec3Smokes[dictRandomKey(self.Vec3Smokes)]
        local coordDestination = COORDINATE:NewFromVec3(randomVec3)
        local distance = coord:Get2DDistance(coordDestination)
        if distance < 10 then
            -- the random location is group's current location; just ignore and try again later
            self:_randomReroute(group)
            return
        end
        group:RouteGroundOnRoad(coordDestination, self.PatrolsSpeed)
        self:_randomReroute(group)
    end, Minutes(delay))
end

function Ragdoll:_activateStaggeredRandomLocation(interval, ...)
    local delay = 0
    for i = 1, #arg, 1 do
        local group = arg[i]
        DCAF.delay(function() self:_activateAtRandomLocation(group) end, delay)
        delay = delay + interval
    end
end

-- Robin._main_menu = GM_Menu:AddMenu(_codeword)
-- Robin._start_menu = Robin._main_menu:AddCommand("Start", function()
--     local tts
--     if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
--     Robin:Start(tts)
-- end)
-- Robin._CAS_menu = Robin._main_menu:AddCommand("Request CAS", function()
--     Robin:CAS_Request()
-- end)

Trace("\\\\\\\\\\ Story_Robin.lua was loaded //////////")
