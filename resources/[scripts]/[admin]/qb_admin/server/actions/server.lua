RegisterServerEvent('919-admin:server:MessageAll', function(message)
    local src = source
    if AdminPanel.HasPermission(src, 'messageall') then
        TriggerClientEvent('chat:addMessage', -1, { args = { '^1[ADMIN MESSAGE]', message } })
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.sentMessageToAll'))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Message All', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** sent message to all: ' .. message, false)
    end
end)

RegisterServerEvent('919-admin:server:DeleteAllEntities', function(entityType)
    local src = source
    local entityTypeString = 'VEHICLES'

    if entityType == 1 then
        if not AdminPanel.HasPermission(src, 'massdv') then return end
    elseif entityType == 2 then
        entityTypeString = 'PEDS'
        if not AdminPanel.HasPermission(src, 'massdp') then return end
    end
    TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.DeletedAllEntities', { value = entityTypeString }))
    TriggerClientEvent('919-admin:client:DeleteAllEntities', -1, entityType)
end)

RegisterServerEvent('919-admin:server:SetWeather', function(weatherType)
    local src = source
    if AdminPanel.HasPermission(src, 'setweather') then
        if GetResourceState('Renewed-WeatherSync') == 'started' then
            GlobalState.weather = {
                weather = weatherType,
                time = 9999999999
            }
        elseif GetResourceState('qb-weathersync') == 'started' then
            TriggerEvent('qb-weathersync:server:setWeather', weatherType, false)
        elseif GetResourceState('weathersync') == 'started' then
            exports.weathersync:setWeather(weatherType, 0, false, false)
        end
        
        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.changedWeather', { value = weatherType }))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Weather Changed', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** changed weather to ' .. weatherType, false)
    end
end)

RegisterServerEvent('919-admin:server:SetTime', function(hour, minute)
    local src = source
    if AdminPanel.HasPermission(src, 'settime') then
        if GetResourceState('Renewed-WeatherSync') == 'started' then
            GlobalState.currentTime = {
                hour = hour,
                minute = minute
            }
        elseif GetResourceState('qb-weathersync') == 'started' then
            TriggerEvent('qb-weathersync:server:setTime', hour, minute)
        elseif GetResourceState('weathersync') == 'started' then
            exports.weathersync:setTime(0, hour, minute, 0, 0, false)
        end

        TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.setTime', { value = hour, value2 = minute }))
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Time Changed', 'red', string.format('**STAFF MEMBER %s** changed time to %02d:%02d', GetPlayerName(src), hour, minute), false)
    end
end)

RegisterNetEvent('919-admin:server:ResourceAction', function(resourceName, action)
    local src = source
    if AdminPanel.HasPermission(src, 'adminmenu') then
        if action == 'start' then
            if GetResourceState(resourceName) == 'stopped' then
                StartResource(resourceName)
                Wait(500)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.startedResource') .. '</strong> ' .. resourceName)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.error') .. '</strong>' .. Lang:t('alerts.resourceAlready'))
            end
        elseif action == 'stop' then
            if GetResourceState(resourceName) == 'started' then
                StopResource(resourceName)
                Wait(500)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.stoppedResource') .. '</strong> ' .. resourceName)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.error') .. '</strong>' .. Lang:t('alerts.resouceStoppedAlready'))
            end
        elseif action == 'restart' then
            if GetResourceState(resourceName) == 'started' then
                StopResource(resourceName)
                Wait(500)
                StartResource(resourceName)
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.RestartedResource') .. '</strong> ' .. resourceName)
            else
                TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.error') .. '</strong>' .. Lang:t('alerts.resouceRestartedAlready'))
            end
        end
        TriggerClientEvent('919-admin:client:ForceReloadResources', src)
    end
end)

RegisterServerEvent('919-admin:server:RequestVehicleSpawn', function(modelName)
    local src = source
    if AdminPanel.HasPermission(src, 'spawncar') then
        TriggerClientEvent('919Admin:Command:SpawnVehicle', src, modelName)
    end
end)

if Config.Framework == 'qbox' then
    RegisterNetEvent('919Admin:server:RequestVehicleKeys', function(vehNetId)
        local src = source
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        if GetResourceState('MrNewbVehicleKeys') == 'started' then
            exports.MrNewbVehicleKeys:GiveKeys(src, vehNetId)
        elseif GetResourceState('qbx_vehiclekeys') == 'started' then
            exports.qbx_vehiclekeys:GiveKeys(src, vehicle, false)
        end
    end)
end 