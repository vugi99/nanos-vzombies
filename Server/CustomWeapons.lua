

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
    local loaded = Server.LoadPackage(k)
    --print("LoadPackage", k, loaded)
    if loaded then
        if _ENV[v.table_name] then
            local good = true
            for _, v2 in ipairs(v.asset_pack_requirements) do
                if not IsAssetPackLoaded(v2) then
                    good = false
                    Console.Warn(k .. " asset pack '" .. v2 .. "' not loaded, not adding those weapons")
                end
            end
            if good then
                for k2, v2 in pairs(_ENV[v.table_name]) do
                    NanosWorldWeapons[k .. " " .. k2] = v2

                    local mystery_box_add_table = FindWeaponInMysteryBoxAddList(k, k2)
                    if mystery_box_add_table then
                        mystery_box_add_table.weapon_name = k .. " " .. k2
                        table.insert(Mystery_box_weapons, mystery_box_add_table)
                        --print(NanosTable.Dump(mystery_box_add_table))
                    end
                end
            end
        else
            Console.Warn(k .. " Weapons table not found")
        end
    end
end