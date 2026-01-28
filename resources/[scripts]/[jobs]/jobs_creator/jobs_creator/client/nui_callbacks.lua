RegisterNUICallback("getLocale", function(data, callback)
    while not config do
        Citizen.Wait(250)
    end
    callback(config.locale)
end)

RegisterNUICallback("get-current-coords", function(data, callback)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    coords = coords - vector3(0.0, 0.0, 1.0)
    local heading = string.format("%.2f", GetEntityHeading(playerPed))
    local strippedCoords = stripCoords(coords)
    callback({
        coords = strippedCoords,
        heading = heading
    })
end)

RegisterNUICallback("exit", function(data, callback)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("getJobGrades", function(data, callback)
    TriggerServerCallback(Utils.eventsPrefix .. ":getAllJobGrades", function(grades)
        callback(grades)
    end, data.jobName)
end)

RegisterNUICallback("getAllJobsOnlinePlayers", function(data, callback)
    TriggerServerCallback(Utils.eventsPrefix .. ":getAllJobsOnlinePlayers", function(players)
        callback(players)
    end)
end)

RegisterNUICallback("getAllJobsTotalPlayers", function(data, callback)
    TriggerServerCallback(Utils.eventsPrefix .. ":getAllJobsTotalPlayers", function(players)
        callback(players)
    end)
end)

RegisterNUICallback("getJobsSocietyMoney", function(data, callback)
    TriggerServerCallback(Utils.eventsPrefix .. ":getJobsSocietyMoney", function(money)
        callback(money)
    end)
end)

RegisterNUICallback("getRanksDistribution", function(data, callback)
    TriggerServerCallback(Utils.eventsPrefix .. ":getRanksDistribution", function(distribution)
        callback(distribution)
    end, data.jobName)
end)

RegisterNUICallback("create-new-rank", function(data, callback)
    local jobName = data.jobName
    local rankName = data.rankName
    local rankLabel = data.rankLabel
    local rankGrade = data.rankGrade
    local rankSalary = data.rankSalary
    
    TriggerServerCallback(Utils.eventsPrefix .. ":createRank", function(result)
        callback(result)
    end, jobName, rankName, rankLabel, rankGrade, rankSalary)
end)

RegisterNUICallback("updateRank", function(data, callback)
    TriggerServerCallback(Utils.eventsPrefix .. ":updateRank", function(result)
        callback(result)
    end, data)
end)

RegisterNUICallback("delete-rank", function(data, callback)
    local rankId = data.rankId
    TriggerServerCallback(Utils.eventsPrefix .. ":deleteRank", function(result)
        callback(result)
    end, rankId)
end)

RegisterNUICallback("retrieveJobRanks", function(data, callback)
    local jobName = data.jobName
    TriggerServerCallback(Utils.eventsPrefix .. ":retrieveJobRanks", function(ranks)
        callback(ranks)
    end, jobName)
end)

RegisterNUICallback("create-new-job", function(data, callback)
    if data then
        TriggerServerCallback(Utils.eventsPrefix .. ":createNewJob", function(result)
            callback(result)
        end, data.jobName, data.jobLabel)
    end
end)

RegisterNUICallback("update-job", function(data, callback)
    local oldJobName = data.oldJobName
    local jobName = data.jobName
    local jobLabel = data.jobLabel
    local actions = data.actions
    
    local result = TriggerServerPromise(
        Utils.eventsPrefix .. ":updateJob",
        oldJobName,
        jobName,
        jobLabel,
        actions
    )
    callback(result)
end)

RegisterNUICallback("delete-job", function(data, callback)
    local jobName = data.jobName
    if jobName then
        TriggerServerCallback(Utils.eventsPrefix .. ":deleteJob", function(result)
            callback(result)
        end, jobName)
    end
end)

RegisterNUICallback("getJobsData", function(data, callback)
    TriggerServerCallback(Utils.eventsPrefix .. ":getJobsData", function(jobsData)
        callback(jobsData)
    end)
end)

RegisterNUICallback("retrieveJobMarkers", function(data, callback)
    local jobName = data.jobName
    if not jobName then
        return
    end
    
    local markers = TriggerServerPromise(
        Utils.eventsPrefix .. ":getMarkersFromJobName",
        jobName
    )
    callback(markers)
end)

RegisterNUICallback("create-marker", function(data, callback)
    if data then
        local jobName = data.jobName
        local label = data.label
        local markerType = data.markerType
        local coords = {
            x = tonumber(data.markerCoordsX),
            y = tonumber(data.markerCoordsY),
            z = tonumber(data.markerCoordsZ)
        }
        local minGrade = tonumber(data.markerMinGrade)
        
        TriggerServerCallback(Utils.eventsPrefix .. ":createMarker", function(result)
            callback(result)
        end, jobName, label, markerType, coords, minGrade)
    end
end)

RegisterNUICallback("create-public-marker", function(data, callback)
    if data then
        local jobName = "public_marker"
        local minGrade = 0
        local label = data.label
        local markerType = data.markerType
        local coords = {
            x = tonumber(data.markerCoordsX),
            y = tonumber(data.markerCoordsY),
            z = tonumber(data.markerCoordsZ)
        }
        
        TriggerServerCallback(Utils.eventsPrefix .. ":createMarker", function(result)
            callback(result)
        end, jobName, label, markerType, coords, minGrade)
    end
end)

RegisterNUICallback("update-marker", function(data, callback)
    if data then
        local markerId = data.markerId
        TriggerServerCallback(Utils.eventsPrefix .. ":updateMarker", function(result)
            callback(result)
        end, markerId, data)
    end
end)

RegisterNUICallback("update-marker-data", function(data, callback)
    local markerId = data.markerId
    local markerData = data.markerData
    TriggerServerCallback(Utils.eventsPrefix .. ":updateMarkerData", function(result)
        callback(result)
    end, markerId, markerData)
end)

RegisterNUICallback("delete-marker", function(data, callback)
    local markerId = data.markerId
    TriggerServerCallback(Utils.eventsPrefix .. ":deleteMarker", function(result)
        callback(result)
    end, markerId)
end)

RegisterNUICallback("delete-stash-inventory", function(data, callback)
    local markerId = data.markerId
    TriggerServerCallback(Utils.eventsPrefix .. ":deleteStashInventory", function(result)
        callback(result)
    end, markerId)
end)

RegisterNUICallback("delete-armory-inventory", function(data, callback)
    local markerId = data.markerId
    TriggerServerCallback(Utils.eventsPrefix .. ":deleteArmoryInventory", function(result)
        callback(result)
    end, markerId)
end)

RegisterNUICallback("get-current-outfit", function(data, callback)
    local outfit = Framework.getPlayerSkin()
    local framework = Framework.getFramework()
    if framework == "QB-core" then
        if config.modules.outfits == "default" then
            outfit = Framework.convertOutfitFromQBCoreToESX(outfit)
        end
    end
    callback(outfit)
end)

RegisterNUICallback("get-vehicle-label", function(data, callback)
    callback(getVehicleNameFromModel(data.vehicleModel))
end)

RegisterNUICallback("getAllAccounts", function(data, callback)
    local accounts = TriggerServerPromise(Utils.eventsPrefix .. ":getAllAccounts")
    callback(accounts)
end)

RegisterNUICallback("getFramework", function(data, callback)
    callback(Framework.getFramework())
end)

RegisterNUICallback("getOpenExternalClothingMenu", function(data, callback)
    local canOpen = Utils.callModuleFunc("outfits", "openExternalMenu")
    callback(canOpen)
end)

RegisterNUICallback("getInventoryScriptUsed", function(data, callback)
    callback(INVENTORY_TO_USE)
end)

RegisterNUICallback("nexus/getJobs", function(data, callback)
    local jobs = TriggerServerPromise(Utils.eventsPrefix .. ":nexus:getJobs")
    callback(jobs)
end)

RegisterNUICallback("nexus/importJob", function(data, callback)
    local jobId = data.jobId
    local result = TriggerServerPromise(Utils.eventsPrefix .. ":nexus:importJob", jobId)
    callback(result)
end)

RegisterNUICallback("nexus/uploadJob", function(data, callback)
    local result = TriggerServerPromise(Utils.eventsPrefix .. ":nexus:uploadJob", data)
    callback(result)
end)

RegisterNUICallback("nexus/rateJob", function(data, callback)
    local jobId = data.jobId
    local rating = data.rating
    local result = TriggerServerPromise(Utils.eventsPrefix .. ":nexus:rateJob", jobId, rating)
    callback(result)
end)

RegisterNUICallback("teleportToMarker", function(data, callback)
    local markerId = data.markerId
    TriggerServerEvent(Utils.eventsPrefix .. ":teleportToMarker", markerId)
    callback(true)
end)