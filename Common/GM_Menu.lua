Blue = coalition.side.BLUE

GM_Menu = {
    ClassName = "GM_Menu",
    ----   
}

function GM_Menu:New(text)
    if not isAssignedString(text) then text = "[GM ONLY!]" end
    GM_Menu._menu = MENU_COALITION:New(Blue, text)
    GM_Menu._path = text
    GM_Menu._subMenuCount = GM_Menu._subMenuCount or 0
    return GM_Menu
end

function GM_Menu:Ensure()
    if not GM_Menu._menu then GM_Menu:New() end
    return GM_Menu._menu
end

function GM_Menu:AddMenu(text)
    GM_Menu:Ensure()
    if self ~= GM_Menu then
        self._subMenuCount = self._subMenuCount or 0
        self._subMenuCount = self._subMenuCount + 1
    end
    local subMenu = DCAF.clone(GM_Menu)
    subMenu._menu = MENU_COALITION:New(Blue, text, self._menu)
    subMenu._path = self._path .. '/' .. text
    subMenu._parent = self
    return subMenu
end

function GM_Menu:AddCommand(text, func)
    GM_Menu:Ensure()
    self._subMenuCount = self._subMenuCount or 0
    self._subMenuCount = self._subMenuCount + 1
    local subMenu = DCAF.clone(GM_Menu)
    subMenu._menu = MENU_COALITION_COMMAND:New(Blue, text, self._menu, func)
    subMenu._path = self._path .. '/' .. text
    subMenu._parent = self
    return subMenu
end

function GM_Menu:Remove(removeEmptyParent)
    if self._menu then
        self._menu:Remove()
        self._menu = nil
        if self._parent then
            self._parent:_notifyRemoveSubMenu(self, removeEmptyParent)
        end
    end
    return self
end

function GM_Menu:_notifyRemoveSubMenu(menu, removeOnEmpty)
    self._subMenuCount = self._subMenuCount - 1
    if self._subMenuCount == 0 and removeOnEmpty then
        self:Remove(removeOnEmpty)
    end
end

Trace("\\\\\\\\\\ GM_Menu.lua was loaded //////////")
