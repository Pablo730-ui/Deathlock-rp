-- Items module for inventory and item management

-- Money management
RegisterNetEvent('919-admin:server:MonetaryAction', function(targetId, action, amount)
    local src = source
    if AdminPanel.HasPermission(src, 'givetakemoney') then
        if action == 'givecash' then
            Bridge.PlayerActions.AddMoney(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gaveCash', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Cash Given', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** added $' .. amount .. ' cash to ' .. GetPlayerName(targetId), false)
        elseif action == 'removecash' then
            Bridge.PlayerActions.RemoveMoney(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.removeCash', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Cash Removed', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed $' .. amount .. ' cash from ' .. GetPlayerName(targetId), false)
        elseif action == 'givebank' then
            Bridge.PlayerActions.AddBank(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gaveBank', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Bank Given', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** added $' .. amount .. ' bank money to ' .. GetPlayerName(targetId), false)
        elseif action == 'removebank' then
            Bridge.PlayerActions.RemoveBank(targetId, amount)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.removeBank', { value = amount, value2 = GetPlayerName(targetId) }))
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Bank Removed', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** removed $' .. amount .. ' bank money from ' .. GetPlayerName(targetId), false)
        end
    end
end)

-- Item management functions
local function addItem(targetId, item, amount)
    -- Ensure targetId is a number for inventory functions
    targetId = tonumber(targetId)
    if not targetId then
        print('[^1ERROR^7] Invalid targetId for addItem')
        return
    end
    
    if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('qs-inventory') == 'started') or Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('ps-inventory') == 'started') or Config.Inventory == 'ps-inventory' then
        exports['ps-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('lj-inventory') == 'started') or Config.Inventory == 'lj-inventory' then
        exports['lj-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('codem-inventory') == 'started') or Config.Inventory == 'codem-inventory' then
        exports['codem-inventory']:AddItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
        exports.core_inventory:addItem(targetId, item, amount)
    else
        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayer(targetId)
            if targetPlayer then targetPlayer.Functions.AddItem(item, amount) end
        elseif Config.Framework == 'qbox' then
            local targetPlayer = exports.qbx_core:GetPlayer(targetId)
            if targetPlayer then targetPlayer.Functions.AddItem(item, amount) end
        elseif Config.Framework == 'esx' then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            if targetPlayer then targetPlayer.addInventoryItem(item, amount) end
        end
    end
end

local function removeItem(targetId, item, amount)
    -- Ensure targetId is a number for inventory functions
    targetId = tonumber(targetId)
    if not targetId then
        print('[^1ERROR^7] Invalid targetId for removeItem')
        return
    end
    
    if (Config.Inventory == 'autodetect' and GetResourceState('ox_inventory') == 'started') or Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('qs-inventory') == 'started') or Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('ps-inventory') == 'started') or Config.Inventory == 'ps-inventory' then
        exports['ps-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('lj-inventory') == 'started') or Config.Inventory == 'lj-inventory' then
        exports['lj-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('codem-inventory') == 'started') or Config.Inventory == 'codem-inventory' then
        exports['codem-inventory']:RemoveItem(targetId, item, amount)
    elseif (Config.Inventory == 'autodetect' and GetResourceState('core_inventory') == 'started') or Config.Inventory == 'core_inventory' then
        exports.core_inventory:removeItem(targetId, item, amount)
    else
        if Config.Framework == 'qbcore' then
            local targetPlayer = QBCore.Functions.GetPlayer(targetId)
            if targetPlayer then targetPlayer.Functions.RemoveItem(item, amount) end
        elseif Config.Framework == 'qbox' then
            local targetPlayer = exports.qbx_core:GetPlayer(targetId)
            if targetPlayer then targetPlayer.Functions.RemoveItem(item, amount) end
        elseif Config.Framework == 'esx' then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            if targetPlayer then targetPlayer.removeInventoryItem(item, amount) end
        end
    end
end

local function handleItemAction(action, targetId, item, amount)
    local itemList = Bridge.GetItemsList()
    if itemList[item] ~= nil then
        if action == 'add' then
            addItem(targetId, item, amount)
        elseif action == 'remove' then
            removeItem(targetId, item, amount)
        end
        return true, ''
    else
        return false, 'invalid item'
    end
end

-- Give/Remove item events
RegisterServerEvent('919-admin:server:GiveItem', function(targetId, item, amount)
    local src = source
    if AdminPanel.HasPermission(src, 'giveitem') then
        amount = tonumber(amount)
        if not amount or amount < 1 then amount = 1 end

        if targetId == 'self' or targetId == nil or targetId == '' or targetId == ' ' then targetId = source end

        local success, errorMsg = handleItemAction('add', targetId, item, amount)
        if success then
            TriggerEvent('919-admin:server:Log', 'adminactions', 'Item Given', 'red', '**STAFF MEMBER ' .. GetPlayerName(src) .. '** gave ' .. item .. ' (x' .. amount .. ') to ' .. GetPlayerName(targetId), false)
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'success', '<strong>' .. Lang:t('alerts.success') .. '</strong> ' .. Lang:t('alerts.gaveItem', { value = item }))
            Bridge.Notify(targetId, Lang:t('notify.givenItem', { value = item }), 'success')
        else
            TriggerClientEvent('919-admin:client:ShowPanelAlert', src, 'danger', '<strong>' .. Lang:t('alerts.error') .. '</strong> ' .. Lang:t('alerts.invalidItem'))
        end
    end
end)

-- Discord item management functions
AdminPanel.GiveItemFromDiscord = function(targetId, item, amount)
    local success, errorMsg = handleItemAction('add', targetId, item, amount)
    if success then
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Item Given', 'red', '**DISCORD** gave ' .. item .. ' (x' .. amount .. ') to ' .. GetPlayerName(targetId), false)
        Bridge.Notify(targetId, Lang:t('notify.givenItem', { value = item }), 'success')
    end
    return success, errorMsg
end

AdminPanel.RemoveItemFromDiscord = function(targetId, item, amount)
    local success, errorMsg = handleItemAction('remove', targetId, item, amount)
    if success then
        TriggerEvent('919-admin:server:Log', 'adminactions', 'Item Removed', 'red', '**DISCORD** removed ' .. item .. ' (x' .. amount .. ') from ' .. GetPlayerName(targetId), false)
        Bridge.Notify(targetId, Lang:t('notify.removedItem', { value = item }), 'error')
    end
    return success, errorMsg
end