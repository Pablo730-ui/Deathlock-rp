local openComponentsMenu, openTintsMenu, openWeaponUpgraderMenu, openOwnedWeapons

function openComponentsMenu(markerId, weaponName)
  local componentsData, menuId, menuTitle, menuItems, onItemSelect, onMenuClose, componentValue, eventPrefix, eventSuffix

  componentsData = TriggerServerPromise(Utils.eventsPrefix .. ":openComponents", markerId, weaponName)

  menuId = Utils.openInteractionMenu
  menuTitle = "weapon_upgrader_components"
  onItemSelect = getLocalizedText
  onMenuClose = "weapon_upgrader"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local componentValue, eventPrefix, eventSuffix

    componentValue = elementData.value

    if not componentValue then
      return
    end

    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":buyWeaponComponent"
    TriggerServerEvent(eventPrefix .. eventSuffix, markerId, weaponName, componentValue)
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, componentsData, onItemSelect, onMenuClose)
end

function openTintsMenu(markerId, weaponName)
  local tintsData, menuId, menuTitle, menuItems, onItemSelect, onMenuClose, tintValue, eventPrefix, eventSuffix

  tintsData = TriggerServerPromise(Utils.eventsPrefix .. ":openTints", markerId, weaponName)

  menuId = Utils.openInteractionMenu
  menuTitle = "weapon_upgrader_tints"
  onItemSelect = getLocalizedText
  onMenuClose = "weapon_upgrader"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local tintValue, eventPrefix, eventSuffix

    tintValue = elementData.value

    if not tintValue then
      return
    end

    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":buyWeaponTint"
    TriggerServerEvent(eventPrefix .. eventSuffix, markerId, weaponName, tintValue)
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
    openedMenu = nil
  end

  menuId(menuTitle, onItemSelect, tintsData, onItemSelect, onMenuClose)
end

function openWeaponUpgraderMenu(markerId, weaponName)
  local menuItems, componentsOption, tintsOption, menuId, menuTitle, onItemSelect, onMenuClose, selectedValue

  menuItems = {}
  componentsOption = {}
  tintsOption = getLocalizedText
  menuId = "components"
  tintsOption = tintsOption(menuId)
  componentsOption.label = tintsOption
  componentsOption.value = "components"
  tintsOption = {}
  menuId = getLocalizedText
  menuTitle = "tints"
  menuId = menuId(menuTitle)
  tintsOption.label = menuId
  tintsOption.value = "tints"
  menuItems[1] = componentsOption
  menuItems[2] = tintsOption

  menuId = Utils.openInteractionMenu
  menuTitle = "weapon_upgrader"
  onItemSelect = getLocalizedText
  onMenuClose = "weapon_upgrader"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local selectedValue

    selectedValue = elementData.value

    if "components" == selectedValue then
      openComponentsMenu(markerId, weaponName)
    elseif "tints" == selectedValue then
      openTintsMenu(markerId, weaponName)
    end
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
    openedMenu = nil
  end

  menuId(menuTitle, onItemSelect, menuItems, onItemSelect, onMenuClose)
end

function openOwnedWeapons(markerId)
  local ownedWeapons, menuItems, iterator, weaponData, menuId, menuTitle, onItemSelect, onMenuClose, weaponValue

  if "ox_inventory" == INVENTORY_TO_USE then
    notifyClient("Weapon upgrader can't be used with OX inventory")
    notifyClient("To upgrade weapons, use the ox_inventory and not Jobs Creator")
    return
  end

  Utils.hideInteractionMenu()

  ownedWeapons = TriggerServerPromise(Utils.eventsPrefix .. ":getOwnedWeapons")

  menuItems = {}
  iterator = pairs
  weaponData = ownedWeapons
  iterator, weaponData, menuId, menuTitle = iterator(weaponData)

  for onItemSelect, onMenuClose in iterator, weaponData, menuId, menuTitle do
    menuId = table.insert
    menuTitle = menuItems
    onItemSelect = {}
    onMenuClose = onMenuClose.label
    onItemSelect.label = onMenuClose
    onMenuClose = onMenuClose.name
    onItemSelect.value = onMenuClose
    menuId(menuTitle, onItemSelect)
  end

  menuId = Utils.openInteractionMenu
  menuTitle = "weapon_upgrader_owned_weapons"
  onItemSelect = getLocalizedText
  onMenuClose = "weapon_upgrader"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local weaponValue

    weaponValue = elementData.value

    if not weaponValue then
      return
    end

    openWeaponUpgraderMenu(markerId, weaponValue)
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, menuItems, onItemSelect, onMenuClose)
end
