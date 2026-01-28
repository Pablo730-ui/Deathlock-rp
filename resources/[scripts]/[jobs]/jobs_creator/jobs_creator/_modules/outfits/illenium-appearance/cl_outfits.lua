local moduleType = "outfits" -- Module category
local moduleName = "illenium" -- THIS module name

-- Don't touch, required to appear in in-game settings
Integrations.modules = Integrations.modules or {}
Integrations.modules[moduleType] = Integrations.modules[moduleType] or {}
Integrations[moduleType] = Integrations[moduleType] or {}
Integrations[moduleType][moduleName] = {}
table.insert(Integrations.modules[moduleType], moduleName)

--[[
    You can edit below here
]]

local function convertComponentsToOutfit(components, props)
    if not components or not props then return end

    local outfit = {}
    
    -- Map component IDs to outfit keys
    local componentMap = {
        [0] = {name = "mask_1", color = "mask_2"},
        [1] = {name = "arms", color = "arms_2"},
        [3] = {name = "torso_1", color = "torso_2"},
        [4] = {name = "pants_1", color = "pants_2"},
        [5] = {name = "bags_1", color = "bags_2"},
        [6] = {name = "shoes_1", color = "shoes_2"},
        [7] = {name = "chain_1", color = "chain_2"},
        [8] = {name = "tshirt_1", color = "tshirt_2"},
        [9] = {name = "bproof_1", color = "bproof_2"},
        [10] = {name = "decals_1", color = "decals_2"}
    }

    -- Convert each component
    for _, component in ipairs(components) do
        local mapping = componentMap[component.component_id]
        if mapping then
            outfit[mapping.name] = component.drawable
            outfit[mapping.color] = component.texture
        end
    end

	-- Search for props with prop_id 0 (helmet) and 1 (glasses)
	for _, prop in ipairs(props) do
		if prop.prop_id == 0 then
			outfit.helmet_1 = prop.drawable
			outfit.helmet_2 = prop.texture
		elseif prop.prop_id == 1 then
			outfit.glasses_1 = prop.drawable
			outfit.glasses_2 = prop.texture
		end
	end

    return outfit
end

local function convertOutfitToComponents(outfit)
    if not outfit then return end

    local components = {}
    local props = {}

    -- Map outfit keys to component IDs
    local componentMap = {
        {id = 0, drawable = "mask_1", texture = "mask_2"},
        {id = 1, drawable = "arms", texture = "arms_2"},
        {id = 3, drawable = "torso_1", texture = "torso_2"},
        {id = 4, drawable = "pants_1", texture = "pants_2"},
        {id = 5, drawable = "bags_1", texture = "bags_2"},
        {id = 6, drawable = "shoes_1", texture = "shoes_2"},
        {id = 7, drawable = "chain_1", texture = "chain_2"},
        {id = 8, drawable = "tshirt_1", texture = "tshirt_2"},
        {id = 9, drawable = "bproof_1", texture = "bproof_2"},
        {id = 10, drawable = "decals_1", texture = "decals_2"}
    }

    -- Convert outfit to components
    for _, mapping in ipairs(componentMap) do
        -- Always add component even if not in outfit, defaulting to -1
        table.insert(components, {
            component_id = mapping.id,
            drawable = outfit[mapping.drawable] or -1,
            texture = outfit[mapping.texture] or 0
        })
    end

    -- Always add props with default -1 values
    props = {
        {
            prop_id = 0,
            drawable = outfit.helmet_1 or -1,
            texture = outfit.helmet_2 or -1
        },
        {
            prop_id = 1, 
            drawable = outfit.glasses_1 or -1,
            texture = outfit.glasses_2 or 0
        }
    }

    return components, props
end

-- This function has to open saved player outfits menu from your own script
Integrations[moduleType][moduleName].openWardrobe = function()
    TriggerEvent(EXTERNAL_EVENTS_NAMES["illenium-appearance:client:openOutfitMenu"])
end

--[[
    return true will call openJobOutfits, so getPlayerClothes and setPlayerClothes will be ignored
    return false will override current getPlayerClothes and setPlayerClothes functions, using Jobs Creator menu
]]
Integrations[moduleType][moduleName].openExternalMenu = function()
    return false
end

-- This function has to open saved job outfits menu from your own script, completely replacing Jobs Creator job outfit feature    
Integrations[moduleType][moduleName].openJobOutfits = function()
    TriggerEvent(EXTERNAL_EVENTS_NAMES["illenium-apearance:client:outfitsCommand"], true)
end

-- This function has return current player's outfit. The required format is shown below
Integrations[moduleType][moduleName].getPlayerClothes = function()
    local ped = PlayerPedId()
    local components = exports['illenium-appearance']:getPedComponents(ped)
	local props = exports['illenium-appearance']:getPedProps(ped)

    -- Convert illenium-appearance format to the required format
	local outfit = convertComponentsToOutfit(components, props)
    return outfit
end

-- This function has set current player's outfit. The required format is shown below
Integrations[moduleType][moduleName].setPlayerClothes = function(outfit, saveAfterRestart)
    local ped = PlayerPedId()
    
    -- Convert the required format to illenium-appearance format using the conversion function
    local components, props = convertOutfitToComponents(outfit)
    
    -- Set components one by one
    for _, component in pairs(components) do
        exports['illenium-appearance']:setPedComponent(ped, component)
    end

     -- Set props one by one 
    for _, prop in pairs(props) do
        exports['illenium-appearance']:setPedProp(ped, prop)
    end
    
    if saveAfterRestart then
        -- Save the appearance to the database
		local appearance = exports['illenium-appearance']:getPedAppearance(ped)
        TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
    end
end

-- EXAMPLE FORMAT FOR OUTFIT
--[[
    ------------------------------
	| Key           | Value      |
	|---------------|------------|
	| tshirt_1      | NUMBER     |
	| tshirt_2      | NUMBER     |
	| torso_1       | NUMBER     |
	| torso_2       | NUMBER     |
	| decals_1      | NUMBER     |
	| decals_2      | NUMBER     |
	| arms          | NUMBER     |
	| arms_2        | NUMBER     |
	| pants_1       | NUMBER     |
	| pants_2       | NUMBER     |
	| shoes_1       | NUMBER     |
	| shoes_2       | NUMBER     |
	| mask_1        | NUMBER     |
	| mask_2        | NUMBER     |
	| bproof_1      | NUMBER     |
	| bproof_2      | NUMBER     |
	| chain_1       | NUMBER     |
	| chain_2       | NUMBER     |
	| helmet_1      | NUMBER     |
	| helmet_2      | NUMBER     |
	| glasses_1     | NUMBER     |
	| glasses_2     | NUMBER     |
	| bags_1        | NUMBER     |
	| bags_2        | NUMBER     |
	------------------------------
]]
