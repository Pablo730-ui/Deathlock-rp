function setPedImmutable(ped)
  local playerPedHash, pedHash, familyHash
  SetPedRelationshipGroupHash(ped, GetHashKey("AMBIENT_GANG_FAMILY"))
  playerPedHash = GetPedRelationshipGroupHash(PlayerPedId())
  familyHash = GetHashKey("AMBIENT_GANG_FAMILY")
  SetRelationshipBetweenGroups(1, familyHash, playerPedHash)
  SetRelationshipBetweenGroups(1, playerPedHash, familyHash)
  SetEntityInvincible(ped)
  FreezeEntityPosition(ped, true)
  SetPedConfigFlag(ped, 24, true)
  SetPedConfigFlag(ped, 43, true)
  SetPedConfigFlag(ped, 122, true)
  SetPedConfigFlag(ped, 128, false)
  SetPedConfigFlag(ped, 188, true)
  DisablePedPainAudio(ped, true)
  SetCanAttackFriendly(ped, false, false)
  SetPedRagdollOnCollision(ped, false)
  SetRagdollBlockingFlags(ped, 1)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
end
function spawnNPC(model, coords, heading)
  local ped, animDict, animName
  RequestModel(model)
  while not HasModelLoaded(model) do
    Citizen.Wait(0)
  end
  ped = CreatePed(0, model, coords.x, coords.y, coords.z, heading, false, false)
  setPedImmutable(ped)
  animDict = "anim@amb@nightclub@peds@"
  animName = "rcmme_amanda1_stand_loop_cop"
  RequestAnimDict(animDict)
  while not HasAnimDictLoaded(animDict) do
    Citizen.Wait(0)
  end
  TaskPlayAnim(ped, animDict, animName, 4.0, 4.0, -1, 1, 1.0, false, false, false)
  return ped
end
local function notifyClientHandler(notifyData, text)
  Framework.showNotification(text, notifyData)
end
addScriptRemovableEvent(RegisterNetEvent(Utils.eventsPrefix .. ":notify", notifyClientHandler))
function notifyClient(text, notifyData)
  local cleanText
  cleanText = text:gsub("~.~", "")
  if "default" ~= config.modules.notify then
    Utils.callModuleFunc("notify", "showNotification", cleanText, text)
    return
  end
  TriggerEvent(Utils.eventsPrefix .. ":notify", cleanText, notifyData)
end
RegisterNetEvent(Utils.eventsPrefix .. ":notifyClient", notifyClient)
local helpNotificationTimer, isHelpNotificationVisible, currentHelpNotificationText, lastHelpNotificationText
helpNotificationTimer = nil
isHelpNotificationVisible = false
currentHelpNotificationText = ""
lastHelpNotificationText = ""
function showHelpNotification(text)
  local parsedText, segments, isInTag, segment, localizedText, segmentText, concatenatedText
  if "none" == config.modules.textui then
    Framework.showHelpNotification(text)
    return
  end
  helpNotificationTimer = GetGameTimer()
  if text ~= lastHelpNotificationText then
    isHelpNotificationVisible = false
  end
  lastHelpNotificationText = text
  if isHelpNotificationVisible then
    return
  end
  segments = {}
  isInTag = string.sub(text, 1, 1) == "~"
  for segment in string.gmatch(text, "([^~]+)") do
    if isInTag then
      if #segment == 1 then
        goto continue
      end
    end
    if isInTag then
      localizedText = getLocalizedText(string.lower(segment) .. ":letter")
      if localizedText then
        segmentText = localizedText
      else
        segmentText = segment
      end
    else
      segmentText = segment
    end
    table.insert(segments, segmentText)
    ::continue::
    isInTag = not isInTag
  end
  concatenatedText = table.concat(segments)
  currentHelpNotificationText = concatenatedText
  Utils.callModuleFunc("textui", "show", concatenatedText)
  isHelpNotificationVisible = true
  Citizen.CreateThread(function()
    while isHelpNotificationVisible do
      if GetGameTimer() - helpNotificationTimer >= 1000 then
        Utils.callModuleFunc("textui", "hide")
        isHelpNotificationVisible = false
      end
      Citizen.Wait(1000)
    end
  end)
end
function replaceShowHelpNotification(newFunction)
  showHelpNotification = newFunction
end
exports("replaceShowHelpNotification", replaceShowHelpNotification)
function getCurrentCoords()
  local playerPed, coords, offset
  playerPed = PlayerPedId()
  coords = GetEntityCoords(playerPed)
  offset = vector3(0.0, 0.0, 1.0)
  coords = coords - offset
  local formattedCoords = {}
  formattedCoords.x = string.format("%.2f", coords.x)
  formattedCoords.y = string.format("%.2f", coords.y)
  formattedCoords.z = string.format("%.2f", coords.z)
  return formattedCoords
end
RegisterNUICallback("getCurrentCoords", function(data, cb)
  cb(getCurrentCoords())
end)
RegisterNUICallback("getCurrentCoordsAndHeading", function(data, cb)
  local playerPed, heading, result
  playerPed = PlayerPedId()
  heading = GetEntityHeading(playerPed)
  result = {}
  result.coords = getCurrentCoords()
  result.heading = string.format("%.2f", heading)
  cb(result)
end)
function registerAdvancedKeymap(commandName, label, resourceName, key, callback)
  local commandKey, savedCommand, randomSuffix, i, charCode, command
  commandKey = GetResourceKvpString(resourceName .. "_command")
  savedCommand = GetResourceKvpString(resourceName)
  if not (savedCommand == label and savedCommand) or not commandKey then
    SetResourceKvp(resourceName, label)
    randomSuffix = ""
    for i = 1, 5, 1 do
      charCode = string.char(math.random(97, 122))
      randomSuffix = randomSuffix .. charCode
    end
    command = commandName .. "_" .. randomSuffix
    SetResourceKvp(resourceName .. "_command", command)
  else
    command = GetResourceKvpString(resourceName .. "_command") or commandName
  end
  RegisterCommand(command, callback, false)
  RegisterKeyMapping(command, label, "keyboard", key)
end
function Utils.loadAnimDict(animDict)
  local exists, loaded
  exists = DoesAnimDictExist(animDict)
  if exists then
    loaded = HasAnimDictLoaded(animDict)
    if loaded then
      return
    end
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
      Citizen.Wait(10)
    end
  else
    print("^1Impossible to load anim dict ^3" .. animDict .. "^7")
  end
end
local function loadModelInternal(model, unloadDelay)
  local timeout, i
  RequestModel(model)
  timeout = GetGameTimer() + 2000
  while not HasModelLoaded(model) do
    if GetGameTimer() > timeout then
      print("^1Impossible to load model ^3" .. model .. "^7")
      return
    end
    Citizen.Wait(10)
  end
  if not unloadDelay then
    return
  end
  SetTimeout(unloadDelay * 1000, function()
    SetModelAsNoLongerNeeded(model)
  end)
end
function Utils.loadModel(models, unloadDelay)
  local modelType, i, model
  modelType = type(models)
  if "table" == modelType then
    for i = 1, #models, 1 do
      loadModelInternal(models[i], unloadDelay)
    end
  elseif "string" == modelType then
    loadModelInternal(models, unloadDelay)
  end
end
function Utils.getPlayerServerIdFromPed(ped)
  local playerIndex, serverId
  if not ped then
    return
  end
  if not DoesEntityExist(ped) then
    return
  end
  playerIndex = NetworkGetPlayerIndexFromPed(ped)
  if -1 == playerIndex then
    return
  end
  serverId = GetPlayerServerId(playerIndex)
  return serverId
end
function Utils.getMouseWorldCoords()
  local shapeTestHandle, resultStatus, hit, endCoords, surfaceNormal, entityHit
  shapeTestHandle, resultStatus, hit, endCoords, surfaceNormal, entityHit = StartShapeTestSurroundingCoords(511, PlayerPedId(), 7)
  while true do
    resultStatus, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTestHandle)
    if 2 == resultStatus or 0 == resultStatus then
      return hit, endCoords, surfaceNormal, entityHit
    end
    Citizen.Wait(0)
  end
end
local openedMenu = nil
local lastOpenedMenuId = nil
function askQuantity(title, min, max)
  local quantityPromise, framework, menuType, resourceName, menuData, submitCallback, cancelCallback, keyboardResult
  quantityPromise = promise.new()
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    menuType = "dialog"
    resourceName = GetCurrentResourceName()
    menuData = {}
    menuData.title = title
    submitCallback = function(data, menu)
      local quantity
      quantity = tonumber(data.value)
      if quantity and (not min or quantity >= min) and (not max or quantity <= max) then
        menu.close()
        quantityPromise:resolve(quantity)
      else
        notifyClient(getLocalizedText("invalid_quantity"))
      end
    end
    cancelCallback = function(data, menu)
      menu.close()
      quantityPromise:resolve(false)
    end
    ESX.UI.Menu.Open(menuType, resourceName, string.lower(title), menuData, submitCallback, cancelCallback)
  elseif "QB-core" == framework then
    AddTextEntry("FMMC_MPM_NA", title)
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
      DisableAllControlActions(0)
      Wait(0)
    end
    keyboardResult = GetOnscreenKeyboardResult()
    if not keyboardResult then
      quantityPromise:resolve(false)
      return
    end
    quantity = tonumber(keyboardResult)
    if quantity and (not max or max >= quantity) and min <= quantity then
      return quantity
    else
      notifyClient(getLocalizedText("invalid_quantity"))
    end
  end
  return Citizen.Await(quantityPromise)
end
function askInput(title)
  local inputPromise, framework, menuType, resourceName, menuData, submitCallback, cancelCallback, keyboardResult
  inputPromise = promise.new()
  framework = CURRENT_FRAMEWORK
  if "ESX" == framework then
    menuType = "dialog"
    resourceName = GetCurrentResourceName()
    menuData = {}
    menuData.title = title
    submitCallback = function(data, menu)
      local value
      value = data.value
      if value then
        menu.close()
        inputPromise:resolve(value)
      end
    end
    cancelCallback = function(data, menu)
      menu.close()
      inputPromise:resolve(false)
    end
    ESX.UI.Menu.Open(menuType, resourceName, string.lower(title), menuData, submitCallback, cancelCallback)
  elseif "QB-core" == framework then
    AddTextEntry("FMMC_MPM_NA", title)
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
      DisableAllControlActions(0)
      Citizen.Wait(0)
    end
    inputPromise:resolve(GetOnscreenKeyboardResult())
  end
  return Citizen.Await(inputPromise)
end
function getMenu()
  local menu, menuResourceName
  menu = nil
  if "ESX" == CURRENT_FRAMEWORK then
    if not ESX.UI.Menu.RegisteredTypes.default then
      updateSharedObject()
    end
    if not ESX.UI.Menu.RegisteredTypes.default then
      print("=====================================================")
      print("^1Error: There is an issue with esx_menu_default^7")
      print("^2Solution: Be sure to start it after es_extended, otherwise reinstall the official latest one^7")
      print("=====================================================")
      return
    end
    menu = ESX.UI.Menu
  elseif "QB-core" == CURRENT_FRAMEWORK then
    menuResourceName = "esx_menu_default"
    if "started" ~= GetResourceState(menuResourceName) then
      menuResourceName = "menu_default"
    end
    if "started" ~= GetResourceState(menuResourceName) then
      TriggerEvent(Utils.eventsPrefix .. ":showMissingMenu")
    end
    menu = exports[menuResourceName]:GetMenu().UI.Menu
  end
  if not menu then
    print("^1Error: No menu found^7")
    return
  end
  return menu
end
function openMenu(menuId, title, elements, onSelect, onClose, onSelected, onSideScroll)
  local menu, formattedElements
  if not elements then
    return
  end
  menu = getMenu()
  menu.Open("default", GetCurrentResourceName(), menuId, {
    title = title,
    align = config.menuPosition or "bottom-right",
    elements = elements
  }, function(data, menu)
    onSelect(nil, nil, data.current)
  end, function(data, menu)
    if onClose then
      onClose()
    end
    openedMenu = nil
    menu.close()
  end, function(data, menu)
    if onSelected then
      onSelected(nil, nil, data.current)
    end
  end, function(data, menu)
    if onSideScroll then
      onSideScroll(nil, nil, data.current)
    end
  end)
end
function Utils.hideInteractionMenu()
  if "menu_default" == config.modules.menu then
    getMenu().CloseAll()
    return
  end
  lib.hideMenu()
  lib.closeInputDialog()
  Citizen.Wait(0)
end


function formatMenuOptions(options)
  local formatted = {}
  for i = 1, #options do
    local opt = Utils.deepCopy(options[i] or {})
    opt.args = Utils.deepCopy(opt or {})
    opt.close = false
    if opt.label then
      opt.label = opt.label:gsub("<span.->(%w.-)</span>", "%1")
    end
    if opt.args and opt.args.label then
      opt.args.label = opt.args.label:gsub("<span.->(%w.-)</span>", "%1")
    end
    if opt.type == "inputQuantity" then
      opt.close = false
    else
      opt.type = "default"
    end
    table.insert(formatted, opt)
  end
  return formatted
end

local function getEventName(menuId)
  return Utils.eventsPrefix .. "_" .. menuId
end

function Utils.openInteractionMenu(menuId, title, options, onSelect, onClose, onSelected, onSideScroll)
    menuId = getEventName(menuId)
    if config.modules.menu == "menu_default" then
        openMenu(menuId, title, options, onSelect, onClose, onSelected, onSideScroll)
        return
    end
    if not (title and options and onSelect) then
        pcall(lib.showMenu, menuId)
        return
    end
    Utils.hideInteractionMenu()
    Citizen.Wait(0)
    local formattedOptions = formatMenuOptions(options)

    lib.registerMenu({
        id = menuId,
        title = title,
        options = formattedOptions,
        position = config.menuPosition or "bottom-right",
        onClose = onClose,
        onSelected = onSelected,
        onSideScroll = onSideScroll and function(selectedOption, selectedIndex, args)
        onSideScroll(selectedOption, selectedIndex, args, args and args.sliderValues and args.sliderValues[selectedIndex])
        end or nil
    }, function(selectedIndex, scrollIndex, args)
        local selectedOption = formattedOptions[selectedIndex]
        if selectedOption then
            local fullOption = Utils.deepCopy(selectedOption)
            if args then
                for key, value in pairs(args) do
                    fullOption[key] = value
                end
            end
            onSelect(nil, nil, fullOption)
        else
            onSelect(nil, nil, args or {})
        end
    end)
    Citizen.Wait(0)
    lib.showMenu(menuId)
end

local savedMenuId = nil
function Utils.askQuantity(title, min, max)
  local result, openMenuId, inputResult
  if not min then
    min = 1
  end
  if "menu_default" == config.modules.menu then
    return askQuantity(title, min, max)
  end
  lib.closeInputDialog()
  openMenuId = lib.getOpenMenu()
  if openMenuId then
    savedMenuId = openMenuId
    lib.hideMenu()
  end
  inputResult = lib.inputDialog(title, {
    {
      label = title,
      type = "number",
      min = min,
      max = max,
      default = min,
      required = true
    }
  })
  if savedMenuId then
    lib.showMenu(savedMenuId)
    savedMenuId = nil
  end
  if inputResult and inputResult[1] then
    return inputResult[1]
  end
  return nil
end
function Utils.askInput(title)
  local result, openMenuId, inputResult
  if "menu_default" == config.modules.menu then
    return askInput(title)
  end
  lib.closeInputDialog()
  openMenuId = lib.getOpenMenu()
  if openMenuId then
    savedMenuId = openMenuId
    lib.hideMenu()
  end
  inputResult = lib.inputDialog(title, {
    {
      label = title,
      type = "input",
      required = true
    }
  })
  if savedMenuId then
    lib.showMenu(savedMenuId)
    savedMenuId = nil
  end
  if inputResult and inputResult[1] then
    return inputResult[1]
  end
  return nil
end
