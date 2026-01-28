local dialogName, registerCallback, nuiReadyEvent, handleNuiReady, introPrefix, registerIntroView, hasIntroBeenViewed
dialogName = "misc"
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
introPrefix = "jobs_creator:intro:"
function registerIntroView(introName)
  SetResourceKvpInt(introPrefix .. introName, 1)
end
registerCallback("registerIntroView", function(data, callback)
  registerIntroView(data.introName)
end)
function hasIntroBeenViewed(introName)
  local viewed
  viewed = GetResourceKvpInt(introPrefix .. introName)
  viewed = 1 == viewed
  return viewed
end
registerCallback("hasIntroBeenViewed", function(data, callback)
  local hasViewed
  hasViewed = hasIntroBeenViewed(data.introName)
  callback(hasViewed)
end)
