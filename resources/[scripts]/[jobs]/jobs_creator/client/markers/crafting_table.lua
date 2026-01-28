
function openCraftingTable(markerId)
  local eventName = Utils.eventsPrefix .. ":getCraftingTableData"
  local craftingData = TriggerServerPromise(eventName, markerId)

  Utils.hideInteractionMenu()

  if #craftingData == 0 then
    table.insert(craftingData, { label = getLocalizedText("crafting_table:nothing_to_craft") })
  end

  print(json.encode(craftingData, { indent = true }))
  
  Utils.openInteractionMenu(
    "crafting_table",
    getLocalizedText("crafting_table"),
    craftingData,
    function(_, _, elementData)
      local craftingIndex = elementData.craftingIndex
      print(json.encode(elementData, { indent = true }))
      if not craftingIndex then return end

      print(json.encode(elementData.recipeElements, { indent = true }))

      Utils.openInteractionMenu(
        "crafting_table_recipe",
        getLocalizedText("crafting_table"),
        elementData.recipeElements,
        function(_, _, elementData2)
          if elementData2.type ~= "inputQuantity" then return end

          local quantity = Utils.askQuantity(getLocalizedText("craft_amount"), 1, nil)
          if not quantity then return end

          local eventName = Utils.eventsPrefix .. ":craftItem"
          TriggerServerEvent(eventName, markerId, craftingIndex, quantity)

          Utils.hideInteractionMenu()
        end
      )
    end,
    Utils.hideInteractionMenu
  )
end

function startCraftingProgress(duration, label)
  local isActive = true
  Dialogs.startProgressBar(duration, label)

  SetTimeout(duration, function()
    isActive = false
  end)

  local controlActions = {
    24, 257, 263, 32, 34, 31, 30, 45, 22, 44, 37, 23, 59,
    71, 72, 36, 47, 264, 257, 140, 141, 142, 143, 75
  }

  local isStopped = false

  while isActive do
    for i = 1, #controlActions do
      DisableControlAction(0, controlActions[i], true)
    end

    if not isStopped then
      showHelpNotification(getLocalizedText("press_to_stop"))
      if IsControlJustReleased(0, 38) then
        TriggerServerEvent(Utils.eventsPrefix .. ":stopCrafting")
        notifyClient(getLocalizedText("you_stopped"))
        isStopped = true
      end
    end

    Citizen.Wait(0)
  end
end

RegisterNetEvent(Utils.eventsPrefix .. ":crafting_table:startCrafting", startCraftingProgress)
