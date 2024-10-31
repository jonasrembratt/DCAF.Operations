Blue = coalition.side.BLUE

GM_Menu = {
    ClassName = "GM_Menu",
    ----
}

function GM_Menu:New(text, parentMenu)
    if not isAssignedString(text) then text = "[GM ONLY!]" end
    Debug("GM_Menu:New :: " .. text .. " :: parentMenu: " .. DumpPretty(parentMenu))
    local gmMenu = DCAF.clone(GM_Menu)
    gmMenu._menu = MENU_COALITION:New(Blue, text, parentMenu)
    gmMenu._text = text
    gmMenu._path = text
    gmMenu._subMenuCount = gmMenu._subMenuCount or 0
    return gmMenu
end

function GM_Menu:Ensure()
    if not GM_Menu._root then GM_Menu._root = GM_Menu:New() end
    return GM_Menu._root
end

function GM_Menu:AddMenu(text)
    Debug("GM_Menu:AddMenu :: " .. text)
    if self == GM_Menu then
        GM_Menu:Ensure()
    else
        self._subMenuCount = self._subMenuCount or 0
        self._subMenuCount = self._subMenuCount + 1
    end
    local subMenu = DCAF.clone(GM_Menu)
    subMenu._menu = MENU_COALITION:New(Blue, text, self._menu or GM_Menu._root._menu)
    subMenu._text = text
    local path = self._path
    if path == null then
        path = GM_Menu._root._path
    end
    subMenu._path = path .. '/' .. text
    subMenu._parent = self
    self._subMenus = self._subMenus or {}
    self._subMenus[text] = subMenu
    return subMenu
end

function GM_Menu:AddCommand(text, func)
    Debug("GM_Menu:AddCommand :: text: " .. Dump(text))
    if self == GM_Menu then
        GM_Menu:Ensure()
    end
    self._subMenuCount = self._subMenuCount or 0
    self._subMenuCount = self._subMenuCount + 1
    local subMenu = DCAF.clone(GM_Menu)
    subMenu._menu = MENU_COALITION_COMMAND:New(Blue, text, self._menu or GM_Menu._root, func)
    subMenu._text = text
    subMenu._path = self._path .. '/' .. text
    subMenu._parent = self
    self._subMenus = self._subMenus or {}
    self._subMenus[text] = subMenu
    return subMenu
end

function GM_Menu:Remove(removeEmptyParent)
    Debug("GM_Menu:Remove :: " .. self._text .. " :: removeEmptyParent: " .. Dump(removeEmptyParent))
    if self._menu then
        self._menu:Remove()
        self._menu = nil
        if self._parent then
            self._parent:_notifyRemoveSubMenu(self, removeEmptyParent)
        end
    end
    return self
end

function GM_Menu:RemoveChildren()
    Debug("GM_Menu:RemoveChildren :: " .. self._text)
    if not self._subMenus then return self end
    for _, subMenu in pairs(self._subMenus) do
        -- subMenu:RemoveChildren()
        subMenu:Remove(false)
    end
end

function GM_Menu:_notifyRemoveSubMenu(menu, removeOnEmpty)
    if self == GM_Menu then self = GM_Menu._root end
    self._subMenuCount = self._subMenuCount - 1
    if self._subMenus then
        self._subMenus[menu._text] = nil
    end
    if self._subMenuCount == 0 and removeOnEmpty then
        self:Remove(removeOnEmpty)
    end
end

Trace("\\\\\\\\\\ GM_Menu.lua was loaded //////////")
