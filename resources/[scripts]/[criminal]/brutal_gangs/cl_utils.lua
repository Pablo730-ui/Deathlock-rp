ESX = Core
QBCore = Core

-- Buy here: (4€+VAT) https://store.brutalscripts.com
function notification(title, text, time, type)
    if Config.BrutalNotify then
        exports['brutal_notify']:SendAlert(title, text, time, type)
    else
        -- Put here your own notify and set the Config.BrutalNotify to false
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(0,1)

        -- Default ESX Notify:
        --TriggerEvent('esx:showNotification', text)

        -- Default QB Notify:
        --TriggerEvent('QBCore:Notify', text, 'info', 5000)

        -- OKOK Notify:
        -- exports['okokNotify']:Alert('Gangs', text, time, type, false)

    end
end

function TextUIFunction(type, text)
    if type == 'open' then
        if Config.TextUI:lower() == 'ox_lib' then
            lib.showTextUI(text)
        elseif Config.TextUI:lower() == 'okoktextui' then
            exports['okokTextUI']:Open(text, 'darkblue', 'right')
        elseif Config.TextUI:lower() == 'esxtextui' then
            ESX.TextUI(text)
        elseif Config.TextUI:lower() == 'qbdrawtext' then
            exports['qb-core']:DrawText(text,'left')
        elseif Config.TextUI:lower() == 'brutal_textui' then
            exports['brutal_textui']:Open(text, "blue")
        end
    elseif type == 'hide' then
        if Config.TextUI:lower() == 'ox_lib' then
            lib.hideTextUI()
        elseif Config.TextUI:lower() == 'okoktextui' then
            exports['okokTextUI']:Close()
        elseif Config.TextUI:lower() == 'esxtextui' then
            ESX.HideUI()
        elseif Config.TextUI:lower() == 'qbdrawtext' then
            exports['qb-core']:HideText()
        elseif Config.TextUI:lower() == 'brutal_textui' then
            exports['brutal_textui']:Close()
        end
    end
end

function InventoryOpenFunction(type, job, size)
    if type == 'stash' then
        if Config.Inventory:lower() == 'ox_inventory' then
            exports.ox_inventory:openInventory('stash', { id = "stash_"..job})
        elseif Config.Inventory:lower() == 'qb_inventory' then
            if GetResourceState('qb-inventory') == "started" then
                TriggerServerEvent("brutal_gangs:qb-inventory:server:OpenInventory", "stash_"..job, {label = Config.Locales.Stashes, maxweight = size*1000, slots = 100})
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", "stash_"..job, {label = Config.Locales.Stashes, maxweight = size*1000, slots = 100})
                TriggerEvent("inventory:client:SetCurrentStash", "stash_"..job)
            end
        elseif Config.Inventory:lower() == 'quasar_inventory' then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", "stash_"..job, { label = Config.Locales.Stashes, maxweight = size*1000, slots = 100 })
            TriggerEvent("inventory:client:SetCurrentStash", "stash_"..job)
        elseif Config.Inventory:lower() == 'codem_inventory' then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", "stash_"..job, { label = Config.Locales.Stashes, maxweight = size*1000, slots = 100 })
            TriggerEvent("inventory:client:SetCurrentStash", "stash_"..job)
        elseif Config.Inventory:lower() == 'chezza_inventory' then
            TriggerEvent('inventory:openStorage', Config.Locales.Stashes, "stash_"..job, size, 1000, {job})
        elseif Config.Inventory:lower() == 'core_inventory' then
            TriggerServerEvent('core_inventory:server:openInventory', "stash_"..job, "big_storage")
        elseif Config.Inventory:lower() == 'origen_inventory' then
            exports.origen_inventory:openInventory("stash", "stash_"..job, {label = Config.Locales.Stashes, maxweight = size*1000, slots = 100})
        elseif Config.Inventory:lower() == 'ps-inventory' then
            if GetResourceState('ps-inventory') == "started" then
                TriggerServerEvent("ps-inventory:server:OpenInventory", "stash_"..job, {label = Config.Locales.Stashes, maxweight = size*1000, slots = 100})
                TriggerEvent("ps-inventory:client:SetCurrentStash", "stash_"..job)
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", "stash_"..job, {label = Config.Locales.Stashes, maxweight = size*1000, slots = 100})
                TriggerEvent("inventory:client:SetCurrentStash", "stash_"..job)
            end
        elseif Config.Inventory:lower() == 'tgiann-inventory' then
            exports["tgiann-inventory"]:OpenInventory("stash", "stash_"..job, {label = Config.Locales.Stashes, maxweight = size*1000, slots = 100})
        end
    elseif type == 'safe' then
        if Config.Inventory:lower() == 'ox_inventory' then
            exports.ox_inventory:openInventory('stash', { id = "safe_"..job})
        elseif Config.Inventory:lower() == 'qb_inventory' then
            if GetResourceState('qb-inventory') == "started" then
                TriggerServerEvent("brutal_gangs:qb-inventory:server:OpenInventory", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
                TriggerEvent("inventory:client:SetCurrentStash", "safe_"..job)
            end
        elseif Config.Inventory:lower() == 'quasar_inventory' then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
            TriggerEvent("inventory:client:SetCurrentStash", "safe_"..job)
        elseif Config.Inventory:lower() == 'codem_inventory' then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
            TriggerEvent("inventory:client:SetCurrentStash", "safe_"..job)
        elseif Config.Inventory:lower() == 'chezza_inventory' then
            TriggerEvent('inventory:openStorage', Config.Locales.Stashes, "safe_"..job, size, 1000, {job})
        elseif Config.Inventory:lower() == 'core_inventory' then
            TriggerServerEvent('core_inventory:server:openInventory', "safe_"..job, "stash")
        elseif Config.Inventory:lower() == 'origen_inventory' then
            exports.origen_inventory:openInventory("stash", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
        elseif Config.Inventory:lower() == 'ps-inventory' then
            if GetResourceState('ps-inventory') == "started" then
                TriggerServerEvent("ps-inventory:server:OpenInventory", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
                TriggerEvent("ps-inventory:client:SetCurrentStash", "safe_"..job)
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
                TriggerEvent("inventory:client:SetCurrentStash", "safe_"..job)
            end
        elseif Config.Inventory:lower() == 'tgiann-inventory' then
            exports["tgiann-inventory"]:OpenInventory("stash", "safe_"..job, {label = Config.Locales.Safe, maxweight = size*1000, slots = 50})
        end
    end
end

function OpenDressingMenu()
    if Config.Wardrobe == 'ak47_clothing' then
        exports['ak47_clothing']:openOutfit() -- if it doesn't work with this export use other event
        -- TriggerEvent('ak47_clothing:openOutfitMenu') -- Use this only if the first export doesn't work, depend of you'r version
    elseif Config.Wardrobe == 'codem_apperance' then 
        TriggerEvent('codem-apperance:OpenWardrobe')
    elseif Config.Wardrobe == 'fivem_appearance' then 
        exports['fivem-appearance']:openWardrobe()
    elseif Config.Wardrobe == 'illenium_appearance' then 
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
    elseif Config.Wardrobe == 'qb_clothing' then 
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    elseif Config.Wardrobe == 'raid_clothes' then 
        TriggerEvent('raid_clothes:openmenu')
    elseif Config.Wardrobe == 'rcore_clothes' then 
        TriggerEvent('rcore_clothes:openOutfits')
    elseif Config.Wardrobe == 'rcore_clothing' then 
        TriggerEvent('rcore_clothing:openChangingRoom')
    elseif Config.Wardrobe == 'sleek_clothestore' then 
        exports['sleek-clothestore']:OpenWardrobe()
    elseif Config.Wardrobe == 'tgiann_clothing' then 
        TriggerEvent('tgiann-clothing:openOutfitMenu')
    end
end

function setPlayerSkin(skinTable)
    if Config['Core']:upper() == 'ESX' then
        TriggerEvent('skinchanger:loadSkin', skinTable.skin)
    elseif Config['Core']:upper() == 'QBCORE' then
        TriggerEvent("qb-clothes:loadSkin", false, tonumber(skinTable.model), skinTable.skin)
        TriggerServerEvent("brutal_gangs:server:qbcore-loadPlayerSkin", tonumber(skinTable.model), skinTable.skin)
    end
end

RegisterNetEvent('brutal_gangs:client:utils:CreateVehicle')
AddEventHandler('brutal_gangs:client:utils:CreateVehicle', function(Vehicle)
    local plate = GetVehicleNumberPlateText(Vehicle)

    SetVehicleFuelLevel(Vehicle, 100.0)
    DecorSetFloat(Vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(Vehicle))

    if Config.BrutalKeys and GetResourceState("brutal_keys") == "started" then 
        exports.brutal_keys:addVehicleKey(plate, plate) 
    end

    if Config['Core']:upper() == 'QBCORE' then
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Vehicle))
    end
end)

RegisterNetEvent('brutal_gangs:client:utils:DeleteVehicle')
AddEventHandler('brutal_gangs:client:utils:DeleteVehicle', function(Vehicle)
    local plate = GetVehicleNumberPlateText(Vehicle)

    if Config.BrutalKeys and GetResourceState("brutal_keys") == "started" then 
		exports.brutal_keys:removeKey(plate, true) 
	end	

    DeleteEntity(Vehicle)
end)

function OpenMenuUtil()
    InMenu = true
    SetNuiFocus(true, true)

    Citizen.CreateThread(function()
        while InMenu do
            N_0xf4f2c0d4ee209e20() -- it's disable the AFK camera zoom
            Citizen.Wait(15000)
        end 
    end)

    DisplayRadar(false)
end

function DisableMinimap()
    DisplayRadar(false)
    -- Here you can add a trigger to hide your HUD system
end

function EnableMinimap()
    DisplayRadar(true)
    -- Here you can add a trigger to enable your HUD system
end

RegisterNetEvent('brutal_gangs:client:utils:StartExternalTask')
AddEventHandler('brutal_gangs:client:utils:StartExternalTask', function()
    -- Put here any robbery or heist you want to start from the gangmenu 
end)