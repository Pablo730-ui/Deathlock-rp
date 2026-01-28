local function depositWeapon(armoryId)
    local playerWeapons = TriggerServerPromise(Utils.eventsPrefix .. ":getPlayerWeapons")
    local elements = {}
    
    if #playerWeapons > 0 then
        for _, weapon in pairs(playerWeapons) do
            table.insert(elements, {
                label = getLocalizedText("weapon", weapon.label, weapon.ammo or 0),
                value = weapon.name
            })
        end
    else
        table.insert(elements, {
            label = getLocalizedText("not_have_any_weapon")
        })
    end
    
    Utils.openInteractionMenu("armory_deposit", getLocalizedText("armory_deposit"), elements, function(selected, scrollIndex, args)
        local weaponName = args.value
        if not weaponName then
            return
        end
        
        local success = TriggerServerPromise(Utils.eventsPrefix .. ":depositWeaponInArmory", armoryId, weaponName)
        if not success then
            return
        end
        
        depositWeapon(armoryId)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function chooseWeapon(armoryId, weapons)
    Utils.openInteractionMenu("armory_choose_weapon", getLocalizedText("armory_take"), weapons, function(selected, scrollIndex, args)
        local weaponId = args.value
        if not weaponId then
            return
        end
        
        local success = TriggerServerPromise(Utils.eventsPrefix .. ":takeWeaponFromArmory", armoryId, weaponId)
        if not success then
            return
        end
        
        takeWeaponFromArmory(armoryId)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

function takeWeaponFromArmory(armoryId)
    local armoryWeapons = TriggerServerPromise(Utils.eventsPrefix .. ":retrieveArmoryWeapons", armoryId)
    local categories = {}
    local weaponsByCategory = {}
    
    for _, weapon in pairs(armoryWeapons) do
        local weaponLabel = ESX.GetWeaponLabel(weapon.weapon)
        if not weaponsByCategory[weaponLabel] then
            weaponsByCategory[weaponLabel] = {}
            table.insert(categories, {
                label = weaponLabel,
                weapons = weaponsByCategory[weaponLabel]
            })
        end
        table.insert(weaponsByCategory[weaponLabel], {
            label = getLocalizedText("weapon", ESX.GetWeaponLabel(weapon.weapon), weapon.ammo),
            value = weapon.id
        })
    end
    
    if #categories == 0 then
        table.insert(categories, {
            label = getLocalizedText("no_weapons_in_armory")
        })
    end
    
    Utils.hideInteractionMenu()
    Utils.openInteractionMenu("armory_take", getLocalizedText("armory_take"), categories, function(selected, scrollIndex, args)
        local weapons = args.weapons
        if not weapons then
            return
        end
        chooseWeapon(armoryId, weapons)
    end, function()
        Utils.hideInteractionMenu()
    end)
end

local function openArmoryMenu(armoryId)
    Utils.hideInteractionMenu()
    Utils.openInteractionMenu("armory", getLocalizedText("armory"), {
        {
            label = getLocalizedText("deposit_weapon"),
            value = "deposit"
        },
        {
            label = getLocalizedText("take_weapon"),
            value = "take"
        }
    }, function(selected, scrollIndex, args)
        local action = args.value
        if action == "deposit" then
            depositWeapon(armoryId)
        elseif action == "take" then
            takeWeaponFromArmory(armoryId)
        end
    end, function()
        Utils.hideInteractionMenu()
    end)
end

RegisterNetEvent(Utils.eventsPrefix .. ":armory:openArmory", function(armoryId)
    if config.modules.stash ~= "default" then
        Utils.callModuleFunc("stash", "open", "armory", armoryId)
        return
    end
    openArmoryMenu(armoryId)
end)