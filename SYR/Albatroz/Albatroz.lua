-- //////////////////////////////////////////////////////////////////////////////////
--                                    ALBATROZ
--                                    ********
-- Syrian motor convoy departs to _site for emergency repairs of _targetVehicleType
-- revealing the location of _maintenanceBuilding for a future Strike package if
-- if located within _revealDeadline.

local _codeword = "Albatroz"
local _ido = "FOCUS"
local _gridStart = "p[LL XX]"
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
        Start = _ido .. "[CALLSIGN], ",
        MissionFailed = _ido .. "[CALLSIGN], ",
        ConvoyDestroyed = _ido .. "[CALLSIGN], ",
        Albatroz_Urgent = _ido .. "[CALLSIGN], ",
    }
}

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
