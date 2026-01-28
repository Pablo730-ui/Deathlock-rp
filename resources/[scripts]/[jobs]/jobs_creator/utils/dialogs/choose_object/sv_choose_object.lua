local registerCallback, eventName, getAllObjectsCallback
registerCallback = RegisterServerCallback
eventName = Utils.eventsPrefix .. ":getAllObjects"
function getAllObjectsCallback(sourceId, callback)
  local isAllowed, objects, items, itemName, itemData, itemEntry, weapons, weaponName, weaponData, weaponEntry, accounts, accountName, accountData, accountLabel, accountEntry
  isAllowed = Utils.isAllowed(sourceId)
  if not isAllowed then
    callback(false)
    return
  end
  objects = {}
  items = Framework.getAllItems()
  if not items then
    items = {}
  end
  if "table" ~= type(items) then
    print("^1Framework.getAllItems() returned " .. tostring(items) .. "(" .. type(items) .. ", the framework MUST return a table)^7")
    items = {}
  end
  for itemName, itemData in pairs(items) do
    itemEntry = {}
    itemEntry.name = itemName or "not_valid"
    itemEntry.label = itemData.label or "Uknown"
    itemEntry.type = "item"
    table.insert(objects, itemEntry)
  end
  weapons = Framework.getAllWeapons()
  if not weapons then
    weapons = {}
  end
  if "table" ~= type(weapons) then
    print("^1Framework.getAllWeapons() returned " .. tostring(weapons) .. "(" .. type(weapons) .. ", the framework MUST return a table)^7")
    weapons = {}
  end
  for weaponName, weaponData in pairs(weapons) do
    weaponEntry = {}
    weaponEntry.name = weaponData.name or "not_valid"
    weaponEntry.label = weaponData.label or "Uknown"
    weaponEntry.type = "weapon"
    table.insert(objects, weaponEntry)
  end
  accounts = Framework.getAllAccounts()
  if not accounts then
    accounts = {}
  end
  if "table" ~= type(accounts) then
    print("^1Framework.getAllAccounts() returned " .. tostring(accounts) .. "(" .. type(accounts) .. ", the framework MUST return a table)^7")
    accounts = {}
  end
  for accountName, accountData in pairs(accounts) do
    if "table" == type(accountData) then
      accountLabel = accountData.label
    else
      accountLabel = Utils.firstToUpper(accountData)
    end
    if "QB-core" == Framework.getFramework() then
      accountLabel = Utils.firstToUpper(accountName)
    end
    accountEntry = {}
    accountEntry.name = accountName or "not_valid"
    accountEntry.label = accountLabel or "Uknown"
    accountEntry.type = "account"
    table.insert(objects, accountEntry)
  end
  callback(objects)
end
registerCallback(eventName, getAllObjectsCallback)
