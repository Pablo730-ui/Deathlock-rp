function GetCurrentBankAmount(src)
    return exports["SDC_Core"]:GetCurrentBankAmount(src)
end

function GetCurrentCashAmount(src)
    return exports["SDC_Core"]:GetCurrentCashAmount(src)
end

function RemoveBankMoney(src, amt)
    return exports["SDC_Core"]:RemoveBankMoney(src, amt)
end

function AddBankAmount(src, amt)
    return exports["SDC_Core"]:AddBankAmount(src, amt)
end

function RemoveCashMoney(src, amt)
    exports["SDC_Core"]:RemoveCashMoney(src, amt)
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

function SaveVehicleInDatabase(src, plate, vdata, vmodel)
    exports["SDC_Core"]:SaveVehicleInDatabase(src, plate, vdata, vmodel)
end

function GetRandomPlate()
    return exports["SDC_Core"]:GetRandomPlate()
end

function GetOwnerTag(src)
    return exports["SDC_Core"]:GetOwnerTag(src)
end




--Item Usage
CreateThread(function()
    for veh,dat in pairs(SDC.FTFoodExtras) do
        for id,tab in pairs(dat) do
            --Food
            for item,data in pairs(tab.FoodPrep) do
                exports["SDC_Core"]:RegisterUsableItem(item, "food", nil, true)
            end

            --Drinks
            for item,data in pairs(tab.DrinkPrep) do
                exports["SDC_Core"]:RegisterUsableItem(item, "drink", nil, true)
            end
        end
    end
end)