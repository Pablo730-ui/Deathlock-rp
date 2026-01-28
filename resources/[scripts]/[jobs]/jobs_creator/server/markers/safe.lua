RegisterServerCallback(Utils.eventsPrefix .. ":getPlayerAccounts", function(source, callback)
  local playerId, player, accounts, accountName, account, accountMoney, accountLabel, accountData

  playerId = source
  player = ESX.GetPlayerFromId(playerId)
  accounts = {}

  for accountName, _ in pairs(config.depositableInSafeAccounts) do
    account = player.getAccount(accountName)
    if account then
      accountMoney = account.money
      if accountMoney > 0 then
        accountLabel = account.label
        if not accountLabel then
          accountLabel = accountName
        end

        accountData = {}
        accountData.accountName = accountName
        accountData.label = getLocalizedText(
          "account",
          accountLabel,
          Framework.groupDigits(accountMoney)
        )
        accountData.money = accountMoney
        table.insert(accounts, accountData)
      end
    elseif accountName == "money" then
      accountMoney = player.getMoney()
      if accountMoney > 0 then
        accountData = {}
        accountData.accountName = "money"
        accountData.label = getLocalizedText(
          "account",
          getLocalizedText("cash"),
          Framework.groupDigits(accountMoney)
        )
        accountData.money = accountMoney
        table.insert(accounts, accountData)
      end
    end
  end

  callback(accounts)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":retrieveReadableSafeData", function(source, callback, safeId)
  local playerId, canAccess, player, markerData, safeInventory, accountName, accountMoney, account, accountLabel, accountData

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, safeId)
  if not canAccess then
    return
  end

  player = ESX.GetPlayerFromId(playerId)

  markerData = JobsCreator.Markers[safeId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  safeInventory = {}

  for accountName, accountMoney in pairs(markerData) do
    account = player.getAccount(accountName)
    if account and accountMoney > 0 then
      accountLabel = account.label
      if not accountLabel then
        accountLabel = accountName
      end

      accountData = {}
      accountData.accountName = accountName
      accountData.label = getLocalizedText(
        "account",
        accountLabel,
        Framework.groupDigits(accountMoney)
      )
      accountData.money = accountMoney
      table.insert(safeInventory, accountData)
    elseif accountName == "money" and accountMoney > 0 then
      accountData = {}
      accountData.accountName = "money"
      accountData.label = getLocalizedText(
        "account",
        getLocalizedText("cash"),
        Framework.groupDigits(accountMoney)
      )
      accountData.money = accountMoney
      table.insert(safeInventory, accountData)
    end
  end

  callback(safeInventory)
end)

function saveDepositToDatabase(playerId, safeId, accountName, accountLabel, amount, callback)
  local player, formattedAmount, markerData, currentAmount

  player = ESX.GetPlayerFromId(playerId)
  formattedAmount = Framework.groupDigits(amount)

  Utils.log(
    playerId,
    getLocalizedText("log_deposited_safe"),
    getLocalizedText("log_deposited_safe_description", formattedAmount, accountLabel, safeId),
    "success",
    "safe"
  )

  markerData = JobsCreator.Markers[safeId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  currentAmount = markerData[accountName]
  if not currentAmount then
    currentAmount = 0
  end
  markerData[accountName] = currentAmount

  currentAmount = markerData[accountName]
  currentAmount = currentAmount + amount
  markerData[accountName] = currentAmount

  MySQL.Async.execute(
    "UPDATE jobs_data SET data=@inventory WHERE id=@markerId",
    {
      ["@inventory"] = json.encode(markerData),
      ["@markerId"] = safeId
    },
    function(affectedRows)
      if affectedRows > 0 then
        JobsCreator.Markers[safeId].data = markerData
        callback(true)
      else
        callback(false)
      end
    end
  )
end

RegisterServerCallback(Utils.eventsPrefix .. ":depositIntoSafe", function(source, callback, safeId, accountName, amount)
  local playerId, canAccess, player, account, accountMoney, accountLabel, colorPrefix, formattedAmount, cashLabel

  if amount <= 0 then
    return
  end

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, safeId)
  if not canAccess then
    return
  end

  player = ESX.GetPlayerFromId(playerId)
  account = player.getAccount(accountName)

  if account then
    accountMoney = account.money
    if amount <= accountMoney then
      player.removeAccountMoney(accountName, amount)
      account = player.getAccount(accountName)
      accountLabel = account.label

      if accountName == "black_money" then
        colorPrefix = "~r~"
      else
        colorPrefix = "~g~"
      end

      formattedAmount = Framework.groupDigits(amount)
      notify(playerId, getLocalizedText("deposited_safe", colorPrefix, formattedAmount, accountLabel))

      saveDepositToDatabase(playerId, safeId, accountName, accountLabel, amount, callback)
    end
  elseif accountName == "money" then
    accountMoney = player.getMoney()
    if amount <= accountMoney then
      player.removeMoney(amount)
      formattedAmount = Framework.groupDigits(amount)
      cashLabel = getLocalizedText("cash")
      notify(playerId, getLocalizedText("deposited_safe", "~g~", formattedAmount, cashLabel))
      saveDepositToDatabase(playerId, safeId, accountName, cashLabel, amount, callback)
    else
      callback(false)
    end
  else
    callback(false)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":withdrawFromSafe", function(source, callback, safeId, accountName, amount)
  local playerId, canAccess, player, markerData, currentAmount, account, accountLabel, success, colorPrefix, formattedAmount, cashLabel

  if amount <= 0 then
    return
  end

  playerId = source

  canAccess = canUseMarkerWithLog(playerId, safeId)
  if not canAccess then
    return
  end

  player = ESX.GetPlayerFromId(playerId)

  markerData = JobsCreator.Markers[safeId]
  if markerData then
    markerData = markerData.data
  end

  if not markerData then
    markerData = {}
  end

  currentAmount = markerData[accountName]
  if not currentAmount then
    currentAmount = 0
  end
  markerData[accountName] = currentAmount

  if amount <= markerData[accountName] then
    account = player.getAccount(accountName)
    accountLabel = nil
    success = false

    if account then
      player.addAccountMoney(accountName, amount)
      accountLabel = account.label
      success = true
    elseif accountName == "money" then
      player.addMoney(amount)
      accountLabel = getLocalizedText("cash")
      success = true
    end

    if success then
      currentAmount = markerData[accountName]
      currentAmount = currentAmount - amount
      markerData[accountName] = currentAmount

      if accountName == "black_money" then
        colorPrefix = "~r~"
      else
        colorPrefix = "~g~"
      end

      formattedAmount = Framework.groupDigits(amount)
      notify(playerId, getLocalizedText("withdrawn_safe", colorPrefix, formattedAmount, accountLabel))

      Utils.log(
        playerId,
        getLocalizedText("log_withdrew_safe"),
        getLocalizedText("log_withdrew_safe_description", formattedAmount, accountLabel, safeId),
        "success",
        "safe"
      )

      MySQL.Async.execute(
        "UPDATE jobs_data SET data=@inventory WHERE id=@markerId",
        {
          ["@inventory"] = json.encode(markerData),
          ["@markerId"] = safeId
        },
        function(affectedRows)
          if affectedRows > 0 then
            JobsCreator.Markers[safeId].data = markerData
          end
          callback(true)
        end
      )
    else
      callback(false)
    end
  else
    callback(false)
  end
end)
