RegisterServerCallback(Utils.eventsPrefix .. ":getShopData", function(source, callback, shopId)
  local playerId, canAccess, markerData, shopItems, i, item, itemData, itemLabel, emptyLabel

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, shopId)
  if not canAccess then
    return
  end

  markerData = JobsCreator.Markers[shopId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  shopItems = {}

  if markerData.itemsOnSale then
    for i = 1, #markerData.itemsOnSale, 1 do
      item = markerData.itemsOnSale[i]
      itemLabel = getLocalizedText(
        "shop:item",
        Framework.getGenericObjectLabel(item.object.name, item.object.type),
        item.price
      )

      itemData = {}
      itemData.label = itemLabel
      itemData.value = i
      itemData.itemType = item.object.type
      table.insert(shopItems, itemData)
    end
  end

  if #shopItems == 0 then
    emptyLabel = getLocalizedText("shop_empty")
    table.insert(shopItems, {
      label = emptyLabel
    })
  end

  callback(shopItems)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":buyShopItem")
AddEventHandler(Utils.eventsPrefix .. ":buyShopItem", function(shopId, itemIndex, quantity)
  local playerId, canAccess, markerData, itemObject, itemPrice, isBlackMoney, totalPrice, itemName, notificationType, notificationMessage, logMessage, logDescription

  playerId = source

  if quantity <= 0 then
    return
  end

  canAccess = canUseMarkerWithLog(playerId, shopId)
  if not canAccess then
    return
  end

  markerData = JobsCreator.Markers[shopId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  if not markerData.itemsOnSale then
    return
  end

  itemObject = markerData.itemsOnSale[itemIndex].object
  itemPrice = markerData.itemsOnSale[itemIndex].price
  isBlackMoney = markerData.itemsOnSale[itemIndex].blackMoney
  totalPrice = itemPrice * quantity

  if not itemPrice then
    Utils.log(
      playerId,
      getLocalizedText("log_not_existing_item"),
      getLocalizedText("log_not_existing_item_description", itemName, shopId),
      "error",
      "shop"
    )
    return
  end

  if not Framework.canPlayerCarryGenericObject(playerId, itemObject.name, itemObject.type, quantity) then
    notify(playerId, getLocalizedText("no_space"))
    return
  end

  if isBlackMoney then
    local blackMoneyAmount = Framework.getBlackMoneyValue(playerId)
    if totalPrice > blackMoneyAmount then
      notify(playerId, getLocalizedText("not_enough_money"))
      return
    end
    Framework.removeBlackMoneyValue(playerId, totalPrice)
  else
    if not payInSomeWay(playerId, totalPrice) then
      notify(playerId, getLocalizedText("not_enough_money"))
      return
    end
  end

  Framework.giveGenericObjectToPlayerId(playerId, itemObject, quantity)

  itemName = Framework.getGenericObjectLabel(itemObject.name, itemObject.type)

  if isBlackMoney then
    notificationType = "r"
  else
    notificationType = "g"
  end

  notificationMessage = getLocalizedText(
    "you_bought",
    quantity,
    itemName,
    notificationType,
    Framework.groupDigits(totalPrice)
  )
  notify(playerId, notificationMessage)

  logMessage = getLocalizedText("log_bought_item")
  logDescription = getLocalizedText(
    "log_bought_item_description",
    quantity,
    itemName,
    itemObject.name,
    shopId
  )
  Utils.log(playerId, logMessage, logDescription, "success", "shop")

  TriggerEvent(
    Utils.eventsPrefix .. ":shop:boughtItem",
    playerId,
    shopId,
    itemObject.name,
    itemObject.type,
    quantity,
    totalPrice
  )
end)
