local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "external_scripts_names"
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
registerCallback("getAllResources", function(data, callback)
  local resources
  resources = TriggerServerPromise(Utils.eventsPrefix .. ":getAllResources")
  callback(resources)
end)
registerCallback("getIntegrationsResources", function(data, callback)
  local resources
  resources = TriggerServerPromise(Utils.eventsPrefix .. ":getIntegrationsResources")
  callback(resources)
end)
