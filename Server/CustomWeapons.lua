

function FindWeaponInMysteryBoxAddList(package_name, weapon_name)
    if (package_name and weapon_name) then
        if CustomWeapons_Mysterybox_Added then
            for i, v in ipairs(CustomWeapons_Mysterybox_Added[package_name]) do
                if v.weapon_name == weapon_name then
                    return v
                end
            end
        end
    end
    return nil
end


for k, v in pairs(CustomWeaponsPackagesLoad) do
    local package_name_w_t = ReplaceLetterInString(k, "_", "-")

    Server.LoadPackage(package_name_w_t)
    --print("LoadPackage", package_name_w_t)

    if _ENV[v] then
        for k2, v2 in pairs(_ENV[v]) do
            NanosWorldWeapons[k .. " " .. k2] = v2

            local mystery_box_add_table = FindWeaponInMysteryBoxAddList(k, k2)
            if mystery_box_add_table then
                mystery_box_add_table.weapon_name = k .. " " .. k2
                table.insert(Mystery_box_weapons, mystery_box_add_table)
                --print(NanosUtils.Dump(mystery_box_add_table))
            end
        end
    end
end