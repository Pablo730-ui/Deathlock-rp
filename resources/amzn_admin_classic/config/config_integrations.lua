-- You can change the following functions to your own functions if you have any third party scripts
Config.Integrations = {}

-- Change this to your own custom function if you have a third party script that handles fuel.
Config.Integrations.FillFuel = function(vehicle) -- This is a client function
    -- This for for QBox / ox_fuel
    if GetResourceState('ox_fuel') == 'started' then
        Entity(vehicle).state.fuel = 100
        SetVehicleFuelLevel(vehicle, 100.0)
        return
    end

    print('[^3INFO^7] No fuel resource found for 919-admin integration. Please add one to ^3config_integrations.lua^7')
end

-- Change this to your own custom function if you have a third party script that handles clothing menu.
Config.Integrations.Clothing = function(player) -- This is a server function
    if GetResourceState('rcore_clothing') == 'started' then
        TriggerClientEvent('rcore_clothing:openClothingShopWithEverythingAndFree', player)
        return
    end

    if GetResourceState('qb-clothing') == 'started' then
        TriggerClientEvent('qb-clothing:client:openMenu', player)
        return
    end

    if GetResourceState('illenium-appearance') == 'started' then
        TriggerClientEvent('illenium-appearance:client:openClothingShop', player, true)
        return
    end

    print('[^3INFO^7] No clothing resource found for 919-admin integration. Please add one to ^3config_integrations.lua^7')
end

-- Change this to your own custom function if you have a third party script that handles vehicle keys.
Config.Integrations.GiveVehicleKeys = function(vehicleId) -- This is a client function and only applies to QBCore and ESX - not used for QBox
    -- This is for QBCore
    if GetResourceState('qb-vehiclekeys') or GetResourceState('qbx_vehiclekeys') == 'started' then
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicleId))
        return
    end

    print('[^3INFO^7] No vehicle keys resource found for 919-admin integration. Please add one to ^3config_integrations.lua^7')
end

-- Change this to your own custom function if you have a third party script that handles revives.
Config.Integrations.Revive = function(targetId) -- This is a server function
    if GetResourceState('wasabi_ambulance') == 'started' then
        exports.wasabi_ambulance:RevivePlayer(targetId)
        return
    end

    -- This is for QBox / qbx_medical
    if GetResourceState('qbx_medical') == 'started' then
        TriggerClientEvent('qbx_medical:client:playerRevived', targetId)
        return
    end

    if GetResourceState('qb-ambulancejob') == 'started' then
        TriggerClientEvent('hospital:client:Revive', targetId)
        return
    end

    if GetResourceState('esx_ambulancejob') == 'started' then
        TriggerClientEvent('esx_ambulancejob:revive', targetId)
        return
    end

    print('[^3INFO^7] No revive resource found for 919-admin integration. Please add one to ^3config_integrations.lua^7')
end

-- Change this to your own custom function if you have a third party script that handles cuffs.
Config.Integrations.Cuff = function(target) -- This is a server function
    if GetResourceState('qb-policejob') == 'started' then
        TriggerClientEvent('police:client:GetCuffed', target)
        return
    end

    if GetResourceState('esx_policejob') == 'started' then
        TriggerClientEvent('esx_policejob:handcuff', target)
        return
    end

    print('[^3INFO^7] No cuff resource found for 919-admin integration. Please add one to ^3config_integrations.lua^7')
end

-- If you want to use a different no clip script, you can set this to true.
-- Make sure to set the function below to your own custom function.
Config.Integrations.UseCustomNoClip = false

Config.Integrations.NoClip = function(toggle, invisible)
    if not Config.Integrations.UseCustomNoClip then
        toggleFreecam(toggle, invisible)
    end

    -- If you want to use a different no clip script, you can add it below.
    -- Make sure to set Config.Integrations.UseCustomNoClip to true.
    -- parameter toggle: boolean
    -- you probably don't need to use the invisible parameter.
    -- ADD CUSTOM NO CLIP FUNCTION HERE:
    --

end

Config.Integrations.GodModeToggle = function(toggle)
    -- This can be ignored, as it was a customer request to add custom code related to their godmode implementation.
end