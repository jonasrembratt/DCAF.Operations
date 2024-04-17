-- //////////////////////////////////////////////////////////////////////////////////
--                                    ALBATROZ
--                                    ********
-- Syrian motor convoy departs to _destination for emergency repairs of _targetVehicleType
-- revealing the location of the vehicledepot for a future Strike package if located within _revealDeadline.
--
-- TODO
--   -
--
-- ///////////////////////////////////////↓\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--                                     CONFIG
--                                     ******

local function getZoneVec3(zoneName)
    local zone = ZONE:FindByName(zoneName)
    if zone then return zone:GetCoordinate():GetVec3() end
end

local _codeword = "Albatroz"
local _ido = "FOCUS"
local _vehicleDepotLocation = getZoneVec3("Albatroz Maintenance-1")
local _gridStart = "p[DV 17]"
local _msr1 = "[Descriptor]"
local _destination = "[Desto Name]"
Albatroz = {
    Name = _codeword,
    Groups = {
        BLU = {
        },
        RED = {
            Convoy = getGroup("Albatroz Convoy-1")
        },
    },
    MSG = {
        Start =
        _ido .. ", [CALLSIGN]. We've received intel that a Syrian motor convoy with supplies and technical staff is departing from " .. _gridStart .. ", headed to " ..
        _destination .. " to repair critical equipment there. [CALLSIGN] actual requests that you task appropriate flight packages to intercept " ..
        " and destroy the convoy. [CALLSIGN] out.",
        MissionFailed = _ido .. "[CALLSIGN], ",
        ConvoyDestroyed = _ido .. "[CALLSIGN], ",
        Albatroz_Urgent = _ido .. "[CALLSIGN], ",
    }
}

-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\↑///////////////////////////////////////////////

function Albatroz:Start(tts)
    if self._is_started then return end
    self._is_started = true
    self._start_menu:Remove(true)
    self.TTS = tts
    self.Groups.RED.Convoy:Activate()
    self:Send(self.MSG.Start)
    self:ConvoyAlive()
end



Albatroz._main_menu = GM_Menu:AddMenu(_codeword)
Albatroz._start_menu = Pheasant._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Albatroz:Start(tts)
end)
Trace("\\\\\\\\\\ Story :: Albatroz.lua was loaded //////////")
