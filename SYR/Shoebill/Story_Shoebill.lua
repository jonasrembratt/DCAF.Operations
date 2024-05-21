--[[ ////////////////////////////////////↓\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                                     SHOEBILL
                                     ********
    A friendly helicopter carrying something important and a team of SpecOps
    but they get shot down near _nearestCity. A local warlord sends out a group
    to recover the valuable cargo, and BLU is tasked with taking out the group
    to prevent this. CAS support for the SpecOps team is also required as they
    are taken small arms fire from a nearby location.

]]

local _codeword = "SHOEBILL"
local _recipient = "FOCUS"
local _nearestCity = "RAQQA"
local _JTAC_Frequency = "97.1"
local _JTAC_Callsign = "SHOEBILL"
local _heloType = "UH-60A"
local _destination = "Tabqa"

Shoebill = {
    Name = _codeword,
    Groups = {
        BLU = {
            Chinook = getGroup("Shoebill_Chinook-1"),
            SpecOps = getGroup("Shoebill_SpecOps-2"),
            JTAC = getGroup("Shoebill_SpecOps-1"),
            CSAR = getGroup("Shoebill_CSAR-1"),
            },
        RED = {
            InsInf = getGroup("Shoebill_InsInf-1"),
            InsCon = getGroup("Shoebill_InsCon-1"),
            InsReinforce = getGroup("Shoebill_InsReinforce-1")
        }
    },
    Flags = {
    },
    MSG = {
        Start =
        _recipient .. ", [CALLSIGN]. Priority mission. A " .. _heloType .. " has been shot down near the city of " .. _nearestCity .. " by unknown hostiles. " ..
        "The helicopter was carrying a Special Ops group bound for " .. _destination .. ". They are requesting immediate CAS support and exfil. Coordinate with local " ..
            "JTAC, callsign " ..
            _JTAC_Callsign .. ", on frequency, " .. _JTAC_Frequency .. ", before dispatching a Cesar mission.",
        CSAR =
        _recipient .. ", [CALLSIGN]. Cesar dispatched.",
        }
}

-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\↑///////////////////////////////////////////////

function Shoebill:Start(tts)
    if self._is_started then return end
    self._is_started = true
    if self._start_menu then self._start_menu:Remove(false) end
    self.TTS = tts
    self.Groups.BLU.Chinook:Activate()
    self.Groups.BLU.Chinook:Explode(150, 2)
    self.Groups.BLU.Chinook:GetCoordinate():BigSmokeAndFire( 6, 1)
    self.Groups.BLU.SpecOps:Activate()
    self.Groups.BLU.JTAC:Activate()
    DCAF.delay(function()
        self.Groups.BLU.JTAC:SetAIOff()
    end, .5)
    self.Groups.RED.InsCon:Activate()
    self.Groups.RED.InsInf:Activate()
    self:Send(self.MSG.Start)
end

function Shoebill:DisableImmortal()
    self.Groups.BLU.SpecOps:SetCommandImmortal(false)
    self.Groups.BLU.JTAC:SetCommandImmortal(false)
end

function Shoebill:ReinforcementsArrive()
    self.Groups.RED.InsReinforce:Activate()
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

function Shoebill:Recover()
    DCAF.delay(function()
        local jtac = self.Groups.BLU.JTAC:getGroup()
        local spec = self.Groups.BLU.SpecOps:getGroup()
        if jtac then
            jtac:Destroy(true, 2)
        end
        if spec then
            spec:Destroy(true, 2)
        end
    end, 30)
end

function Shoebill:MissionComplete()
end

function Shoebill:CSAR()
    DCAF.delay(function()
        self:Send(self.MSG.CSAR)
        self.Groups.BLU.CSAR:Activate()
        self._csar_menu:Remove(true)
    end, 10)
end

function Shoebill:DropBomb()
        local units = self.Groups.RED.InsInf:GetUnits()
        local killUnits = math.floor(#units * 1)
        for i = 1, killUnits, 1 do
            local unit = self.Groups.RED.InsInf:GetUnit(i)
            unit:Destroy()
        end
        self._boom_menu:Remove(true)
end

Shoebill._main_menu = GM_Menu:AddMenu(_codeword)
Shoebill._start_menu = Shoebill._main_menu:AddCommand("Start", function()
    Shoebill:Start(TTS_Top_Dog)
    Shoebill._boom_menu = Shoebill._main_menu:AddCommand("Boom", function()
        Shoebill:DropBomb()
    end)
    Shoebill._csar_menu = Shoebill._main_menu:AddCommand("CSAR", function()
        Shoebill:CSAR()
    end)
end)

Trace("\\\\\\\\\\ Story :: SHOEBILL.lua was loaded //////////")
