local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "items"
registerCallback = RegisterNUICallback
nuiReadyEvent = "nuiReady"
function handleNuiReady()
  local messageData
  messageData = {}
  messageData.action = "loadDialog"
  messageData.dialogName = dialogName
  SendNUIMessage(messageData)
end
registerCallback(nuiReadyEvent, handleNuiReady)
registerCallback("getAllItems", function(data, callback)
  local itemsList
  itemsList = TriggerServerPromise(Utils.eventsPrefix .. ":getAllItemsList")
  if not itemsList or type(itemsList) ~= "table" then
    itemsList = {}
  end
  callback(itemsList)
end)
