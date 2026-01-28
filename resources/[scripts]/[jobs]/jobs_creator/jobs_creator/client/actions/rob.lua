local searchPlayerInventory, searchPlayer, handleRobAction

function searchPlayerInventory(serverId)
  local framework, inventoryData, menuId, menuTitle, menuItems, onItemSelect, onMenuClose, itemValue, quantity, eventPrefix, eventSuffix

  framework = Framework.getFramework()
  if "QB-core" == framework then
    Utils.hideInteractionMenu()
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":qb-inventory:robPlayer"
    TriggerServerEvent(eventPrefix .. eventSuffix, serverId)
  else
    framework = Framework.getFramework()
    if "ESX" == framework then
      eventPrefix = Utils.eventsPrefix
      eventSuffix = ":getTargetPlayerInventory"
      inventoryData = TriggerServerPromise(eventPrefix .. eventSuffix, serverId)

      if not inventoryData then
        return
      end

      menuId = #inventoryData
      if 0 == menuId then
        menuId = table.insert
        menuTitle = inventoryData
        onItemSelect = {}
        onMenuClose = getLocalizedText
        menuItems = "search_inventory_empty"
        onMenuClose = onMenuClose(menuItems)
        onItemSelect.label = onMenuClose
        menuId(menuTitle, onItemSelect)
      end

      menuId = Utils.openInteractionMenu
      menuTitle = "actions_menu_search"
      onItemSelect = getLocalizedText
      onMenuClose = "actions_menu_search"
      onItemSelect = onItemSelect(onMenuClose)

      function onItemSelect(elementIndex, selectedIndex, elementData)
        local itemValue, quantity, eventPrefix, eventSuffix

        itemValue = elementData.value
        if nil == itemValue then
          return
        end

        quantity = elementData.max
        if nil == quantity then
          eventPrefix = Utils.eventsPrefix
          eventSuffix = ":stealFromPlayer"
          TriggerServerPromise(eventPrefix .. eventSuffix, serverId, elementData)

          if not TriggerServerPromise then
            return
          end

          searchPlayerInventory(serverId)
        else
          quantity = Utils.askQuantity(getLocalizedText("quantity"), 1, elementData.max)

          if quantity then
            if not (quantity > elementData.max) then
              eventPrefix = Utils.eventsPrefix
              eventSuffix = ":stealFromPlayer"
              TriggerServerPromise(eventPrefix .. eventSuffix, serverId, elementData, quantity)

              if not TriggerServerPromise then
                return
              end

              searchPlayerInventory(serverId)
            else
              notifyClient(getLocalizedText("invalid_quantity"))
              Utils.hideInteractionMenu()
              return
            end
          end
        end
      end

      function onMenuClose()
        Utils.hideInteractionMenu()
      end

      menuId(menuTitle, onItemSelect, inventoryData, onItemSelect, onMenuClose)
    end
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:search:searchPlayer", function(serverId)
  local searchModule

  searchModule = config.modules.search_player
  if "default" ~= searchModule then
    searchModule = Utils.callModuleFunc
    menuId = "search_player"
    menuTitle = "search"
    onItemSelect = serverId
    searchModule(menuId, menuTitle, onItemSelect)
    Utils.hideInteractionMenu()
    return
  end

  searchPlayerInventory(serverId)
end)

function handleRobAction(targetPed)
  local serverId, requiresHandcuff, isHandcuffed, eventPrefix, eventSuffix

  serverId = Utils.getPlayerServerIdFromPed(targetPed)
  if not serverId then
    serverId = Framework.getClosestPlayer(true, 4.0)
  end

  if not serverId then
    notifyClient(getLocalizedText("no_players_nearby"))
    return
  end

  requiresHandcuff = config.searchRequiresHandcuffState
  if requiresHandcuff then
    eventPrefix = Utils.eventsPrefix
    eventSuffix = ":isPlayerHandcuffed"
    isHandcuffed = TriggerServerPromise(eventPrefix .. eventSuffix, serverId)

    if not isHandcuffed then
      notifyClient(getLocalizedText("player_is_not_handcuffed"))
      return
    end
  end

  eventPrefix = Utils.eventsPrefix
  eventSuffix = ":actions:search:searchPlayer"
  TriggerEvent(eventPrefix .. eventSuffix, serverId)
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:search", handleRobAction)
