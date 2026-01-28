local activeDutySessions = {}

function saveDutySession(playerId)
  local session, currentTime, elapsedMinutes, date

  session = activeDutySessions[playerId]
  if not session then
    return
  end

  currentTime = getCurrentUnixTime()
  elapsedMinutes = currentTime - session.startTime
  elapsedMinutes = math.floor(elapsedMinutes / 60)

  date = os.date("%Y-%m-%d")

  MySQL.Async.execute(
    [[
            INSERT INTO jobs_employee_hours (job_name, char_identifier, total_minutes, date) VALUES (@job, @id, @min, @date)
            ON DUPLICATE KEY UPDATE total_minutes = total_minutes + @min
        ]],
    {
      ["@job"] = session.job,
      ["@id"] = session.charIdentifier,
      ["@min"] = elapsedMinutes,
      ["@date"] = date
    }
  )

  activeDutySessions[playerId] = nil
end

RegisterNetEvent(Utils.eventsPrefix .. ":framework:ready", function()
  local players, playerId, jobName, isOnDuty, identifier

  players = GetPlayers()

  MySQL.Sync.execute("DELETE FROM jobs_employee_hours WHERE date < DATE_SUB(CURDATE(), INTERVAL 14 DAY)")

  for i = 1, #players, 1 do
    playerId = tonumber(players[i])
    jobName = Framework.getPlayerJobName(playerId)
    isOnDuty = not JobsCreator.isOffDutyName(jobName)

    if isOnDuty then
      identifier = Framework.getPlayerCharIdentifier(playerId)

      activeDutySessions[playerId] = {
        job = jobName,
        startTime = getCurrentUnixTime(),
        charIdentifier = identifier
      }
    end
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":switchJobDuty", function(playerId, callback, markerId, shouldBeOnDuty)
  local framework, jobName, jobGrade, offDutyJob, isOffDuty, targetJobName, timeoutTime, identifier, session

  framework = Framework.getFramework()
  if framework ~= "ESX" then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  jobGrade = Framework.getPlayerJobGrade(playerId)

  offDutyJob = JobsCreator.Jobs[JobsCreator.getOffDutyName(jobName)]
  if not offDutyJob then
    JobsCreator.ensureOffDutyJob(jobName)
    Citizen.Wait(1000)
  end

  if shouldBeOnDuty == nil then
    isOffDuty = JobsCreator.isOffDutyName(jobName)
    shouldBeOnDuty = isOffDuty
  else
    if shouldBeOnDuty then
      isOffDuty = JobsCreator.isOffDutyName(jobName)
      if not isOffDuty then
        return callback(isOffDuty)
      end
    end
    if not shouldBeOnDuty then
      isOffDuty = JobsCreator.isOffDutyName(jobName)
      if isOffDuty then
        return callback(isOffDuty)
      end
    end
  end

  targetJobName = nil
  if shouldBeOnDuty then
    targetJobName = JobsCreator.getOnDutyName(jobName)
  else
    targetJobName = JobsCreator.getOffDutyName(jobName)
  end

  timeoutTime = GetGameTimer() + 3000
  while true do
    if JobsCreator.Jobs[targetJobName] then
      break
    end
    if not (timeoutTime > GetGameTimer()) then
      break
    end
    Citizen.Wait(1000)
  end

  Framework.setJobToPlayer(playerId, targetJobName, jobGrade)

  if shouldBeOnDuty then
    identifier = Framework.getPlayerCharIdentifier(playerId)

    activeDutySessions[playerId] = {
      job = targetJobName,
      startTime = getCurrentUnixTime(),
      charIdentifier = identifier
    }
  else
    session = activeDutySessions[playerId]
    if session then
      saveDutySession(playerId)
    end
  end

  callback(shouldBeOnDuty)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":isSelfOnDuty", function(playerId, callback)
  local framework, jobName, isOnDuty

  framework = Framework.getFramework()
  if framework ~= "ESX" then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  isOnDuty = not JobsCreator.isOffDutyName(jobName)
  callback(isOnDuty)
end)

function isPlayerOnDuty(playerId)
  local framework, jobName, isOnDuty, player, isDuty

  framework = Framework.getFramework()
  if framework == "ESX" then
    jobName = Framework.getPlayerJobName(playerId)
    isOnDuty = not JobsCreator.isOffDutyName(jobName)
    return isOnDuty
  else
    framework = Framework.getFramework()
    if framework == "QB-core" then
      player = QBCore.Functions.GetPlayer(playerId)
      while not player do
        player = QBCore.Functions.GetPlayer(playerId)
        Citizen.Wait(1000)
      end
      isDuty = player.PlayerData.job.onduty
      return isDuty
    end
  end
end
exports("isPlayerOnDuty", isPlayerOnDuty)

RegisterServerCallback(Utils.eventsPrefix .. ":isPlayerOnDuty", function(playerId, callback)
  callback(isPlayerOnDuty(playerId))
end)

RegisterNetEvent(Utils.eventsPrefix .. ":changeDutyStatus", function(markerId)
  local playerId, jobName

  playerId = source
  jobName = Framework.getPlayerJobName(playerId)

  TriggerEvent(Utils.eventsPrefix .. ":toggleDuty", playerId, jobName, markerId)
end)

RegisterNetEvent("QBCore:Server:PlayerLoaded", function(playerData)
  local defaultDutyStatus

  defaultDutyStatus = DEFAULT_DUTY_STATUS
  if defaultDutyStatus == nil then
    return
  end

  Citizen.Wait(1000)

  TriggerClientEvent(
    Utils.eventsPrefix .. ":toggleCurrentDutyStatus",
    playerData.PlayerData.source,
    DEFAULT_DUTY_STATUS
  )
end)

RegisterNetEvent("playerDropped", function()
  local playerId

  playerId = source
  saveDutySession(playerId)
end)

RegisterNetEvent("onResourceStop", function(resourceName)
  local currentResourceName, savedCount, playerId, session

  currentResourceName = GetCurrentResourceName()
  if resourceName ~= currentResourceName then
    return
  end

  savedCount = 0
  for playerId, session in pairs(activeDutySessions) do
    saveDutySession(playerId)
    savedCount = savedCount + 1
  end

  print("^2Saved " .. savedCount .. " active duty sessions^7")
end)

RegisterNetEvent("esx:playerLoaded", function(playerId, xPlayer)
  local jobName, isOffDuty, identifier

  jobName = xPlayer.job.name
  isOffDuty = JobsCreator.isOffDutyName(jobName)
  if isOffDuty then
    return
  end

  identifier = Framework.getPlayerCharIdentifier(playerId)

  activeDutySessions[playerId] = {
    job = jobName,
    startTime = getCurrentUnixTime(),
    charIdentifier = identifier
  }
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
  local playerId, isOnDuty, jobName, identifier

  playerId = source

  Citizen.Wait(1000)

  isOnDuty = exports[GetCurrentResourceName()]:isPlayerOnDuty(playerId)
  if not isOnDuty then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  identifier = Framework.getPlayerCharIdentifier(playerId)

  activeDutySessions[playerId] = {
    job = jobName,
    startTime = getCurrentUnixTime(),
    charIdentifier = identifier
  }
end)

RegisterNetEvent("esx:setJob", function(playerId, job, grade)
  local isOffDuty, identifier

  saveDutySession(playerId)

  isOffDuty = JobsCreator.isOffDutyName(job.name)
  if not isOffDuty then
    identifier = Framework.getPlayerCharIdentifier(playerId)

    activeDutySessions[playerId] = {
      job = job.name,
      startTime = getCurrentUnixTime(),
      charIdentifier = identifier
    }
  end
end)

RegisterNetEvent("QBCore:Server:OnJobUpdate", function(playerId, job)
  local isDuty, identifier

  saveDutySession(playerId)

  isDuty = job or false
  if job then
    isDuty = job.onduty
  end

  if isDuty then
    identifier = Framework.getPlayerCharIdentifier(playerId)

    activeDutySessions[playerId] = {
      job = job.name,
      startTime = getCurrentUnixTime(),
      charIdentifier = identifier
    }
  end
end)

RegisterNetEvent("esx:playerLogout", function(playerId)
  saveDutySession(playerId)
end)

RegisterNetEvent("QBCore:Server:OnPlayerUnload", function(playerId)
  saveDutySession(playerId)
end)
