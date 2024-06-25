-- @param name module
SafeRequire = function(module)
  local success, loadedModule = pcall(require, module)
  if success then return loadedModule end
  print("Error loading " .. module)
end
