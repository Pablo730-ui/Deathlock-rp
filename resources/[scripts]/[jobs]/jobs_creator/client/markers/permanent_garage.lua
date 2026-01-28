local garageType = "permanent_garage"

local function buyVehicle(garageId)
    local garageData = TriggerServerPromise(Utils.eventsPrefix .. ":getGarageBuyableData", garageId)
    local elements = {}
    
    if garageData.vehicles then
        for vehicleModel, price in pairs(garageData.vehicles) do
            local vehicleLabel = getVehicleNameFromModel(vehicleModel)
            table.insert(elements, {
                label = getLocalizedText("buyable_vehicle", vehicleLabel, Framework.groupDigits(price)),
                value = vehicleModel,
                price = price,
                vehicleLabel = vehicleLabel
            })
        end
    end
    
    if #elements == 0 then
        table.insert(elements, {
            label = getLocalizedText("permanent_garage:no_vehicle_to_buy")
        })
    end
    
    Utils.openInteractionMenu("job_garage_buyable", getLocalizedText("garage"), elements, function(selected, scrollIndex, args)
        local vehicleModel = args.value
        if not vehicleModel then
            return
        end
        
        local price = args.price
        local vehicleLabel = args.vehicleLabel
        
        Utils.openInteractionMenu("job_garage_confirm", getLocalizedText("are_you_sure", vehicleLabel, Framework.groupDigits(price)), {
            {
                label = getLocalizedText("yes"),
                value = "yes"
            },
            {
                label = getLocalizedText("no"),
                value = "no"
            }
        }, function(selected2, scrollIndex2, args2)
            Utils.hideInteractionMenu()
            if args2.value == "yes" then
                TriggerServerEvent(Utils.eventsPrefix .. ":buyVehicleFromGarage", garageId, vehicleModel)
                openGarageBuyable(garageId)
            end
        end, function()
            Utils.hideInteractionMenu()
        end)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function showOwnedVehicles(garageId)
    local playerPed = PlayerPedId()
    local garageData = TriggerServerPromise(Utils.eventsPrefix .. ":getGarageOwnedVehicles", garageId)
    local elements = {}
    
    if garageData.vehicles then
        for _, vehicleData in pairs(garageData.vehicles) do
            local vehicleModel = vehicleData.vehicle
            local vehicleName = getVehicleNameFromModel(vehicleModel)
            local plate = vehicleData.plate
            
            if plate then
                vehicleName = vehicleName .. " - " .. plate
            end
            
            if vehicleData.isOutside then
                vehicleName = getLocalizedText("buyable_vehicle:outside", vehicleName)
            end
            
            table.insert(elements, {
                label = vehicleName,
                vehicleName = vehicleModel,
                vehicleId = vehicleData.vehicleId,
                vehicleProps = vehicleData.vehicleProps,
                vehiclePlate = plate,
                isOutside = vehicleData.isOutside
            })
        end
    end
    
    if #elements == 0 then
        table.insert(elements, {
            label = getLocalizedText("no_vehicles_in_garage")
        })
    end
    
    Utils.openInteractionMenu("job_garage_owned", getLocalizedText("garage"), elements, function(selected, scrollIndex, args)
        local vehicleModel = args.vehicleName
        if not vehicleModel then
            return
        end
        
        if args.isOutside then
            notifyClient(getLocalizedText("vehicle_outside"))
            return
        end
        
        local vehicleProps = args.vehicleProps
        local vehicleId = args.vehicleId
        local vehiclePlate = args.vehiclePlate
        local spawnpoint = getFreeSpawnpoint(garageData.spawnPoints)
        
        if not spawnpoint then
            notifyClient(getLocalizedText("no_free_spawnpoints"))
            return
        end
        
        openedMenu = nil
        Utils.hideInteractionMenu()
        
        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do
            Citizen.Wait(0)
        end
        
        local vehicle = CreateVehicle(
            vehicleModel,
            spawnpoint.coords,
            spawnpoint.heading,
            true,
            false
        )
        
        SetEntityAsMissionEntity(vehicle, true, true)
        Framework.setVehicleProperties(vehicle, vehicleProps)
        
        if vehiclePlate then
            SetVehicleNumberPlateText(vehicle, vehiclePlate)
        end
        
        TaskEnterVehicle(playerPed, vehicle, 1000, -1, 2.0, 16, 0)
        
        TriggerServerEvent(
            Utils.eventsPrefix .. ":permanent_garage:vehicleIdSpawned",
            vehicleId,
            VehToNet(vehicle)
        )
        
        TriggerEvent(
            Utils.eventsPrefix .. ":permanent_garage:vehicleSpawned",
            vehicle,
            vehicleModel,
            GetVehicleNumberPlateText(vehicle)
        )
        
        addVehicleToOutsideVehicles(garageType, vehicle)
    end, function()
        openedMenu = nil
        Utils.hideInteractionMenu()
    end)
end

function openGarageBuyable(garageId)
    local playerPed = PlayerPedId()
    Utils.hideInteractionMenu()
    
    Utils.openInteractionMenu("job_garage_options", getLocalizedText("garage"), {
        {
            label = getLocalizedText("park_vehicle"),
            value = "deposit"
        },
        {
            label = getLocalizedText("garage"),
            value = "garage"
        },
        {
            label = getLocalizedText("buy_vehicle"),
            value = "buy"
        }
    }, function(selected, scrollIndex, args)
        local action = args.value
        if action == "buy" then
            buyVehicle(garageId)
        elseif action == "garage" then
            showOwnedVehicles(garageId)
        elseif action == "deposit" then
            local vehicle = nil
            if IsPedInAnyVehicle(playerPed, false) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
            else
                vehicle = getOutsideVehicleInRange(garageType)
            end
            
            if not DoesEntityExist(vehicle) then
                notifyClient(getLocalizedText("no_car_found"))
                return
            end
            
            local vehicleProps = Framework.getVehicleProperties(vehicle)
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            local vehicleModel = GetEntityModel(vehicle)
            
            local success = TriggerServerPromise(
                Utils.eventsPrefix .. ":permanent_garage:updateVehicleProps",
                garageId,
                VehToNet(vehicle),
                vehicleProps,
                vehiclePlate
            )
            
            if not success then
                return
            end
            
            deleteVehicleFromOutsideVehicles(garageType, vehicle)
            TriggerEvent(Utils.eventsPrefix .. ":permanent_garage:vehicleParked", vehicleModel, vehiclePlate)
            openedMenu = nil
        end
    end, function()
        openedMenu = nil
        Utils.hideInteractionMenu()
    end)
end