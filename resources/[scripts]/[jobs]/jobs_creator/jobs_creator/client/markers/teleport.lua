function teleportMarker(markerId)
    TriggerServerCallback(Utils.eventsPrefix .. ":getTeleportCoords", function(coords)
        if not coords then
            return
        end
        
        local playerPed = PlayerPedId()
        local entityToTeleport = playerPed
        
        DoScreenFadeOut(500)
        Citizen.Wait(750)
        
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle and vehicle > 0 then
            entityToTeleport = vehicle
        end
        
        SetEntityCoords(
            entityToTeleport,
            coords.x + 0.0,
            coords.y + 0.0,
            coords.z + 0.0,
            0.0, 0.0, 0.0,
            false
        )
        
        Citizen.Wait(750)
        DoScreenFadeIn(500)
    end, markerId)
end