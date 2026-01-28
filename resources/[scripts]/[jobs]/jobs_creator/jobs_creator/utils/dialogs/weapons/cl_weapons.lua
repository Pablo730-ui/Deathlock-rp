local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "weapons"
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
function onGetAllWeapons(data, callback)
  local weaponsList
  weaponsList = TriggerServerPromise(Utils.eventsPrefix .. ":getAllWeaponsList")
  callback(weaponsList)
end
RegisterNUICallback("getAllWeapons", onGetAllWeapons)
