if Config.Framework == 'esx' then
    if GetResourceState('es_extended') ~= 'started' then
        return
    end
elseif Config.Framework == 'autodetect' then
    if GetResourceState('es_extended') ~= 'started' then return end
    print('[^3INFO^7] ^3Auto-Detect^7: Detected ^3ESX^7 Framework.')
else
    return
end

Config.Framework = 'esx'

ESX = exports['es_extended']:getSharedObject()

local Cache = { MoneyLeaderboard = {}}

-- SERVER COMPATIBILITY LAYER
if (IsDuplicityVersion()) then
    Config.DB = {}
    Config.DB.VehiclesTable = 'owned_vehicles'
    Config.DB.CharactersTable = 'users'
    Config.DB.BansTable = 'bans'

    SetTimeout(1000, function()
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `bans` ( `id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(50) DEFAULT NULL, `license` varchar(50) DEFAULT NULL, `discord` varchar(50) DEFAULT NULL, `ip` varchar(50) DEFAULT NULL, `reason` text DEFAULT NULL, `expire` int(11) DEFAULT NULL, `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer', PRIMARY KEY (`id`) )
        ]])

        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `warns` ( `id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(50) NOT NULL, `license` varchar(50) NOT NULL, `reason` text NOT NULL, `warnedby` varchar(50) NOT NULL, `warnedtime` bigint(20) NOT NULL DEFAULT unix_timestamp(), PRIMARY KEY (`id`) )
        ]])

        print('[919ADMIN] Database tables initialized.')

        -- LEADERBOARD CACHE
        CreateThread(function()
            while true do
                Wait(2000)
                print('[919ADMIN] Caching Leaderboard Data...')

                local money = {}
                local results = MySQL.query.await('SELECT identifier, firstname, lastname, accounts, last_seen FROM `' .. Config.DB.CharactersTable .. '`')
                for k, v in pairs(results) do
                    local moneyInfo = json.decode(v.accounts)
                    money[#money + 1] = { citizenid = v.identifier, firstname = v.firstname, lastname = v.lastname, cash = moneyInfo.money, bank = moneyInfo.bank, crypto = nil, coins = nil, lastseen = v.last_seen }
                    Wait(10)
                end
                Cache.MoneyLeaderboard = money
                print('[919ADMIN] Leaderboard data caching complete.')
                Wait(Config.LeaderboardCacheTimer)
            end
        end)
    end)

    Bridge = {
        GetPlayer = ESX.GetPlayerFromId, GetPlayerFromCharacterIdentifier = ESX.GetPlayerFromIdentifier, GetOfflinePlayerFromCharacterIdentifier = function(CitizenId)
            local results = MySQL.query.await('SELECT * FROM `' .. Config.DB.CharactersTable .. '` WHERE `identifier` = ? LIMIT 1', { CitizenId })
            local result = results[1]
            local PlayerData = result
            PlayerData.accounts = json.decode(PlayerData.accounts)
            PlayerData.status = json.decode(PlayerData.status)

            local amountofVehicles = MySQL.query.await('SELECT COUNT(*) as count FROM `' .. Config.DB.VehiclesTable .. '` WHERE `owner` = ?', { PlayerData.citizenid })
            local hunger, thirst = nil, nil
            for k, v in pairs(PlayerData.status) do
                if v.name == 'hunger' then hunger = v.percent end
                if v.name == 'thirst' then thirst = v.percent end
            end
            
            local FixedPlayerData = {
                id = 'OFFLINE', name = PlayerData.firstname .. ' ' .. PlayerData.lastname, identifiers = PlayerData.identifier, role = PlayerData.group, bank = '$' .. comma_value(PlayerData.accounts.bank), cash = '$' .. comma_value(PlayerData.accounts.money),
                steamid = PlayerData.identifier, citizenid = PlayerData.identifier, gender = PlayerData.sex, nationality = 'Unknown', phone = PlayerData.phone_number, accountid = 'Unknown', hunger = hunger or 100, thirst = thirst or 100, injail = 0,
                lastonline = PlayerData.last_seen, amountofVehicles = amountofVehicles[1].count, job = PlayerData.job, rank = PlayerData.job_grade, health = 0, armor = 0, jobboss = 'Unknown', duty = 'Unknown', gang = 'Unknown', gangrank = 'Unknown',
                gangboss = 'Unknown', charname = PlayerData.firstname .. ' ' .. PlayerData.lastname
            }
            return FixedPlayerData
        end,
        GetPlayerList = function()
            local PlayerList = {}
            for _, strPlayerId in pairs(GetPlayers()) do
                local playerId = tonumber(strPlayerId)
                local Player = ESX.GetPlayerFromId(playerId)

                if Player then
                    local identifiers, steamIdentifier = GetPlayerIdentifiers(playerId)
                    for _, v2 in pairs(identifiers) do
                        if string.find(v2, 'license:') then steamIdentifier = v2 end
                        if not Config.ShowIPInIdentifiers then if string.find(v2, 'ip:') then identifiers[_] = nil end end
                    end

                    local lastOnlineResult = MySQL.query.await('SELECT last_seen FROM `' .. Config.DB.CharactersTable .. '` WHERE identifier = ?', { Player.getIdentifier() })
                    local amountofVehicles = MySQL.query.await('SELECT COUNT(*) as count FROM `' .. Config.DB.VehiclesTable .. '` WHERE `owner` = ?', { Player.getIdentifier() })

                    local hunger, thirst = nil, nil
                    if not Player.variables.status then Player.variables.status = {} end
                    for _, status in pairs(Player.variables.status) do
                        if status.name == 'hunger' then hunger = status.percent end
                        if status.name == 'thirst' then thirst = status.percent end
                    end

                    local playerRole = Player.group
                    table.insert(PlayerList, {
                        id = playerId, name = GetPlayerName(playerId), identifiers = json.encode(identifiers), role = playerRole, bank = '$' .. comma_value(Player.getAccount('bank').money), cash = '$' .. comma_value(Player.getMoney()),
                        steamid = steamIdentifier, citizenid = Player.identifier, gender = Player.get('sex'), nationality = 'Unknown', phone = 'Unknown', accountid = 'Unknown', hunger = hunger, thirst = thirst, injail = 0,
                        lastonline = lastOnlineResult[1]?.last_seen or 'Unknown', amountofVehicles = amountofVehicles[1]?.count or 0, job = Player.job, rank = Player.job_grade, health = GetEntityHealth(GetPlayerPed(Player.source)) - 100,
                        armor = GetPedArmour(GetPlayerPed(Player.source)), jobboss = 'Unknown', duty = 'Unknown', gang = 'Unknown', gangrank = 'Unknown', gangboss = 'Unknown', charname = Player.getName()
                    })
                end
            end
            return PlayerList
        end,
        Notify = function(targetId, message)
            local p = ESX.GetPlayerFromId(targetId)
            if p then
                p.showNotification(message)
            end
        end,
        SetPlayerJob = function(targetId, job, grade)
            local p = ESX.GetPlayerFromId(targetId)
            if p then p.setJob(job, grade) end
        end,
        SetPlayerGang = function(targetId, gang, grade)
            -- Unavailable
        end,
        GetCharacterName = function(targetId)
            local p = ESX.GetPlayerFromId(targetId)
            if p then
                return p.getName()
            else
                return nil
            end
        end,
        ClearPlayerInventory = function(targetId)
            if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
                exports.ox_inventory:ClearInventory(targetId)
            elseif (Config.Inventory == 'autodetect' and GetResourceState('ps-inventory') == 'started') or Config.Inventory == 'ps-inventory' then
                exports['ps-inventory']:ClearInventory(targetId)
            elseif (Config.Inventory == 'autodetect' and GetResourceState('lj-inventory') == 'started') or Config.Inventory == 'lj-inventory' then
                exports['lj-inventory']:ClearInventory(targetId)
            elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
                exports.core_inventory:clearInventory(targetId, targetId)
            elseif (Config.Inventory == 'autodetect' and GetResourceState('qs-inventory') == 'started') or Config.Inventory == 'qs-inventory' then
                print('^1[ERROR]^7 Clearing inventory is not supported with QS-Inventory. Please use their ^5/clearinv^7 command to clear the inventory.')
            elseif (Config.Inventory == 'autodetect' and GetResourceState('codem-inventory') == 'started') or Config.Inventory == 'codem-inventory' then
                print('^1[ERROR]^7 Clearing inventory is not supported with CodeM-Inventory. Please use their ^5/clearinv^7 command to clear the inventory.')
            else
                local p = ESX.GetPlayerFromId(targetId)
                if p then
                    for k, v in ipairs(p.inventory) do if v.count > 0 then p.setInventoryItem(v.name, 0) end end
                    TriggerEvent('esx:playerInventoryCleared', targetId)
                end
            end
        end,
        GetVehiclesList = function()
            local results = MySQL.query.await('SELECT * FROM vehicles')
            local vehicles = {}
            for k, v in pairs(results) do vehicles[v.model] = { name = v.name, price = v.price, category = v.category, shop = '', brand = '', model = v.name, hash = GetHashKey(v.model) } end
            return vehicles
        end,
        GetItemsList = function()
            if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then 
                return exports.ox_inventory:Items()
            end
            local items = MySQL.query.await('SELECT * FROM items')
            local itemsList = {}
            for k, v in pairs(items) do itemsList[v.name] = { name = v.name, label = v.label, weight = v.weight, description = v.description } end
            return itemsList
        end,
        GetCharacterIdentifier = function(targetId)
            local p = ESX.GetPlayerFromId(targetId)
            if p then
                return p.getIdentifier()
            else
                return nil
            end
        end,
        GetMasterEmployeeList = function()
            local jobs = ESX.GetJobs()
            local list = {}
            for k, v in pairs(jobs) do
                local res = MySQL.query.await('SELECT * FROM `users` WHERE `job` = ?', { v.name })
                local JobEmployees = {}
                for k2, v2 in pairs(res) do
                    local CharName, JobInfo, GradeInfo = 'Unknown?', 'Unknown?', 'Unknown?'

                    CharName = v2.firstname .. ' ' .. v2.lastname
                    JobInfo = v2.job
                    GradeInfo = v2.job_grade

                    Online = ESX.GetPlayerFromIdentifier(v2.identifier)
                    table.insert(JobEmployees, {
                        Name = v2.label, CitizenId = v2.identifier, CharName = CharName, IsBoss = false, IsOnline = Online and '<span class="badge bg-success text-light">ONLINE</span>' or '<span class="badge bg-danger text-light">OFFLINE</span>',
                        Grade = { name = v2.job, level = v2.job_grade }
                    })
                end
                list[k] = JobEmployees
            end
            return list
        end,
        GetMasterGangList = function()
            -- Unavailable
        end,
        GetCharacterData = function(targetId)
            local d = {}
            local p = ESX.GetPlayerFromId(targetId)
            local playerGroup = p.getGroup()
            if p then
                d.CharacterName = p.getName()
                d.Role = playerGroup
                d.Cash = p.getMoney()
                d.Bank = p.getAccount('bank').money
                d.CharacterIdentifier = p.getIdentifier()
                d.Job = p.job
                d.Rank = p.job_grade
                d.PlayerId = p.source
                d.IsBoss = false
                d.OnDuty = false
                d.GangLabel = nil
                d.GangRank = nil
                d.GangIsBoss = nil
            end
            return d
        end,
        GetLeaderboardInfo = function()
            return Cache.MoneyLeaderboard
        end,
        PlayerActions = {
            AddMoney = function(targetId, amount)
                local p = ESX.GetPlayerFromId(targetId)
                if p then p.addMoney(amount) end
            end,
            RemoveMoney = function(targetId, amount)
                local p = ESX.GetPlayerFromId(targetId)
                if p then p.removeMoney(amount) end
            end,
            AddBank = function(targetId, amount)
                local p = ESX.GetPlayerFromId(targetId)
                if p then p.addAccountMoney('bank', amount) end
            end,
            RemoveBank = function(targetId, amount)
                local p = ESX.GetPlayerFromId(targetId)
                if p then p.removeAccountMoney('bank', amount) end
            end
        }
    }

    RegisterNetEvent('919-admin:server:OpenOxInventory', function(targetId)
        local src = source
        if AdminPanel.HasPermission(src, 'openinventory') then
            exports.ox_inventory:forceOpenInventory(src, 'player', targetId)
        end
    end)
end

-- CLIENT COMPATIBILITY LAYER
if (not IsDuplicityVersion()) then
    Bridge = {
        OpenInventory = function(targetId)
            if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
                TriggerServerEvent('919-admin:server:OpenOxInventory', targetId)
            elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
                TriggerServerEvent('core_inventory:server:openInventory', targetId, 'otherplayer', nil, nil, true)
            else
                TriggerServerEvent('919-Admin:server:OpenInventory', targetId)
            end
        end, UncuffSelf = function() TriggerEvent('esx_policejob:handcuff') end,
        Notify = function(message) TriggerEvent('esx:showNotification', message, 'info', 5000) end
    }
end
