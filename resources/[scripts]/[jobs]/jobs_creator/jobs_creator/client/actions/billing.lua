local function createBilling(ped)
    local billingScript = Utils.getScriptName("billing_ui")
    
    if billingScript then
        local resourceState = GetResourceState(billingScript)
        if resourceState == "started" then
            Utils.hideInteractionMenu()
            TriggerEvent("billing_ui:activateBillingMode")
            return
        end
    end
    
    local reason = ""
    local framework = Framework.getFramework()
    if framework == "ESX" then
        reason = Utils.askInput(getLocalizedText("billing_reason"))
    end
    
    local amount = Utils.askQuantity(getLocalizedText("billing_amount"), 1, nil)
    if not amount or not reason then
        return
    end
    
    local targetServerId = Utils.getPlayerServerIdFromPed(ped)
    if not targetServerId then
        targetServerId = Framework.getClosestPlayer(true, 4.0)
    end
    
    if not targetServerId then
        notifyClient(getLocalizedText("no_players_nearby"))
        return
    end
    
    TriggerServerCallback(Utils.eventsPrefix .. ":getJobInfo", function(jobName, societyName)
        framework = Framework.getFramework()
        if framework == "ESX" then
            TriggerServerEvent(
                EXTERNAL_EVENTS_NAMES["esx_billing:sendBill"],
                targetServerId,
                "society_" .. jobName,
                societyName .. " - " .. reason,
                amount
            )
        else
            framework = Framework.getFramework()
            if framework == "QB-core" then
                ExecuteCommand("bill " .. targetServerId .. " " .. amount)
            end
        end
        
        notifyClient(getLocalizedText("invoice_sent", Framework.groupDigits(amount)))
    end)
end

addScriptRemovableEvent(
    RegisterNetEvent(Utils.eventsPrefix .. ":actions:createBilling", createBilling)
)