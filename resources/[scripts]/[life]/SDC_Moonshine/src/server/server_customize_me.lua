function GetCurrentCashAmount(src)
    return exports["SDC_Core"]:GetCurrentCashAmount(src)
end

function RemoveCashMoney(src, amt)
    exports["SDC_Core"]:RemoveCashMoney(src, amt)
end

function GiveCashMoney(src, amt)
    exports["SDC_Core"]:AddCashAmount(src, amt)
end

function GiveItem(src, item, amt)
    exports["SDC_Core"]:GiveItem(src, item, amt)
end

function RemoveItem(src, item, amt)
    exports["SDC_Core"]:RemoveItem(src, item, amt)
end

function HasItemAmt(src, item, amt)
    return exports["SDC_Core"]:HasItemAmt(src, item, amt)
end

function GetItemAmt(src, item)
    return exports["SDC_Core"]:GetItemAmt(src, item)
end

function GetOwnerTag(src)
    return exports["SDC_Core"]:GetOwnerTag(src)
end


--Custom Functions (Requested By code.nz)
function CanPlaceBarrel(src, totalBarrelsCurrently)
    --Here you can integrate your own code (I will not help with this, totalBarrelsCurrently - is a numerical value of how many barrels the person currently has placed)

    return true
end


--Item Usage
Citizen.CreateThread(function()
    RegisterServerEvent("SDMS:Server:BarrelItemEvent")
    AddEventHandler("SDMS:Server:BarrelItemEvent", function(item, src)
        TriggerClientEvent("SDMS:Client:TryToPlaceBarrel", src)
    end)
    exports["SDC_Core"]:RegisterUsableItem(SDC.BarrelItem, "drink", "SDMS:Server:BarrelItemEvent", false)

    RegisterServerEvent("SDMS:Server:StillItemEvent")
    AddEventHandler("SDMS:Server:StillItemEvent", function(item, src)
        TriggerClientEvent("SDMS:Client:TryToPlaceStill", src)
    end)
    exports["SDC_Core"]:RegisterUsableItem(SDC.StillItem.StillMain, "drink", "SDMS:Server:StillItemEvent", false)

    RegisterServerEvent("SDMS:Server:MoonshineItemEvent")
    AddEventHandler("SDMS:Server:MoonshineItemEvent", function(item, src)
        local shine = nil
        for k,v in pairs(SDC.AllMoonshines) do
            if v.ProductItem == item then 
                shine = k
            end
        end
        TriggerClientEvent("SDMS:Client:DrinkShineAnim", src, shine)
    end)
    if SDC.EnableUseableItems then
        for k,v in pairs(SDC.AllMoonshines) do
            exports["SDC_Core"]:RegisterUsableItem(v.ProductItem, "drink", "SDMS:Server:MoonshineItemEvent", true)
        end
    end
end)


function PreWarnCops(coords, sellerid)
    if SDC.SaleNotificationForCops.Enabled and SDC.PreWarnCopsAboutSale then
        if SDC.DispatchResource == "none" then
            TriggerClientEvent("SDMS:Client:PreWarnCops", -1, coords) --Event In src/client/client_customize_me.lua
        elseif SDC.DispatchResource == "ps-dispatch" then
            TriggerClientEvent("SDMS:Client:PreWarnCops", sellerid, coords) --Event In src/client/client_customize_me.lua
        end
    end
end

function WarnCops(coords, sellerid)
    if SDC.SaleNotificationForCops.Enabled then
        if SDC.DispatchResource == "none" then
            TriggerClientEvent("SDMS:Client:WarnCops", -1, coords) --Event In src/client/client_customize_me.lua
        elseif SDC.DispatchResource == "ps-dispatch" then
            TriggerClientEvent("SDMS:Client:WarnCops", sellerid, coords) --Event In src/client/client_customize_me.lua
        end 
    end
end