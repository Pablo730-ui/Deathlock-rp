RegisterNetEvent('919-admin:server:SendReport', function(subject, info, type)
    local src = source

    local CitizenId = Bridge.GetCharacterIdentifier(src)
    local reportCount = 0
    for k, v in pairs(AdminPanel.Reports) do 
        if v.SenderCitizenID == CitizenId then 
            reportCount = reportCount + 1 
        end 
    end
    
    if reportCount >= Config.MaxReportsPerPlayer then 
        return TriggerClientEvent('919-admin:client:ShowReportAlert', src, Lang:t('alerts.failedReportSend'), Lang:t('alerts.reportLimitReached')) 
    end
    
    TriggerClientEvent('919-admin:client:ShowReportAlert', src, Lang:t('alerts.reportSent'), 'Your report was sent to server staff!')
    local sendername = GetPlayerName(src) .. ' (' .. Bridge.GetCharacterName(src) .. ')'
    local id = 1
    for k, v in pairs(AdminPanel.Reports) do 
        id = id + 1 
    end
    
    AdminPanel.Reports[tostring(id)] = { 
        ReportID = id, 
        Claimed = nil, 
        ReportTime = os.time(), 
        SenderCitizenID = CitizenId, 
        SenderID = src, 
        SenderName = sendername, 
        Subject = subject, 
        Info = info, 
        Type = type 
    }
    
    TriggerEvent('919-admin:server:Log', 'adminactions', Lang:t('alerts.reportSent'), 'red', sendername .. '' .. Lang:t('alerts.sentFollowingReport') .. ' ' .. subject .. ' ' .. Lang:t('alerts.message') .. ' ' .. info, false)
    
    for k, v in pairs(GetPlayers()) do
        v = tonumber(v)
        if AdminPanel.HasPermissionEx(v, 'viewreports') then 
            TriggerClientEvent('919-admin:client:ShowReportAlert', v, Lang:t('alerts.newReport'), sendername .. ': ' .. subject .. ' Report ID: ' .. id) 
        end
    end
end)

RegisterNetEvent('919-admin:server:ReportReply', function(data)
    if data.name ~= nil then
        for _, playerId in ipairs(GetPlayers()) do
            playerId = tonumber(playerId)
            local charInfo = Bridge.GetCharacterData(playerId)
            if charInfo.CharacterIdentifier == data.name then
                Bridge.Notify(playerId, 'Report Reply: ' .. data.message, 'info')
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:ClaimReport', function(id)
    local src = source
    if AdminPanel.HasPermission(src, 'claimreport') then
        if AdminPanel.Reports[tostring(id)] then
            AdminPanel.Reports[tostring(id)].Claimed = GetPlayerName(src)
            TriggerEvent('919-admin:server:Log', 'adminactions', Lang:t('alerts.reportClaimed'), 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** claimed report ID ' .. id, false)
            
            for k, v in pairs(GetPlayers()) do
                v = tonumber(v)
                if AdminPanel.HasPermissionEx(v, 'viewreports') then
                    TriggerClientEvent('919-admin:client:ShowReportAlert', v, Lang:t('alerts.reportClaimed'), GetPlayerName(src) .. ' claimed Report ID ' .. id .. ' from ' .. AdminPanel.Reports[tostring(id)].SenderName .. '.')
                end
            end
            
            TriggerClientEvent('919-admin:client:ShowPanelAlert', AdminPanel.Reports[tostring(id)].SenderID, 'success', '<strong>' .. Lang:t('alerts.report') .. '</strong>' .. Lang:t('alerts.reportClaimedByStaff') .. '<strong>' .. GetPlayerName(src) .. '</strong>.')
            TriggerLatentClientEvent('919-admin:client:ReceiveReportsInfo', src, 100000, AdminPanel.Reports)
        end
    end
end)

RegisterServerEvent('919-admin:server:DeleteReport', function(id)
    local src = source
    if AdminPanel.HasPermission(src, 'deletereport') then
        if AdminPanel.Reports[tostring(id)] then
            AdminPanel.Reports[tostring(id)] = nil
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Report Deleted', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** deleted report ID ' .. id, false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>SUCCESS:</strong> Deleted Report ID ' .. id .. '.')
            TriggerLatentClientEvent('919-admin:client:ReceiveReportsInfo', src, 100000, AdminPanel.Reports)
        end
    end
end)

RegisterNetEvent('919-admin:server:AdminChatSend', function(message)
    local src = source
    if AdminPanel.HasPermission(src, 'adminchat') then
        local SenderName = GetPlayerName(src)
        local SentTime = os.time()
        table.insert(AdminPanel.AdminChat, { 
            Sender = SenderName, 
            TimeStamp = SentTime, 
            Message = message 
        })
        
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Admin chat send', 'red', SenderName .. ' Has sent the following message in the adminchat: ' .. message .. ' At: ' .. SentTime, false)

        for k, v in pairs(GetPlayers()) do
            v = tonumber(v)
            if AdminPanel.HasPermissionEx(v, 'adminchat') then 
                TriggerLatentClientEvent('919-admin:client:ReceiveAdminChat', v, 100000, AdminPanel.AdminChat) 
            end
        end
    end
end)