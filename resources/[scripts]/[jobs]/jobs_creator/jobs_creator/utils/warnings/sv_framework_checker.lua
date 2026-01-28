local function detectFramework()
  local esxScriptName, esxResourceState, qbScriptName, qbResourceState, resourceName
  esxScriptName = Utils.getScriptName("es_extended")
  esxResourceState = GetResourceState(esxScriptName)
  if "missing" ~= esxResourceState then
    return "ESX"
  else
    qbScriptName = Utils.getScriptName("qb-core")
    qbResourceState = GetResourceState(qbScriptName)
    if "missing" ~= qbResourceState then
      return "QB-core"
    end
  end
  print("--------------------------")
  print("^1Couldn't find any server framework^7")
  resourceName = GetCurrentResourceName()
  print("^1If you renamed the folder of your framework script, make sure to change it in " .. resourceName .. "/integrations/sh_integrations.lua^7")
  print("--------------------------")
  return nil
end

Citizen.CreateThread(function()
  local detectedFramework
  detectedFramework = detectFramework()
  if detectedFramework and CURRENT_FRAMEWORK ~= detectedFramework then
    while true do
      print("^1")
      print("=====================================")
      print("You are trying to use the ^4" .. CURRENT_FRAMEWORK .. "^1 of ^4" .. GetCurrentResourceName() .. "^1, but you have ^4" .. detectedFramework .. "^1 framework")
      print("- If you have the correct version in ^3FiveM keymaster^1, please download it and use that one")
      print("- If you don't have the correct version in ^3FiveM keymaster^1, you can purchase it in ^2jaksam's store^1")
      print("=====================================")
      print("^7")
      Citizen.Wait(5000)
    end
  end
end)
