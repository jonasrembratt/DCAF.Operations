-- //////////////////////////////////////////////////////////////////////////////////
--                                     RAGDOLL
--                                     *******
-------------------------------------------------------------------------------------
-- DEPENDENCIES
--   MOOSE
--   DCAF.Core
--   DCAF.Story
--   DCAF.GM_Menu

local _codeword = "Ragdoll"
local _vec3smoke = _codeword .. " SMK"
local _zoneConvoyDestination = _codeword .. " Convoy Destination"

Ragdoll = DCAF.Story:New(_codeword)
if not Ragdoll then return end
Ragdoll.Groups = {
    RED = {
        Convoy = getGroup(_codeword .. " Convoy")
    },
}
Ragdoll.Vec3SmokeSources = SET_ZONE:New():FilterPrefixes(_vec3smoke):FilterOnce()

Ragdoll.Vec3Smokes = {
  [1] = {
    ["y"] = 5.8198065757751,
    ["x"] = 64607.53515625,
    ["z"] = -34615.9765625,
  },
  [2] = {
    ["y"] = 6.0734715461731,
    ["x"] = 64864.80078125,
    ["z"] = -34250.734375,
  },
  [3] = {
    ["y"] = 6.5270700454712,
    ["x"] = 65119.75390625,
    ["z"] = -34161.02734375,
  },
  [4] = {
    ["y"] = 5.9994692802429,
    ["x"] = 65148.546875,
    ["z"] = -34074.375,
  },
  [5] = {
    ["y"] = 5.9994692802429,
    ["x"] = 64764.16015625,
    ["z"] = -34414.4921875,
  },
  [6] = {
    ["y"] = 10.837698936462,
    ["x"] = 65857.4140625,
    ["z"] = -33109.87890625,
  },
  [7] = {
    ["y"] = 7.9368276596069,
    ["x"] = 65775.3125,
    ["z"] = -33155.48828125,
  },
  [8] = {
    ["y"] = 6.1586508750916,
    ["x"] = 64783.1796875,
    ["z"] = -34298.390625,
  },
  [9] = {
    ["y"] = 6.1714882850647,
    ["x"] = 64926.73046875,
    ["z"] = -34192.8125,
  },
  [10] = {
    ["y"] = 6.4492015838623,
    ["x"] = 65010.3203125,
    ["z"] = -34186.68359375,
  },
  [11] = {
    ["y"] = 7.34623670578,
    ["x"] = 65758.4765625,
    ["z"] = -32935.16015625,
  },
  [12] = {
    ["y"] = 6.7495608329773,
    ["x"] = 65723.390625,
    ["z"] = -33134.44140625,
  },
  [13] = {
    ["y"] = 10.844191551208,
    ["x"] = 65906.53125,
    ["z"] = -33039.7109375,
  },
  [14] = {
    ["y"] = 6.0481324195862,
    ["x"] = 65689.7421875,
    ["z"] = -33033.24609375,
  },
  [15] = {
    ["y"] = 5.9994692802429,
    ["x"] = 64704.37890625,
    ["z"] = -34506.1015625,
  }
}

Ragdoll.Vec3ConvoyDestination = {
  ["y"] = 5.4318480491638,
  ["x"] = 88167.0078125,
  ["z"] = -16395.119140625,
 }

-- local countVec3SmokeSources = dictCount(Ragdoll.Vec3SmokeSources.Set)
-- local countVec3Smokes = dictCount(Ragdoll.Vec3Smokes)
-- if countVec3SmokeSources > 0 and countVec3SmokeSources ~= countVec3Smokes then
--     -- we have no Vec3s at this point; generate from ZONE sources so we can just copy/paste into the file (remove all Battle.Vec3 items to re-generate)
--     local vec3 = {}
--     for _, zone in pairs(Ragdoll.Vec3SmokeSources.Set) do
--         vec3[#vec3+1] = zone:GetVec3()
--     end
--     Ragdoll.Vec3Smokes = vec3
--     Debug("|||||||||||||||||||||||||||||||||||||| " .. Ragdoll.Name .. " Vec3 ||||||||||||||||||||||||||||||||||||||")
--     Debug(DumpPrettyDeep(Ragdoll.Vec3Smokes, 2))
--     error(Ragdoll.Name .. " please re-inject Vec3s into the story")
-- end

local zoneConvoyDestination = ZONE:New(_zoneConvoyDestination):GetCoordinate()
-- if Ragdoll.Vec3ConvoyDestination == nil or Ragdoll.Vec3ConvoyDestination.x ~= zoneConvoyDestination.x or Ragdoll.Vec3ConvoyDestination.z ~= zoneConvoyDestination.z then
--     -- re-generate COORDINATE for convoy destination...
--     Debug("|||||||||||||||||||||||||||||||||||||| " .. Ragdoll.Name .. " Vec3 ||||||||||||||||||||||||||||||||||||||")
--     Debug(DumpPrettyDeep(zoneConvoyDestination:GetVec3(), 2))
--     error(Ragdoll.Name .. " please re-inject Vec3 for Convoy Destination into the story")
-- end


function Ragdoll:OnStarted()
    if Ragdoll._start_menu then Ragdoll._start_menu:Remove(true) end
    self:StartFires()
end

function Ragdoll:StartFires()
    local index = math.random(1, #self.Vec3Smokes)
    local vec3 = self.Vec3Smokes[index]
-- Debug("nisse - " .. self.Name .. ".StartFires :: index: " .. index .. " :: #self.Vec3: " .. #self.Vec3)
    COORDINATE:NewFromVec3(vec3):BigSmokeLarge(1)
    table.remove(self.Vec3Smokes, index)
-- Debug("nisse - " .. self.Name .. ".StartFires :: #self.Vec3: " .. #self.Vec3)
    if #self.Vec3Smokes == 0 then
        Debug(self.Name .. ".StartFires :: all fires started")
        return self
    end

    local nextFireTime = math.random(1, 20)
    Debug(self.Name .. ".StartFires :: index: " .. index .. " :: nextFireTime: " .. nextFireTime .. "s")
    DCAF.delay(function()
        self:StartFires()
    end, nextFireTime)
end

function Ragdoll:StartConvoy()
    Debug(_codeword .. ":StartConvoy...")
    local convoy = self.Groups.RED.Convoy
    local coord = COORDINATE:NewFromVec3(self.Vec3ConvoyDestination)
    convoy:RouteGroundOnRoad(coord, 40)
end

function Ragdoll:StartFiresOnDetectedHostileAir(distanceNm, ignoreAI)
    if not isNumber(distanceNm) then distanceNm = 50 end
    if not isBoolean(ignoreAI) then ignoreAI = true end
    Debug(_codeword .. ":StartFiresOnDetectedHostileAir :: distanceNm: " .. distanceNm .. " :: ignoreAI: " .. Dump(ignoreAI))
    local coord = COORDINATE:NewFromVec3(self.Vec3Smokes[1])
    self._firesSchedulerID = DCAF.startScheduler(function()
        local hostiles = ScanAirborneUnits(coord, NauticalMiles(distanceNm), Coalition.Blue, true, nil, nil, nil, ignoreAI)
        if not hostiles:Any() then return end
        Debug(_codeword .. ":StartFiresOnDetectedHostileAir :: BLU air detected - starts story")
        self:Start()
        DCAF.stopScheduler(self._firesSchedulerID)
        self._firesSchedulerID = nil
    end, 3)
end

function Ragdoll:StartConvoyOnNearbyHostileAir(distanceNm, ignoreAI)
    if not isNumber(distanceNm) then distanceNm = 15 end
    if not isBoolean(ignoreAI) then ignoreAI = true end
    Debug(_codeword .. ":StartConvoyOnNearbyHostileAir :: distanceNm: " .. distanceNm .. " :: ignoreAI: " .. Dump(ignoreAI))
    local coord = COORDINATE:NewFromVec3(self.Vec3Smokes[1])
    self._convoySchedulerID = DCAF.startScheduler(function()
        local hostiles = ScanAirborneUnits(coord, NauticalMiles(distanceNm), Coalition.Blue, true, nil, nil, nil, ignoreAI)
        if not hostiles:Any() then return end
        Debug(_codeword .. ":StartConvoyOnNearbyHostileAir :: BLU air nearby - starts convoy")
        self:StartConvoy()
        DCAF.stopScheduler(self._convoySchedulerID)
        self._convoySchedulerID = nil
    end, 3)
end

Ragdoll._main_menu = GM_Menu:AddMenu(_codeword)
Ragdoll._start_menu = Ragdoll._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Ragdoll:Start(tts)
end)

Trace("\\\\\\\\\\ Ragdoll.lua was loaded //////////")
