
--print("Sky.lua")

local weather_exists = false

if (not MAP_SETTINGS or MAP_SETTINGS.spawn_nanos_sky) then
    if (MAP_SETTINGS and MAP_SETTINGS.Weather and WeatherType[MAP_SETTINGS.Weather]) then
        weather_exists = true
    end
    Sky.Spawn(weather_exists)
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
        --Sky.SetOverallIntensity(MAP_SETTINGS.Sky_Light_Intensity)
    end
end

Sky.SetTimeOfDay(HoursToSet, MinutesToSet)
Sky.SetAnimateTimeOfDay(false)

if weather_exists then
    Sky.ChangeWeather(WeatherType[MAP_SETTINGS.Weather], 0)
end