function GetCurrentJob()
    return exports["SDC_Core"]:GetCurrentJob()
end

function GetCurrentJobGrade()
    return exports["SDC_Core"]:GetCurrentJobGrade()
end

function GiveKeysToVehicle(veh)
    exports["SDC_Core"]:GiveKeysToVehicle(veh)
end

function TrimVehiclePlate(plate)
    return exports["SDC_Core"]:TrimVehiclePlate(plate)
end

function GiveVehicleFuel(veh)
    exports["SDC_Core"]:GiveVehicleFuel(veh)
end

function GetVehicleProperties(veh)
    return exports["SDC_Core"]:GetVehicleProperties(veh)
end

function DoProgressbar(time, label)
    return exports["SDC_Core"]:ProgressBar(time, label)
end

local OxTargetTable = {}
function AddTargetToRegister(coords, eventtotrigger, plate)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddBoxZone("sdft:register:"..plate, vector3(coords.x, coords.y, coords.z), 1.5, 1.5, {  
            name = "sdft:register:"..plate,  
            heading = 0.0, 
            debugPoly = false,  
            minZ = coords.z - 1, 
            maxZ = coords.z + 1,  
        }, {
            options = { 
                {  
                    num = 1,
                    label = SDC.Lang.Register, 
                    type = "client",  
                    event = eventtotrigger, 
                    icon = 'fas fa-cash-register',
                }
            },
            distance = 1.5, 
        })
    elseif SDC.Target == "ox_target" then
        local zoneID = nil
        zoneID = exports.ox_target:addSphereZone({
            coords = coords,
            radius = 0.5,
            debug = false,
            options = {  
                label = SDC.Lang.Register, 
                icon = 'fa-cash-register', 
                distance = 1.5,
                event = eventtotrigger, 
            }
        })
        OxTargetTable[plate] = zoneID
    end
end
function RemoveTargetFromRegister(plate)
    if SDC.Target == "qb-target" then
        exports['qb-target']:RemoveZone("sdft:register:"..plate)
    elseif SDC.Target == "ox_target" then
        if OxTargetTable[plate] then
            exports.ox_target:removeZone(OxTargetTable[plate])
        end
    end
end

function AddTargetToTable(prop, eventtotrigger, plate)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(prop, { 
            options = {  
                {  
                    type = "client", 
                    event = eventtotrigger,  
                    icon = 'fas fa-chair',  
                    label = SDC.Lang.TakeASeat, 
                }
            },
            distance = 2.5, 
        })
    elseif SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(prop, {
            {  
                label = SDC.Lang.TakeASeat, 
                icon = 'fa-chair', 
                distance = 2.5,
                event = eventtotrigger, 
            }
        })
    end
end

function AddTargetToDealerPed(ped, eventtotrigger)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(ped, { 
            options = {  
                  {  
                    type = "client",  
                    event = eventtotrigger,   
                    icon = 'fas fa-truck',   
                    label = SDC.Lang.DealershipLabel,  
                  }
            },
            distance = 1.5, 
          })
    elseif  SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(ped, {
            {  
                label = SDC.Lang.DealershipLabel, 
                icon = 'fa-truck', 
                distance = 1.5,
                event = eventtotrigger, 
            }
        })
    end
end

function AddTargetToStorePed(ped, eventtotrigger, label)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(ped, { 
            options = {  
                  {  
                    type = "client",  
                    event = eventtotrigger,   
                    icon = 'fas fa-shop',   
                    label = label,  
                  }
            },
            distance = 1.5, 
          })
    elseif  SDC.Target == "ox_target" then
        exports.ox_target:addLocalEntity(ped, {
            {  
                label = label, 
                icon = 'fa-shop', 
                distance = 1.5,
                event = eventtotrigger, 
            }
        })
    end
end

RegisterNetEvent("SDFT:Client:Notification")
AddEventHandler("SDFT:Client:Notification", function(msg, extra)
    exports["SDC_Core"]:ShowNotification(msg, extra)
end)