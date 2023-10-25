
local Powerups_Loops_Sounds = {}

PerksAmbSounds = {}

WunderSounds = {}


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

function PlayVZSound(data_tbl, loc)
    if data_tbl then
        if data_tbl.basic_sound_tbl then
            if data_tbl.basic_sound_tbl.falloff_distance then
                local _3D_Sound = Sound(
                    loc,
                    data_tbl.basic_sound_tbl.asset,
                    false,
                    true,
                    SoundType.SFX,
                    data_tbl.basic_sound_tbl.volume,
                    1,
                    data_tbl.basic_sound_tbl.radius,
                    data_tbl.basic_sound_tbl.falloff_distance
                )
            else
                local _2D_Sound = Sound(
                    Vector(0, 0, 0),
                    data_tbl.basic_sound_tbl.asset,
                    true,
                    true,
                    SoundType.SFX,
                    data_tbl.basic_sound_tbl.volume
                )
            end
        end

        if data_tbl.random_sound_tbl then
            local sound_asset_to_play
            if data_tbl.random_sound_selected then
                sound_asset_to_play = data_tbl.random_sound_selected
            else
                sound_asset_to_play = VZ_RandomSound(data_tbl.random_sound_tbl)
            end

            if data_tbl.random_sound_tbl.falloff_distance then
                local _3D_Sound = Sound(
                    loc,
                    sound_asset_to_play,
                    false,
                    true,
                    SoundType.SFX,
                    data_tbl.random_sound_tbl.volume,
                    1,
                    data_tbl.random_sound_tbl.radius,
                    data_tbl.random_sound_tbl.falloff_distance
                )
            else
                local _2D_Sound = Sound(
                    Vector(0, 0, 0),
                    sound_asset_to_play,
                    true,
                    true,
                    SoundType.SFX,
                    data_tbl.random_sound_tbl.volume
                )
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "PlayVZSound", PlayVZSound)
VZ_EVENT_SUBSCRIBE_REMOTE("PlayVZSound", PlayVZSound)

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

VZ_EVENT_SUBSCRIBE("Player", "UnPossess", function(ply, character)
    if ply == Client.GetLocalPlayer() then
        down_sound:Stop()
        LastStandExitSound()
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
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

VZ_EVENT_SUBSCRIBE_REMOTE("OpenMBOXSound", function(loc)
    PlayVZSound({basic_sound_tbl=OpenMBOX_Sound}, loc)
    PlayVZSound({basic_sound_tbl=MBOX_Sound}, loc)
end)

VZ_EVENT_SUBSCRIBE("StaticMesh", "ValueChange", function(SM, key, value)
    if key == "GrabPowerup" then
        PlayVZSound({basic_sound_tbl=Powerup_Spawn_Sound}, SM:GetLocation())
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

VZ_EVENT_SUBSCRIBE("StaticMesh", "Destroy", function(SM)
    local g_powerup_id = SM:GetValue("GrabPowerup")
    if g_powerup_id then
        if Powerups_Loops_Sounds[g_powerup_id] then
            Powerups_Loops_Sounds[g_powerup_id]:Destroy()
            Powerups_Loops_Sounds[g_powerup_id] = nil
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PowerONSound", function()
    PlayVZSound({basic_sound_tbl=PowerOn_Sound})
    PlayVZSound({basic_sound_tbl=PowerOn3D_Sound}, MAP_POWER.location + Vector(0, 0, 100))
    POWER_ON = true
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
            for k, v in pairs(PreparedLoops.Enemies) do
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
                local enemy_table = GetEnemyTable(nearest_zombie_for_sound)
                if enemy_table.Behind_Sounds then
                    local z_behind_sound = Sound(
                        zombie_loc,
                        VZ_RandomSound(enemy_table.Behind_Sounds),
                        false,
                        true,
                        SoundType.SFX,
                        enemy_table.Behind_Sounds.volume,
                        1,
                        enemy_table.Behind_Sounds.radius,
                        enemy_table.Behind_Sounds.falloff_distance
                    )
                    z_behind_sound:AttachTo(nearest_zombie_for_sound)

                    Timer.ClearInterval(Z_Behind_Interval)
                    Z_Behind_Interval = nil
                    Timer.SetTimeout(function()
                        CreateZBehindInterval()
                    end, math.random(Zombie_Behind_Sound_Trigger_Config.Cooldown_ms[1], Zombie_Behind_Sound_Trigger_Config.Cooldown_ms[2]))
                end
            end
        end
    end, Zombie_Behind_Sound_Trigger_Config.Interval_ms)
end
CreateZBehindInterval()


local amb_sound_in_cooldown = false
local Z_Amb_Sounds_Interval
function CreateZAmbInterval()
    Z_Amb_Sounds_Interval = Timer.SetInterval(function()
        if not amb_sound_in_cooldown then
            local ply = Client.GetLocalPlayer()
            local char = ply:GetControlledCharacter()
            if char then
                local char_loc = char:GetLocation()

                local selected_zs = {}

                for k, v in pairs(PreparedLoops.Enemies) do
                    if v:IsValid() then
                        if not v:GetPlayer() then
                            if v:GetHealth() > 0 then
                                if (not v:GetValue("PlayingAmbSound") or (not v:GetValue("PlayingAmbSound"):IsValid())) then
                                    local zombie_velocity = v:GetVelocity()
                                    if (zombie_velocity.X ~= 0 or zombie_velocity.Y ~= 0) then
                                        local enemy_type = v:GetValue("EnemyType")
                                        if enemy_type then

                                            local Random_Sounds_tbl = GetEnemyTable(v).Types[enemy_type].Ambient_Sounds

                                            if Random_Sounds_tbl then
                                                local zombie_loc = v:GetLocation()
                                                local dist_sq = char_loc:DistanceSquared(zombie_loc)

                                                if dist_sq <= Random_Sounds_tbl.falloff_distance ^ 2 then
                                                    table.insert(selected_zs, v)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if selected_zs[1] then
                    local v = selected_zs[math.random(table_count(selected_zs))]
                    local enemy_type = v:GetValue("EnemyType")
                    if enemy_type then

                        local Random_Sounds_tbl = GetEnemyTable(v).Types[enemy_type].Ambient_Sounds

                        if Random_Sounds_tbl then
                            local zombie_loc = v:GetLocation()

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

                            v:SetValue("PlayingAmbSound", z_amb_sound, false)

                            amb_sound_in_cooldown = true

                            --Timer.ClearInterval(Z_Amb_Sounds_Interval)
                            --Z_Amb_Sounds_Interval = nil
                            Timer.SetTimeout(function()
                                amb_sound_in_cooldown = false
                                --CreateZAmbInterval()
                            end, math.random(Zombie_Amb_Sounds.Cooldown_ms[1], Zombie_Amb_Sounds.Cooldown_ms[2]))
                        end
                    end
                end
            end
        end
    end, Zombie_Amb_Sounds.Interval_ms)
end
CreateZAmbInterval()


-- Destroy sounds attached to zombies when they die
VZ_EVENT_SUBSCRIBE("Character", "Death", function(char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator)
    if not char:GetPlayer() then
        local attached_actors = char:GetAttachedEntities()
        for k, v in pairs(attached_actors) do
            if v:IsA(Sound) then
                v:Destroy()
            end
        end
    end
end)

function PlayLowHealthLoop()
    PlayVZSound({basic_sound_tbl=LowHealth_Enter_Sound})
    lowhealth_sound:Play(0)
    Playing_LowHealth_Sound = true
end

function PlayExitLowHealthSound()
    PlayVZSound({basic_sound_tbl=LowHealth_Exit_Sound})
end

function StopLowHealthLoop()
    lowhealth_sound:Stop()
    Playing_LowHealth_Sound = false
end

function PlayPlayerHurtSound()
    PlayVZSound({random_sound_tbl=RANDOM_SOUNDS.zombie_hit_player})
end

Timer.SetInterval(function()
    if POWER_ON then
        local ply = Client.GetLocalPlayer()
        local char = ply:GetControlledCharacter()
        local location
        if char then
            location = char:GetLocation()
        else
            location = ply:GetCameraLocation()
        end
        for k, v in pairs(StaticMesh.GetAll()) do
            local perk_name = v:GetValue("MapPerk")
            if perk_name then
                local perk_location = v:GetLocation()
                local max_distance_sq = PERKS_CONFIG[perk_name].Amb_Sound.falloff_distance ^ 2
                if location:DistanceSquared(perk_location) <= max_distance_sq then
                    if (not PerksAmbSounds[perk_name] or not PerksAmbSounds[perk_name]:IsValid()) then
                        PerksAmbSounds[perk_name] = Sound(
                            perk_location,
                            PERKS_CONFIG[perk_name].Amb_Sound.asset,
                            false,
                            true,
                            SoundType.SFX,
                            PERKS_CONFIG[perk_name].Amb_Sound.volume,
                            1,
                            PERKS_CONFIG[perk_name].Amb_Sound.radius,
                            PERKS_CONFIG[perk_name].Amb_Sound.falloff_distance,
                            AttenuationFunction.NaturalSound,
                            false,
                            SoundLoopMode.Forever
                        )
                    end
                elseif PerksAmbSounds[perk_name] then
                    if PerksAmbSounds[perk_name]:IsValid() then
                        PerksAmbSounds[perk_name]:Destroy()
                    end
                    PerksAmbSounds[perk_name] = nil
                end
            end
        end
    end
end, 15000)


PapAmbSound = nil

Timer.SetInterval(function()
    if POWER_ON then
        local ply = Client.GetLocalPlayer()
        local char = ply:GetControlledCharacter()
        local location
        if char then
            location = char:GetLocation()
        else
            location = ply:GetCameraLocation()
        end
        for k, v in pairs(StaticMesh.GetAll()) do
            local is_pap = v:GetValue("IsPackAPunch")
            if is_pap then
                local perk_location = v:GetLocation()
                local max_distance_sq = Pack_A_Punch_Amb_Sound.falloff_distance ^ 2
                if location:DistanceSquared(perk_location) <= max_distance_sq then
                    if (not PapAmbSound or not PapAmbSound:IsValid()) then
                        PapAmbSound = Sound(
                            perk_location,
                            Pack_A_Punch_Amb_Sound.asset,
                            false,
                            true,
                            SoundType.SFX,
                            Pack_A_Punch_Amb_Sound.volume,
                            1,
                            Pack_A_Punch_Amb_Sound.radius,
                            Pack_A_Punch_Amb_Sound.falloff_distance,
                            AttenuationFunction.NaturalSound,
                            false,
                            SoundLoopMode.Forever
                        )
                    end
                elseif PapAmbSound then
                    if PapAmbSound:IsValid() then
                        PapAmbSound:Destroy()
                    end
                    PapAmbSound = nil
                end
                break
            end
        end
    end
end, 15000)

function WunderStopSound(loc)
    PlayVZSound({basic_sound_tbl=Wunderfizz_stop_Sound}, loc)
end

VZ_EVENT_SUBSCRIBE("StaticMesh", "ValueChange", function(sm, key, value)
    if key == "CanBuyWunder" then
        if value == false then
            WunderSounds[1] = Sound(
                sm:GetLocation() + Wonderfizz_Bottles_Offset,
                Wunderfizz_loop_Sound.asset,
                false,
                true,
                SoundType.SFX,
                Wunderfizz_loop_Sound.volume,
                1,
                Wunderfizz_loop_Sound.radius,
                Wunderfizz_loop_Sound.falloff_distance,
                AttenuationFunction.Linear,
                false,
                SoundLoopMode.Forever
            )

            WunderSounds[2] = Sound(
                sm:GetLocation() + Wonderfizz_Bottles_Offset,
                Wunderfizz_vortex_Sound.asset,
                false,
                true,
                SoundType.SFX,
                Wunderfizz_vortex_Sound.volume,
                1,
                Wunderfizz_vortex_Sound.radius,
                Wunderfizz_vortex_Sound.falloff_distance,
                AttenuationFunction.Linear,
                false,
                SoundLoopMode.Forever
            )
        elseif value == nil then
            if table_count(WunderSounds) > 0 then
                WunderStopSound(sm:GetLocation() + Wonderfizz_Bottles_Offset)
            end
            for i, v in ipairs(WunderSounds) do
                if v:IsValid() then
                    v:Destroy()
                end
            end
            WunderSounds = {}
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Prop", "ValueChange", function(prop, key, value)
    if key == "RealBottleData" then
        --print("Prop RealBottleData ValueChange")
        if value then
            for i, v in ipairs(WunderSounds) do
                if v:IsValid() then
                    v:Destroy()
                end
            end
            WunderSounds = {}

            WunderStopSound(prop:GetLocation())

            PlayVZSound({random_sound_tbl=RANDOM_SOUNDS.wunderfizz_impact}, prop:GetLocation())
        end
    end
end)

function PlayStartRepairBarricade()
    PlayVZSound({basic_sound_tbl=Barricade_Start_Repair})
end

VZ_EVENT_SUBSCRIBE_REMOTE("ZombieGroundDirt", function(sound_path, loc)
    PlayVZSound({random_sound_tbl=RANDOM_SOUNDS.spawn_dirt_sound, random_sound_selected=sound_path}, loc)

    local zombie_g_dirt_particle = Particle(
        loc,
        Rotator(0, math.random(-180, 180), 0),
        "vzombies-assets::PSN_Dirt_Surface",
        true,
        true
    )
    zombie_g_dirt_particle:SetScale(Enemies_Ground_Dirt_Scale)
end)

VZ_EVENT_SUBSCRIBE_REMOTE("JokerZombieSound", function(char)
    if char:IsValid() then
        PlayVZSound({random_sound_tbl=RANDOM_SOUNDS.zombie_death}, char:GetLocation())
    end
end)