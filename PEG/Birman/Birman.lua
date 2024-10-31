-- //////////////////////////////////////////////////////////////////////////////////
--                                     BIRMAN
--                                     ******
-------------------------------------------------------------------------------------
-- DEPENDENCIES
--   MOOSE
--   DCAF.Core
--   DCAF.Story
--   DCAF.GM_Menu
--   TopDog
-------------------------------------------------------------------------------------

local _name = "Birman"
local _words = {
    Start = ""
}

Birman = DCAF.Story:New(_name)
if not Birman then return Error(_name .. " :: cannot create story") end
Birman.Groups = {
    BLU = {
        CivilianTruck = getGroup(_name .. " Civ Truck")
    },
    RED = {
        Convoy = getGroup(_name .. " Connvoy")
    },
}
Birman.MSG = {
    TopDog = {
        Start = "[CALLSIGN]. Word is "
    },
}

Birman.Vec3 = {
    ConvoyDestination = {
        ["y"] = 0,
        ["x"] = 451676.28125,
        ["z"] = 72452.9140625,
    }
}

if not Birman.Vec3.ConvoyDestination then
    -- we have no Vec3s at this point; generate from ZONE sources so we can just copy/paste into the file (remove all Battle.Vec3 items to re-generate)
    Birman.Vec3.ConvoyDestination = ZONE:New(_name .. " Convoy Destination"):GetCoordinate()
    Debug("|||||||||||||||||||||||||||||||||||||| " .. _name .. " Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Birman.Vec3.ConvoyDestination, 2))
    error(_name .. " please re-inject Vec3s into the story")
end

function Birman:OnStarted()
    self:StartConvoy()
    DCAF.delay(function()
        self:StartCivilianTruck()
    end, Minutes(3))
end

function Birman:StartConvoy()
    local coord = COORDINATE:NewFromVec3(self.Vec3.ConvoyDestination)
    self.Groups.RED.Convoy:RouteGroundOnRoad(coord, 60)
end

function Birman:StartCivilianTruck()
    local coord = COORDINATE:NewFromVec3(self.Vec3.ConvoyDestination)
    self.Groups.BLU.CivilianTruck:RouteGroundOnRoad(coord, 70)
end

Birman._main_menu = GM_Menu:AddMenu(_name)
Birman._start_menu = Birman._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Birman:Start(tts)
end)

Trace("\\\\\\\\\\ " .. _name .. ".lua was loaded //////////")
