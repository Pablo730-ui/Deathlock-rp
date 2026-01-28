local garageType = "temporary_garage"

local function takeVehicle(garageId)
    local garageData = TriggerServerPromise(Utils.eventsPrefix .. ":retrieveVehicles", garageId)
    if not garageData then
        return
    end
    
    local elements = {}
    for vehicleModel, vehicleData in pairs(garageData.vehicles) do
        local vehicleName = getVehicleNameFromModel(vehicleModel)
        local isOutside = vehicleData.isOutside
        if isOutside then
            vehicleName = getLocalizedText("buyable_vehicle:outside", vehicleName)
        end
        
        table.insert(elements, {
            label = vehicleName,
            value = vehicleModel,
            vehicleData = vehicleData,
            isOutside = isOutside
        })
    end
    
    if #elements == 0 then
        table.insert(elements, {
            label = getLocalizedText("no_vehicle")
        })
    end
    
    Utils.openInteractionMenu("garage_vehicles", getLocalizedText("garage"), elements, function(selected, scrollIndex, args)
        local vehicleModel = args.value
        if not vehicleModel then
            return
        end
        
        if args.isOutside then
            return
        end
        
        local vehicleData = args.vehicleData
        local spawnpoint = getFreeSpawnpoint(garageData.spawnPoints)
        if not spawnpoint then
            notifyClient(getLocalizedText("no_free_spawnpoints"))
            return
        end
        
        Utils.hideInteractionMenu()
        openedMenu = nil
        
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
        
        local playerPed = PlayerPedId()
        SetEntityAsMissionEntity(vehicle, true, true)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        
        local primaryR, primaryG, primaryB = getRGBFromHex(vehicleData.primaryColor)
        SetVehicleCustomPrimaryColour(vehicle, primaryR, primaryG, primaryB)
        
        local secondaryR, secondaryG, secondaryB = getRGBFromHex(vehicleData.secondaryColor)
        SetVehicleCustomSecondaryColour(vehicle, secondaryR, secondaryG, secondaryB)
        
        local plate = vehicleData.plate
        if not plate then
            plate = generatePlate()
        end
        SetVehicleNumberPlateText(vehicle, plate)
        
        if vehicleData.livery then
            local liveryCount = GetVehicleLiveryCount(vehicle)
            if liveryCount ~= -1 then
                SetVehicleLivery(vehicle, vehicleData.livery)
            else
                SetVehicleModKit(vehicle, 0)
                SetVehicleMod(vehicle, 48, vehicleData.livery, false)
            end
        end
        
        TriggerServerEvent(
            Utils.eventsPrefix .. ":temporary_garage:spawnedVehicle",
            garageId,
            vehicleModel,
            VehToNet(vehicle)
        )
        
        TriggerEvent(
            Utils.eventsPrefix .. ":temporary_garage:vehicleSpawned",
            vehicle,
            vehicleModel,
            GetVehicleNumberPlateText(vehicle)
        )
        
        addVehicleToOutsideVehicles(garageType, vehicle)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

function openGarage(garageId)
    Utils.hideInteractionMenu()
    local playerPed = PlayerPedId()
    
    Utils.openInteractionMenu("garage", getLocalizedText("garage"), {
        {
            label = getLocalizedText("take_vehicle"),
            value = "take_vehicle"
        },
        {
            label = getLocalizedText("park_vehicle"),
            value = "park_vehicle"
        }
    }, function(selected, scrollIndex, args)
        local action = args.value
        if action == "take_vehicle" then
            takeVehicle(garageId)
        elseif action == "park_vehicle" then
            local vehicle = nil
            if IsPedInAnyVehicle(playerPed, false) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
            else
                vehicle = getOutsideVehicleInRange(garageType)
            end
            
            local plate = GetVehicleNumberPlateText(vehicle)
            local vehicleModel = GetEntityModel(vehicle)
            
            if DoesEntityExist(vehicle) then
                Framework.deleteVehicle(vehicle)
                deleteVehicleFromOutsideVehicles(garageType, vehicle)
                TriggerEvent(Utils.eventsPrefix .. ":temporary_garage:vehicleParked", vehicleModel, plate)
            else
                notifyClient(getLocalizedText("no_car_found"))
            end
            
            openedMenu = nil
            Utils.hideInteractionMenu()
        end
    end, function()
        openedMenu = nil
        Utils.hideInteractionMenu()
    end)
end