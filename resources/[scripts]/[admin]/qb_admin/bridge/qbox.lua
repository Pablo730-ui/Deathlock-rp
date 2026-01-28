if Config.Framework == 'qbox' then
    if GetResourceState('qbx_core') ~= 'started' then
        return
    end
elseif Config.Framework == 'autodetect' then
    if GetResourceState('qbx_core') ~= 'started' then return end
    print('[^3INFO^7] ^3Auto-Detect^7: Detected ^3QBox^7 Framework.')
else
    return
end

Config.Framework = 'qbox'

local Cache = { MoneyLeaderboard = {} }

-- SERVER COMPATIBILITY LAYER
if (IsDuplicityVersion()) then
    Config.DB = {}
    Config.DB.VehiclesTable = 'player_vehicles'
    Config.DB.CharactersTable = 'players'
    Config.DB.BansTable = 'bans'

    SetTimeout(1000, function()
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `bans` ( `id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(50) DEFAULT NULL, `license` varchar(50) DEFAULT NULL, `discord` varchar(50) DEFAULT NULL, `ip` varchar(50) DEFAULT NULL, `reason` text DEFAULT NULL, `expire` int(11) DEFAULT NULL, `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer', PRIMARY KEY (`id`) )
        ]])

        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `warns` ( `id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(50) NOT NULL, `license` varchar(50) NOT NULL, `reason` text NOT NULL, `warnedby` varchar(50) NOT NULL, `warnedtime` bigint(20) NOT NULL DEFAULT unix_timestamp(), PRIMARY KEY (`id`) )
        ]])

        print('[919ADMIN] Database tables initialized.')
    end)

    -- LEADERBOARD CACHE
    CreateThread(function()
        while true do
            Wait(2000)
            print('[919ADMIN] Caching Leaderboard Data...')
            local money = {}
            MySQL.query('SELECT citizenid, charinfo, money, last_updated FROM `players`', {}, function(results)
                for _, result in pairs(results) do
                    local charinfo = json.decode(result.charinfo)
                    local moneyInfo = json.decode(result.money)
                    money[#money + 1] = {
                        citizenid = result.citizenid, firstname = charinfo.firstname, lastname = charinfo.lastname, cash = moneyInfo.cash, bank = moneyInfo.bank, crypto = moneyInfo.crypto, coins = moneyInfo.coins, lastseen = result.last_updated
                    }
                    Wait(10) -- We only want to process 100 records per second.
                end
                Cache.MoneyLeaderboard = money
                print('[919ADMIN] Leaderboard data caching complete.')
            end)
            Wait(Config.LeaderboardCacheTimer)
        end
    end)

    Bridge = {
        GetPlayer = function(source) return exports.qbx_core:GetPlayer(source) end, GetPlayerFromCharacterIdentifier = function(citizenid) return exports.qbx_core:GetPlayerByCitizenId(citizenid) end,
        GetOfflinePlayerFromCharacterIdentifier = function(CitizenId)
            local sqlResult = MySQL.query.await('SELECT * FROM `players` WHERE `citizenid` = ? LIMIT 1', { CitizenId })
            local res = sqlResult[1]
            if not res then return end
            local PlayerData = { charinfo = json.decode(res.charinfo), job = json.decode(res.job), money = json.decode(res.money), metadata = json.decode(res.metadata), gang = json.decode(res.gang), status = json.decode(res.status) }

            local amountofVehicles = MySQL.query.await('SELECT COUNT(*) as count FROM `player_vehicles` WHERE `citizenid` = ?', { res.citizenid })
            local MenuPlayerData = {
                id = 'OFFLINE', name = ('%s %s'):format(PlayerData.charinfo.firstname, PlayerData.charinfo.lastname), identifiers = res.citizenid, role = PlayerData.role, bank = ('$%s'):format(comma_value(PlayerData.money.bank)),
                cash = ('$%s'):format(comma_value(PlayerData.money.cash)), steamid = res.license, citizenid = res.citizenid, gender = PlayerData.charinfo.gender, nationality = PlayerData.charinfo.nationality, phone = PlayerData.charinfo.phone,
                accountid = PlayerData.charinfo.account, hunger = PlayerData.metadata['hunger'], thirst = PlayerData.metadata['thirst'], injail = PlayerData.metadata['injail'], lastonline = PlayerData.last_updated, amountofVehicles = amountofVehicles[1].count,
                job = PlayerData.job.label, rank = PlayerData.job.grade.name, health = 0, armor = 0,
                jobboss = PlayerData.job.isboss and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>',
                duty = PlayerData.job.onduty and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>', gang = PlayerData.gang.label,
                gangrank = PlayerData.gang.grade.name, gangboss = PlayerData.gang.isboss and '<span class="badge badge-success">' .. Lang:t('alerts.yes') .. '</span>' or '<span class="badge badge-danger">' .. Lang:t('alerts.no') .. '</span>',
                charname = ('%s %s'):format(PlayerData.charinfo.firstname, PlayerData.charinfo.lastname)
            }
            return MenuPlayerData
        end, GetPlayerList = function()
            local PlayerList = {}
            for _, playerId in pairs(GetPlayers()) do
                playerId = tonumber(playerId)
                local Player = exports.qbx_core:GetPlayer(playerId)

                if Player then
                    local identifiers, steamIdentifier = GetPlayerIdentifiers(playerId)
                    for _, v2 in pairs(identifiers) do
                        if string.find(v2, 'license:') then steamIdentifier = v2 end
                        if not Config.ShowIPInIdentifiers then if string.find(v2, 'ip:') then identifiers[_] = nil end end
                    end
                    local playerRole = 'user'
                    local adminRole = AdminPanel.GetPlayerGroup(playerId)
                    if adminRole then
                        playerRole = adminRole
                    end

                    local lastOnlineResult = MySQL.query.await('SELECT last_updated FROM players WHERE citizenid = ?', { Player.PlayerData.citizenid })
                    local amountofVehicles = MySQL.query.await('SELECT COUNT(*) as count FROM `player_vehicles` WHERE `citizenid` = ?', { Player.PlayerData.citizenid })

                    table.insert(PlayerList, {
                        id = playerId, name = GetPlayerName(playerId), identifiers = json.encode(identifiers), role = playerRole, bank = ('$' .. comma_value(Player.PlayerData.money.bank)) or 'Unknown',
                        cash = ('$' .. comma_value(Player.PlayerData.money.cash)) or 'Unknown', steamid = steamIdentifier, citizenid = Player.PlayerData.citizenid or 'Unknown', gender = Player.PlayerData.charinfo.gender or 'Unknown',
                        nationality = Player.PlayerData.charinfo.nationality or 'Unknown', phone = Player.PlayerData.charinfo.phone or 'Unknown', accountid = Player.PlayerData.charinfo.account or 'Unknown',
                        hunger = Player.PlayerData.metadata['hunger'] or 'Unknown', thirst = Player.PlayerData.metadata['thirst'] or 'Unknown', injail = Player.PlayerData.metadata['injail'] or 'Unknown',
                        lastonline = lastOnlineResult[1].last_updated or 'Unknown', amountofVehicles = amountofVehicles[1].count, job = Player.PlayerData.job.label or 'Unknown', rank = Player.PlayerData.job.grade.name or 'Unknown',
                        health = GetEntityHealth(GetPlayerPed(Player.PlayerData.source)) - 100, armor = GetPedArmour(GetPlayerPed(Player.PlayerData.source)),
                        jobboss = Player.PlayerData.job.isboss and Lang:t('alerts.yes') or Lang:t('alerts.no'),
                        duty = Player.PlayerData.job.onduty and Lang:t('alerts.yes') or Lang:t('alerts.no'),
                        gang = Player.PlayerData.gang.label or 'Unknown', gangrank = Player.PlayerData.gang.grade.name or 'Unknown',
                        gangboss = Player.PlayerData.gang.isboss and Lang:t('alerts.yes') or Lang:t('alerts.no'),
                        charname = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
                    })
                end
            end
            return PlayerList
        end, 
        Notify = function(targetId, message) exports.qbx_core:Notify(targetId, message) end,
        SetPlayerJob = function(targetId, job, grade) exports.qbx_core:SetJob(targetId, job, grade) end,
        SetPlayerGang = function(targetId, gang, grade) exports.qbx_core:SetGang(targetId, gang, grade) end,
        GetCharacterName = function(targetId)
            local p = exports.qbx_core:GetPlayer(targetId)
            if p then return p.PlayerData.charinfo.firstname .. ' ' .. p.PlayerData.charinfo.lastname end
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
            end
        end,
        GetVehiclesList = function() return exports.qbx_core:GetVehiclesByName() end, GetItemsList = function()
            if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
                return exports.ox_inventory:Items()
            elseif (Config.Inventory == 'autodetect' and GetResourceState('qs-inventory') == 'started') or Config.Inventory == 'qs-inventory' then
                return exports['qs-inventory']:GetItemList()
            elseif (Config.Inventory == 'autodetect' and GetResourceState('codem-inventory') == 'started') or Config.Inventory == 'codem-inventory' then
                return exports['codem-inventory']:GetItemList()
            elseif (Config.Inventory == 'autodetect' and GetResourceState('codem-inventory') == 'started') or Config.Inventory == 'codem-inventory' then
                return exports['codem-inventory']:GetItemList()
            elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
                return exports.core_inventory:getItemsList()
            else
                print('[^1ERROR^7] No compatible inventory found.')
                return {}
            end
        end,
        GetCharacterIdentifier = function(targetId)
            local p = exports.qbx_core:GetPlayer(targetId)
            if p then
                return p.PlayerData.citizenid
            else
                return nil
            end
        end,
        GetMasterEmployeeList = function()
            local jobs = exports.qbx_core:GetJobs()
            local list = {}
            for jobName, _ in pairs(jobs) do
                local res = MySQL.query.await('SELECT `citizenid`, `charinfo`, `job` FROM `players` WHERE JSON_EXTRACT(`job`, "$.name") = ?', { jobName })
                local JobEmployees = {}
                for k2, v2 in pairs(res) do
                    local CharName, JobInfo, GradeInfo = 'Unknown?', 'Unknown?', 'Unknown?'

                    local CharInfo = json.decode(v2.charinfo)
                    if CharInfo then CharName = CharInfo.firstname .. ' ' .. CharInfo.lastname end
                    local JobInfo = json.decode(v2.job)
                    local GradeInfo = JobInfo.grade

                    Online = exports.qbx_core:GetPlayerByCitizenId(v2.citizenid)
                    table.insert(JobEmployees, {
                        Name = v2.name, CitizenId = v2.citizenid, CharName = CharName, IsBoss = JobInfo.isboss, IsOnline = Online and '<span class="badge bg-success text-light">ONLINE</span>' or '<span class="badge bg-danger text-light">OFFLINE</span>',
                        Grade = { name = GradeInfo.name, level = GradeInfo.level }
                    })
                end
                list[jobName] = JobEmployees
            end
            return list
        end,
        GetMasterGangList = function()
            local gangs = exports.qbx_core:GetGangs()
            local list = {}
            for gangName, _ in pairs(gangs) do
                local GangMembers = {}
                local results = MySQL.query.await('SELECT `citizenid`, `charinfo`, `gang` FROM `players` WHERE JSON_EXTRACT(`gang`, "$.name") = ?', { gangName })
                for k1, v1 in ipairs(results) do
                    local CharInfo = json.decode(v1.charinfo)
                    local CharName = 'Unknown?'
                    if CharInfo then CharName = CharInfo.firstname .. ' ' .. CharInfo.lastname end
                    local GangInfo = json.decode(v1.gang)
                    local GradeInfo = GangInfo.grade
                    local Online = exports.qbx_core:GetPlayerByCitizenId(v1.citizenid)
                    table.insert(GangMembers, {
                        Name = v1.name, CitizenId = v1.citizenid, CharName = CharName, IsBoss = GangInfo.isboss, IsOnline = Online and '<span class="badge bg-success text-light">ONLINE</span>' or '<span class="badge bg-danger text-light">OFFLINE</span>',
                        Grade = { name = GradeInfo.name, level = GradeInfo.level }
                    })
                end
                list[gangName] = GangMembers
            end
            return list
        end,
        GetCharacterData = function(targetId)
            local cData = {}
            local qbPlayer = exports.qbx_core:GetPlayer(targetId)
            if qbPlayer then
                cData = {
                    Name = ('%s %s'):format(qbPlayer.PlayerData.charinfo.firstname, qbPlayer.PlayerData.charinfo.lastname), CharacterName = ('%s %s'):format(qbPlayer.PlayerData.charinfo.firstname, qbPlayer.PlayerData.charinfo.lastname), Role = 'Unknown',
                    Cash = qbPlayer.PlayerData.money.cash, Bank = qbPlayer.PlayerData.money.bank, CharacterIdentifier = qbPlayer.PlayerData.citizenid, Job = qbPlayer.PlayerData.job.label, Rank = qbPlayer.PlayerData.job.grade.name,
                    PlayerId = qbPlayer.PlayerData.source, IsBoss = qbPlayer.PlayerData.job.isboss, OnDuty = qbPlayer.PlayerData.job.onduty, GangLabel = qbPlayer.PlayerData.gang.label, GangRank = qbPlayer.PlayerData.gang.grade.name,
                    GangIsBoss = qbPlayer.PlayerData.gang.isboss
                }
            end
            return cData
        end,
        GetLeaderboardInfo = function() return Cache.MoneyLeaderboard, {} end, PlayerActions = {
            AddMoney = function(targetId, amount) exports.qbx_core:AddMoney(targetId, 'cash', amount, 'Admin Action') end,
            RemoveMoney = function(targetId, amount) exports.qbx_core:RemoveMoney(targetId, 'cash', amount, 'Admin Action') end,
            AddBank = function(targetId, amount) exports.qbx_core:AddMoney(targetId, 'bank', amount, 'Admin Action') end,
            RemoveBank = function(targetId, amount) exports.qbx_core:RemoveMoney(targetId, 'bank', amount, 'Admin Action') end
        }
    }

    RegisterNetEvent('919-admin:server:OpenQBoxInventory', function(targetId)
        local src = source
        if AdminPanel.HasPermission(src, 'openinventory') then
            exports.ox_inventory:forceOpenInventory(src, 'player', targetId)
            print('^2[919ADMIN]^7 Opening QBox Inventory for player ' .. targetId)
        end
    end)
end

-- CLIENT COMPATIBILITY LAYER
if (not IsDuplicityVersion()) then
    Bridge = {
        OpenInventory = function(targetId)
            if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
                TriggerServerEvent('919-admin:server:OpenQBoxInventory', targetId)
            elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
                TriggerServerEvent('core_inventory:server:openInventory', targetId, 'otherplayer', nil, nil, true)
            else
                print('[^1ERROR^7] No compatible inventory found. You are running QBox so should be running ox_inventory.')
            end
        end, UncuffSelf = function() TriggerEvent('police:client:GetCuffed') end,
        Notify = function(message) exports.qbx_core:Notify(message) end,
    }
end
