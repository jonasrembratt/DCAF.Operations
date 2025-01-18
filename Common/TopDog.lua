TTS_Top_Dog = nil

if DCAF.TTSChannel then
    local frequency = DCAF.Frequency:Get("guard")
    TTS_Top_Dog = DCAF.TTSChannel:New("TOP DOG", frequency)
Debug("nisse - TTS_Top_Dog: " .. DumpPretty(TTS_Top_Dog))
end

Trace("\\\\\\\\\\ TopDog.lua was loaded //////////")
