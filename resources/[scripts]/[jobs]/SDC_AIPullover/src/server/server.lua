local pullovers = {}

RegisterServerEvent("SDAP:Server:GetPullovers")
AddEventHandler("SDAP:Server:GetPullovers", function()
    local src = source

    TriggerClientEvent("SDAP:Client:UpdatedPullovers", src, nil, pullovers)
end)

RegisterServerEvent("SDAP:Server:PulloverStarted")
AddEventHandler("SDAP:Server:PulloverStarted", function(netid, netid2)
    local src = source

    pullovers[tostring(src)] = {Ped = netid, Veh = netid2}
    TriggerClientEvent("SDAP:Client:UpdatedPullovers", -1, tostring(src), pullovers[tostring(src)])
end)

RegisterServerEvent("SDAP:Server:PulloverFinished")
AddEventHandler("SDAP:Server:PulloverFinished", function(tt)
    local src = source
    if pullovers[tostring(src)] then
        pullovers[tostring(src)] = nil
        if tt and SDC.PayoutSettings[tt] then
            GiveCashMoney(src, SDC.PayoutSettings[tt])
        end

        TriggerClientEvent("SDAP:Client:UpdatedPullovers", -1, tostring(src), nil)
    end
end)

RegisterServerEvent("SDAP:Server:ChasePayout")
AddEventHandler("SDAP:Server:ChasePayout", function(tt)
    local src = source
    if tt and SDC.PayoutSettings[tt] then
        GiveCashMoney(src, SDC.PayoutSettings[tt])
    end
end)