local function sortMenuItems(a, b)
    return a.index < b.index
end

local function openGradesMenu(bossId)
    TriggerServerCallback(Utils.eventsPrefix .. ":boss:getJobGrades", function(grades, maxSalary)
        local elements = {}
        for _, grade in pairs(grades) do
            table.insert(elements, {
                label = getLocalizedText("boss:rank_salary", grade.label, Framework.groupDigits(grade.salary)),
                gradeId = grade.id,
                grade = grade.grade
            })
        end
        
        Utils.openInteractionMenu("boss_menu_grades", getLocalizedText("boss_menu"), elements, function(selected, scrollIndex, args)
            local gradeId = args.gradeId
            local grade = args.grade
            if not gradeId then
                return
            end
            
            local newSalary = Utils.askQuantity(getLocalizedText("boss:new_salary"), 1, maxSalary)
            if not newSalary then
                return
            end
            
            TriggerServerEvent(Utils.eventsPrefix .. ":updateGradeSalary", bossId, gradeId, grade, newSalary)
            Utils.hideInteractionMenu()
        end, function()
            Utils.hideInteractionMenu()
        end)
    end, bossId)
end

local function confirmFireEmployee(bossId, employeeId)
    Utils.openInteractionMenu("boss_menu_employee_fire", getLocalizedText("boss_menu"), {
        {
            label = getLocalizedText("boss:cancel"),
            value = "no"
        },
        {
            label = getLocalizedText("boss:fire"),
            value = "yes"
        }
    }, function(selected, scrollIndex, args)
        local action = args.value
        if action == "yes" then
            TriggerServerEvent(Utils.eventsPrefix .. ":boss:fireEmployee", bossId, employeeId)
        end
        openBoss(bossId)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function changeEmployeeGrade(bossId, employeeId)
    local playerJob = Framework.getPlayerJob()
    local ranks = TriggerServerPromise(Utils.eventsPrefix .. ":retrieveJobRanks", playerJob)
    local elements = {}
    
    for _, rank in pairs(ranks) do
        table.insert(elements, {
            label = getLocalizedText("boss:grade", rank.grade, rank.label, Framework.groupDigits(rank.salary)),
            grade = rank.grade
        })
    end
    
    Utils.openInteractionMenu("boss_menu_employee_change_grade", getLocalizedText("boss_menu"), elements, function(selected, scrollIndex, args)
        local grade = args.grade
        if not grade then
            return
        end
        
        TriggerServerEvent(Utils.eventsPrefix .. ":boss:changeGradeToEmployee", bossId, employeeId, grade)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function formatWorkTime(minutes, resetDays)
    if not resetDays then
        resetDays = config.resetEmployeeWorkTimeEveryNDays
    end
    
    if not minutes then
        return getLocalizedText("boss:work_time", 0, 0, resetDays)
    end
    
    local hours = math.floor(minutes / 60)
    local mins = math.floor(minutes % 60)
    return getLocalizedText("boss:work_time", hours, mins, resetDays)
end

function manageEmployee(bossId, employeeId, days)
    if not days then
        days = 7
    end
    
    local workTime = TriggerServerPromise(Utils.eventsPrefix .. ":boss:getEmployeeWorkTime", bossId, employeeId, days)
    local elements = {
        {
            label = formatWorkTime(workTime, days),
            value = "work_time"
        },
        {
            label = getLocalizedText("boss:change_grade"),
            value = "change_grade"
        },
        {
            label = getLocalizedText("boss:fire"),
            value = "fire"
        }
    }
    
    Utils.openInteractionMenu("boss_menu_employee_management", getLocalizedText("boss_menu"), elements, function(selected, scrollIndex, args)
        local action = args.value
        if action == "change_grade" then
            changeEmployeeGrade(bossId, employeeId)
        elseif action == "fire" then
            confirmFireEmployee(bossId, employeeId)
        elseif action == "work_time" then
            local inputDays = Utils.askQuantity(getLocalizedText("boss:work_time_days_input_title"), 0, 14)
            if not inputDays then
                return
            end
            manageEmployee(bossId, employeeId, inputDays)
        end
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function getEmployeesList(bossId)
    TriggerServerCallback(Utils.eventsPrefix .. ":boss:getEmployees", function(employees, gradeLabels)
        local elements = {}
        for _, employee in pairs(employees) do
            local employeeText = getLocalizedText("boss:employee", employee.firstname, employee.lastname, gradeLabels[employee.job_grade])
            local statusSuffix = nil
            
            if not employee.isOnline then
                statusSuffix = getLocalizedText("boss:offline_suffix")
            else
                if employee.isOnDuty then
                    statusSuffix = getLocalizedText("boss:on_duty_suffix")
                else
                    statusSuffix = getLocalizedText("boss:off_duty_suffix")
                end
            end
            
            table.insert(elements, {
                label = employeeText .. statusSuffix,
                value = employee.identifier
            })
        end
        
        if #elements == 0 then
            table.insert(elements, {
                label = getLocalizedText("boss:no_employees")
            })
        end
        
        Utils.openInteractionMenu("boss_menu_employees_management", getLocalizedText("boss_menu"), elements, function(selected, scrollIndex, args)
            local employeeId = args.value
            if not employeeId then
                return
            end
            manageEmployee(bossId, employeeId)
        end, function()
            Utils.hideInteractionMenu()
        end)
    end, bossId)
end

local function recruitPlayer(bossId)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closePlayers = Framework.getClosePlayers(10.0, true)
    
    TriggerServerCallback(Utils.eventsPrefix .. ":boss:getClosePlayersNames", function(players)
        if #players == 0 then
            table.insert(players, {
                label = getLocalizedText("boss:nobody_close")
            })
        end
        
        Utils.openInteractionMenu("boss_menu_employees_recruit", getLocalizedText("boss_menu"), players, function(selected, scrollIndex, args)
            local serverId = args.serverId
            if not serverId then
                return
            end
            TriggerServerEvent(Utils.eventsPrefix .. ":boss:recruitPlayer", bossId, serverId)
        end, function()
            Utils.hideInteractionMenu()
        end)
    end, closePlayers)
end

local function openEmployeesMenu(bossId)
    Utils.openInteractionMenu("boss_menu_employees", getLocalizedText("boss_menu"), {
        {
            label = getLocalizedText("boss:employees_list"),
            value = "employees"
        },
        {
            label = getLocalizedText("boss:recruit"),
            value = "recruit"
        }
    }, function(selected, scrollIndex, args)
        local action = args.value
        if action == "employees" then
            getEmployeesList(bossId)
        elseif action == "recruit" then
            recruitPlayer(bossId)
        end
    end, function()
        Utils.hideInteractionMenu()
    end)
end

function openBoss(bossId)
    Utils.hideInteractionMenu()
    TriggerServerCallback(Utils.eventsPrefix .. ":getBossData", function(bossData, societyMoney)
        local menuItems = {
            withdraw = {
                label = getLocalizedText("boss:withdraw"),
                value = "withdraw",
                index = 1
            },
            deposit = {
                label = getLocalizedText("boss:deposit"),
                value = "deposit",
                index = 2
            },
            wash = {
                label = getLocalizedText("boss:wash_money"),
                value = "wash",
                index = 5
            },
            grades = {
                label = getLocalizedText("boss:grades"),
                value = "grades",
                index = 3
            },
            employees = {
                label = getLocalizedText("boss:employees"),
                value = "employees",
                index = 4
            }
        }
        
        local elements = {}
        for key, enabled in pairs(bossData) do
            if enabled then
                table.insert(elements, menuItems[key])
            end
        end
        
        table.sort(elements, sortMenuItems)
        
        if societyMoney then
            table.insert(elements, 1, {
                label = getLocalizedText("boss:society_money", Framework.groupDigits(societyMoney))
            })
        end
        
        Utils.openInteractionMenu("boss_menu", getLocalizedText("boss_menu"), elements, function(selected, scrollIndex, args)
            local action = args.value
            if action == "withdraw" then
                local amount = Utils.askQuantity(getLocalizedText("boss:withdraw_amount"), 1, nil)
                if not amount then
                    return
                end
                TriggerServerEvent(Utils.eventsPrefix .. ":withdrawSocietyMoney", bossId, amount)
                openBoss(bossId)
            elseif action == "deposit" then
                local amount = Utils.askQuantity(getLocalizedText("boss:deposit_amount"), 1, nil)
                if not amount then
                    return
                end
                TriggerServerEvent(Utils.eventsPrefix .. ":depositSocietyMoney", bossId, amount)
                openBoss(bossId)
            elseif action == "grades" then
                openGradesMenu(bossId)
            elseif action == "employees" then
                openEmployeesMenu(bossId)
            elseif action == "wash" then
                local amount = Utils.askQuantity(getLocalizedText("boss:how_much_to_wash"), 1, nil)
                if not amount then
                    return
                end
                TriggerServerEvent(Utils.eventsPrefix .. ":washMoney", bossId, amount)
            end
        end, function()
            Utils.hideInteractionMenu()
        end)
    end, bossId)
end