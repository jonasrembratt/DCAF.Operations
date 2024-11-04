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
    Start = "Trick Or Treat",
    Abort = "Coffin",
    Contingency = "Spectre Drift",
    Extraction = "Graveyard Shift",
}

Birman = DCAF.Story:New(_name)
if not Birman then return Error(_name .. " :: cannot create story") end
Birman.Groups = {
    BLU = {
        CivilianTruck = getGroup(_name .. " Civ Truck"),
        Fenris_2 = getGroup(_name .. " Fenris 2"),
        Fenris_2_1 = getGroup(_name .. " Fenris 2-1"),
        Fenris_6 = getGroup(_name .. " Fenris 6"),
        Valkyrie = getGroup(_name .. " Valkyrie 1")
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
        ["z"] = 72452.9140625,
        ["x"] = 451676.28125,
        ["y"] = 1749.884765625,
    },
    PumpkinPatch = {
        ["z"] = 3537.6611328125,
        ["x"] = 113407.671875,
        ["y"] = 24.104047775269,
    },
    GraveyardShift = {
        ["z"] = -6920.8745117188,
        ["x"] = 111281.171875,
        ["y"] = 37.869323730469,
    }
}
-- Birman.Codewords = {
--     TrickOrTreat = false,
--     GraveyardShift = false,
--     SpectreDrift = false,
--     Coffin = false,
-- }

if not Birman.Vec3.ConvoyDestination then
    -- we have no Vec3s at this point; generate from ZONE sources so we can just copy/paste into the file (remove all Battle.Vec3 items to re-generate)
    Birman.Vec3.ConvoyDestination = ZONE:New(_name .. " Convoy Destination"):GetCoordinate()
    Debug("|||||||||||||||||||||||||||||||||||||| " .. _name .. " Convoy Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Birman.Vec3.ConvoyDestination, 2))
    error(_name .. " please re-inject Vec3s into the story")
end

if not Birman.Vec3.PumpkinPatch then
    Birman.Vec3.PumpkinPatch = ZONE:New(_name .. " Pumpkin Patch"):GetCoordinate()
    Debug("|||||||||||||||||||||||||||||||||||||| " ..
    _name .. " Pumpkin Patch Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Birman.Vec3.PumpkinPatch, 2))
    error(_name .. " please re-inject Vec3 into the story")
end

if not Birman.Vec3.GraveyardShift then
    Birman.Vec3.GraveyardShift = ZONE:New(_name .. " Graveyard Shift"):GetCoordinate()
    Debug("|||||||||||||||||||||||||||||||||||||| " ..
        _name .. " Graveyard Shift Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Birman.Vec3.GraveyardShift, 2))
    error(_name .. " please re-inject Vec3 into the story")
end

function Birman:OnStarted()
    -- self:StartConvoy()
    self:StartCivilianTruck()
    self:StartFenris2()
end

function Birman:SpectreDrift()
    local convoy = Birman.Groups.RED.Convoy
    local fenris = Birman.Groups.BLU.Fenris_2
    local coord = COORDINATE:NewFromVec3(Birman.Vec3.ConvoyDestination)
    local pumpkin = COORDINATE:NewFromVec3(Birman.Vec3.PumpkinPatch)
    convoy:RouteGroundOnRoad(coord, 80)
    fenris:RouteGroundOnRoad(pumpkin, 40)
    DCAF.delay(function()
        fenris:RouteGroundOnRoad(coord, 80)
    end, Minutes(2))
end

function Birman:GraveyardShift()
    local fenris = self.Groups.BLU.Fenris_2
    local coord = COORDINATE:NewFromVec3(self.Vec3.GraveyardShift)
    fenris:RouteGroundOnRoad(coord, 100)
    self.Groups.BLU.Valkyrie:Activate()
end

function Birman:TruckStrobeBegin()
    self._truckStrobe = DCAF.Lase:New(self.Groups.BLU.CivilianTruck):StartStrobe()
end

function Birman:StartCivilianTruck()
    self.Groups.BLU.CivilianTruck:Activate()
end

function Birman:StartFenris2()
    self.Groups.BLU.Fenris_2:Activate()
end

Birman._main_menu = GM_Menu:AddMenu(_name)
Birman._start_menu = Birman._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Birman:Start(tts)
end)
Birman._spectre_menu = Birman._main_menu:AddCommand("Spectre Drift", function()
    -- Debug("sausage --> " .. Birman.Codewords.SpectreDrift)
    Birman:SpectreDrift()
end)
Birman._start_menu = Birman._main_menu:AddCommand("Graveyard Shift", function()
    Birman:GraveyardShift()
end)

Trace("\\\\\\\\\\ " .. _name .. ".lua was loaded //////////")