RegisterServerCallback(Utils.eventsPrefix .. ":getCraftingTableData", function(source, callback, markerId)
    local playerId = source
    if not canUseMarkerWithLog(playerId, markerId) then return end

    local markerData = JobsCreator.Markers[markerId]
    if markerData and markerData.data then markerData = markerData.data else markerData = {} end

    local craftableItems = markerData.craftablesItems
    local craftingData = {}
    if not craftableItems then callback(craftingData) return end

    for i = 1, #craftableItems do
        local craftableItem = craftableItems[i]
        local recipe = craftableItem.recipes or {}
        local recipeElements = {}
        local maxCraftable = 0

        for j = 1, #recipe do
            local ingredient = recipe[j]
            local playerCount = Framework.getPlayerGenericObjectCount(playerId, ingredient.object.name, ingredient.object.type)
            local itemLabel = Framework.getGenericObjectLabel(ingredient.object.name, ingredient.object.type)
            local requiredQuantity = ingredient.quantity
            local craftableCount = math.floor(playerCount / requiredQuantity)

            if maxCraftable > craftableCount or maxCraftable == 0 then
                maxCraftable = craftableCount
            end

            table.insert(recipeElements, {
                label = getLocalizedText("ingredient", itemLabel, playerCount, requiredQuantity),
                quantity = requiredQuantity,
                itemLabel = itemLabel,
                itemQuantity = playerCount
            })
        end

        table.insert(recipeElements, {
            label = getLocalizedText("craft_amount"),
            value = maxCraftable > 0 and 1 or 0,
            min = 1,
            max = maxCraftable,
            type = "inputQuantity"
        })

        table.insert(craftingData, {
            label = Framework.getGenericObjectLabel(craftableItem.resultObject.name, craftableItem.resultObject.type),
            craftingIndex = i,
            recipeElements = recipeElements
        })
    end

    callback(craftingData)
end)

function hasAllIngredients(playerId, recipe)
    for i = 1, #recipe do
        local ingredient = recipe[i]
        if not Framework.hasPlayerEnoughOfGenericObject(playerId, ingredient.object.name, ingredient.object.type, ingredient.quantity) then
            return false
        end
    end
    return true
end

local activeCrafting = {}
local isStopped = {}

RegisterNetEvent(Utils.eventsPrefix .. ":craftItem")
AddEventHandler(Utils.eventsPrefix .. ":craftItem", function(markerId, craftingIndex, quantity)
    local playerId = source
    if not quantity then quantity = 1 end

    if not isCloseToMarker(playerId, markerId) then return end
    if activeCrafting[playerId] then return end

    local markerData = JobsCreator.Markers[markerId]
    if markerData and markerData.data then markerData = markerData.data else markerData = {} end
    local craftableItems = markerData.craftablesItems
    if not craftableItems then return end

    local craftableItem = craftableItems[craftingIndex]
    local recipe = craftableItem.recipes
    local animations = craftableItem.animations or {}

    if not recipe then return end

    local resultLabel = Framework.getGenericObjectLabel(craftableItem.resultObject.name, craftableItem.resultObject.type)
    local resultQuantity = craftableItem.quantity or 1
    local craftingTime = craftableItem.craftingTime or 8

    if #animations == 0 then
        table.insert(animations, {
            type = "scenario",
            scenarioName = "PROP_HUMAN_BUM_BIN",
            scenarioDuration = craftingTime
        })
    end

    activeCrafting[playerId] = true

    for i = 1, quantity do
        if isStopped[playerId] then
            activeCrafting[playerId] = false
            isStopped[playerId] = false
            return
        end

        if not hasAllIngredients(playerId, recipe) then
            notify(playerId, getLocalizedText("dont_have_ingredients"))
            break
        end

        if not Framework.canPlayerCarryGenericObject(playerId, craftableItem.resultObject.name, craftableItem.resultObject.type, resultQuantity) then
            notify(playerId, getLocalizedText("no_space"))
            break
        end

        local totalTime = craftingTime * 1000
        TriggerClientEvent(Utils.eventsPrefix .. ":crafting_table:startCrafting", playerId, totalTime, getLocalizedText("crafting", resultLabel))
        playAnimation(playerId, animations)
        Citizen.Wait(totalTime)

        if not hasAllIngredients(playerId, recipe) then
            notify(playerId, getLocalizedText("dont_have_ingredients"))
            break
        end

        for _, ingredient in ipairs(recipe) do
            if ingredient.loseOnUse then
                Framework.removeGenericObjectFromPlayerId(
                    playerId,
                    ingredient.object.name,
                    ingredient.object.type,
                    ingredient.quantity
                )
            end
        end

        Framework.giveGenericObjectToPlayerId(playerId, craftableItem.resultObject, resultQuantity)
        notify(playerId, getLocalizedText("you_crafted", resultQuantity, resultLabel))

        Utils.log(
            playerId,
            getLocalizedText("log_crafted_item"),
            getLocalizedText(
                "log_crafted_item_description",
                resultQuantity,
                resultLabel,
                craftableItem.resultObject.name,
                markerId
            ),
            "success",
            "crafting_table"
        )

        TriggerEvent(
            Utils.eventsPrefix .. ":crafting_table:craftedItem",
            playerId,
            markerId,
            craftableItem.resultObject.name,
            resultQuantity
        )

        Citizen.Wait(2000)
    end

    activeCrafting[playerId] = false
end)

RegisterNetEvent(Utils.eventsPrefix .. ":stopCrafting")
AddEventHandler(Utils.eventsPrefix .. ":stopCrafting", function()
    local playerId = source
    isStopped[playerId] = true
end)
