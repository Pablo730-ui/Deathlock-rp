local integrations = {}
local integrationCodes = {}

local esxRefreshJobsIntegration = {}
esxRefreshJobsIntegration.framework = "ESX"
esxRefreshJobsIntegration.resourceName = Utils.getScriptName("es_extended")
esxRefreshJobsIntegration.path = "server/common.lua"
esxRefreshJobsIntegration.keyString = "esx:refreshJobs"
esxRefreshJobsIntegration.code = [[
            -- Jobs Creator integration (jobs_creator)
            RegisterNetEvent('esx:refreshJobs')
            AddEventHandler('esx:refreshJobs', function()
                if type(source) == "number" and source > 0 then
                    print("^1A possible cheater triggered the esx:refreshJobs event", GetPlayerName(source), "(server ID:" .. source .. ")^7")
                    return
                end
                MySQL.Async.fetchAll('SELECT * FROM jobs', {}, function(jobs)
                    for k,v in ipairs(jobs) do
                        ESX.Jobs[v.name] = v
                        ESX.Jobs[v.name].grades = {}
                    end

                    MySQL.Async.fetchAll('SELECT * FROM job_grades', {}, function(jobGrades)
                        for k,v in ipairs(jobGrades) do
                            if ESX.Jobs[v.job_name] then
                                ESX.Jobs[v.job_name].grades[tostring(v.grade)] = v
                            else
                                print(('[es_extended] [^3WARNING^7] Ignoring job grades for "%s" due to missing job'):format(v.job_name))
                            end
                        end

                        for k2,v2 in pairs(ESX.Jobs) do
                            if ESX.Table.SizeOf(v2.grades) == 0 then
                                ESX.Jobs[v2.name] = nil
                                print(('[es_extended] [^3WARNING^7] Ignoring job "%s" due to no job grades found'):format(v2.name))
                            end
                        end
                    end)
                end)
            end)
        ]]

local esxAddonAccountIntegration = {}
esxAddonAccountIntegration.framework = "ESX"
esxAddonAccountIntegration.resourceName = Utils.getScriptName("esx_addonaccount")
esxAddonAccountIntegration.path = "server/main.lua"
esxAddonAccountIntegration.keyString = "esx_addonaccount:refreshAccounts"
esxAddonAccountIntegration.code = [[
            -- Jobs Creator integration (jobs_creator)
            RegisterNetEvent('esx_addonaccount:refreshAccounts')
            AddEventHandler('esx_addonaccount:refreshAccounts', function() 
                if type(source) == "number" and source > 0 then
                    print("^1A possible cheater triggered the esx_addonaccount:refreshAccounts event", GetPlayerName(source), "(server ID:" .. source .. ")^7")
                    return
                end
                local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account')

                for i=1, #result, 1 do
                    local name   = result[i].name
                    local label  = result[i].label
                    local shared = result[i].shared

                    local result2 = MySQL.Sync.fetchAll('SELECT * FROM addon_account_data WHERE account_name = @account_name', {
                        ['@account_name'] = name
                    })

                    if shared == 0 then
                        table.insert(AccountsIndex, name)
                        Accounts[name] = {}

                        for j=1, #result2, 1 do
                            local addonAccount = CreateAddonAccount(name, result2[j].owner, result2[j].money)
                            table.insert(Accounts[name], addonAccount)
                        end
                    else
                        local money = nil

                        if #result2 == 0 then
                            MySQL.Sync.execute('INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, NULL)', {
                                ['@account_name'] = name,
                                ['@money']        = 0
                            })

                            money = 0
                        else
                            money = result2[1].money
                        end

                        local addonAccount   = CreateAddonAccount(name, nil, money)
                        SharedAccounts[name] = addonAccount
                    end
                end
            end)
        ]]

local esxServerCallbacksIntegration1 = {}
esxServerCallbacksIntegration1.framework = "ESX"
esxServerCallbacksIntegration1.resourceName = Utils.getScriptName("es_extended")
esxServerCallbacksIntegration1.path = "server/common.lua"
esxServerCallbacksIntegration1.keyString = "ESX.ServerCallbacks"
esxServerCallbacksIntegration1.code = [[
            -- Jobs Creator integration (jobs_creator)
            ESX.ServerCallbacks = Core.ServerCallbacks
        ]]
function esxServerCallbacksIntegration1.controlFunction()
  local callbackFile

  callbackFile = LoadResourceFile(Utils.getScriptName("es_extended"), "server/modules/callback.lua")
  if callbackFile then
    return false
  end
  return true
end

local esxServerCallbacksIntegration2 = {}
esxServerCallbacksIntegration2.framework = "ESX"
esxServerCallbacksIntegration2.resourceName = Utils.getScriptName("es_extended")
esxServerCallbacksIntegration2.path = "server/modules/callback.lua"
esxServerCallbacksIntegration2.keyString = "ESX.ServerCallbacks"
esxServerCallbacksIntegration2.code = [[
            -- Jobs Creator integration (jobs_creator)
            ESX.ServerCallbacks = serverCallbacks
        ]]
function esxServerCallbacksIntegration2.controlFunction()
  local callbackFile

  callbackFile = LoadResourceFile(Utils.getScriptName("es_extended"), "server/modules/callback.lua")
  if not callbackFile then
    return false
  end
  return callbackFile:find("local serverCallbacks = {}") ~= nil
end

local esxServerCallbacksIntegration3 = {}
esxServerCallbacksIntegration3.framework = "ESX"
esxServerCallbacksIntegration3.resourceName = Utils.getScriptName("es_extended")
esxServerCallbacksIntegration3.path = "server/modules/callback.lua"
esxServerCallbacksIntegration3.keyString = "ESX.ServerCallbacks = Callbacks.storage"
esxServerCallbacksIntegration3.code = [[
            -- Jobs Creator integration (jobs_creator)
            ESX.ServerCallbacks = Callbacks.storage
        ]]
function esxServerCallbacksIntegration3.controlFunction()
  local callbackFile

  callbackFile = LoadResourceFile(Utils.getScriptName("es_extended"), "server/modules/callback.lua")
  if not callbackFile then
    return false
  end
  return callbackFile:find("Callbacks.storage = {}") ~= nil
end

local qbClothingIntegration = {}
qbClothingIntegration.framework = "QB-core"
qbClothingIntegration.resourceName = Utils.getScriptName("qb-clothing")
qbClothingIntegration.path = "client/main.lua"
qbClothingIntegration.keyString = "getPlayerSkin"
qbClothingIntegration.code = [[
            -- Jobs Creator integration (jobs_creator)
            RegisterNetEvent("qb-clothes:getPlayerSkin", function(cb)
                cb(skinData)
            end)
        ]]
function qbClothingIntegration.controlFunction()
  local resourceName

  resourceName = Utils.getScriptName("qb-clothing")
  return CLOTHING_TO_USE == "framework" and Utils.doesScriptProvideFor(resourceName, "qb-clothing") == "framework"
end

local qbWeaponsIntegration = {}
qbWeaponsIntegration.framework = "QB-core"
qbWeaponsIntegration.resourceName = Utils.getScriptName("qb-weapons")
qbWeaponsIntegration.path = "config.lua"
qbWeaponsIntegration.keyString = "getWeaponsAttachments"
qbWeaponsIntegration.code = [[
            -- Jobs Creator integration (jobs_creator)
            RegisterNetEvent("qb-weapons:getWeaponsAttachments", function(cb)
                cb(WeaponAttachments)
            end)
        ]]
function qbWeaponsIntegration.controlFunction()
  return INVENTORY_TO_USE == "default"
end

local qbCoreSharedJobsIntegration = {}
qbCoreSharedJobsIntegration.framework = "QB-core"
qbCoreSharedJobsIntegration.resourceName = Utils.getScriptName("qb-core")
qbCoreSharedJobsIntegration.path = "shared/jobs.lua"
qbCoreSharedJobsIntegration.keyString = "injectJobs"
qbCoreSharedJobsIntegration.code = [[
            -- Jobs Creator integration (jobs_creator)
            RegisterNetEvent("jobs_creator:injectJobs", function(jobs)
                if IsDuplicityVersion() and type(source) == "number" and source > 0 then return end
                QBShared.Jobs = jobs
            end)
        ]]
function qbCoreSharedJobsIntegration.controlFunction()
  return SUBFRAMEWORK == nil
end

local qbCoreServerJobsIntegration = {}
qbCoreServerJobsIntegration.framework = "QB-core"
qbCoreServerJobsIntegration.resourceName = Utils.getScriptName("qb-core")
qbCoreServerJobsIntegration.path = "server/main.lua"
qbCoreServerJobsIntegration.keyString = "injectJobs"
qbCoreServerJobsIntegration.code = [[
            -- Jobs Creator integration (jobs_creator)
            RegisterNetEvent("jobs_creator:injectJobs", function(jobs)
                if type(source) == "number" and source > 0 then return end
                QBCore.Shared.Jobs = jobs
            end)
        ]]
function qbCoreServerJobsIntegration.controlFunction()
  return SUBFRAMEWORK == nil
end

local qbCoreClientJobsIntegration = {}
qbCoreClientJobsIntegration.framework = "QB-core"
qbCoreClientJobsIntegration.resourceName = Utils.getScriptName("qb-core")
qbCoreClientJobsIntegration.path = "client/main.lua"
qbCoreClientJobsIntegration.keyString = "injectJobs"
qbCoreClientJobsIntegration.code = [[
            -- Jobs Creator integration (jobs_creator)
            RegisterNetEvent("jobs_creator:injectJobs", function(jobs)
                QBCore.Shared.Jobs = jobs
            end)
        ]]
function qbCoreClientJobsIntegration.controlFunction()
  return SUBFRAMEWORK == nil
end

integrations[1] = esxRefreshJobsIntegration
integrations[2] = esxAddonAccountIntegration
integrations[3] = esxServerCallbacksIntegration1
integrations[4] = esxServerCallbacksIntegration2
integrations[5] = esxServerCallbacksIntegration3
integrations[6] = qbClothingIntegration
integrations[7] = qbWeaponsIntegration
integrations[8] = qbCoreSharedJobsIntegration
integrations[9] = qbCoreServerJobsIntegration
integrations[10] = qbCoreClientJobsIntegration

function doesCodeExistInFile(resourceName, filePath, keyString)
  local fileContent, exists

  fileContent = LoadResourceFile(resourceName, filePath)
  if fileContent then
    exists = fileContent:match(keyString)
    return exists ~= nil
  else
    return false
  end
end

function addCodeToFile(resourceName, filePath, code)
  local fileContent, success, tempFileName, tempPath, directoryName, fileName

  fileContent = LoadResourceFile(resourceName, filePath)
  if not fileContent then
    print("^1" .. filePath .. " can't be found in " .. resourceName .. "^7")
    return false, nil
  end

  fileContent = fileContent .. "\n\n" .. code
  success = SaveResourceFile(resourceName, filePath, fileContent, -1)
  if success then
    return true
  end

  tempFileName = filePath:gsub("/", "-")
  tempPath = "tmp/" .. resourceName .. "-" .. tempFileName
  currentResource = GetCurrentResourceName()
  SaveResourceFile(currentResource, tempPath, fileContent, -1)

  directoryName = filePath:match("(.*/)")
  fileName = filePath:match("[^/]+$")

  print()
  print("^1Failed to add integration to ^3'" .. directoryName .. fileName .. "'^1, the file is probably read-only. To fix it, follow these steps:^7")
  print("1. Backup the file ^3" .. directoryName .. fileName .. "^7 and delete it from the ^3" .. resourceName .. "^7 resource")
  print("2. Move the file ^3" .. tempPath .. "^7 to ^2" .. directoryName .. "^7")
  print("3. Rename the file ^3" .. directoryName .. tempFileName .. "^7 to ^2" .. fileName .. "^7 (so it replaces the file you backed up and deleted in step 1)")
  print("4. Restart the server")
  print("----------------------------------")
  print()

  return false, tempPath
end

function integrateAllCodes()
  local hasIntegrations, integration, framework, controlFunction, exists, success, tempPath, resourceName, path, fileName, directoryName

  hasIntegrations = false
  for _, integration in pairs(integrations) do
    framework = integration.framework
    controlFunction = integration.controlFunction

    if not framework or (controlFunction and controlFunction()) then
      exists = doesCodeExistInFile(integration.resourceName, integration.path, integration.keyString)
      if not exists then
        success, tempPath = addCodeToFile(integration.resourceName, integration.path, integration.code)
        if success then
          print("^2Added integration to " .. integration.resourceName .. "/" .. integration.path .. "^7")
          hasIntegrations = true
        elseif tempPath then
          resourceName = integration.resourceName
          path = integration.path
          fileName = tempPath:match("[^/]+$")
          directoryName = path:match("(.*/)")

          print()
          print("^1Failed to add integration to ^3'" .. directoryName .. (path:match("[^/]+$")) .. "'^1, the file is probably read-only. To fix it, follow these steps:^7")
          print("1. Backup the file ^3" .. directoryName .. (path:match("[^/]+$")) .. "^7 and delete it from the ^3" .. resourceName .. "^7 resource")
          print("2. Move the file ^3" .. tempPath .. "^7 to ^2" .. directoryName .. "^7")
          print("3. Rename the file ^3" .. directoryName .. fileName .. "^7 to ^2" .. (path:match("[^/]+$")) .. "^7 (so it replaces the file you backed up and deleted in step 1)")
          print("4. Restart the server")
          print("----------------------------------")
          print()
        end
      end
    end
  end

  if hasIntegrations then
    endTime = GetGameTimer() + 10000
    while GetGameTimer() < endTime do
      Citizen.Wait(1000)
      print("^3Code integration automatically done, SERVER REQUIRES RESTART^7")
    end
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":serverConfigLoadedOnStart", function()
  local integration

  for _, integration in pairs(integrations) do
    integration.resourceName = Utils.getScriptName(integration.resourceName)
  end
  integrateAllCodes()
end)
