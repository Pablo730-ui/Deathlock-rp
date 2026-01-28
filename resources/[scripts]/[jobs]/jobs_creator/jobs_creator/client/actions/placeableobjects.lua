local currentlyPlacingObject, placedObjectsCount

currentlyPlacingObject = nil
placedObjectsCount = {}

function placeObject(objectModel)
  local playerPed = PlayerPedId()
  local playerHeading = GetEntityHeading(playerPed)
  local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, vector3(0.0, 1.0, -1.0))

  Utils.loadModel(objectModel, 3)

  local objectEntity = CreateObject(objectModel, spawnCoords, true, true, false)
  PlaceObjectOnGroundProperly(objectEntity)
  FreezeEntityPosition(objectEntity, true)
  SetEntityHeading(objectEntity, playerHeading)

  Entity(objectEntity).state:set("isJobsCreatorObject", true, true)
  Entity(objectEntity).state:set("serverIdWhoPlacedObject", GetPlayerServerId(PlayerId()), true)

  local objectHash = GetHashKey(objectModel)
  local currentCount = placedObjectsCount[objectHash]

  if not currentCount then
    currentCount = 1
  else
    currentCount = currentCount + 1
  end
  placedObjectsCount[objectHash] = currentCount
end

RegisterNetEvent(Utils.eventsPrefix .. ":placedObjectsHasBeenDeleted", function(objectHash)
  local currentCount

  currentCount = placedObjectsCount[objectHash]
  if currentCount then
    if currentCount > 0 then
      placedObjectsCount[objectHash] = currentCount - 1
    end
  end
end)

function deleteClosestObject()
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)
  local closestObject = nil
  local closestDistance = nil

  local allObjects = GetGamePool("CObject")

  for i = 1, #allObjects, 1 do
    local object = allObjects[i]
    if Entity(object).state.isJobsCreatorObject then
      local objectCoords = GetEntityCoords(object)
      local distance = #(playerCoords - objectCoords)
      if not closestDistance or closestDistance > distance then
        closestObject = object
        closestDistance = distance
      end
    end
  end

  if closestObject and closestDistance <= 3.0 then
    local eventPrefix = Utils.eventsPrefix
    local eventSuffix = ":deletePlacedObject"
    TriggerServerEvent(eventPrefix .. eventSuffix, ObjToNet(closestObject))
  else
    notifyClient(getLocalizedText("no_object_found"))
  end
end

function startObjectPreview(objectModel)
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)

  Utils.loadModel(objectModel, 3)
  local previewObject = CreateObject(objectModel, playerCoords, false, false, false)
  SetEntityAlpha(previewObject, 100, false)
  SetEntityCollision(previewObject, false, false)
  SetCanClimbOnEntity(previewObject, false)

  while currentlyPlacingObject == objectModel do
    Citizen.Wait(0)

    playerPed = PlayerPedId()
    local offsetCoords = GetOffsetFromEntityInWorldCoords(playerPed, vector3(0.0, 1.0, -1.0))
    local playerHeading = GetEntityHeading(playerPed)

    SetEntityCoords(previewObject, offsetCoords)
    SetEntityHeading(previewObject, playerHeading)
    PlaceObjectOnGroundProperly(previewObject)
  end

  DeleteEntity(previewObject)
end

function openPlaceableObjectsMenu()
  local placeableObjects = JobsCreator.activeActions.placeableObjects
  local menuItems = {}
  local deleteOption = {}
  local menuTitle = getLocalizedText("delete_object")
  deleteOption.label = menuTitle
  deleteOption.value = "delete_object"
  menuItems[1] = deleteOption

  local iterator, objectData, menuId, menuTitle = pairs(placeableObjects)

  for onItemSelect, onMenuClose in iterator, objectData, menuId, menuTitle do
    menuId = table.insert
    menuTitle = menuItems
    onItemSelect = {}
    onMenuClose = onMenuClose.label
    onItemSelect.label = onMenuClose
    onMenuClose = onItemSelect
    onItemSelect.value = onItemSelect
    menuId(menuTitle, onItemSelect)
  end

  menuId = Utils.openInteractionMenu
  menuTitle = "placeable_objects"
  onItemSelect = getLocalizedText
  onMenuClose = "actions_menu"
  onItemSelect = onItemSelect(onMenuClose)

  function onItemSelect(elementIndex, selectedIndex, elementData)
    local selectedValue = elementData.value

    if "delete_object" == selectedValue then
      deleteClosestObject()
    else
      local objectHash = GetHashKey(selectedValue)
      local currentCount = placedObjectsCount[objectHash]

      if currentCount then
        currentCount = placedObjectsCount[objectHash]
        local objectLimit = placeableObjects[selectedValue].limit

        if currentCount >= objectLimit then
          notifyClient(getLocalizedText("limit_reached"))
          return
        end
      else
        placeObject(selectedValue)
      end
    end
  end

  function onMenuClose()
    currentlyPlacingObject = nil
    Utils.openInteractionMenu("actions")
  end

  function onMenuOpen(elementIndex, selectedIndex, elementData)
    local selectedValue

    selectedValue = elementData.value

    if "delete_object" == selectedValue then
      currentlyPlacingObject = nil
      return
    end

    currentlyPlacingObject = selectedValue
    startObjectPreview(currentlyPlacingObject)
  end

  menuId(menuTitle, onItemSelect, menuItems, onItemSelect, onMenuClose, onMenuOpen)
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:placeObject", openPlaceableObjectsMenu)
