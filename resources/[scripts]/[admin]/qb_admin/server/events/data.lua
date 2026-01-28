RegisterNetEvent('919-admin:server:RequestJobPageInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'jobpage') then 
        TriggerLatentClientEvent('919-admin:client:ReceiveJobPageInfo', src, 100000, Bridge.GetMasterEmployeeList()) 
    end
end)

RegisterNetEvent('919-admin:server:RequestGangPageInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'gangpage') then 
        TriggerLatentClientEvent('919-admin:client:ReceiveGangPageInfo', src, 100000, Bridge.GetMasterGangList()) 
    end
end)

RegisterNetEvent('919-admin:server:RequestBansInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'banspage') then
        local results = MySQL.query.await('SELECT * FROM `' .. Config.DB.BansTable .. '`')
        local BansInfo = {}
        for k1, v1 in ipairs(results) do 
            table.insert(BansInfo, { 
                ID = v1.id, 
                Name = v1.name, 
                License = v1.license, 
                Discord = v1.discord, 
                IP = v1.ip, 
                Reason = v1.reason, 
                Expire = v1.expire, 
                BannedBy = v1.bannedby 
            }) 
        end
        TriggerLatentClientEvent('919-admin:client:ReceiveBansInfo', src, 100000, BansInfo)
    end
end)

RegisterNetEvent('919-admin:server:RequestReportsInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'viewreports') then 
        TriggerLatentClientEvent('919-admin:client:ReceiveReportsInfo', src, 100000, AdminPanel.Reports) 
    end
end)

RegisterNetEvent('919-admin:server:RequestAdminChat', function()
    local src = source
    if AdminPanel.HasPermission(src, 'adminchat') then 
        TriggerLatentClientEvent('919-admin:client:ReceiveAdminChat', src, 100000, AdminPanel.AdminChat) 
    end
end)

RegisterNetEvent('919-admin:server:RequestVehiclesInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'vehiclesinfo') then
        local results = Bridge.GetVehiclesList()
        if results ~= nil then 
            TriggerLatentClientEvent('919-admin:client:ReceiveVehiclesInfo', src, 100000, results) 
        end
    end
end)

RegisterNetEvent('919-admin:server:RequestLeaderboardInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'leaderboardinfo') then
        local money, vehicles = Bridge.GetLeaderboardInfo()
        TriggerLatentClientEvent('919-admin:client:ReceiveLeaderboardInfo', src, 100000, money, vehicles)
    end
end)

RegisterNetEvent('919-admin:server:RequestMapInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'mapinfo') then
        local playerMapInfo = {}
        for _, strId in pairs(GetPlayers()) do
            local playerId = tonumber(strId)
            local playerData = Bridge.GetCharacterData(playerId)
            playerMapInfo[#playerMapInfo + 1] = { 
                coords = GetEntityCoords(GetPlayerPed(playerId)), 
                charname = playerData.CharacterName, 
                name = GetPlayerName(playerId), 
                id = playerId 
            }
        end
        TriggerLatentClientEvent('919-admin:client:ReceivePlayerMap', src, 100000, playerMapInfo)
    end
end)

RegisterNetEvent('919-admin:server:RequestItemsInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'itemsinfo') then
        local items = Bridge.GetItemsList()
        TriggerLatentClientEvent('919-admin:client:ReceiveItemsInfo', src, 100000, items)
    end
end)

RegisterNetEvent('919-admin:server:RequestCharacters', function()
    local src = source
    if AdminPanel.HasPermission(src, 'characterspage') then
        local results
        if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            results = MySQL.query.await('SELECT name, citizenid, license, charinfo FROM `' .. Config.DB.CharactersTable .. '`')
        else
            results = MySQL.query.await('SELECT identifier, firstname, lastname FROM `' .. Config.DB.CharactersTable .. '`')
        end
        TriggerClientEvent('919-admin:client:ReceiveCharacters', src, results)
    end
end)

RegisterNetEvent('919-admin:server:RequestResourcePageInfo', function()
    local src = source
    if AdminPanel.HasPermission(src, 'resourcepage') then
        local resourceList = {}
        for i = 0, GetNumResources(), 1 do
            local resource_name = GetResourceByFindIndex(i)
            if resource_name then
                if resource_name ~= '_cfx_internal' and resource_name ~= 'fivem' then
                    table.insert(resourceList, { resource_name, GetResourceState(resource_name) })
                end
            end
        end
        TriggerLatentClientEvent('919-admin:client:ReceiveResourcePageInfo', src, 100000, resourceList)
    end
end)

RegisterNetEvent('919-admin:server:RequestCurrentLogs', function()
    local src = source
    if AdminPanel.HasPermission(src, 'serverlogs') then 
        TriggerLatentClientEvent('919-admin:client:ReceiveCurrentLogs', src, 100000, AdminPanel.InterceptedLogs) 
    end
end)

RegisterNetEvent('919-admin:server:RequestServerMetrics', function()
    local src = source
    if AdminPanel.HasPermission(src, 'servermetrics') then
        CreateThread(function()
            local ServerMetrics = {}
            ServerMetrics.StaffCount = 0
            local results
            if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                results = MySQL.query.await('SELECT money, inventory FROM `' .. Config.DB.CharactersTable .. '`')
            else
                results = MySQL.query.await('SELECT accounts FROM `' .. Config.DB.CharactersTable .. '`')
            end
            ServerMetrics.CharacterCount = #results
            ServerMetrics.TotalCash = 0
            
            for k, v in pairs(results) do
                if v.money then
                    local money = json.decode(v.money)
                    if money then ServerMetrics.TotalCash = ServerMetrics.TotalCash + money.cash end
                elseif v.accounts then
                    local money = json.decode(v.accounts)
                    if money then 
                        for type, amount in pairs(money) do 
                            if type == 'money' then ServerMetrics.TotalCash = ServerMetrics.TotalCash + amount end 
                        end 
                    end
                end
            end
            
            ServerMetrics.TotalBank = 0
            for k, v in pairs(results) do
                if v.money then
                    local money = json.decode(v.money)
                    if money then ServerMetrics.TotalBank = ServerMetrics.TotalBank + money.bank end
                elseif v.accounts then
                    local money = json.decode(v.accounts)
                    if money then 
                        for type, amount in pairs(money) do 
                            if type == 'bank' then ServerMetrics.TotalBank = ServerMetrics.TotalBank + amount end 
                        end 
                    end
                end
            end
            
            ServerMetrics.TotalItems = 0
            for k, v in pairs(results) do
                if v.inventory then
                    local inv = json.decode(v.inventory)
                    if inv then
                        local count = 0
                        for k, v in pairs(inv) do count = count + 1 end
                        ServerMetrics.TotalItems = ServerMetrics.TotalItems + count
                    end
                end
            end
            
            results = MySQL.query.await('SELECT COUNT(*) as count FROM `' .. Config.DB.VehiclesTable .. '`')
            ServerMetrics.VehicleCount = results[1].count
            results = MySQL.query.await('SELECT COUNT(*) as count FROM `' .. Config.DB.BansTable .. '`')
            ServerMetrics.BansCount = results[1].count
            
            if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                results = MySQL.query.await('SELECT DISTINCT `license` FROM `' .. Config.DB.CharactersTable .. '`')
            elseif Config.Framework == 'esx' then
                results = MySQL.query.await('SELECT DISTINCT `identifier` FROM `' .. Config.DB.CharactersTable .. '`')
            end
            
            ServerMetrics.UniquePlayers = #results
            TriggerLatentClientEvent('919-admin:client:ReceiveServerMetrics', src, 100000, ServerMetrics)
        end)
    end
end) 