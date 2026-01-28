local isSelling = false

function openMarket(marketId)
    Utils.hideInteractionMenu()
    local marketItems = TriggerServerPromise(Utils.eventsPrefix .. ":getMarketItems", marketId)
    
    if not marketItems then
        marketItems = {}
    end
    
    if #marketItems == 0 then
        table.insert(marketItems, {
            label = getLocalizedText("nothing_can_be_sold_yet")
        })
    end
    
    Utils.openInteractionMenu("market", getLocalizedText("market"), marketItems, function(selected, scrollIndex, args)
        local itemName = args.value
        if not itemName then
            return
        end
        
        if config.marketSellOnePerTime then
            local quantity = Utils.askQuantity(getLocalizedText("market:how_many_to_sell"), 1, nil)
            if not quantity then
                return
            end
            TriggerServerEvent(Utils.eventsPrefix .. ":sellMarketItem", marketId, itemName, quantity)
        else
            TriggerServerEvent(Utils.eventsPrefix .. ":sellMarketItem", marketId, itemName, 1)
        end
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function sellingLoop()
    while isSelling do
        showHelpNotification(getLocalizedText("press_to_stop"))
        
        if IsControlJustReleased(0, 38) then
            TriggerServerEvent(Utils.eventsPrefix .. ":market:stopSelling")
            stopTimedFreeze()
            Dialogs.stopProgressBar()
        end
        
        Citizen.Wait(0)
    end
end

RegisterNetEvent(Utils.eventsPrefix .. ":market:toggleSelling", function(selling)
    isSelling = selling
    if isSelling then
        Citizen.CreateThread(sellingLoop)
    end
end)