DiscordRolesList = {}

local function getDiscordRolesWithCache(targetId)    
    if DiscordRolesList[targetId] then
        DebugTrace('Using cached Discord roles for player: ' .. targetId)
        return DiscordRolesList[targetId]
    end
    
    local roles = GetDiscordRoles(targetId)
    DiscordRolesList[targetId] = roles
    DebugTrace('Cached Discord roles for player: ' .. targetId)
    
    return roles
end

local function getHighestPriorityRole(discordRoles)
    if not Config.RolePriority then
        DebugTrace('Warning: Config.RolePriority not found, using fallback')
        return nil
    end
    
    local highestRole = nil
    local highestPriority = -1
    
    for _, role in pairs(discordRoles) do
        for roleId, group in pairs(Config.DiscordRoles.Roles) do
            if role == roleId then
                local priority = Config.RolePriority[group] or 0
                if priority > highestPriority then
                    highestPriority = priority
                    highestRole = group
                    DebugTrace('Found role: ' .. group .. ' with priority: ' .. priority)
                end
            end
        end
    end
    
    if highestRole then
        DebugTrace('Highest priority role: ' .. highestRole .. ' (priority: ' .. highestPriority .. ')')
    else
        DebugTrace('No valid Discord roles found')
    end
    
    return highestRole
end

local function getAllPermissionsForRole(role)
    if not Config.Permissions[role] then
        return {}
    end
    
    local permissions = {}
    
    for _, permission in pairs(Config.Permissions[role].AllowedActions) do
        permissions[permission] = true
    end
    
    local rolePriority = Config.RolePriority[role] or 0
    
    for inheritRole, inheritPriority in pairs(Config.RolePriority) do
        if inheritPriority < rolePriority and Config.Permissions[inheritRole] then
            for _, permission in pairs(Config.Permissions[inheritRole].AllowedActions) do
                permissions[permission] = true
            end
            DebugTrace('Inherited permissions from: ' .. inheritRole)
        end
    end
    
    return permissions
end
    
local function getPlayerPermissionGroup(targetId)
    DebugTrace('Checking permissions for player: ' .. targetId)

    if Config.UseAcePermissions then
        DebugTrace('Checking ACE permissions...')
        local highestRole = nil
        local highestPriority = -1
        
        for group, data in pairs(Config.Permissions) do
            if IsPlayerAceAllowed(targetId, group) then
                local priority = Config.RolePriority[group] or 0
                DebugTrace('Player has ACE permission: ' .. group .. ' with priority: ' .. priority)
                
                if priority > highestPriority then
                    highestPriority = priority
                    highestRole = group
                end
            end
        end
        
        if highestRole then
            DebugTrace('Highest ACE permission: ' .. highestRole .. ' (priority: ' .. highestPriority .. ')')
            return highestRole
        else
            DebugTrace('No ACE permissions found')
        end
    end

    DebugTrace('Checking license-based permissions...')
    for k, v in pairs(Config.Permissions) do
        local playerLicense = GetPlayerIdentifierByType(targetId, 'license')
        local playerRole = Config.PermissionedUsers[playerLicense]
        
        DebugTrace('Player license: ' .. (playerLicense or 'nil') .. ', Role in config: ' .. (playerRole or 'nil'))
        
        if playerRole and playerRole == k then
            DebugTrace('Player has license-based permission: ' .. k)
            return k
        end
    end
    DebugTrace('No license-based permissions found')

    if Config.DiscordRoles.Enabled then
        DebugTrace('Checking Discord roles...')
        local discordRoles = getDiscordRolesWithCache(targetId)
        if discordRoles then
            DebugTrace('Player has Discord roles: ' .. json.encode(discordRoles))
            local highestRole = getHighestPriorityRole(discordRoles)
            if highestRole then
                DebugTrace('Player has Discord-based permission: ' .. highestRole)
                return highestRole
            end
        else
            DebugTrace('No Discord roles found for player')
        end
    else
        DebugTrace('Discord roles are disabled')
    end
    
    DebugTrace('No permissions found for player')
    return nil
end

AdminPanel.HasPermission = function(targetId, permName)
    DebugTrace('Permission check: ' .. permName .. ' for player: ' .. targetId)
    
    local playerGroup = getPlayerPermissionGroup(targetId)
    
    if not playerGroup then
        DebugTrace('Permission denied: No valid permission group')
        if permName ~= 'clearreports' and permName ~= 'clearadminchat' then 
            TriggerClientEvent('919-admin:client:ShowPanelAlert', targetId, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noPermission')) 
        end
        TriggerClientEvent('919-admin:client:ResetMenu', targetId)
        return false
    end
    
    local permissions = getAllPermissionsForRole(playerGroup)
    
    if permissions[permName] then
        DebugTrace('Permission granted: ' .. permName .. ' via group: ' .. playerGroup)
        return true
    end
    
    DebugTrace('Permission denied: ' .. permName .. ' not found in group: ' .. playerGroup)
    if permName ~= 'clearreports' and permName ~= 'clearadminchat' then 
        TriggerClientEvent('919-admin:client:ShowPanelAlert', targetId, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.noPermission')) 
    end
    TriggerClientEvent('919-admin:client:ResetMenu', targetId)
    
    return false
end

AdminPanel.HasPermissionEx = function(targetId, permName)
    DebugTrace('Permission check (Ex): ' .. permName .. ' for player: ' .. targetId)
    
    local playerGroup = getPlayerPermissionGroup(targetId)
    
    if not playerGroup then
        DebugTrace('Permission denied: No valid permission group')
        return false
    end
    
    local permissions = getAllPermissionsForRole(playerGroup)
    
    if permissions[permName] then
        DebugTrace('Permission granted: ' .. permName .. ' via group: ' .. playerGroup)
        return true
    end
    
    DebugTrace('Permission denied: ' .. permName .. ' not found in group: ' .. playerGroup)
    return false
end

AdminPanel.GetPlayerGroup = function(targetId)
    return getPlayerPermissionGroup(targetId)
end

AdminPanel.GetPlayerPermissions = function(targetId)
    local playerGroup = getPlayerPermissionGroup(targetId)
    if not playerGroup then
        return {}
    end
    return getAllPermissionsForRole(playerGroup)
end 