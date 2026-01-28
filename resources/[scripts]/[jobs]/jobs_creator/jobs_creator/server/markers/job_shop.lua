local shopItems = {}

function getAllShopsData()
  MySQL.Async.fetchAll("SELECT * FROM jobs_shops", {}, function(results)
    local markerId, itemData

    if results then
      for _, itemData in pairs(results) do
        markerId = itemData.marker_id

        if not shopItems[markerId] then
          shopItems[markerId] = {}
        end

        if itemData.item_type == "item_standard" then
          itemData.item_label = Framework.getItemLabel(itemData.item_name)
        elseif itemData.item_type == "item_weapon" then
          itemData.item_label = Framework.getWeaponLabel(itemData.item_name)
        end

        shopItems[markerId][itemData.id] = itemData
      end
    end
  end)
end

function canSellInThisShop(playerId, markerId)
  local jobName, jobGrade, markerData, allowedJob

  jobName = Framework.getPlayerJobName(playerId)
  jobGrade = Framework.getPlayerJobGrade(playerId)

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  allowedJob = markerData.allowedJob
  return allowedJob == jobName
end

RegisterServerCallback(Utils.eventsPrefix .. ":canSellInThisShop", function(playerId, callback, markerId)
  callback(canSellInThisShop(playerId, markerId))
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getJobShop", function(playerId, callback, markerId)
  local canAccess, shopData

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  shopData = shopItems[markerId]
  if shopData then
    callback(shopData)
  else
    MySQL.Async.fetchAll(
      "SELECT * FROM jobs_shops WHERE marker_id=@markerId",
      {
        ["@markerId"] = markerId
      },
      function(results)
        shopItems[markerId] = {}

        if results then
          for _, itemData in pairs(results) do
            itemLabel = Framework.getItemLabel(itemData.item_name)
            if not itemLabel then
              itemLabel = Framework.getWeaponLabel(itemData.item_name)
            end
            itemData.item_label = itemLabel

            shopItems[markerId][itemData.id] = itemData
          end
        end

        callback(shopItems[markerId])
      end
    )
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":jobShopPutOnSale")
AddEventHandler(Utils.eventsPrefix .. ":jobShopPutOnSale", function(itemName, itemType, quantity, price, markerId)
  local playerId, canAccess, canSell, hasEnough, itemLabel, insertId, shopItem

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  if quantity <= 0 or price <= 0 then
    return
  end

  canSell = canSellInThisShop(playerId, markerId)
  if not canSell then
    return
  end

  hasEnough = false
  itemLabel = nil

  if itemType == "item_standard" then
    hasEnough = Framework.hasPlayerEnoughOfItem(playerId, itemName, quantity)
    if hasEnough then
      itemLabel = Framework.getItemLabel(itemName)
      Framework.removeItemFromPlayer(playerId, itemName, quantity)
    end
  elseif itemType == "item_weapon" then
    hasEnough = Framework.hasPlayerWeapon(playerId, itemName)
    if hasEnough then
      itemLabel = Framework.getWeaponLabel(itemName)
      Framework.removeWeaponFromPlayer(playerId, itemName)
    end
  end

  if not hasEnough then
    return
  end

  insertId = MySQL.Sync.insert(
    "INSERT INTO jobs_shops(marker_id, item_name, item_type, item_quantity, price) VALUES (@markerId, @itemName, @itemType, @itemQuantity, @price)",
    {
      ["@itemName"] = itemName,
      ["@itemType"] = itemType,
      ["@itemQuantity"] = quantity,
      ["@price"] = price,
      ["@markerId"] = markerId
    }
  )

  if not insertId or insertId == 0 then
    return
  end

  shopItem = {
    id = insertId,
    marker_id = markerId,
    item_name = itemName,
    item_type = itemType,
    item_quantity = quantity,
    price = price,
    item_label = itemLabel
  }

  shopItems[markerId][insertId] = shopItem

  notify(
    playerId,
    getLocalizedText("job_shop:you_put_on_sale", quantity, itemLabel, Framework.groupDigits(price))
  )

  Utils.log(
    playerId,
    getLocalizedText("logs:job_shop:put_on_sale"),
    getLocalizedText("logs:job_shop:put_on_sale:description", quantity, itemLabel, Framework.groupDigits(price), markerId),
    "success",
    "job_shop"
  )
end)

RegisterNetEvent(Utils.eventsPrefix .. ":job_shop:buyItem")
AddEventHandler(Utils.eventsPrefix .. ":job_shop:buyItem", function(markerId, itemId, quantity)
  local playerId, markerData, canBuy, shopItem, canCarry, totalPrice, wasPaid, itemLabel

  playerId = source

  if not quantity or quantity <= 0 then
    return
  end

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  if markerData and markerData.allowedJob then
    if not markerData.minimumRank then
      print("^1No job/rank defined in 'Job Shop' marker ID " .. markerId .. "^7")
      return
    end
  else
    print("^1No job/rank defined in 'Job Shop' marker ID " .. markerId .. "^7")
    return
  end

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  shopItem = shopItems[markerId][itemId]
  if shopItem then
    if quantity <= shopItem.item_quantity then
      canBuy = false

      if shopItem.item_type == "item_standard" then
        canCarry = Framework.canPlayerCarryItem(playerId, shopItem.item_name, quantity)
        if canCarry then
          canBuy = true
        else
          notify(playerId, getLocalizedText("no_space"))
        end
      elseif shopItem.item_type == "item_weapon" then
        hasWeapon = Framework.hasPlayerWeapon(playerId, shopItem.item_name)
        if not hasWeapon then
          canBuy = true
        else
          notify(
            playerId,
            getLocalizedText(
              "job_shop:you_already_have_that_weapon",
              Framework.getWeaponLabel(shopItem.item_name)
            )
          )
        end
      end

      if canBuy then
        totalPrice = shopItem.price * quantity
        wasPaid = payInSomeWay(playerId, totalPrice)

        if wasPaid then
          Framework.giveMoneyToSocietyAccount(markerData.allowedJob, totalPrice)

          if shopItem.item_type == "item_standard" then
            Framework.giveItemToPlayer(playerId, shopItem.item_name, quantity)
          elseif shopItem.item_type == "item_weapon" then
            Framework.giveWeaponToPlayer(playerId, shopItem.item_name, 60)
          end

          notify(
            playerId,
            getLocalizedText(
              "job_shop:bought_item",
              quantity,
              shopItem.item_label,
              Framework.groupDigits(totalPrice)
            )
          )

          Utils.log(
            playerId,
            getLocalizedText("logs:job_shop:bought_item"),
            getLocalizedText(
              "logs:job_shop:bought_item:description",
              quantity,
              shopItem.item_label,
              Framework.groupDigits(totalPrice),
              markerId
            ),
            "success",
            "job_shop"
          )

          newQuantity = shopItem.item_quantity - quantity

          if newQuantity > 0 then
            shopItem.item_quantity = newQuantity
            MySQL.Async.execute(
              "UPDATE jobs_shops SET item_quantity=@itemQuantity WHERE id=@itemId",
              {
                ["@itemQuantity"] = newQuantity,
                ["@itemId"] = itemId
              }
            )
          else
            shopItems[markerId][itemId] = nil
            MySQL.Async.execute(
              "DELETE FROM jobs_shops WHERE id=@itemId",
              {
                ["@itemId"] = itemId
              }
            )
          end
        else
          notify(playerId, getLocalizedText("job_shop_cant_afford"))
        end
      end
    end
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":job_shop:removeFromSale")
AddEventHandler(Utils.eventsPrefix .. ":job_shop:removeFromSale", function(markerId, itemId, quantity)
  local playerId, canAccess, canSell, shopItem, itemLabel, hasEnough

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  canSell = canSellInThisShop(playerId, markerId)
  if not canSell then
    return
  end

  shopItem = shopItems[markerId][itemId]

  if shopItem.item_type == "item_weapon" then
    hasWeapon = Framework.hasPlayerWeapon(playerId, shopItem.item_name)
    if not hasWeapon then
      quantity = 1
    else
      notify(
        playerId,
        getLocalizedText(
          "job_shop:you_already_have_that_weapon",
          Framework.getWeaponLabel(shopItem.item_name)
        )
      )
      return
    end
  end

  if quantity > shopItem.item_quantity then
    return
  end

  canCarry = Framework.canPlayerCarryItem(playerId, shopItem.item_name, quantity)
  if not canCarry then
    notify(playerId, getLocalizedText("no_space"))
    return
  end

  itemLabel = nil

  if shopItem.item_type == "item_standard" then
    Framework.giveItemToPlayer(playerId, shopItem.item_name, quantity)
    itemLabel = Framework.getItemLabel(shopItem.item_name)
  elseif shopItem.item_type == "item_weapon" then
    Framework.giveWeaponToPlayer(playerId, shopItem.item_name, 60)
    itemLabel = Framework.getWeaponLabel(shopItem.item_name)
  end

  notify(playerId, getLocalizedText("job_shop:you_removed_from_sale", quantity, itemLabel))

  Utils.log(
    playerId,
    getLocalizedText("logs:job_shop:remove_from_sale"),
    getLocalizedText(
      "logs:job_shop:remove_from_sale:description",
      quantity,
      itemLabel,
      Framework.groupDigits(shopItem.price),
      markerId
    ),
    "success",
    "job_shop"
  )

  newQuantity = shopItem.item_quantity - quantity

  if newQuantity > 0 then
    shopItem.item_quantity = newQuantity
    MySQL.Async.execute(
      "UPDATE jobs_shops SET item_quantity=@itemQuantity WHERE id=@itemId",
      {
        ["@itemQuantity"] = newQuantity,
        ["@itemId"] = itemId
      }
    )
  else
    shopItems[markerId][itemId] = nil
    MySQL.Async.execute(
      "DELETE FROM jobs_shops WHERE id=@itemId",
      {
        ["@itemId"] = itemId
      }
    )
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":job_shop:addSupplies")
AddEventHandler(Utils.eventsPrefix .. ":job_shop:addSupplies", function(markerId, itemId, quantity)
  local playerId, canAccess, canSell, shopItem, itemName, itemLabel, hasEnough, newQuantity

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  canSell = canSellInThisShop(playerId, markerId)
  if canSell then
    shopItem = shopItems[markerId][itemId]
    itemName = shopItem.item_name
    itemLabel = nil
    hasEnough = false

    if shopItem.item_type == "item_standard" then
      itemLabel = Framework.getItemLabel(itemName)
      hasEnough = Framework.hasPlayerEnoughOfItem(playerId, itemName, quantity)

      if hasEnough then
        Framework.removeItemFromPlayer(playerId, itemName, quantity)
        hasEnough = true
      end
    elseif shopItem.item_type == "item_weapon" then
      itemLabel = Framework.getWeaponLabel(itemName)
      quantity = 1
      hasWeapon = Framework.hasPlayerWeapon(playerId, itemName)

      if hasWeapon then
        Framework.removeWeaponFromPlayer(playerId, itemName)
        hasEnough = true
      end
    end

    if hasEnough then
      newQuantity = shopItem.item_quantity + quantity
      shopItem.item_quantity = newQuantity

      MySQL.Async.execute(
        "UPDATE jobs_shops SET item_quantity=@newQuantity WHERE id=@id",
        {
          ["@id"] = itemId,
          ["@newQuantity"] = newQuantity
        }
      )

      notify(playerId, getLocalizedText("job_shop:added_to_supplies", quantity, itemLabel))

      Utils.log(
        playerId,
        getLocalizedText("logs:job_shop:add_to_supplies"),
        getLocalizedText(
          "logs:job_shop:add_to_supplies:description",
          quantity,
          itemLabel,
          Framework.groupDigits(shopItem.price),
          markerId
        ),
        "success",
        "job_shop"
      )
    else
      notify(playerId, getLocalizedText("not_enough", itemLabel))
    end
  else
    print("tried to supply but can't ")
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getSellableStuff", function(playerId, callback)
  local items, framework, player, inventory, itemName, itemData, weaponName, weaponData

  items = {}
  framework = Framework.getFramework()

  if framework == "ESX" then
    player = ESX.GetPlayerFromId(playerId)
    inventory = player.getInventory()

    for itemName, itemData in pairs(inventory) do
      if itemData.count > 0 then
        table.insert(items, {
          label = getLocalizedText("job_shop:item", itemData.count, itemData.label),
          value = itemData.name,
          count = itemData.count,
          type = "item_standard"
        })
      end
    end
  else
    framework = Framework.getFramework()
    if framework == "QB-core" then
      player = QBCore.Functions.GetPlayer(playerId)

      for itemName, itemData in pairs(player.PlayerData.items) do
        if itemData.amount > 0 then
          isWeapon = Framework.isItemWeapon(itemData.name)
          if not isWeapon then
            table.insert(items, {
              label = getLocalizedText("job_shop:item", itemData.amount, itemData.label),
              value = itemData.name,
              count = itemData.amount,
              type = "item_standard"
            })
          end
        end
      end

      weapons = Framework.getPlayerWeapons(playerId)
      for weaponName, weaponData in pairs(weapons) do
        table.insert(items, {
          label = weaponData.label,
          value = weaponData.name,
          count = 1,
          type = "item_weapon"
        })
      end
    end
  end

  callback(items)
end)
