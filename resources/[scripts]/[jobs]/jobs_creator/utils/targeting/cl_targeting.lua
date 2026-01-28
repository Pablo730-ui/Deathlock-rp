local entityToTypeMap, qbTargetEntityIds, sphereZones
Target = Target or {}
entityToTypeMap = {}
qbTargetEntityIds = {}
sphereZones = {}
function Target.addLocalEntityToOxTarget(entity, eventName, label, options)
  local oxTargetScriptName, targetEventName, targetOption
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeLocalEntity(entity, {targetEventName})
  targetOption = {}
  targetOption.name = targetEventName
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.onSelect = function(data)
    return options.onSelect(data.entity)
  end
  targetOption.canInteract = options.canInteract
  targetOption.distance = options.distance
  targetOption.items = options.items
  targetOption.event = options.event
  exports[oxTargetScriptName]:addLocalEntity(entity, {targetOption})
end
function Target.removeLocalEntityFromOxTarget(entity, eventName)
  local oxTargetScriptName, targetEventName
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeLocalEntity(entity, {targetEventName})
end
function Target.addGlobalPlayerToOxTarget(eventName, label, options)
  local oxTargetScriptName, targetEventName, targetOption
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeGlobalPlayer(targetEventName)
  targetOption = {}
  targetOption.name = targetEventName
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.onSelect = function(data)
    return options.onSelect(data.entity)
  end
  targetOption.canInteract = options.canInteract
  targetOption.distance = options.distance
  targetOption.items = options.items
  targetOption.event = options.event
  exports[oxTargetScriptName]:addGlobalPlayer({targetOption})
end
function Target.removeGlobalPlayerFromOxTarget(eventName)
  local oxTargetScriptName, targetEventName
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeGlobalPlayer(targetEventName)
end
function Target.addGlobalVehicleToOxTarget(eventName, label, options)
  local oxTargetScriptName, targetEventName, targetOptions, targetOption
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeGlobalVehicle(targetEventName)
  targetOptions = {}
  targetOption = {}
  targetOption.name = targetEventName
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.onSelect = function(data)
    return options.onSelect(data.entity)
  end
  targetOption.canInteract = options.canInteract
  targetOption.distance = options.distance
  targetOption.items = options.items
  targetOption.event = options.event
  targetOptions[1] = targetOption
  exports[oxTargetScriptName]:addGlobalVehicle(targetOptions)
end
function Target.removeGlobalVehicleFromOxTarget(eventName)
  local oxTargetScriptName, targetEventName
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeGlobalVehicle(targetEventName)
end
function Target.addGlobalPedToOxTarget(eventName, label, options)
  local oxTargetScriptName, targetEventName, targetOptions, targetOption
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeGlobalPed(targetEventName)
  targetOptions = {}
  targetOption = {}
  targetOption.name = targetEventName
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.onSelect = function(data)
    return options.onSelect(data.entity)
  end
  targetOption.canInteract = options.canInteract
  targetOption.distance = options.distance
  targetOption.items = options.items
  targetOption.event = options.event
  targetOptions[1] = targetOption
  exports[oxTargetScriptName]:addGlobalPed(targetOptions)
end
function Target.removeGlobalPedFromOxTarget(eventName)
  local oxTargetScriptName, targetEventName
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. eventName
  exports[oxTargetScriptName]:removeGlobalPed(targetEventName)
end
function Target.addLocalEntityToQbTarget(entity, eventName, label, options)
  local qbTargetScriptName, targetOptions, targetOption
  if "qb_target" ~= config.targetingScript then
    return
  end
  qbTargetEntityIds[eventName] = label
  qbTargetScriptName = Utils.getScriptName("qb-target")
  targetOptions = {}
  targetOption = {}
  targetOption.event = options.event
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.action = options.onSelect
  targetOption.canInteract = options.canInteract
  targetOptions[1] = targetOption
  targetOptions.options = targetOptions
  targetOptions.distance = options.distance
  exports[qbTargetScriptName]:AddTargetEntity(entity, targetOptions)
end
function Target.removeLocalEntityFromQbTarget(entity, eventName)
  local label, qbTargetScriptName
  if "qb_target" ~= config.targetingScript then
    return
  end
  label = qbTargetEntityIds[eventName]
  if not label then
    return
  end
  qbTargetScriptName = Utils.getScriptName("qb-target")
  exports[qbTargetScriptName]:RemoveTargetEntity(entity, label)
end
function Target.addGlobalPlayerToQbTarget(eventName, label, options)
  local qbTargetScriptName, targetOptions, targetOption
  if "qb_target" ~= config.targetingScript then
    return
  end
  qbTargetEntityIds[eventName] = label
  qbTargetScriptName = Utils.getScriptName("qb-target")
  targetOptions = {}
  targetOption = {}
  targetOption.event = options.event
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.action = options.onSelect
  targetOption.canInteract = options.canInteract
  targetOptions[1] = targetOption
  targetOptions.options = targetOptions
  targetOptions.distance = options.distance
  exports[qbTargetScriptName]:AddGlobalPlayer(targetOptions)
end
function Target.removeGlobalPlayerFromQbTarget(eventName)
  local label, qbTargetScriptName
  if "qb_target" ~= config.targetingScript then
    return
  end
  label = qbTargetEntityIds[eventName]
  if not label then
    return
  end
  qbTargetScriptName = Utils.getScriptName("qb-target")
  exports[qbTargetScriptName]:RemoveGlobalPlayer(label)
end
function Target.addGlobalVehicleToQbTarget(eventName, label, options)
  local qbTargetScriptName, targetOptions, targetOption
  if "qb_target" ~= config.targetingScript then
    return
  end
  qbTargetEntityIds[eventName] = label
  qbTargetScriptName = Utils.getScriptName("qb-target")
  targetOptions = {}
  targetOption = {}
  targetOption.event = options.event
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.action = options.onSelect
  targetOption.canInteract = options.canInteract
  targetOptions[1] = targetOption
  targetOptions.options = targetOptions
  targetOptions.distance = options.distance
  exports[qbTargetScriptName]:AddGlobalVehicle(targetOptions)
end
function Target.removeGlobalVehicleFromQbTarget(eventName)
  local label, qbTargetScriptName
  if "qb_target" ~= config.targetingScript then
    return
  end
  label = qbTargetEntityIds[eventName]
  if not label then
    return
  end
  qbTargetScriptName = Utils.getScriptName("qb-target")
  exports[qbTargetScriptName]:RemoveGlobalVehicle(label)
end
function Target.addGlobalPedToQbTarget(eventName, label, options)
  local qbTargetScriptName, targetOptions, targetOption
  if "qb_target" ~= config.targetingScript then
    return
  end
  qbTargetEntityIds[eventName] = label
  qbTargetScriptName = Utils.getScriptName("qb-target")
  targetOptions = {}
  targetOption = {}
  targetOption.event = options.event
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.action = options.onSelect
  targetOption.canInteract = options.canInteract
  targetOptions[1] = targetOption
  targetOptions.options = targetOptions
  targetOptions.distance = options.distance
  exports[qbTargetScriptName]:AddGlobalPed(targetOptions)
end
function Target.removeGlobalPedFromQbTarget(eventName)
  local label, qbTargetScriptName
  if "qb_target" ~= config.targetingScript then
    return
  end
  label = qbTargetEntityIds[eventName]
  if not label then
    return
  end
  qbTargetScriptName = Utils.getScriptName("qb-target")
  exports[qbTargetScriptName]:RemoveGlobalPed(label)
end
function Target.addSphereZoneToOxTarget(entityId, type, label, coords, radius, options)
  local zoneKey, oxTargetScriptName, targetEventName, existingZone, targetOption, zoneId, zoneInfo
  if "ox_target" ~= config.targetingScript then
    return
  end
  zoneKey = entityId .. "-" .. type
  oxTargetScriptName = Utils.getScriptName("ox_target")
  targetEventName = Utils.eventsPrefix .. ":" .. type
  existingZone = sphereZones[zoneKey]
  if existingZone then
    exports[oxTargetScriptName]:removeZone(existingZone.zoneId)
    sphereZones[zoneKey] = nil
  end
  targetOption = {}
  targetOption.name = targetEventName
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.onSelect = function(data)
    return options.onSelect(entityId)
  end
  targetOption.canInteract = options.canInteract
  targetOption.distance = radius * 2
  targetOption.items = options.items
  targetOption.event = options.event
  zoneId = exports[oxTargetScriptName]:addSphereZone({
    coords = coords,
    radius = radius,
    drawSprite = true,
    options = {targetOption}
  })
  zoneInfo = {}
  zoneInfo.zoneId = zoneId
  zoneInfo.type = type
  sphereZones[zoneKey] = zoneInfo
end
function Target.removeSphereZoneFromOxTarget(zoneId)
  local oxTargetScriptName
  if "ox_target" ~= config.targetingScript then
    return
  end
  oxTargetScriptName = Utils.getScriptName("ox_target")
  exports[oxTargetScriptName]:removeZone(zoneId)
end
function Target.addSphereZoneToQbTarget(entityId, type, label, coords, radius, options)
  local zoneKey, qbTargetScriptName, existingZone, targetOption, zoneData, zoneInfo
  if "qb_target" ~= config.targetingScript then
    return
  end
  zoneKey = entityId .. "-" .. type
  qbTargetScriptName = Utils.getScriptName("qb-target")
  existingZone = sphereZones[zoneKey]
  if existingZone then
    exports[qbTargetScriptName]:RemoveZone(existingZone.zoneId)
    sphereZones[zoneKey] = nil
  end
  targetOption = {}
  targetOption.event = options.event
  targetOption.icon = "fa-solid fa-hand"
  targetOption.label = label
  targetOption.action = function(data)
    return options.onSelect(entityId)
  end
  targetOption.canInteract = options.canInteract
  zoneData = exports[qbTargetScriptName]:AddCircleZone(zoneKey, vector3(coords.x, coords.y, coords.z), radius, {
    name = zoneKey,
    debugPoly = false,
    options = {targetOption},
    distance = radius * 2
  })
  zoneInfo = {}
  zoneInfo.zoneId = zoneData.name
  zoneInfo.type = type
  sphereZones[zoneKey] = zoneInfo
end
function Target.removeSphereZoneFromQbTarget(zoneKey)
  local qbTargetScriptName
  if "qb_target" ~= config.targetingScript then
    return
  end
  qbTargetScriptName = Utils.getScriptName("qb-target")
  exports[qbTargetScriptName]:RemoveZone(zoneKey)
end
function Target.addGlobalVehicleToTargeting(eventName, label, options)
  Target.addGlobalVehicleToOxTarget(eventName, label, options)
  Target.addGlobalVehicleToQbTarget(eventName, label, options)
end
function Target.removeGlobalVehicleFromTargeting(eventName)
  Target.removeGlobalVehicleFromOxTarget(eventName)
  Target.removeGlobalVehicleFromQbTarget(eventName)
end
function Target.addGlobalPlayerToTargeting(eventName, label, options)
  Target.addGlobalPlayerToOxTarget(eventName, label, options)
  Target.addGlobalPlayerToQbTarget(eventName, label, options)
end
function Target.removeGlobalPlayerFromTargeting(eventName)
  Target.removeGlobalPlayerFromOxTarget(eventName)
  Target.removeGlobalPlayerFromQbTarget(eventName)
end
function Target.addLocalEntityToTargeting(entity, eventName, label, options)
  local entityModel, minCoords, maxCoords, dimensions, isVisible, useSphereZone
  entityModel = GetEntityModel(entity)
  minCoords, maxCoords = GetModelDimensions(entityModel)
  dimensions = maxCoords - minCoords
  isVisible = IsEntityVisible(entity)
  useSphereZone = false
  if isVisible and dimensions.x < 0.5 and dimensions.y < 0.5 and dimensions.z < 0.5 then
    useSphereZone = true
  end
  if useSphereZone then
    entityToTypeMap[entity] = eventName
    Target.addSphereZoneToTargeting(entity, eventName, label, GetEntityCoords(entity), 1.5, options)
    return
  end
  Target.addLocalEntityToOxTarget(entity, eventName, label, options)
  Target.addLocalEntityToQbTarget(entity, eventName, label, options)
end
function Target.removeLocalEntityFromTargeting(entity, eventName)
  Target.removeLocalEntityFromOxTarget(entity, eventName)
  Target.removeLocalEntityFromQbTarget(entity, eventName)
end
function Target.addGlobalPedToTargeting(eventName, label, options)
  Target.addGlobalPedToOxTarget(eventName, label, options)
  Target.addGlobalPedToQbTarget(eventName, label, options)
end
function Target.removeGlobalPedFromTargeting(eventName)
  Target.removeGlobalPedFromOxTarget(eventName)
  Target.removeGlobalPedFromQbTarget(eventName)
end
function Target.addSphereZoneToTargeting(entityId, type, label, coords, radius, options)
  Target.addSphereZoneToOxTarget(entityId, type, label, coords, radius, options)
  Target.addSphereZoneToQbTarget(entityId, type, label, coords, radius, options)
end
function Target.removeSphereZoneFromTargeting(type)
  local zoneKey, zoneInfo
  for zoneKey, zoneInfo in pairs(sphereZones) do
    if type == zoneInfo.type then
      Target.removeSphereZoneFromOxTarget(zoneInfo.zoneId)
      Target.removeSphereZoneFromQbTarget(zoneKey)
      sphereZones[zoneKey] = nil
    end
  end
end
Citizen.CreateThread(function()
  local zoneKey, zoneInfo
  while not config do
    Citizen.Wait(1000)
  end
  if "none" == config.targetingScript then
    return
  end
  while true do
    Citizen.Wait(2000)
    for entity, eventName in pairs(entityToTypeMap) do
      if not DoesEntityExist(entity) then
        entityToTypeMap[entity] = nil
        zoneKey = entity .. "-" .. eventName
        zoneInfo = sphereZones[zoneKey]
        if zoneInfo then
          Target.removeSphereZoneFromOxTarget(zoneInfo.zoneId)
          Target.removeSphereZoneFromQbTarget(zoneKey)
          sphereZones[zoneKey] = nil
        end
      end
    end
  end
end)
