function comma_value(amount)
    local formatted = math.floor(amount)
    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if (k == 0) then break end
    end
    return formatted
end

AdminPanel.GetAllPlayers = function(cb)
    ServerInformation.StaffCount = 0

    for _, splayerId in ipairs(GetPlayers()) do
        local playerId = tonumber(splayerId) --[[@as number]]
        
        if not LoadedRole[playerId] then
            local playerRole = AdminPanel.GetPlayerGroup(playerId) or 'user'
            
            if playerRole ~= 'user' then
                ServerInformation.StaffCount = ServerInformation.StaffCount + 1
            end
            
            LoadedRole[playerId] = playerRole
            DebugTrace('[ADMIN DEBUG] Set role for player ' .. playerId .. ': ' .. playerRole)
        else
            if LoadedRole[playerId] ~= 'user' then
                ServerInformation.StaffCount = ServerInformation.StaffCount + 1
            end
        end
    end

    ServerInformation.PlayerList = Bridge.GetPlayerList()
    if cb then cb() end
end

RegisterNetEvent('919-admin:server:ClearJSON', function(type)
    local src = source
    if type == 'admin' then
        AdminPanel.AdminChat = {}
        local success, error = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/adminchat.json', json.encode(AdminPanel.AdminChat), -1)
        if not success then
            DebugTrace('[ADMINCHAT] Failed to save cleared admin chat: ' .. tostring(error))
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>ERROR:</strong> Failed to clear admin chat - file save error.')
        else
            DebugTrace('[ADMINCHAT] Successfully cleared admin chat')
        end
    elseif type == 'reports' then
        AdminPanel.Reports = {}
        local success, error = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/reports.json', json.encode(AdminPanel.Reports), -1)
        if not success then
            DebugTrace('[REPORTS] Failed to save cleared reports: ' .. tostring(error))
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>ERROR:</strong> Failed to clear reports - file save error.')
        else
            DebugTrace('[REPORTS] Successfully cleared reports')
        end
    elseif type == 'logs' then
        AdminPanel.InterceptedLogs = {}
        local success, error = pcall(SaveResourceFile, GetCurrentResourceName(), 'json/logs.json', json.encode(AdminPanel.InterceptedLogs), -1)
        if not success then
            DebugTrace('[LOGS] Failed to save cleared logs: ' .. tostring(error))
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>ERROR:</strong> Failed to clear logs - file save error.')
        else
            DebugTrace('[LOGS] Successfully cleared logs')
        end
    end
end)

RegisterServerEvent('qb-log:server:CreateLog', function(name, title, color, message, tagEveryone)
    table.insert(AdminPanel.InterceptedLogs, { 
        time = os.time(), 
        from = name, 
        title = title, 
        message = message 
    })
end) 

RegisterNetEvent('919-admin:server:Log', function(name, title, color, message, tagEveryone)
    table.insert(AdminPanel.InterceptedLogs, { 
        time = os.time(), 
        from = name, 
        title = title, 
        message = message 
    })
    
    local webHook = Config.LogsWebhook
    if not webHook or webHook == '' then return print('^2[919ADMIN]^7 No webhook found for logging admin panel actions. Please set one in the file config/config_server.lua.') end
    local embedData = { { 
        ['title'] = title, 
        ['color'] = 16743168, 
        ['footer'] = { ['text'] = os.date('%c') }, 
        ['description'] = message, 
        ['author'] = { ['name'] = '919Admin', ['icon_url'] = '' } 
    } }
    PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode({ 
        username = 'Admin log!', 
        embeds = embedData 
    }), { ['Content-Type'] = 'application/json' })
end)