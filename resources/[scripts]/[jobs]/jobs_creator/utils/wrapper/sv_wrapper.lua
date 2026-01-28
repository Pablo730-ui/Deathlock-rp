function SaveResourceFile(resourceName, fileName, data)
  if not resourceName or not fileName or not data then
    return false
  end

  local path = string.format("%s/%s", GetResourcePath(resourceName), fileName)
  local exportResource = exports[GetCurrentResourceName()]
  return exportResource.SaveResourceFile(exportResource, path, data)
end
