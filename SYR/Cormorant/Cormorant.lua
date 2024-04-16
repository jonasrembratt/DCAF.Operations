-- ///////////////////////////////////////↓\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--                                    CORMORANT
--                                    *********
-- Syrian Army dispatches a freight train with infantry and supplies to reinforce position
-- near Al Tabqa. Harriers are tasked with intercepting and disabling the train.

-- TODO
-- Configure messages to be sent on start, death, etc.
--

-- ///////////////////////////////////////↓\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--                                     CONFIG
--                                     ******
local _codeword = "CORMORANT"
local _recipient = "FOCUS"
local _msr1 = "the railroad south of lake Buhayrat Al Asad, from Aleppo to Al Tabqa"
local _destination = "the Artillery emplacement at Tabqa"
local _offloadDelay = Minutes(30)
Cormorant = {
    Name = _codeword,
    Groups = {
        BLU = {
        },
        RED = {
            Convoy = getGroup("Cormorant Convoy-1"),
            SHORAD = {}
        },
    },
    MSG = {
        Start =
            _recipient .. ", [CALLSIGN]. New mission, codename: " .. _codeword .. ". . [CALLSIGN] out.",
        MissionFailed =
            _recipient .. ", [CALLSIGN], . [CALLSIGN] out.",
        ConvoyDestroyed =
            _recipient .. ", [CALLSIGN], mission " .. _codeword .. ": . [CALLSIGN] out.",
        Cormorant_Urgent =
            _recipient .. ", [CALLSIGN], update on " .. _codeword .. ". . [CALLSIGN] out."
    }
}

Debug("sausage :: dump Cormorant.Groups.RED.SHORAD: " .. DumpPrettyDeep(Cormorant.Groups.RED.Convoy, 3))
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\↑///////////////////////////////////////////////

function Cormorant:addSHORAD()
    for i = 1, 8, 1 do
        self.Groups.RED.SHORAD[i] = getGroup("Cormorant SHORAD-" .. i)
    end
end

Cormorant:addSHORAD()

function Cormorant:Start(tts)
    if self._is_started then return end
    self._is_started = true
    self._start_menu:Remove(true)
    self.TTS = tts
    self:addSHORAD()
    self.Groups.RED.Convoy:Activate()
    for _, group in pairs(self.Groups.RED.SHORAD) do
        group:Activate()
    end
    self:Send(self.MSG.Start)
    self:ConvoyAlive()
end

function Cormorant:Send(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:Send(msg)
end

function Cormorant:SendActual(msg)
    if not self.TTS or not isAssignedString(msg) then return end
    self.TTS:SendActual(msg)
end

function Cormorant:MissionFailed()
    self:Send(self.MSG.MissionFailed)
end

function Cormorant:Urgent()
    self:Send(self.MSG.Cormorant_Urgent)
    -- self.Groups.BLU.A10:Activate()
end

function Cormorant:ConvoyDestroyed()
    self:Send(self.MSG.ConvoyDestroyed)
end

function Cormorant:Offload()
    local convoy = self.Groups.RED.Convoy
    if convoy and not convoy:IsActive() then return end
    self.Groups.RED.Convoy:SetAIOff()
    self._offLoadSchedulerID = DCAF.startScheduler(function()
    if convoy and convoy:IsAlive() then
            convoy:SetAIOn()
        end
    end, _offloadDelay)
end

function Cormorant:ConvoyAlive()
    self._checkLifeSchedulerID = DCAF.startScheduler(function()
        local convoy = self.Groups.RED.Convoy
        local degradeRatio = 0.6
        if convoy and not convoy:IsActive() then return end
        local ratio = convoy:GetSize() / convoy:GetInitialSize()
        if ratio <= degradeRatio then
            self:ConvoyDestroyed()
            DCAF.stopScheduler(self._checkLifeSchedulerID)
            convoy:SetAIOff()
        end
    end, 30)
end

function Cormorant:CAS_Request()
    local units = self.Groups.RED.Convoy:GetUnits()
    local killUnits = math.floor(#units * 1)
    for i = 1, killUnits, 1 do
        local unit = self.Groups.RED.Convoy:GetUnit(i)
        unit:Explode(500, 2)
    end
    self._CAS_menu:Remove(true)
end

Cormorant._main_menu = GM_Menu:AddMenu(_codeword)
Cormorant._start_menu = Cormorant._main_menu:AddCommand("Start", function()
    local tts
    if DCAF.TTSChannel then tts = DCAF.TTSChannel:New() end
    Cormorant:Start(tts)
end)
Cormorant._CAS_menu = Cormorant._main_menu:AddCommand("Request CAS", function()
    Cormorant:CAS_Request()
end)

Trace("\\\\\\\\\\ Story :: Cormorant.lua was loaded //////////")