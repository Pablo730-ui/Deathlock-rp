local callbackId, callbacks, maxCallbackId, resourceName, triggerServerCallbackFunction, triggerServerPromiseFunction, receiveServerCallbackFunction
callbackId = 0
callbacks = {}
maxCallbackId = 32767
resourceName = GetCurrentResourceName()

function triggerServerCallbackFunction(callbackName, callback, ...)
  local currentCallbackId
  if callbackId < maxCallbackId then
    callbackId = callbackId + 1
  else
    callbackId = 0
  end
  currentCallbackId = callbackId
  callbacks[currentCallbackId] = callback
  TriggerServerEvent(resourceName .. ":triggerServerCallback", callbackName, currentCallbackId, ...)
end
TriggerServerCallback = triggerServerCallbackFunction

function triggerServerPromiseFunction(callbackName, ...)
  local promiseObj, currentCallbackId
  promiseObj = promise.new()
  if callbackId < maxCallbackId then
    callbackId = callbackId + 1
  else
    callbackId = 0
  end
  currentCallbackId = callbackId
  callbacks[currentCallbackId] = promiseObj
  TriggerServerEvent(resourceName .. ":triggerServerCallback", callbackName, currentCallbackId, ...)
  return Citizen.Await(promiseObj)
end
TriggerServerPromise = triggerServerPromiseFunction

function receiveServerCallbackFunction(callbackId, ...)
  local callbackType, callback
  callbackType = type(callbacks[callbackId])
  if "function" == callbackType then
    callback = callbacks[callbackId]
    callback(...)
  elseif "table" == callbackType then
    callbacks[callbackId]:resolve(...)
  end
  callbacks[callbackId] = nil
end

RegisterNetEvent(resourceName .. ":receiveServerCallback", receiveServerCallbackFunction)
