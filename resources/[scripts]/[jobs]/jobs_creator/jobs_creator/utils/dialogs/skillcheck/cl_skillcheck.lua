local dialogName, isActive, currentPromise, registerCallback, nuiReadyEvent, handleNuiReady
dialogName = "skillcheck"
isActive = false
currentPromise = nil
registerCallback = RegisterNUICallback
nuiReadyEvent = "nuiReady"
function handleNuiReady()
  local messageData
  messageData = {}
  messageData.action = "loadDialog"
  messageData.dialogName = dialogName
  SendNUIMessage(messageData)
end
registerCallback(nuiReadyEvent, handleNuiReady)
registerCallback("skillCheckFinish", function(data, callback)
  local success, soundName, soundSet
  success = data.success
  if success then
    soundName = "Hack_Success"
    soundSet = "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS"
  else
    soundName = "Hack_Fail"
    soundSet = "DLC_sum20_Business_Battle_AC_Sounds"
  end
  PlaySoundFrontend(-1, soundName, soundSet, true)
  SetNuiFocus(false, false)
  if currentPromise then
    currentPromise:resolve(success)
  end
end)
local skillcheckConfigs = {}
skillcheckConfigs[1] = {speed = 1, positiveBars = 6}
skillcheckConfigs[2] = {speed = 3, positiveBars = 4}
skillcheckConfigs[3] = {speed = 5, positiveBars = 5}
function Dialogs.skillcheck(difficulty, speed, positiveBars)
  local config, skillcheckPromise, result
  if isActive then
    return false
  end
  if difficulty > 3 then
    difficulty = 3
  end
  if difficulty < 1 then
    difficulty = 1
  end
  if not speed then
    config = skillcheckConfigs[difficulty]
    speed = config.speed
  end
  if not positiveBars then
    config = skillcheckConfigs[difficulty]
    positiveBars = config.positiveBars
  end
  isActive = true
  SendNUIMessage({
    action = "skillcheck",
    speed = speed,
    positiveBars = positiveBars
  })
  SetNuiFocus(true, false)
  SetNuiFocusKeepInput(true)
  skillcheckPromise = promise.new()
  currentPromise = skillcheckPromise
  result = Citizen.Await(skillcheckPromise)
  isActive = false
  return result
end
exports("skillcheck", Dialogs.skillcheck)
function Dialogs.cancelSkillcheck()
  if not isActive then
    return
  end
  SendNUIMessage({action = "cancelSkillcheck"})
  SetNuiFocus(false, false)
  isActive = false
  if currentPromise then
    currentPromise:resolve(false)
  end
end
exports("cancelSkillcheck", Dialogs.cancelSkillcheck)
