local YourWebhook = 'YOUR-WEBHOOK'  -- help: https://docs.brutalscripts.com/site/others/discord-webhook

function GetWebhook()
    return YourWebhook
end

RESCB("brutal_gangs:server:StaffCheck",function(source,cb,groups)
    local src = source

    cb(StaffCheck(src, groups))
end)

RESCB("brutal_gangs:server:GetDressing",function(source,cb)
    local src = source
    local dressingTable = {}
    local dataArrived = false

    if Config['Core']:upper() == 'ESX' then
        TriggerEvent('esx_datastore:getDataStore', 'property', GetIdentifier(src), function(store)
            local dressings = store.get('dressing') or {}
        
            for k,v in pairs(dressings) do
                table.insert(dressingTable, {label = v.label, skin = v.skin})
            end
        end)
        dataArrived = true
    elseif Config['Core']:upper() == 'QBCORE' then
        local results = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { GetIdentifier(src) })
        for k, v in pairs(results) do
            table.insert(dressingTable, {label = v.outfitname ~= "" and v.outfitname or "None", skin = results[k].skin, model = v.model})
        end
        dataArrived = true
    end

    while not dataArrived do
        Citizen.Wait(10)
    end

    cb(dressingTable)
end)

function StaffCheck(source, AdminGroups)
    local staff = false

    if Config.Core:upper() == 'ESX'then
        local player = Core.GetPlayerFromId(source)
        local playerGroup = player.getGroup()

        for i, Group in ipairs(AdminGroups) do
            if playerGroup == Group then
                staff = true
                break
            end
        end
    elseif Config.Core:upper() == 'QBCORE' then

        for i, Group in ipairs(AdminGroups) do
            if Core.Functions.HasPermission(source, Group) or IsPlayerAceAllowed(source, Group) or IsPlayerAceAllowed(source, 'command') then
                staff = true
                break
            end
        end
    end

    return staff
end

RegisterNetEvent("brutal_gangs:server:qbcore-loadPlayerSkin")
AddEventHandler("brutal_gangs:server:qbcore-loadPlayerSkin", function(model, skin)
    local src = source

    if model ~= nil and skin ~= nil then
        MySQL.query('DELETE FROM playerskins WHERE citizenid = ?', { GetIdentifier(src) }, function()
            MySQL.insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
                GetIdentifier(src),
                model,
                skin,
                1
            })
        end)
    end
end)