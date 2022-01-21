

local found_outdated_no_type
for k, v in pairs(MAP_ROOMS) do
    for k2, v2 in pairs(v) do
        if not v2.type then
            found_outdated = true
            v2.type = "barricade"
            v2.z_spawns = {}
            table.insert(v2.z_spawns, {
                location = v2.z_spawn_location,
                rotation = v2.z_spawn_rotation
            })
        end
    end
end

if found_outdated_no_type then
    Package.Warn("VZombies : Zombie Map Config is outdated, fixed the outdated issues.")
end