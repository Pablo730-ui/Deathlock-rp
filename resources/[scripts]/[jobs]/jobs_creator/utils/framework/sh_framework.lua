CURRENT_FRAMEWORK = "QB-core"
SUBFRAMEWORK = nil
if "QB-core" == CURRENT_FRAMEWORK then
  if "missing" ~= GetResourceState("qbx_core") then
    SUBFRAMEWORK = "QBX"
  end
end
if not Framework then
  Framework = {}
end
local function getESXSharedObjectEventName()
  local fileContent, eventName
  fileContent = LoadResourceFile(Utils.getScriptName("es_extended"), "client/common.lua")
  eventName = nil
  if fileContent then
    eventName = fileContent:match("['\"](.*)['\"]")
  else
    print("^1Couldn't find file " .. Utils.getScriptName("es_extended") .. "/client/common.lua^7")
  end
  return eventName
end
local function hasItemsTable()
  local promiseObj, result
  promiseObj = promise.new()
  MySQL.Async.fetchScalar("SELECT COUNT(*) FROM items", {}, function(count)
    promiseObj:resolve(count > 0)
  end)
  return Citizen.Await(promiseObj)
end
local function hasJobsTable()
  local promiseObj, result
  promiseObj = promise.new()
  MySQL.Async.fetchScalar("SELECT COUNT(*) FROM jobs", {}, function(count)
    promiseObj:resolve(count > 0)
  end)
  return Citizen.Await(promiseObj)
end
local function hasJobGradesTable()
  local promiseObj, result
  promiseObj = promise.new()
  MySQL.Async.fetchScalar("SELECT COUNT(*) FROM job_grades", {}, function(count)
    promiseObj:resolve(count > 0)
  end)
  return Citizen.Await(promiseObj)
end
local function isFrameworkReady()
  local hasItems, hasJobs, hasGrades, itemsExists, jobsExists, gradesExists
  if IsDuplicityVersion() then
    hasItems = false
    hasJobs = false
    hasGrades = false
    if "ox_inventory" == INVENTORY_TO_USE then
      for itemName, itemData in pairs(Utils.getScriptExports("ox_inventory").Items) do
        hasItems = true
        break
      end
    else
      if ESX.Items then
        for itemName, itemData in pairs(ESX.Items) do
          hasItems = true
          break
        end
      else
        if not ESX.Items then
          hasItems = true
        end
      end
    end
    for jobName, jobData in pairs(ESX.Jobs) do
      if jobData.grades then
        for gradeId, gradeData in pairs(jobData.grades) do
          hasGrades = true
          break
        end
      end
      hasJobs = true
      break
    end
    if not hasJobs then
      jobsExists = hasJobsTable()
    end
    gradesExists = hasGrades or jobsExists
    if not hasGrades then
      gradesExists = hasJobGradesTable()
      gradesExists = not gradesExists and gradesExists
    end
    return gradesExists
  else
    hasItems = true
    return hasItems
  end
end
local function isESXReady()
  return nil ~= isFrameworkReady and isFrameworkReady()
end
local function updateESXSharedObject()
  local kvpKey, eventName, hasExport, promiseObj, thread
  kvpKey = "esx_shared_object"
  if Utils.doesExportExistAnywhere("getSharedObject") then
    repeat
      ESX = Utils.callScriptExport("es_extended", "getSharedObject")
      Citizen.Wait(100)
    until isESXReady()
    return
  end
  promiseObj = promise.new()
  thread = Citizen.CreateThread(function()
    local isProfiling, eventName, shouldTryAlternative, timeout, lastSavedEventName
    isProfiling = ProfilerIsRecording()
    if isProfiling then
      ProfilerEnterScope("Getting shared object")
    end
    eventName = EXTERNAL_EVENTS_NAMES["esx:getSharedObject"]
    if not eventName then
      eventName = GetResourceKvpString(kvpKey)
      if not eventName then
        eventName = "esx:getSharedObject"
      end
    end
    shouldTryAlternative = true
    timeout = GetGameTimer() + 1000
    repeat
      if not ESX then
        if eventName then
          TriggerEvent(eventName, function(sharedObject)
            ESX = sharedObject
          end)
          if GetGameTimer() > timeout then
            if shouldTryAlternative then
              shouldTryAlternative = false
              timeout = GetGameTimer() + 1000
              eventName = getESXSharedObjectEventName()
            else
              return
            end
          end
        else
          print("^1ESX Shared Object is nil^7")
          return
        end
      else
        TriggerEvent(eventName, function(sharedObject)
          ESX = sharedObject
        end)
      end
      Citizen.Wait(500)
    until isESXReady()
    lastSavedEventName = GetResourceKvpString(kvpKey)
    if not (lastSavedEventName and lastSavedEventName == eventName) then
      SetResourceKvp(kvpKey, eventName)
    end
    if isProfiling then
      ProfilerExitScope()
    end
    promiseObj:resolve()
  end)
  return Citizen.Await(promiseObj)
end
function updateSharedObject()
  local timeout
  if "ESX" == CURRENT_FRAMEWORK then
    updateESXSharedObject()
  elseif "QB-core" == CURRENT_FRAMEWORK then
    QBCore = nil
    timeout = GetGameTimer() + 10000
    while nil == QBCore do
      QBCore = Utils.getScriptExports("qb-core").GetCoreObject()
      if GetGameTimer() > timeout then
        print("^1Couldn't find QBCore object, if you edited qb-core folder name, be sure to update it in jobs_creator/integrations/sh_integrations.lua^7")
        return
      end
      Citizen.Wait(100)
    end
  end
end
function Framework.setupFramework()
  updateSharedObject()
  TriggerEvent(Utils.eventsPrefix .. ":framework:ready")
  if SECONDS_TO_REFRESH_SHARED_OBJECT then
    Citizen.CreateThread(function()
      while true do
        Citizen.Wait(SECONDS_TO_REFRESH_SHARED_OBJECT * 1000)
        updateSharedObject()
      end
    end)
  end
  RegisterNetEvent("jobs_creator:refreshJobs", updateSharedObject)
end
function Framework.groupDigits(number)
  local prefix, digits, suffix, separator, reversedDigits, formattedDigits
  prefix, digits, suffix = string.match(number, "^([^%d]*%d)(%d*)(.-)$")
  separator = PRICES_SEPARATOR or "."
  reversedDigits = string.reverse(digits)
  formattedDigits = string.gsub(reversedDigits, "(%d%d%d)", "%1" .. separator)
  formattedDigits = string.reverse(formattedDigits)
  return prefix .. formattedDigits .. suffix
end
function Framework.trim(text)
  if text then
    return string.gsub(text, "^%s*(.-)%s*$", "%1")
  else
    return nil
  end
end
function Framework.getFramework()
  return CURRENT_FRAMEWORK
end
local outfitMapping = {}
outfitMapping["t-shirt"] = {name = "tshirt_1", color = "tshirt_2"}
outfitMapping.torso2 = {name = "torso_1", color = "torso_2"}
outfitMapping.decals = {name = "decals_1", color = "decals_2"}
outfitMapping.arms = {name = "arms", color = "arms_2"}
outfitMapping.pants = {name = "pants_1", color = "pants_2"}
outfitMapping.shoes = {name = "shoes_1", color = "shoes_2"}
outfitMapping.mask = {name = "mask_1", color = "mask_2"}
outfitMapping.vest = {name = "bproof_1", color = "bproof_2"}
outfitMapping.accessory = {name = "chain_1", color = "chain_2"}
outfitMapping.hat = {name = "helmet_1", color = "helmet_2"}
outfitMapping.glass = {name = "glasses_1", color = "glasses_2"}
outfitMapping.bag = {name = "bags_1", color = "bags_2"}
function Framework.convertOutfitFromQBCoreToESX(qbOutfit)
  local esxOutfit, componentName, componentData, esxName, esxColor
  esxOutfit = {}
  for componentName, componentData in pairs(qbOutfit) do
    if outfitMapping[componentName] then
      esxName = outfitMapping[componentName].name
      esxColor = outfitMapping[componentName].color
      esxOutfit[esxName] = componentData.item
      esxOutfit[esxColor] = componentData.texture
    end
  end
  return esxOutfit
end
local function findOutfitComponent(esxComponentName)
  local componentName, componentData, componentType
  for componentName, componentData in pairs(outfitMapping) do
    if componentData.name == esxComponentName then
      return componentName, "name"
    elseif componentData.color == esxComponentName then
      return componentName, "color"
    end
  end
end
function Framework.convertOutfitFromESXToQBCore(esxOutfit)
  local qbOutfit, esxComponentName, esxValue, componentName, componentType
  qbOutfit = {}
  for esxComponentName, esxValue in pairs(esxOutfit) do
    componentName, componentType = findOutfitComponent(esxComponentName)
    if componentName then
      if not qbOutfit[componentName] then
        qbOutfit[componentName] = {}
      end
      if "name" == componentType then
        qbOutfit[componentName].item = esxValue
      elseif "color" == componentType then
        qbOutfit[componentName].texture = esxValue
      end
    end
  end
  return qbOutfit
end
local function setInventoryToUse(inventory)
  INVENTORY_TO_USE = inventory
end
local function setClothingToUse(clothing)
  CLOTHING_TO_USE = clothing
end
local function showMissingScriptError(scriptType, availableScripts)
  print("=====================================================")
  print("^1Couldn't find any " .. scriptType .. " script. Make sure to update them in jobs_creator/integrations/sh_integrations.lua^7")
  print("^1Only " .. table.concat(availableScripts, " and ") .. " can be used^7")
  print("=====================================================")
end
local frameworkCompatibility = {}
frameworkCompatibility.ESX = {
  clothing = {"esx_skin", "illenium-appereance"},
  inventory = {},
  boss = {}
}
frameworkCompatibility["QB-core"] = {
  clothing = {"qb-clothing", "illenium-appereance"},
  inventory = {},
  boss = {"qb-banking (latest QBCore wants this)"}
}
local moduleCompatibility = {}
moduleCompatibility.ox_inventory = {
  label = "OX Inventory",
  successFunction = setInventoryToUse
}
moduleCompatibility.esx_skin = {
  label = "ESX Skin",
  value = "framework",
  checkFunction = function()
    if "ESX" ~= Framework.getFramework() then
      return false
    end
    if "missing" == GetResourceState("illenium-appearance") then
      if "missing" == GetResourceState("fivem-appearance") then
        return true
      end
    end
    return false
  end,
  successFunction = setClothingToUse
}
moduleCompatibility["qb-clothing"] = {
  label = "QB Clothing",
  value = "framework",
  checkFunction = function()
    if "QB-core" ~= Framework.getFramework() then
      return false
    end
    if "missing" == GetResourceState("illenium-appearance") then
      if "missing" == GetResourceState("fivem-appearance") then
        return true
      end
    end
    return false
  end,
  successFunction = setClothingToUse
}
moduleCompatibility["illenium-appearance"] = {
  label = "Illenium Appearance",
  successFunction = setClothingToUse
}
local function autoDetectAndSetupModules()
  local scriptName, resourceState, moduleConfig, moduleValue, moduleType, moduleName
  for moduleName, moduleConfig in pairs(moduleCompatibility) do
    scriptName = Utils.getScriptName(moduleName)
    resourceState = GetResourceState(scriptName)
    if "missing" ~= resourceState then
      if moduleConfig.checkFunction then
        if moduleConfig.checkFunction() then
          print("^2Automatically using ^4" .. moduleConfig.label .. "^7")
          moduleValue = moduleConfig.value
          if not moduleValue then
            moduleValue = moduleName
          end
          moduleConfig.successFunction(moduleValue)
        end
      else
        print("^2Automatically using ^4" .. moduleConfig.label .. "^7")
        moduleValue = moduleConfig.value
        if not moduleValue then
          moduleValue = moduleName
        end
        moduleConfig.successFunction(moduleValue)
      end
    end
  end
  if nil == CLOTHING_TO_USE then
    showMissingScriptError("clothing", frameworkCompatibility[CURRENT_FRAMEWORK].clothing)
  end
  if nil == INVENTORY_TO_USE then
    INVENTORY_TO_USE = "default"
    print("^2Using default ^4" .. CURRENT_FRAMEWORK .. " inventory^7")
  end
  for moduleType, moduleName in pairs(config.modules) do
    print("^2Automatically using ^4" .. moduleName .. "^2 for " .. moduleType .. "^7")
  end
end
RegisterNetEvent(Utils.eventsPrefix .. ":clientConfigLoadedOnStart", autoDetectAndSetupModules)
RegisterNetEvent(Utils.eventsPrefix .. ":serverConfigLoadedOnStart", autoDetectAndSetupModules)
