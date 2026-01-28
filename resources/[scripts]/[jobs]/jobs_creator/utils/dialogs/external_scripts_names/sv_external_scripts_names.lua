local function formatResourceList(resourceNames)
  local resources, i, resourceName, resourceInfo
  resources = {}
  for i = 1, #resourceNames do
    resourceName = resourceNames[i]
    resourceInfo = {}
    resourceInfo.name = resourceName
    resourceInfo.state = GetResourceState(resourceName)
    resourceInfo.version = GetResourceMetadata(resourceName, "version")
    resourceInfo.author = GetResourceMetadata(resourceName, "author")
    resources[#resources + 1] = resourceInfo
  end
  table.sort(resources, function(a, b)
    return a.name < b.name
  end)
  return resources
end
local function getIntegrationsResources()
  local resources, timeout, resourceName
  resources = {}
  timeout = GetGameTimer() + 10000
  while true do
    if config.externalScriptsNames then
      break
    end
    Citizen.Wait(1000)
    if timeout < GetGameTimer() then
      print("^7Couldn't find 'config.externalScriptsNames', update the script and REPLACE 'default_config.json' file^7")
      return
    end
  end
  for resourceName, _ in pairs(config.externalScriptsNames) do
    resources[#resources + 1] = resourceName
  end
  return formatResourceList(resources)
end
local function getAllResources()
  local resources, resourceCount, i, resourceName
  resourceCount = GetNumResources()
  resources = {}
  for i = 0, resourceCount - 1 do
    resourceName = GetResourceByFindIndex(i)
    resources[#resources + 1] = resourceName
  end
  return formatResourceList(resources)
end
RegisterServerCallback(Utils.eventsPrefix .. ":getAllResources", function(sourceId, callback)
  local isAllowed
  isAllowed = Utils.isAllowed(sourceId)
  if not isAllowed then
    return
  end
  callback(getAllResources())
end)
RegisterServerCallback(Utils.eventsPrefix .. ":getIntegrationsResources", function(sourceId, callback)
  local isAllowed
  isAllowed = Utils.isAllowed(sourceId)
  if not isAllowed then
    return
  end
  callback(getIntegrationsResources())
end)
