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

local _codeword = "Robin"
Robin = {
    Name = _codeword,
    Groups = {
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
        },
    },
    PatrolsSpeed = 40, -- Km/h
    MSG = {

    },
    Vec3Sources = {
        Random_1 = getZoneVec3("Robin ZN RND-1"),
        Random_2 = getZoneVec3("Robin ZN RND-2"),
        Random_3 = getZoneVec3("Robin ZN RND-3"),
        Random_4 = getZoneVec3("Robin ZN RND-4"),
        Random_5 = getZoneVec3("Robin ZN RND-5"),
    },
    Vec3 = {
        ["Random_1"] = {
            ["y"] = 348.73226928711,
            ["x"] = 108099.5234375,
            ["z"] = 192300.65625,
          },
          ["Random_5"] = {
            ["y"] = 348.74346923828,
            ["x"] = 97637.5703125,
            ["z"] = 193569.46875,
          },
          ["Random_3"] = {
            ["y"] = 339.03994750977,
            ["x"] = 104035.4609375,
            ["z"] = 197327.5,
          },
          ["Random_2"] = {
            ["y"] = 348.73742675781,
            ["x"] = 102657.5546875,
            ["z"] = 191891.5625,
          },
          ["Random_4"] = {
            ["y"] = 345.40322875977,
            ["x"] = 99722.0078125,
            ["z"] = 198754.078125,
          }
    }
}

local countVec3Sources = dictCount(Robin.Vec3Sources)
local countVec3 = dictCount(Robin.Vec3)
if countVec3Sources > 0 and countVec3Sources ~= countVec3 then
    -- we have no Vec3s at this point; generate from ZONE sources so we can just copy/paste into the file (remove all Battle.Vec3 items to re-generate)
    Robin.Vec3 = Robin.Vec3Sources
    Debug("|||||||||||||||||||||||||||||||||||||| " .. _codeword .. " Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Robin.Vec3Sources, 2))
    error(_codeword .. " please re-inject Vec3s into the story")
end

function Robin:Start(tts)
    if self._is_started then return end
    self._is_started = true
    --Robin._start_menu:Remove(true)
    self.TTS = tts
    self:_activateStaggered(10,
        self.Groups.RED.AAA,
        self.Groups.RED.Logistics_1,
        self.Groups.RED.Logistics_2,
        self.Groups.RED.MechInf_1,
        self.Groups.RED.Tents_1,
        self.Groups.RED.Tents_2)
    self:_activateStaggeredRandomLocation(10,
        self.Groups.RED.IFV_1,
        self.Groups.RED.IFV_2,
        self.Groups.RED.MBT_1)
end

function Robin:Send(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:Send(msg)
    return self
end

function Robin:SendActual(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:SendActual(msg)
    return self
end

function Robin:_activateAtRandomLocation(group)
    local spawn = getSpawn(group.GroupName)
    if not spawn then return Error("Robin:_activateAtRandomLocation :: cannot resolve SPAWN from: " .. group.GroupName) end
    self._randomStartLocations = self._randomStartLocations or {}
    local randomVec3Key = dictRandomKey(self.Vec3)
    local retry = 5
    while self._randomStartLocations[randomVec3Key] and retry > 0 do
        randomVec3Key = dictRandomKey(self.Vec3)
        retry = retry - 1
    end
    self._randomStartLocations[randomVec3Key] = true
    local randomVec3 = self.Vec3[randomVec3Key]
    local group = spawn:SpawnFromVec3(randomVec3)
    randomVec3 = self.Vec3[dictRandomKey(self.Vec3)]
    group:RouteGroundOnRoad(COORDINATE:NewFromVec3(randomVec3), self.PatrolsSpeed)
    self:_randomReroute(group)
    return self
end

--- Reroutes group to a different random location
function Robin:_randomReroute(group)
    local delay = math.random(10, 30) -- minutes
    DCAF.delay(function()
        local coord = group:GetCoordinate()
        if not coord then return end
        local randomVec3 = self.Vec3[dictRandomKey(self.Vec3)]
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

function Robin:_activateStaggered(interval, ...)
    local delay = 0
    for i = 1, #arg, 1 do
        local group = arg[i]
        DCAF.delay(function()
            group:Activate()
        end, delay)
        delay = delay + interval
    end
end

function Robin:_activateStaggeredRandomLocation(interval, ...)
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
