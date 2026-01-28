local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "choose_object"
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
registerCallback("getAllObjects", function(data, callback)
  local objects
  objects = TriggerServerPromise(Utils.eventsPrefix .. ":getAllObjects")
  callback(objects)
end)
