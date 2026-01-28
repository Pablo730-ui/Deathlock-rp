if not Dialogs then
  Dialogs = {}
end

RegisterNUICallback("enableCursor", function()
  if not IsNuiFocused() then
    SetNuiFocus(true, true)
  end
end)

RegisterNUICallback("disableCursor", function()
  if IsNuiFocused() then
    SetNuiFocus(false, false)
  end
end)
