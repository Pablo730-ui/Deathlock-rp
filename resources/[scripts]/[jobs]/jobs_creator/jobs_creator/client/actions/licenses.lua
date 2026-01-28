RegisterNetEvent(Utils.eventsPrefix .. ":actions:checkPlayerLicenses", function(ped, licenseCategory)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetServerId = Utils.getPlayerServerIdFromPed(ped)
    if not targetServerId then
        targetServerId = Framework.getClosestPlayer(true, 3.0)
    end
    
    if not targetServerId then
        notifyClient(getLocalizedText("actions:no_player_found"))
        return
    end
    
    if config.useJSFourIdCard then
        TriggerServerEvent(
            EXTERNAL_EVENTS_NAMES["jsfour-idcard:open"],
            targetServerId,
            GetPlayerServerId(PlayerId()),
            licenseCategory
        )
        Utils.hideInteractionMenu()
        return
    end
    
    local playerLicenses = Framework.getPlayerLicenses(targetServerId)
    local elements = {}
    local framework = Framework.getFramework()
    
    if framework == "ESX" then
        for _, license in pairs(playerLicenses) do
            if config.licenses[licenseCategory] and config.licenses[licenseCategory][license.type] then
                table.insert(elements, {
                    label = getLocalizedText("actions:license", license.label)
                })
            end
        end
    else
        framework = Framework.getFramework()
        if framework == "QB-core" then
            for licenseKey, licenseValue in pairs(playerLicenses) do
                if config.licenses[licenseCategory] and config.licenses[licenseCategory][licenseKey] then
                    table.insert(elements, {
                        label = getLocalizedText("actions:license", Utils.firstToUpper(licenseKey))
                    })
                end
            end
        end
    end
    
    if #elements == 0 then
        table.insert(elements, {
            label = getLocalizedText("actions:no_license_found")
        })
    end
    
    Utils.openInteractionMenu("actions_license_menu_check", getLocalizedText("actions:licenses"), elements, nil)
end)

local function getESXLicensesList()
    local promiseObj = promise.new()
    TriggerServerCallback("esx_license:getLicensesList", function(licenses)
        promiseObj:resolve(licenses)
    end)
    return Citizen.Await(promiseObj)
end

local function openLicenseGiveRemoveMenu(targetServerId, licenseCategory)
    local availableLicenses = {}
    local framework = Framework.getFramework()
    
    if framework == "ESX" then
        availableLicenses = getESXLicensesList()
    else
        framework = Framework.getFramework()
        if framework == "QB-core" then
            availableLicenses = config.licenses[licenseCategory]
        end
    end
    
    local playerLicenses = Framework.getPlayerLicenses(targetServerId)
    local elements = {}
    framework = Framework.getFramework()
    
    if framework == "ESX" then
        for _, availableLicense in pairs(availableLicenses) do
            if config.licenses[licenseCategory] and config.licenses[licenseCategory][availableLicense.type] then
                local hasLicense = false
                for _, playerLicense in pairs(playerLicenses) do
                    if playerLicense.type == availableLicense.type then
                        hasLicense = true
                        break
                    end
                end
                
                local prefix = hasLicense and "[+]" or "[-]"
                table.insert(elements, {
                    label = prefix .. availableLicense.label,
                    type = availableLicense.type,
                    owned = hasLicense,
                    licenseLabel = availableLicense.label
                })
            end
        end
    else
        framework = Framework.getFramework()
        if framework == "QB-core" then
            for licenseKey, _ in pairs(availableLicenses) do
                if playerLicenses[licenseKey] ~= nil then
                    local hasLicense = false
                    for key, value in pairs(playerLicenses) do
                        if licenseKey == key and value then
                            hasLicense = true
                            break
                        end
                    end
                    
                    local prefix = hasLicense and "[+]" or "[-]"
                    local licenseLabel = Utils.firstToUpper(licenseKey)
                    table.insert(elements, {
                        label = prefix .. licenseLabel,
                        type = licenseKey,
                        owned = hasLicense,
                        licenseLabel = licenseLabel
                    })
                end
            end
        end
    end
    
    Utils.openInteractionMenu("license_give_remove_menu", getLocalizedText("actions_menu"), elements, function(selected, scrollIndex, args)
        local licenseType = args.type
        local isOwned = args.owned
        local licenseLabel = args.licenseLabel
        
        if isOwned then
            Framework.removeLicenseFromPlayer(targetServerId, licenseType)
            notifyClient(getLocalizedText("actions:removed_license", licenseLabel))
        else
            Framework.giveLicenseToPlayer(targetServerId, licenseType)
            notifyClient(getLocalizedText("actions:gave_license", licenseLabel))
        end
        
        openLicenseGiveRemoveMenu(targetServerId, licenseCategory)
    end)
end

function openLicenseMenu(licenseCategory)
    Utils.openInteractionMenu("actions_license_menu", getLocalizedText("actions_menu"), {
        {
            label = getLocalizedText("actions:license:give_remove"),
            value = "license_give_remove"
        },
        {
            label = getLocalizedText("actions:check_licenses"),
            value = "checklicenses"
        }
    }, function(selected, scrollIndex, args)
        local action = args.value
        if action == "license_give_remove" then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closestPlayer = Framework.getClosestPlayer(true, 3.0)
            if not closestPlayer then
                notifyClient(getLocalizedText("actions:no_player_found"))
                return
            end
            openLicenseGiveRemoveMenu(closestPlayer, licenseCategory)
        elseif action == "checklicenses" then
            TriggerEvent(Utils.eventsPrefix .. ":actions:checkPlayerLicenses", nil, licenseCategory)
        end
    end)
end