TTS_Top_Dog = nil

if DCAF.TTSChannel then
    local frequency
    local modulation
        if Freq then
        frequency = Freq.TopDog
        modulation = FreqMod.TopDog
    end
    TTS_Top_Dog = DCAF.TTSChannel:New("TOP DOG", frequency or 243, modulation or "AM")
Debug("nisse - TTS_Top_Dog: " .. DumpPretty(TTS_Top_Dog))
end

Trace("\\\\\\\\\\ TopDog.lua was loaded //////////")
