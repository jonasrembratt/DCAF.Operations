-- //////////////////////////////////////////////////////////////////////////////////
--                                    PHEASANT
--                                    ********
-- Syrian Army dispatches a freight train with infantry and supplies to reinforce position
-- near Al Tabqah. Harriers are tasked with intercepting and disabling the train.

-- TODO
-- More messages (top dog)'
-- Complete isEscortNearby function

local _codeword = "Pheasant"
local _weco = "Rapture"
local _msr1 = "the Al Bab, Manjib highway"
local _destination = "Kharab Ishk"
local Pheasant = {
    Name = _codeword,
    Groups = {
        BLU = {
        },
        RED = {
            Pheasant = getGroup("Pheasant Convoy-1")
        },
    },
    MSG = {
        Start =
            _weco .. ", [CALLSIGN]. New mission, codename: " .. _codeword .. ". We've received intel that a motor convoy carrying supplies and troops is driving along "
            .. _msr1 .. " towards " .. _destination .. ". Request retasking of Harriers to intercept and destroy A S A P. E T A of convoy at " ..
            _destination .. " is time plus one hour and fifteen. [CALLSIGN] out.",
        SCAR_Request =
            _weco .. "[CALLSIGN], [CALLSIGN] out.",
        MissionFailed =
            _weco ..
            "[CALLSIGN], mission " .. _codeword .. " has failed. The motor convoy has reached " .. _destination .. " and have succesfully "
            .. "resupplied and reinforced the forces there. [CALLSIGN] out.",
        MissionComplete =
            _weco .. "[CALLSIGN], mission " .. _codeword .. ": motor convoy succesfully destroyed, and enemy forces at "
            .. _destination .. " are severely weakened in their ability to maintain control of the base. Good work. [CALLSIGN] out.",
        Pheasant_Urgent =
            _weco .. "[CALLSIGN], update on " .. _codeword .. ". The motor convoy has just crossed the bridge north east of Manjib into the N F Z. Unless action is taken immediately, "
            .. "they are slated to arrive at " .. _destination .. " in .[CALLSIGN] out.",
    }
}

function Pheasant:Start(tts)
    if self._is_started then return end
    self._is_started = true
    Pheasant._start_menu:Remove(true)
    self.TTS = tts
    self.Groups.RED.Pheasant:Activate()
    self:Send(self.MSG.Start)
end

function Pheasant:Send(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:Send(msg)
end

function Pheasant:SendActual(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:SendActual(msg)
end

function Pheasant:MissionFailed()
    self:Send(self.MSG.MissionFailed)
end

function Pheasant:Urgent()
    self:Send(self.MSG.Pheasant_Urgent)
end

function Pheasant:MissionComplete()
    DCAF.startScheduler(function()
        if not self.Groups.RED.Pheasant:IsActive() then return end
        if not self.Groups.RED.Pheasant:IsAlive() then
            self:Send(self.MSG.MissionComplete)
        end
    end, Minutes(1))
end

Pheasant._main_menu = GM_Menu:AddMenu(_codeword)
Pheasant._start_menu = Pheasant._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Pheasant:Start(tts)
end)