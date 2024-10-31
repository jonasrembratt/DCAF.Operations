local _name = "Mockingbird"
Mockingbird = DCAF.Story:New(_name)
if not Mockingbird then return end

Mockingbird.Groups = {
    RED = {
        DiversionWest = getGroup(_name .. " RED Diversion West"),
        DiversionEast = getGroup(_name .. " RED Diversion East"),
        Hidden_Fulcrums_West = getGroup(_name .. " RED Fulcrum Trap West"),
        Hidden_Fulcrums_South = getGroup(_name .. " RED Fulcrum Trap South"),
        Strikers_1 = getGroup(_name .. " RED Strikers-1"),
        Strikers_2 = getGroup(_name .. " RED Strikers-2"),
    }
}

function Mockingbird:GetGM_Menu()
    if not self.GM_Menu then
        self.GM_Menu = GM_Menu:AddMenu(string.upper(self.Name))
    end
    return self.GM_Menu
end

function Mockingbird:StartStrikers()
    self._menuStartStrikers:Remove(true)
    self.Groups.RED.Strikers_1:Activate()
    DCAF.delay(function()
        self.Groups.RED.Strikers_2:Activate()
    end, Minutes(2))
end

function Mockingbird:_activateHiddenFighters(hiddenGroup)
    local trap = hiddenGroup:Activate()
    if not trap then return end
    local bluUnits = ScanAirborneUnits(trap, NauticalMiles(20), Coalition.Blue, true)
    if not bluUnits:Any() then return end
    local info = bluUnits.Units[1]
    local bluGroup = info.Unit:GetGroup()
    trap:SetTask(CONTROLLABLE:TaskAttackGroup(bluGroup))
end

function Mockingbird:OnStarted()
    Debug("Mockingbird:OnStarted()")
    self:_setUpMenus()
    if self.Groups.RED.DiversionWest then
        self.Groups.RED.DiversionWest:Activate()
    end
    if self.Groups.RED.DiversionEast then
        self.Groups.RED.DiversionEast:Activate()
    end
end

function Mockingbird:_setUpMenus()
    Debug("Mockingbird:_setUpMenus()")
    local menuHiddenFighters = self:GetGM_Menu():AddMenu("Hidden Fighters")
    self._menuStartHiddenFulcrumsWest = menuHiddenFighters:AddCommand("West Group - Start", function()
        self:_activateHiddenFighters(self.Groups.RED.Hidden_Fulcrums_West)
        self._menuStartHiddenFulcrumsWest:Remove(true)
    end)
    self._menuStartHiddenFulcrumsSouth = menuHiddenFighters:AddCommand("South Group - Start", function()
        self:_activateHiddenFighters(self.Groups.RED.Hidden_Fulcrums_South)
        self._menuStartHiddenFulcrumsSouth:Remove(true)
    end)

    self._menuStartStrikers = self:GetGM_Menu():AddCommand("Strikers - Start", function()
        self:StartStrikers()
    end)
end

Mockingbird._menuStart = Mockingbird:GetGM_Menu():AddCommand("Start", function()
    Mockingbird:Start()
    Mockingbird._menuStart:Remove(false)
end)



