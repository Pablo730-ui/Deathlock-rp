Utils = {}
Utils.eventsPrefix = "jobs_creator"

if not Integrations then
  Integrations = {}
end

if not locales then
  locales = {}
end

function getLocalizedText(textKey, ...)
  local text, localeConfig, expectedArgCount, argCount, modifiedText, originalText
  localeConfig = locales[config.locale]
  if localeConfig then
    if localeConfig[textKey] then
      text = localeConfig[textKey]
    else
      text = locales.en[textKey]
    end
  else
    text = locales.en[textKey]
  end
  if text then
    originalText = text
    modifiedText = string.gsub(text, "%%[^%%]", "")
    expectedArgCount = 0
    for _ in string.gmatch(text, "%%[^%%]") do
      expectedArgCount = expectedArgCount + 1
    end
    text = modifiedText
    argCount = select("#", ...)
    if expectedArgCount == argCount then
      if argCount > 0 then
        return string.format(text, ...)
      else
        return text
      end
    else
      print()
      print("^1Argument missing for translation, retranslate it by copy pasting the ^3['" .. textKey .. "']^1 translation of the ^5LATEST VERSION of ^6locales/en.lua^1 in the file of your language^7")
      print("^3[DEBUG] Expected arguments: " .. tostring(expectedArgCount) .. ", Arguments passed: " .. tostring(argCount))
      print()
      return textKey
    end
  else
    print("^1Translation missing: ^3" .. textKey .. "^7")
    return textKey
  end
end

local timeoutCallbacks = {}
local timeoutCounter = 0

function Timeout(delay, callback)
  local timeoutId
  timeoutCounter = timeoutCounter + 1
  timeoutId = timeoutCounter
  timeoutCallbacks[timeoutId] = callback
  SetTimeout(delay, function()
    local callbackFunc
    callbackFunc = timeoutCallbacks[timeoutId]
    if callbackFunc then
      callbackFunc()
    end
  end)
  return timeoutId
end

function ClearTimeout(timeoutId)
  timeoutCallbacks[timeoutId] = nil
end

function vecFromTable(table)
  return vector3(table.x + 0.0, table.y + 0.0, table.z + 0.0)
end
function getRandomElementFromTable(tableWithChances)
  local totalChances, ranges, randomValue, range, key
  totalChances = 0
  ranges = {}
  for key, value in pairs(tableWithChances) do
    totalChances = totalChances + value.chances
    table.insert(ranges, {
      min = totalChances - value.chances,
      max = totalChances,
      key = key
    })
  end
  randomValue = math.random(0, totalChances)
  for _, range in pairs(ranges) do
    if randomValue >= range.min and randomValue <= range.max then
      return tableWithChances[range.key]
    end
  end
end

local scriptRemovableEvents = {}

function addScriptRemovableEvent(eventData)
  local eventKey, scriptName, eventList
  eventKey = eventData.key
  scriptName = eventData.name
  eventList = scriptRemovableEvents[scriptName]
  if not eventList then
    eventList = {}
  end
  scriptRemovableEvents[scriptName] = eventList
  table.insert(eventList, eventKey)
end

function disableScriptEvent(scriptName)
  local events, key, eventData
  events = scriptRemovableEvents[scriptName]
  if events then
    for _, eventKey in pairs(events) do
      eventData = {
        key = eventKey,
        name = scriptName
      }
      RemoveEventHandler(eventData)
    end
  end
end

exports("disableScriptEvent", disableScriptEvent)

local function loadConfig()
  local configLoaded
  configLoaded = Settings.loadConfig()
  if not configLoaded then
    print("^1Config failed to load^7")
    return
  end
  print("^2Config loaded successfully^7")
end

Citizen.CreateThread(function()
  local resourceName
  if IsDuplicityVersion() then
    resourceName = GetCurrentResourceName()
    if resourceName ~= Utils.eventsPrefix then
      print("It would be appreciated using ^5" .. Utils.eventsPrefix .. "^7 as name of the resource")
    end
    if not setupDatabase() then
      return
    end
  end
  loadConfig()
  Framework.setupFramework()
end)
function DumpTable(table, indent)
  local output, key, value, indentStr, keyType, valueStr
  if nil == indent then
    indent = 0
  end
  if type(table) == "table" then
    indentStr = ""
    for i = 1, indent + 1 do
      indentStr = indentStr .. "    "
    end
    output = "{\n"
    for key, value in pairs(table) do
      keyType = type(key)
      if "number" ~= keyType then
        key = "\"" .. key .. "\""
      end
      for i = 1, indent do
        output = output .. "    "
      end
      valueStr = DumpTable(value, indent + 1)
      output = output .. "[" .. key .. "] = " .. valueStr .. ",\n"
    end
    for i = 1, indent do
      output = output .. "    "
    end
    output = output .. "}"
    return output
  else
    return tostring(table)
  end
end

function getCurrentUnixTime()
  return os.time(os.date("*t"))
end

local function getRandomLetter()
  return string.char(math.random(65, 90))
end

local function getRandomDigit()
  return tostring(math.random(0, 9))
end

function generatePlate()
  local plate, isLetterMode, char, plateWithoutHash, plateLength, i, char
  plate = ""
  isLetterMode = false
  plateWithoutHash = string.gsub(EXAMPLE_PLATE, "#", "")
  plateLength = string.len(plateWithoutHash)
  if plateLength > 8 then
    print("^1Maximum plate length is 8 characters^7")
  end
  for i = 1, #EXAMPLE_PLATE do
    char = string.sub(EXAMPLE_PLATE, i, i)
    if "#" == char then
      isLetterMode = not isLetterMode
    elseif isLetterMode then
      plate = plate .. char
    else
      if tonumber(char) then
        plate = plate .. getRandomDigit()
      elseif " " == char then
        plate = plate .. " "
      else
        plate = plate .. getRandomLetter()
      end
    end
  end
  return plate
end

function stripCoords(coords)
  local x, y, z, result
  x, y, z = table.unpack(coords)
  if not (x and y) or not z then
    x = coords.x
    y = coords.y
    z = coords.z
  end
  result = {}
  result.x = string.format("%.2f", x)
  result.y = string.format("%.2f", y)
  result.z = string.format("%.2f", z)
  return result
end

function Utils.firstToUpper(str)
  if type(str) ~= "string" then
    return str
  end
  return string.gsub(str, "^%l", string.upper)
end
function Utils.getUniqueEntityId(entity)
  local networkId, modelHash, entityType, uniqueId
  if not DoesEntityExist(entity) then
    return "UNIQUE_ID_NOT_FOUND"
  end
  networkId = NetworkGetNetworkIdFromEntity(entity)
  modelHash = math.abs(GetEntityModel(entity))
  entityType = GetEntityType(entity)
  uniqueId = networkId .. "-" .. modelHash .. "-" .. entityType
  return uniqueId
end

function Utils.doesExportExist(scriptName, exportName)
  local success, result
  success, result = pcall(function()
    return exports[scriptName][exportName]
  end)
  return success
end

function Utils.toBool(value)
  local valueType
  valueType = type(value)
  if "boolean" == valueType then
    return value
  elseif "number" == valueType then
    return 1 == value
  else
    return false
  end
end

function Utils.deepCopy(table)
  local copy, key, value, valueType
  if not table then
    return
  end
  copy = {}
  for key, value in pairs(table) do
    valueType = type(value)
    if "table" == valueType then
      value = Utils.deepCopy(value)
    end
    copy[key] = value
  end
  return copy
end

function Utils.showPermanentError(...)
  local errors, firstError, secondError
  errors = {}
  firstError, secondError = ...
  errors[1] = firstError
  errors[2] = secondError
  Citizen.CreateThread(function()
    local i
    while true do
      Citizen.Wait(3000)
      print()
      for i = 1, #errors do
        print(errors[i])
      end
      print()
    end
  end)
end

function Utils.getScriptName(scriptName)
  if config and config.externalScriptsNames and config.externalScriptsNames[scriptName] then
    return config.externalScriptsNames[scriptName]
  end
  return scriptName
end

function Utils.getScriptExports(scriptName)
  local actualScriptName, exportsTable
  actualScriptName = Utils.getScriptName(scriptName)
  if not actualScriptName then
    return
  end
  exportsTable = exports[actualScriptName]
  return exportsTable
end

function Utils.getRandomQuantity(min, max)
  if min <= max then
    return math.random(min, max)
  else
    return math.random(max, min)
  end
end
function Utils.callModuleFunc(moduleName, functionName, ...)
  local moduleType, moduleIntegration, moduleFunction
  moduleType = config.modules[moduleName]
  if not moduleType then
    print("^1Select a module for '" .. moduleName .. "' in menu settings!^7")
    return
  end
  moduleIntegration = Integrations[moduleName]
  moduleFunction = moduleIntegration[moduleType][functionName]
  if not moduleFunction then
    print("^1Function " .. functionName .. " does not exist in " .. moduleName .. " module^7")
    return
  end
  return moduleFunction(...)
end

function Utils.findScriptFromExportName(exportName)
  local scripts, i, resourceCount, resourceName
  scripts = {}
  resourceCount = GetNumResources() - 1
  for i = 0, resourceCount do
    resourceName = GetResourceByFindIndex(i)
    if Utils.doesExportExist(resourceName, exportName) then
      scripts[#scripts + 1] = resourceName
    end
  end
  if 0 == #scripts then
    return
  end
  table.sort(scripts)
  return scripts[1]
end

function Utils.doesExportExistAnywhere(exportName)
  local scriptName
  scriptName = Utils.findScriptFromExportName(exportName)
  return nil ~= scriptName
end
function Utils.callScriptExport(scriptName, exportName, ...)
  local actualScriptName, exportExists, foundScriptName, paramString, argCount, i, paramValue, exportsTable
  actualScriptName = Utils.getScriptName(scriptName)
  exportExists = Utils.doesExportExist(actualScriptName, exportName)
  if not exportExists then
    foundScriptName = Utils.findScriptFromExportName(exportName)
    actualScriptName = foundScriptName
    if not actualScriptName then
      paramString = ""
      argCount = select("#", ...)
      for i = 1, argCount do
        paramValue = select(i, ...)
        paramString = paramString .. "param" .. i .. ": " .. type(paramValue)
        if i ~= argCount then
          paramString = paramString .. ", "
        end
      end
      print("^1Couldn't find any script that replaces ^3export['" .. scriptName .. "']:" .. exportName .. "(" .. paramString .. ")^7")
      return -1
    end
  end
  exportsTable = exports[actualScriptName]
  return exportsTable[exportName](exportsTable, ...)
end

function Utils.useDefaultValues(targetTable, defaultValues)
  if not targetTable or not defaultValues then
    print("^1Utils.useDefaultValues error^7")
    return nil
  end
  local result = {}
  for k, v in pairs(defaultValues) do
    if type(v) == "table" then
      result[k] = Utils.useDefaultValues(targetTable[k] or {}, v)
    else
      result[k] = targetTable[k] ~= nil and targetTable[k] or v
    end
  end
  for k, v in pairs(targetTable) do
    if result[k] == nil then
      result[k] = v
    end
  end
  return result
end

function Utils.getProvidedForByScript(scriptName)
  local actualScriptName, provides, metadataCount, i, providedScript
  actualScriptName = Utils.getScriptName(scriptName)
  provides = {}
  metadataCount = GetNumResourceMetadata(actualScriptName, "provide")
  for i = 0, metadataCount - 1 do
    providedScript = GetResourceMetadata(actualScriptName, "provide", i)
    provides[providedScript] = true
  end
  return provides
end
function Utils.doesScriptProvideFor(scriptName, providedScriptName)
  local provides
  provides = Utils.getProvidedForByScript(scriptName)
  return provides[providedScriptName] ~= nil
end

