local info = {
    maxweight = 1000000,
    slots = 50
    -- label = "Stash" -- Uncomment this line if you want a fixed label
}

-- hc_inventory requirement for stash
RegisterNetEvent(Utils.eventsPrefix .. ":hc_inventory:server:stashNew",
                 function(stashId)
    local playerId = source
    local scriptName = Utils.getScriptName("hc_inventory")
    exports[scriptName]:openExternalStash(playerId, stashId, info)
end)

