Finch = DCAF.Story:New("Finch")
if not Finch then return end -- just to keep the stupid Lua plugin happy

local _names = {
    OwnRecon = "JACKAL p[91]",
    Recon = "Finch Recon-1",
    Arty = "Finch Arty-1",
}

Finch.Groups = {
    Recon = getGroup(_names.Recon, 1),
    Logistics = getGroup("Finch Logistics-1", 2),
    SHORAD = getGroup("Finch SHORAD-1", 3),
    Arty = getGroup(_names.Arty, 4),
}
Finch.MSG = {
    AlertRecon =
        "[IDO], [CALLSIGN]. Relaying report from ".._names.OwnRecon..". An enemy reconnaissance unit has been spotted kp[".._names.Recon.."] "..
        "Unit is platoon strength on rural road parallel to highway, heading south east. Repeat. Enemy reconnaissance platoon in kp[".._names.Recon.."]",
    AlertArty =
        "[IDO], [CALLSIGN]. ".._names.OwnRecon.." is reporting enemy artillery on the move. kp[".. _names.Arty .. "] Company strength. "..
        "Convoy is heading south east on rural road west of highway. Repeat. Enemy artillery company heading toward Tabqa area. kp[" .. _names.Arty .. "]",

}

function Finch:InitMobileDefence(manpadsPattern)
    self._mobileDefence_manpadsPattern = manpadsPattern
    return self
end

function Finch:InitTopDog(tts)
Debug("nisse - Finch:InitTopDog :: tts: " .. DumpPretty(tts))
    self._topDog = tts
    return self
end

function Finch:SendTopDog(msg)
Debug("nisse - Finch:SendTopDog :: ._topDog: " .. DumpPretty(self._topDog))
    if self._topDog and isAssignedString(msg) then
        self._topDog:Send(msg .. ". [CALLSIGN] out")
    end
    return self
end

function Finch:OnStarted()
    if self._menu then self._menu:Remove(true) end
    self:ActivateStaggered(self.Groups, 5, true, function(_, group)
        if self._mobileDefence_manpadsPattern then
            DCAF.MobileDefence:New(group, 1, self._mobileDefence_manpadsPattern)
        end
    end)
end

function Finch:SendAlertRecon()
Debug("nisse - Finch:SendAlertRecon...")
    self:SendTopDog(self.MSG.AlertRecon)
end

function Finch:SendAlertArty()
    self:SendTopDog(self.MSG.AlertArty)
end

function Finch:AddMenu()
    self._menu = GM_Menu:AddMenu(self.Name)
    self._menu:AddCommand("Start", function()
        self:Start()
    end)
end

Trace("\\\\\\\\\\ Story_Finch.lua was loaded //////////")
