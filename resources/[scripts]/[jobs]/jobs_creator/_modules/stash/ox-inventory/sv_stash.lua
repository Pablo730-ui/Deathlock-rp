--[[ You can edit below here ]] 
local STASH_CONFIG = {
    slots = 50,
    weight = 100000,
}

local function extractAllowedJobsFromMarker(marker)
    if marker.job_name == "public_marker" then return nil end

    if marker.grades_type == "minimumGrade" then
        return { [marker.job_name] = marker.min_grade }
    end

    local minGrade = math.huge
    local grades = json.decode(marker.specific_grades)

    for gradeId, _ in pairs(grades) do
        gradeId = tonumber(gradeId)

        minGrade = math.min(minGrade, gradeId)
    end

    if minGrade == math.huge then
        minGrade = 0
    end

    return { [marker.job_name] = minGrade }
end

local function isMarkerDifferentForEachPlayer(marker)
    local markerData = json.decode(marker.data)
    if marker.type ~= "armory" then return false end

    return markerData?.isShared and true or false
end

local function registerStashes()
    if(config.modules.stash ~= "ox_inventory") then return end

    local scriptName = Utils.getScriptName("ox_inventory") -- DO NOT EDIT! If you want to edit the name, you can do it in-game

    local results = MySQL.Sync.fetchAll('SELECT id, job_name, type, coords, label, grades_type, specific_grades, min_grade, data FROM jobs_data WHERE type="stash" OR type="safe" OR type="armory"')
    for i=1, #results do
        local currentMarker = results[i]
        local stashId = "job_stash_" .. currentMarker.id
        local coords = vecFromTable(json.decode(currentMarker.coords) or {})
        local jobs = extractAllowedJobsFromMarker(currentMarker)

        exports[scriptName]:RegisterStash(stashId, currentMarker.label, STASH_CONFIG.slots, STASH_CONFIG.weight, isMarkerDifferentForEachPlayer(currentMarker), jobs, vecFromTable(coords))
    end

    print("^2" .. #results .. " OX stashes registered^7")
end

RegisterNetEvent(Utils.eventsPrefix .. ":refreshMarkers", registerStashes)
RegisterNetEvent(Utils.eventsPrefix .. ":serverConfigLoadedOnStart", registerStashes)
