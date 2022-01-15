
local Powerups_Loops_Sounds = {}


local down_sound = Sound(
    Vector(0, 0, 0),
    DownLoop_Sound.asset,
    true,
    false,
    SoundType.SFX,
    DownLoop_Sound.volume,
    1,
    0,
    0,
    AttenuationFunction.Linear,
    false,
    SoundLoopMode.Forever
)
down_sound:Stop()

Events.Subscribe("WaveFinished", function()
    local wave_finished = Sound(
        Vector(0, 0, 0),
        WaveFinished_Sound.asset,
        true,
        true,
        SoundType.SFX,
        WaveFinished_Sound.volume
    )
end)

function ZombieAttackSound(zombie_a_path, zombie_loc)
    local zombie_a_sound = Sound(
        zombie_loc,
        zombie_a_path,
        false,
        true,
        SoundType.SFX,
        RANDOM_SOUNDS.zombie_attack.volume,
        1,
        RANDOM_SOUNDS.zombie_attack.radius,
        RANDOM_SOUNDS.zombie_attack.falloff_distance
    )
end
Events.Subscribe("ZombieAttackSound", ZombieAttackSound)

Events.Subscribe("DamageBarricadeSound", function(slam_path, zombie_a_path, destroyed_loc, zombie_loc)
    local slam_b_sound = Sound(
        destroyed_loc,
        slam_path,
        false,
        true,
        SoundType.SFX,
        RANDOM_SOUNDS.barricade_slam.volume,
        1,
        RANDOM_SOUNDS.barricade_slam.radius,
        RANDOM_SOUNDS.barricade_slam.falloff_distance
    )

    ZombieAttackSound(zombie_a_path, zombie_loc)
end)


Events.Subscribe("MBOXChangedSound", function()
    local mbox_changed = Sound(
        Vector(0, 0, 0),
        Mbox_Changed_Sound.asset,
        true,
        true,
        SoundType.SFX,
        Mbox_Changed_Sound.volume
    )
end)

Events.Subscribe("GameOver", function()
    local GameOver = Sound(
        Vector(0, 0, 0),
        GameOver_Sound.asset,
        true,
        true,
        SoundType.SFX,
        GameOver_Sound.volume
    )
end)

Player.Subscribe("Possess", function(ply, character)
    if ply == Client.GetLocalPlayer() then
        down_sound:Stop()
    end
end)

Character.Subscribe("ValueChange", function(char, key, value)
    if IsSelfCharacter(char) then
        if key == "PlayerDown" then
            if value then
                down_sound:Play(0)
            else
                down_sound:Stop()
            end
        end
    end
end)

Events.Subscribe("OpenMBOXSound", function(loc)
    local open_mbox = Sound(
        loc,
        OpenMBOX_Sound.asset,
        false,
        true,
        SoundType.SFX,
        OpenMBOX_Sound.volume,
        1,
        OpenMBOX_Sound.radius,
        OpenMBOX_Sound.falloff_distance
    )
    local mbox_music = Sound(
        loc,
        MBOX_Sound.asset,
        false,
        true,
        SoundType.SFX,
        MBOX_Sound.volume,
        1,
        MBOX_Sound.radius,
        MBOX_Sound.falloff_distance
    )
end)

Events.Subscribe("PowerupGrabSound", function()
    local PowerupGrab = Sound(
        Vector(0, 0, 0),
        Powerup_Grab_Sound.asset,
        true,
        true,
        SoundType.SFX,
        Powerup_Grab_Sound.volume
    )
end)

function PowerupSound(sound)
    local psound = Sound(
        Vector(0, 0, 0),
        sound.asset,
        true,
        true,
        SoundType.SFX,
        sound.volume
    )
end

StaticMesh.Subscribe("ValueChange", function(SM, key, value)
    if key == "GrabPowerup" then
        local p_spawn_dound = Sound(
            SM:GetLocation(),
            Powerup_Spawn_Sound.asset,
            false,
            true,
            SoundType.SFX,
            Powerup_Spawn_Sound.volume,
            1,
            Powerup_Spawn_Sound.radius,
            Powerup_Spawn_Sound.falloff_distance
        )
        Powerups_Loops_Sounds[value] = Sound(
            SM:GetLocation(),
            Powerup_Loop_Sound.asset,
            false,
            false,
            SoundType.SFX,
            Powerup_Loop_Sound.volume,
            1,
            Powerup_Loop_Sound.radius,
            Powerup_Loop_Sound.falloff_distance,
            AttenuationFunction.Linear,
            true,
            SoundLoopMode.Forever
        )
    end
end)

StaticMesh.Subscribe("Destroy", function(SM)
    local g_powerup_id = SM:GetValue("GrabPowerup")
    if g_powerup_id then
        if Powerups_Loops_Sounds[g_powerup_id] then
            Powerups_Loops_Sounds[g_powerup_id]:Destroy()
            Powerups_Loops_Sounds[g_powerup_id] = nil
        end
    end
end)

Events.Subscribe("PowerONSound", function()
    local pow_sound = Sound(
        Vector(0, 0, 0),
        PowerOn_Sound.asset,
        true,
        true,
        SoundType.SFX,
        PowerOn_Sound.volume
    )
    local pow3D_sound = Sound(
        MAP_POWER.location + Vector(0, 0, 100),
        PowerOn3D_Sound.asset,
        false,
        true,
        SoundType.SFX,
        PowerOn3D_Sound.volume,
        1,
        PowerOn3D_Sound.radius,
        PowerOn3D_Sound.falloff_distance
    )
    POWER_ON = true
end)

function NewPerkSound()
    local npsound = Sound(
        Vector(0, 0, 0),
        NewPerk_Sound.asset,
        true,
        true,
        SoundType.SFX,
        NewPerk_Sound.volume
    )
end

Events.Subscribe("PAPUpgradeSound", function()
    local pap_up = Sound(
        MAP_PACK_A_PUNCH.location,
        PAP_Upgrade_Sound.asset,
        false,
        true,
        SoundType.SFX,
        PAP_Upgrade_Sound.volume,
        1,
        PAP_Upgrade_Sound.radius,
        PAP_Upgrade_Sound.falloff_distance
    )
end)

Events.Subscribe("PAPReadySound", function()
    local pap_ready = Sound(
        MAP_PACK_A_PUNCH.location,
        PAP_Ready_Sound.asset,
        false,
        true,
        SoundType.SFX,
        PAP_Ready_Sound.volume,
        1,
        PAP_Ready_Sound.radius,
        PAP_Ready_Sound.falloff_distance
    )
end)