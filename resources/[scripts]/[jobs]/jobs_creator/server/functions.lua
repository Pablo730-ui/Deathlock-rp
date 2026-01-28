local markersByJob = {}
local markersByJobAndGrade = {}
local jobNamesByGradeId = {}

function isAllowedToUseMarker(playerId, markerId)
  local markerData, jobName, jobGrade, gradesType

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.jobName
  end

  if "public_marker" == markerData then
    return true
  end

  jobName = Framework.getPlayerJobName(playerId)
  jobGrade = Framework.getPlayerJobGrade(playerId)

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.gradesType
  end

  if "minimumGrade" == markerData then
    markerData = JobsCreator.Markers[markerId]
    if markerData then
      markerData = markerData.jobName
    end
    return markerData == jobName
  elseif "specificGrades" == markerData then
    markerData = JobsCreator.Markers[markerId]
    if markerData then
      markerData = markerData.jobName
    end
    jobGrade = JobsCreator.Markers[markerId]
    if jobGrade then
      jobGrade = jobGrade.specificGrades
    end
    jobGrade = tostring(jobGrade)
    return markerData == jobName and jobGrade
  end
end

function canUseMarkerWithLog(playerId, markerId)
  local isAllowed, isClose

  isAllowed = isAllowedToUseMarker(playerId, markerId)
  if not isAllowed then
    Utils.log(playerId, getLocalizedText("log_not_allowed_marker"), getLocalizedText("log_not_allowed_marker_description", markerId), "error", "marker")
    return false
  end

  isClose = isCloseToMarker(playerId, markerId)
  if not isClose then
    print("^3" .. GetPlayerName(playerId) .. "^7 tried to use marker ^5" .. markerId .. "^7 but he wasn't close enough")
    return false
  end

  return true
end

function isCloseToMarker(playerId, markerId)
  local playerPed = GetPlayerPed(playerId)
  local playerCoords = GetEntityCoords(playerPed)
  local markerCoords = vecFromTable(JobsCreator.Markers[markerId].coords)
  local markerScale = JobsCreator.Markers[markerId].scale
  local distance = #(playerCoords - markerCoords)
  return distance < markerScale.x + 2.0
end

function getJobNameFromGradeId(gradeId)
  local cachedJobName

  cachedJobName = jobNamesByGradeId[gradeId]
  if cachedJobName then
    return cachedJobName
  end

  cachedJobName = MySQL.Sync.fetchScalar("SELECT job_name FROM job_grades WHERE id=@id", {
    ["@id"] = gradeId
  })
  jobNamesByGradeId[gradeId] = cachedJobName
  return cachedJobName
end

function getGradeFromGradeId(gradeId)
  local promise, grade

  promise = promise.new()
  MySQL.Async.fetchScalar("SELECT grade FROM job_grades WHERE id=@id", {
    ["@id"] = gradeId
  }, function(result)
    promise:resolve(result)
  end)
  return Citizen.Await(promise)
end

RegisterServerCallback(Utils.eventsPrefix .. ":checkAllowedActions", function(playerId, callback)
  local jobName, jobData

  while true do
    if Framework.isPlayerLoaded(playerId) then
      break
    end
    Citizen.Wait(1000)
  end

  jobName = Framework.getPlayerJobName(playerId)
  jobData = JobsCreator.Jobs[jobName]
  if jobData then
    callback(jobData.actions)
  else
    callback({})
  end
end)

function payInSomeWay(playerId, amount)
  local framework, player, cashMoney, bankMoney, identifier, cashAccount, bankAccount

  framework = Framework.getFramework()
  if "ESX" == framework then
    player = ESX.GetPlayerFromId(playerId)
    cashMoney = player.getMoney()
    if amount <= cashMoney then
      player.removeMoney(amount)
      return true
    else
      bankMoney = player.getAccount("bank")
      bankMoney = bankMoney.money
      if amount <= bankMoney then
        player.removeAccountMoney("bank", amount)
        return true
      else
        return false
      end
    end
  else
    framework = Framework.getFramework()
    if "QB-core" == framework then
      identifier = Framework.getPlayerCharIdentifier(playerId)
      cashAccount = Framework.getAccountMoneyFromIdentifier(identifier, "cash")
      if amount <= cashAccount then
        Framework.removeAccountMoneyFromIdentifier(identifier, "cash", amount)
        return true
      else
        bankAccount = Framework.getAccountMoneyFromIdentifier(identifier, "bank")
        if amount <= bankAccount then
          Framework.removeAccountMoneyFromIdentifier(identifier, "bank", amount)
          return true
        else
          return false
        end
      end
    end
  end
end

function arePlayersClose(playerId1, playerId2, maxDistance)
  local ped1, ped2, coords1, coords2, distance

  ped1 = GetPlayerPed(playerId1)
  ped2 = GetPlayerPed(playerId2)
  if ped1 and ped1 > 0 and ped2 and ped2 > 0 then
    coords1 = GetEntityCoords(ped1)
    coords2 = GetEntityCoords(ped2)
    distance = #(coords1 - coords2)
    return maxDistance > distance
  else
    return false
  end
end

function notify(playerId, message)
  if playerId then
    TriggerClientEvent(Utils.eventsPrefix .. ":notifyClient", playerId, message)
  end
end

function timedFreezePlayer(playerId, duration)
  TriggerClientEvent(Utils.eventsPrefix .. ":startTimedFreeze", playerId, duration)
end

function getOnlinePlayersCount(jobName)
  local count, players, i, playerId, playerJobName

  count = 0
  players = GetPlayers()
  for i = 1, #players, 1 do
    playerId = tonumber(players[i])
    playerJobName = Framework.getPlayerJobName(playerId)
    if playerJobName == jobName then
      count = count + 1
    end
  end
  return count
end

function getAllJobsOnlinePlayers(playerId, callback)
  local isAllowed, jobsList, jobName, jobData, playersCount

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  jobsList = {}
  for jobName, jobData in pairs(JobsCreator.Jobs) do
    playersCount = getOnlinePlayersCount(jobName)
    table.insert(jobsList, {
      playersCount = playersCount,
      label = jobData.label,
      name = jobName
    })
  end

  callback(jobsList)
end

RegisterServerCallback(Utils.eventsPrefix .. ":getAllJobsOnlinePlayers", getAllJobsOnlinePlayers)

function getAllJobsTotalPlayersFromDatabase()
  local jobsByPlayersCount, framework

  framework = Framework.getFramework()
  if "ESX" == framework then
    jobsByPlayersCount = MySQL.Sync.fetchScalar([[
            SELECT JSON_OBJECTAGG(job, count) AS jobsByPlayersCount
            FROM (
                SELECT job, COUNT(*) AS count
                FROM users
                GROUP BY job
            ) AS job_counts;
        ]])
  else
    framework = Framework.getFramework()
    if "QB-core" == framework then
      jobsByPlayersCount = MySQL.Sync.fetchScalar([[
			SELECT JSON_OBJECTAGG(job_name, count) AS jobsByPlayersCount
			FROM (
				SELECT JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) AS job_name, COUNT(*) AS count
				FROM players
				GROUP BY job_name
			) AS job_counts;
        ]])
    end
  end

  return json.decode(jobsByPlayersCount)
end

function getAllJobsTotalPlayers(playerId, callback)
  local isAllowed, jobsByPlayersCount, jobsList, jobName, jobData, playerCount

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  jobsByPlayersCount = getAllJobsTotalPlayersFromDatabase()
  jobsList = {}
  for jobName, jobData in pairs(JobsCreator.Jobs) do
    playerCount = jobsByPlayersCount[jobName]
    if not playerCount then
      playerCount = 0
    end
    table.insert(jobsList, {
      playersCount = playerCount,
      label = jobData.label,
      name = jobName
    })
  end

  callback(jobsList)
end

RegisterServerCallback(Utils.eventsPrefix .. ":getAllJobsTotalPlayers", getAllJobsTotalPlayers)

function getJobsSocietyMoney(playerId, callback)
  local isAllowed, jobsList, jobName, jobData, societyMoney

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  jobsList = {}
  for jobName, jobData in pairs(JobsCreator.Jobs) do
    societyMoney = Framework.getSocietyAccountMoney(jobName)
    table.insert(jobsList, {
      money = societyMoney,
      label = jobData.label,
      name = jobName
    })
  end

  callback(jobsList)
end

RegisterServerCallback(Utils.eventsPrefix .. ":getJobsSocietyMoney", getJobsSocietyMoney)

function getPlayersCountByJobAndGrade(jobName, grade)
  local framework, count

  local promise = promise.new()
  
  framework = Framework.getFramework()
  if "ESX" == framework then
    MySQL.Async.fetchScalar("SELECT COUNT(*) FROM users WHERE job=@jobName AND job_grade=@rankGrade", {
      ["@jobName"] = jobName,
      ["@rankGrade"] = grade
    }, function(result)
      promise:resolve(result)
    end)
  else
    framework = Framework.getFramework()
    if "QB-core" == framework then
      MySQL.Async.fetchAll("SELECT job FROM players", {}, function(results)
        count = 0
        for _, playerData in pairs(results) do
          local jobData = json.decode(playerData.job)
          if jobData.name == jobName then
            if jobData.grade.level == grade then
              count = count + 1
            end
          end
        end
        promise:resolve(count)
      end)
    end
  end
  return promise
end

function getRanksDistribution(playerId, callback, jobName)
  local isAllowed

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  MySQL.Async.fetchAll("SELECT grade, label FROM job_grades WHERE job_name = @jobName", {
    ["@jobName"] = jobName
  }, function(grades)
    local ranksList, grade, label, playersCount

    ranksList = {}
    for _, gradeData in pairs(grades) do
      grade = gradeData.grade
      label = gradeData.label
      playersCount = Citizen.Await(getPlayersCountByJobAndGrade(jobName, grade))
      table.insert(ranksList, {
        playersCount = playersCount,
        label = label,
        grade = grade
      })
    end

    callback(ranksList)
  end)
end

RegisterServerCallback(Utils.eventsPrefix .. ":getRanksDistribution", getRanksDistribution)

JobsCreator.refreshFrameworkJobs = function()
  local framework

  framework = Framework.getFramework()
  if "ESX" == framework then
    TriggerEvent("esx:refreshJobs")
  else
    framework = Framework.getFramework()
    if "QB-core" == framework then
      JobsCreator.injectJobsInQBCoreTable()
    end
  end

  SetTimeout(1500, function()
    TriggerEvent(Utils.eventsPrefix .. ":refreshJobs")
    TriggerClientEvent(Utils.eventsPrefix .. ":refreshJobs", -1)
  end)
end

RegisterServerCallback(Utils.eventsPrefix .. ":createRank", function(playerId, callback, jobName, rankName, rankLabel, rankGrade, rankSalary)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    result = JobsCreator.createRank(jobName, rankName, rankLabel, rankGrade, rankSalary)
    callback(result)
  end
end)

function updateRank(rankData)
  local promise, jobName, oldGrade, newGrade, existingRank

  promise = promise.new()
  jobName = getJobNameFromGradeId(rankData.rankId)
  oldGrade = getGradeFromGradeId(rankData.rankId)
  newGrade = rankData.rankGrade

  if oldGrade ~= newGrade then
    existingRank = JobsCreator.Jobs[jobName]
    if existingRank then
      existingRank = existingRank.ranks
      if existingRank then
        existingRank = existingRank[newGrade]
      end
    end

    if existingRank then
      return {
        isSuccessful = false,
        message = "This grade already exists"
      }
    end
  end

  MySQL.Async.execute("UPDATE job_grades SET name=@rankName, grade=@rankGrade, label=@rankLabel, salary=@rankSalary WHERE id=@rankId", {
    ["@rankId"] = rankData.rankId,
    ["@rankGrade"] = rankData.rankGrade,
    ["@rankLabel"] = rankData.rankLabel,
    ["@rankSalary"] = rankData.rankSalary,
    ["@rankName"] = rankData.rankName
  }, function(affectedRows)
    if affectedRows > 0 then
      local jobData, rankEntry

      jobData = JobsCreator.Jobs[jobName]
      if jobData then
        rankEntry = {
          name = rankData.rankName,
          label = rankData.rankLabel,
          salary = rankData.rankSalary,
          grade = rankData.rankGrade,
          id = rankData.rankId
        }
        jobData.ranks[rankData.rankGrade] = rankEntry

        if oldGrade ~= newGrade then
          jobData.ranks[oldGrade] = nil
        end
      end

      JobsCreator.refreshFrameworkJobs()
      promise:resolve({
        isSuccessful = true,
        message = "Successful"
      })
    else
      promise:resolve({
        isSuccessful = false,
        message = "Couldn't update the rank (check server console)"
      })
    end
  end)

  return Citizen.Await(promise)
end

RegisterServerCallback(Utils.eventsPrefix .. ":updateRank", function(playerId, callback, rankData)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    result = updateRank(rankData)
    callback(result)
  end
end)

function deleteRank(rankId)
  local promise, jobName, oldGrade

  promise = promise.new()
  jobName = getJobNameFromGradeId(rankId)
  oldGrade = getGradeFromGradeId(rankId)

  MySQL.Async.execute("DELETE FROM `job_grades` WHERE id=@rankId", {
    ["@rankId"] = rankId
  }, function(affectedRows)
    if affectedRows > 0 then
      jobNamesByGradeId[rankId] = nil

      local jobData = JobsCreator.Jobs[jobName]
      if jobData then
        jobData.ranks[oldGrade] = nil
      end

      JobsCreator.refreshFrameworkJobs()

      local framework = Framework.getFramework()
      if "ESX" == framework then
        MySQL.Async.execute("UPDATE `users` SET job_grade=0 WHERE job=@jobName AND job_grade=@jobGrade", {
          ["@jobName"] = jobName,
          ["@jobGrade"] = oldGrade
        }, function()
          promise:resolve({
            isSuccessful = true,
            message = "Successful"
          })
        end)
      else
        promise:resolve({
          isSuccessful = true,
          message = "Successful"
        })
      end
    else
      promise:resolve({
        isSuccessful = false,
        message = "Couldn't delete rank id: " .. rankId .. " (check server console)"
      })
    end
  end)

  return Citizen.Await(promise)
end

RegisterServerCallback(Utils.eventsPrefix .. ":deleteRank", function(playerId, callback, rankId)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    result = deleteRank(rankId)
    callback(result)
  end
end)

function deleteGradesOfJob(jobName)
  MySQL.Async.execute("DELETE FROM job_grades WHERE job_name=@jobName", {
    ["@jobName"] = jobName
  }, function(affectedRows)
    if affectedRows > 0 then
      for gradeId, jobNameInCache in pairs(jobNamesByGradeId) do
        if jobNameInCache == jobName then
          jobNamesByGradeId[gradeId] = nil
        end
      end
    end
  end)
end

function retrieveJobRanks(jobName)
  local jobData

  jobData = JobsCreator.Jobs[jobName]
  if not jobData then
    return {}
  end

  jobData = JobsCreator.Jobs[jobName]
  if jobData then
    jobData = jobData.ranks
  end
  return jobData
end

RegisterServerCallback(Utils.eventsPrefix .. ":retrieveJobRanks", function(playerId, callback, jobName)
  if jobName then
    callback(retrieveJobRanks(jobName))
  else
    callback(false)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getJobsData", function(playerId, callback)
  local isAllowed

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  while true do
    if hasFirstLoadFinished then
      break
    end
    Citizen.Wait(200)
  end

  callback(JobsCreator.Jobs)
end)

function registerSocieties()
  for jobName, jobData in pairs(JobsCreator.Jobs) do
    createSociety(jobName, jobData.label)
  end
end

function createAddonAccount(jobName, jobLabel, societyName)
  MySQL.Async.fetchScalar("SELECT 1 FROM `addon_account` WHERE BINARY(name)=@societyName", {
    ["@societyName"] = societyName
  }, function(exists)
    if exists then
      return
    end

    MySQL.Async.execute("INSERT INTO `addon_account`(name, label, shared) VALUES (@societyName, @jobLabel, 1) ON DUPLICATE KEY UPDATE name=@societyName", {
      ["@societyName"] = societyName,
      ["@jobLabel"] = jobLabel
    }, function(affectedRows)
      if affectedRows > 0 then
        print("Created ^5" .. jobName .. "^7 in ^8'addon_account'^7")
        MySQL.Async.fetchScalar("SELECT 1 FROM addon_account_data WHERE account_name=@societyName", {
          ["@societyName"] = societyName
        }, function(exists)
          if exists then
            TriggerEvent("esx_addonaccount:refreshAccounts")
            return
          end

          MySQL.Async.execute("INSERT INTO `addon_account_data`(account_name, money, owner) VALUES (@societyName, 0, NULL) ON DUPLICATE KEY UPDATE account_name=@societyName", {
            ["@societyName"] = societyName
          }, function(affectedRows)
            if affectedRows > 0 then
              print("Created ^5" .. jobName .. "^7 in ^8'addon_account_data'^7")
            end
            TriggerEvent("esx_addonaccount:refreshAccounts")
          end)
        end)
      end
    end)
  end)
end

function createDatastore(jobName, jobLabel, societyName)
  MySQL.Async.fetchScalar("SELECT 1 FROM datastore WHERE BINARY(name)=@societyName", {
    ["@societyName"] = societyName
  }, function(exists)
    if exists then
      return
    end

    MySQL.Async.execute("INSERT INTO `datastore`(name, label, shared) VALUES (@societyName, @jobLabel, 1) ON DUPLICATE KEY UPDATE name=@societyName", {
      ["@societyName"] = societyName,
      ["@jobLabel"] = jobLabel
    }, function(affectedRows)
      if affectedRows > 0 then
        print("Created ^5" .. jobName .. "^7 in ^3'datastore'^7")
        MySQL.Async.fetchScalar("SELECT 1 FROM datastore_data WHERE BINARY(name)=@societyName", {
          ["@societyName"] = societyName
        }, function(exists)
          if exists then
            return
          end

          MySQL.Async.execute("INSERT INTO `datastore_data`(name, owner, data) VALUES (@societyName, NULL, \"{}\") ON DUPLICATE KEY UPDATE name=@societyName", {
            ["@societyName"] = societyName
          }, function(affectedRows)
            if affectedRows > 0 then
              print("Created ^5" .. jobName .. "^7 in ^3'datastore_data'^7")
            end
          end)
        end)
      end
    end)
  end)
end

function createAddonInventory(jobName, jobLabel, societyName)
  MySQL.Async.fetchScalar("SELECT 1 FROM addon_inventory WHERE BINARY(name)=@societyName", {
    ["@societyName"] = societyName
  }, function(exists)
    if exists then
      return
    end

    MySQL.Async.execute("INSERT INTO `addon_inventory`(name, label, shared) VALUES (@societyName, @jobLabel, 1) ON DUPLICATE KEY UPDATE name=@societyName", {
      ["@societyName"] = societyName,
      ["@jobLabel"] = jobLabel
    }, function(affectedRows)
      if affectedRows > 0 then
        print("Created ^5" .. jobName .. "^7 in ^2'addon_inventory'^7")
      end
    end)
  end)
end

function registerSocietyInESX(jobName, jobLabel, societyName, retryCount)
  Citizen.CreateThread(function()
    local doesExportExist, existingSociety, sharedValue

    doesExportExist = Utils.doesExportExistAnywhere("GetSociety")
    if not doesExportExist then
      return
    end

    existingSociety = Utils.callScriptExport("esx_society", "GetSociety", societyName)
    if not existingSociety then
      existingSociety = Utils.callScriptExport("esx_society", "GetSociety", jobName)
      if not existingSociety then
        existingSociety = nil
      end
    end

    if existingSociety then
      return
    end

    if not retryCount then
      retryCount = 1
    end

    sharedValue = MySQL.Sync.fetchScalar("SELECT shared FROM addon_account WHERE name=@societyName", {
      ["@societyName"] = societyName
    })
    if 1 ~= sharedValue then
      return
    end

    TriggerEvent(EXTERNAL_EVENTS_NAMES["esx_society:registerSociety"], jobName, jobLabel, societyName, societyName, societyName, {
      type = "public"
    })

    Citizen.Wait(2000)

    TriggerEvent(EXTERNAL_EVENTS_NAMES["esx_society:getSociety"], jobName, function(society)
      if not society then
        return
      end

      TriggerEvent(EXTERNAL_EVENTS_NAMES["esx_addonaccount:getSharedAccount"], societyName, function(account)
        if account then
          return
        end

        local accountData = MySQL.Sync.fetchAll("SELECT * FROM addon_account WHERE name=@societyName", {
          ["@societyName"] = societyName
        })
        if accountData[1] then
          if accountData[1].name == societyName then
            sharedValue = accountData[1].shared
          end
          if 0 == sharedValue then
            print()
            print("^1 Found ^5" .. jobName .. "^1 in database table 'addon_account' but couldn't register it^7")
            print("^1 Database values: name = " .. accountData[1].name .. ", label = " .. accountData[1].label .. ", shared = " .. accountData[1].shared .. "^7")
          end
        else
          print("^1 Couldn't find ^5" .. societyName .. "^1 in database table 'addon_account'^7")
        end

        if retryCount < 3 then
          Citizen.Wait(2000)
          registerSocietyInESX(jobName, jobLabel, societyName, retryCount + 1)
        end
      end)

      TriggerEvent(EXTERNAL_EVENTS_NAMES["esx_datastore:getSharedDataStore"], societyName, function(datastore)
        if datastore then
          return
        end

        local datastoreData = MySQL.Sync.fetchAll("SELECT * FROM datastore WHERE name=@societyName", {
          ["@societyName"] = societyName
        })
        if datastoreData[1] then
          if datastoreData[1].name == societyName then
            sharedValue = datastoreData[1].shared
          end
          if 0 == sharedValue then
            print()
            print("^1 Found ^5" .. jobName .. "^1 in database table 'datastore' but couldn't register it^7")
            print("^1 Database values: name = " .. datastoreData[1].name .. ", label = " .. datastoreData[1].label .. ", shared = " .. datastoreData[1].shared .. "^7")
          end
        else
          print("^1 Couldn't find ^5" .. societyName .. "^1 in database table 'datastore'^7")
        end

        if retryCount < 3 then
          Citizen.Wait(2000)
          registerSocietyInESX(jobName, jobLabel, societyName, retryCount + 1)
        end
      end)
    end)
  end)
end

function createSociety(jobName, jobLabel)
  local framework, societyName

  framework = Framework.getFramework()
  if "ESX" ~= framework then
    return
  end

  societyName = "society_" .. jobName

  createAddonAccount(jobName, jobLabel, societyName)
  createAddonInventory(jobName, jobLabel, societyName)
  createDatastore(jobName, jobLabel, societyName)
  registerSocietyInESX(jobName, jobLabel, societyName)
end

JobsCreator.findLowestGrade = function(jobName)
  local grade

  grade = 0
  while true do
    local rankData = JobsCreator.Jobs[jobName]
    if rankData then
      rankData = rankData.ranks
      if rankData then
        rankData = rankData[grade]
      end
    end
    if rankData then
      break
    end
    grade = grade + 1
    if grade > 10 then
      print("Couldn't find the lowest grade of " .. jobName)
      return false
    end
  end
  return grade
end

JobsCreator.fixJobNameWhenNeeded = function(jobName)
  local fixedJobName, suffix, testName, existingJob

  fixedJobName = jobName
  existingJob = JobsCreator.Jobs[fixedJobName]
  if not existingJob then
    return fixedJobName
  end

  fixedJobName = ""
  suffix = 2
  repeat
    testName = jobName .. "_" .. tostring(suffix)
    fixedJobName = testName
    suffix = suffix + 1
    existingJob = JobsCreator.Jobs[fixedJobName]
  until not existingJob

  return fixedJobName
end

JobsCreator.createJob = function(jobName, jobLabel)
  local optionsJson, insertId, jobData

  optionsJson = json.encode({})

  insertId = MySQL.Sync.execute("INSERT INTO jobs(name, label, options) VALUES (@jobName, @jobLabel, @options)", {
    ["@jobName"] = jobName,
    ["@jobLabel"] = jobLabel,
    ["@options"] = optionsJson
  })

  if not insertId or 0 == insertId then
    return {
      isSuccessful = false,
      message = "Couldn't create the job (check server console)"
    }
  end

  createSociety(jobName, jobLabel)

  jobData = {
    name = jobName,
    label = jobLabel,
    actions = {},
    ranks = {}
  }
  JobsCreator.Jobs[jobName] = jobData

  JobsCreator.refreshFrameworkJobs()
  JobsCreator.preloadMarkersForJobName(jobName)

  return {
    isSuccessful = true,
    message = "Successful"
  }
end

RegisterServerCallback(Utils.eventsPrefix .. ":createNewJob", function(playerId, callback, jobName, jobLabel)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    result = JobsCreator.createJob(jobName, jobLabel)
    callback(result)
  end
end)

JobsCreator.createRank = function(jobName, rankName, rankLabel, rankGrade, rankSalary)
  local existingRank, insertQuery, rankId, rankEntry

  existingRank = JobsCreator.Jobs[jobName]
  if existingRank then
    existingRank = existingRank.ranks
    if existingRank then
      existingRank = existingRank[rankGrade]
    end
  end

  if existingRank then
    return {
      isSuccessful = false,
      message = "Rank grade already exists"
    }
  end

  insertQuery = [[
        INSERT INTO job_grades(job_name, name, label, grade, salary, skin_male, skin_female) 
        VALUES (@jobName, @rankName, @rankLabel, @rankGrade, @rankSalary, "{}", "{}");
    ]]

  local framework = Framework.getFramework()
  if "QB-core" == framework then
    insertQuery = [[
            INSERT INTO job_grades(job_name, name, label, grade, salary) 
            VALUES (@jobName, @rankName, @rankLabel, @rankGrade, @rankSalary);
        ]]
  end

  rankId = MySQL.Sync.insert(insertQuery, {
    ["@jobName"] = jobName,
    ["@rankName"] = rankName,
    ["@rankLabel"] = rankLabel,
    ["@rankGrade"] = rankGrade,
    ["@rankSalary"] = rankSalary
  })

  if not rankId or 0 == rankId then
    return {
      isSuccessful = false,
      message = "Couldn't create rank (check server console)"
    }
  end

  jobNamesByGradeId[rankId] = jobName

  rankEntry = {
    grade = rankGrade,
    name = rankName,
    label = rankLabel,
    salary = rankSalary,
    id = rankId
  }
  JobsCreator.Jobs[jobName].ranks[rankGrade] = rankEntry

  JobsCreator.refreshFrameworkJobs()
  JobsCreator.preloadMarkersForJobName(jobName)

  return {
    isSuccessful = true,
    message = "Successful"
  }
end

function updateJobGradesJobName(oldJobName, newJobName)
  MySQL.Async.execute("UPDATE job_grades SET job_name=@newJobName WHERE job_name=@oldJobName", {
    ["@oldJobName"] = oldJobName,
    ["@newJobName"] = newJobName
  })
end

function updateJobsDataJobName(oldJobName, newJobName)
  MySQL.Async.execute("UPDATE jobs_data SET job_name=@newJobName WHERE job_name=@oldJobName", {
    ["@oldJobName"] = oldJobName,
    ["@newJobName"] = newJobName
  })
end

function updateUsersJobName(oldJobName, newJobName)
  local framework

  framework = Framework.getFramework()
  if "ESX" == framework then
    MySQL.Async.execute("UPDATE users SET job=@newJobName WHERE job=@oldJobName", {
      ["@oldJobName"] = oldJobName,
      ["@newJobName"] = newJobName
    })
  end
end

function updateAddonAccountJobName(oldJobName, newJobName)
  local oldSocietyName, newSocietyName

  oldSocietyName = "society_" .. oldJobName
  newSocietyName = "society_" .. newJobName

  MySQL.Async.execute("UPDATE addon_account SET name=@newSocietyName WHERE name=@oldSocietyName", {
    ["@oldSocietyName"] = oldSocietyName,
    ["@newSocietyName"] = newSocietyName
  }, function(affectedRows)
    if affectedRows > 0 then
      MySQL.Async.execute("UPDATE addon_account_data SET account_name=@newSocietyName WHERE account_name=@oldSocietyName", {
        ["@oldSocietyName"] = oldSocietyName,
        ["@newSocietyName"] = newSocietyName
      })
    end
  end)
end

function updateAddonInventoryJobName(oldJobName, newJobName)
  local oldSocietyName, newSocietyName

  oldSocietyName = "society_" .. oldJobName
  newSocietyName = "society_" .. newJobName

  MySQL.Async.execute("UPDATE addon_inventory SET name=@newSocietyName WHERE name=@oldSocietyName", {
    ["@oldSocietyName"] = oldSocietyName,
    ["@newSocietyName"] = newSocietyName
  }, function(affectedRows)
    if affectedRows > 0 then
      MySQL.Async.execute("UPDATE addon_inventory_items SET inventory_name=@newSocietyName WHERE inventory_name=@oldSocietyName", {
        ["@oldSocietyName"] = oldSocietyName,
        ["@newSocietyName"] = newSocietyName
      })
    end
  end)
end

function updateDatastoreJobName(oldJobName, newJobName)
  local oldSocietyName, newSocietyName

  oldSocietyName = "society_" .. oldJobName
  newSocietyName = "society_" .. newJobName

  MySQL.Async.execute("UPDATE datastore SET name=@newSocietyName WHERE name=@oldSocietyName", {
    ["@oldSocietyName"] = oldSocietyName,
    ["@newSocietyName"] = newSocietyName
  }, function(affectedRows)
    if affectedRows > 0 then
      MySQL.Async.execute("UPDATE datastore_data SET name=@newSocietyName WHERE name=@oldSocietyName", {
        ["@oldSocietyName"] = oldSocietyName,
        ["@newSocietyName"] = newSocietyName
      })
    end
  end)
end

function updateAllJobNameReferences(oldJobName, newJobName)
  updateJobGradesJobName(oldJobName, newJobName)
  updateJobsDataJobName(oldJobName, newJobName)
  updateUsersJobName(oldJobName, newJobName)

  local framework = Framework.getFramework()
  if "ESX" == framework then
    updateAddonAccountJobName(oldJobName, newJobName)
    updateAddonInventoryJobName(oldJobName, newJobName)
    updateDatastoreJobName(oldJobName, newJobName)
  end
end

JobsCreator.updateJob = function(oldJobName, newJobName, newJobLabel, newActions)
  if not (oldJobName and newJobName) or not newJobLabel then
    return {
      isSuccessful = false,
      message = "Couldn't update the job, argument missing"
    }
  end

  local optionsJson, players, playerId, playerJobName

  optionsJson = json.encode(newActions)

  for _, playerIdStr in pairs(GetPlayers()) do
    playerId = tonumber(playerIdStr)
    playerJobName = Framework.getPlayerJobName(playerId)
    if playerJobName == oldJobName then
      TriggerClientEvent(Utils.eventsPrefix .. ":checkAllowedActions", playerId)
    end
  end

  local affectedRows = MySQL.Sync.execute([[
            UPDATE `jobs` 
            SET `label`=@newJobLabel,
            `name`=@newJobName,
            `options`=@optionsJson

            WHERE `name`=@oldJobName
        ]], {
    ["@newJobName"] = newJobName,
    ["@newJobLabel"] = newJobLabel,
    ["@optionsJson"] = optionsJson,
    ["@oldJobName"] = oldJobName
  })

  if 0 == affectedRows then
    return {
      isSuccessful = false,
      message = "Couldn't update the job (check server console)"
    }
  end

  local oldJobData = JobsCreator.Jobs[oldJobName]
  JobsCreator.Jobs[newJobName] = oldJobData
  JobsCreator.Jobs[newJobName].actions = newActions
  JobsCreator.Jobs[newJobName].name = newJobName
  JobsCreator.Jobs[newJobName].label = newJobLabel

  if oldJobName ~= newJobName then
    updateAllJobNameReferences(oldJobName, newJobName)
    JobsCreator.Jobs[oldJobName] = nil
  end

  JobsCreator.refreshFrameworkJobs()

  return {
    isSuccessful = true,
    message = "Successful"
  }
end

RegisterServerCallback(Utils.eventsPrefix .. ":updateJob", function(playerId, callback, oldJobName, newJobName, newJobLabel, newActions)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  result = JobsCreator.updateJob(oldJobName, newJobName, newJobLabel, newActions)
  callback(result)
end)

function removeJobFromPlayers(jobName)
  local framework

  framework = Framework.getFramework()
  if "ESX" == framework then
    MySQL.Async.execute("UPDATE users SET job=@unemployedJob, job_grade=@unemployedGrade WHERE job=@jobName", {
      ["@jobName"] = jobName,
      ["@unemployedJob"] = config.unemployedJob,
      ["@unemployedGrade"] = config.unemployedGrade
    })
  end
end

function deleteJob(jobName)
  local promise = promise.new()

  MySQL.Async.execute("DELETE FROM jobs WHERE name=@jobName", {
    ["@jobName"] = jobName
  }, function(affectedRows)
    if affectedRows > 0 then
      JobsCreator.Jobs[jobName] = nil
      removeJobFromPlayers(jobName)
      deleteGradesOfJob(jobName)
      deleteJobMarkers(jobName)
      JobsCreator.refreshFrameworkJobs()
      promise:resolve({
        isSuccessful = true,
        message = "Successful"
      })
    else
      promise:resolve({
        isSuccessful = false,
        message = "Couldn't delete this job"
      })
    end
  end)

  return Citizen.Await(promise)
end

RegisterServerCallback(Utils.eventsPrefix .. ":deleteJob", function(playerId, callback, jobName)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    result = deleteJob(jobName)
    callback(result)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getJobInfo", function(playerId, callback)
  local jobName, jobLabel

  jobName = Framework.getPlayerJobName(playerId)
  jobLabel = Framework.getJobLabel(jobName)

  callback(jobName, jobLabel)
end)

JobsCreator.createNewMarker = function(jobName, label, type, coords, minGrade)
  local strippedCoords, gradesType, insertId, markerEntry

  strippedCoords = stripCoords(coords)
  gradesType = "minimumGrade"

  insertId = MySQL.Sync.insert("INSERT INTO jobs_data(job_name, type, coords, min_grade, label, grades_type) VALUES (@jobName, @type, @coords, @minGrade, @label, \"minimumGrade\");", {
    ["@jobName"] = jobName,
    ["@type"] = type,
    ["@coords"] = json.encode(strippedCoords),
    ["@gradesType"] = gradesType,
    ["@minGrade"] = minGrade,
    ["@label"] = label
  })

  if not insertId or 0 == insertId then
    return {
      isSuccessful = false,
      message = "Couldn't create the marker (check server console)"
    }
  end

  if not markersByJob[jobName] then
    markersByJob[jobName] = {}
  end
  markersByJob[jobName][insertId] = true

  markerEntry = {
    id = insertId,
    jobName = jobName,
    label = label,
    type = type,
    coords = strippedCoords,
    gradesType = gradesType,
    minGrade = minGrade,
    data = {},
    color = {
      r = 255,
      g = 255,
      b = 0,
      alpha = 50
    },
    scale = {
      x = 1.5,
      y = 1.5,
      z = 0.5
    },
    blip = {},
    markerType = 1
  }
  JobsCreator.Markers[insertId] = markerEntry

  makeAllJobPlayersRefreshMarkers(jobName)

  return {
    isSuccessful = true,
    message = "Successful",
    markerId = insertId
  }
end

RegisterServerCallback(Utils.eventsPrefix .. ":createMarker", function(playerId, callback, jobName, label, type, coords, minGrade)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  result = JobsCreator.createNewMarker(jobName, label, type, coords, minGrade)
  callback(result)
end)

JobsCreator.getMarkersFromJobName = function(jobName)
  local markers, jobMarkers, markerId, markerData

  markers = {}
  jobMarkers = markersByJob[jobName]
  if jobMarkers then
    for markerId, _ in pairs(jobMarkers) do
      markerData = JobsCreator.Markers[markerId]
      markers[markerId] = markerData
    end
  end
  return markers
end

RegisterServerCallback(Utils.eventsPrefix .. ":getMarkersFromJobName", function(playerId, callback, jobName)
  local isAllowed, markers

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  while true do
    if hasFirstLoadFinished then
      break
    end
    Citizen.Wait(200)
  end

  markers = JobsCreator.getMarkersFromJobName(jobName)
  callback(markers)
end)

function getPublicMarkers()
  return JobsCreator.getMarkersFromJobName("public_marker")
end

function getAllMarkers()
  local promise = promise.new()

  MySQL.Async.fetchAll("SELECT * FROM jobs_data", {}, function(results)
    for _, markerData in pairs(results) do
      local markerId, jobName, markerEntry, coords, specificGrades, minGrade, blip, data, scale, color, ped, object

      markerId = markerData.id
      jobName = markerData.job_name

      markerEntry = {
        id = markerId,
        label = markerData.label,
        coords = json.decode(markerData.coords),
        gradesType = markerData.grades_type,
        specificGrades = json.decode(markerData.specific_grades),
        minGrade = markerData.min_grade or 0,
        blip = {
          spriteId = markerData.blip_id,
          color = markerData.blip_color,
          scale = markerData.blip_scale
        },
        type = markerData.type,
        jobName = jobName,
        data = json.decode(markerData.data),
        markerType = markerData.marker_type,
        scale = {
          x = markerData.marker_scale_x,
          y = markerData.marker_scale_y,
          z = markerData.marker_scale_z
        },
        color = {
          r = markerData.marker_color_red,
          g = markerData.marker_color_green,
          b = markerData.marker_color_blue,
          alpha = markerData.marker_color_alpha
        },
        ped = {
          model = markerData.ped,
          heading = markerData.ped_heading
        },
        object = {
          model = markerData.object,
          heading = markerData.object_heading,
          pitch = markerData.object_pitch,
          roll = markerData.object_roll,
          yaw = markerData.object_yaw
        }
      }

      JobsCreator.Markers[markerId] = markerEntry

      if not markersByJob[jobName] then
        markersByJob[jobName] = {}
      end
      markersByJob[jobName][markerId] = true
    end

    promise:resolve()
  end)

  return Citizen.Await(promise)
end

function getMarkersForJobAndGrade(jobName, grade)
  local markers, markerId, markerData, hasAccess, gradesType, specificGrades

  markers = {}
  for markerId, markerData in pairs(JobsCreator.Markers) do
    hasAccess = false
    gradesType = markerData.gradesType
    if "minimumGrade" == gradesType then
      if markerData.jobName == jobName then
        if grade >= markerData.minGrade then
          hasAccess = true
        end
      end
    elseif "specificGrades" == gradesType then
      if markerData.jobName == jobName then
        specificGrades = markerData.specificGrades
        if specificGrades then
          specificGrades = specificGrades[tostring(grade)]
        end
        if specificGrades then
          hasAccess = true
        end
      end
    else
      if "public_marker" == markerData.jobName then
        hasAccess = true
      end
    end

    if hasAccess then
      markers[markerId] = markerData
    end
  end
  return markers
end

function cacheMarkersForJobAndGrade(jobName, grade)
  if not markersByJobAndGrade[jobName] then
    markersByJobAndGrade[jobName] = {}
  end

  markersByJobAndGrade[jobName][grade] = getMarkersForJobAndGrade(jobName, grade)
end

JobsCreator.preloadMarkersForJobName = function(jobName)
  local jobRanks, rankGrade, rankData

  jobRanks = retrieveJobRanks(jobName)
  for rankGrade, rankData in pairs(jobRanks) do
    cacheMarkersForJobAndGrade(jobName, rankGrade)
  end
end

function getAllJobNames()
  local jobNames, jobName, jobData

  jobNames = {}
  for jobName, jobData in pairs(JobsCreator.Jobs) do
    table.insert(jobNames, jobName)
  end
  return jobNames
end

function preloadMarkersForAllJobs()
  local jobNames, jobName

  jobNames = getAllJobNames()
  for _, jobName in pairs(jobNames) do
    JobsCreator.preloadMarkersForJobName(jobName)
  end
end

function makeAllJobPlayersRefreshMarkers(jobName)
  local players, playerId, playerJobName

  if "public_marker" == jobName then
    preloadMarkersForAllJobs()
    TriggerClientEvent(Utils.eventsPrefix .. ":refreshMarkers", -1)
  else
    JobsCreator.preloadMarkersForJobName(jobName)
    players = GetPlayers()
    for _, playerIdStr in pairs(players) do
      playerId = tonumber(playerIdStr)
      playerJobName = Framework.getPlayerJobName(playerId)
      if jobName == playerJobName then
        TriggerClientEvent(Utils.eventsPrefix .. ":refreshMarkers", playerId)
      end
    end
  end

  TriggerEvent(Utils.eventsPrefix .. ":refreshMarkers")
end

function deleteMarker(markerId, callback)
  local markerData, jobName

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    jobName = markerData.jobName
  end

  if jobName then
    MySQL.Async.execute("DELETE FROM jobs_data WHERE id=@markerId", {
      ["@markerId"] = markerId
    }, function(affectedRows)
      if affectedRows > 0 then
        markersByJob[jobName][markerId] = nil
        JobsCreator.Markers[markerId] = nil
        makeAllJobPlayersRefreshMarkers(jobName)
        callback({
          isSuccessful = true,
          message = "Successful"
        })
      else
        callback({
          isSuccessful = false,
          message = "Couldn't delete the marker (check server console)"
        })
      end
    end)
  else
    callback({
      isSuccessful = false,
      message = "Couldn't delete the marker (no job name in marker id data)"
    })
  end
end

RegisterServerCallback(Utils.eventsPrefix .. ":deleteMarker", function(playerId, callback, markerId)
  local isAllowed

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    deleteMarker(markerId, callback)
  end
end)

JobsCreator.updateMarker = function(markerId, markerUpdateData)
  local strippedCoords, affectedRows, markerData, jobName, updatedMarker

  strippedCoords = stripCoords(markerUpdateData.coords)

  affectedRows = MySQL.Sync.execute([[
            UPDATE jobs_data SET 
            coords=@coords,

            grades_type=@gradesType,
            specific_grades=@specificGrades,
            min_grade=@minGrade,

            label=@label,

            blip_id=@blipSpriteId,
            blip_color=@blipColor,
            blip_scale=@blipScale,

            marker_type=@markerType,

            marker_scale_x=@scaleX,
            marker_scale_y=@scaleY,
            marker_scale_z=@scaleZ,

            marker_color_red=@red,
            marker_color_green=@green,
            marker_color_blue=@blue,

            marker_color_alpha=@alpha,

            ped=@ped,
            ped_heading=@ped_heading,

            object=@objectModel,
            object_heading=@objectHeading

            WHERE id=@markerId
        ]], {
    ["@markerId"] = markerId,
    ["@coords"] = json.encode(strippedCoords),
    ["@gradesType"] = markerUpdateData.gradesType,
    ["@specificGrades"] = markerUpdateData.specificGrades and json.encode(markerUpdateData.specificGrades) or nil,
    ["@minGrade"] = markerUpdateData.minGrade,
    ["@label"] = markerUpdateData.label,
    ["@blipSpriteId"] = markerUpdateData.blip.spriteId,
    ["@blipColor"] = markerUpdateData.blip.color,
    ["@blipScale"] = markerUpdateData.blip.scale,
    ["@markerType"] = markerUpdateData.markerType,
    ["@scaleX"] = markerUpdateData.scale.x,
    ["@scaleY"] = markerUpdateData.scale.y,
    ["@scaleZ"] = markerUpdateData.scale.z,
    ["@red"] = markerUpdateData.color.r,
    ["@green"] = markerUpdateData.color.g,
    ["@blue"] = markerUpdateData.color.b,
    ["@alpha"] = markerUpdateData.color.alpha,
    ["@ped"] = markerUpdateData.ped.model,
    ["@ped_heading"] = markerUpdateData.ped.heading,
    ["@objectModel"] = markerUpdateData.object.model,
    ["@objectHeading"] = markerUpdateData.object.heading
  })

  if 0 == affectedRows then
    return {
      isSuccessful = false,
      message = "Couldn't update the marker (check server console)"
    }
  end

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    markerData = markerData.data
  end

  jobName = JobsCreator.Markers[markerId]
  if jobName then
    jobName = jobName.jobName
  end

  updatedMarker = {
    id = markerId,
    label = markerUpdateData.label,
    coords = strippedCoords,
    gradesType = markerUpdateData.gradesType,
    specificGrades = markerUpdateData.specificGrades,
    minGrade = markerUpdateData.minGrade,
    blip = markerUpdateData.blip,
    color = markerUpdateData.color,
    scale = markerUpdateData.scale,
    markerType = markerUpdateData.markerType,
    ped = markerUpdateData.ped,
    object = markerUpdateData.object,
    data = markerData,
    type = JobsCreator.Markers[markerId].type,
    jobName = jobName
  }
  JobsCreator.Markers[markerId] = updatedMarker

  makeAllJobPlayersRefreshMarkers(jobName)

  return {
    isSuccessful = true,
    message = "Successful"
  }
end

RegisterServerCallback(Utils.eventsPrefix .. ":updateMarker", function(playerId, callback, markerId, markerUpdateData)
  local isAllowed, result

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  result = JobsCreator.updateMarker(markerId, markerUpdateData)
  callback(result)
end)

function updateMarkerData(markerId, data, callback)
  MySQL.Async.execute("UPDATE jobs_data SET data=@data WHERE id=@markerId", {
    ["@markerId"] = markerId,
    ["@data"] = json.encode(data)
  }, function(affectedRows)
    if affectedRows > 0 then
      JobsCreator.Markers[markerId].data = data
      makeAllJobPlayersRefreshMarkers(JobsCreator.Markers[markerId].jobName)
      callback({
        isSuccessful = true,
        message = "Successful"
      })
    else
      callback({
        isSuccessful = false,
        message = "Couldn't update marker data (check server console)"
      })
    end
  end)
end

updateMarkerData = updateMarkerData

RegisterServerCallback(Utils.eventsPrefix .. ":updateMarkerData", function(playerId, callback, markerId, data)
  local isAllowed

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    updateMarkerData(markerId, data, callback)
  end
end)

function deleteJobMarkers(jobName)
  MySQL.Async.execute("DELETE FROM jobs_data WHERE job_name=@jobName", {
    ["@jobName"] = jobName
  }, function(affectedRows)
    if affectedRows > 0 then
      for markerId, _ in pairs(markersByJob[jobName]) do
        JobsCreator.Markers[markerId] = nil
      end
      markersByJob[jobName] = {}
    end
  end)
end

RegisterServerCallback(Utils.eventsPrefix .. ":getMarkerLabel", function(playerId, callback, markerId)
  local markerLabel

  markerLabel = JobsCreator.Markers[markerId]
  if markerLabel then
    markerLabel = markerLabel.label
  end
  callback(markerLabel)
end)

function playAnimation(playerId, animations)
  local randomAnimation

  if animations then
    randomAnimation = animations[math.random(1, #animations)]
    if randomAnimation then
      TriggerClientEvent(Utils.eventsPrefix .. ":playAnimation", playerId, randomAnimation)
    end
  end
end

RegisterServerCallback(Utils.eventsPrefix .. ":getAllAccounts", function(playerId, callback)
  local isAllowed, accounts, accountName

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    accounts = {}
    for accountName, _ in pairs(Framework.getAllAccounts()) do
      accounts[accountName] = accountName
    end
    callback(accounts)
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getAllJobGrades", function(playerId, callback, jobName)
  local isAllowed

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    callback(false)
    return
  end

  MySQL.Async.fetchAll("SELECT * FROM job_grades WHERE job_name = @job_name", {
    ["@job_name"] = jobName
  }, function(grades)
    callback(grades)
  end)
end)

function getMarkers(playerId, callback)
  local cachedMarkers, jobName, grade

  while true do
    if Framework.isPlayerLoaded(playerId) then
      if hasFirstLoadFinished then
        break
      end
    end
    Citizen.Wait(1000)
  end

  jobName = Framework.getPlayerJobName(playerId)
  grade = Framework.getPlayerJobGrade(playerId)

  cachedMarkers = getCachedMarkersForJobAndGrade(jobName, grade)
  callback(cachedMarkers)
end

function getCachedMarkersForJobAndGrade(jobName, grade)
  local jobMarkers, gradeMarkers

  jobMarkers = markersByJobAndGrade[jobName]
  if jobMarkers then
    gradeMarkers = jobMarkers[grade]
    if not gradeMarkers then
      print("^1Can't find markers for grade " .. tostring(grade) .. " of job " .. jobName .. "^7")
    end
    if not gradeMarkers then
      gradeMarkers = {}
    end
    return gradeMarkers
  else
    print("^1Can't find markers for the job " .. jobName .. " and grade " .. tostring(grade) .. "^7")
  end

  return {}
end

RegisterServerCallback(Utils.eventsPrefix .. ":getMarkers", getMarkers)

RegisterNetEvent(Utils.eventsPrefix .. ":teleportToMarker", function(markerId)
  local playerId, isAllowed, markerData, coords, vecCoords, playerPed

  playerId = source
  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  markerData = JobsCreator.Markers[markerId]
  if markerData then
    coords = markerData.coords
    if coords then
      vecCoords = vecFromTable(markerData.coords)
      playerPed = GetPlayerPed(playerId)
      SetEntityCoords(playerPed, vecCoords.x, vecCoords.y, vecCoords.z + 0.5)
    end
  end
end)
