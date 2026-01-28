local dialogName, timeoutId, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "progressbar"
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
timeoutId = nil
function showProgressBar(time, text, hexColor)
  local messageData
  messageData = {}
  messageData.action = "progressBar"
  messageData.time = time
  messageData.text = text
  messageData.hexColor = hexColor
  SendNUIMessage(messageData)
end
RegisterNetEvent(Utils.eventsPrefix .. ":internalProgressBar", function(time, text, hexColor)
  local progressbarModule
  progressbarModule = config.modules.progressbar
  if "jaksam" == progressbarModule then
    showProgressBar(time, text, hexColor)
  else
    Utils.callModuleFunc("progressbar", "start", time, text, hexColor)
  end
end)
function Dialogs.startProgressBar(time, text, hexColor)
  if not hexColor then
    hexColor = DEFAULT_PROGRESSBAR_COLOR
  end
  canUseMarkers = false
  TriggerEvent(Utils.eventsPrefix .. ":internalProgressBar", time, text, hexColor)
  timeoutId = Timeout(time, function()
    canUseMarkers = true
  end)
end
RegisterNetEvent(Utils.eventsPrefix .. ":startProgressBar", Dialogs.startProgressBar)
function Dialogs.stopProgressBar()
  if timeoutId then
    ClearTimeout(timeoutId)
    timeoutId = nil
  end
  SendNUIMessage({action = "stopProgressBar"})
  canUseMarkers = true
end
