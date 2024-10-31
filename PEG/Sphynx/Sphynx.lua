-- //////////////////////////////////////////////////////////////////////////////////
--                                     SPHYNX
--                                     ******
-------------------------------------------------------------------------------------
-- DEPENDENCIES
--   MOOSE
--   DCAF.Core
--   DCAF.Story
--   DCAF.GM_Menu

local _codeword = "Sphynx"

Sphynx = DCAF.Story:New(_codeword)
if not Sphynx then return end
Sphynx.SpawnGroupsIntervalMin = 60
Sphynx.SpawnGroupsIntervalMax = 180
Sphynx.SpawnUnitsInterval = 2
Sphynx.Groups = {
    BLU = {
        GroundTargets = getGroup(_codeword .. " BLU TGT")
    },
    RED = {
        -- UAVGroup1 = SET_GROUP:New():FilterPrefixes(_codeword .. " UAV-1"):FilterOnce()
    },
}



function Sphynx:OnStarted()
    if Sphynx._start_menu then Sphynx._start_menu:Remove(true) end
    self:StartUAV(3)
    DCAF.delay(function()
        self:StartUAV(1)
    end, math.random(self.SpawnGroupsIntervalMin, self.SpawnGroupsIntervalMax))
    DCAF.delay(function()
        self:StartUAV(2)
    end, math.random(self.SpawnGroupsIntervalMin, self.SpawnGroupsIntervalMax))
    self:SmokeAndFire()
end

function Sphynx:StartUAV(number)
    Debug(_codeword..":StartUAV: " .. number .. " :: SpawnUnitsInterval: " .. Dump(self.SpawnUnitsInterval))
    local set = SET_GROUP:New():FilterPrefixes(_codeword .. " UAV-" .. number):FilterOnce()
    local delay = self.SpawnUnitsInterval
    set:ForEachGroup(function(group)
        DCAF.delay(function()
            Debug(_codeword..":StartUAV :: activates " .. group.GroupName)
            group:Activate()
        end, delay)
        delay = delay + self.SpawnUnitsInterval
    end)
end

function Sphynx:SmokeAndFire()
    local dictUnitCoords = {}
    for _, unit in ipairs(self.Groups.BLU.GroundTargets:GetUnits()) do
        dictUnitCoords[unit.UnitName] = unit:GetCoordinate()
    end
Debug("nisse - ".._codeword..":SmokeAndFire :: dictUnitCoords: " .. DumpPretty(dictUnitCoords)) -- nisse

    BASE:New():HandleEvent(EVENTS.Hit, function(_, e)
Debug("nisse - ".._codeword..":SmokeAndFire :: HIT/e: " .. DumpPrettyDeep(e, 2)) -- nisse
        local coord = dictUnitCoords[e.TgtUnit.UnitName]
        if not coord then return end
        if math.random(100) < 51 then
            coord:BigSmokeSmall(math.random())
        else
            coord:BigSmokeAndFireSmall(math.random())
        end
    end)
end

Sphynx._main_menu = GM_Menu:AddMenu(_codeword)
Sphynx._start_menu = Sphynx._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Sphynx:Start(tts)
end)

Trace("\\\\\\\\\\ Sphynx.lua was loaded //////////")
