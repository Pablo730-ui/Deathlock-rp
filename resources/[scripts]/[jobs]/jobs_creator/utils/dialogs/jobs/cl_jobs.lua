local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "jobs"
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
registerCallback("getAllJobs", function(data, callback)
  local jobsList
  jobsList = TriggerServerPromise(Utils.eventsPrefix .. ":getAllJobs")
  callback(jobsList)
end)
