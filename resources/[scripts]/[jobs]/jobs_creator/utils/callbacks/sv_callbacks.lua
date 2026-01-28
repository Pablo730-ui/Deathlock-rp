local registeredCallbacks, resourceName, registerServerCallbackFunction, getESXCallbackFunction, handleTriggerServerCallback
registeredCallbacks = {}
resourceName = GetCurrentResourceName()

function registerServerCallbackFunction(callbackName, callback)
  registeredCallbacks[callbackName] = callback
end
RegisterServerCallback = registerServerCallbackFunction

local function getESXCallbackFunction(callbackName)
  local callback, key, value
  for key, value in pairs(ESX.ServerCallbacks[callbackName]) do
    if "__cfx_functionReference" == key then
      return ESX.ServerCallbacks[callbackName]
    end
  end
  return ESX.ServerCallbacks[callbackName].cb
end

function handleTriggerServerCallback(callbackName, callbackId, ...)
  local sourceId, callback
  sourceId = source
  callback = nil
  callback = registeredCallbacks[callbackName]
  if not callback then
    if ESX and ESX.ServerCallbacks and ESX.ServerCallbacks[callbackName] then
      callback = getESXCallbackFunction(callbackName)
    else
      print("No callback registered for event " .. callbackName .. " and ESX is not available")
      return
    end
  else
    callback = registeredCallbacks[callbackName]
  end
  callback(sourceId, function(...)
    TriggerClientEvent(resourceName .. ":receiveServerCallback", sourceId, callbackId, ...)
  end, ...)
end

RegisterNetEvent(resourceName .. ":triggerServerCallback", handleTriggerServerCallback)
