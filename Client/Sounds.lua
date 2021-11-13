
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

local lowhealth_sound = Sound(
    Vector(0, 0, 0),
    LowHealth_Loop_Sound.asset,
    true,
    false,
    SoundType.SFX,
    LowHealth_Loop_Sound.volume,
    1,
    0,
    0,
    AttenuationFunction.Linear,
    false,
    SoundLoopMode.Forever
)
lowhealth_sound:Stop()

Playing_LowHealth_Sound = false

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

function LastStandExitSound()
    local down_exit = Sound(
        Vector(0, 0, 0),
        LastStand_Exit_Sound.asset,
        true,
        true,
        SoundType.SFX,
        LastStand_Exit_Sound.volume
    )
end

Player.Subscribe("UnPossess", function(ply, character)
    if ply == Client.GetLocalPlayer() then
        down_sound:Stop()
        LastStandExitSound()
    end
end)

Character.Subscribe("ValueChange", function(char, key, value)
    if IsSelfCharacter(char) then
        if key == "PlayerDown" then
            if value then
                local down_enter = Sound(
                    Vector(0, 0, 0),
                    LastStand_Enter_Sound.asset,
                    true,
                    true,
                    SoundType.SFX,
                    LastStand_Enter_Sound.volume
                )
                down_sound:Play(0)
                if Playing_LowHealth_Sound then
                    StopLowHealthLoop()
                end
            else
                down_sound:Stop()
                LastStandExitSound()
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

Events.Subscribe("RepairBarricadeSound", function(snap_path, repaired_loc)
    local snap_b_sound = Sound(
        repaired_loc,
        snap_path,
        false,
        true,
        SoundType.SFX,
        RANDOM_SOUNDS.barricade_snap.volume,
        1,
        RANDOM_SOUNDS.barricade_snap.radius,
        RANDOM_SOUNDS.barricade_snap.falloff_distance
    )
end)

local Z_Behind_Interval

function CreateZBehindInterval()
    Z_Behind_Interval = Timer.SetInterval(function()
        local ply = Client.GetLocalPlayer()
        local char = ply:GetControlledCharacter()
        if char then
            local char_loc = char:GetLocation()
            local char_rot = char:GetRotation()

            local nearest_zombie_for_sound
            local nearest_zombie_dist_sq
            for k, v in pairs(Character.GetPairs()) do
                if v:IsValid() then
                    if not v:GetPlayer() then
                        if v:GetHealth() > 0 then
                            local zombie_velocity = v:GetVelocity()
                            if (zombie_velocity.X ~= 0 or zombie_velocity.Y ~= 0) then
                                local zombie_loc = v:GetLocation()
                                local dist_sq = char_loc:DistanceSquared(zombie_loc)
                                if dist_sq <= Zombie_Behind_Sound_Trigger_Config.max_distance_sq then
                                    local dist_z = zombie_loc.Z - char_loc.Z
                                    if dist_z < 0 then
                                        dist_z = dist_z * -1
                                    end
                                    if dist_z <= Zombie_Behind_Sound_Trigger_Config.max_z_dist then
                                        local zombie_rot = v:GetRotation()
                                        local relrot = RelRot1(char_rot.Yaw, zombie_rot.Yaw)
                                        --print(relrot)
                                        if (relrot > Zombie_Behind_Sound_Trigger_Config.Rel_Rot_Between[1] and relrot < Zombie_Behind_Sound_Trigger_Config.Rel_Rot_Between[2]) then
                                            if (not nearest_zombie_for_sound or nearest_zombie_dist_sq > dist_sq) then
                                                nearest_zombie_for_sound = v
                                                nearest_zombie_dist_sq = dist_sq
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if nearest_zombie_for_sound then
                local zombie_loc = nearest_zombie_for_sound:GetLocation()
                local z_behind_sound = Sound(
                    zombie_loc,
                    VZ_RandomSound(RANDOM_SOUNDS.zombie_behind),
                    false,
                    true,
                    SoundType.SFX,
                    RANDOM_SOUNDS.zombie_behind.volume,
                    1,
                    RANDOM_SOUNDS.zombie_behind.radius,
                    RANDOM_SOUNDS.zombie_behind.falloff_distance
                )
                z_behind_sound:AttachTo(nearest_zombie_for_sound)

                Timer.ClearInterval(Z_Behind_Interval)
                Z_Behind_Interval = nil
                Timer.SetTimeout(function()
                    CreateZBehindInterval()
                end, Zombie_Behind_Sound_Trigger_Config.Cooldown_ms)
            end
        end
    end, Zombie_Behind_Sound_Trigger_Config.Interval_ms)
end
CreateZBehindInterval()



local Z_Amb_Sounds_Interval
function CreateZAmbInterval()
    Z_Amb_Sounds_Interval = Timer.SetInterval(function()
        local ply = Client.GetLocalPlayer()
        local char = ply:GetControlledCharacter()
        if char then
            local char_loc = char:GetLocation()

            for k, v in pairs(Character.GetPairs()) do
                if v:IsValid() then
                    if not v:GetPlayer() then
                        if v:GetHealth() > 0 then
                            local zombie_velocity = v:GetVelocity()
                            if (zombie_velocity.X ~= 0 or zombie_velocity.Y ~= 0) then
                                local zombie_type = v:GetValue("ZombieType")
                                if zombie_type then

                                    local Random_Sounds_tbl
                                    if zombie_type == "walk" then
                                        Random_Sounds_tbl = RANDOM_SOUNDS.zombie_soft
                                    elseif zombie_type == "run" then
                                        Random_Sounds_tbl = RANDOM_SOUNDS.zombie_sprint
                                    end

                                    if Random_Sounds_tbl then
                                        local zombie_loc = v:GetLocation()
                                        local dist_sq = char_loc:DistanceSquared(zombie_loc)

                                        if dist_sq <= Random_Sounds_tbl.falloff_distance ^ 2 then
                                            --print("AMB SOUND CREATED")
                                            local z_amb_sound = Sound(
                                                zombie_loc,
                                                VZ_RandomSound(Random_Sounds_tbl),
                                                false,
                                                true,
                                                SoundType.SFX,
                                                Random_Sounds_tbl.volume,
                                                1,
                                                Random_Sounds_tbl.radius,
                                                Random_Sounds_tbl.falloff_distance,
                                                AttenuationFunction.NaturalSound
                                            )
                                            z_amb_sound:AttachTo(v)

                                            Timer.ClearInterval(Z_Amb_Sounds_Interval)
                                            Z_Amb_Sounds_Interval = nil
                                            Timer.SetTimeout(function()
                                                CreateZAmbInterval()
                                            end, Zombie_Amb_Sounds.Cooldown_ms)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end, Zombie_Amb_Sounds.Interval_ms)
end
CreateZAmbInterval()


-- Destroy sounds attached to zombies when they die
Character.Subscribe("Death", function(char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator)
    if not char:GetPlayer() then
        local attached_actors = char:GetAttachedEntities()
        for k, v in pairs(attached_actors) do
            v:Destroy()
        end
    end
end)

function PlayLowHealthLoop()
    local lowhealth_enter = Sound(
        Vector(0, 0, 0),
        LowHealth_Enter_Sound.asset,
        true,
        true,
        SoundType.SFX,
        LowHealth_Enter_Sound.volume
    )
    lowhealth_sound:Play(0)
    Playing_LowHealth_Sound = true
end

function PlayExitLowHealthSound()
    local lowhealth_exit = Sound(
        Vector(0, 0, 0),
        LowHealth_Exit_Sound.asset,
        true,
        true,
        SoundType.SFX,
        LowHealth_Exit_Sound.volume
    )
end

function StopLowHealthLoop()
    lowhealth_sound:Stop()
    Playing_LowHealth_Sound = false
end

function PlayPlayerHurtSound()
    local ply_hurt_sound = Sound(
        Vector(0, 0, 0),
        VZ_RandomSound(RANDOM_SOUNDS.zombie_hit_player),
        true,
        true,
        SoundType.SFX,
        RANDOM_SOUNDS.zombie_hit_player.volume
    )
end