local depositIntoSafe, withdrawFromSafe, openSafeMenu

function depositIntoSafe(markerId)
  local playerAccounts, menuId, menuTitle, menuItems, onItemSelect, onMenuClose, accountName, quantity, eventPrefix, eventSuffix

  playerAccounts = TriggerServerPromise(Utils.eventsPrefix .. ":getPlayerAccounts")

  menuId = #playerAccounts
  if 0 == menuId then
    menuId = table.insert
    menuTitle = playerAccounts
    onItemSelect = {}
    onMenuClose = getLocalizedText
    menuItems = "nothing_to_deposit"
    onMenuClose = onMenuClose(menuItems)
    onItemSelect.label = onMenuClose
    onItemSelect.value = "empty"
    menuId(menuTitle, onItemSelect)
  end

  menuId = Utils.openInteractionMenu
  menuTitle = "safe_deposit"
  onItemSelect = getLocalizedText
  onMenuClose = "safe"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local accountName, quantity, eventPrefix, eventSuffix

    print(DumpTable(elementData))
    accountName = elementData.accountName

    if not accountName then
      return
    end

    quantity = Utils.askQuantity(getLocalizedText("quantity"), 1, nil)

    if not quantity then
      return
    end

    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":depositIntoSafe"
    local result = TriggerServerPromise(eventPrefix .. eventSuffix, accountName, quantity, markerId)

    if not result then
      return
    end

    depositIntoSafe(markerId)
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, playerAccounts, onItemSelect, onMenuClose)
end

function withdrawFromSafe(markerId)
  local safeData, menuId, menuTitle, menuItems, onItemSelect, onMenuClose, accountName, quantity, eventPrefix, eventSuffix

  safeData = TriggerServerPromise(Utils.eventsPrefix .. ":retrieveReadableSafeData", markerId)

  menuId = #safeData
  if 0 == menuId then
    menuId = table.insert
    menuTitle = safeData
    onItemSelect = {}
    onMenuClose = getLocalizedText
    menuItems = "empty_safe"
    onMenuClose = onMenuClose(menuItems)
    onItemSelect.label = onMenuClose
    onItemSelect.value = "empty"
    menuId(menuTitle, onItemSelect)
  end

  menuId = Utils.openInteractionMenu
  menuTitle = "safe_withdraw"
  onItemSelect = getLocalizedText
  onMenuClose = "safe"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local accountName, quantity, eventPrefix, eventSuffix

    accountName = elementData.accountName

    if not accountName then
      return
    end

    quantity = Utils.askQuantity(getLocalizedText("quantity"), 1, nil)

    if not quantity then
      return
    end

    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":withdrawFromSafe"
    local result = TriggerServerPromise(eventPrefix .. eventSuffix, accountName, quantity, markerId)

    if not result then
      return
    end

    withdrawFromSafe(markerId)
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, safeData, onItemSelect, onMenuClose)
end

function openSafeMenu(markerId)
  local menuItems, depositOption, withdrawOption, menuId, menuTitle, onItemSelect, onMenuClose, selectedValue

  menuItems = {}
  depositOption = {}
  withdrawOption = getLocalizedText
  menuId = "deposit"
  withdrawOption = withdrawOption(menuId)
  depositOption.label = withdrawOption
  depositOption.value = "deposit"
  withdrawOption = {}
  menuId = getLocalizedText
  menuTitle = "withdraw"
  menuId = menuId(menuTitle)
  withdrawOption.label = menuId
  withdrawOption.value = "withdraw"
  menuItems[1] = depositOption
  menuItems[2] = withdrawOption

  menuId = Utils.hideInteractionMenu
  menuId()

  menuId = Utils.openInteractionMenu
  menuTitle = "safe"
  onItemSelect = getLocalizedText
  onMenuClose = "safe"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local selectedValue

    selectedValue = elementData.value

    if "deposit" == selectedValue then
      depositIntoSafe(markerId)
    elseif "withdraw" == selectedValue then
      withdrawFromSafe(markerId)
    end
  end

  function onMenuClose()
    Utils.hideInteractionMenu()
  end

  menuId(menuTitle, onItemSelect, menuItems, onItemSelect, onMenuClose)
end

RegisterNetEvent(Utils.eventsPrefix .. ":safe:openSafe", function(markerId)
  local stashModule

  stashModule = config.modules.stash
  if "default" ~= stashModule then
    stashModule = Utils.callModuleFunc
    menuId = "stash"
    menuTitle = "open"
    onItemSelect = "safe"
    onMenuClose = markerId
    stashModule(menuId, menuTitle, onItemSelect, onMenuClose)
    return
  end

  openSafeMenu(markerId)
end)
