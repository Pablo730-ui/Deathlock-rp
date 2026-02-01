PlayerList = {}
PlayerListCache = {}
ServerInformation = { 
    StaffCount = nil, 
    CharacterCount = nil, 
    VehicleCount = nil, 
    BansCount = nil, 
    PlayerCountHistory = {} 
}

AdminPanel = { 
    ClientCallbacks = {}, 
    ServerCallbacks = {}, 
    AdminChat = {}, 
    Reports = {}, 
    InterceptedLogs = {} 
}

LoadedRole = {}
PlayersB = {} 

CreateThread(function()
    while true do
        ServerInformation.PlayerCountHistory[os.time()] = #GetPlayers()

        for entryTime, _ in pairs(ServerInformation.PlayerCountHistory) do 
            if entryTime < os.time() - 86400 then 
                ServerInformation.PlayerCountHistory[entryTime] = nil 
            end 
        end

        Wait(Config.PlayerGraphFrequency)
    end
end)

-- Function to validate and clean report data
local function validateAndCleanReports()
    if not AdminPanel.Reports or type(AdminPanel.Reports) ~= 'table' then
        DebugTrace('[REPORTS] Invalid reports structure detected, resetting')
        AdminPanel.Reports = {}
        return
    end
    
    local validReports = {}
    local cleanedCount = 0
    
    for k, v in pairs(AdminPanel.Reports) do
        -- Validate each report has required fields
        if type(v) == 'table' and 
           v.ReportID and 
           v.SenderCitizenID and 
           v.SenderName and 
           v.Subject and 
           v.ReportTime and
           type(v.ReportTime) == 'number' then
            validReports[k] = v
        else
            cleanedCount = cleanedCount + 1
            DebugTrace('[REPORTS] Removed corrupted report with key: ' .. tostring(k))
        end
    end
    
    AdminPanel.Reports = validReports
    
    if cleanedCount > 0 then
        DebugTrace('[REPORTS] Cleaned ' .. cleanedCount .. ' corrupted reports')
        -- Save cleaned data
        local success, error = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
        if not success then
            DebugTrace('[REPORTS] Failed to save cleaned reports: ' .. tostring(error))
        end
    end
end

if Config.SaveTOJSON then
    CreateThread(function()
        -- Load reports with proper error handling
        local reportsFile = LoadResourceFile(GetCurrentResourceName(), './json/reports.json')
        if reportsFile and reportsFile ~= '' then
            local success, decodedReports = pcall(json.decode, reportsFile)
            if success and type(decodedReports) == 'table' then
                AdminPanel.Reports = decodedReports
                -- Count reports properly since it's a keyed table
                local reportCount = 0
                for _ in pairs(AdminPanel.Reports) do
                    reportCount = reportCount + 1
                end
                DebugTrace('[REPORTS] Successfully loaded ' .. reportCount .. ' reports from JSON')
                -- Validate and clean loaded reports
                validateAndCleanReports()
            else
                AdminPanel.Reports = {}
                DebugTrace('[REPORTS] Failed to decode reports JSON, initializing empty table')
                -- Save empty reports to fix corrupted file
                SaveResourceFile(GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
            end
        else
            AdminPanel.Reports = {}
            DebugTrace('[REPORTS] No reports file found, initializing empty table')
            -- Create initial empty reports file
            SaveResourceFile(GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
        end

        -- Load admin chat with proper error handling
        local adminChatFile = LoadResourceFile(GetCurrentResourceName(), './json/adminchat.json')
        if adminChatFile and adminChatFile ~= '' then
            local success, decodedAdminChat = pcall(json.decode, adminChatFile)
            if success and type(decodedAdminChat) == 'table' then
                AdminPanel.AdminChat = decodedAdminChat
                DebugTrace('[ADMINCHAT] Successfully loaded admin chat from JSON')
            else
                AdminPanel.AdminChat = {}
                DebugTrace('[ADMINCHAT] Failed to decode admin chat JSON, initializing empty table')
                SaveResourceFile(GetCurrentResourceName(), 'json/adminchat.json', json.encode(AdminPanel.AdminChat), -1)
            end
        else
            AdminPanel.AdminChat = {}
            DebugTrace('[ADMINCHAT] No admin chat file found, initializing empty table')
            SaveResourceFile(GetCurrentResourceName(), 'json/adminchat.json', json.encode(AdminPanel.AdminChat), -1)
        end

        -- Load logs with proper error handling
        local logsFile = LoadResourceFile(GetCurrentResourceName(), './json/logs.json')
        if logsFile and logsFile ~= '' then
            local success, decodedLogs = pcall(json.decode, logsFile)
            if success and type(decodedLogs) == 'table' then
                AdminPanel.InterceptedLogs = decodedLogs
                DebugTrace('[LOGS] Successfully loaded logs from JSON')
            else
                AdminPanel.InterceptedLogs = {}
                DebugTrace('[LOGS] Failed to decode logs JSON, initializing empty table')
                SaveResourceFile(GetCurrentResourceName(), 'json/logs.json', json.encode(AdminPanel.InterceptedLogs), -1)
            end
        else
            AdminPanel.InterceptedLogs = {}
            DebugTrace('[LOGS] No logs file found, initializing empty table')
            SaveResourceFile(GetCurrentResourceName(), 'json/logs.json', json.encode(AdminPanel.InterceptedLogs), -1)
        end
    end)

    AddEventHandler('onResourceStop', function(name)
        if name == GetCurrentResourceName() then
            -- Save with error handling
            local success1, error1 = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
            if not success1 then
                DebugTrace('[REPORTS] Failed to save reports on resource stop: ' .. tostring(error1))
            end
            
            local success2, error2 = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/logs.json', json.encode(AdminPanel.InterceptedLogs), -1)
            if not success2 then
                DebugTrace('[LOGS] Failed to save logs on resource stop: ' .. tostring(error2))
            end
            
            local success3, error3 = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/adminchat.json', json.encode(AdminPanel.AdminChat), -1)
            if not success3 then
                DebugTrace('[ADMINCHAT] Failed to save admin chat on resource stop: ' .. tostring(error3))
            end
        end
    end)

    AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
        if eventData.secondsRemaining == 60 then
            CreateThread(function()
                Wait(45000)
                -- Save with error handling for scheduled restart
                local success1, error1 = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
                if not success1 then
                    DebugTrace('[REPORTS] Failed to save reports on scheduled restart: ' .. tostring(error1))
                end
                
                local success2, error2 = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/logs.json', json.encode(AdminPanel.InterceptedLogs), -1)
                if not success2 then
                    DebugTrace('[LOGS] Failed to save logs on scheduled restart: ' .. tostring(error2))
                end
                
                local success3, error3 = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/adminchat.json', json.encode(AdminPanel.AdminChat), -1)
                if not success3 then
                    DebugTrace('[ADMINCHAT] Failed to save admin chat on scheduled restart: ' .. tostring(error3))
                end
            end)
        end
    end)
end

if Config.EnableAdminPanelCommand then 
    RegisterCommand(Config.AdminPanelCommand, function(source, args) 
        if AdminPanel.HasPermission(source, 'adminmenu') then 
            OpenPanel(source) 
        end 
    end, false) 
end 

DebugTrace = function(msg)
    if Config.EnableDebug then
        print('[919-Admin Debug] ' .. msg)
    end
end