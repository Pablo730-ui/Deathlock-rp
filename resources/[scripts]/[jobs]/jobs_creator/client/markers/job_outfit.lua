local savedOutfit = nil

function openJobOutfit(markerId)
    if config.modules.outfits ~= "default" then
        local canOpen = Utils.callModuleFunc("outfits", "openExternalMenu")
        if canOpen then
            Utils.callModuleFunc("outfits", "openJobOutfits")
            return
        end
    end
    
    local outfits = TriggerServerPromise(Utils.eventsPrefix .. ":getJobOutfits", markerId)
    local elements = {}
    
    if #outfits > 0 then
        table.insert(elements, {
            label = getLocalizedText("civilian_outfit"),
            value = "civilian"
        })
        
        for _, outfit in pairs(outfits) do
            table.insert(elements, {
                label = outfit.label,
                value = outfit
            })
        end
    else
        table.insert(elements, {
            label = getLocalizedText("no_outfits")
        })
    end
    
    Utils.hideInteractionMenu()
    Utils.openInteractionMenu("job_outfit", getLocalizedText("job_outfit"), elements, function(selected, scrollIndex, args)
        local outfitValue = args.value
        if outfitValue == "civilian" then
            if savedOutfit then
                setClothes(savedOutfit)
                savedOutfit = nil
            end
        elseif outfitValue then
            if not savedOutfit then
                savedOutfit = Framework.getPlayerSkin()
            end
            
            local framework = Framework.getFramework()
            if framework == "QB-core" then
                if config.modules.outfits == "default" then
                    outfitValue = Framework.convertOutfitFromESXToQBCore(outfitValue)
                end
            end
            setClothes(outfitValue, false)
        end
    end, function()
        Utils.hideInteractionMenu()
    end)
end