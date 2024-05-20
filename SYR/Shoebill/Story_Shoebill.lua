--[[ ////////////////////////////////////↓\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                                     SHOEBILL
                                     ********
    A friendly helicopter carrying something important and a team of SpecOps
    but they get shot down near _nearestCity. A local warlord sends out a group
    to recover the valuable cargo, and BLU is tasked with taking out the group
    to prevent this. CAS support for the SpecOps team is also required as they
    are taken small arms fire from a nearby location.

]]

local _shoebillSmoke = false
local _codeword = "SHOEBILL"
local _recipient = "FOCUS"
local _nearestCity = "RAQQA"
Shoebill = {
    Name = _codeword,
    Groups = {
        BLU = {
            Chinook = getGroup("Shoebill_Chinook-1"),
            SpecOps = getGroup("Shoebill_SpecOps-2"),
            JTAC = getGroup("Shoebill_SpecOps-1"),
            SAR_Helo = getGroup("Shoebill_SAR-1"),
        },
        RED = {
            InsInf = getGroup("Shoebill_InsInf-1"),
            InsCon = getGroup("Shoebill_InsCon-1"),
        }
    },
    Flags = {
    },
    MSG = {
        Start =
        _recipient .. ", [CALLSIGN]. Priority mission.",
        RequestEscort =
            _recipient .. ", [CALLSIGN]. ",
            MissionComplete =
            _recipient .. ", [CALLSIGN]. ",
        GauntletActive =
            _recipient .. ", [CALLSIGN]. ",
        MissionAbortedNoEscort =
            _recipient .. ", [CALLSIGN]. ",
        MissionAbortedGauntletAwake =
            _recipient .. ", [CALLSIGN]. ",
        MissionAbortedManually =
            _recipient .. ", [CALLSIGN]. ",
    }
}

-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\↑///////////////////////////////////////////////

function Shoebill:Start(tts)
    if self._is_started then return end
    self._is_started = true
    if self._start_menu then self._start_menu:Remove(false) end
    self.TTS = tts
    _shoebillSmoke = true
    self.Groups.BLU.Chinook:Activate()
    self.Groups.BLU.Chinook:Explode(150, 2)
    self.Groups.BLU.Chinook:GetCoordinate():BigSmokeAndFire( 6, 1)
    self.Groups.BLU.SpecOps:Activate()
    self.Groups.BLU.JTAC:Activate()
    self.Groups.BLU.SAR_Helo:Activate()
    self.Groups.RED.InsCon:Activate()
    self.Groups.RED.InsInf:Activate()
    self:Send(self.MSG.Start)
end

function Shoebill:InitTTS(tts)
    self.TTS = tts
    return self
end

function Shoebill:Send(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:Send(msg)
end

function Shoebill:SendActual(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:SendActual(msg)
end

function Shoebill:MissionComplete()
    if self._rtb_menu then self._rtb_menu:Remove(true) end
    self:Send(self.MSG.MissionComplete)
end

Shoebill._main_menu = GM_Menu:AddMenu(_codeword)
Shoebill._start_menu = Shoebill._main_menu:AddCommand("Start", function()
    Shoebill:Start(TTS_Top_Dog)
end)

Trace("\\\\\\\\\\ Story :: SHOEBILL.lua was loaded //////////")
