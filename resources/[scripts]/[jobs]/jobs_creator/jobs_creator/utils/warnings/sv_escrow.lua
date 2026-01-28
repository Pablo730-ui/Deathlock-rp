local resourceName, errorMessages, checkEscrowErrors
resourceName = GetCurrentResourceName()
errorMessages = {}
errorMessages[1] = "Error parsing script @" .. resourceName .. "/"
errorMessages[2] = "Failed to verify protected resource " .. resourceName

Citizen.CreateThread(function()
  local consoleBuffer, foundIndex, i, lineStart, lineEnd, lineText, filePath
  consoleBuffer = GetConsoleBuffer()
  foundIndex = nil
  for i = 1, #errorMessages do
    foundIndex = consoleBuffer.find(consoleBuffer, errorMessages[i])
    if foundIndex then
      break
    end
  end
  if not foundIndex then
    return
  end
  lineEnd = consoleBuffer.find(consoleBuffer, "\n", foundIndex)
  lineEnd = lineEnd - 1
  lineText = consoleBuffer.sub(consoleBuffer, foundIndex, lineEnd)
  filePath = lineText.match(lineText, "Error parsing script.*@(.*)")
  while true do
    Citizen.Wait(5000)
    print("^1")
    print("=====================================")
    print("ESCROW/SYNTAX ERROR DETECTED FOR " .. resourceName)
    print("This error does NOT depend on the script, there is something wrong in " .. resourceName .. " files")
    print("The most common issue is a virus or syntax error in this file: ^3" .. filePath .. "^1\n")
    print("https://documentation.jaksam-scripts.com/fivem-escrow-system-errors/what-to-do-if-nothing-is-fixing-the-errors")
    print("=====================================")
    print("^7")
  end
end)
