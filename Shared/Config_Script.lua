
function ApplyCustomSettings(tbl)
    for k, v in pairs(tbl) do
        --print(k, v)
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
                gender = "male",
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
                gender = "female",
            }

            Player_Models.Mike = {
                Models = {
                    --"vzombies-survivors-assets::SK_Mike_01",
                    --"vzombies-survivors-assets::SK_Mike_02",
                    "vzombies-survivors-assets::SK_Mike_01_NoCap",
                    "vzombies-survivors-assets::SK_Mike_02_NoCap",
                },
                gender = "male",
            }

            Player_Models.Man = {
                Models = {
                    "vzombies-survivors-assets::SK_Man_Full_03",
                    "vzombies-survivors-assets::SK_Man_Full_04",
                },
                gender = "male",
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
                gender = "female",
            }

            Player_Models.Mannequin = nil

            Console.Log("VZombies Survivors Player Models Loaded")

        elseif v.Path == "zombie-pack-v1" then
            Enemies_Config.ZombiePackV1 = TableDeepCopy(Enemies_Config.Zombie)
            Enemies_Config.ZombiePackV1.Gibs = nil
            Enemies_Config.ZombiePackV1.Gibs_heart_bone = nil
            Enemies_Config.ZombiePackV1.Gibs_heart_bone = nil
            Enemies_Config.ZombiePackV1.Enemy_Materials_Assets = nil
            Enemies_Config.ZombiePackV1.Models = {}

            local sk_meshes = Assets.GetSkeletalMeshes(v.Path)
            if sk_meshes then
                for _, mesh in pairs(sk_meshes) do
                    --print("zombie-pack-v1::" .. mesh.key)
                    table.insert(Enemies_Config.ZombiePackV1.Models, "zombie-pack-v1::" .. mesh.key)
                end
            end

            local percentage = 5

            if FirstWave then
                if FirstWave.Zombie then
                    FirstWave.ZombiePackV1 = TableDeepCopy(FirstWave.Zombie)
                    for k, perc in pairs(FirstWave.ZombiePackV1) do
                        FirstWave.Zombie[k] = ((100-percentage)*perc)/100
                        FirstWave.ZombiePackV1[k] = ((percentage)*perc)/100
                    end
                end

                if Added_Per_Wave_Percentage.Zombie then
                    Added_Per_Wave_Percentage.ZombiePackV1 = TableDeepCopy(Added_Per_Wave_Percentage.Zombie)
                    for k, perc in pairs(Added_Per_Wave_Percentage.ZombiePackV1) do
                        Added_Per_Wave_Percentage.Zombie[k] = ((100-percentage)*perc)/100
                        Added_Per_Wave_Percentage.ZombiePackV1[k] = ((percentage)*perc)/100
                    end
                end
            end

            Console.Log("zombie-pack-v1 Zombies loaded")
        end
    end
end)