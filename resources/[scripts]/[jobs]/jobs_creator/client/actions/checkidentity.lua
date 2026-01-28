local function checkIdentity(ped)
    local targetServerId = Utils.getPlayerServerIdFromPed(ped)
    if not targetServerId then
        targetServerId = Framework.getClosestPlayer(true, 2.0)
    end
    
    if not targetServerId then
        notifyClient(getLocalizedText("actions:no_player_found"))
        return
    end
    
    if config.useJSFourIdCard then
        TriggerServerEvent(
            EXTERNAL_EVENTS_NAMES["jsfour-idcard:open"],
            targetServerId,
            GetPlayerServerId(PlayerId())
        )
        Utils.hideInteractionMenu()
    else
        TriggerServerEvent(Utils.eventsPrefix .. ":actions:checkIdentity", targetServerId)
    end
end

RegisterNetEvent(Utils.eventsPrefix .. ":actions:checkIdentity", checkIdentity)