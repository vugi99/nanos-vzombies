
function VZ_IsPackageLoaded(package_name)
    local packages = Server.GetPackages(true)
    for _, v in ipairs(packages) do
        if v.name == package_name then return true end
    end
    return false
end
