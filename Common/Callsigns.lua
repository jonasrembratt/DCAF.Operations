DCAF.Story.CallSign =
{
    Squadrons = {
        ["75th"] = {
            Names = {
                [1] = "Blackbird",
                [2] = "Condor",
                [3] = "Magpie",
            },
            Numbers = { 1, 2, 3, 4, 5 }
        },
        ["119th"] = {
            Names = {
                [1] = "Devil",
                [2] = "Hell",
                [3] = "Satan",
            },
            Numbers = { 1, 2, 3, 4, 5 }
        },
        ["335th"] = {
            Names = {
                [1] = "Chief",
                [2] = "Dallas",
                [3] = "Eagle",
            },
            Numbers = { 1, 2, 3, 4, 5 }
        },
    }
}

function DCAF.Story.CallSign:SelectFromGM_Menu(gm_mainMenu, funcDone, text)
    Debug("DCAF.Story.CallSign:SelectFromMenu")
    if not isAssignedString(text) then text = "Select Flight" end
    local menu = gm_mainMenu:AddMenu(text)
    for squadronName, squadronInfo in pairs(DCAF.Story.CallSign.Squadrons) do
        local squadronMenu = menu:AddMenu(squadronName)
        for _, name in ipairs(squadronInfo.Names) do
           local nameMenu = squadronMenu:AddMenu(name)
            for _, number in ipairs(squadronInfo.Numbers) do
                nameMenu:AddCommand(number, function()
                    local phoneticNumber = PhoneticAlphabet:ConvertNumber(number)
                    local callSign = name .. " " .. phoneticNumber
                    pcall(function()
                        funcDone(callSign)
                    end)
                end)
            end
        end
    end
    return menu
end

Trace("\\\\\\\\\\ DCAF.Story.Callsign.lua was loaded //////////")
