function openShop(shopId)
    local shopData = TriggerServerPromise(Utils.eventsPrefix .. ":getShopData", shopId)
    Utils.hideInteractionMenu()
    Utils.openInteractionMenu("job_shop", getLocalizedText("job_shop"), shopData, function(selected, scrollIndex, args)
        local itemValue = args.value
        local itemType = args.itemType
        if not itemValue then
            return
        end
        
        if itemType == "item" then
            local quantity = Utils.askQuantity(getLocalizedText("quantity"), 1, nil)
            if not quantity then
                return
            end
            TriggerServerEvent(Utils.eventsPrefix .. ":buyShopItem", shopId, itemValue, quantity)
        elseif itemType == "weapon" then
            TriggerServerEvent(Utils.eventsPrefix .. ":buyShopItem", shopId, itemValue, 1)
        end
    end, function()
        Utils.hideInteractionMenu()
    end)
end