SendPlayerBack = {}
SendBack = {}
SpectatingPlayer = {}
Frozen = {}

RegisterServerEvent('919-admin:server:SetPosition', function(playerId, x, y, z)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then 
        SetEntityCoords(GetPlayerPed(playerId), x, y, z) 
    end
end)

RegisterServerEvent('919-admin:server:KillPlayer', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'kill') then
        TriggerClientEvent('919-admin:client:KillPlayer', playerId)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.killed') .. ' ' .. GetPlayerName(playerId) .. '.')
        TriggerEvent('919-admin:server:Log', 'adminactions', 'KICK', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.killed') .. ' **' .. GetPlayerName(playerId) .. '** [' .. playerId .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:SavePlayer', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'savedata') then
        if Config.Framework == 'qbcore' then
            local TargetPlayer = QBCore.Functions.GetPlayer(playerId)
            TargetPlayer.Functions.Save()
        elseif Config.Framework == 'qbox' then
            exports.qbx_core:Save(playerId)
        end
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.savedToDB', { value = GetPlayerName(playerId) }))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'KICK', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '**' .. Lang:t('alerts.savedToDB', { value = GetPlayerName(playerId) }) .. '** [' .. playerId .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:RepairPlayerVehicle', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'repairplayervehicle') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.repairedPlayerVehicle'))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'KICK', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.repairedPlayerVehicle') .. '** [' .. playerId .. ']', false)
        TriggerClientEvent('919-admin:client:RepairVehicle', playerId)
    end
end)

RegisterServerEvent('919-admin:server:KickPlayer', function(playerId, reason)
    local src = source
    if AdminPanel.HasPermission(src, 'kick') then
        TriggerEvent('919-admin:server:Log', 'adminactions', 'KICK', 'red', Lang:t('alerts.kickedPlayer', { value = GetPlayerName(src), value2 = GetPlayerName(playerId), value3 = playerId, value4 = reason }), false)
        DropPlayer(playerId, Lang:t('alerts.YouBeenKicked') .. '\n' .. reason)
    end
end)

RegisterServerEvent('919-admin:server:Freeze', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'freeze') then
        if not Frozen[playerId] then
            Frozen[playerId] = true
            FreezeEntityPosition(GetPlayerPed(playerId), true)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.froze') .. ' ' .. GetPlayerName(playerId) .. '.')
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Frozen', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.froze') .. ' **' .. GetPlayerName(playerId) .. '** [' .. playerId .. ']', false)
        else
            Frozen[playerId] = false
            FreezeEntityPosition(GetPlayerPed(playerId), false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.unfroze') .. ' ' .. GetPlayerName(playerId) .. '.')
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Frozen', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** ' .. Lang:t('alerts.unfroze') .. ' **' .. GetPlayerName(playerId) .. '** [' .. playerId .. ']', false)
        end
    end
end)

RegisterServerEvent('919-admin:server:GotoPlayer', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        SendBack[src] = GetEntityCoords(GetPlayerPed(src))
        local coords = GetEntityCoords(GetPlayerPed(targetId))
        SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.teleportedTo', { value = GetPlayerName(targetId) }))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Teleport', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** teleported to **' .. GetPlayerName(targetId) .. '** [' .. targetId .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:BringPlayer', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        SendPlayerBack[targetId] = GetEntityCoords(GetPlayerPed(targetId))
        local coords = GetEntityCoords(GetPlayerPed(src))
        SetEntityCoords(GetPlayerPed(targetId), coords)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.teleportToYou', { value = GetPlayerName(targetId) }))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Teleport', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** brought **' .. GetPlayerName(targetId) .. '** [' .. targetId .. '] to them', false)
    end
end)

RegisterServerEvent('919-admin:server:SendPlayerBack', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        if SendPlayerBack[targetId] then
            SetEntityCoords(GetPlayerPed(targetId), SendPlayerBack[targetId])
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.teleportedBack', { value = GetPlayerName(targetId) }))
            SendPlayerBack[targetId] = nil
        else
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noPosition'))
        end
    end
end)

RegisterServerEvent('919-admin:server:SendBackSelf', function()
    local src = source
    if AdminPanel.HasPermission(src, 'teleport') then
        if SendBack[src] then
            SetEntityCoords(GetPlayerPed(src), SendBack[src])
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.sentSelfBack'))
            SendBack[src] = nil
        else
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noPosition'))
        end
    end
end)

RegisterNetEvent('919-admin:server:CuffPlayer', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'cuff') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.cuffed'))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Cuff Player', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** cuffed/uncuffed **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
        local targetTrigger = 'police:client:GetCuffed'
        if Config.Framework == 'esx' then targetTrigger = 'esx_policejob:handcuff' end
        TriggerClientEvent(targetTrigger, target)
    end
end)

RegisterServerEvent('919-admin:server:RevivePlayer', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'revive') then
        Config.Integrations.Revive(target)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.revived') .. ' ' .. GetPlayerName(target) .. '.')
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Player Revived', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** revived **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:ReviveAll', function()
    local src = source
    if AdminPanel.HasPermission(src, 'reviveall') then
        Config.Integrations.Revive(-1)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.revivedAll'))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Revive All', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** revived all players.', false)
    end
end)

RegisterServerEvent('919-admin:server:FeedPlayer', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'foodandwater') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.setMaxValues'))
        if Config.Framework == 'qbcore' then
            local Player = QBCore.Functions.GetPlayer(target)
            Player.Functions.SetMetaData('hunger', 100)
            Player.Functions.SetMetaData('thirst', 100)
            TriggerClientEvent('qb-hud:client:update:needs', target, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
        elseif Config.Framework == "qbox" then
            local player = exports.qbx_core:GetPlayer(target)
            player.Functions.SetMetaData('hunger', 100)
            player.Functions.SetMetaData('thirst', 100)
            TriggerClientEvent('hud:client:UpdateNeeds', player.PlayerData.source, 100, 100)
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx_status:set', target, 'hunger', 1000000)
            TriggerClientEvent('esx_status:set', target, 'thirst', 1000000)
        end
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Food & Water Max', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** fed and watered **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
    end
end)

RegisterServerEvent('919-admin:server:FireJob', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'firejob') then
        Bridge.SetPlayerJob(targetId, 'unemployed', 0)
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** fired ' .. GetPlayerName(targetId) .. ' from their job.', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
    end
end)

RegisterServerEvent('919-admin:server:FireGang', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'firegang') then
        Bridge.SetPlayerGang(targetId, 'none', 0)
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Fired From Gang', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. GetPlayerName(targetId) .. ' from their gang.', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
    end
end)

RegisterServerEvent('919-admin:server:FireJobByCitizenId', function(citizenId)
    local src = source
    if AdminPanel.HasPermission(src, 'firejob') then
        if Config.Framework == 'qbox' then
            exports.qbx_core:SetJob(citizenId, 'unemployed', 0)
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. citizenId .. ' from their job.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
            return
        end

        local targetPlayer = Bridge.GetPlayerFromCharacterIdentifier(citizenId)
        if targetPlayer then
            if Config.Framework == 'qbcore' then
                targetPlayer.Functions.SetJob('unemployed', 0)
                targetPlayer.Functions.Save()
                TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' from their job.', false)
            elseif Config.Framework == 'esx' then
                targetPlayer.setJob('unemployed', 0)
            end
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
        else -- Player is offline, so we"re going to formulate the default JSON for unemployed and set it to the offline character
            if Config.Framework == 'qbcore' then
                PlayerData = {}
                PlayerData.job = {}
                PlayerData.job.name = 'unemployed'
                PlayerData.job.label = 'Civilian'
                PlayerData.job.payment = 10
                if QBCore.Shared.ForceJobDefaultDutyAtLogin or PlayerData.job.onduty == nil then PlayerData.job.onduty = QBCore.Shared.Jobs[PlayerData.job.name].defaultDuty end
                PlayerData.job.isboss = false
                PlayerData.job.grade = {}
                PlayerData.job.grade.name = 'Freelancer'
                PlayerData.job.grade.level = 0

                MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job` = ? WHERE `citizenid` = ?', { json.encode(PlayerData.job), citizenId }, function(rowsAffected)
                    if rowsAffected ~= 0 and rowsAffected ~= nil then
                        TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed (OFFLINE) Citizen ID ' .. citizenId .. ' from their job.', false)
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
                    end
                end)
            elseif Config.Framework == 'esx' then
                MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job` = ? WHERE `identifier` = ?', { 'unemployed', citizenId }, function(rowsAffected)
                    if rowsAffected ~= 0 and rowsAffected ~= nil then
                        TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed (OFFLINE) Citizen ID ' .. citizenId .. ' from their job.', false)
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedJob'))
                    end
                end)
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:FireGangByCitizenId', function(citizenId)
    local src = source
    if AdminPanel.HasPermission(src, 'firegang') then
        if Config.Framework == 'qbox' then
            exports.qbx_core:SetGang(citizenId, 'unemployed', 0)
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. citizenId .. ' from their gang.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
            return
        end

        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenId)
            if targetPlayer then
                targetPlayer.Functions.SetGang('none', 0)
                targetPlayer.Functions.Save()
                TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' from their gang.', false)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
            else -- Player is offline, so we"re going to formulate the default JSON for unemployed and set it to the offline character
                PlayerData = {}
                PlayerData.gang = {}
                PlayerData.gang.name = 'none'
                PlayerData.gang.label = 'No Gang Affiliaton'
                PlayerData.gang.isboss = false
                PlayerData.gang.grade = {}
                PlayerData.gang.grade.name = 'none'
                PlayerData.gang.grade.level = 0
                MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `gang` = ? WHERE `citizenid` = ?', { json.encode(PlayerData.gang), citizenId }, function(rowsAffected)
                    if rowsAffected ~= 0 and rowsAffected ~= nil then
                        TriggerEvent('919-admin:server:Log', 'adminactions', 'Fired From Gang', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed (OFFLINE) Citizen ID ' .. citizenId .. ' from their gang.', false)
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.firedGang'))
                    end
                end)
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:SetGangGradeByCitizenId', function(citizenId, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setgang') then
        if Config.Framework == 'qbox' then
            local playerData = exports.qbx_core:GetPlayerByCitizenId(citizenId) or exports.qbx_core:GetOfflinePlayer(citizenId)
            exports.qbx_core:SetJob(citizenId, playerData.job.name, grade)
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Gang Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set gang grade of ' .. citizenId .. ' to ' .. grade .. '.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gangGradeSet', { value = grade }))
            return
        end

        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenId)
            if targetPlayer then
                if QBCore.Shared.Gangs[targetPlayer.PlayerData.gang.name].grades[grade] ~= nil then
                    targetPlayer.Functions.SetGang(targetPlayer.PlayerData.gang.name, grade)
                    targetPlayer.Functions.Save()
                    TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Gang Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set gang grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set gang grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidgangGrade'))
                end
            else
                local result = MySQL.query.await('SELECT `gang` FROM ' .. Config.DB.CharactersTable .. ' WHERE citizenid = ?', { citizenId })
                if result ~= nil then
                    local gangInfo = json.decode(result[1].gang)
                    if gangInfo.grade ~= nil then
                        if QBCore.Shared.Gangs[gangInfo.name].grades[grade] ~= nil then
                            gangInfo.isboss = (QBCore.Shared.Gangs[gangInfo.name].grades[grade].isboss and true or false) -- We dont need a "payment" here because gangs dont have a salary.
                            gangInfo.grade.name = QBCore.Shared.Gangs[gangInfo.name].grades[grade].name -- We only need isboss, grade.name information from framework
                            gangInfo.grade.level = tonumber(grade)
                            MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `gang` = ? WHERE `citizenid` = ?', { json.encode(gangInfo), citizenId }, function(rowsAffected)
                                if rowsAffected ~= 0 and rowsAffected ~= nil then
                                    TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Gang Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set citizen id ' .. citizenId .. ' to gang grade ' .. grade .. ' (OFFLINE)', false)
                                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gangGradeSet', { value = grade }))
                                else
                                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError'))
                                end
                            end)
                        else
                            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidgangGrade'))
                        end
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError2'))
                    end
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError3'))
                end
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:SetJobGradeByCitizenId', function(citizenId, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setjob') then
        if Config.Framework == 'qbox' then
            local playerData = exports.qbx_core:GetPlayerByCitizenId(citizenId) or exports.qbx_core:GetOfflinePlayer(citizenId)
            exports.qbx_core:SetJob(citizenId, playerData.PlayerData.job.name, grade)
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set job grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set job grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
            return
        end

        local targetPlayer = Bridge.GetPlayerFromCharacterIdentifier(citizenId)
        if targetPlayer then
            if Config.Framework == 'qbcore' then
                if QBCore.Shared.Jobs[targetPlayer.PlayerData.job.name].grades[grade] ~= nil then
                    targetPlayer.Functions.SetJob(targetPlayer.PlayerData.job.name, grade)
                    targetPlayer.Functions.Save()
                    TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set job grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set job grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
                else
                    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> Invalid job grade.')
                end
            elseif Config.Framework == 'esx' then
                targetPlayer.setJob(targetPlayer.getJob().name, grade)
                TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set job grade of ' .. GetPlayerName(targetPlayer.PlayerData.source) .. ' to ' .. grade .. '.', false)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> Set job grade of ' .. GetPlayerName(targetId) .. ' to ' .. grade)
            end
        else
            local result = nil
            if Config.Framework == 'qbcore' then
                result = MySQL.query.await('SELECT `job` FROM `' .. Config.DB.CharactersTable .. '` WHERE citizenid = ?', { citizenId })
            elseif Config.Framework == 'esx' then
                result = MySQL.query.await('SELECT `job` FROM `' .. Config.DB.CharactersTable .. '` WHERE identifier = ?', { citizenId })
            end
            if result ~= nil then
                jobInfo = result[1].job
                if Config.Framework == 'qbcore' then
                    jobInfo = json.decode(result[1].job)
                    if QBCore.Shared.Jobs[jobInfo.name].grades[grade] ~= nil then
                        jobInfo.payment = QBCore.Shared.Jobs[jobInfo.name].grades[grade].payment
                        jobInfo.isboss = (QBCore.Shared.Jobs[jobInfo.name].grades[grade].isboss and true or false)
                        jobInfo.grade.name = QBCore.Shared.Jobs[jobInfo.name].grades[grade].name
                        jobInfo.grade.level = tonumber(grade)
                        MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job` = ? WHERE `citizenid` = ?', { json.encode(jobInfo), citizenId }, function(rowsAffected)
                            if rowsAffected ~= 0 and rowsAffected ~= nil then
                                TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set citizen id ' .. citizenId .. ' to job grade ' .. grade .. ' (OFFLINE)', false)
                                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobGradeSet', { value = grade }))
                            else
                                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError'))
                            end
                        end)
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidJobGrade'))
                    end
                elseif Config.Framework == 'esx' then
                    MySQL.update('UPDATE `' .. Config.DB.CharactersTable .. '` SET `job_grade` = ? WHERE `identifier` = ?', { jobInfo.grade.level, citizenId }, function(rowsAffected)
                        if rowsAffected ~= 0 and rowsAffected ~= nil then
                            TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job Grade', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set citizen id ' .. citizenId .. ' to job grade ' .. grade .. ' (OFFLINE)', false)
                            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobGradeSet', { value = grade }))
                        else
                            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError'))
                        end
                    end)
                end
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.databaseError3'))
            end
        end
    end
end)

RegisterServerEvent('919-admin:server:AddVehicleToGarage', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'savecar') then TriggerClientEvent('919-admin:client:SaveCar', targetId, src) end
end)

RegisterServerEvent('919-admin:server:OpenSkinMenu', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'clothing') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', source, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.skinMenuOpened', { value = GetPlayerName(targetId) }))
        if Config.Integrations.Clothing then Config.Integrations.Clothing(targetId) end
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Skin Menu', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** opened skin menu for ' .. GetPlayerName(targetId), false)
    end
end)

RegisterServerEvent('919-admin:server:SetJob', function(targetId, job, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setjob') then
        Bridge.SetPlayerJob(targetId, job, grade)
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Job', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set the job of ' .. GetPlayerName(targetId) .. ' to ' .. job .. ' (' .. grade .. ')', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobSet', { value = job, value2 = grade }))
    end
end)

RegisterServerEvent('919-admin:server:SetGang', function(targetId, gang, grade)
    local src = source
    if AdminPanel.HasPermission(src, 'setgang') then
        Bridge.SetPlayerGang(targetId, gang, grade)
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Set Gang', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** set the gang of ' .. GetPlayerName(targetId) .. ' to ' .. gang .. ' (' .. grade .. ')', false)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.jobSet', { value = gang, value2 = grade }))
    end
end)

RegisterServerEvent('919-admin:server:RelieveStress', function(target)
    local src = source
    if AdminPanel.HasPermission(src, 'relievestress') then
        if Config.Framework == 'qbcore' then
            local Player = QBCore.Functions.GetPlayer(target)
            Player.Functions.SetMetaData('stress', 0)
        elseif Config.Framework == 'qbox' then
            local player = exports.qbx_core:GetPlayer(target)
            player.Functions.SetMetaData('stress', 0)
        end
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.stressRelieved') .. ' ' .. GetPlayerName(target) .. '.')
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Stress Relief', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** relieved stress for **' .. GetPlayerName(target) .. '** [' .. target .. ']', false)
    end
end)

RegisterNetEvent('919-admin:server:SetPedModel', function(player, model)
    local src = source
    if AdminPanel.HasPermission(src, 'setpedmodel') then
        TriggerClientEvent('919-admin:client:SetPedModel', player, model)
    end
end)

RegisterNetEvent('919-admin:server:RequestSpectate', function(player)
    local src = source
    if AdminPanel.HasPermission(src, 'spectate') then
        local coords = GetEntityCoords(GetPlayerPed(player))
        SpectatingPlayer[src] = player
        TriggerClientEvent('919-admin:client:RequestSpectate', src, player, coords, GetPlayerName(player))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Spectate', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** started spectating **' .. GetPlayerName(player) .. '** [' .. player .. ']', false)
    end
end)

RegisterNetEvent('919-admin:server:StopSpectate', function()
    local src = source
    if AdminPanel.HasPermission(src, 'spectate') and SpectatingPlayer[src] then
        local previousTarget = SpectatingPlayer[src]
        SpectatingPlayer[src] = nil
        TriggerClientEvent('919-admin:client:RequestSpectate', src, nil, nil, nil)
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Spectate', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** stopped spectating **' .. GetPlayerName(previousTarget) .. '** [' .. previousTarget .. ']', false)
    end
end)

RegisterNetEvent('919-admin:server:requestNextSpectate', function()
    local src = source
    if AdminPanel.HasPermission(src, 'spectate') and SpectatingPlayer[src] then
        local allPlayers = GetPlayers()
        
        local playerIds = {}
        for _, playerId in pairs(allPlayers) do
            local id = tonumber(playerId)
            if id and id ~= src then
                playerIds[#playerIds + 1] = id
            end
        end
        table.sort(playerIds)
        
        if #playerIds == 0 then
            Bridge.Notify(src, Lang:t('notify.noPlayerFound'), 'error')
            return
        end
        
        local currentIndex = nil
        for i, playerId in ipairs(playerIds) do
            if playerId == SpectatingPlayer[src] then
                currentIndex = i
                break
            end
        end
        
        if not currentIndex then
            currentIndex = 0
        end
        
        local nextIndex = currentIndex + 1
        if nextIndex > #playerIds then
            nextIndex = 1
        end
        
        local nextPlayer = playerIds[nextIndex]
        local coords = GetEntityCoords(GetPlayerPed(nextPlayer))
        
        SpectatingPlayer[src] = nextPlayer
        TriggerClientEvent('919-admin:client:RequestSpectate', src, nextPlayer, coords, GetPlayerName(nextPlayer))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Spectate', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** started spectating **' .. GetPlayerName(nextPlayer) .. '** [' .. nextPlayer .. ']', false)
    end
end)

RegisterNetEvent('919-admin:server:requestPrevSpectate', function()
    local src = source
    if AdminPanel.HasPermission(src, 'spectate') and SpectatingPlayer[src] then
        local allPlayers = GetPlayers()
        
        local playerIds = {}
        for _, playerId in pairs(allPlayers) do
            local id = tonumber(playerId)
            if id and id ~= src then
                playerIds[#playerIds + 1] = id
            end
        end
        table.sort(playerIds)
        
        if #playerIds == 0 then
            Bridge.Notify(src, Lang:t('notify.noPlayerFound'), 'error')
            return
        end

        local currentIndex = nil
        for i, playerId in ipairs(playerIds) do
            if playerId == SpectatingPlayer[src] then
                currentIndex = i
                break
            end
        end

        if not currentIndex then
            currentIndex = #playerIds + 1
        end
        
        local prevIndex = currentIndex - 1
        if prevIndex < 1 then
            prevIndex = #playerIds
        end
        
        local prevPlayer = playerIds[prevIndex]
        local coords = GetEntityCoords(GetPlayerPed(prevPlayer))
        
        SpectatingPlayer[src] = prevPlayer
        TriggerClientEvent('919-admin:client:RequestSpectate', src, prevPlayer, coords, GetPlayerName(prevPlayer))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Spectate', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** started spectating **' .. GetPlayerName(prevPlayer) .. '** [' .. prevPlayer .. ']', false)
    end
end)

RegisterNetEvent('919-admin:server:ScreenshotSubmit', function(playerId)
    local src = source
    if AdminPanel.HasPermission(src, 'screenshot') then
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.screenshotting'))
        local ids = ExtractIdentifiers(playerId)
        if GetResourceState('discord-screenshot') ~= 'started' then
            print('^1[ERROR]^7 discord-screenshot resource is not started. Please make sure it is started and running.')
            return
        end
        exports['discord-screenshot']:requestCustomClientScreenshotUploadToDiscord(playerId, Config.ScreenshotWebhook, { encoding = 'png', quality = 1 }, {
            username = '919ADMIN SS Bot', avatar_url = '', content = '', embeds = {
                {
                    color = 16711680, author = { name = '[919ADMIN SS Bot]', icon_url = '' }, title = 'Requested Screenshot',
                    description = '**__Player Identifiers:__** \n\n' .. '**Server ID:** `' .. playerId .. '`\n\n' .. '**Username:** `' .. GetPlayerName(playerId) .. '`\n\n' .. '**IP:** `' .. ids.ip .. '`\n\n' .. '**Steam:** `' .. ids.steam .. '`\n\n' .. '**License:** `' .. ids.license .. '`\n\n' .. '**Xbl:** `' .. ids.xbl .. '`\n\n' .. '**Live:** `' .. ids.live .. '`\n\n' .. '**Discord:** `' .. ids.discord .. '`\n\n',
                    footer = { text = '[' .. playerId .. ']' .. GetPlayerName(playerId) }
                }
            }
        });
    end
end)

function ExtractIdentifiers(src)
    local identifiers = { steam = '', ip = '', discord = '', license = '', xbl = '', live = '' }

    -- Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        -- Convert it to a nice table.
        if string.find(id, 'steam') then
            identifiers.steam = id
        elseif string.find(id, 'ip') then
            identifiers.ip = id
        elseif string.find(id, 'discord') then
            identifiers.discord = id
        elseif string.find(id, 'license') then
            identifiers.license = id
        elseif string.find(id, 'xbl') then
            identifiers.xbl = id
        elseif string.find(id, 'live') then
            identifiers.live = id
        end
    end

    return identifiers
end

RegisterNetEvent('919-admin:server:SaveCar', function(mods, modelname, hash, plate, senderId)
    local src = source
    local Player = Bridge.GetPlayer(src)
    local result = MySQL.query.await('SELECT plate FROM `' .. Config.DB.VehiclesTable .. '` WHERE plate = ?', { plate })
    if result[1] == nil then
        if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            MySQL.insert('INSERT INTO `' .. Config.DB.VehiclesTable .. '` (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
                         { Player.PlayerData.license, Player.PlayerData.citizenid, modelname, hash, json.encode(mods), plate, 0 })
        else
            MySQL.insert('INSERT INTO `' .. Config.DB.VehiclesTable .. '` (owner, plate, vehicle) VALUES (?, ?, ?)',
                         { Player.getIdentifier(), plate, json.encode(mods) })
        end
        Bridge.Notify(src, Lang:t('notify.VehicleYours'), 'success')
        if senderId then
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Admin Car', 'red', '**STAFF MEMBER ' .. GetPlayerName(senderId) .. '** has added a ' .. modelname .. ' (' .. plate .. ') to the garage of ' .. GetPlayerName(src), false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', senderId, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.addedVehicle', { value = modelname }))
        end
    else
        if senderId then TriggerClientEvent('919-admin:client:ShowPanelAlert', senderId, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.playerOwnsAlready')) end
        Bridge.Notify(src, Lang:t('notify.vehicleAlreadyYours'), 'error')
    end
end)

RegisterServerEvent('919-admin:server:DeleteCharacter', function(citizenId)
    local src = source
    if AdminPanel.HasPermission(src, 'deletecharacter') then
        MySQL.query('SELECT * FROM  `' .. Config.DB.CharactersTable .. '` WHERE citizenid = ? LIMIT 1', { citizenId }, function(result)
            if result[1] then
                MySQL.query('DELETE FROM `' .. Config.DB.CharactersTable .. '` WHERE citizenid = ? LIMIT 1', { citizenId }, function(rowsAffected)
                    if rowsAffected then
                        local charInfo = json.decode(result[1].charinfo) or { firstname = result[1].firstname, lastname = result[1].lastname }
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.deletedCharacter'))
                        TriggerEvent('919-admin:server:Log', 'adminactions', 'Character Deleted', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** deleted ' .. result[1].name .. '\'s character ' .. charInfo.firstname .. ' ' .. charInfo.lastname, false)
                    else
                        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noRowsDeleted'))
                    end
                    local results = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '`')
                    TriggerClientEvent('919-admin:client:ReceiveCharacters', src, results)
                end)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.cantFindLicense'))
            end
        end)
    end
end)

RegisterServerEvent('919-admin:server:ClearInventory', function(targetId)
    local src = source
    if AdminPanel.HasPermission(src, 'clearinventory') then
        Bridge.ClearPlayerInventory(targetId)
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.clearedInventory'))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Inventory Cleared', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** cleared inventory for **' .. GetPlayerName(targetId) .. '**', false)
    end
end)

RegisterNetEvent('919-Admin:server:OpenInventory', function(target) 
    local src = source
    if AdminPanel.HasPermission(src, 'openinventory') then
        TriggerClientEvent('inventory:client:RobPlayer:Admin', target, tonumber(target)) 
    end
end) 

AdminPanel.CreateCallback('919-admin:server:GetPlayerPositions', function(source, cb)
    local PlayerPositions = {}
    
    -- Use GetPlayers() which is more efficient than iterating all possible IDs
    for _, playerId in pairs(GetPlayers()) do 
        playerId = tonumber(playerId)
        if playerId and playerId > 0 then
            local playerPed = GetPlayerPed(playerId)
            if playerPed and playerPed > 0 then
                -- Use cached player name from ServerInformation.PlayerList if available
                local playerName = GetPlayerName(playerId)
                local cachedPlayer = nil
                
                -- Try to get character name from cache first
                if ServerInformation.PlayerList then
                    for _, player in pairs(ServerInformation.PlayerList) do
                        if player.id == playerId then
                            cachedPlayer = player
                            break
                        end
                    end
                end
                
                if cachedPlayer and cachedPlayer.charname then
                    playerName = cachedPlayer.charname .. ' | (' .. playerName .. ')'
                end
                
                table.insert(PlayerPositions, { 
                    pos = GetEntityCoords(playerPed), 
                    name = playerName, 
                    id = playerId 
                })
            end
        end
    end
    
    cb(PlayerPositions)
end)