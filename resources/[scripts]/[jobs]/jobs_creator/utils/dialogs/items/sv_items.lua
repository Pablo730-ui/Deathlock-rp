local registerCallback, eventName, getAllItemsCallback
registerCallback = RegisterServerCallback
eventName = Utils.eventsPrefix .. ":getAllItemsList"
function getAllItemsCallback(sourceId, callback)
  local isAllowed, items, itemsList, itemName, itemData, itemEntry
  isAllowed = Utils.isAllowed(sourceId)
  if not isAllowed then
    callback(false)
    return
  end
  items = Framework.getAllItems()
  if items and type(items) == "table" then
    itemsList = {}
    for itemName, itemData in pairs(items) do
      if itemData and type(itemData) == "table" then
        itemEntry = {}
        itemEntry.label = itemData.label or "Unknown"
        itemEntry.type = "item"
        itemEntry.name = itemData.name or itemName
        itemsList[#itemsList + 1] = itemEntry
      end
    end
    callback(itemsList)
  else
    callback({})
  end
end
registerCallback(eventName, getAllItemsCallback)
