function GetCurrentJob()
    return exports["SDC_Core"]:GetCurrentJob()
end

function GetCurrentJobGrade()
    return exports["SDC_Core"]:GetCurrentJobGrade()
end

function DoProgressbar(time, label)
    return exports["SDC_Core"]:ProgressBar(time, label)
end

RegisterNetEvent("SDAP:Client:Notification")
AddEventHandler("SDAP:Client:Notification", function(msg, extra)
    exports["SDC_Core"]:ShowNotification(msg, extra)
end)