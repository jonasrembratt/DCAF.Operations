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
        Valkyrie = getGroup(_name .. " Valkyrie 1"),
        Valkyrie2 = getGroup(_name .. " Valkyrie 2"),
        Goblin = getGroup(_name .. " Goblin"),
    },
    RED = {
        Convoy = getGroup(_name .. " Connvoy"),
        Checkpoint = getGroup(_name .. " Checkpoint 1"),
        Checkpoint2 = getGroup(_name .. " Checkpoint 2"),
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
        ["z"] = -6874.693359375,
        ["x"] = 111354.1484375,
        ["y"] = 36.771984100342,
    },
    Ambush = {
        ["z"] = 7971.3984375,
        ["x"] = 130168.2421875,
        ["y"] = 130.80070495605,
    },
    Ambush_2 = {
        ["z"] = 4499.6591796875,
        ["x"] = 124127.6875,
        ["y"] = 60.641513824463,
    },
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

if not Birman.Vec3.Ambush then
    Birman.Vec3.Ambush = ZONE:New(_name .. " Late"):GetCoordinate()
    Debug("|||||||||||||||||||||||||||||||||||||| " ..
        _name .. " Ambush Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Birman.Vec3.Ambush, 2))
    Trace(_name .. " please re-inject Vec3 into the story")
end

if not Birman.Vec3.Ambush_2 then
    Birman.Vec3.Ambush_2 = ZONE:New(_name .. " Early"):GetCoordinate()
    Debug("|||||||||||||||||||||||||||||||||||||| " ..
        _name .. " Ambush 2 Vec3 ||||||||||||||||||||||||||||||||||||||")
    Debug(DumpPrettyDeep(Birman.Vec3.Ambush_2, 2))
    Trace(_name .. " please re-inject Vec3 above into the story")
end

function Birman:OnStarted()
    -- self:StartConvoy()
    self.Groups.BLU.Valkyrie:Activate()
    self.Groups.BLU.Valkyrie2:Activate()
    self:StartCivilianTruck()
    self:StartFenris2()
    self._start_menu:Remove()
    Birman._spectre_menu = Birman._main_menu:AddCommand("Spectre Drift", function()
        -- Debug("sausage --> " .. Birman.Codewords.SpectreDrift)
        Birman:SpectreDrift()
    end)
    Birman._graveyard_menu = Birman._main_menu:AddCommand("Graveyard Shift", function()
        Birman:GraveyardShift()
    end)
end

function Birman:SpectreDrift()
    Birman._graveyard_menu:Remove()
    self._SpectreDriftFlag = true
    local convoy = Birman.Groups.RED.Convoy
    local fenris = Birman.Groups.BLU.Fenris_2
    local coord = COORDINATE:NewFromVec3(Birman.Vec3.ConvoyDestination)
    local pumpkin = COORDINATE:NewFromVec3(Birman.Vec3.PumpkinPatch)
    convoy:RouteGroundOnRoad(coord, 80)
    DCAF.delay(function()
        fenris:RouteGroundOnRoad(pumpkin, 60)
    end, 30)
    DCAF.delay(function()
        fenris:RouteGroundOnRoad(coord, 131)
    end, Minutes(2))
    self._spectre_menu:Remove()
    Birman._convoy_ambush2_menu = Birman._main_menu:AddCommand("Ambush early", function()
        Birman:Ambush2()
        Birman._convoy_ambush_menu = Birman._main_menu:AddCommand("Ambush late", function()
            Birman:Ambush()
        end)
        Birman._graveyard_menu = Birman._main_menu:AddCommand("Graveyard Shift", function()
            Birman:GraveyardShift()
        end)
    end)
end

function Birman:Ambush()
    local convoy = Birman.Groups.RED.Convoy
    local fenris = Birman.Groups.BLU.Fenris_2
    local coord = COORDINATE:NewFromVec3(Birman.Vec3.Ambush)
    convoy:RouteGroundOnRoad(coord, 80)
    fenris:RouteGroundOnRoad(coord, 131)
    self._convoy_ambush_menu:Remove()
end

function Birman:Ambush2()
    local convoy = Birman.Groups.RED.Convoy
    local fenris = Birman.Groups.BLU.Fenris_2
    local coord = COORDINATE:NewFromVec3(Birman.Vec3.Ambush_2)
    convoy:RouteGroundOnRoad(coord, 80)
    fenris:RouteGroundOnRoad(coord, 131)
    self._convoy_ambush2_menu:Remove()
end

function Birman:GraveyardShift()
    local fenris = self.Groups.BLU.Fenris_2
    local coord = COORDINATE:NewFromVec3(self.Vec3.PumpkinPatch)
    local evac = COORDINATE:NewFromVec3(self.Vec3.GraveyardShift)
    if not self._SpectreDriftFlag then
        fenris:RouteGroundOnRoad(coord, 100)
    end
    DCAF.delay(function()
        fenris:RouteGroundOnRoad(evac, 131)
    end, Minutes(2))
    self._graveyard_menu:Remove()
    self._convoy_ambush2_menu:Remove()
    self._convoy_ambush_menu:Remove()
    self._engage_checkpoint = self._main_menu:AddCommand("Angry Apache", function()
        SetFlag("_valkyrie2_engage")
        Birman._engage_checkpoint:Remove()
    end)
    Birman._heli_option = Birman._main_menu:AddCommand("Heli Proceed", function()
        SetFlag("_heli_continue")
        Birman._heli_option:Remove()
        Birman._goblin_menu = Birman._main_menu:AddCommand("Goblin Spawn", function()
            Birman.Groups.BLU.Goblin:Activate()
            Birman._goblin_menu:Remove()
        end)
    end)
    self.Groups.RED.Checkpoint:Activate()
    self.Groups.RED.Checkpoint2:Activate()
    self._stop_fenris_menu = self._main_menu:AddCommand("Fenris Hold", function()
        Birman:FenrisHold()
    end)
end

function Birman:FenrisHold()
    self.Groups.BLU.Fenris_2:RouteStop()
    Birman._resume_fenris_menu = Birman._main_menu:AddCommand("Fenris Resume", function()
        Birman:FenrisResume()
    end)
    self._stop_fenris_menu:Remove()
end

function Birman:FenrisResume()
    self.Groups.BLU.Fenris_2:RouteResume()
    Birman._stop_fenris_menu = Birman._main_menu:AddCommand("Fenris Hold", function()
        Birman:FenrisHold()
    end)
    self._resume_fenris_menu:Remove()
end

function Birman:TruckStrobeBegin()
    self._truckStrobe = DCAF.Lase:New(self.Groups.BLU.CivilianTruck, 1613):StartStrobe()
end

function Birman: StartCivilianTruck()
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
Birman._graveyars_shirtstart_menu = Birman._main_menu:AddCommand("Graveyard Shift", function()
    Birman:GraveyardShift()
end)




Trace("\\\\\\\\\\ " .. _name .. ".lua was loaded //////////")