RegisterNetEvent('919-admin:server:BanPlayer', function(player, time, reason, citizenid)
    local src = source
    if AdminPanel.HasPermission(src, 'ban') then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then banTime = 2147483647 end
        local timeTable = os.date('*t', banTime)
        
        if player ~= 'OFFLINE' then
            AdminPanel.OnlineBanPlayer(src, player, time, timeTable, reason)
        else
            if citizenid ~= nil then
                local result = nil
                if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then 
                    result = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `citizenid` = ?', { citizenid })
                else
                    result = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `identifier` = ?', { citizenid })
                end
                
                if result[1] then
                    local online = false
                    for k, v in pairs(GetPlayers()) do
                        v = tonumber(v)
                        if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                            if GetPlayerIdentifierByType(v, 'license') == result[1].license then
                                AdminPanel.OnlineBanPlayer(src, v, time, timeTable, reason)
                                online = true
                                break
                            end
                        else
                            if ESX.GetIdentifier(v) == result[1].Identifier then
                                AdminPanel.OnlineBanPlayer(src, v, time, timeTable, reason)
                                online = true
                                break
                            end
                        end
                    end

                    local name = 'Unknown'
                    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                        name = result[1].name
                    else
                        name = result[1].firstname .. ' ' .. result[1].lastname
                    end

                    local license = nil
                    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                        license = result[1].license
                    else
                        license = 'license:' .. string.match(result[1].identifier, ":(.+)")
                    end
                    
                    if not online then
                        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', { 
                            name, 
                            license, 
                            '', 
                            '', 
                            reason, 
                            banTime, 
                            GetPlayerName(src) 
                        })
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', 'Banned ' .. (result[1].name or 'Unknown') .. ' (OFFLINE) for ' .. (time / 60 / 60) .. ' hours.')
                        TriggerEvent('919-admin:server:Log', 'adminactions', 'Player Banned', 'red', string.format('%s was banned by %s for %s (%s hours)', result[1].name or 'Unknown', GetPlayerName(src), reason, time / 60 / 60), false)
                    end
                else
                    DebugTrace('Offline ban citizenid had no results. CitizenID: ' .. citizenid)
                end
            else
                DebugTrace('Tried to ban offline but citizenid was invalid. Scripting error.')
            end
        end
    end
end)

local function onPlayerConnecting(name, _, deferrals)
    local src = source --[[@as string]]
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    local discord = GetPlayerIdentifierByType(src, 'discord')

    deferrals.defer()
    Wait(0)

    local result = MySQL.query.await('SELECT * FROM `bans` WHERE (`license` = ? OR `discord` = ?) AND `expire` > ?', { license, discord, os.time() })
    if result[1] then
        if result[1].expire >= 2147483647 then
            deferrals.done(Lang:t('alerts.bannedPermanent', { value = result[1].reason, value2 = result[1].bannedby }))
            return
        else
            local timeTable = os.date('*t', result[1].expire)
            deferrals.done(Lang:t('alerts.bannedTemp', { 
                value = result[1].reason, 
                value2 = timeTable['day'], 
                value3 = timeTable['month'], 
                value4 = timeTable['year'], 
                value5 = timeTable['hour'], 
                value6 = timeTable['min'] 
            }))
            return
        end
    end

    deferrals.done()
end
AddEventHandler('playerConnecting', onPlayerConnecting)

AdminPanel.OnlineBanPlayer = function(source, player, time, timeTable, reason)
    local src = source
    local time = tonumber(time)
    local banTime = tonumber(os.time() + time)
    if banTime >= 2147483647 then banTime = 2147483647 end
    if not GetPlayerName(player) then return warn('tried to online ban a player who is no longer connected') end
    
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(player), 
        GetPlayerIdentifierByType(player, 'license2') or GetPlayerIdentifierByType(player, 'license'), 
        GetPlayerIdentifierByType(player, 'discord'), 
        GetPlayerIdentifierByType(player, 'ip'), 
        reason, 
        banTime, 
        GetPlayerName(src)
    })

    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', 'Banned ' .. GetPlayerName(player) .. ' for ' .. (time / 60 / 60) .. ' hours.')
    TriggerEvent('919-admin:server:Log', 'adminactions', 'Player Banned', 'red', string.format('%s was banned by %s for %s (%s hours)', GetPlayerName(player), GetPlayerName(src), reason, time / 60 / 60), false)
    
    if banTime >= 2147483647 then
        DropPlayer(player, Lang:t('alerts.bannedPermanent', { value = reason }))
    else
        DropPlayer(player, Lang:t('alerts.bannedTemp', { 
            value = reason, 
            value2 = timeTable['day'], 
            value3 = timeTable['month'], 
            value4 = timeTable['year'], 
            value5 = timeTable['hour'], 
            value6 = timeTable['min']
        }))
    end
end

AdminPanel.OnlineBanPlayerFromDiscord = function(player, time, reason)
    local time = tonumber(time)
    local banTime = tonumber(os.time() + time)
    local timeTable = os.date('*t', banTime)
    if banTime > 2147483647 then banTime = 2147483647 end

    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(player), 
        GetPlayerIdentifierByType(player, 'license2') or GetPlayerIdentifierByType(player, 'license'), 
        GetPlayerIdentifierByType(player, 'discord'), 
        GetPlayerIdentifierByType(player, 'ip'), 
        reason, 
        banTime, 
        'DISCORD COMMAND'
    })
    
    TriggerEvent('919-admin:server:Log', 'adminactions', 'Player Banned', 'red', string.format('%s was banned by discord admin command for %s (%s hours)', GetPlayerName(player), reason, time / 60 / 60), false)
    
    if banTime >= 2147483647 then
        DropPlayer(player, Lang:t('alerts.bannedPermanent', { value = reason }))
    else
        DropPlayer(player, Lang:t('alerts.bannedTemp', { 
            value = reason, 
            value2 = timeTable['day'], 
            value3 = timeTable['month'], 
            value4 = timeTable['year'], 
            value5 = timeTable['hour'], 
            value6 = timeTable['min'] 
        }))
    end
end

RegisterServerEvent('919-admin:server:UnbanPlayer', function(license)
    local src = source
    if AdminPanel.HasPermission(src, 'unban') then
        MySQL.query('SELECT * FROM `bans` WHERE license = ? LIMIT 1', { license }, function(result)
            if result[1] then
                MySQL.query('DELETE FROM `bans` WHERE license = ? LIMIT 1', { license }, function(rowsAffected)
                    if rowsAffected then
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.unbanned'))
                        TriggerEvent('919-admin:server:Log', 'adminactions', 'Player Unbanned', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** unbanned ' .. result[1].name, false)
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noRowsDeleted'))
                    end
                    local results = MySQL.query.await('SELECT * FROM `bans`')
                    local BansInfo = {}
                    for k1, v1 in ipairs(results) do table.insert(BansInfo, { ID = v1.id, Name = v1.name, License = v1.license, Discord = v1.discord, IP = v1.ip, Reason = v1.reason, Expire = v1.expire, BannedBy = v1.bannedby }) end
                    TriggerClientEvent('919-admin:client:ReceiveBansInfo', src, BansInfo)
                end)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.cantFindLicense'))
            end
        end)
    end
end)

RegisterNetEvent('919-admin:server:WarnPlayer', function(player, reason, citizenid)
    local src = source
    if AdminPanel.HasPermission(src, 'warn') then
        if player ~= 'OFFLINE' then
            AdminPanel.OnlineWarnPlayer(src, player, reason)
        else
            if citizenid ~= nil then
                local result = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `citizenid` = ?', { citizenid })
                if result[1] then
                    local online = false
                    for k, v in pairs(GetPlayers()) do
                        v = tonumber(v)
                        if Config.Framework == 'qbcore' then
                            if QBCore.Functions.GetIdentifier(v, 'license') == result[1].license then
                                AdminPanel.OnlineWarnPlayer(src, v, reason)
                                online = true
                                break
                            end
                        elseif Config.Framework == 'qbox' then
                            if GetPlayerIdentifierByType(v, 'license') == result[1].license then
                                AdminPanel.OnlineWarnPlayer(src, v, reason)
                                online = true
                                break
                            end
                        else
                            if ESX.GetIdentifier(player) == result[1].Identifier then
                                AdminPanel.OnlineWarnPlayer(src, v, reason)
                                online = true
                                break
                            end
                        end
                    end
                    if not online then
                        MySQL.insert('INSERT INTO warns (name, license, reason, warnedby) VALUES (?, ?, ?, ?)', { result[1].name, result[1].license, reason, GetPlayerName(src) })
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.warnedPlayerOffline', { value = result[1].name }))
                        TriggerEvent('919-admin:server:Log', 'warns', 'Player Warned', 'red', string.format('%s was warned by %s for %s', result[1].name, GetPlayerName(src), reason), false)
                    end
                else
                    DebugTrace('Offline warning citizenid had no results. CitizenID: ' .. citizenid)
                end
            else
                DebugTrace('Tried to warn offline but citizenid was invalid. Scripting error.')
            end
        end
    end
end)

AdminPanel.OnlineWarnPlayer = function(source, player, reason)
    local src = source
    local identifier = nil
    if Config.Framework == 'qbcore' then
        identifier = QBCore.Functions.GetIdentifier(player, 'license')
    elseif Config.Framework == 'qbox' then
        identifier = GetPlayerIdentifierByType(player, 'license')
    else
        identifier = ESX.GetIdentifier(player)
    end

    MySQL.insert('INSERT INTO warns (name, license, reason, warnedby) VALUES (?, ?, ?, ?)', { GetPlayerName(player), identifier, reason, GetPlayerName(src) })
    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.warnedPlayerOnline', { value = GetPlayerName(player) }))
    TriggerEvent('919-admin:server:Log', 'warns', 'Player Warned', 'red', string.format('%s was warned by %s for %s', GetPlayerName(player), GetPlayerName(src), reason), false)
    TriggerClientEvent('919-admin:client:WarnPlayer', player, GetPlayerName(src), reason)
end

AdminPanel.OnlineWarnPlayerFromDiscord = function(player, reason)
    local identifier = nil
    if Config.Framework == 'qbcore' then
        identifier = QBCore.Functions.GetIdentifier(player, 'license')
    elseif Config.Framework == 'qbox' then
        identifier = GetPlayerIdentifierByType(player, 'license')
    else
        identifier = ESX.GetIdentifier(player)
    end

    MySQL.insert('INSERT INTO warns (name, license, reason, warnedby) VALUES (?, ?, ?, ?)', { GetPlayerName(player), identifier, reason, 'DISCORD COMMAND' })
    TriggerEvent('919-admin:server:Log', 'warns', 'Player Warned', 'red', string.format('%s was warned by discord admin command for %s', GetPlayerName(player), reason), false)
    TriggerClientEvent('919-admin:client:WarnPlayer', player, 'DISCORD COMMAND', reason)
end

RegisterNetEvent('919-admin:server:ViewWarnings', function(player, citizenid)
    local src = source
    local license = nil
    if AdminPanel.HasPermission(src, 'checkwarns') then
        if player ~= 'OFFLINE' then
            if Config.Framework == 'qbcore' then
                license = QBCore.Functions.GetIdentifier(player, 'license')
            elseif Config.Framework == 'qbox' then
                license = GetPlayerIdentifierByType(player, 'license')
            else
                license = ESX.GetIdentifier(player)
            end
            DebugTrace('[919-admin:server:ViewWarnings] Got license (online): ' .. license)
        else
            if citizenid ~= nil then
                local result = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `citizenid` = ?', { citizenid })
                if result[1] then
                    license = result[1].license
                    DebugTrace('[919-admin:server:ViewWarnings] Got license (offline): ' .. license)
                else
                    DebugTrace('Offline view warnings citizenid had no results. CitizenID: ' .. citizenid)
                end
            else
                DebugTrace('Citizenid nil')
            end
        end
        if license ~= nil then
            local result = MySQL.query.await('SELECT * FROM `warns` WHERE `license` = ?', { license })
            if #result > 0 then
                TriggerClientEvent('919-admin:client:ViewWarnings', src, result)
                DebugTrace('[919-admin:server:ViewWarnings] Sending warnings')
            else
                if player ~= 'OFFLINE' then
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.noWarnings') .. '</strong> ' .. Lang:t('alerts.noWarningsPlayer'))
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.noWarnings') .. '</strong> ' .. Lang:t('alerts.noWarningsPlayer'))
                end
            end
        else
            DebugTrace('Citizenid nil')
        end
    end
end)