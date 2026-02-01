OpenPanel = function(source)
    local src = source
    local version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    
    local playerRole = LoadedRole[source]
    
    if not playerRole or playerRole == 'user' then
        playerRole = AdminPanel.GetPlayerGroup(source) or 'user'
        LoadedRole[source] = playerRole
        DebugTrace('[ADMIN DEBUG] Fresh role lookup for player: ' .. src .. ', Role: ' .. playerRole)
    else
        DebugTrace('[ADMIN DEBUG] Using cached role for player: ' .. src .. ', Role: ' .. playerRole)
    end
    
    local playerPermissions = {}
    
    if playerRole and playerRole ~= 'user' then
        playerPermissions = AdminPanel.GetPlayerPermissions(source)
        
        local permissionsArray = {}
        for permission, _ in pairs(playerPermissions) do
            table.insert(permissionsArray, permission)
        end
        playerPermissions = permissionsArray
        
        DebugTrace('[ADMIN DEBUG] Computed ' .. #playerPermissions .. ' permissions for role: ' .. playerRole)
    else
        DebugTrace('[ADMIN DEBUG] Player has no admin role, sending empty permissions')
    end
    
    AdminPanel.GetAllPlayers(function()
        TriggerClientEvent('919-admin:client:OpenMenu', source, json.encode(ServerInformation.PlayerList), ServerInformation, GetConvarInt('sv_maxclients', 32), version, playerRole, playerPermissions)
    end)
end

RegisterNetEvent('919-admin:server:RequestPanel', function()
    local src = source
    if AdminPanel.HasPermissionEx(src, 'adminmenu') then OpenPanel(src) end
end)

RegisterNetEvent('919-admin:AddPlayer', function()
    local src = source
    TriggerClientEvent('919-admin:AddPlayer', -1, src, os.time())
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerClientEvent('919-admin:RemovePlayer', -1, src)
    
    if SpectatingPlayer[src] then
        SpectatingPlayer[src] = nil
    end

    for spectatorId, spectatedId in pairs(SpectatingPlayer) do
        if spectatedId == src then
            SpectatingPlayer[spectatorId] = nil

            if GetPlayerPed(spectatorId) and GetPlayerPed(spectatorId) ~= 0 then
                TriggerClientEvent('919-admin:client:RequestSpectate', spectatorId, nil, nil, nil) -- Send nil to stop spectating
                Bridge.Notify(spectatorId, 'Spectated player disconnected', 'error')
            end
        end
    end
end)

RegisterNetEvent('919-admin:server:RefreshMenu', function(silent)
    local src = source
    TriggerClientEvent('919-admin:client:RefreshMenu', src, json.encode(Bridge.GetPlayerList()), silent)
end)

RegisterNetEvent('919-admin:server:RequestViewPlayer', function(CitizenId)
    DebugTrace(CitizenId)
    local src = source
    local Player = Bridge.GetPlayerFromCharacterIdentifier(CitizenId)
    if Player then
        local sourcer = Player.source or Player.PlayerData.source
        TriggerClientEvent('919-admin:client:ViewPlayer', src, true, sourcer)
    else
        TriggerClientEvent('919-admin:client:ViewPlayer', src, false, Bridge.GetOfflinePlayerFromCharacterIdentifier(CitizenId))
    end
end)

RegisterNetEvent('919-admin:server:RequestNoClip', function()
    local src = source
    if AdminPanel.HasPermissionEx(src, 'noclip') then 
        TriggerClientEvent('919-admin:client:ToggleNoClip', src) 
    end
end)

RegisterNetEvent('919-admin:server:GetPlayersForBlips', function()
    local src = source
    local tempPlayers = {}
    for _, v in pairs(GetPlayers()) do
        v = tonumber(v)
        local targetped = GetPlayerPed(v)
        local charname = Bridge.GetCharacterName(v)
        tempPlayers[#tempPlayers + 1] = { 
            name = (charname .. ' | (' .. (GetPlayerName(v) or '') .. ')'), 
            id = v, 
            coords = GetEntityCoords(targetped), 
            cid = charname, 
            citizenid = '---', 
            sources = targetped, 
            sourceplayer = v 
        }
    end
    table.sort(tempPlayers, function(a, b) return a.id < b.id end)
    PlayersB = tempPlayers
    TriggerClientEvent('919-admin:client:Show', src, PlayersB)
end) 