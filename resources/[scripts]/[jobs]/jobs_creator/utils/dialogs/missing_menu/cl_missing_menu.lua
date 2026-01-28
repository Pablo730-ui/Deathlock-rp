local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "missing_menu"
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
RegisterNetEvent(Utils.eventsPrefix .. ":showMissingMenu", function()
  SendNUIMessage({action = "showMissingMenuDialog"})
  SetNuiFocus(true, true)
end)
