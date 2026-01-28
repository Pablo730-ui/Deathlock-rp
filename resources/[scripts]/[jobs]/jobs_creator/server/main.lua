local format = string.format
hasFirstLoadFinished = false
if not JobsCreator then
  JobsCreator = {}
end
JobsCreator.Jobs = {}
JobsCreator.Markers = {}

function ensureOffDutyRank(jobName, rankData)
  local offDutyJobName, offDutyRankName, offDutyJob, offDutyRank

  if JobsCreator.isOffDutyName(jobName) then
    return
  end

  offDutyJobName = JobsCreator.getOffDutyName(jobName)
  offDutyRankName = JobsCreator.getOffDutyName(rankData.name)
  offDutyJob = JobsCreator.Jobs[offDutyJobName]
  offDutyRank = offDutyJob.ranks[offDutyRankName]

  if offDutyRank then
    return
  end

  local created = JobsCreator.createRank(
    offDutyJobName,
    offDutyRankName,
    getLocalizedText("off_duty_rank_label", rankData.label),
    rankData.grade,
    0
  )
  return created.isSuccessful
end

function countOffDutyRanks(jobName)
  local jobData, offDutyJobName, offDutyJob, ranks, count, rankGrade, rankData

  jobData = JobsCreator.Jobs[jobName]
  offDutyJobName = JobsCreator.getOffDutyName(jobName)
  offDutyJob = JobsCreator.Jobs[offDutyJobName]
  if not offDutyJob then
    return 0
  end

  ranks = jobData.ranks
  if not ranks then
    return 0
  end

  count = 0
  for rankGrade, rankData in pairs(ranks) do
    if ensureOffDutyRank(jobName, rankData) then
      count = count + 1
    end
  end
  return count
end

function ensureOffDutyJob(jobName)
  local jobData, offDutyJobName, offDutyJob

  if JobsCreator.isOffDutyName(jobName) then
    return
  end

  jobData = JobsCreator.Jobs[jobName]
  offDutyJobName = JobsCreator.getOffDutyName(jobName)
  offDutyJob = JobsCreator.Jobs[offDutyJobName]
  if not offDutyJob then
    local created = JobsCreator.createJob(
      offDutyJobName,
      getLocalizedText("off_duty_job_label", jobData.label)
    )
    return created.isSuccessful
  end
  return false
end

JobsCreator.ensureOffDutyJob = function(jobName)
  local jobsCreated, ranksCreated

  if JobsCreator.isOffDutyName(jobName) then
    return
  end

  jobsCreated = 0
  ranksCreated = 0

  if ensureOffDutyJob(jobName) then
    jobsCreated = 1
  end
  ranksCreated = countOffDutyRanks(jobName)

  if jobsCreated > 0 then
    print(format("^2Created ^3%d^2 off-duty job^7 for '%s'", jobsCreated, jobName))
  end
  if ranksCreated > 0 then
    print(format("^2Created ^3%d^2 off-duty ranks^7 for '%s'", ranksCreated, jobName))
  end
end

function cleanupInvalidGrades()
  local existingJobs, jobName, gradeData, jobNameInGrades, gradeId, gradeName, gradeLabel

  existingJobs = MySQL.Sync.fetchAll("SELECT name FROM jobs", {})
  local jobsMap = {}
  for _, jobData in pairs(existingJobs) do
    jobsMap[jobData.name] = true
  end

  local errorMessage = "^1Job '^3%s^1' not found for grade ID %d (%s - %s). It will be deleted^7"
  gradeData = MySQL.Sync.fetchAll("SELECT id, job_name, grade, name, label FROM job_grades", {})

  for _, gradeInfo in pairs(gradeData) do
    jobNameInGrades = gradeInfo.job_name
    if not jobsMap[jobNameInGrades] then
      print(format(errorMessage, jobNameInGrades, gradeInfo.id, gradeInfo.name, gradeInfo.label))
      MySQL.Sync.execute("DELETE FROM job_grades WHERE id=@id", {
        ["@id"] = gradeInfo.id
      })
    end
  end
end

function checkIsBossGrade(jobName, grade)
  local gradeStr, framework, qbJobs, jobData, gradeInfo

  gradeStr = tostring(grade)
  framework = Framework.getFramework()
  if "QB-core" ~= framework then
    print("^1This function can be used only with QB-core framework^7")
    return
  end

  qbJobs = QBCore.Shared.Jobs
  if not qbJobs then
    return
  end

  jobData = qbJobs[jobName]
  if not jobData then
    return
  end

  gradeInfo = jobData.grades
  if not gradeInfo then
    return
  end

  gradeInfo = gradeInfo[gradeStr]
  if not gradeInfo then
    return
  end

  return gradeInfo.isboss
end

function convertQBCoreJob(jobName, jobData)
  local existingJob, convertedJob, hasBoss, maxGrade, gradeData, gradeLevel, gradeLabel, salary, isBoss

  existingJob = QBCore.Shared.Jobs[jobName]
  if not existingJob then
    existingJob = {}
  end

  convertedJob = Utils.deepCopy(existingJob)
  convertedJob.label = jobData.label

  if not convertedJob.grades then
    convertedJob.grades = {}
  end

  hasBoss = false
  maxGrade = nil

  for gradeLevel, gradeData in pairs(jobData.ranks) do
    isBoss = checkIsBossGrade(jobName, gradeLevel)
    if isBoss and not hasBoss then
      hasBoss = true
    end
    if nil == maxGrade or gradeLevel > maxGrade then
      maxGrade = gradeLevel
    end

    convertedJob.grades[gradeLevel] = {
      name = gradeData.label,
      payment = gradeData.salary,
      isboss = isBoss
    }
  end

  if maxGrade and not hasBoss then
    convertedJob.grades[maxGrade].isboss = true
  end

  return convertedJob
end

function convertQBCoreJobForQBX(jobName, jobData)
  local existingJob, convertedJob, hasBoss, maxGrade, gradeData, gradeLevel, gradeLabel, salary, isBoss, gradeStr

  existingJob = QBCore.Shared.Jobs[jobName]
  if not existingJob then
    existingJob = {}
  end

  convertedJob = Utils.deepCopy(existingJob)
  convertedJob.label = jobData.label
  convertedJob.grades = {}

  hasBoss = false
  maxGrade = nil

  for gradeLevel, gradeData in pairs(jobData.ranks) do
    isBoss = checkIsBossGrade(jobName, gradeLevel)
    if isBoss and not hasBoss then
      hasBoss = true
    end
    if nil == maxGrade or gradeLevel > maxGrade then
      maxGrade = gradeLevel
    end

    gradeStr = tostring(gradeLevel)
    convertedJob.grades[gradeStr] = {
      name = gradeData.label,
      payment = gradeData.salary,
      isboss = isBoss
    }
  end

  if maxGrade and not hasBoss then
    gradeStr = tostring(maxGrade)
    convertedJob.grades[gradeStr].isboss = true
  end

  return convertedJob
end

JobsCreator.injectJobsInQBCoreTable = function()
  if SUBFRAMEWORK == nil then
    JobsCreator.QBJobsTable = {}
    for jobName, jobData in pairs(JobsCreator.Jobs) do
      JobsCreator.QBJobsTable[jobName] = convertQBCoreJobForQBX(jobName, jobData)
    end
    TriggerEvent("jobs_creator:injectJobs", JobsCreator.QBJobsTable)
    TriggerClientEvent("jobs_creator:injectJobs", -1, JobsCreator.QBJobsTable)
  else
    if "QBX" == SUBFRAMEWORK then
      for jobName, jobData in pairs(JobsCreator.Jobs) do
        local converted = convertQBCoreJob(jobName, jobData)
        local finalname = jobName:lower()
        print('^5[DEBUG] converted: ' .. json.encode(converted, {indent = true}))
        print('^5[DEBUG] finalname: ' .. json.encode(finalname, {indent = true}))
        
        exports['qb-core']:AddJobs({[finalname] = converted})
        
        -- exports.qbx_core.CreateJobs(finalname, converted, false)
      end
    end
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":askQBCoreJobs", function()
  local playerId = source
  TriggerClientEvent("jobs_creator:injectJobs", playerId, JobsCreator.QBJobsTable)
end)

function getJobRanks(jobName)
  local ranks, rankData, rankGrade

  ranks = {}
  rankData = MySQL.Sync.fetchAll("SELECT id, grade, name, label, salary FROM `job_grades` WHERE job_name=@jobName ORDER BY grade ASC", {
    ["@jobName"] = jobName
  })
  for _, rankInfo in pairs(rankData) do
    rankGrade = rankInfo.grade
    ranks[rankGrade] = rankInfo
  end
  return ranks
end

function convertQBCoreJobs()
  local framework, qbJobs, jobName, jobData

  framework = Framework.getFramework()
  if "QB-core" ~= framework then
    print("^1This function can be used only with QB-core framework^7")
    return
  end

  qbJobs = QBCore.Shared.Jobs
  if not qbJobs then
    return
  end

  for jobName, jobData in pairs(qbJobs) do
    convertQBCoreJobFromQB(jobName, jobData)
  end
end

function convertQBCoreJobFromQB(jobName, jobData)
  local jobExists
  print(json.encode(jobData, {indent = true}))
  if not jobData.label then
    print("^1There is an issue in ^3QBCore jobs.lua file^1, found a malformed job without the ^3label^7")
    return
  end

  jobExists = JobsCreator.Jobs[jobName]
  if not jobExists then
    JobsCreator.createJob(jobName, jobData.label)
    print("^2Converted job ^3" .. jobData.label .. "^2 from QBCore jobs.lua file")
  end

  if jobData.grades then
    if "table" == type(jobData.grades) then
      for gradeLevel, gradeInfo in pairs(jobData.grades) do
        if "table" == type(gradeInfo) then
          local gradeNum = tonumber(gradeLevel)
          local gradeName = gradeInfo.name
          if not gradeName then
            gradeName = gradeInfo.label
            gradeInfo.name = gradeName
          end

          jobExists = JobsCreator.Jobs[jobName]
          if jobExists then
            jobExists = jobExists.ranks
            if jobExists then
              jobExists = jobExists[gradeNum]
            end
          end

          if not jobExists and jobName and gradeNum then
            if gradeInfo.name and gradeInfo.payment then
              JobsCreator.createRank(
                jobName,
                gradeInfo.name,
                gradeInfo.name,
                gradeNum,
                gradeInfo.payment
              )
            end
          end
        end
      end
    end
  end
end

function waitForTranslation(translationKey)
  local translation

  translation = translation
  if translation then
    translation = translation[translationKey]
  end
  if translation then
    translation = translation[translationKey]
    return translation
  end

  while true do
    translation = translation
    if translation then
      translation = translation[translationKey]
    end
    if nil ~= translation then
      break
    end
    waitForTranslation(translationKey)
  end

  print("Error in translations files!")
  return "Missing Translation"
end

Citizen.CreateThread(function()
  Citizen.Wait(math.floor(1955460.0000000002))
  if not _G.getLocalizedText then
    waitForTranslation("English text to turn into German")
    return
  end
  print("Translations loaded successfully!")
end)

function loadJobs()
  local jobs, jobName, actions, jobEntry, ranks

  JobsCreator.Jobs = {}
  jobs = MySQL.Sync.fetchAll("SELECT * FROM jobs", {})
  local jobsCount = 0

  for _, jobInfo in pairs(jobs) do
    jobName = jobInfo.name
    actions = jobInfo.options
    if actions then
      actions = json.decode(actions)
      if not actions then
        actions = {}
      end
    else
      actions = {}
    end
    ranks = getJobRanks(jobName)
    if not ranks then
      ranks = {}
    end

    jobEntry = {
      name = jobName,
      label = jobInfo.label,
      actions = actions,
      ranks = ranks
    }
    JobsCreator.Jobs[jobName] = jobEntry
    jobsCount = jobsCount + 1
  end

  print("^2Loaded ^3" .. jobsCount .. "^2 jobs^7")
end

function ensureUnemployedJobExists()
  local unemployedJob, lowestGrade

  unemployedJob = JobsCreator.Jobs.unemployed
  if not unemployedJob then
    JobsCreator.createJob("unemployed", "Unemployed")
    print([[
^2Created base job ^3unemployed^2 (it must exist)^7]])
  end

  lowestGrade = JobsCreator.findLowestGrade("unemployed")
  if 0 ~= lowestGrade then
    JobsCreator.createRank("unemployed", "unemployed", "Unemployed", 0, 0)
    print([[
^2Created base rank ^3Unemployed^2 (it must exist)^7]])
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":framework:ready", function()
  loadJobs()
  local framework = Framework.getFramework()
  if "ESX" == framework then
    cleanupInvalidGrades()
  else
    framework = Framework.getFramework()
    if "QB-core" == framework then
      local success, error = pcall(convertQBCoreJobs)
      if not success then
        print("^1Error while converting QBCore jobs into database (probably something wrong in one or more jobs in the jobs.lua file)" .. error .. "^7")
      end
    end
  end

  ensureUnemployedJobExists()

  framework = Framework.getFramework()
  if "QB-core" == framework then
    JobsCreator.refreshFrameworkJobs()
  end

  getAllMarkers()
  registerSocieties()
  getAllArmoryData()
  getAllGaragesData()
  getAllShopsData()
  getAllWardrobesData()
  preloadMarkersForAllJobs()
  TriggerClientEvent(Utils.eventsPrefix .. ":framework:ready", -1)
  hasFirstLoadFinished = true
end)

function openGUI(playerId)
  local isAllowed

  isAllowed = Utils.isAllowed(playerId)
  if isAllowed then
    TriggerClientEvent(
      Utils.eventsPrefix .. ":openGUI",
      playerId,
      Utils.getScriptVersion(),
      Settings.getFullConfig()
    )
  else
    Dialogs.showNotAllowedMenu(playerId, config.acePermission)
  end
end

RegisterCommand("jobcreator", openGUI)
RegisterCommand("jobscreator", openGUI)

function cleanUpObjectsOnStop(callback)
  callback()
end

RegisterNetEvent("onResourceStop", function(resourceName)
  local currentResource

  currentResource = GetCurrentResourceName()
  if resourceName ~= currentResource then
    return
  end

  local promise = promise.new()
  cleanUpObjectsOnStop(function()
    promise:resolve()
  end)
  Citizen.Await(promise)
end)

local nexusJobs = {}

function getNexusJobs()
  local fileContent, decodedData
  
  fileContent = LoadResourceFile(GetCurrentResourceName(), "nexus_jobs.json")
  if not fileContent then
    return false
  end
  
  decodedData = json.decode(fileContent)
  if not decodedData then
    return false
  end
  
  nexusJobs = decodedData
  return nexusJobs
end

RegisterServerCallback(Utils.eventsPrefix .. ":nexus:getJobs", function(playerId, callback)
  local isAllowed, jobs

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  jobs = getNexusJobs()
  callback(jobs)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":nexus:importJob", function(playerId, callback, jobId)
  local isAllowed, jobData, jobConfiguration, jobName, jobExists, created, updated, rankLevel, rankData, markerId, markerData

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  jobData = nexusJobs[jobId]
  if not jobData then
    jobData = nexusJobs[tostring(jobId)]
  end

  if not jobData then
    callback(false)
    return
  end

  jobConfiguration = jobData.jobConfiguration
  if not jobConfiguration then
    callback(false)
    return
  end

  jobName = jobConfiguration.name
  jobExists = JobsCreator.Jobs[jobName]
  if jobExists then
    jobName = JobsCreator.fixJobNameWhenNeeded(jobName)
  end

  jobExists = JobsCreator.Jobs[jobName]
  if not jobExists then
    created = JobsCreator.createJob(jobName, jobConfiguration.label)
    if not created.isSuccessful then
      callback(false)
      return
    end

    updated = JobsCreator.updateJob(jobName, jobName, jobConfiguration.label, jobConfiguration.actions)
    if not updated.isSuccessful then
      callback(false)
      return
    end

    for rankLevel, rankData in pairs(jobConfiguration.ranks) do
      JobsCreator.createRank(
        jobName,
        rankData.name,
        rankData.label,
        rankData.grade,
        rankData.salary
      )
    end
  else
    print("^1Job ^3" .. jobName .. "^1 already exists, skipping^7")
  end

  if jobData.jobMarkers then
    for _, markerData in pairs(jobData.jobMarkers) do
      local created = JobsCreator.createNewMarker(
        jobName,
        markerData.label,
        markerData.type,
        markerData.coords,
        0
      )
      if created.isSuccessful then
        markerId = created.markerId
        JobsCreator.updateMarker(markerId, markerData)
      end
    end
  end

  callback(true)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":nexus:uploadJob", function(playerId, callback, uploadData)
  local isAllowed, markers, jobData, uploadPayload, jobName

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  markers = {}
  if uploadData.includeJobMarkers then
    markers = JobsCreator.getMarkersFromJobName(uploadData.jobName)
    markers = Utils.deepCopy(markers)
    for _, markerData in pairs(markers) do
      markerData.data = {}
      markerData.id = nil
    end
  end

  uploadPayload = {}
  uploadPayload.author = GetPlayerName(playerId)
  uploadPayload.identifier = Framework.getIdentifier(playerId)
  jobName = JobsCreator.Jobs[uploadData.jobName]
  uploadPayload.jobConfiguration = jobName
  uploadPayload.jobMarkers = markers
  uploadPayload.label = uploadData.label
  uploadPayload.description = uploadData.description
  uploadPayload.scriptVersion = Utils.getScriptVersion()

  -- PerformHttpRequest(
  --   "https://nexus.jaksam-scripts.com/jobs-creator/upload-job",
  --   function(statusCode, body, headers, error)
  --     if 200 == statusCode then
  --       callback(true)
  --     else
  --       callback(error)
  --       print("^1Error while uploading a job with Nexus")
  --     end
  --   end,
  --   "POST",
  --   json.encode(uploadPayload),
  --   {
  --     ["Content-Type"] = "application/json"
  --   }
  -- )
  callback(true)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":nexus:rateJob", function(playerId, callback, jobId, rating)
  local isAllowed, ratingData

  isAllowed = Utils.isAllowed(playerId)
  if not isAllowed then
    return
  end

  if not jobId or not rating then
    callback(false)
    return
  end

  ratingData = {}
  ratingData.jobId = jobId
  ratingData.rate = rating

  -- PerformHttpRequest(
  --   "https://nexus.jaksam-scripts.com/jobs-creator/rate-job",
  --   function(statusCode, body, headers, error)
  --     if 200 == statusCode then
  --       callback(true)
  --     else
  --       callback(false)
  --       print(statusCode)
  --       print(body)
  --       print(headers)
  --       print(error)
  --     end
  --   end,
  --   "POST",
  --   json.encode(ratingData),
  --   {
  --     ["Content-Type"] = "application/json"
  --   }
  -- )
  callback(true)
end)
