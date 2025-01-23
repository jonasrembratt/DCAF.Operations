local _name = "ShatteredConvoy"
local _displayName = "Shattered Convoy"

ShatteredConvoy = DCAF.Story:New(_name)
if not ShatteredConvoy then return Error(_name .. " :: could not create story") end

ShatteredConvoy.Groups = {
    BLU = {
        SomeAgentGroup = getGroup("someAgent")
    },
    RED = {
    },
    CIV = SET_GROUP:New():FilterPrefixes(_name.." CIV"):FilterOnce()
}

local cs = {
    natoCenter = "Sentinel",
    callSign_A = "callSign-A",
    callSign_B = "callSign-B",
}

local tts_NATO_Center = DCAF.TTSChannel:New(cs.natoCenter, FREQ.NATO_Center)

ShatteredConvoy.Messages = {
    Start = "This is [CALLSIGN]. This is the start of the story ".._name..". Please design appropriate introductory message"
}

function ShatteredConvoy:OnStarted()
    if self._started then return end
    self._started = true
    self._menuStart:Remove(false)
    self:Send(TTS_Top_Dog, self.Messages.Start)
    self:WhenIn2DRange(NauticalMiles(16), function() self:OnFlightArrive() end)
    self:Activate(self.Groups.CIV)
end

function ShatteredConvoy:OnFlightArrive()
    -- maybe send some instructions so we can start playing?...
end

do  -- ||||||||||||||||||||||||||||||||||||    GM Menus    ||||||||||||||||||||||||||||||||||||

function ShatteredConvoy:BlueWins(resolution)
    self:End()
    self:DebugMessage(_name.." :: BLU WINS")
end

function ShatteredConvoy:RedWins()
    self:End()
    self:DebugMessage(_name.." :: RED WINS", 40)
end

ShatteredConvoy:AddStartMenu()
ShatteredConvoy:EnableSyntheticController(tts_NATO_Center, true)
ShatteredConvoy:EnableAssignFlight()

end

Trace("\\\\\\\\\\ ShatteredConvoy.lua was loaded //////////")