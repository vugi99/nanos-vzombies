
function ApplyCustomSettings(tbl)
    for k, v in pairs(tbl) do
        if k == "Max_Bots" then
            if v >= 1 then
                Bots_Enabled = true
            end
        end
        if k == "DEV_MODE" then
            ZDEV_CONFIG.ENABLED = v
        else
            _ENV[k] = v
        end
    end

    print("Parsed VZombies Custom Settings")
end

if Parse_Custom_Settings then
    if Server then
        --print(NanosUtils.Dump(Server.GetCustomSettings()))
        ApplyCustomSettings(Server.GetCustomSettings())
    end
end


if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].overwrites then
    for k, v in pairs(VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].overwrites) do
        for k2, v2 in pairs(v) do
            VZ_GLOBAL_FEATURES[k][k2] = v2
        end
    end
end

if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Powerups_Overwrite then
    Powerups_Names = VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Powerups_Overwrite
end

Package.Subscribe("Load", function()
    --print(NanosUtils.Dump(Assets.GetAssetPacks()))

    for i, v in ipairs(Assets.GetAssetPacks()) do
        if v.Path == "vzombies-survivors-assets" then
            Player_Models.Hank = {
                Models = {
                    "vzombies-survivors-assets::SK_Hank_01",
                    "vzombies-survivors-assets::SK_Hank_02",
                    "vzombies-survivors-assets::SK_Hank_01_NoBeanie",
                    "vzombies-survivors-assets::SK_Hank_02_NoBeanie",
                },
            }

            Player_Models.Maria = {
                Models = {
                    "vzombies-survivors-assets::SK_Maria_01",
                    "vzombies-survivors-assets::SK_Maria_02",
                    "vzombies-survivors-assets::SK_Maria_01_Civilian",
                    "vzombies-survivors-assets::SK_Maria_02_Civilian",
                    "vzombies-survivors-assets::SK_Maria_01_NoGun",
                    "vzombies-survivors-assets::SK_Maria_02_NoGun",
                    --"vzombies-survivors-assets::SK_Maria_01_NoScarf",
                    "vzombies-survivors-assets::SK_Maria_02_NoScarf",
                    "vzombies-survivors-assets::SK_Maria_01_NoScarfNoGun",
                    "vzombies-survivors-assets::SK_Maria_02_NoScarfNoGun",
                },
            }

            Player_Models.Mike = {
                Models = {
                    --"vzombies-survivors-assets::SK_Mike_01",
                    --"vzombies-survivors-assets::SK_Mike_02",
                    "vzombies-survivors-assets::SK_Mike_01_NoCap",
                    "vzombies-survivors-assets::SK_Mike_02_NoCap",
                },
            }

            Player_Models.Man = {
                Models = {
                    "vzombies-survivors-assets::SK_Man_Full_03",
                    "vzombies-survivors-assets::SK_Man_Full_04",
                },
            }

            Player_Models.Sarah = {
                Models = {
                    "vzombies-survivors-assets::SK_Sarah_01",
                    "vzombies-survivors-assets::SK_Sarah_01_NoWeaponsNoMask",
                    "vzombies-survivors-assets::SK_Sarah_01_NoMask",
                    "vzombies-survivors-assets::SK_Sarah_01_NoWeapons",
                    "vzombies-survivors-assets::SK_Sarah_02",
                    "vzombies-survivors-assets::SK_Sarah_02_NoMask",
                    "vzombies-survivors-assets::SK_Sarah_02_NoWeapons",
                    "vzombies-survivors-assets::SK_Sarah_02_NoWeaponsNoMask",
                    "vzombies-survivors-assets::SK_Sarah_03",
                    "vzombies-survivors-assets::SK_Sarah_03_NoMask",
                },
            }

            Player_Models.Mannequin = nil

            --Package.Log("VZombies Survivors Player Models Loaded")
            break
        end
    end
end)