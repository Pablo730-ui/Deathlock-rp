exports("getJobAccountMoney", Framework.getSocietyAccountMoney)
exports("removeSocietyMoney", Framework.removeMoneyFromSocietyAccount)
exports("addSocietyMoney", Framework.giveMoneyToSocietyAccount)

RegisterNetEvent(Utils.eventsPrefix .. ":withdrawSocietyMoney", function(markerId, amount)
  local playerId, canAccess, jobName, societyMoney, resourceName, removeResult

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  societyMoney = Framework.getSocietyAccountMoney(jobName)

  if societyMoney then
    if amount > 0 and amount <= societyMoney then
      resourceName = GetCurrentResourceName()
      removeResult = exports[resourceName].removeSocietyMoney(jobName, amount)
      if removeResult then
        Framework.giveCashToPlayer(playerId, amount)
        notify(playerId, getLocalizedText("boss:withdrew_money", Framework.groupDigits(amount)))
        Utils.log(
          playerId,
          getLocalizedText("log_withdrew_money"),
          getLocalizedText("log_withdrew_money_description", amount, jobName),
          "success",
          "boss"
        )
      else
        print("Couldn't remove money from job name: " .. jobName)
      end
    else
      notify(playerId, getLocalizedText("boss:invalid_amount"))
    end
  else
    print("Couldn't find esx_addonaccount for job: " .. jobName)
  end
end)

RegisterNetEvent(Utils.eventsPrefix .. ":depositSocietyMoney", function(markerId, amount)
  local playerId, canAccess, jobName, accountName, identifier, accountMoney, resourceName, addResult

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  accountName = "money"
  if Framework.getFramework() == "QB-core" then
    accountName = "cash"
  end

  identifier = Framework.getPlayerCharIdentifier(playerId)
  accountMoney = Framework.getAccountMoneyFromIdentifier(identifier, accountName)

  if amount > 0 and amount <= accountMoney then
    resourceName = GetCurrentResourceName()
    addResult = exports[resourceName].addSocietyMoney(jobName, amount)
    if not addResult then
      print("Couldn't add money to job name: " .. jobName)
      return
    end

    Framework.removeAccountMoneyFromIdentifier(identifier, accountName, amount)
    notify(playerId, getLocalizedText("boss:deposited_money", Framework.groupDigits(amount)))
    Utils.log(
      playerId,
      getLocalizedText("log_deposited_money"),
      getLocalizedText("log_deposited_money_description", amount, jobName),
      "success",
      "boss"
    )
  else
    notify(playerId, getLocalizedText("boss:invalid_amount"))
  end
end)

RegisterServerCallback(Utils.eventsPrefix .. ":getBossData", function(playerId, callback, markerId)
  local canAccess, jobName, markerData, permissions, societyMoney

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  markerData = JobsCreator.Markers[markerId].data
  if not markerData then
    markerData = {}
  end

  permissions = {}
  permissions.withdraw = markerData.canWithdraw
  permissions.deposit = markerData.canDeposit
  permissions.wash = markerData.canWashMoney
  permissions.employees = markerData.canEmployees
  permissions.grades = markerData.canGrades

  societyMoney = Framework.getSocietyAccountMoney(jobName)
  callback(permissions, societyMoney)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":boss:getJobGrades", function(playerId, callback, markerId)
  local canAccess, jobName, markerData, maxSalary

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  markerData = JobsCreator.Markers[markerId].data
  maxSalary = markerData.maxSalary

  MySQL.Async.fetchAll("SELECT id, grade, label, salary FROM job_grades WHERE job_name=@jobName", {
    ["@jobName"] = jobName
  }, function(results)
    callback(results, maxSalary)
  end)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":updateGradeSalary", function(markerId, gradeId, grade, salary)
  local playerId, canAccess, jobName, markerData, maxSalary, affectedRows, playerServerId, playerJobName, playerJobGrade

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  markerData = JobsCreator.Markers[markerId].data
  maxSalary = markerData.maxSalary

  if maxSalary and salary > maxSalary then
    salary = maxSalary
  end

  affectedRows = MySQL.Sync.execute(
    "UPDATE job_grades SET salary=@quantity WHERE id=@gradeId AND job_name=@jobName AND grade=@grade",
    {
      ["@gradeId"] = gradeId,
      ["@quantity"] = salary,
      ["@jobName"] = jobName,
      ["@grade"] = grade
    }
  )

  if affectedRows == 0 then
    notify(playerId, getLocalizedText("boss:grade_salary_not_updated"))
    return
  end

  notify(playerId, getLocalizedText("boss:grade_salary_updated"))
  Utils.log(
    playerId,
    getLocalizedText("log_updated_salary"),
    getLocalizedText("log_updated_salary_description", grade, salary),
    "success",
    "boss"
  )

  for _, playerServerId in pairs(GetPlayers()) do
    playerServerId = tonumber(playerServerId)
    playerJobName = Framework.getPlayerJobName(playerServerId)
    playerJobGrade = Framework.getPlayerJobGrade(playerServerId)

    if jobName == playerJobName and playerJobGrade == grade then
      Framework.setJobToPlayer(playerServerId, jobName, grade)
    end
  end
end)

function getJobGrades(jobName)
  local results, grades, grade, label

  results = MySQL.Sync.fetchAll("SELECT grade, label FROM job_grades WHERE job_name=@jobName", {
    ["@jobName"] = jobName
  })
  grades = {}

  for _, result in pairs(results) do
    grade = result.grade
    label = result.label
    grades[grade] = label
  end

  return grades
end

function getAllEmployeesWorkTime(employees, jobName)
  local workTimes, resetDays, params, paramNames, i, employee, paramName, query, results, identifier, totalMinutes

  workTimes = {}
  if not employees or #employees == 0 then
    return workTimes
  end

  resetDays = config.resetEmployeeWorkTimeEveryNDays
  params = {}
  paramNames = {}

  for i = 1, #employees, 1 do
    employee = employees[i]
    paramName = "@id" .. i
    table.insert(paramNames, paramName)
    params[paramName] = employee.identifier
  end

  if #paramNames == 0 then
    return workTimes
  end

  params["@jobName"] = jobName
  query = ""
  if resetDays ~= 0 then
    query = " AND date >= (CURDATE() - INTERVAL @days DAY) "
    params["@days"] = resetDays
  end

  query = string.format(
    [[
        SELECT char_identifier, COALESCE(SUM(total_minutes), 0) as totalMinutes
        FROM jobs_employee_hours
        WHERE job_name = @jobName
          AND char_identifier IN (%s)
          %s
        GROUP BY char_identifier
    ]],
    table.concat(paramNames, ","),
    query
  )

  results = MySQL.Sync.fetchAll(query, params)

  for _, result in ipairs(results) do
    identifier = result.char_identifier
    totalMinutes = result.totalMinutes
    if not totalMinutes then
      totalMinutes = 0
    end
    workTimes[identifier] = totalMinutes
  end

  for _, employee in ipairs(employees) do
    identifier = employee.identifier
    if workTimes[identifier] == nil then
      workTimes[identifier] = 0
    end
  end

  return workTimes
end

RegisterServerCallback(Utils.eventsPrefix .. ":boss:getAllEmployeesWorkTime", function(playerId, callback, markerId)
  local canAccess, jobName, grades, employees, framework, query, params, onJobName, offJobName, results, result, job, charinfo, identifier, firstname, lastname, jobGrade, workTimes

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = JobsCreator.Markers[markerId].jobName
  grades = getJobGrades(jobName)
  employees = {}
  framework = Framework.getFramework()

  if framework == "ESX" then
    onJobName = JobsCreator.getOnDutyName(jobName)
    offJobName = JobsCreator.getOffDutyName(jobName)

    results = MySQL.Sync.fetchAll(
      "SELECT identifier, firstname, lastname, job_grade FROM users WHERE (job=@jobName OR job=@offJobName)",
      {
        ["@jobName"] = onJobName,
        ["@offJobName"] = offJobName
      }
    )
    employees = results
  else
    if framework == "QB-core" then
      results = MySQL.Sync.fetchAll("SELECT license, charinfo, job FROM players")
      for _, result in pairs(results) do
        job = json.decode(result.job)
        result.job = job
        if result.job.name == jobName then
          charinfo = json.decode(result.charinfo)
          result.charinfo = charinfo

          identifier = result.license
          firstname = result.charinfo.firstname
          lastname = result.charinfo.lastname
          jobGrade = result.job.grade.level

          table.insert(employees, {
            identifier = identifier,
            firstname = firstname,
            lastname = lastname,
            job_grade = jobGrade
          })
        end
      end
    end
  end

  workTimes = getAllEmployeesWorkTime(employees, jobName)
  callback(employees, grades, workTimes)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":boss:getEmployees", function(playerId, callback, markerId)
  local canAccess, jobName, grades, employees, framework, query, params, onJobName, offJobName, results, result, job, charinfo, identifier, firstname, lastname, jobGrade, onlinePlayerId, resourceName, isOnDuty, workTimes

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = JobsCreator.Markers[markerId].jobName
  grades = getJobGrades(jobName)
  employees = {}
  framework = Framework.getFramework()

  if framework == "ESX" then
    onJobName = JobsCreator.getOnDutyName(jobName)
    offJobName = JobsCreator.getOffDutyName(jobName)

    results = MySQL.Sync.fetchAll(
      "SELECT identifier, firstname, lastname, job_grade FROM users WHERE (job=@jobName OR job=@offJobName)",
      {
        ["@jobName"] = onJobName,
        ["@offJobName"] = offJobName
      }
    )
    employees = results
  else
    if framework == "QB-core" then
      results = MySQL.Sync.fetchAll("SELECT license, charinfo, job FROM players")
      for _, result in pairs(results) do
        job = json.decode(result.job)
        result.job = job
        if result.job.name == jobName then
          charinfo = json.decode(result.charinfo)
          result.charinfo = charinfo

          identifier = result.license
          firstname = result.charinfo.firstname
          lastname = result.charinfo.lastname
          jobGrade = result.job.grade.level

          table.insert(employees, {
            identifier = identifier,
            firstname = firstname,
            lastname = lastname,
            job_grade = jobGrade
          })
        end
      end
    end
  end

  for _, employee in pairs(employees) do
    onlinePlayerId = Framework.getIdentifierPlayerId(employee.identifier)
    if onlinePlayerId then
      resourceName = GetCurrentResourceName()
      isOnDuty = exports[resourceName].isPlayerOnDuty(onlinePlayerId)
      employee.isOnDuty = isOnDuty
      employee.isOnline = true
    else
      employee.isOnDuty = false
      employee.isOnline = false
    end
  end

  if config.modules.boss ~= "default" then
    modifiedEmployees = Utils.callModuleFunc("boss", "modifyEmployeesList", employees, jobName)
    if modifiedEmployees then
      employees = modifiedEmployees
    end
  end

  callback(employees, grades)
end)

RegisterServerCallback(Utils.eventsPrefix .. ":boss:getEmployeeWorkTime", function(playerId, callback, markerId, identifier, days)
  local canAccess, jobName, markerData, maxDays, query, params, totalMinutes

  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = JobsCreator.Markers[markerId].jobName
  maxDays = days or 7
  if not days then
    maxDays = 7
  end

  query = ""
  params = {}
  params["@jobName"] = jobName
  params["@identifier"] = identifier
  if maxDays ~= 0 then
    query = " AND date >= (CURDATE() - INTERVAL @days DAY) "
    params["@days"] = maxDays
  end

  query = "SELECT COALESCE(SUM(total_minutes), 0) FROM jobs_employee_hours WHERE job_name=@jobName AND char_identifier=@identifier" .. query
  totalMinutes = MySQL.Sync.fetchScalar(query, params)
  callback(totalMinutes or 0)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":boss:fireEmployee", function(markerId, identifier)
  local playerId, canAccess, jobName, moduleResult, onlinePlayerId, framework, unemployedJob, unemployedGrade, offJobName, jobData, job, grade, label, payment

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  if config.modules.boss ~= "default" then
    moduleResult = Utils.callModuleFunc("boss", "fireEmployee", playerId, identifier, jobName)
    if moduleResult ~= nil then
      return
    end
  end

  onlinePlayerId = Framework.getIdentifierPlayerId(identifier)
  if onlinePlayerId then
    Framework.setJobToPlayer(onlinePlayerId, config.unemployedJob, config.unemployedGrade)
  else
    framework = Framework.getFramework()
    if framework == "ESX" then
      unemployedJob = config.unemployedJob
      unemployedGrade = config.unemployedGrade
      offJobName = JobsCreator.getOffDutyName(jobName)

      MySQL.Async.execute(
        "UPDATE users SET job=@unemployedJob, job_grade=@unemployedGrade WHERE identifier=@identifier AND (job=@currentJobName OR job=@offJobName)",
        {
          ["@unemployedJob"] = unemployedJob,
          ["@unemployedGrade"] = unemployedGrade,
          ["@identifier"] = identifier,
          ["@currentJobName"] = jobName,
          ["@offJobName"] = offJobName
        }
      )
    else
      if framework == "QB-core" then
        jobData = {}
        jobData.name = config.unemployedJob
        grade = {}
        grade.name = JobsCreator.Jobs[config.unemployedJob].ranks[config.unemployedGrade].label
        grade.level = config.unemployedGrade
        jobData.grade = grade
        jobData.payment = JobsCreator.Jobs[config.unemployedJob].ranks[config.unemployedGrade].salary
        jobData.label = JobsCreator.Jobs[config.unemployedJob].label
        jobData.onduty = false
        jobData.isboss = false

        MySQL.Async.execute(
          "UPDATE players SET job=@jobData WHERE license=@license",
          {
            ["@license"] = identifier,
            ["@jobData"] = json.encode(jobData)
          }
        )
      end
    end
  end

  TriggerEvent(Utils.eventsPrefix .. ":boss:employeeFired", identifier, jobName)
  notify(playerId, getLocalizedText("boss:employee_fired"))
  Utils.log(
    playerId,
    getLocalizedText("log_fired_employee"),
    getLocalizedText("log_fired_employee_description", identifier),
    "success",
    "boss"
  )
end)

RegisterServerCallback(Utils.eventsPrefix .. ":boss:getClosePlayersNames", function(playerId, callback, closePlayers)
  local playerNames, playerServerId, characterName

  playerNames = {}
  for _, playerServerId in pairs(closePlayers) do
    characterName = Framework.getPlayerCharacterName(playerServerId)
    table.insert(playerNames, {
      label = characterName,
      serverId = playerServerId
    })
  end

  callback(playerNames)
end)

RegisterNetEvent(Utils.eventsPrefix .. ":boss:recruitPlayer", function(markerId, playerServerId)
  local playerId, canAccess, jobName, moduleResult, lowestGrade, framework, player, playerToRecruit

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  if config.modules.boss ~= "default" then
    moduleResult = Utils.callModuleFunc("boss", "recruitPlayer", playerId, playerServerId, jobName)
    if moduleResult ~= nil then
      return
    end
  end

  lowestGrade = JobsCreator.findLowestGrade(jobName)
  Framework.setJobToPlayer(playerServerId, jobName, lowestGrade)

  notify(playerServerId, getLocalizedText("boss:you_got_hired", JobsCreator.Jobs[jobName].label))
  notify(playerId, getLocalizedText("boss:you_hired", Framework.getPlayerCharacterName(playerServerId)))

  framework = Framework.getFramework()
  if framework == "ESX" then
    player = ESX.GetPlayerFromId(playerServerId)
    if ESX.SavePlayer then
      ESX.SavePlayer(player)
    end
  else
    if framework == "QB-core" then
      QBCore.Player.Save(playerServerId)
    end
  end

  TriggerEvent(Utils.eventsPrefix .. ":boss:playerHired", playerServerId, jobName)
  Utils.log(
    playerId,
    getLocalizedText("log_recruited_employee"),
    getLocalizedText("log_recruited_employee_description", GetPlayerName(playerServerId), Framework.getIdentifier(playerServerId)),
    "success",
    "boss"
  )
end)

RegisterNetEvent(Utils.eventsPrefix .. ":boss:changeGradeToEmployee", function(markerId, identifier, grade)
  local playerId, canAccess, jobName, moduleResult, framework, player, playerToUpdate, job, gradeLabel, offJobName, jobData, gradeLevel

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  jobName = Framework.getPlayerJobName(playerId)
  if config.modules.boss ~= "default" then
    moduleResult = Utils.callModuleFunc("boss", "changeGradeToEmployee", playerId, identifier, grade, jobName)
    if moduleResult ~= nil then
      return
    end
  end

  framework = Framework.getFramework()
  if framework == "ESX" then
    player = ESX.GetPlayerFromIdentifier(identifier)
    if player then
      player.setJob(jobName, grade)
      playerToUpdate = ESX.GetPlayerFromId(player.source)
      if ESX.SavePlayer then
        ESX.SavePlayer(playerToUpdate)
      end
      notify(player.source, getLocalizedText("boss:your_grade_changed_to", playerToUpdate.job.grade_label))
    else
      offJobName = JobsCreator.getOffDutyName(jobName)
      MySQL.Async.execute(
        "UPDATE users SET job_grade=@jobGrade WHERE identifier=@identifier AND (job=@currentJobName OR job=@offJobName)",
        {
          ["@jobGrade"] = grade,
          ["@identifier"] = identifier,
          ["@currentJobName"] = jobName,
          ["@offJobName"] = offJobName
        }
      )
    end
  else
    if framework == "QB-core" then
      onlinePlayerId = QBCore.Functions.GetSource(identifier)
      if onlinePlayerId and onlinePlayerId > 0 then
        player = QBCore.Functions.GetPlayer(onlinePlayerId)
        player.Functions.SetJob(jobName, grade)
        notify(player.source, getLocalizedText("boss:your_grade_changed_to", player.PlayerData.job.grade.name))
        QBCore.Player.Save(onlinePlayerId)
      else
        MySQL.Async.fetchScalar("SELECT job FROM players WHERE license=@license", {
          ["@license"] = identifier
        }, function(jobJson)
          job = json.decode(jobJson)
          job.name = jobName
          job.grade.level = grade

          MySQL.Async.execute(
            "UPDATE players SET job=@job WHERE license=@license",
            {
              ["@license"] = identifier,
              ["@job"] = json.encode(job)
            }
          )
        end)
      end
    end
  end

  notify(playerId, getLocalizedText("boss:changed_grade_successfully"))
  Utils.log(
    playerId,
    getLocalizedText("log_changed_grade_employee"),
    getLocalizedText("log_changed_grade_employee_description", identifier, grade),
    "success",
    "boss"
  )
end)

RegisterNetEvent(Utils.eventsPrefix .. ":washMoney", function(markerId, amount)
  local playerId, canAccess, blackMoney, markerData, returnPercentage, goesToSociety, cleanAmount, success, jobName

  playerId = source
  canAccess = canUseMarkerWithLog(playerId, markerId)
  if not canAccess then
    return
  end

  blackMoney = Framework.getBlackMoneyValue(playerId)

  if amount <= blackMoney then
    markerData = JobsCreator.Markers[markerId].data
    returnPercentage = markerData.washMoneyReturnPercentage
    if not returnPercentage then
      returnPercentage = 100
    end

    goesToSociety = markerData.washMoneyGoesToSocietyAccount
    cleanAmount = math.floor(amount * returnPercentage / 100)
    success = false

    if goesToSociety then
      jobName = Framework.getPlayerJobName(playerId)
      success = Framework.giveMoneyToSocietyAccount(jobName, cleanAmount)
    else
      Framework.giveCashToPlayer(playerId, cleanAmount)
      success = true
    end

    if success then
      Framework.removeBlackMoneyValue(playerId, amount)
      notify(
        playerId,
        getLocalizedText("boss:you_washed_money", Framework.groupDigits(amount), Framework.groupDigits(cleanAmount))
      )
      Utils.log(
        playerId,
        getLocalizedText("log_washed_money"),
        getLocalizedText("log_washed_money_description", Framework.groupDigits(amount)),
        "success",
        "boss"
      )
    else
      notify(playerId, getLocalizedText("boss:couldnt_wash_money"))
    end
  else
    notify(playerId, getLocalizedText("boss:not_enough_dirty_money"))
  end
end)
