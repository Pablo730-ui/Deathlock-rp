local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "not_allowed"
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
RegisterNetEvent(Utils.eventsPrefix .. ":dialogs:notAllowed", function(acePermission, playerIdentifiers, playerName)
  local messageData
  messageData = {}
  messageData.action = "showNotAllowedDialog"
  messageData.acePermission = acePermission
  messageData.playerIdentifiers = playerIdentifiers
  messageData.playerName = playerName
  SendNUIMessage(messageData)
end)
