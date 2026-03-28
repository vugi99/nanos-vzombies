

WaveInterval_ms = 20000
GameOverInterval_ms = 30000

-- Do not do WaveIntervals, instead change wave when time calculated to spawn enemies continuously (ignoring Enemies limit) is reached
Timed_Waves = false

Hellhounds_Each_x_Rounds = 6 -- Put 0 to disable, only on maps that supports it

Players_Respawn_Between_Rounds = true


local target_wave_no_walk = 17.5
function VZ_Make_Wave_walk_weight(init, wave_target)
    local function walk_weight(nb)
        return (init-((nb-1)/(wave_target-1))*init)
    end
    return walk_weight
end
Package.Export("VZ_Make_Wave_walk_weight", VZ_Make_Wave_walk_weight)

function VZ_Make_Wave_run_weight(target, wave_target)
    local function run_weight(nb)
        return math.min(target, ((target*(nb-1))/(wave_target-1)))
    end
    return run_weight
end
Package.Export("VZ_Make_Wave_run_weight", VZ_Make_Wave_run_weight)

Enemies_Waves_Weight_Functions = {
    Zombie = {
        walk = VZ_Make_Wave_walk_weight(7, target_wave_no_walk),
        run = VZ_Make_Wave_run_weight(7, target_wave_no_walk),
    },
    UrbanZombie = {
        walk = VZ_Make_Wave_walk_weight(1, target_wave_no_walk),
        run = VZ_Make_Wave_run_weight(1, target_wave_no_walk),
    },
    HoodieZombie = {
        walk = VZ_Make_Wave_walk_weight(1, target_wave_no_walk),
        run = VZ_Make_Wave_run_weight(1, target_wave_no_walk),
    },
    TankTopZombie = {
        walk = VZ_Make_Wave_walk_weight(1, target_wave_no_walk),
        run = VZ_Make_Wave_run_weight(1, target_wave_no_walk),
    },
}


-- Pre 3.1.0 config for waves enemies
--[[
FirstWave = {
    Zombie = {
        walk = 70, -- Max perc for this enemy
    },
    UrbanZombie = {
        walk = 10,
    },
    HoodieZombie = {
        walk = 10,
    },
    TankTopZombie = {
        walk = 10,
    },
}

Added_Per_Wave_Percentage = {
    Zombie = {
        run = 4,
    },
    UrbanZombie = {
        run = 1,
    },
    HoodieZombie = {
        run = 1,
    },
    TankTopZombie = {
        run = 1,
    },
}]]--