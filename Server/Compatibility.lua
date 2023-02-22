

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
    Console.Warn("VZombies : Zombie Map Config is outdated, fixed the outdated issues.")
end

if not NanosWorldWeapons[Powerups_Config.death_machine.minigun_weapon_name] then
    Console.Warn("Missing Death Machine Powerup Weapon, running in compatibility mode")

    Powerups_Config.death_machine = nil
    for i, v in ipairs(Powerups_Names) do
        if v == "death_machine" then
            table.remove(Powerups_Names, i)
            break
        end
    end
end