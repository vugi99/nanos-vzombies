
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