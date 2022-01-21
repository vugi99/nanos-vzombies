
--print("Sky.lua")
if (not MAP_SETTINGS or MAP_SETTINGS.spawn_nanos_sky) then
    World.SpawnDefaultSun()
end
World.SetTime(SKY_TIME[1], SKY_TIME[2])
World.SetSunSpeed(0)