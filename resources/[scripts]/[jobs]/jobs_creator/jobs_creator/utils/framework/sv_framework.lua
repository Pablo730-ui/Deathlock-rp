
function getItemMetadata(item)
  local inventoryToUse, metadata
  if not item then
    print("^1Tried to get item metadata of nil object^7")
    return {}
  end
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    metadata = item.metadata
    if not metadata then
      metadata = {}
    end
    return metadata
  else
    metadata = item.info
    if not metadata then
      metadata = {}
    end
    return metadata
  end
end

function hasPlayerEnoughOfItemFunction(playerId, itemName, quantity)
  local itemCount
  itemCount = Framework.getPlayerItemCount(playerId, itemName)
  return quantity <= itemCount
end
Framework.hasPlayerEnoughOfItem = hasPlayerEnoughOfItemFunction
function getPlayerItemCountFunction(playerId, itemName)
  local inventoryToUse, scriptName, exportObject, player, inventoryItem, itemCount
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    return exportObject.GetItemCount(exportObject, playerId, itemName)
  end
  inventoryToUse = CURRENT_FRAMEWORK
  if "ESX" == inventoryToUse then
    player = ESX.GetPlayerFromId(playerId)
    inventoryItem = player.getInventoryItem(itemName)
    if not inventoryItem then
      print("^1Item '" .. itemName .. "' doesn't exists^7")
      return 0
    end
    itemCount = inventoryItem.count
    if not itemCount then
      itemCount = inventoryItem.amount
      if not itemCount then
        itemCount = 0
      end
    end
    return itemCount
  else
    inventoryToUse = CURRENT_FRAMEWORK
    if "QB-core" == inventoryToUse then
      scriptName = Utils.getScriptName("qb-inventory")
      if Utils.doesExportExist(scriptName, "GetItemCount") then
        exportObject = exports[scriptName]
        return exportObject.GetItemCount(exportObject, playerId, itemName)
      end
      player = QBCore.Functions.GetPlayer(playerId)
      inventoryItem = player.Functions.GetItemByName(itemName)
      if not inventoryItem then
        return 0
      end
      itemCount = inventoryItem.count
      if not itemCount then
        itemCount = inventoryItem.amount
        if not itemCount then
          itemCount = 0
        end
      end
      return itemCount
    end
  end
end
Framework.getPlayerItemCount = getPlayerItemCountFunction

function getPlayerJobNameFunction(playerId)
  local player = nil
  if "ESX" == CURRENT_FRAMEWORK then
    player = ESX.GetPlayerFromId(playerId)
    if player then
      return player.job.name
    end
  else
    print("^5[DEBUG] framework: " .. CURRENT_FRAMEWORK)
    if "QB-core" == CURRENT_FRAMEWORK then
      player = QBCore.Functions.GetPlayer(playerId)
      if player then
        return player.PlayerData.job.name
      end
    end
  end
end
Framework.getPlayerJobName = getPlayerJobNameFunction

function getPlayerJobGradeFunction(playerId)
  local framework, player
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    if player then
      return player.job.grade
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      if player then
        return player.PlayerData.job.grade.level
      end
    end
  end
end
Framework.getPlayerJobGrade = getPlayerJobGradeFunction
function registerUsableItemFunction(itemName, callback)
  local framework
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    ESX.RegisterUsableItem(itemName, callback)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      QBCore.Functions.CreateUseableItem(itemName, callback)
    end
  end
end
Framework.registerUsableItem = registerUsableItemFunction
function getItemLabelFunction(itemName)
  local inventoryToUse, scriptName, exportObject, item, label
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    item = exportObject.Items(exportObject, itemName)
    if not item then
      print("^1OX Inventory couldn't get item label for item '" .. itemName .. "'^7")
      return itemName
    end
    return item.label
  end
  inventoryToUse = CURRENT_FRAMEWORK
  if "ESX" == inventoryToUse then
    label = ESX.GetItemLabel(itemName)
    if label then
      return label
    else
      print([[
======================]])
      print("^1ESX.GetItemLabel('" .. itemName .. "') returned nil instead of the item label, this will probably cause issues. Possible reasons:^7")
      print("^7- Item doesn't exist or you didn't create it properly")
      print("^7- ESX.GetItemLabel function of es_extended doesn't work properly for unknown reasons")
      print("^3Note: The issue is not caused by this script, but by ESX.GetItemLabel function, the script developer can't do anything about this")
      print("^7======================\n")
      return itemName
    end
  else
    inventoryToUse = CURRENT_FRAMEWORK
    if "QB-core" == inventoryToUse then
      item = QBCore.Shared.Items[itemName]
      if item then
        label = item.label
        if label then
          return label
        end
      else
        print([[
======================]])
        print("^1Couldn't get the item label of '" .. itemName .. "', this will probably cause issues. Possible reasons:^7")
        print("^7- Item doesn't exist or you didn't create it properly")
        print("^7- Something wrong in qb-core installation or the default behaviour was modified")
        print("^3Note: The issue is not caused by this script, the script developer can't do anything about this")
        print("^7======================\n")
        return itemName
      end
    end
  end
end
Framework.getItemLabel = getItemLabelFunction
function getAllItemsFromDB()
  local promiseObj, itemsDict, query
  promiseObj = promise.new()
  MySQL.Async.fetchAll("SELECT name, label FROM items", {}, function(results)
    itemsDict = {}
    for i = 1, #results do
      itemsDict[results[i].name] = results[i]
    end
    promiseObj:resolve(itemsDict)
  end)
  return Citizen.Await(promiseObj)
end

function getAllItemsFunction()
  local framework, items, inventoryToUse, scriptName, exportObject, itemCount
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    items = ESX.Items
    inventoryToUse = INVENTORY_TO_USE
    if "ox_inventory" == inventoryToUse then
      scriptName = Utils.getScriptName("ox_inventory")
      if not scriptName then
        print("^ox_inventory script name is not set in EXTERNAL_SCRIPTS_NAMES^7")
      end
      exportObject = exports[scriptName]
      items = exportObject.Items(exportObject)
    end
    itemCount = 0
    for k, v in pairs(items) do
      itemCount = itemCount + 1
      break
    end
    if 0 == itemCount then
      items = getAllItemsFromDB()
    end
    return items
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      items = QBCore.Shared.Items
      return items
    end
  end
end
Framework.getAllItems = getAllItemsFunction
function getAllWeaponsFunction()
  local framework
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    return ESX.GetWeaponList()
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      return QBCore.Shared.Weapons
    end
  end
end
Framework.getAllWeapons = getAllWeaponsFunction
function canPlayerCarryItemFunction(playerId, itemName, quantity)
  local canAlwaysCarry, inventoryToUse, scriptName, exportObject, player, inventoryItem, canCarry, itemLimit
  if config.canAlwaysCarryItem then
    return true
  end
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    return exportObject.CanCarryItem(exportObject, playerId, itemName, quantity)
  end
  canCarry = false
  inventoryToUse = CURRENT_FRAMEWORK
  if "ESX" == inventoryToUse then
    player = ESX.GetPlayerFromId(playerId)
    if player.canCarryItem then
      return player.canCarryItem(itemName, quantity)
    end
    inventoryItem = player.getInventoryItem(itemName)
    if not inventoryItem then
      return true
    end
    itemLimit = inventoryItem.limit
    canCarry = -1 == itemLimit
  else
    inventoryToUse = CURRENT_FRAMEWORK
    if "QB-core" == inventoryToUse then
      scriptName = Utils.getScriptName("qb-inventory")
      if not Utils.doesExportExist(scriptName, "CanAddItem") then
        return true
      end
      exportObject = exports[scriptName]
      return exportObject.CanAddItem(exportObject, playerId, itemName, quantity)
    end
  end
  return canCarry
end
Framework.canPlayerCarryItem = canPlayerCarryItemFunction
function giveItemToPlayerFunction(playerId, itemName, quantity, metadata)
  local canCarry, inventoryToUse, scriptName, exportObject, player, success, errorMsg
  canCarry = Framework.canPlayerCarryItem(playerId, itemName, quantity)
  if not canCarry then
    return false
  end
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    success, errorMsg = exportObject.AddItem(exportObject, playerId, itemName, quantity, metadata)
    if not success then
      print("^1OX Inventory couldn't give item to player: " .. errorMsg .. "^7")
    end
    return success
  end
  inventoryToUse = CURRENT_FRAMEWORK
  if "ESX" == inventoryToUse then
    player = ESX.GetPlayerFromId(playerId)
    player.addInventoryItem(itemName, quantity)
    return true
  else
    inventoryToUse = CURRENT_FRAMEWORK
    if "QB-core" == inventoryToUse then
      player = QBCore.Functions.GetPlayer(playerId)
      return player.Functions.AddItem(itemName, quantity, false, metadata)
    end
  end
end
Framework.giveItemToPlayer = giveItemToPlayerFunction
function removeItemFromPlayerFunction(playerId, itemName, quantity, metadata)
  local inventoryToUse, scriptName, exportObject, player, inventoryItem, itemCount, success, errorMsg
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    success, errorMsg = exportObject.RemoveItem(exportObject, playerId, itemName, quantity, metadata)
    if not success then
      print("^1OX Inventory couldn't remove item from player: " .. errorMsg .. "^7")
    end
    return success
  end
  inventoryToUse = CURRENT_FRAMEWORK
  if "ESX" == inventoryToUse then
    player = ESX.GetPlayerFromId(playerId)
    inventoryItem = player.getInventoryItem(itemName)
    itemCount = inventoryItem.count
    if quantity <= itemCount then
      player.removeInventoryItem(itemName, quantity)
      return true
    else
      return false
    end
  else
    inventoryToUse = CURRENT_FRAMEWORK
    if "QB-core" == inventoryToUse then
      player = QBCore.Functions.GetPlayer(playerId)
      if player then
        return player.Functions.RemoveItem(itemName, quantity)
      else
        return false
      end
    end
  end
end
Framework.removeItemFromPlayer = removeItemFromPlayerFunction
function doesItemExistsFunction(itemName)
  local skipCheck, inventoryToUse, scriptName, exportObject, item, allItems
  if not itemName then
    return false
  end
  if SKIP_ITEM_EXISTS_CHECK then
    return true
  end
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    item = exportObject.Items(exportObject, itemName)
    return nil ~= item
  end
  inventoryToUse = CURRENT_FRAMEWORK
  if "ESX" == inventoryToUse then
    allItems = Framework.getAllItems()
    return allItems[itemName] ~= nil
  else
    inventoryToUse = CURRENT_FRAMEWORK
    if "QB-core" == inventoryToUse then
      item = QBCore.Shared.Items[itemName]
      return nil ~= item
    end
  end
end
Framework.doesItemExists = doesItemExistsFunction
function getAllJobsFunction()
  local framework
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    return ESX.Jobs
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      return QBCore.Shared.Jobs
    end
  end
end
Framework.getAllJobs = getAllJobsFunction
function giveAccountMoneyToPlayerFunction(playerId, accountName, amount)
  local framework, player, account
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    account = player.getAccount(accountName)
    if account then
      player.addAccountMoney(accountName, amount)
    elseif "money" == accountName then
      player.addMoney(amount)
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      if player then
        if "black_money" == accountName then
          Framework.giveBlackMoneyValue(playerId, amount)
        else
          player.Functions.AddMoney(accountName, amount)
        end
      end
    end
  end
end
Framework.giveAccountMoneyToPlayer = giveAccountMoneyToPlayerFunction

function giveCashToPlayerFunction(playerId, amount)
  local framework, player
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    player.addMoney(amount)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      player.Functions.AddMoney("cash", amount)
    end
  end
end
Framework.giveCashToPlayer = giveCashToPlayerFunction
function giveAccountMoneyToIdentifierFunction(identifier, accountName, amount)
  local framework, player, promiseObj, accountsJson, accounts, playerSource, playerObj
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromIdentifier(identifier)
    if player then
      player.addAccountMoney(accountName, amount)
      return true
    else
      promiseObj = promise.new()
      MySQL.Async.fetchScalar("SELECT accounts FROM users WHERE identifier=@identifier", {
        ["@identifier"] = identifier
      }, function(accountsJson)
        if accountsJson then
          accounts = json.decode(accountsJson)
          accounts[accountName] = accounts[accountName] + amount
          MySQL.Async.execute("UPDATE users SET accounts=@accounts WHERE identifier=@identifier", {
            ["@identifier"] = identifier,
            ["@accounts"] = json.encode(accounts)
          }, function(affectedRows)
            promiseObj:resolve(affectedRows > 0)
          end)
        else
          promiseObj:resolve(false)
        end
      end)
      return Citizen.Await(promiseObj)
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      playerSource = QBCore.Functions.GetSource(identifier)
      if playerSource and 0 ~= playerSource then
        playerObj = QBCore.Functions.GetPlayer(playerSource)
        if playerObj then
          playerObj.Functions.AddMoney(accountName, amount)
          return true
        else
          return false
        end
      else
        promiseObj = promise.new()
        MySQL.Async.fetchScalar("SELECT money FROM players WHERE license=@identifier", {
          ["@identifier"] = identifier
        }, function(moneyJson)
          if moneyJson then
            accounts = json.decode(moneyJson)
            accounts[accountName] = accounts[accountName] + amount
            MySQL.Async.execute("UPDATE players SET money=@accounts WHERE license=@identifier", {
              ["@identifier"] = identifier,
              ["@accounts"] = json.encode(accounts)
            }, function(affectedRows)
              promiseObj:resolve(affectedRows > 0)
            end)
          else
            promiseObj:resolve(false)
          end
        end)
        return Citizen.Await(promiseObj)
      end
    end
  end
end
Framework.giveAccountMoneyToIdentifier = giveAccountMoneyToIdentifierFunction
function removeAccountMoneyFromIdentifierFunction(identifier, accountName, amount)
  local framework, player, account, promiseObj, accountsJson, accounts, playerObj
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromIdentifier(identifier)
    if player then
      account = player.getAccount(accountName)
      if account then
        player.removeAccountMoney(accountName, amount)
        return true
      else
        if "money" == accountName then
          player.removeMoney(amount)
          return true
        end
        return false
      end
    else
      promiseObj = promise.new()
      MySQL.Async.fetchScalar("SELECT accounts FROM users WHERE identifier=@identifier", {
        ["@identifier"] = identifier
      }, function(accountsJson)
        if accountsJson then
          accounts = json.decode(accountsJson)
          accounts[accountName] = accounts[accountName] - amount
          MySQL.Async.execute("UPDATE users SET accounts=@accounts WHERE identifier=@identifier", {
            ["@identifier"] = identifier,
            ["@accounts"] = json.encode(accounts)
          }, function(affectedRows)
            promiseObj:resolve(affectedRows > 0)
          end)
        else
          promiseObj:resolve(false)
        end
      end)
      return Citizen.Await(promiseObj)
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      playerObj = QBCore.Functions.GetPlayerByCitizenId(identifier)
      if playerObj then
        playerObj.Functions.RemoveMoney(accountName, amount)
        return true
      else
        promiseObj = promise.new()
        MySQL.Async.fetchScalar("SELECT money FROM players WHERE citizenid=@citizenid", {
          ["@citizenid"] = identifier
        }, function(moneyJson)
          if moneyJson then
            accounts = json.decode(moneyJson)
            accounts[accountName] = accounts[accountName] - amount
            MySQL.Async.execute("UPDATE players SET money=@accounts WHERE citizenid=@citizenid", {
              ["@citizenid"] = identifier,
              ["@accounts"] = json.encode(accounts)
            }, function(affectedRows)
              promiseObj:resolve(affectedRows > 0)
            end)
          else
            promiseObj:resolve(false)
          end
        end)
        return Citizen.Await(promiseObj)
      end
    end
  end
end
Framework.removeAccountMoneyFromIdentifier = removeAccountMoneyFromIdentifierFunction

function removeAccountMoneyFromPlayerFunction(playerId, accountName, amount)
  local identifier
  identifier = Framework.getPlayerCharIdentifier(playerId)
  return Framework.removeAccountMoneyFromCharIdentifier(identifier, accountName, amount)
end
Framework.removeAccountMoneyFromPlayer = removeAccountMoneyFromPlayerFunction
function removeAccountMoneyFromCharIdentifierFunction(identifier, accountName, amount)
  local framework, player, playerSource, playerObj
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromIdentifier(identifier)
    if not player then
      return Framework.removeAccountMoneyFromOfflineCharIdentifier(identifier, accountName, amount)
    end
    player.removeAccountMoney(accountName, amount)
    return true
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      playerSource = QBCore.Functions.GetSource(identifier)
      if not playerSource or 0 == playerSource then
        return Framework.removeAccountMoneyFromOfflineCharIdentifier(identifier, accountName, amount)
      end
      playerObj = QBCore.Functions.GetPlayer(playerSource)
      if not playerObj then
        return false
      end
      playerObj.Functions.RemoveMoney(accountName, amount)
      return true
    end
  end
end
Framework.removeAccountMoneyFromCharIdentifier = removeAccountMoneyFromCharIdentifierFunction
function getAccountMoneyFromIdentifierFunction(identifier, accountName)
  local framework, player, account, promiseObj, accountsJson, accounts, playerObj
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromIdentifier(identifier)
    if player then
      account = player.getAccount(accountName)
      if account then
        return account.money
      elseif "money" == accountName then
        return player.getMoney()
      end
    else
      promiseObj = promise.new()
      MySQL.Async.fetchScalar("SELECT accounts FROM users WHERE identifier=@identifier", {
        ["@identifier"] = identifier
      }, function(accountsJson)
        if accountsJson then
          accounts = json.decode(accountsJson)
          promiseObj:resolve(accounts[accountName])
        else
          promiseObj:resolve(0)
        end
      end)
      return Citizen.Await(promiseObj)
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      playerObj = QBCore.Functions.GetPlayerByCitizenId(identifier)
      if playerObj then
        return playerObj.PlayerData.money[accountName]
      else
        promiseObj = promise.new()
        MySQL.Async.fetchScalar("SELECT money FROM players WHERE citizenid=@citizenid", {
          ["@citizenid"] = identifier
        }, function(moneyJson)
          if moneyJson then
            accounts = json.decode(moneyJson)
            promiseObj:resolve(accounts[accountName])
          else
            promiseObj:resolve(0)
          end
        end)
        return Citizen.Await(promiseObj)
      end
    end
  end
end
Framework.getAccountMoneyFromIdentifier = getAccountMoneyFromIdentifierFunction
function getAccountMoneyFromPlayerFunction(playerId, accountName)
  local identifier
  identifier = Framework.getIdentifier(playerId)
  return Framework.getAccountMoneyFromIdentifier(identifier, accountName)
end
Framework.getAccountMoneyFromPlayer = getAccountMoneyFromPlayerFunction

function getSourceFromIdentifierFunction(identifier)
  local framework, player
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromIdentifier(identifier)
    if player then
      return player.source
    else
      return nil
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      playerSource = QBCore.Functions.GetSource(identifier)
      if playerSource and 0 ~= playerSource then
        return playerSource
      else
        return nil
      end
    end
  end
end
Framework.getIdentifierPlayerId = getSourceFromIdentifierFunction
local function createJobAccountQBX(jobName)
  return Utils.callScriptExport("qb-banking", "CreateJobAccount", jobName, 0)
end

local function doesBankAccountExist(jobName)
  return MySQL.Sync.fetchScalar("SELECT 1 FROM bank_accounts WHERE account_name=@jobName", {
    ["@jobName"] = jobName
  })
end

local function doesRenewedBankAccountExist(jobName)
  local exportObject, account
  exportObject = exports["Renewed-Banking"]
  account = exportObject.GetJobAccount(exportObject, jobName)
  return nil ~= account
end

local function ensureRenewedBankAccountExists(jobName)
  local accountExists, accountData, exportObject
  accountExists = doesRenewedBankAccountExist(jobName)
  if accountExists then
    return
  end
  accountData = {}
  accountData.label = jobName
  accountData.name = jobName
  exportObject = exports["Renewed-Banking"]
  exportObject.CreateJobAccount(exportObject, accountData, 0)
end

function giveMoneyToSocietyAccountFunction(jobName, amount)
  local bankingModule, subframework, promiseObj, hasResolved, societyAccountName, exportObject, accountExists, createResult
  bankingModule = config.modules.banking
  if "default" ~= bankingModule then
    return Utils.callModuleFunc("banking", "giveMoneyToSociety", jobName, amount)
  end
  subframework = SUBFRAMEWORK
  if "QBX" == subframework then
    ensureRenewedBankAccountExists(jobName)
    exportObject = exports["Renewed-Banking"]
    return exportObject.addAccountMoney(exportObject, jobName, amount)
  end
  bankingModule = CURRENT_FRAMEWORK
  if "ESX" == bankingModule then
    promiseObj = promise.new()
    hasResolved = false
    societyAccountName = "society_" .. jobName
    TriggerEvent(EXTERNAL_EVENTS_NAMES["esx_addonaccount:getSharedAccount"], societyAccountName, function(account)
      if hasResolved then
        return
      else
        hasResolved = true
      end
      if account then
        account.addMoney(amount)
        promiseObj:resolve(true)
      else
        promiseObj:resolve(false)
      end
    end)
    SetTimeout(500, function()
      if not hasResolved then
        promiseObj:resolve(false)
      end
    end)
    return Citizen.Await(promiseObj)
  else
    bankingModule = CURRENT_FRAMEWORK
    if "QB-core" == bankingModule then
      accountExists = doesBankAccountExist(jobName)
      if accountExists then
        Utils.callScriptExport("qb-banking", "AddMoney", jobName, amount)
      else
        createResult = createJobAccountQBX(jobName)
        if createResult then
          Framework.giveMoneyToSocietyAccount(jobName, amount)
        else
          print("^1'" .. jobName .. "' doesn't exist in qb-banking, you have to add it in bank_accounts table in the database^7")
          return false
        end
      end
      return true
    end
  end
end
Framework.giveMoneyToSocietyAccount = giveMoneyToSocietyAccountFunction
function getSocietyAccountMoneyFunction(jobName)
  local bankingModule, subframework, promiseObj, hasResolved, societyAccountName, exportObject
  bankingModule = config.modules.banking
  if "default" ~= bankingModule then
    return Utils.callModuleFunc("banking", "getSocietyMoney", jobName)
  end
  subframework = SUBFRAMEWORK
  if "QBX" == subframework then
    ensureRenewedBankAccountExists(jobName)
    exportObject = exports["Renewed-Banking"]
    return exportObject.getAccountMoney(exportObject, jobName)
  end
  bankingModule = CURRENT_FRAMEWORK
  if "ESX" == bankingModule then
    promiseObj = promise.new()
    societyAccountName = "society_" .. jobName
    hasResolved = false
    TriggerEvent(EXTERNAL_EVENTS_NAMES["esx_addonaccount:getSharedAccount"], societyAccountName, function(account)
      if hasResolved then
        return
      else
        hasResolved = true
      end
      if account then
        promiseObj:resolve(account.money)
      else
        promiseObj:resolve(false)
      end
    end)
    SetTimeout(500, function()
      if not hasResolved then
        promiseObj:resolve(false)
      end
    end)
    return Citizen.Await(promiseObj)
  else
    bankingModule = CURRENT_FRAMEWORK
    if "QB-core" == bankingModule then
      return Utils.callScriptExport("qb-banking", "GetAccountBalance", jobName)
    end
  end
end
Framework.getSocietyAccountMoney = getSocietyAccountMoneyFunction
function removeMoneyFromSocietyAccountFunction(jobName, amount)
  local bankingModule, subframework, promiseObj, hasResolved, societyAccountName, exportObject, accountExists, createResult
  bankingModule = config.modules.banking
  if "default" ~= bankingModule then
    return Utils.callModuleFunc("banking", "removeMoneyFromSociety", jobName, amount)
  end
  subframework = SUBFRAMEWORK
  if "QBX" == subframework then
    ensureRenewedBankAccountExists(jobName)
    exportObject = exports["Renewed-Banking"]
    return exportObject.removeAccountMoney(exportObject, jobName, amount)
  end
  bankingModule = CURRENT_FRAMEWORK
  if "ESX" == bankingModule then
    promiseObj = promise.new()
    hasResolved = false
    societyAccountName = "society_" .. jobName
    TriggerEvent(EXTERNAL_EVENTS_NAMES["esx_addonaccount:getSharedAccount"], societyAccountName, function(account)
      if hasResolved then
        return
      else
        hasResolved = true
      end
      if account then
        account.removeMoney(amount)
        promiseObj:resolve(true)
      else
        promiseObj:resolve(false)
      end
    end)
    SetTimeout(500, function()
      if not hasResolved then
        promiseObj:resolve(false)
      end
    end)
    return Citizen.Await(promiseObj)
  else
    bankingModule = CURRENT_FRAMEWORK
    if "QB-core" == bankingModule then
      accountExists = doesBankAccountExist(jobName)
      if accountExists then
        Utils.callScriptExport("qb-banking", "RemoveMoney", jobName, amount)
      else
        createResult = createJobAccountQBX(jobName)
        if createResult then
          Framework.removeMoneyFromSocietyAccount(jobName, amount)
        else
          print("^1'" .. jobName .. "' doesn't exist in qb-banking, you have to add it in bank_accounts table in the database^7")
          return false
        end
      end
      return true
    end
  end
end
Framework.removeMoneyFromSocietyAccount = removeMoneyFromSocietyAccountFunction
function getIdentifierFunction(playerId)
  local framework, player
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    return player.identifier
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      if player then
        return player.PlayerData.license
      end
    end
  end
end
Framework.getIdentifier = getIdentifierFunction

function getJobLabelFunction(jobName)
  local framework, job, label
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    job = ESX.Jobs[jobName]
    if job then
      label = job.label
      if label then
        return label
      end
    end
    return nil
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      job = QBCore.Shared.Jobs[jobName]
      if job then
        label = job.label
        if label then
          return label
        end
      end
      return nil
    end
  end
end
Framework.getJobLabel = getJobLabelFunction

function isPlayerLoadedFunction(playerId)
  local getPlayerFunc, player
  getPlayerFunc = nil
  if CURRENT_FRAMEWORK == "ESX" then
    getPlayerFunc = ESX.GetPlayerFromId
  else
    getPlayerFunc = QBCore.Functions.GetPlayer
  end
  if getPlayerFunc then
    player = getPlayerFunc(playerId)
    return nil ~= player
  else
    print("^2No function for getPlayer^7")
    return false
  end
end
Framework.isPlayerLoaded = isPlayerLoadedFunction
function giveWeaponToPlayerFunction(playerId, weaponName, ammo)
  local framework, player, inventoryToUse
  if not ammo then
    ammo = 0
  end
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    inventoryToUse = INVENTORY_TO_USE
    if "ox_inventory" == inventoryToUse then
      player.addInventoryItem(weaponName, 1)
    else
      player.addWeapon(weaponName, ammo)
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      if player then
        player.Functions.AddItem(weaponName, 1)
      end
    end
  end
end
Framework.giveWeaponToPlayer = giveWeaponToPlayerFunction

function removeWeaponFromPlayerFunction(playerId, weaponName)
  local framework, player
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    player.removeWeapon(weaponName)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      player.Functions.RemoveItem(weaponName, 1)
    end
  end
end
Framework.removeWeaponFromPlayer = removeWeaponFromPlayerFunction
function getBlackMoneyValueFunction(playerId)
  local blackMoneyConfig, worthType, inventoryToUse, scriptName, exportObject, slots, totalValue, slot, metadata, count, player, items, item, itemMetadata
  if not config or not config.blackMoney then
    print("^1Missing black money settings in getBlackMoneyValue^7")
    return 0
  end
  blackMoneyConfig = config.blackMoney
  worthType = blackMoneyConfig.worthType
  if "quantity" == worthType then
    return Framework.getPlayerGenericObjectCount(playerId, blackMoneyConfig.object.name, blackMoneyConfig.object.type)
  end
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    slots = exportObject.Search(exportObject, playerId, "slots", blackMoneyConfig.object.name)
    totalValue = 0
    for i = 1, #slots do
      slot = slots[i]
      if slot.metadata and slot.metadata[blackMoneyConfig.metadataFieldId] then
        count = slot.metadata[blackMoneyConfig.metadataFieldId]
      else
        count = slot.count or 0
      end
      totalValue = totalValue + count
    end
    return totalValue
  end
  if CURRENT_FRAMEWORK == "QB-core" then
    player = QBCore.Functions.GetPlayer(playerId)
    items = player.Functions.GetItemsByName("markedbills")
    totalValue = 0
    for k, item in pairs(items) do
      itemMetadata = getItemMetadata(item)
      totalValue = totalValue + itemMetadata.worth
    end
    return totalValue
  end
  return 0
end
Framework.getBlackMoneyValue = getBlackMoneyValueFunction
function clearBlackMoneyFromPlayerFunction(playerId)
  local blackMoneyConfig, blackMoneyValue, worthType, itemCount, inventoryToUse, scriptName, exportObject, player, items, item
  blackMoneyConfig = config.blackMoney
  if not blackMoneyConfig then
    print("^1Missing black money settings in clearBlackMoneyFromPlayer^7")
    return false
  end
  blackMoneyValue = Framework.getBlackMoneyValue(playerId)
  worthType = blackMoneyConfig.worthType
  if "quantity" == worthType then
    return Framework.removeGenericObjectFromPlayerId(playerId, blackMoneyConfig.object.name, blackMoneyConfig.object.type, blackMoneyValue)
  end
  itemCount = Framework.getPlayerGenericObjectCount(playerId, blackMoneyConfig.object.name, blackMoneyConfig.object.type)
  inventoryToUse = INVENTORY_TO_USE
  if "ox_inventory" == inventoryToUse then
    scriptName = Utils.getScriptName("ox_inventory")
    exportObject = exports[scriptName]
    return exportObject.RemoveItem(exportObject, playerId, blackMoneyConfig.object.name, itemCount)
  end
  if CURRENT_FRAMEWORK == "QB-core" then
    player = QBCore.Functions.GetPlayer(playerId)
    items = player.Functions.GetItemsByName(blackMoneyConfig.object.name)
    for k, item in pairs(items) do
      exports["qb-inventory"].RemoveItem(exports["qb-inventory"], playerId, blackMoneyConfig.object.name, item.amount, item.slot)
    end
    return true
  end
  Framework.removeGenericObjectFromPlayerId(playerId, blackMoneyConfig.object.name, blackMoneyConfig.object.type, blackMoneyValue)
  return true
end
Framework.clearBlackMoneyFromPlayer = clearBlackMoneyFromPlayerFunction
function removeBlackMoneyValueFunction(playerId, amount)
  local blackMoneyConfig, objectData, worthType, currentValue, newValue, metadata
  blackMoneyConfig = config.blackMoney
  if not blackMoneyConfig then
    print("^1Missing black money settings in removeBlackMoneyValue^7")
    return false
  end
  objectData = {}
  objectData.name = blackMoneyConfig.object.name
  objectData.type = blackMoneyConfig.object.type
  worthType = blackMoneyConfig.worthType
  if "quantity" == worthType then
    return Framework.removeGenericObjectFromPlayerId(playerId, objectData.name, objectData.type, amount)
  end
  currentValue = Framework.getBlackMoneyValue(playerId)
  newValue = currentValue - amount
  Framework.clearBlackMoneyFromPlayer(playerId)
  if newValue < 0 then
    return
  end
  metadata = {}
  metadata[blackMoneyConfig.metadataFieldId] = newValue
  objectData.metadata = metadata
  Framework.giveGenericObjectToPlayerId(playerId, objectData, 1, false)
end
Framework.removeBlackMoneyValue = removeBlackMoneyValueFunction

function giveBlackMoneyValueFunction(playerId, amount)
  local blackMoneyConfig, objectData, worthType, currentValue, newValue, metadata
  blackMoneyConfig = config.blackMoney
  if not blackMoneyConfig then
    print("^1Missing black money settings in giveBlackMoneyValue^7")
    return false
  end
  objectData = {}
  objectData.name = blackMoneyConfig.object.name
  objectData.type = blackMoneyConfig.object.type
  worthType = blackMoneyConfig.worthType
  if "quantity" == worthType then
    return Framework.giveGenericObjectToPlayerId(playerId, objectData, amount)
  end
  currentValue = Framework.getBlackMoneyValue(playerId)
  newValue = currentValue + amount
  Framework.clearBlackMoneyFromPlayer(playerId)
  metadata = {}
  metadata[blackMoneyConfig.metadataFieldId] = newValue
  objectData.metadata = metadata
  Framework.giveGenericObjectToPlayerId(playerId, objectData, 1, false)
end
Framework.giveBlackMoneyValue = giveBlackMoneyValueFunction

function getAllAccountsFunction()
  local framework, subframework
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    return ESX.GetConfig().Accounts
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      subframework = SUBFRAMEWORK
      if nil == subframework then
        return QBCore.Config.Money.MoneyTypes
      else
        return QBCore.Config.money.moneyTypes
      end
    end
  end
end
Framework.getAllAccounts = getAllAccountsFunction
function getAccountLabelFunction(accountName)
  local framework, account, accountType
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    account = ESX.GetConfig().Accounts[accountName]
    if not account then
      return accountName
    end
    accountType = type(account)
    if "table" == accountType then
      return account.label
    else
      return account
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      return accountName
    end
  end
end
Framework.getAccountLabel = getAccountLabelFunction
function getPlayerWeaponsFunction(playerId)
  local weapons, framework, player, loadout, item, weaponHash, weaponData
  weapons = {}
  framework = Framework.getFramework()
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    loadout = player.getLoadout()
    weapons = loadout
  else
    framework = Framework.getFramework()
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      for slot, item in pairs(player.PlayerData.items) do
        weaponHash = GetHashKey(item.name)
        weaponData = QBCore.Shared.Weapons[weaponHash]
        if weaponData then
          table.insert(weapons, {
            name = item.name,
            label = item.label
          })
        end
      end
    end
  end
  return weapons
end
Framework.getPlayerWeapons = getPlayerWeaponsFunction
function isItemWeaponFunction(itemName)
  local framework, weaponHash, weaponData
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    return false
  else
    weaponHash = GetHashKey(itemName)
    weaponData = QBCore.Shared.Weapons[weaponHash]
    return nil ~= weaponData
  end
end
Framework.isItemWeapon = isItemWeaponFunction
function hasPlayerWeaponComponentFunction(playerId, weaponName, componentName)
  local framework, player, item
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    return player.hasWeaponComponent(weaponName, componentName)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      item = player.Functions.GetItemByName(componentName)
      return nil ~= item
    end
  end
end
Framework.hasPlayerWeaponComponent = hasPlayerWeaponComponentFunction

local function getQBWeaponsAttachments()
  local promiseObj, hasResolved
  promiseObj = promise.new()
  hasResolved = false
  TriggerEvent("qb-weapons:getWeaponsAttachments", function(attachments)
    hasResolved = true
    promiseObj:resolve(attachments)
  end)
  SetTimeout(1000, function()
    if not hasResolved then
      promiseObj:resolve(false)
    end
  end)
  return Citizen.Await(promiseObj)
end

function doesComponentExistsForWeaponFunction(weaponName, componentName)
  local framework, weaponComponent, promiseObj, hasResolved, attachments, weaponNameUpper, componentData, scriptName
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    weaponComponent = ESX.GetWeaponComponent(weaponName, componentName)
    return nil ~= weaponComponent
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      promiseObj = promise.new()
      hasResolved = false
      attachments = getQBWeaponsAttachments()
      weaponNameUpper = string.upper(weaponName)
      componentData = attachments[weaponNameUpper]
      if componentData then
        promiseObj:resolve(nil ~= componentData[componentName])
      else
        scriptName = Utils.getScriptName("qb-weapons")
        print("^1Weapon " .. weaponNameUpper .. " not found in " .. scriptName .. "/config.lua^7")
      end
      return Citizen.Await(promiseObj)
    end
  end
end
Framework.doesComponentExistsForWeapon = doesComponentExistsForWeaponFunction
function getWeaponComponentLabelFunction(weaponName, componentName)
  local framework, weaponComponent, attachments, weaponNameUpper, componentData, label, scriptName
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    weaponComponent = ESX.GetWeaponComponent(weaponName, componentName)
    return weaponComponent.label
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      attachments = getQBWeaponsAttachments()
      weaponNameUpper = string.upper(weaponName)
      componentData = attachments[weaponNameUpper]
      if componentData then
        componentData = componentData[componentName]
        label = componentData.label
        if not label then
          label = Framework.getItemLabel(componentData.item)
        end
        return label
      else
        scriptName = Utils.getScriptName("qb-weapons")
        print("^1Weapon " .. weaponNameUpper .. " not found in " .. scriptName .. "/config.lua^7")
      end
      return componentName
    end
  end
end
Framework.getWeaponComponentLabel = getWeaponComponentLabelFunction
function hasPlayerWeaponFunction(playerId, weaponName)
  local framework, player, inventoryToUse, scriptName, exportObject, item
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    inventoryToUse = INVENTORY_TO_USE
    if "default" == inventoryToUse then
      return player.hasWeapon(weaponName)
    else
      inventoryToUse = INVENTORY_TO_USE
      if "ox_inventory" == inventoryToUse then
        scriptName = Utils.getScriptName("ox_inventory")
        if not scriptName then
          print("^ox_inventory script name is not set in EXTERNAL_SCRIPTS_NAMES^7")
        end
        exportObject = exports[scriptName]
        return not exportObject.CanCarryItem(exportObject, playerId, weaponName, 1)
      end
    end
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      item = player.Functions.GetItemByName(weaponName)
      return nil ~= item
    end
  end
end
Framework.hasPlayerWeapon = hasPlayerWeaponFunction

function getWeaponLabelFunction(weaponName)
  local framework
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    return ESX.GetWeaponLabel(weaponName)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      return Framework.getItemLabel(weaponName)
    end
  end
end
Framework.getWeaponLabel = getWeaponLabelFunction
local weaponComponentMapping = {}
weaponComponentMapping.clip_extended = "extendedclip"
weaponComponentMapping.clip_drum = "drum"
weaponComponentMapping.flashlight = "flashlight"
weaponComponentMapping.suppressor = "suppressor"
weaponComponentMapping.scope = "scope"
weaponComponentMapping.scope_advanced = "advancedscope"
weaponComponentMapping.grip = "grip"
weaponComponentMapping.clip_box = "drum"
weaponComponentMapping.luxary_finish = "luxuryfinish"

function removeWeaponComponentFromPlayerFunction(playerId, weaponName, componentType)
  local framework, player, attachments, weaponNameUpper, weaponAttachments, componentKey, componentItem
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    player.removeWeaponComponent(weaponName, componentType)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      attachments = getQBWeaponsAttachments()
      weaponNameUpper = string.upper(weaponName)
      weaponAttachments = attachments[weaponNameUpper]
      componentKey = weaponComponentMapping[componentType]
      componentItem = weaponAttachments[componentKey]
      componentItem = componentItem.item
      player.Functions.RemoveItem(componentItem, 1)
    end
  end
end
Framework.removeWeaponComponentFromPlayer = removeWeaponComponentFromPlayerFunction

function addWeaponComponentToPlayerFunction(playerId, weaponName, componentType)
  local framework, player, attachments, weaponNameUpper, weaponAttachments, componentKey, componentItem
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    player.addWeaponComponent(weaponName, componentType)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      attachments = getQBWeaponsAttachments()
      weaponNameUpper = string.upper(weaponName)
      weaponAttachments = attachments[weaponNameUpper]
      componentKey = weaponComponentMapping[componentType]
      componentItem = weaponAttachments[componentKey]
      componentItem = componentItem.item
      player.Functions.AddItem(componentItem, 1)
    end
  end
end
Framework.addWeaponComponentToPlayer = addWeaponComponentToPlayerFunction
local weaponTintMapping = {}
weaponTintMapping[0] = "weapontint_black"
weaponTintMapping[1] = "weapontint_green"
weaponTintMapping[2] = "weapontint_gold"
weaponTintMapping[3] = "weapontint_pink"
weaponTintMapping[4] = "weapontint_army"
weaponTintMapping[5] = "weapontint_lspd"
weaponTintMapping[6] = "weapontint_orange"
weaponTintMapping[7] = "weapontint_plat"

function giveWeaponTintToPlayerWeaponFunction(playerId, weaponName, tintIndex)
  local framework, player, tintItemName
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    player.setWeaponTint(weaponName, tintIndex)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      tintItemName = weaponTintMapping[tintIndex]
      player.Functions.AddItem(tintItemName, 1)
    end
  end
end
Framework.giveWeaponTintToPlayerWeapon = giveWeaponTintToPlayerWeaponFunction

function setJobToPlayerFunction(playerId, jobName, grade)
  local framework, player
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    player.setJob(jobName, grade)
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      player.Functions.SetJob(jobName, grade)
    end
  end
end
Framework.setJobToPlayer = setJobToPlayerFunction
function getPlayerCharacterNameFunction(playerId)
  local framework, player, name, charinfo
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    name = player.getName()
    if not name then
      name = GetPlayerName(playerId)
    end
    return name
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      charinfo = player.PlayerData.charinfo
      return charinfo.firstname .. " " .. charinfo.lastname
    end
  end
end
Framework.getPlayerCharacterName = getPlayerCharacterNameFunction
RegisterServerCallback(Utils.eventsPrefix .. ":getPlayerLicenses", function(playerId, cb, targetPlayerId)
  local player, licenses
  player = QBCore.Functions.GetPlayer(targetPlayerId)
  licenses = player.PlayerData.metadata.licences
  cb(licenses)
end)
RegisterNetEvent(Utils.eventsPrefix .. ":giveLicenseToPlayer", function(targetPlayerId, licenseName)
  local framework, player, licenses
  framework = Framework.getFramework()
  if "QB-core" ~= framework then
    print("Event :giveLicenseToPlayer can be used only on QBCore")
    return
  end
  player = QBCore.Functions.GetPlayer(targetPlayerId)
  licenses = player.PlayerData.metadata.licences
  licenses[licenseName] = true
  player.Functions.SetMetaData("licences", licenses)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":removeLicenseFromPlayer", function(targetPlayerId, licenseName)
  local framework, player, licenses
  framework = Framework.getFramework()
  if "QB-core" ~= framework then
    print("Event :removeLicenseFromPlayer can be used only on QBCore")
    return
  end
  player = QBCore.Functions.GetPlayer(targetPlayerId)
  licenses = player.PlayerData.metadata.licences
  licenses[licenseName] = false
  player.Functions.SetMetaData("licences", licenses)
end)
function getPlayerCharIdentifierFunction(playerId)
  local framework, player
  framework = Framework.getFramework()
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    return player.identifier
  else
    framework = Framework.getFramework()
    if "QB-core" == framework then
      player = QBCore.Functions.GetPlayer(playerId)
      return player.PlayerData.citizenid
    end
  end
end
Framework.getPlayerCharIdentifier = getPlayerCharIdentifierFunction
function giveAccountMoneyToCharIdentifierFunction(charIdentifier, accountName, amount)
  local framework, player, sourceId
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromIdentifier(charIdentifier)
    if not player then
      return Framework.giveAccountMoneyToOfflineCharIdentifier(charIdentifier, accountName, amount)
    end
    player.addAccountMoney(accountName, amount)
    return true
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      sourceId = QBCore.Functions.GetSource(charIdentifier)
      if not sourceId or 0 == sourceId then
        return Framework.giveAccountMoneyToOfflineCharIdentifier(charIdentifier, accountName, amount)
      end
      player = QBCore.Functions.GetPlayer(sourceId)
      if not player then
        return false
      end
      player.Functions.AddMoney(accountName, amount)
      return true
    end
  end
end
Framework.giveAccountMoneyToCharIdentifier = giveAccountMoneyToCharIdentifierFunction

function removeAccountMoneyFromCharIdentifierFunction(charIdentifier, accountName, amount)
  local framework, player, sourceId
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    player = ESX.GetPlayerFromIdentifier(charIdentifier)
    if not player then
      return Framework.removeAccountMoneyFromOfflineCharIdentifier(charIdentifier, accountName, amount)
    end
    player.removeAccountMoney(accountName, amount)
    return true
  else
    framework = CURRENT_FRAMEWORK
    if "QB-core" == framework then
      sourceId = QBCore.Functions.GetSource(charIdentifier)
      if not sourceId or 0 == sourceId then
        return Framework.removeAccountMoneyFromOfflineCharIdentifier(charIdentifier, accountName, amount)
      end
      player = QBCore.Functions.GetPlayer(sourceId)
      if not player then
        return false
      end
      player.Functions.RemoveMoney(accountName, amount)
      return true
    end
  end
end
Framework.removeAccountMoneyFromCharIdentifier = removeAccountMoneyFromCharIdentifierFunction
function doesGenericObjectExistFunction(objectName, objectType)
  local label
  if "item" == objectType then
    return Framework.doesItemExists(objectName)
  elseif "weapon" == objectType then
    label = Framework.getWeaponLabel(objectName)
    return label ~= objectName
  elseif "account" == objectType then
    label = Framework.getAccountLabel(objectName)
    return label ~= objectName
  end
end
Framework.doesGenericObjectExist = doesGenericObjectExistFunction
function giveGenericObjectToPlayerIdFunction(playerId, objectData, quantity, showNotification)
  local itemLabel, weaponLabel, accountLabel
  if not objectData.name or not objectData.type then
    print("^1Can't give item to player, object must have name and type^7")
    return
  end
  if "item" == objectData.type then
    Framework.giveItemToPlayer(playerId, objectData.name, quantity, objectData.metadata)
    if showNotification then
      itemLabel = Framework.getItemLabel(objectData.name)
      notify(playerId, getLocalizedText("you_received_item", quantity, itemLabel))
    end
  else
    if "weapon" == objectData.type then
      Framework.giveWeaponToPlayer(playerId, objectData.name, quantity)
      if showNotification then
        weaponLabel = Framework.getWeaponLabel(objectData.name)
        notify(playerId, getLocalizedText("you_received_weapon", weaponLabel))
      end
    else
      if "account" == objectData.type then
        Framework.giveAccountMoneyToPlayer(playerId, objectData.name, quantity)
        if showNotification then
          accountLabel = Framework.getAccountLabel(objectData.name)
          notify(playerId, getLocalizedText("you_received_money", Utils.groupDigits(quantity), accountLabel))
        end
      end
    end
  end
end
Framework.giveGenericObjectToPlayerId = giveGenericObjectToPlayerIdFunction

function removeGenericObjectFromPlayerIdFunction(playerId, objectName, objectType, quantity)
  if "item" == objectType then
    Framework.removeItemFromPlayer(playerId, objectName, quantity)
  elseif "weapon" == objectType then
    Framework.removeWeaponFromPlayer(playerId, objectName)
  elseif "account" == objectType then
    Framework.removeAccountMoneyFromPlayer(playerId, objectName, quantity)
  end
end
Framework.removeGenericObjectFromPlayerId = removeGenericObjectFromPlayerIdFunction
function hasPlayerEnoughOfGenericObjectFunction(playerId, objectName, objectType, quantity)
  local accountMoney
  if "item" == objectType then
    return Framework.hasPlayerEnoughOfItem(playerId, objectName, quantity)
  elseif "weapon" == objectType then
    return Framework.hasPlayerWeapon(playerId, objectName)
  elseif "account" == objectType then
    accountMoney = Framework.getAccountMoneyFromPlayer(playerId, objectName)
    return quantity <= accountMoney
  end
end
Framework.hasPlayerEnoughOfGenericObject = hasPlayerEnoughOfGenericObjectFunction
function getPlayerGenericObjectCountFunction(playerId, objectName, objectType)
  local hasWeapon
  if "item" == objectType then
    return Framework.getPlayerItemCount(playerId, objectName)
  elseif "weapon" == objectType then
    hasWeapon = Framework.hasPlayerWeapon(playerId, objectName)
    if hasWeapon then
      return 1
    end
    return 0
  elseif "account" == objectType then
    return Framework.getAccountMoneyFromPlayer(playerId, objectName)
  end
end
Framework.getPlayerGenericObjectCount = getPlayerGenericObjectCountFunction
function canPlayerCarryGenericObjectFunction(playerId, objectName, objectType, quantity)
  local hasWeapon
  if "item" == objectType then
    return Framework.canPlayerCarryItem(playerId, objectName, quantity)
  elseif "weapon" == objectType then
    hasWeapon = Framework.hasPlayerWeapon(playerId, objectName)
    return not hasWeapon
  else
    return true
  end
end
Framework.canPlayerCarryGenericObject = canPlayerCarryGenericObjectFunction

function getGenericObjectLabelFunction(objectName, objectType)
  if "item" == objectType then
    return Framework.getItemLabel(objectName)
  elseif "weapon" == objectType then
    return Framework.getWeaponLabel(objectName)
  elseif "account" == objectType then
    return Framework.getAccountLabel(objectName)
  end
end
Framework.getGenericObjectLabel = getGenericObjectLabelFunction
function giveMultipleItemsByChancesFunction(playerId, minQuantity, maxQuantity, itemsTable, allowDuplicates)
  local quantity, givenItems, usedItems, item, itemQuantity, canCarry, givenItem
  quantity = #itemsTable
  if 0 == quantity then
    return
  end
  quantity = Utils.getRandomQuantity(minQuantity, maxQuantity)
  if quantity <= 0 then
    return
  end
  givenItems = {}
  usedItems = {}
  for i = 1, quantity do
    item = Utils.getRandomElementFromTable(itemsTable, usedItems)
    if item then
      if not allowDuplicates then
        usedItems[item.name] = true
      end
      itemQuantity = Utils.getRandomQuantity(item.minQuantity, item.maxQuantity)
      canCarry = Framework.canPlayerCarryGenericObject(playerId, item.name, item.type, itemQuantity)
      if canCarry then
        Framework.giveGenericObjectToPlayerId(playerId, {name = item.name, type = item.type}, itemQuantity, true)
        givenItem = givenItems[item.name]
        if not givenItem then
          givenItem = {}
          givenItem.quantity = 0
          givenItem.label = Framework.getGenericObjectLabel(item.name, item.type)
          givenItem.type = item.type
          givenItem.name = item.name
        end
        givenItems[item.name] = givenItem
        givenItem = givenItems[item.name]
        givenItem.quantity = givenItem.quantity + itemQuantity
      else
        notify(playerId, getLocalizedText("you_cant_carry_this_object"))
      end
    end
  end
  return givenItems
end
Framework.giveMultipleItemsByChances = giveMultipleItemsByChancesFunction

function hasPlayerAllRequiredItemsFunction(playerId, requiredItems)
  local item, hasEnough, itemLabel, quantity
  if not requiredItems or #requiredItems == 0 then
    return true
  end
  for i = 1, #requiredItems do
    item = requiredItems[i]
    hasEnough = Framework.hasPlayerEnoughOfGenericObject(playerId, item.name, item.type, item.minQuantity)
    if not hasEnough then
      itemLabel = Framework.getGenericObjectLabel(item.name, item.type)
      notify(playerId, getLocalizedText("you_dont_have_enough", item.minQuantity, itemLabel))
      return false
    end
  end
  return true
end
Framework.hasPlayerAllRequiredItems = hasPlayerAllRequiredItemsFunction

function removeAllRequiredItemsFromPlayerFunction(playerId, requiredItems)
  local item, quantity
  if not requiredItems or #requiredItems == 0 then
    return
  end
  for i = 1, #requiredItems do
    item = requiredItems[i]
    if item.hasToRemove then
      Framework.removeGenericObjectFromPlayerId(playerId, item.name, item.type, item.minQuantity)
    end
  end
end
Framework.removeAllRequiredItemsFromPlayer = removeAllRequiredItemsFromPlayerFunction



