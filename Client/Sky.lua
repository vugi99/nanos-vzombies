
--print("Sky.lua")
if (not MAP_SETTINGS or MAP_SETTINGS.spawn_nanos_sky) then
    World.SpawnDefaultSun()
end

local HoursToSet = SKY_TIME[1]
local MinutesToSet = SKY_TIME[2]

if MAP_SETTINGS then
    if MAP_SETTINGS.time_overwrite then
        if (MAP_SETTINGS.time_overwrite[1] and tonumber(MAP_SETTINGS.time_overwrite[1])) then
            HoursToSet = tonumber(MAP_SETTINGS.time_overwrite[1])
        end

        if (MAP_SETTINGS.time_overwrite[2] and tonumber(MAP_SETTINGS.time_overwrite[2])) then
            MinutesToSet = tonumber(MAP_SETTINGS.time_overwrite[2])
        end
    end

    if (MAP_SETTINGS.Sky_Light_Intensity and MAP_SETTINGS.Sky_Light_Intensity >= 0) then
        World.SetSkyLightIntensity(MAP_SETTINGS.Sky_Light_Intensity)
    end

    if (MAP_SETTINGS.Sun_Light_Intensity and MAP_SETTINGS.Sun_Light_Intensity >= 0) then
        World.SetSunLightIntensity(MAP_SETTINGS.Sun_Light_Intensity)
    end
end

World.SetTime(HoursToSet, MinutesToSet)
World.SetSunSpeed(0)

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    Client.Subscribe("Chat", function(text)
        if text then
            local split_txt = split_str(text, " ")
            if (split_txt and split_txt[1] and split_txt[2]) then
                if split_txt[1] == "/settime" then
                    if (tonumber(split_txt[2]) and tonumber(split_txt[3])) then
                        World.SetTime(tonumber(split_txt[2]), tonumber(split_txt[3]))
                    end
                end
            end
        end
    end)
end