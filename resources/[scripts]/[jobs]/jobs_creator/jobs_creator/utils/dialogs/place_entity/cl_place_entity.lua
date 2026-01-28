local dialogName, placeholderEntity, registerCallback, nuiReadyEvent, handleNuiReady, entities, createEntity, updateEntitiesThread, cleanupEntities, placeEntityWithModel, placeEntityMarker
dialogName = "place_entity"
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
placeholderEntity = nil
function createEntity(modelName, entityType, coords, heading)
  local entity
  if not (modelName and "" ~= modelName and entityType) then
    return
  end
  if not (coords.x and coords.y and coords.z and heading) then
    return
  end
  entity = nil
  Utils.loadModel(modelName, 5)
  if "vehicle" == entityType then
    entity = CreateVehicle(modelName, coords, heading, false, false)
  elseif "object" == entityType then
    entity = CreateObject(modelName, coords, false, false, false)
  elseif "ped" == entityType then
    entity = CreatePed(4, modelName, coords, heading, false, false)
  end
  if not DoesEntityExist(entity) then
    notifyClient("Failed to create entity (it may be wrong model ' " .. tostring(modelName) .. " ' ?)")
    Citizen.Wait(2000)
    return
  end
  if "ped" ~= entityType then
    SetEntityDrawOutline(entity, true)
  end
  FreezeEntityPosition(entity, true)
  SetEntityCollision(entity, false, true)
  SetEntityAlpha(entity, 150, false)
  return entity
end
entities = {}
function updateEntitiesThread(placedEntities)
  Citizen.CreateThread(function()
    if not placedEntities then
      return
    end
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    for i = 1, #placedEntities do
      local entityData = placedEntities[i]
      local entityCoords = vecFromTable(entityData.coords)
      local entityHeading = entityData.heading
      local distance = #(playerCoords - entityCoords)
      if distance <= 100.0 then
        local zeroVec = vector3(0.0, 0.0, 0.0)
        if entityCoords ~= zeroVec and entityHeading then
          local entity = createEntity(entityData.model, entityData.type, entityCoords, entityHeading)
          entities[#entities + 1] = entity
        end
      end
    end
  end)
end
function cleanupEntities()
  local i, entity
  for i = 1, #entities do
    entity = entities[i]
    if DoesEntityExist(entity) then
      DeleteEntity(entity)
    end
  end
  entities = {}
end
function placeEntityWithModel(modelName, entityType, placedEntities)
  placeholderEntity = nil
  if not modelName or "" == modelName then
    notifyClient("This is NOT a valid model!")
    Citizen.Wait(2000)
    return
  end
  if not entityType then
    print("^1entityType not defined in placeEntity^7")
    return
  end
  local playerPed = PlayerPedId()
  local isActive = true
  local isConfirmed = false
  local playerCoords = GetEntityCoords(playerPed)
  local heading = GetEntityHeading(playerPed)
  local finalCoords = playerCoords
  local entity = createEntity(modelName, entityType, playerCoords, heading)
  placeholderEntity = entity
  if not placeholderEntity then
    return
  end
  updateEntitiesThread(placedEntities)
  Citizen.CreateThread(function()
    while isActive do
      Citizen.Wait(0)
      local _, endCoords = Utils.getMouseWorldCoords()
      if endCoords then
        finalCoords = endCoords
        SetEntityCoords(placeholderEntity, endCoords)
      end
      if "object" == entityType then
        PlaceObjectOnGroundProperly(placeholderEntity)
      elseif "vehicle" == entityType then
        SetVehicleOnGroundProperly(placeholderEntity)
      end
      SetEntityHeading(placeholderEntity, heading)
    end
  end)
  local helpText = string.format([[
%s
%s
%s
%s]], getLocalizedText("place_entity:cancel"), getLocalizedText("place_entity:heading"), getLocalizedText("place_entity:move"), getLocalizedText("place_entity:confirm"))
  while isActive do
    Citizen.Wait(0)
    showHelpNotification(helpText)
    if IsDisabledControlJustPressed(0, 241) then
      heading = heading + 5.0
    elseif IsDisabledControlJustPressed(0, 242) then
      heading = heading - 5.0
    end
    if IsDisabledControlJustReleased(0, 200) then
      isActive = false
      isConfirmed = true
    end
    if not IsControlPressed(0, 21) and not IsDisabledControlPressed(0, 21) then
      DisableAllControlActions(0)
    end
    if IsDisabledControlJustReleased(0, 24) then
      isActive = false
    end
    InvalidateIdleCam()
    InvalidateVehicleIdleCam()
  end
  cleanupEntities()
  DeleteEntity(placeholderEntity)
  if isConfirmed then
    return
  end
  local result = {}
  result.coords = stripCoords(finalCoords)
  result.heading = string.format("%.2f", heading)
  return result
end
function placeEntityMarker(markerType)
  if not markerType then
    markerType = 1
  end
  local playerPed = PlayerPedId()
  local isActive = true
  local isConfirmed = false
  local markerCoords = GetEntityCoords(playerPed)
  Citizen.CreateThread(function()
    while isActive do
      Citizen.Wait(0)
      local _, endCoords = Utils.getMouseWorldCoords()
      if endCoords then
        markerCoords = endCoords
      end
    end
  end)
  local helpText = string.format([[
%s
%s
%s]], getLocalizedText("place_entity:cancel"), getLocalizedText("place_entity:move"), getLocalizedText("place_entity:confirm"))
  while isActive do
    Citizen.Wait(0)
    DrawMarker(markerType, markerCoords.x, markerCoords.y, markerCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 150, false, true, 2, false, false, false, false)
    showHelpNotification(helpText)
    if IsDisabledControlJustReleased(0, 200) then
      isActive = false
      isConfirmed = true
    end
    if not IsControlPressed(0, 21) and not IsDisabledControlPressed(0, 21) then
      DisableAllControlActions(0)
    end
    if IsDisabledControlJustReleased(0, 24) then
      isActive = false
    end
    InvalidateIdleCam()
    InvalidateVehicleIdleCam()
  end
  if isConfirmed then
    return
  end
  return stripCoords(markerCoords)
end
RegisterNUICallback("placeEntity", function(data, callback)
  local modelName = data.model
  local entityType = data.entityType
  local placedEntities = data.placedEntities
  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(true)
  local result = nil
  if modelName and entityType then
    result = placeEntityWithModel(modelName, entityType, placedEntities)
  else
    result = placeEntityMarker(data.markerType)
  end
  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(false)
  callback(result)
end)
RegisterNetEvent("onResourceStop", function(resourceName)
  local currentResourceName = GetCurrentResourceName()
  if resourceName ~= currentResourceName then
    return
  end
  cleanupEntities()
  if placeholderEntity then
    DeleteEntity(placeholderEntity)
  end
end)
