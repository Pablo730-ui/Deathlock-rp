local dialogName, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "modules"
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
registerCallback("getAllModules", function(data, callback)
  local modules, moduleType, moduleOptions, moduleData
  modules = {}
  for moduleType, moduleOptions in pairs(Integrations.modules) do
    if "table" == type(moduleOptions) then
      if #moduleOptions > 0 then
        moduleData = {}
        moduleData.type = moduleType
        moduleData.options = moduleOptions
        modules[#modules + 1] = moduleData
      end
    end
  end
  callback(modules)
end)
