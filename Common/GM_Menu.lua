Blue = coalition.side.BLUE

GM_Menu = {
    ClassName = "GM_Menu",
    ----
}

local menu_ID = 0
local menus_DB = {
    -- key   = menu path
    -- value = #GM_Menu
}

function menus_DB:getNextID()
    menu_ID = menu_ID + 1
    return menu_ID
end

function menus_DB:add(gm_menu)
    self[gm_menu._path] = gm_menu
end

function menus_DB:remove(gm_menu)
    local menuPath = gm_menu._path
    for path, menu in pairs(self) do
        if stringStartsWith(path, menuPath) then
            self[path] = nil
        end
    end
end

function menus_DB:getSubMenus(gm_menu)
    local subMenus = {}
    for path, menu in pairs(self) do
        if menu._parent == gm_menu then
            subMenus[#subMenus+1] = menu
        end
    end
    return subMenus
end

function GM_Menu:New(text, parentMenu)
    if not isAssignedString(text) then text = "[GM ONLY!]" end
    Debug("GM_Menu:New :: " .. text .. " :: parentMenu: " .. DumpPretty(parentMenu))
    local gmMenu = DCAF.clone(GM_Menu)
    if not isAssignedString(text) then text = tostring(text) end
    gmMenu._menu = MENU_COALITION:New(Blue, text, parentMenu)
    gmMenu._text = text
    gmMenu._path = text
    gmMenu._subMenuCount = gmMenu._subMenuCount or 0
    gmMenu.ID = menus_DB:getNextID()
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
    subMenu.ID = menus_DB:getNextID()
    if not isAssignedString(text) then text = tostring(text) end
    subMenu._menu = MENU_COALITION:New(Blue, text, self._menu or GM_Menu._root._menu)
    subMenu._text = text
    local path = self._path
    if path == nil then
        path = GM_Menu._root._path
    end
    subMenu._path = path .. '/' .. text
    subMenu._parent = self
    menus_DB:add(subMenu)
    -- self._subMenus = self._subMenus or {}
    -- self._subMenus[text] = subMenu
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
    if not isAssignedString(text) then text = tostring(text) end
    subMenu._menu = MENU_COALITION_COMMAND:New(Blue, text, self._menu or GM_Menu._root._menu, func)
    subMenu.ID = menus_DB:getNextID()
    subMenu._text = text
    subMenu._path = (self._path or GM_Menu._root._path) .. '/' .. text
    subMenu._parent = self
    menus_DB:add(subMenu)
    -- self._subMenus = self._subMenus or {}
    -- self._subMenus[text] = subMenu
    return subMenu
end

function GM_Menu:Remove(removeEmptyParent)
    Debug("GM_Menu:Remove :: " .. self._text .. " :: removeEmptyParent: " .. Dump(removeEmptyParent))
    if self._menu then
        self._menu:Remove()
        self._menu = nil
        menus_DB:remove(self)
        if self._parent then
            self._parent:_notifyRemoveSubMenu(self, removeEmptyParent)
        end
    end
    return self
end

function GM_Menu:RemoveChildren()
    Debug("GM_Menu:RemoveChildren :: " .. self._text)
    local subMenus = menus_DB:getSubMenus(self)
    if #subMenus == 0 then return self end
    for _, subMenu in pairs(subMenus) do
        subMenu:Remove(false)
    end
    -- if not self._subMenus then return self end
    -- for _, subMenu in pairs(self._subMenus) do
    --     -- subMenu:RemoveChildren()
    --     subMenu:Remove(false)
    -- end
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
