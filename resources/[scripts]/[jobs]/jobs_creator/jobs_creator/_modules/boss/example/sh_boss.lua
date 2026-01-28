local moduleType = "boss" -- Module category
local moduleName = "example" -- THIS module name

-- Don't touch, required to appear in in-game settings
Integrations.modules = Integrations.modules or {}
Integrations.modules[moduleType] = Integrations.modules[moduleType] or {}
Integrations[moduleType] = Integrations[moduleType] or {}
Integrations[moduleType][moduleName] = {}
table.insert(Integrations.modules[moduleType], moduleName)

-- Example function to modify the employees list
-- This function is called before returning the employees list to the client
-- You can modify the employees table to add or filter employees
Integrations[moduleType][moduleName].modifyEmployeesList = function(employeesArray, jobName)
    -- Example: Do your edits to the employeesArray

    return employeesArray -- Return the modified employees list
end

--- Example function to modify the fire employee behavior
--- This function is called when an employee is fired
--- @return boolean|nil true if the employee is fired, nil if you don't want to edit the default behavior
Integrations[moduleType][moduleName].fireEmployee = function(playerId, employeeIdentifier, jobName)
    -- Write your code if you want to

    -- nil will not edit the default behavior, so if nil is returned, after this function finish the default fire employee will start
    return nil
end

-- Example function to modify the recruit player behavior
-- This function is called before recruiting a player
-- @return boolean|nil true if the player is recruited, nil if you don't want to edit the default behavior
Integrations[moduleType][moduleName].recruitPlayer = function(playerId, targetId, jobName)
    -- nil will not edit the default behavior, so if nil is returned, after this function finish the default recruit player will start
    return nil
end

-- Example function to modify the change grade behavior
-- This function is called before changing an employee's grade
-- @return boolean|nil true if the grade is changed, nil if you don't want to edit the default behavior
Integrations[moduleType][moduleName].changeGradeToEmployee = function(playerId, employeeIdentifier, newGrade, jobName)
    -- Write your code if you want to

    -- nil will not edit the default behavior, so if nil is returned, after this function finish the default change grade will start
    return nil
end
