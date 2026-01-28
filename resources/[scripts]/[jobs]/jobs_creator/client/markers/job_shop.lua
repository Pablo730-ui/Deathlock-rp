local openShopBuyMenu, putItemOnSale, removeItemFromSale, addSuppliesToShop, openJobShop

function openShopBuyMenu(markerId)
  local shopData, menuItems, iterator, itemData, itemLabel, itemQuantity, price, menuId, menuTitle, onItemSelect, onMenuClose

  shopData = TriggerServerPromise
  menuItems = Utils
  menuItems = menuItems.eventsPrefix
  iterator = ":getJobShop"
  menuItems = menuItems .. iterator
  iterator = markerId
  shopData = shopData(menuItems, iterator)

  menuItems = {}
  iterator = pairs
  itemData = shopData
  iterator, itemData, itemLabel, itemQuantity = iterator(itemData)

  for price, menuId in iterator, itemData, itemLabel, itemQuantity do
    menuTitle = table
    menuTitle = menuTitle.insert
    onItemSelect = menuItems
    onMenuClose = {}
    onMenuClose = getLocalizedText
    itemQuantity = "job_shop_item"
    itemLabel = menuId.item_label
    price = menuId.item_quantity
    menuTitle = Framework
    menuTitle = menuTitle.groupDigits
    iterator = menuId.price
    menuTitle, iterator = menuTitle(iterator)
    onMenuClose = onMenuClose(itemQuantity, itemLabel, price, menuTitle, iterator)
    onItemSelect.label = onMenuClose
    menuId = menuId.id
    onItemSelect.itemId = menuId
    onItemSelect.itemData = menuId
    menuTitle(onItemSelect, onItemSelect)
  end

  iterator = #menuItems
  if 0 == iterator then
    iterator = table
    iterator = iterator.insert
    itemData = menuItems
    itemLabel = {}
    itemQuantity = getLocalizedText
    price = "job_shop_empty"
    itemQuantity = itemQuantity(price)
    itemLabel.label = itemQuantity
    iterator(itemData, itemLabel)
  end

  iterator = Utils
  iterator = iterator.openInteractionMenu
  itemData = "job_owned_shop_items"
  itemLabel = getLocalizedText
  itemQuantity = "job_owned_shop"
  itemLabel = itemLabel(itemQuantity)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local itemId, itemPrice, itemQuantityLimit, itemType, quantity, eventPrefix, eventSuffix, markerId

    itemId = elementData.itemId
    if not itemId then
      return
    end

    itemPrice = elementData.itemData
    itemPrice = itemPrice.price
    itemQuantityLimit = elementData.itemData
    itemQuantityLimit = itemQuantityLimit.item_quantity
    itemType = elementData.itemData
    itemType = itemType.item_type

    if "item_standard" == itemType then
      quantity = Utils
      quantity = quantity.askQuantity
      eventPrefix = getLocalizedText
      eventSuffix = "quantity"
      eventPrefix = eventPrefix(eventSuffix)
      markerId = 1
      itemPrice = itemQuantityLimit
      quantity = quantity(eventPrefix, markerId, itemPrice)

      if not quantity then
        return
      end

      eventPrefix = TriggerServerEvent
      eventSuffix = Utils
      eventSuffix = eventSuffix.eventsPrefix
      markerId = ":job_shop:buyItem"
      eventSuffix = eventSuffix .. markerId
      markerId = markerId
      itemPrice = itemId
      eventPrefix(eventSuffix, markerId, itemPrice, quantity)

      eventPrefix = openShopBuyMenu
      eventSuffix = markerId
      eventPrefix(eventSuffix)
    elseif "item_weapon" == itemType then
      quantity = TriggerServerEvent
      eventPrefix = Utils
      eventPrefix = eventPrefix.eventsPrefix
      eventSuffix = ":job_shop:buyItem"
      eventPrefix = eventPrefix .. eventSuffix
      eventSuffix = markerId
      markerId = itemId
      itemPrice = 1
      quantity(eventPrefix, eventSuffix, markerId, itemPrice)

      quantity = openShopBuyMenu
      eventPrefix = markerId
      quantity(eventPrefix)
    end
  end

  function onMenuClose()
    local _unused

    _unused = Utils
    _unused = _unused.hideInteractionMenu
    _unused()
  end

  iterator(itemData, itemLabel, menuItems, onItemSelect, onMenuClose)
end

function putItemOnSale(markerId)
  local sellableItems, itemsCount, menuId, menuTitle, menuItems, onItemSelect, onMenuClose

  sellableItems = TriggerServerPromise
  itemsCount = Utils
  itemsCount = itemsCount.eventsPrefix
  menuId = ":getSellableStuff"
  itemsCount = itemsCount .. menuId
  sellableItems = sellableItems(itemsCount)

  itemsCount = #sellableItems
  if 0 == itemsCount then
    itemsCount = table
    itemsCount = itemsCount.insert
    menuId = sellableItems
    menuTitle = {}
    menuItems = getLocalizedText
    onItemSelect = "job_shop:nothing_to_sell"
    menuItems = menuItems(onItemSelect)
    menuTitle.label = menuItems
    itemsCount(menuId, menuTitle)
  end

  itemsCount = Utils
  itemsCount = itemsCount.openInteractionMenu
  menuId = "job_owned_shop_put_on_sale"
  menuTitle = getLocalizedText
  menuItems = "job_owned_shop"
  menuTitle = menuTitle(menuItems)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local itemValue, itemCount, itemType, quantity, price, eventPrefix, eventSuffix, markerId

    itemValue = elementData.value
    itemCount = elementData.count
    itemType = elementData.type

    if itemCount > 1 then
      quantity = Utils
      quantity = quantity.askQuantity
      price = getLocalizedText
      eventPrefix = "quantity"
      price = price(eventPrefix)
      eventSuffix = 1
      markerId = itemCount
      quantity = quantity(price, eventSuffix, markerId)

      if not quantity then
        return
      end

      price = Utils
      price = price.askQuantity
      eventPrefix = getLocalizedText
      eventSuffix = "item_price"
      eventPrefix = eventPrefix(eventSuffix)
      markerId = 1
      eventSuffix = nil
      price = price(eventPrefix, markerId, eventSuffix)

      if not price then
        return
      end

      eventPrefix = TriggerServerEvent
      eventSuffix = Utils
      eventSuffix = eventSuffix.eventsPrefix
      markerId = ":jobShopPutOnSale"
      eventSuffix = eventSuffix .. markerId
      markerId = itemValue
      eventPrefix = itemType
      eventSuffix = quantity
      eventPrefix(eventSuffix, markerId, eventPrefix, eventSuffix, price)

      eventPrefix = putItemOnSale
      eventSuffix = markerId
      eventPrefix(eventSuffix)
    else
      quantity = Utils
      quantity = quantity.askQuantity
      price = getLocalizedText
      eventPrefix = "item_price"
      price = price(eventPrefix)
      eventSuffix = 1
      markerId = nil
      quantity = quantity(price, eventSuffix, markerId)

      if not quantity then
        return
      end

      price = TriggerServerEvent
      eventPrefix = Utils
      eventPrefix = eventPrefix.eventsPrefix
      eventSuffix = ":jobShopPutOnSale"
      eventPrefix = eventPrefix .. eventSuffix
      eventSuffix = itemValue
      markerId = itemType
      price(eventPrefix, eventSuffix, markerId, itemCount, quantity)

      price = putItemOnSale
      eventPrefix = markerId
      price(eventPrefix)
    end
  end

  function onMenuClose()
    local _unused

    _unused = Utils
    _unused = _unused.hideInteractionMenu
    _unused()
  end

  itemsCount(menuId, menuTitle, sellableItems, onItemSelect, onMenuClose)
end

function removeItemFromSale(markerId)
  local shopData, menuItems, iterator, itemData, itemLabel, itemQuantity, price, menuId, menuTitle, onItemSelect, onMenuClose

  shopData = TriggerServerPromise
  menuItems = Utils
  menuItems = menuItems.eventsPrefix
  iterator = ":getJobShop"
  menuItems = menuItems .. iterator
  iterator = markerId
  shopData = shopData(menuItems, iterator)

  menuItems = {}
  iterator = pairs
  itemData = shopData
  iterator, itemData, itemLabel, itemQuantity = iterator(itemData)

  for price, menuId in iterator, itemData, itemLabel, itemQuantity do
    menuTitle = table
    menuTitle = menuTitle.insert
    onItemSelect = menuItems
    onMenuClose = {}
    onMenuClose = getLocalizedText
    itemQuantity = "job_shop_item"
    itemLabel = menuId.item_label
    price = menuId.item_quantity
    menuTitle = Framework
    menuTitle = menuTitle.groupDigits
    iterator = menuId.price
    menuTitle, iterator = menuTitle(iterator)
    onMenuClose = onMenuClose(itemQuantity, itemLabel, price, menuTitle, iterator)
    onItemSelect.label = onMenuClose
    menuId = menuId.id
    onItemSelect.itemId = menuId
    onItemSelect.itemData = menuId
    menuTitle(onItemSelect, onItemSelect)
  end

  iterator = #menuItems
  if 0 == iterator then
    iterator = table
    iterator = iterator.insert
    itemData = menuItems
    itemLabel = {}
    itemQuantity = getLocalizedText
    price = "job_shop_empty"
    itemQuantity = itemQuantity(price)
    itemLabel.label = itemQuantity
    iterator(itemData, itemLabel)
  end

  iterator = Utils
  iterator = iterator.openInteractionMenu
  itemData = "job_owned_shop_items_remove_from_sale"
  itemLabel = getLocalizedText
  itemQuantity = "job_owned_shop"
  itemLabel = itemLabel(itemQuantity)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local itemId, itemQuantityLimit, quantity, eventPrefix, eventSuffix, markerId

    itemId = elementData.itemId
    if itemId then
      itemQuantityLimit = elementData.itemData
      itemQuantityLimit = itemQuantityLimit.item_quantity

      if itemQuantityLimit > 1 then
        quantity = Utils
        quantity = quantity.askQuantity
        eventPrefix = getLocalizedText
        eventSuffix = "quantity"
        eventPrefix = eventPrefix(eventSuffix)
        markerId = 1
        eventSuffix = itemQuantityLimit
        quantity = quantity(eventPrefix, markerId, eventSuffix)

        if not quantity then
          return
        end

        eventPrefix = TriggerServerEvent
        eventSuffix = Utils
        eventSuffix = eventSuffix.eventsPrefix
        markerId = ":job_shop:removeFromSale"
        eventSuffix = eventSuffix .. markerId
        markerId = markerId
        eventPrefix = itemId
        eventPrefix(eventSuffix, markerId, eventPrefix, quantity)

        eventPrefix = removeItemFromSale
        eventSuffix = markerId
        eventPrefix(eventSuffix)
      else
        quantity = TriggerServerEvent
        eventPrefix = Utils
        eventPrefix = eventPrefix.eventsPrefix
        eventSuffix = ":job_shop:removeFromSale"
        eventPrefix = eventPrefix .. eventSuffix
        eventSuffix = markerId
        markerId = itemId
        quantity(eventPrefix, eventSuffix, markerId, itemQuantityLimit)

        quantity = removeItemFromSale
        eventPrefix = markerId
        quantity(eventPrefix)
      end
    end
  end

  function onMenuClose()
    local _unused

    _unused = Utils
    _unused = _unused.hideInteractionMenu
    _unused()
  end

  iterator(itemData, itemLabel, menuItems, onItemSelect, onMenuClose)
end

function addSuppliesToShop(markerId)
  local shopData, menuItems, iterator, itemData, itemLabel, itemQuantity, price, menuId, menuTitle, onItemSelect, onMenuClose

  shopData = TriggerServerPromise
  menuItems = Utils
  menuItems = menuItems.eventsPrefix
  iterator = ":getJobShop"
  menuItems = menuItems .. iterator
  iterator = markerId
  shopData = shopData(menuItems, iterator)

  menuItems = {}
  iterator = pairs
  itemData = shopData
  iterator, itemData, itemLabel, itemQuantity = iterator(itemData)

  for price, menuId in iterator, itemData, itemLabel, itemQuantity do
    menuTitle = table
    menuTitle = menuTitle.insert
    onItemSelect = menuItems
    onMenuClose = {}
    onMenuClose = getLocalizedText
    itemQuantity = "job_shop_item"
    itemLabel = menuId.item_label
    price = menuId.item_quantity
    menuTitle = Framework
    menuTitle = menuTitle.groupDigits
    iterator = menuId.price
    menuTitle, iterator = menuTitle(iterator)
    onMenuClose = onMenuClose(itemQuantity, itemLabel, price, menuTitle, iterator)
    onItemSelect.label = onMenuClose
    menuId = menuId.id
    onItemSelect.itemId = menuId
    onItemSelect.itemData = menuId
    menuTitle(onItemSelect, onItemSelect)
  end

  iterator = #menuItems
  if 0 == iterator then
    iterator = table
    iterator = iterator.insert
    itemData = menuItems
    itemLabel = {}
    itemQuantity = getLocalizedText
    price = "job_shop_empty"
    itemQuantity = itemQuantity(price)
    itemLabel.label = itemQuantity
    iterator(itemData, itemLabel)
  end

  iterator = Utils
  iterator = iterator.openInteractionMenu
  itemData = "job_owned_shop_items_restock"
  itemLabel = getLocalizedText
  itemQuantity = "job_owned_shop"
  itemLabel = itemLabel(itemQuantity)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local itemId, quantity, eventPrefix, eventSuffix, markerId

    itemId = elementData.itemId
    if itemId then
      quantity = Utils
      quantity = quantity.askQuantity
      eventPrefix = getLocalizedText
      eventSuffix = "job_shop:how_many_to_restock"
      eventPrefix = eventPrefix(eventSuffix)
      markerId = 1
      eventSuffix = nil
      quantity = quantity(eventPrefix, markerId, eventSuffix)

      if not quantity then
        return
      end

      eventPrefix = TriggerServerEvent
      eventSuffix = Utils
      eventSuffix = eventSuffix.eventsPrefix
      markerId = ":job_shop:addSupplies"
      eventSuffix = eventSuffix .. markerId
      markerId = markerId
      eventPrefix = itemId
      eventPrefix(eventSuffix, markerId, eventPrefix, quantity)

      eventPrefix = addSuppliesToShop
      eventSuffix = markerId
      eventPrefix(eventSuffix)
    end
  end

  function onMenuClose()
    local _unused

    _unused = Utils
    _unused = _unused.hideInteractionMenu
    _unused()
  end

  iterator(itemData, itemLabel, menuItems, onItemSelect, onMenuClose)
end

function openJobShop(markerId)
  local canSell, menuItems, shopOption, menuId, menuTitle, onItemSelect, onMenuClose

  canSell = Utils
  canSell = canSell.hideInteractionMenu
  canSell()

  canSell = TriggerServerPromise
  menuItems = Utils
  menuItems = menuItems.eventsPrefix
  menuId = ":canSellInThisShop"
  menuItems = menuItems .. menuId
  menuId = markerId
  canSell = canSell(menuItems, menuId)

  menuItems = {}
  shopOption = {}
  menuId = getLocalizedText
  menuTitle = "shop"
  menuId = menuId(menuTitle)
  shopOption.label = menuId
  shopOption.value = "shop"
  menuItems[1] = shopOption

  if canSell then
    shopOption = table
    shopOption = shopOption.insert
    menuId = menuItems
    menuTitle = {}
    onItemSelect = getLocalizedText
    onMenuClose = "put_on_sale"
    onItemSelect = onItemSelect(onMenuClose)
    menuTitle.label = onItemSelect
    menuTitle.value = "put_on_sale"
    shopOption(menuId, menuTitle)

    shopOption = table
    shopOption = shopOption.insert
    menuId = menuItems
    menuTitle = {}
    onItemSelect = getLocalizedText
    onMenuClose = "remove_from_sale"
    onItemSelect = onItemSelect(onMenuClose)
    menuTitle.label = onItemSelect
    menuTitle.value = "remove_from_sale"
    shopOption(menuId, menuTitle)

    shopOption = table
    shopOption = shopOption.insert
    menuId = menuItems
    menuTitle = {}
    onItemSelect = getLocalizedText
    onMenuClose = "job_shop:add_supplies"
    onItemSelect = onItemSelect(onMenuClose)
    menuTitle.label = onItemSelect
    menuTitle.value = "add_supplies"
    shopOption(menuId, menuTitle)
  end

  shopOption = Utils
  shopOption = shopOption.openInteractionMenu
  menuId = "job_owned_shop"
  menuTitle = getLocalizedText
  onItemSelect = "job_owned_shop"
  menuTitle = menuTitle(onItemSelect)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local selectedValue, _, __

    selectedValue = elementData.value

    if "shop" == selectedValue then
      _ = openShopBuyMenu
      __ = markerId
      _(__)
    elseif "put_on_sale" == selectedValue then
      _ = putItemOnSale
      __ = markerId
      _(__)
    elseif "remove_from_sale" == selectedValue then
      _ = removeItemFromSale
      __ = markerId
      _(__)
    elseif "add_supplies" == selectedValue then
      _ = addSuppliesToShop
      __ = markerId
      _(__)
    end
  end

  function onMenuClose()
    local _unused

    _unused = Utils
    _unused = _unused.hideInteractionMenu
    _unused()
  end

  shopOption(menuId, menuTitle, menuItems, onItemSelect, onMenuClose)
end
