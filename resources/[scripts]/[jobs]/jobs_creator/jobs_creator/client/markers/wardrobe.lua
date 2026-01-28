local function openPlayerDressing()
    local wardrobeData = TriggerServerPromise(Utils.eventsPrefix .. ":getPlayerWardrobe")
    local outfits = wardrobeData.outfits
    local propertyOutfits = wardrobeData.propertyOutfits
    local elements = {}
    
    for outfitId, outfit in pairs(outfits) do
        table.insert(elements, {
            label = outfit.label,
            id = outfitId,
            outfit = outfit.outfit,
            isPropertyOutfit = false
        })
    end
    
    local framework = Framework.getFramework()
    if framework == "ESX" then
        for outfitId, outfit in pairs(propertyOutfits) do
            table.insert(elements, {
                label = outfit.label,
                id = outfitId,
                outfit = outfit.skin,
                isPropertyOutfit = true
            })
        end
    else
        framework = Framework.getFramework()
        if framework == "QB-core" then
            for outfitId, outfit in pairs(propertyOutfits) do
                table.insert(elements, {
                    label = outfit.outfitname,
                    id = outfit.id,
                    outfit = outfit.skin,
                    isPropertyOutfit = true
                })
            end
        end
    end
    
    if #elements == 0 then
        table.insert(elements, {
            label = getLocalizedText("wardrobe:empty")
        })
    end
    
    Utils.openInteractionMenu("player_dressing", getLocalizedText("player_clothes"), elements, function(selected, scrollIndex, args)
        local outfit = args.outfit
        if not outfit then
            return
        end
        setClothes(outfit, true)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function removeOutfit()
    local wardrobeData = TriggerServerPromise(Utils.eventsPrefix .. ":getPlayerWardrobe")
    local outfits = wardrobeData.outfits
    local propertyOutfits = wardrobeData.propertyOutfits
    local elements = {}
    
    for outfitId, outfit in pairs(outfits) do
        table.insert(elements, {
            label = getLocalizedText("wardrobe:delete", outfit.label),
            id = outfitId,
            outfit = outfit.outfit,
            isPropertyOutfit = false
        })
    end
    
    local framework = Framework.getFramework()
    if framework == "ESX" then
        for outfitId, outfit in pairs(propertyOutfits) do
            table.insert(elements, {
                label = getLocalizedText("wardrobe:delete", outfit.label),
                id = outfitId,
                outfit = outfit.skin,
                isPropertyOutfit = true
            })
        end
    else
        framework = Framework.getFramework()
        if framework == "QB-core" then
            for outfitId, outfit in pairs(propertyOutfits) do
                table.insert(elements, {
                    label = getLocalizedText("wardrobe:delete", outfit.outfitname),
                    id = outfit.id,
                    outfit = outfit.skin,
                    isPropertyOutfit = true
                })
            end
        end
    end
    
    if #elements == 0 then
        table.insert(elements, {
            label = getLocalizedText("wardrobe:empty")
        })
    end
    
    Utils.openInteractionMenu("remove_cloth", getLocalizedText("remove_cloth"), elements, function(selected, scrollIndex, args)
        local outfitId = args.id
        local isPropertyOutfit = args.isPropertyOutfit
        if not outfitId then
            return
        end
        
        if isPropertyOutfit then
            TriggerServerEvent(Utils.eventsPrefix .. ":wardrobe:deletePropertyOutfit", outfitId)
        else
            TriggerServerEvent(Utils.eventsPrefix .. ":wardrobe:deleteOutfit", outfitId)
        end
        
        notifyClient(getLocalizedText("delete_outfit"))
    end, function()
        Utils.hideInteractionMenu()
    end)
end

function openWardrobe()
    if config.modules.outfits ~= "default" then
        Utils.callModuleFunc("outfits", "openWardrobe")
        return
    end
    
    Utils.hideInteractionMenu()
    Utils.openInteractionMenu("wardrobe", getLocalizedText("wardrobe"), {
        {
            label = getLocalizedText("player_clothes"),
            value = "player_dressing"
        },
        {
            label = getLocalizedText("remove_cloth"),
            value = "remove_cloth"
        },
        {
            label = getLocalizedText("save_cloth"),
            value = "save_cloth"
        }
    }, function(selected, scrollIndex, args)
        local action = args.value
        if action == "player_dressing" then
            openPlayerDressing()
        elseif action == "remove_cloth" then
            removeOutfit()
        elseif action == "save_cloth" then
            local outfitName = Utils.askInput(getLocalizedText("outfit_name"))
            if outfitName then
                local currentSkin = Framework.getPlayerSkin()
                if currentSkin then
                    TriggerServerEvent(Utils.eventsPrefix .. ":saveNewOutfitInWardrobe", currentSkin, outfitName)
                end
            else
                notifyClient(getLocalizedText("outfit_label_empty"))
            end
        end
    end, function()
        Utils.hideInteractionMenu()
    end)
end