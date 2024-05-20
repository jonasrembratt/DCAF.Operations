-- ///////////////////////////////////////↓\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--                                    CORMORANT
--                                    *********
-- Syrian Army dispatches a freight train with infantry and supplies to reinforce position
-- near Al Tabqa. Harriers are tasked with intercepting and disabling the train.

-- TODO
--
--

-- ///////////////////////////////////////↓\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--                                     CONFIG
--                                     ******
local _codeword = "CORMORANT"
local _recipient = "FOCUS"
local _msr1 = "the highway south of lake Buhayrat Al Asad, from Aleppo to Tabqa"
local _destination = "the Artillery emplacement at Tabqa"
local _offloadDelay = Minutes(30)
local _departurePoint = "Aleppo"
local setShorad = SET_GROUP:New():FilterCoalitions({coalition.side.RED}):FilterPrefix("Cormorant SHORAD-"):FilterOnce()

Cormorant = {
    Name = _codeword,
    Groups = {
        BLU = {
        },
        RED = {
            Convoy = getGroup("Cormorant Convoy-1"),
            SHORAD = SET_GROUP:New():FilterCoalitions({coalition.side.RED}):FilterPrefix("Cormorant SHORAD-"):FilterOnce()
        },
    },
    MSG = {
        Start =
            _recipient .. ", [CALLSIGN]. Priority mission, codename: " .. _codeword .. ". We've received intel that a motor convoy has just departed " ..
            _departurePoint .. " headed for " .. _destination .. " along " .. _msr1 .. ". [CALLSIGN] actual requests that you retask appropriate package" ..
            " to intercept and destroy. [CALLSIGN] out.",
        MissionFailed =
            _recipient .. ", [CALLSIGN], . [CALLSIGN] out.",
        ConvoyDestroyed =
            _recipient .. ", [CALLSIGN], mission " .. _codeword .. ": . [CALLSIGN] out.",
        Cormorant_Urgent =
            _recipient .. ", [CALLSIGN], update on " .. _codeword .. ". . [CALLSIGN] out."
    }
}

Debug("sausage :: dump Cormorant.Groups.RED.SHORAD: " .. DumpPretty(Cormorant.Groups.RED.Convoy))
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\↑///////////////////////////////////////////////

function Cormorant:Start(tts)
    if self._is_started then return end
    self._is_started = true
    if self._start_menu then self._start_menu:Remove(true) end
    self.TTS = tts
    self.Groups.RED.Convoy:Activate()

    -- self.Groups.RED.SHORAD:ForEachGroup(function(group)
    --     group:Activate()
    -- end)

    for i = 1, #self.Groups.RED.SHORAD.Set, 1 do
        if self.Groups.RED.SHORAD[i] then
            self.Groups.RED.SHORAD[i]:Activate()
        end
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
            DCAF.stopScheduler(self._offLoadSchedulerID)
        end
    end, _offloadDelay)
end

function Cormorant:ConvoyAlive()
    self._checkLifeSchedulerID = DCAF.startScheduler(function()
        local convoy = self.Groups.RED.Convoy
        local degradeRatio = 0.7
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
    local killUnits = math.floor(#units * 0.8)
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