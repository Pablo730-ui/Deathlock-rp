local takeFromStash, depositIntoStash, openStashMenu

function takeFromStash(markerId)
  local stashData, menuId, menuTitle, menuItems, onItemSelect, onMenuClose, itemValue, quantity, eventPrefix, eventSuffix

  stashData = TriggerServerPromise(Utils.eventsPrefix .. ":retrieveStash", markerId)

  menuId = #stashData
  if 0 == menuId then
    menuId = table.insert
    menuTitle = stashData
    onItemSelect = {}
    onMenuClose = getLocalizedText
    menuItems = "empty_stash"
    onMenuClose = onMenuClose(menuItems)
    onItemSelect.label = onMenuClose
    menuId(menuTitle, onItemSelect)
  end

  menuId = Utils.openInteractionMenu
  menuTitle = "stash_take"
  onItemSelect = getLocalizedText
  onMenuClose = "stash_take"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local itemValue, quantity, eventPrefix, eventSuffix

    quantity = Utils.askQuantity(getLocalizedText("quantity"), 1, elementData.quantity)

    if not quantity then
      return
    end

    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":stash:takeItem"
    local result = TriggerServerPromise(eventPrefix .. eventSuffix, elementData.value, quantity, markerId)

    if not result then
      return
    end

    takeFromStash(markerId)
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, stashData, onItemSelect, onMenuClose)
end

function depositIntoStash(markerId)
  local inventoryData, menuId, menuTitle, menuItems, onItemSelect, onMenuClose, itemValue, quantity, eventPrefix, eventSuffix

  inventoryData = TriggerServerPromise(Utils.eventsPrefix .. ":getPlayerInventory", markerId)

  menuId = #inventoryData
  if 0 == menuId then
    menuId = table.insert
    menuTitle = inventoryData
    onItemSelect = {}
    onMenuClose = getLocalizedText
    menuItems = "empty_inventory"
    onMenuClose = onMenuClose(menuItems)
    onItemSelect.label = onMenuClose
    onItemSelect.value = "emptyinventory"
    menuId(menuTitle, onItemSelect)
  end

  menuId = Utils.openInteractionMenu
  menuTitle = "stash_deposit"
  onItemSelect = getLocalizedText
  onMenuClose = "stash_deposit"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local itemValue, quantity, eventPrefix, eventSuffix

    quantity = Utils.askQuantity(getLocalizedText("quantity"), 1, elementData.quantity)

    if not quantity then
      return
    end

    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":stash:depositItem"
    local result = TriggerServerPromise(eventPrefix .. eventSuffix, elementData.value, quantity, markerId)

    if not result then
      return
    end

    depositIntoStash(markerId)
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, inventoryData, onItemSelect, onMenuClose)
end

function openStashMenu(markerId)
  local menuItems, depositOption, takeOption, menuId, menuTitle, onItemSelect, onMenuClose, selectedValue

  Utils.hideInteractionMenu()

  menuItems = {}
  depositOption = {}
  takeOption = getLocalizedText
  menuId = "deposit"
  takeOption = takeOption(menuId)
  depositOption.label = takeOption
  depositOption.value = "deposit"
  takeOption = {}
  menuId = getLocalizedText
  menuTitle = "take"
  menuId = menuId(menuTitle)
  takeOption.label = menuId
  takeOption.value = "take"
  menuItems[1] = depositOption
  menuItems[2] = takeOption

  menuId = Utils.openInteractionMenu
  menuTitle = "stash"
  onItemSelect = getLocalizedText
  onMenuClose = "stash"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local selectedValue

    selectedValue = elementData.value

    if "deposit" == selectedValue then
      depositIntoStash(markerId)
    elseif "take" == selectedValue then
      takeFromStash(markerId)
    end
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, menuItems, onItemSelect, onMenuClose)
end

RegisterNetEvent(Utils.eventsPrefix .. ":stash:openStash", function(markerId)
  local stashModule, framework

  stashModule = config.modules.stash
  if "default" ~= stashModule then
    stashModule = Utils.callModuleFunc
    menuId = "stash"
    menuTitle = "open"
    onItemSelect = "stash"
    onMenuClose = markerId
    stashModule(menuId, menuTitle, onItemSelect, onMenuClose)
    return
  end

  framework = Framework.getFramework()
  if "ESX" == framework then
    openStashMenu(markerId)
  else
    print("^1Choose an inventory to use for stash in Jobs Creator settings^7")
  end
end)
