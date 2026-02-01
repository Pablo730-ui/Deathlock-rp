AdminPanel.TriggerClientCallback = function(name, source, cb, ...)
    AdminPanel.ClientCallbacks[name] = cb
    TriggerClientEvent('AdminPanel:Client:TriggerClientCallback', source, name, ...)
end

AdminPanel.CreateCallback = function(name, cb) 
    AdminPanel.ServerCallbacks[name] = cb 
end

AdminPanel.TriggerCallback = function(name, source, cb, ...)
    if not AdminPanel.ServerCallbacks[name] then return end
    AdminPanel.ServerCallbacks[name](source, cb, ...)
end

RegisterNetEvent('AdminPanel:Server:TriggerClientCallback', function(name, ...)
    if AdminPanel.ClientCallbacks[name] then
        AdminPanel.ClientCallbacks[name](...)
        AdminPanel.ClientCallbacks[name] = nil
    end
end)

RegisterNetEvent('AdminPanel:Server:TriggerCallback', function(name, ...)
    local src = source
    AdminPanel.TriggerCallback(name, src, function(...) 
        TriggerClientEvent('AdminPanel:Client:TriggerCallback', src, name, ...) 
    end, ...)
end)

AdminPanel.CreateCallback('919-admin:server:GetPlayerCountHistory', function(source, cb) 
    cb(ServerInformation.PlayerCountHistory) 
end)

AdminPanel.CreateCallback('919-Admin:GetPlayerName', function(source, cb, id)
    -- First try to get from cached player list to avoid database calls
    local cachedPlayer = nil
    for _, player in pairs(ServerInformation.PlayerList or {}) do
        if player.id == id then
            cachedPlayer = player
            break
        end
    end
    
    if cachedPlayer and cachedPlayer.charname then
        cb(cachedPlayer.charname)
    else
        -- Fallback to framework call only if not in cache
        local result = Bridge.GetCharacterData(id)
        if result and result.CharacterName then
            cb(result.CharacterName)
        else
            -- Ultimate fallback to simple FiveM name
            cb(GetPlayerName(id) or 'Unknown')
        end
    end
end)

AdminPanel.CreateCallback('919-admin:server:Refresh', function(source, cb)
    if AdminPanel.HasPermission(source, 'adminmenu') then
        local playerList = {}
        for k, v in ipairs(GetPlayers()) do
            v = tonumber(v)
            local identifiers, steamIdentifier = GetPlayerIdentifiers(v)
            for _, v2 in pairs(identifiers) do
                if string.find(v2, 'license:') then steamIdentifier = v2 end
                if not Config.ShowIPInIdentifiers then 
                    if string.find(v2, 'ip:') then identifiers[_] = nil end 
                end
            end

            local PlayerData = Bridge.GetCharacterData(v)
            table.insert(playerList, {
                id = v, 
                name = GetPlayerName(v), 
                identifiers = json.encode(identifiers), 
                role = PlayerData.Role, 
                bank = '$' .. comma_value(PlayerData.Bank), 
                cash = '$' .. comma_value(PlayerData.Cash), 
                steamid = steamIdentifier,
                citizenid = PlayerData.CharacterIdentifier, 
                job = PlayerData.Job, 
                rank = PlayerData.Rank, 
                health = GetEntityHealth(GetPlayerPed(v)) - 100, 
                armor = GetPedArmour(GetPlayerPed(v)),
                jobboss = PlayerData.IsBoss and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>',
                duty = PlayerData.OnDuty and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>', 
                gang = PlayerData.GangLabel, 
                gangrank = PlayerData.GangRank,
                gangboss = PlayerData.GangIsBoss and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>', 
                charname = PlayerData.CharacterName
            })
        end
        cb(playerList)
    end
end)

local PermissionLogMap = {
    playernames = { title = 'Player Names Toggled', color = 'red', action = 'toggled their player names.' },
    playerblips = { title = 'Player Blips Toggled', color = 'red', action = 'toggled their player blips.' },
    invisibility = { title = 'Invisibility', color = 'red', action = 'toggled their invisibility.' },
    forceradar = { title = 'Force Radar', color = 'red', action = 'toggled their forceradar.' },
    fastrun = { title = 'Fast Run', color = 'red', action = 'toggled their fastrun.' },
    godmode = { title = 'Godmode', color = 'red', action = 'toggled their godmode.' },
    setmedriver = { title = 'Set Driver', color = 'red', action = 'forced themselves to be the driver of the closest vehicle.' },
    setmepassenger = { title = 'Set Passenger', color = 'red', action = 'forced themselves to be the passenger of the closest vehicle.' },
    clearblood = { title = 'Cleared Blood', color = 'red', action = 'cleared their blood.' },
    wetclothes = { title = 'Wet Clothes', color = 'red', action = 'made their clothes wet.' },
    dryclothes = { title = 'Dry Clothes', color = 'red', action = 'made their clothes dry.' },
    deleteclosestvehicle = { title = 'Deleted Vehicle', color = 'red', action = 'deleted the closest vehicle.' },
    deleteclosestped = { title = 'Deleted Ped', color = 'red', action = 'deleted the closest ped.' },
    deleteclosestobject = { title = 'Deleted Object', color = 'red', action = 'deleted the closest object.' },
    repairvehicle = { title = 'Repaired Vehicle', color = 'red', action = 'repaired the closest vehicle.' },
    washvehicle = { title = 'Washed Vehicle', color = 'red', action = 'washed the closest vehicle.' },
    lockvehicle = { title = 'Locked Vehicle', color = 'red', action = 'locked the closest vehicle.' },
    unlockvehicle = { title = 'Unlocked Vehicle', color = 'red', action = 'unlocked the closest vehicle.' },
    maxperformanceupgrades = { title = 'Max Performance Upgrades', color = 'red', action = 'given the closest vehicle max performance upgrades.' },
    randomvisualparts = { title = 'Random Visual Parts', color = 'red', action = 'given the closest vehicle random visual parts.' },
    fillgastank = { title = 'Fill Gas Tank', color = 'red', action = "filled the closest vehicle's gas tank." },
    superjump = { title = 'Super Jump', color = 'red', action = 'toggled their superjump.' },
    noragdoll = { title = 'No Ragdoll', color = 'red', action = 'toggled their no-ragdoll.' },
    infinitestam = { title = 'Infinite Stamina', color = 'red', action = 'toggled their infinite stamina.' }
}

AdminPanel.CreateCallback('919-admin:server:HasPermission', function(source, cb, permission)
    if AdminPanel.HasPermissionEx(source, permission) then
        local entry = PermissionLogMap[permission]
        if entry then
            local playerName = GetPlayerName(source)
            local message = '**STAFF MEMBER ' .. playerName .. '** has ' .. entry.action
            TriggerEvent('919-admin:server:Log', 'adminactions', entry.title, entry.color, message, false)
        end
        return cb(true)
    end
    return cb(false)
end)