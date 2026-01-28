Database = {}

local sqlFiles = {}
local sqlFile1 = {}
sqlFile1.path = "sql/jobs_data.sql"
local sqlFile2 = {}
sqlFile2.path = "sql/jobs_armories.sql"
local sqlFile3 = {}
sqlFile3.path = "sql/jobs_garages.sql"
local sqlFile4 = {}
sqlFile4.path = "sql/jobs_wardrobes.sql"
local sqlFile5 = {}
sqlFile5.path = "sql/jobs_shops.sql"
local sqlFile6 = {}
sqlFile6.path = "sql/jobs_columns.sql"
sqlFile6.framework = "ESX"
local sqlFile7 = {}
sqlFile7.path = "sql/jobs.sql"
local sqlFile8 = {}
sqlFile8.path = "sql/jobs_data_columns.sql"
local sqlFile9 = {}
sqlFile9.path = "sql/job_grades_esx.sql"
sqlFile9.framework = "ESX"
local sqlFile10 = {}
sqlFile10.path = "sql/job_grades_qbcore.sql"
sqlFile10.framework = "QB-core"
local sqlFile11 = {}
sqlFile11.path = "job_grades_auto_increment.sql"
local sqlFile12 = {}
sqlFile12.path = "jobs_data_specific_grades_fix.sql"
local sqlFile13 = {}
sqlFile13.path = "sql/jobs_employee_hours.sql"
sqlFiles[1] = sqlFile1
sqlFiles[2] = sqlFile2
sqlFiles[3] = sqlFile3
sqlFiles[4] = sqlFile4
sqlFiles[5] = sqlFile5
sqlFiles[6] = sqlFile6
sqlFiles[7] = sqlFile7
sqlFiles[8] = sqlFile8
sqlFiles[9] = sqlFile9
sqlFiles[10] = sqlFile10
sqlFiles[11] = sqlFile11
sqlFiles[12] = sqlFile12
sqlFiles[13] = sqlFile13

local columnDefinitions = {}
local columnDef1 = {}
columnDef1.table = "jobs"
columnDef1.column = "enable_billing"
columnDef1.sql = "ALTER TABLE jobs ADD COLUMN enable_billing INT(1) DEFAULT 0"
local columnDef2 = {}
columnDef2.table = "jobs"
columnDef2.column = "can_rob"
columnDef2.sql = "ALTER TABLE jobs ADD COLUMN can_rob INT(1) DEFAULT 0"
local columnDef3 = {}
columnDef3.table = "jobs"
columnDef3.column = "can_handcuff"
columnDef3.sql = "ALTER TABLE jobs ADD COLUMN can_handcuff INT(1) DEFAULT 0"
local columnDef4 = {}
columnDef4.table = "jobs"
columnDef4.column = "whitelisted"
columnDef4.sql = "ALTER TABLE jobs ADD COLUMN whitelisted INT(1) DEFAULT 0"
local columnDef5 = {}
columnDef5.table = "jobs"
columnDef5.column = "can_lockpick_cars"
columnDef5.sql = "ALTER TABLE jobs ADD COLUMN can_lockpick_cars INT(1) DEFAULT 0"
local columnDef6 = {}
columnDef6.table = "jobs"
columnDef6.column = "can_wash_vehicles"
columnDef6.sql = "ALTER TABLE jobs ADD COLUMN can_wash_vehicles INT(1) DEFAULT 0"
local columnDef7 = {}
columnDef7.table = "jobs"
columnDef7.column = "can_repair_vehicles"
columnDef7.sql = "ALTER TABLE jobs ADD COLUMN can_repair_vehicles INT(1) DEFAULT 0"
local columnDef8 = {}
columnDef8.table = "jobs"
columnDef8.column = "can_impound_vehicles"
columnDef8.sql = "ALTER TABLE jobs ADD COLUMN can_impound_vehicles INT(1) DEFAULT 0"
local columnDef9 = {}
columnDef9.table = "jobs"
columnDef9.column = "can_check_identity"
columnDef9.sql = "ALTER TABLE jobs ADD COLUMN can_check_identity INT(1) DEFAULT 0"
local columnDef10 = {}
columnDef10.table = "jobs"
columnDef10.column = "can_check_vehicle_owner"
columnDef10.sql = "ALTER TABLE jobs ADD COLUMN can_check_vehicle_owner INT(1) DEFAULT 0"
local columnDef11 = {}
columnDef11.table = "jobs"
columnDef11.column = "can_check_driving_license"
columnDef11.sql = "ALTER TABLE jobs ADD COLUMN can_check_driving_license INT(1) DEFAULT 0"
local columnDef12 = {}
columnDef12.table = "jobs"
columnDef12.column = "can_check_weapon_license"
columnDef12.sql = "ALTER TABLE jobs ADD COLUMN can_check_weapon_license INT(1) DEFAULT 0"
local columnDef13 = {}
columnDef13.table = "jobs"
columnDef13.column = "can_heal"
columnDef13.sql = "ALTER TABLE jobs ADD COLUMN can_heal INT(1) DEFAULT 0"
local columnDef14 = {}
columnDef14.table = "jobs"
columnDef14.column = "can_revive"
columnDef14.sql = "ALTER TABLE jobs ADD COLUMN can_revive INT(1) DEFAULT 0"
local columnDef15 = {}
columnDef15.table = "jobs"
columnDef15.column = "actions_menu_enabled"
columnDef15.sql = "ALTER TABLE jobs ADD COLUMN actions_menu_enabled INT(1) DEFAULT 1"
local columnDef16 = {}
columnDef16.table = "jobs"
columnDef16.column = "placeable_objects"
columnDef16.sql = "ALTER TABLE jobs ADD COLUMN placeable_objects LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin'"
local columnDef17 = {}
columnDef17.table = "jobs"
columnDef17.column = "options"
columnDef17.sql = "ALTER TABLE jobs ADD COLUMN options LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin'"
local columnDef18 = {}
columnDef18.table = "jobs_data"
columnDef18.column = "blip_id"
columnDef18.sql = "ALTER TABLE jobs_data ADD COLUMN `blip_id` INT(11) NULL DEFAULT NULL;"
local columnDef19 = {}
columnDef19.table = "jobs_data"
columnDef19.column = "blip_color"
columnDef19.sql = "ALTER TABLE jobs_data ADD COLUMN `blip_color` INT(11) NULL DEFAULT '0';"
local columnDef20 = {}
columnDef20.table = "jobs_data"
columnDef20.column = "blip_scale"
columnDef20.sql = "ALTER TABLE jobs_data ADD COLUMN `blip_scale` FLOAT(12) NULL DEFAULT '1';"
local columnDef21 = {}
columnDef21.table = "jobs_data"
columnDef21.column = "label"
columnDef21.sql = "ALTER TABLE jobs_data ADD COLUMN `label` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci';"
local columnDef22 = {}
columnDef22.table = "jobs_data"
columnDef22.column = "marker_type"
columnDef22.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_type` INT(11) NULL DEFAULT '1';"
local columnDef23 = {}
columnDef23.table = "jobs_data"
columnDef23.column = "marker_scale_x"
columnDef23.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_scale_x` FLOAT(12) NULL DEFAULT '1.5';"
local columnDef24 = {}
columnDef24.table = "jobs_data"
columnDef24.column = "marker_scale_y"
columnDef24.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_scale_y` FLOAT(12) NULL DEFAULT '1.5';"
local columnDef25 = {}
columnDef25.table = "jobs_data"
columnDef25.column = "marker_scale_z"
columnDef25.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_scale_z` FLOAT(12) NULL DEFAULT '0.5';"
local columnDef26 = {}
columnDef26.table = "jobs_data"
columnDef26.column = "marker_color_red"
columnDef26.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_color_red` INT(3) NULL DEFAULT '150';"
local columnDef27 = {}
columnDef27.table = "jobs_data"
columnDef27.column = "marker_color_green"
columnDef27.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_color_green` INT(3) NULL DEFAULT '150';"
local columnDef28 = {}
columnDef28.table = "jobs_data"
columnDef28.column = "marker_color_blue"
columnDef28.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_color_blue` INT(3) NULL DEFAULT '0';"
local columnDef29 = {}
columnDef29.table = "jobs_data"
columnDef29.column = "marker_color_alpha"
columnDef29.sql = "ALTER TABLE jobs_data ADD COLUMN `marker_color_alpha` INT(3) NULL DEFAULT '50';"
local columnDef30 = {}
columnDef30.table = "jobs_data"
columnDef30.column = "ped"
columnDef30.sql = "ALTER TABLE jobs_data ADD COLUMN `ped` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci';"
local columnDef31 = {}
columnDef31.table = "jobs_data"
columnDef31.column = "ped_heading"
columnDef31.sql = "ALTER TABLE jobs_data ADD COLUMN `ped_heading` FLOAT(12) NULL DEFAULT NULL;"
local columnDef32 = {}
columnDef32.table = "jobs_data"
columnDef32.column = "object"
columnDef32.sql = "ALTER TABLE jobs_data ADD COLUMN `object` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci';"
local columnDef33 = {}
columnDef33.table = "jobs_data"
columnDef33.column = "object_heading"
columnDef33.sql = "ALTER TABLE jobs_data ADD COLUMN `object_heading` FLOAT(12) NULL DEFAULT NULL;"
local columnDef34 = {}
columnDef34.table = "jobs_data"
columnDef34.column = "specific_grades"
columnDef34.sql = "ALTER TABLE jobs_data ADD COLUMN `specific_grades` VARCHAR(255) DEFAULT NULL;"
local columnDef35 = {}
columnDef35.table = "jobs_data"
columnDef35.column = "grades_type"
columnDef35.sql = "ALTER TABLE jobs_data ADD COLUMN `grades_type` VARCHAR(20) DEFAULT NULL;"
columnDefinitions[1] = columnDef1
columnDefinitions[2] = columnDef2
columnDefinitions[3] = columnDef3
columnDefinitions[4] = columnDef4
columnDefinitions[5] = columnDef5
columnDefinitions[6] = columnDef6
columnDefinitions[7] = columnDef7
columnDefinitions[8] = columnDef8
columnDefinitions[9] = columnDef9
columnDefinitions[10] = columnDef10
columnDefinitions[11] = columnDef11
columnDefinitions[12] = columnDef12
columnDefinitions[13] = columnDef13
columnDefinitions[14] = columnDef14
columnDefinitions[15] = columnDef15
columnDefinitions[16] = columnDef16
columnDefinitions[17] = columnDef17
columnDefinitions[18] = columnDef18
columnDefinitions[19] = columnDef19
columnDefinitions[20] = columnDef20
columnDefinitions[21] = columnDef21
columnDefinitions[22] = columnDef22
columnDefinitions[23] = columnDef23
columnDefinitions[24] = columnDef24
columnDefinitions[25] = columnDef25
columnDefinitions[26] = columnDef26
columnDefinitions[27] = columnDef27
columnDefinitions[28] = columnDef28
columnDefinitions[29] = columnDef29
columnDefinitions[30] = columnDef30
columnDefinitions[31] = columnDef31
columnDefinitions[32] = columnDef32
columnDefinitions[33] = columnDef33
columnDefinitions[34] = columnDef34
columnDefinitions[35] = columnDef35

local function isDatabaseConnected()
  local promise = promise.new()
  local isConnected = false
  pcall(function()
    local result = MySQL.Sync.fetchScalar("SELECT 1", {})
    isConnected = true
    promise:resolve(result)
  end)
  SetTimeout(5000, function()
    if not isConnected then
      promise:resolve(false)
    end
  end)
  return Citizen.Await(promise)
end

local function waitForDatabase()
  local attempts = 0
  local waitTime = 10
  while true do
    attempts = attempts + 1
    if isDatabaseConnected() then
      break
    end
    if attempts > 10 then
      print("^1")
      print("The database is not set up properly (or it's not started at all). Retrying connection in " .. waitTime .. " seconds...")
      print("This is NOT fault of '" .. GetCurrentResourceName() .. "' script, make sure to have a server ready before using this script")
      print("^7")
    end
    Citizen.Wait(waitTime * 1000)
  end
end

function setupDatabase()
  waitForDatabase()
  local resourceName = GetCurrentResourceName()
  print("^3Setting up database (it may take few seconds)...^7")
  for _, sqlFile in pairs(sqlFiles) do
    if sqlFile.framework then
      if sqlFile.framework == Framework.getFramework() then
        local sqlContent = LoadResourceFile(resourceName, sqlFile.path)
        if sqlContent then
          local promise = promise.new()
          MySQL.Async.execute(sqlContent, {}, function()
            promise:resolve()
          end)
          Citizen.Await(promise)
        end
      end
    else
      local sqlContent = LoadResourceFile(resourceName, sqlFile.path)
      if sqlContent then
        local promise = promise.new()
        MySQL.Async.execute(sqlContent, {}, function()
          promise:resolve()
        end)
        Citizen.Await(promise)
      end
    end
  end
  local databaseName = Database.getCurrentDatabaseName()
  for _, columnDef in pairs(columnDefinitions) do
    if not Database.doesColumnExist(databaseName, columnDef.table, columnDef.column) then
      local promise = promise.new()
      MySQL.Async.execute(columnDef.sql, {}, function()
        promise:resolve()
      end)
      Citizen.Await(promise)
    end
  end
  local jobsWithoutOptions = MySQL.Sync.fetchAll("SELECT * FROM jobs WHERE options IS NULL OR options = ''")
  for _, job in pairs(jobsWithoutOptions) do
    local options = {}
    options.enableBilling = job.enable_billing == 1
    options.canRob = job.can_rob == 1
    options.canHandcuff = job.can_handcuff == 1
    options.whitelisted = job.whitelisted == 1
    options.canLockpickCars = job.can_lockpick_cars == 1
    options.canWashVehicles = job.can_wash_vehicles == 1
    options.canRepairVehicles = job.can_repair_vehicles == 1
    options.canImpoundVehicles = job.can_impound_vehicles == 1
    options.canCheckIdentity = job.can_check_identity == 1
    options.canCheckVehicleOwner = job.can_check_vehicle_owner == 1
    options.canCheckDrivingLicense = job.can_check_driving_license == 1
    options.canCheckWeaponLicense = job.can_check_weapon_license == 1
    options.canHeal = job.can_heal == 1
    options.canRevive = job.can_revive == 1
    options.actionsMenuEnabled = job.actions_menu_enabled == 1
    if job.placeable_objects then
      local decodedPlaceableObjects = json.decode(job.placeable_objects)
      if decodedPlaceableObjects then
        options.placeableObjects = decodedPlaceableObjects
      else
        options.placeableObjects = {}
      end
    else
      options.placeableObjects = {}
    end
    local optionsJson = json.encode(options)
    MySQL.Sync.execute("UPDATE jobs SET options=@options WHERE name=@name", {
      ["@options"] = optionsJson,
      ["@name"] = job.name
    })
  end
  print("^2Database ready^7")
  print()
  TriggerEvent(Utils.eventsPrefix .. ":database:ready")
  return true
end

function Database.getCurrentDatabaseName()
  return MySQL.Sync.fetchScalar("SELECT DATABASE();")
end

function Database.doesColumnExist(databaseName, tableName, columnName)
  return MySQL.Sync.fetchScalar(
    "SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @databaseName AND TABLE_NAME = @tableName AND COLUMN_NAME = @columnName",
    {
      ["@databaseName"] = databaseName,
      ["@tableName"] = tableName,
      ["@columnName"] = columnName
    }
  )
end
