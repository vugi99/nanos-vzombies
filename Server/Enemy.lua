


ENEMIES_SPAWN_INTERVAL = 0

ENEMY_CHARACTERS = {}
BOSS_CHARACTERS = {}

ENEMY_DEAD_RAGDOLLS = {}

function GetEnemiesCharsCopy()
    local tbl = {}
    for k, v in pairs(ENEMY_CHARACTERS) do
        tbl[k] = v
    end
    return tbl
end

function GetMergedEnemiesChars()
    local tbl = {}
    for k, v in pairs(ENEMY_CHARACTERS) do
        table.insert(tbl, v)
    end
    for k, v in pairs(BOSS_CHARACTERS) do
        table.insert(tbl, v)
    end
    return tbl
end

function DestroyEnemies()
    for k, v in pairs(ENEMY_CHARACTERS) do
        if v:IsValid() then
            if v:GetValue("AttackB") then
                Timer.ClearInterval(v:GetValue("AttackBInterval"))
            end
            if type(v:GetValue("RefreshTargetInterval")) == "number" then
                Timer.ClearInterval(v:GetValue("RefreshTargetInterval"))
            end
            v:Destroy()
        end
    end
    ENEMY_CHARACTERS = {}
end

function DestroyBosses()
    for k, v in pairs(BOSS_CHARACTERS) do
        if v:IsValid() then
            v:Destroy()
        end
    end
    BOSS_CHARACTERS = {}
end

function RandomEnemyAttackAnim(enemy, enemy_type)
    local enemy_table = GetEnemyTable(enemy)
    local on_tbl = enemy_table.Attack_Anims
    if (enemy_table.Types[enemy_type].New_Attack_Anims) then
        on_tbl = enemy_table.Types[enemy_type].New_Attack_Anims
    end
    return on_tbl[math.random(table_count(on_tbl))]
end

function Calculate_Enemy_Health(enemy_table)
    local return_mult = 1
    if enemy_table.Health_Mult_By then
        return_mult = enemy_table.Health_Mult_By
    end

    local hardcoded_health_count = table_count(Zombies_Health_Start)
    if ROUND_NB <= hardcoded_health_count then
        return Zombies_Health_Start[ROUND_NB] * return_mult
    else
        local health = Zombies_Health_Start[hardcoded_health_count] * Zombies_Health_Multiplier_At_Each_Wave^(ROUND_NB - hardcoded_health_count)
        --print(health)
        return health * return_mult
    end
end

function GetSelectedSpawn(spawn_type_data)
    local selected_spawn
    if spawn_type_data.type == "zombie_spawns" then
        selected_spawn = SmartSpawnLogic(SPAWNS_ENABLED)
    elseif spawn_type_data.type == "direct_zombie_spawns" then
        local spawns_ = {}
        for k, v in pairs(SPAWNS_ENABLED) do
            local spawn_target = GetSpawnTargetFromZSpawnID(v.zspawnid)
            if spawn_target then
                if spawn_target.type == "ground" then
                    table.insert(spawns_, v)
                end
            end
        end
        if spawns_[1] then
            selected_spawn = SmartSpawnLogic(spawns_)
        end
    elseif spawn_type_data.type == "custom_spawns" then
        selected_spawn = SmartSpawnLogic(GetCustomSpawnsUnlocked(spawn_type_data))
    end
    return selected_spawn, spawn_type_data.type
end

function SpawnEnemy(EnemyName, EnemyType)
    local players_alive = GetPlayersAlive()
    if table_count(players_alive) > 0 then

        local enemy_table = Enemies_Config[EnemyName]
        if type(enemy_table) ~= "table" then return Console.Error("SpawnEnemy: Enemies_Config '" .. tostring(EnemyName) .. "' doesn't exist") end
        if type(enemy_table.Types[EnemyType]) ~= "table" then return Console.Error("SpawnEnemy: Enemy Type '" .. tostring(EnemyType) .. "' doesn't exist in '" .. tostring(EnemyName) .. "' config table") end

        local selected_spawn
        local selected_spawn_type
        if enemy_table.Spawning_Config.type then
            selected_spawn = GetSelectedSpawn(enemy_table.Spawning_Config)
            selected_spawn_type = enemy_table.Spawning_Config.type
        elseif enemy_table.Spawning_Config.types then
            for i, v in ipairs(enemy_table.Spawning_Config.types) do
                selected_spawn, selected_spawn_type = GetSelectedSpawn(v)
                if selected_spawn then
                    break
                end
            end
        end

        if selected_spawn then
            local selected_spawn_target = GetSpawnTargetFromZSpawnID(selected_spawn.zspawnid)

            local is_ground_anim_disabled = (enemy_table.Custom_Skeleton == true)
            if ((selected_spawn_type ~= "zombie_spawns" and selected_spawn_type ~= "direct_zombie_spawns") or (selected_spawn.ground_anim == false or selected_spawn_target.ground_anim == false)) then
                is_ground_anim_disabled = true
            end

            local spawn_location = selected_spawn.location + Vector(0, 0, 100)
            if (not is_ground_anim_disabled) then
                spawn_location = selected_spawn.location - Vector(0, 0, 140)
            end
            --print("I guess it's from there", VZ_RandomSound(enemy_table.Death_Sounds))

            local random_enemy_model_id = math.random(table_count(enemy_table.Models))
            local random_enemy_model_asset
            local random_enemy_model_table
            local enemy_mats = nil
            if type(enemy_table.Models[random_enemy_model_id]) == "string" then
                random_enemy_model_asset = enemy_table.Models[random_enemy_model_id]
            else
                random_enemy_model_asset = enemy_table.Models[random_enemy_model_id].asset
                random_enemy_model_table = enemy_table.Models[random_enemy_model_id]
                if enemy_table.Models[random_enemy_model_id].materials_slots then
                    if (enemy_table.Enemy_Materials_Assets and enemy_table.Enemy_Materials_Assets[random_enemy_model_id]) then
                        local e_mat_assets = enemy_table.Enemy_Materials_Assets[random_enemy_model_id]
                        enemy_mats = {}
                        for i, v in ipairs(enemy_table.Models[random_enemy_model_id].materials_slots) do
                            if not enemy_mats[v] then
                                enemy_mats[v] = {{i}, e_mat_assets[v][math.random(table_count(e_mat_assets[v]))]}
                            else
                                table.insert(enemy_mats[v][1], i)
                            end
                        end
                    end
                end
            end
            local enemy = Character(
                spawn_location,
                selected_spawn.rotation,
                random_enemy_model_asset,
                CollisionType.Normal,
                true,
                Calculate_Enemy_Health(enemy_table),
                VZ_RandomSound(enemy_table.Death_Sounds),
                ""
            )

            --print("Spawn", random_enemy_model_asset)

            if enemy_mats then
                --print(NanosTable.Dump(enemy_mats))

                for k, v in pairs(enemy_mats) do
                    for i2, v2 in ipairs(v[1]) do
                        enemy:SetMaterial(v[2], v2-1)
                    end
                end
                enemy:SetValue("EnemyMaterials", enemy_mats, true)
            end

            if ZDEV_IsModeEnabled("ZDEV_DEBUG_ZOMBIES_SPAWNS") then
                print("Enemy (" .. enemy:GetID() .. ", " .. tostring(EnemyName) .. ", " .. tostring(EnemyType) .. ") spawn, in spawn " .. tostring(selected_spawn.zspawnid))
            end

            enemy:SetSpeedMultiplier(enemy_table.Types[EnemyType].Speed_Multiplier)
            enemy:SetGaitMode(enemy_table.Types[EnemyType].GaitMode)

            enemy:SetCapsuleSize(enemy_table.Collision_Radius, enemy_table.Collision_Height or 96)

            if enemy_table.Types[EnemyType].Physical_Anim_Settings then
                for i, v in ipairs(enemy_table.Types[EnemyType].Physical_Anim_Settings) do
                    enemy:SetPhysicalAnimationSettings(table.unpack(v))
                end
            end

            enemy:SetValue("Enemy", true, false)
            enemy:SetValue("EnemyName", EnemyName, true)
            enemy:SetValue("EnemyType", EnemyType, true)
            enemy:SetValue("EnemyTypeAtSpawn", EnemyType, false)
            enemy:SetValue("WeirdPunchNB", 0, false)

            if enemy_table.Custom_Skeleton then
                enemy:SetHitReactionEnabled(false)
            end

            enemy:SetAIAvoidanceSettings(table.unpack(Enemies_AI_Avoidance_Settings))
            --enemy:SetBrakingSettings(0, 0)

            if enemy_table.Emissive_Key and enemy_table.Emissive_Spawn_Value then
                local mat_index = (random_enemy_model_table and random_enemy_model_table.Emissive_Material_Index) or enemy_table.Emissive_Material_Index
                enemy:SetMaterialScalarParameter(enemy_table.Emissive_Key, enemy_table.Emissive_Spawn_Value, mat_index or -1)
                --print("SetMaterialScalarParameter", enemy_table.Emissive_Key, enemy_table.Emissive_Spawn_Value)
            end

            if (enemy_table.Spawning_Config.type == "zombie_spawns" or enemy_table.Spawning_Config.type == "direct_zombie_spawns") then
                if (not is_ground_anim_disabled) then
                    enemy:SetFlyingMode(true)
                    enemy:SetValue("GroundAnim", true, false)
                    enemy:PlayAnimation(Enemy_Under_Ground_Animation.asset, AnimationSlotType.FullBody, false, 0, 0)

                    --local players_sound = GetPlayersInRadius(selected_spawn.location, RANDOM_SOUNDS.spawn_dirt_sound.falloff_distance)
                    --for k, v in pairs(players_sound) do
                        --Events.CallRemote("ZombieGroundDirt", v, VZ_RandomSound(RANDOM_SOUNDS.spawn_dirt_sound), selected_spawn.location)
                    --end
                    Events.BroadcastRemoteInRadius("ZombieGroundDirt", selected_spawn.location, RANDOM_SOUNDS.spawn_dirt_sound.falloff_distance, Reliability.Unreliable, VZ_RandomSound(RANDOM_SOUNDS.spawn_dirt_sound), selected_spawn.location)

                    Timer.SetTimeout(function()
                        if enemy:IsValid() then
                            if enemy:GetHealth() > 0 then
                                EnemyOutGround(enemy, selected_spawn, selected_spawn_target, true)
                            end
                        end
                    end, Enemy_Under_Ground_Animation.duration_ms)
                else
                    EnemyOutGround(enemy, selected_spawn, selected_spawn_target, false)
                end
            else
                EnemySwitchToPlaying(enemy)
            end

            if not enemy_table.Boss then
                table.insert(ENEMY_CHARACTERS, enemy)
            else
                table.insert(BOSS_CHARACTERS, enemy)
            end

            if enemy:IsValid() then
                VZ_EVENT_CALL("Events", "VZ_EnemySpawned", enemy)
            end
        else
            --Console.Error("Can't select a zombie spawn")
            -- Can go there for bosses when there isn't spawns for them
        end
    end
end

function EnemyOutGround(enemy, selected_spawn, selected_spawn_target, after_ground_anim)

    local enemy_table = GetEnemyTable(enemy)

    if ZDEV_IsModeEnabled("ZDEV_DEBUG_ZOMBIES_SPAWNS") then
        print("EnemyOutGround", enemy:GetID(), selected_spawn.zspawnid)
    end

    if after_ground_anim then
        enemy:SetValue("GroundAnim", nil, false)
        enemy:StopAnimation(Enemy_Under_Ground_Animation.asset)
        enemy:SetLocation(selected_spawn.location + Vector(0, 0, 97))
        --zombie:SetGravityEnabled(true)
        enemy:SetFlyingMode(false)
    end

    if selected_spawn_target.type == "ground" then
        EnemySwitchToPlaying(enemy)
    elseif selected_spawn_target.type == "barricade" then
        enemy:SetValue("Target_type", "barricade", false)
        local i, b = GetBarricadeFromZSpawnID(selected_spawn_target.zspawnid)
        enemy:SetValue("Target", i, false)

        enemy:MoveTo(selected_spawn_target.z_move_to_b_target_location, GetEnemyTable(enemy).Acceptance_Radius)
        enemy:LookAt(selected_spawn_target.barricade_location)
    elseif selected_spawn_target.type == "vault" then
        enemy:SetValue("Target_type", "vault", false)
        enemy:SetValue("Target", selected_spawn_target.zspawnid, false)

        local target_loc = selected_spawn_target[enemy_table.Types[enemy:GetValue("EnemyType")].Vault_Anim.target_location_key]
        enemy:MoveTo(target_loc, GetEnemyTable(enemy).Acceptance_Radius)
        enemy:LookAt(target_loc + Vector(0, 0, 180))
    end
end

function RespawnEnemy(enemy)
    if enemy:IsValid() then
        if enemy:GetHealth() > 0 then
            SpawnEnemy(enemy:GetValue("EnemyName"), enemy:GetValue("EnemyTypeAtSpawn"))
            enemy:SetHealth(0)
        end
    end
end
Package.Export("RespawnEnemy", RespawnEnemy)

function SmartSpawnLogic(spawns_table)
    if table_count(spawns_table) == 0 then
        return
    end

    local players_alive = GetPlayersAlive()
    if table_count(players_alive) == 0 then
        return
    end

    local random_player = players_alive[math.random(table_count(players_alive))]
    local character = random_player:GetControlledCharacter()
    if not character then
        return
    end
    local loc = character:GetLocation()

    -- Collect every spawn with its distance
    local sorted_spawns = {}
    for _, v in pairs(spawns_table) do
        sorted_spawns[#sorted_spawns + 1] = {
            spawn = v,
            dist_sq = loc:DistanceSquared(v.location)
        }
    end

    -- Sort nearest -> farthest
    table.sort(sorted_spawns, function(a, b)
        return a.dist_sq < b.dist_sq
    end)

    -- Only as many candidates as we have weights for
    local candidates = math.min(#sorted_spawns, #Zombies_Nearest_SmartSpawns_Percentage)

    -- Total weight of the candidates actually available
    local total = 0
    for i = 1, candidates do
        total = total + Zombies_Nearest_SmartSpawns_Percentage[i]
    end

    local roll = math.random(total)
    local cur = 0
    for i = 1, candidates do
        cur = cur + Zombies_Nearest_SmartSpawns_Percentage[i]
        if roll <= cur then
            --print("Selected spawn rank " .. i)
            return sorted_spawns[i].spawn
        end
    end
end

function SpawnEnemyIntervalFunc()
    if not GAME_PAUSED then
        if (REMAINING_ENEMIES_TO_SPAWN > 0 and table_count(ENEMY_CHARACTERS) < Max_enemies_spawned) then
            REMAINING_ENEMIES_TO_SPAWN = REMAINING_ENEMIES_TO_SPAWN - 1

            local index = math.random(table_count(ENEMIES_TO_SPAWN_TBL))
            local Enemy = ENEMIES_TO_SPAWN_TBL[index]
            if Enemy then
                SpawnEnemy(Enemy[1], Enemy[2])

                if not In_Hellhound_Round then
                    if (not MAP_SETTINGS or MAP_SETTINGS.Bosses_Enabled) then
                        for k, v in pairs(Enemies_Config) do
                            if v.Boss then
                                if not IsEnemyDisabled(k) then
                                    if (v.Spawning_Config and v.Spawning_Config.minimum_round_to_spawn and v.Spawning_Config.minimum_round_to_spawn <= ROUND_NB) then
                                        local chance_to_spawn = v.Spawning_Config.spawn_chance_per_zombie
                                        if math.random(1000) <= chance_to_spawn then
                                            local boss_type
                                            for k2, v2 in pairs(v.Types) do
                                                boss_type = k2
                                                if v2.default then
                                                    break
                                                end
                                            end
                                            SpawnEnemy(k, boss_type)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                table.remove(ENEMIES_TO_SPAWN_TBL, index)
            else
                warn("Missing enemies in the TO_SPAWN Table")
            end

            --CheckRoundFinished()
        end
    end
end

function EnemyStartFollow(enemy, target_char)
    local enemy_table = GetEnemyTable(enemy)

    enemy:SetValue(
        "Target",
        target_char,
        false
    )

    local acceptance_r_mult = 1

    local veh = target_char:GetVehicle()
    if IsValid(veh) then
        acceptance_r_mult = veh:GetValue("AR_Multiplier")
    end

    if enemy:GetLocation():DistanceSquared(target_char:GetLocation()) < enemy_table.Damage_At_Distance_sq then
        EnemyAttack(enemy)
    else
        enemy:Follow(target_char, enemy_table.Acceptance_Radius*acceptance_r_mult, true, true, Enemy_Route_Update_ms / 1000)
        UpdateEnemyLookAt(enemy)
    end
end

function EnemyRefreshTarget(enemy)
    if EnemyCanTarget(enemy) then
        if enemy:GetValue("Target_type") == "player" then
            local cur_target = enemy:GetValue("Target")
            local nearest_ply_char
            local nearest_dist_sq
            local zombie_loc = enemy:GetLocation()
            for k, v in pairs(Character.GetPairs()) do
                local ply = v:GetPlayer()
                if ply then
                    if not v:GetValue("PlayerDown") then
                        if not v:GetValue("EnemiesDontTarget") then
                            local dist_sq = zombie_loc:DistanceSquared(v:GetLocation())
                            if (not nearest_ply_char or (nearest_dist_sq > dist_sq)) then
                                nearest_ply_char = v
                                nearest_dist_sq = dist_sq
                            end
                        end
                    end
                end
            end
            if (nearest_ply_char and (not cur_target or cur_target ~= nearest_ply_char)) then
                EnemyStartFollow(enemy, nearest_ply_char)
            elseif (not nearest_ply_char) then
                --print("StopFollow")
                enemy:SetValue(
                    "Target",
                    nil,
                    false
                )

                enemy:MoveTo(zombie_loc, 100)
            end
        elseif enemy:GetValue("Target_type") == "noise_player" then
            -- Has lost noise_player... Don't make noise and you're fine
            enemy:SetValue("Target_type", "noise", false)
            ChangeEnemyType(enemy, "walk")
        end
    end
end

function EnemyHearNoiseCanTargetPlayer(instigator)
    if not IsValid(instigator) then return end
    local char = instigator:GetControlledCharacter()
    if not IsValid(char) then return end
    if char:GetValue("PlayerDown") then return end
    if char:GetValue("EnemiesDontTarget") then return end
    return char
end

function EnemyCanTarget(enemy)
    if not IsValid(enemy) then return end
    if GAME_PAUSED then return end
    if enemy:IsInRagdollMode() then return end
    if enemy:GetValue("PunchCoolDownTimer") then return end
    return true
end

function EnemyHearNoise(enemy, instigator, awareness, added_amount)
    if not EnemyCanTarget(enemy) then return end
    local char = EnemyHearNoiseCanTargetPlayer(instigator)
    if not char then return end

    if enemy:GetValue("Target_type") == "noise" then
        local target_loc = char:GetLocation()
        enemy:SetValue("Target", target_loc, false)
        enemy:MoveTo(target_loc, 100)
    elseif enemy:GetValue("Target_type") == "noise_player" then
        if enemy:GetValue("Target") ~= char then
            EnemyStartFollow(enemy, char)
        end
    end
end

function EnemyNoiseThreshold(enemy, instigator)
    if not EnemyCanTarget(enemy) then return end
    local char = EnemyHearNoiseCanTargetPlayer(instigator)
    if not char then return end

    --VZ_Noise.RemoveListeningEntity(enemy)

    enemy:SetValue(
        "Target_type",
        "noise_player",
        false
    )

    ChangeEnemyType(enemy, "run")

    EnemyStartFollow(enemy, char)
end


function EnemyInitPlayerTarget(enemy)
    enemy:SetValue(
        "RefreshTargetInterval",
        Timer.SetInterval(EnemyRefreshTarget, Enemies_Target_Refresh_ms, enemy),
        false
    )
    EnemyRefreshTarget(enemy)
end

function EnemySwitchToPlaying(enemy)
    if enemy:IsValid() then
        local enemy_table = GetEnemyTable(enemy)
        if type(enemy_table) ~= "table" then return error("EnemyRefreshTarget: EnemyRefreshTarget enemy table is invalid") end

        local target_type = "player"
        local Custom_Target_Behavior = enemy_table.Custom_Target_Behavior
        if Custom_Target_Behavior then
            target_type = Custom_Target_Behavior.type
        end
        enemy:SetValue(
            "Target_type",
            target_type,
            false
        )
        enemy:SetValue(
            "Target",
            nil,
            false
        )

        enemy:SetValue("CanDamageTimeout", Timer.SetTimeout(function()
            if enemy:IsValid() then
                enemy:SetValue("CanDamageTimeout", nil, false)
            end
        end, GetEnemyTable(enemy).Can_Damage_After_ms), false)
        local zloc = enemy:GetLocation()
        enemy:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
        --print("StuckNB Set 0 ZombieSwitchToPlayerTarget")
        enemy:SetValue("StuckNB", 0, false)

        if target_type == "player" then
            EnemyInitPlayerTarget(enemy)
        elseif target_type == "noise" then
            if VZ_Noise then
                VZ_Noise.NewListeningEntity(enemy, Custom_Target_Behavior.threshold, EnemyNoiseThreshold, Custom_Target_Behavior.reduce_interval_ms, Custom_Target_Behavior.reduce_amount, EnemyHearNoise)
            else
                Console.Warn("VZ_Noise missing for enemy '" .. tostring(enemy:GetValue("EnemyName")) .. "'")
            end
        end
    end
end

function LeaveBarricade(enemy, barricade)
    --print("LeaveBarricade", enemy, barricade)

    if enemy:GetValue("AttackB") then
        --print("AttackBInterval Clear", enemy)
        Timer.ClearInterval(enemy:GetValue("AttackBInterval"))
        enemy:SetValue("AttackBInterval", nil, false)
        enemy:SetValue("AttackB", nil, false)
        enemy:SetValue("AttackBID", nil, false)
    end
    --print(NanosTable.Dump(barricade))
    local spawn = GetSpawnTargetFromZSpawnID(barricade.zspawnid)
    enemy:SetLocation(spawn.z_leave_b_tp_location + Vector(0, 0, 100))
    enemy:SetRotation(spawn.z_leave_b_tp_rotation)

    EnemySwitchToPlaying(enemy)
end

function EnemyAttackSound(enemy)
    local enemy_table = GetEnemyTable(enemy)
    local zombie_loc = enemy:GetLocation()
    --local play_sound_for_players = GetPlayersInRadius(zombie_loc, enemy_table.Attack_Sounds.falloff_distance)
    --for i, v in ipairs(play_sound_for_players) do
        --Events.CallRemote("PlayVZSound", v, {random_sound_tbl=enemy_table.Attack_Sounds, random_sound_selected=VZ_RandomSound(enemy_table.Attack_Sounds)}, zombie_loc)
    --end
    Events.BroadcastRemoteInRadius("PlayVZSound", zombie_loc, enemy_table.Attack_Sounds.falloff_distance, Reliability.Unreliable, {random_sound_tbl=enemy_table.Attack_Sounds, random_sound_selected=VZ_RandomSound(enemy_table.Attack_Sounds)}, zombie_loc)
end

function AttackBarricade(enemy, barricade, start)
    --print("AttackBarricade", enemy, barricade, start)

    --print(NanosTable.Dump(debug.getinfo(2)))
    --print("AttackBarricade", start)
    local top_barricades = table_count(barricade.top.barricades)
    if top_barricades > 0 then
        if start then
            enemy:SetValue(
                "AttackBInterval",
                Timer.SetInterval(AttackBarricade, GetEnemyTable(enemy).Damage_Barricade_Cooldown_ms,
                enemy,
                barricade,
                false),
                false
            )
            enemy:SetValue(
                "AttackB",
                barricade,
                false
            )
            enemy:SetValue(
                "AttackBID",
                barricade.zspawnid,
                false
            )
            enemy:SetValue(
                "Target",
                nil,
                false
            )
            local spawn = GetSpawnTargetFromZSpawnID(barricade.zspawnid)
            --zombie:SetLocation(spawn.z_move_to_b_target_location)
            enemy:SetRotation(spawn.z_leave_b_tp_rotation)
        else
            local random_z_attack_anim = RandomEnemyAttackAnim(enemy, enemy:GetValue("EnemyType"))
            enemy:PlayAnimation(random_z_attack_anim[1], AnimationSlotType.FullBody, false)
            EnemyAttackSound(enemy)
            Timer.SetTimeout(function()
                if enemy:IsValid() then
                    if enemy:GetValue("AttackB") then
                        DamageBarricade(barricade)
                        local new_top_barricades = table_count(barricade.top.barricades)
                        if new_top_barricades == 0 then
                            enemy:StopAnimation(random_z_attack_anim[1])
                            for k, v in pairs(GetMergedEnemiesChars()) do
                                if (v:GetValue("AttackB") and v:GetValue("AttackBID") == barricade.zspawnid) then
                                    LeaveBarricade(v, barricade)
                                end
                            end
                        end
                    end
                end
            end, random_z_attack_anim[2])
        end
    else
        LeaveBarricade(enemy, barricade)
    end
end

function ReachTarget_PrePlayerTargetFailed(enemy)
    Console.Warn("Reach target (blocker) failed, Respawning zombie, the zombie was there : " .. tostring(enemy:GetLocation()))
    Timer.SetTimeout(function()
        RespawnEnemy(enemy)
    end, 1)
end

function EnemyGetDamageAmount(enemy, target_char)
    local enemy_table = GetEnemyTable(enemy)
    if type(enemy_table.Damage_Amount) == "number" then
        return enemy_table.Damage_Amount
    elseif type(enemy_table.Damage_Amount) == "function" then
        return enemy_table.Damage_Amount(target_char)
    else
        return Console.Error("EnemyGetDamageAmount invalid enemy_table.Damage_Amount value for '" .. tostring(enemy:GetValue("EnemyName")) .. "'")
    end
end

function EnemyAttack(enemy)
    local plychar = enemy:GetValue("Target")
    if (IsValid(plychar) and (not plychar:GetValue("PlayerDown"))) then
        --print("EnemyAttack", enemy, plychar, plychar:GetValue("BotGotInRagdoll"))

        local random_z_attack_anim = RandomEnemyAttackAnim(enemy, enemy:GetValue("EnemyType"))
        enemy:PlayAnimation(random_z_attack_anim[1], AnimationSlotType.FullBody, false)
        enemy:SetValue("Target", nil, false)
        enemy:SetValue("StuckNB", nil, false)

        local ply_veh = plychar:GetVehicle()

        --print(plychar:GetLocation():DistanceSquared(enemy:GetLocation()), GetEnemyTable(enemy).Damage_At_Distance_sq * 4)
        if (plychar:GetLocation():DistanceSquared(enemy:GetLocation()) > GetEnemyTable(enemy).Damage_At_Distance_sq * 4 and (not IsValid(ply_veh))) then
            local w_p_nb = enemy:GetValue("WeirdPunchNB")
            --print(w_p_nb)

            if plychar:GetPlayer().BOT then
                if plychar:GetValue("BotGotInRagdoll") then
                    if not enemy:GetValue("AppliedUniqueWeirdPunch") then
                        enemy:SetValue("AppliedUniqueWeirdPunch", true, false)
                        plychar:SetValue("WeirdPunchCount", plychar:GetValue("WeirdPunchCount") + 1, false)
                        --print(plychar:GetValue("WeirdPunchCount"))
                        if plychar:GetValue("WeirdPunchCount") >= Weird_Attack_On_Bots_Unique_Count_Kill then
                            local health = plychar:GetHealth()
                            plychar:ApplyDamage(health - 1000)
                            plychar:SetValue("WeirdPunchCount", 0, false)
                        end
                    end
                end
            end

            if w_p_nb < Enemies_Weird_Punch_Respawn_After_x_Weird - 1 then
                enemy:SetValue("WeirdPunchNB", w_p_nb + 1, false)
            else
                RespawnEnemy(enemy)
                return
            end
        else
            enemy:SetValue("WeirdPunchNB", 0, false)
            plychar:SetValue("WeirdPunchCount", 0, false)
        end

        enemy:RotateTo(Rotator(0, VectorGetLookAt(enemy:GetLocation(), plychar:GetLocation()).Yaw, 0), random_z_attack_anim[2]/1000, 0)

        if not plychar:GetPlayer():GetValue("MM_GodMode") then
            local enemy_table = GetEnemyTable(enemy)
            if enemy_table.Damage_Amount then
                Timer.SetTimeout(function()
                    if enemy:IsValid() then
                        if enemy:GetHealth() > 0 then
                            for k, v in pairs(PLAYING_PLAYERS) do
                                if v:IsValid() then
                                    local char = v:GetControlledCharacter()
                                    if (char and char:IsValid() and enemy:IsValid()) then
                                        if not char:GetValue("PlayerDown") then
                                            local plychar_loc = char:GetLocation()
                                            local plychar_veh = char:GetVehicle()

                                            local dist_check_mult = 1
                                            if IsValid(plychar_veh) then
                                                dist_check_mult = plychar_veh:GetValue("Damage_Radius_sq_Mult")
                                            end

                                            local z_loc = enemy:GetLocation()
                                            --print(char:GetPlayer():GetAccountName(), plychar_loc:DistanceSquared(z_loc), enemy_table.Damage_At_Distance_sq*dist_check_mult)
                                            if (plychar_loc:DistanceSquared(z_loc) <= enemy_table.Damage_At_Distance_sq*dist_check_mult) then
                                                local rel = RelRot1(enemy:GetRotation().Yaw, VectorGetLookAt(enemy:GetLocation(), char:GetLocation()).Yaw)
                                                if (rel > -Enemies_Damage_Angle_LookAt and rel < Enemies_Damage_Angle_LookAt) then
                                                    if enemy_table.Damage_Amount then
                                                        local dm_amount = EnemyGetDamageAmount(enemy, char)
                                                        if not IsValid(plychar_veh) then
                                                            char:ApplyDamage(dm_amount, "", DamageType.Punch)
                                                        else
                                                            plychar_veh:ApplyDamage(dm_amount, "", DamageType.Punch)
                                                        end
                                                    end
                                                    if enemy_table.Custom_Attack_Behavior then
                                                        if enemy_table.Custom_Attack_Behavior.type == "grab" then
                                                            if not char:GetValue("PlayerDown") then
                                                                local ply = char:GetPlayer()
                                                                if ply then
                                                                    if not plychar_veh then
                                                                        enemy:PlayAnimation("vzombies-assets::AS_NAAT_Zombie_Grab_To_Wrestle", AnimationSlotType.FullBody, true, 0.1, 0.1)
                                                                        if not ply.BOT then
                                                                            char:SetInputEnabled(false)
                                                                            char:SetCanAim(false)
                                                                        end
                                                                        char:PlayAnimation("vzombies-assets::AS_NAAT_Human_Grab_To_Wrestle", AnimationSlotType.FullBody, true)

                                                                        char:SetValue("PlayerGrabbedBy", enemy, true)

                                                                        local l_at = VectorGetLookAt(char:GetLocation(), enemy:GetLocation())
                                                                        char:SetRotation(Rotator(0, l_at.Yaw, 0))

                                                                        CheckToStopBotReviveTimer(char, false)
                                                                        if ply.BOT then
                                                                            BotResetTarget(ply)
                                                                            ply:SetValue("BotAimPlayer", nil, true)

                                                                            if char:GetValue("DoingAction") then
                                                                                --print("STOP MOVETO BOT")
                                                                                char:SetValue("DoingAction", nil, false)
                                                                                char:MoveTo(char:GetLocation(), 50)
                                                                            end
                                                                        end
                                                                        Timer.SetTimeout(function()
                                                                            if enemy:IsValid() then
                                                                                enemy:StopAnimation("vzombies-assets::AS_NAAT_Zombie_Grab_To_Wrestle")
                                                                            end
                                                                            if (char:IsValid() and not char:GetValue("PlayerDown") and char:GetValue("PlayerGrabbedBy") and char:GetValue("PlayerGrabbedBy") == enemy) then
                                                                                char:StopAnimation("vzombies-assets::AS_NAAT_Human_Grab_To_Wrestle")
                                                                                if not ply.BOT then
                                                                                    char:SetInputEnabled(true)
                                                                                    char:SetCanAim(true)
                                                                                else
                                                                                    RequestBotAction(ply)
                                                                                    ply:SetValue("BotAimPlayer", GetRandomPlayer():GetID(), true)
                                                                                end
                                                                                char:SetValue("PlayerGrabbedBy", nil, true)
                                                                            end
                                                                        end, enemy_table.Custom_Attack_Behavior.Grab_Time_ms)
                                                                    else
                                                                        char:LeaveVehicle()
                                                                    end
                                                                end
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
                        end
                    end
                end, random_z_attack_anim[2])
            end

            enemy:SetValue("PunchCoolDownTimer", Timer.SetTimeout(function()
                if enemy:IsValid() then
                    enemy:SetValue("PunchCoolDownTimer", nil, false)
                    local zloc = enemy:GetLocation()
                    enemy:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
                    --print("StuckNB Set 0 PunchCoolDownTimer finished")
                    enemy:SetValue("StuckNB", 0, false)
                    EnemyRefreshTarget(enemy)
                end
            end, random_z_attack_anim[3]), false)
        else
            enemy:SetValue("PunchCoolDownTimer", true, false)
        end

        EnemyAttackSound(enemy)
    end
end

function ZMoveCompleted(enemy, succeeded)
    if enemy:IsValid() then
        --print("Enemy MoveCompleted", succeeded)
        local target_type = enemy:GetValue("Target_type")
        if target_type == "barricade" then
            if succeeded then
                --print(enemy:GetValue("Target"))
                AttackBarricade(enemy, BARRICADES[enemy:GetValue("Target")], true)
            else
                ReachTarget_PrePlayerTargetFailed(enemy)
            end
        elseif target_type == "vault" then
            if succeeded then
                local spawn_target = GetSpawnTargetFromZSpawnID(enemy:GetValue("Target"))

                local anim = GetEnemyTable(enemy).Types[enemy:GetValue("EnemyType")].Vault_Anim

                local target_rot = spawn_target[anim.target_rotation_key]
                local target_loc = spawn_target[anim.target_location_key]
                enemy:SetLocation(target_loc + Vector(0, 0, 97))
                enemy:SetRotation(target_rot)

                enemy:PlayAnimation(anim.path, AnimationSlotType.FullBody, false, 0.25, 0)

                Timer.SetTimeout(function()
                    if enemy:IsValid() then
                        if enemy:GetHealth() > 0 then
                            enemy:StopAnimation(anim.path)

                            local leave_loc = spawn_target[anim.leave_location_key]
                            local leave_rot = spawn_target[anim.leave_rotation_key]

                            enemy:SetLocation(leave_loc + Vector(0, 0, 100))
                            enemy:SetRotation(leave_rot)

                            EnemySwitchToPlaying(enemy)
                        end
                    end
                end, anim.timeout_ms)
            else
                ReachTarget_PrePlayerTargetFailed(enemy)
            end
        elseif target_type == "player" or target_type == "noise_player" then
            --print("MoveCompleted", "player", succeeded, zombie:GetValue("CanDamageTimeout"))
            if (succeeded and not enemy:GetValue("CanDamageTimeout")) then
                EnemyAttack(enemy)
            else
                enemy:SetValue("Target", nil, false)
                --print("StuckNB Set 0 MoveCompleted false or CanDamageTimeout target player")
                if succeeded then
                    enemy:SetValue("StuckNB", 0, false)
                end
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE("Character", "MoveComplete", ZMoveCompleted)

VZ_EVENT_SUBSCRIBE("Character", "Death", function(char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer, ...)
    if char:GetValue("Enemy") == true then
        if causer then
            if causer:IsValid() then
                if not causer:IsA(Character) then
                    local instig_char
                    if IsAVehicle(causer) then
                        instig_char = causer:GetPassenger(0)
                    else
                        instig_char = causer:GetHandler()
                    end
                    if instig_char then
                        local bot = instig_char:GetPlayer()
                        if (bot and bot.BOT) then
                            instigator = bot
                        end
                    end
                end
            end
        end

        if char:GetValue("AttackB") then
            Timer.ClearInterval(char:GetValue("AttackBInterval"))
            char:SetValue("AttackBInterval", nil, false)
            char:SetValue("AttackB", nil, false)
            char:SetValue("AttackBID", nil, false)
        end
        --print("Death", "RefreshTargetInterval", char:GetValue("RefreshTargetInterval"))
        if type(char:GetValue("RefreshTargetInterval")) == "number" then
            Timer.ClearInterval(char:GetValue("RefreshTargetInterval"))
        end

        VZ_Noise.RemoveListeningEntity(char)

        -- No instigator when zombies killed by nuke so it doesn't spawn new powerups or give player money, same in instakill (money given at damage for instakill)
        if instigator then
            local zkills = instigator:GetValue("ZKills")
            if zkills then
                local instig_char = instigator:GetControlledCharacter()
                if instig_char  then
                    local picked_thing = instig_char:GetPicked()
                    if (picked_thing and picked_thing:IsValid() and picked_thing:IsA(Melee)) then
                        AddMoney(instigator, Player_Zombie_Kill_Knife_Money)
                    else
                        AddMoney(instigator, Player_Zombie_Kill_Money)
                    end
                    instigator:SetValue("ZKills", zkills + 1, false)
                    ZombieDie_SpawnRandomPowerup(char)
                    KILL_COUNT = KILL_COUNT + 1
                end
            end
        end

        for k, v in pairs(ENEMY_CHARACTERS) do
            if v == char then
                ENEMY_CHARACTERS[k] = nil
            end
        end
        for k, v in pairs(BOSS_CHARACTERS) do
            if v == char then
                BOSS_CHARACTERS[k] = nil
            end
        end
        local enemy_table = GetEnemyTable(char)
        if enemy_table then
            if enemy_table.Emissive_Key then
                char:SetMaterialScalarParameter(enemy_table.Emissive_Key, 0.0)
            end
        end

        SendEnemiesRemaining() -- TODO: Optimize remove this and listen for Character Death clientside?

        if char:GetValue("EnemyType") == "napalm" then
            --print("Grenade")

            local grenade = Grenade(
                char:GetLocation(),
                Rotator(0, 0, 0),
                "nanos-world::SM_Grenade_G67",
                "nanos-world::P_Grenade_Special",
                "",
                CollisionType.NoCollision,
                false
            )
            grenade:SetDamage(table.unpack(Napalm_Explosion_Damage))
            grenade:Explode()
        end

        table.insert(ENEMY_DEAD_RAGDOLLS, char)

        if (IsValid(char)) then
            VZ_EVENT_CALL("Events", "VZ_EnemyDied", char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer, ...)
        end

        Timer.SetTimeout(function()
            if char:IsValid() then
                for i, v in ipairs(ENEMY_DEAD_RAGDOLLS) do
                    if v == char then
                        table.remove(ENEMY_DEAD_RAGDOLLS, i)
                        break
                    end
                end
                char:Destroy()
            end
        end, DestroyEnemy_After_death_ms)

        local edr_count = table_count(ENEMY_DEAD_RAGDOLLS)
        if edr_count > Max_Enemies_Dead_Ragdolls then
            for i = Max_Enemies_Dead_Ragdolls + 1, edr_count do
                if ENEMY_DEAD_RAGDOLLS[1]:IsValid() then
                    ENEMY_DEAD_RAGDOLLS[1]:Destroy()
                end
                table.remove(ENEMY_DEAD_RAGDOLLS, 1)
            end
        end

        local was_hellhound_round = In_Hellhound_Round

        local finished = CheckRoundFinished()
        if finished then
            if was_hellhound_round then
                SpawnPowerup(char:GetLocation(), "max_ammo")
            end
        end
    end
end)

function RandomEnemyJoker(char)
    local joker_chance = GetEnemyTable(char).Joker_Chance
    if joker_chance then
        local target_type = char:GetValue("Target_type")
        if target_type ~= "barricade" then
            if not char:IsInRagdollMode() then
                local rand1000 = math.random(10000)
                if rand1000 <= joker_chance then
                    --print("Joker")
                    char:SetRagdollMode(true)
                    Events.BroadcastRemote("JokerZombieSound", Reliability.Unreliable, char)
                end
            end
        end
    end
end



function AttachRepackParticle(char, pap_repack_effect)
    local repack_particle = Particle(
        Vector(),
        Rotator(),
        PAP_Repack_Config[pap_repack_effect].particle_asset,
        false,
        true
    )
    repack_particle:AttachTo(char, AttachmentRule.SnapToTarget, "", 0)
    repack_particle:SetRelativeLocation(PAP_Repack_Config[pap_repack_effect].particle_relative_loc)
    repack_particle:SetLifeSpan(PAP_Repack_Config[pap_repack_effect].particle_lifespan / 1000)
    return repack_particle
end


local DoubleDamage_Applied = false

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, dtype, from_direction, instigator, causer)
    if not (char:GetValue("Enemy") == true and damage > 0) then DoubleDamage_Applied = false; return end
    if char:IsDead() then DoubleDamage_Applied = false; return end
    --print("TakeDamage", char:GetValue("EnemyType"), damage, bone, dtype, from_direction, instigator, causer)

    if causer then
        if causer:IsValid() then
            if not causer:IsA(Character) then
                local instig_char
                if IsAVehicle(causer) then
                    instig_char = causer:GetPassenger(0)
                else
                    instig_char = causer:GetHandler()
                end
                if instig_char then
                    local bot = instig_char:GetPlayer()
                    if (bot and bot.BOT) then
                        instigator = bot
                    end
                end
            end
        end
    end
    if instigator then
        if not DoubleDamage_Applied then
            AddMoney(instigator, Player_Zombie_Damage_Money)
            local instig_char = instigator:GetControlledCharacter()

            local enemy_table = GetEnemyTable(char)
            if (ACTIVE_POWERUPS.instakill and not enemy_table.Boss) then
                local instigator_passed = instigator
                if instigator.BOT then
                    instigator_passed = "BOT"
                end
                VZ_EVENT_CALL("Events", "VZ_ZombieKill_InstaKill", char, damage, bone, dtype, from_direction, instigator_passed, causer)

                local zkills = instigator:GetValue("ZKills")
                if zkills then
                    AddMoney(instigator, Player_Zombie_Kill_Money)
                    ZombieDie_SpawnRandomPowerup(char)
                    instigator:SetValue("ZKills", zkills + 1, false)
                    char:SetHealth(0)
                    KILL_COUNT = KILL_COUNT + 1
                end
            elseif (instig_char and not char:GetValue("ApplyingRepack")) then
                if (not causer or (not causer:IsValid()) or ((not causer:IsA(Melee)) and (not causer:IsA(Grenade)) and (not IsAVehicle(causer)))) then
                    local perks = instig_char:GetValue("OwnedPerks")
                    local mult = 1
                    local added_damage = 0
                    if (perks and perks["doubletap"]) then
                        mult = mult * PERKS_CONFIG.doubletap.MultDamage
                    end
                    local charInvID = GetCharacterInventory(instig_char)
                    if charInvID then
                        local Inv = PlayersCharactersWeapons[charInvID]
                        if Inv.selected_slot then
                            for i, v in ipairs(Inv.weapons) do
                                if (v.slot == Inv.selected_slot and v.weapon) then
                                    if v.weapon:IsValid() then
                                        if v.pap then
                                            mult = mult * Pack_a_punch_damage_mult
                                            if v.pap_repack_effect then
                                                if not instigator:GetValue("RepackCooldown") then
                                                    --print("PAP Repack Apply", v.pap_repack_effect)

                                                    added_damage = added_damage + PAP_Repack_Config[v.pap_repack_effect].damage_on_target
                                                    instigator:SetValue("RepackCooldown", true, false)
                                                    Timer.SetTimeout(function()
                                                        if instigator:IsValid() then
                                                            instigator:SetValue("RepackCooldown", nil, false)
                                                        end
                                                    end, PAP_Repack_Config[v.pap_repack_effect].cooldown_ms)
                                                    AttachRepackParticle(char, v.pap_repack_effect)

                                                    for k2, v2 in pairs(Character.GetAll()) do
                                                        if (v2:IsValid() and v2:GetHealth() > 0 and v2 ~= char and v2:GetValue("Enemy")) then
                                                            local dist_sq = v2:GetLocation():DistanceSquared(char:GetLocation())
                                                            if (dist_sq > 0 and dist_sq < PAP_Repack_Config[v.pap_repack_effect].radius_sq) then
                                                                v2:SetValue("ApplyingRepack", true, false)
                                                                AttachRepackParticle(v2, v.pap_repack_effect)
                                                                local ap_dam_instig = instigator
                                                                if instigator.BOT then
                                                                    ap_dam_instig = nil
                                                                end
                                                                v2:ApplyDamage(math.max(1, math.floor(PAP_Repack_Config[v.pap_repack_effect].damage_func(dist_sq) + 0.5)), bone, DamageType.Unknown, Vector(), ap_dam_instig, causer)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    break
                                end
                            end
                        end
                    end
                    if mult > 1 then
                        DoubleDamage_Applied = true
                        --print("DOUBLE APPLY", (mult-1))
                        if (char:GetHealth() - damage - damage * (mult-1) > 0) then
                            RandomEnemyJoker(char)
                        end
                        if not instigator.BOT then
                            --print(causer)
                            if causer then
                                char:ApplyDamage(damage * (mult-1) + added_damage, bone, dtype, from_direction, instigator, causer)
                            else
                                char:ApplyDamage(damage * (mult-1) + added_damage, bone, dtype, from_direction, instigator)
                            end
                        else
                            char:ApplyDamage(damage * (mult-1) + added_damage, bone, dtype, from_direction, nil, causer)
                        end
                    elseif char:GetHealth() - damage > 0 then
                        RandomEnemyJoker(char)
                    end
                end
            end
        end
    end
    if DoubleDamage_Applied then
        DoubleDamage_Applied = false
        --print("DoubleDamage_Applied = false so TakeDamage called 2 times, good")
    end
    if (char:IsValid() and char:GetValue("ApplyingRepack")) then
        char:SetValue("ApplyingRepack", nil, false)
    end
end)

Timer.SetInterval(function()
    if ROUND_NB > 0 then
        for k, v in pairs(Character.GetAll()) do
            if v:IsValid() then
                local loc = v:GetLocation()
                if (loc.Z > MAP_Z_LIMITS.max or loc.Z < MAP_Z_LIMITS.min) then
                    --print("Character Reached MAP Z LIMITS")
                    if v:GetValue("Enemy") then
                        if v:GetHealth() > 0 then
                            RespawnEnemy(v)
                        end
                    elseif v:GetPlayer() then
                        PlayerCharacterDie(v, true)
                    end
                end
            end
        end
    end
end, Map_Z_Limits_Check_Interval_ms)

Timer.SetInterval(function()
    if ROUND_NB > 0 then
        if not GAME_PAUSED then
            for k, v in pairs(GetEnemiesCharsCopy()) do
                if v:IsValid() then
                    if v:GetValue("Enemy") then
                        if v:GetHealth() > 0 then
                            if not v:IsInRagdollMode() then
                                local stuck_nb = v:GetValue("StuckNB")
                                local last_loc = v:GetValue("LastLocation")
                                --print("StuckNB check start", stuck_nb)
                                if (stuck_nb and last_loc) then
                                    last_loc = Vector(last_loc[1], last_loc[2], last_loc[3])
                                    local loc = v:GetLocation()
                                    --print(last_loc:DistanceSquared(loc))
                                    if last_loc:DistanceSquared(loc) <= Enemies_Stuck_DistanceSq then
                                        --print("StuckNB Add 1")
                                        stuck_nb = stuck_nb + 1
                                        v:SetValue("StuckNB", stuck_nb, false)
                                        if stuck_nb >= Enemies_Stuck_Respawn_After_x_Stuck then
                                            RespawnEnemy(v)
                                            --print("Zombie Respawn, stuck")
                                        end
                                    else
                                        --print("StuckNB Set 0 because far")
                                        v:SetValue("StuckNB", 0, false)
                                    end
                                    v:SetValue("LastLocation", {loc.X, loc.Y, loc.Z}, false)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end, Enemies_Stuck_Check_Each_ms)

function UpdateEnemyLookAt(v)
    if v:IsValid() then
        if v:GetValue("Enemy") then
            if v:GetHealth() > 0 then
                local target_type = v:GetValue("Target_type")
                if (target_type and (target_type == "player" or target_type == "noise_player")) then
                    local char = v:GetValue("Target")
                    if IsValid(char) then
                        v:LookAt(char:GetLocation())
                    end
                end
            end
        end
    end
end

Timer.SetInterval(function()
    if ROUND_NB > 0 then
        for k, v in pairs(GetMergedEnemiesChars()) do
            UpdateEnemyLookAt(v)
        end
    end
end, Enemy_Look_At_Update_ms)

VZ_EVENT_SUBSCRIBE("Character", "RagdollModeChange", function(enemy, old_state, new_state)
    if enemy:GetValue("Enemy") then
        --print("Enemy RagdollModeChange", old_state, new_state)

        if new_state then
            enemy:SetCollision(CollisionType.StaticOnly)
            --print("Enemy Ragdoll", enemy:GetHealth())

            if enemy:GetHealth() > 0 then
                local target_type = enemy:GetValue("Target_type")
                if (target_type == "barricade" or target_type == "vault") then
                    if enemy:GetValue("AttackB") then
                        Timer.ClearInterval(enemy:GetValue("AttackBInterval"))
                        enemy:SetValue("AttackBInterval", nil, false)
                        enemy:SetValue("AttackB", nil, false)
                        enemy:SetValue("AttackBID", nil, false)
                    end
                    Timer.SetTimeout(function()
                        RespawnEnemy(enemy)
                    end, Enemies_Ragdoll_Get_Up_Timeout_ms)
                elseif target_type == "player" or target_type == "noise_player" or target_type == "noise" then
                    enemy:SetValue("Target", nil, false)
                    enemy:SetValue("StuckNB", nil, false)

                    Timer.SetTimeout(function()
                        if enemy:IsValid() then
                            if enemy:GetHealth() > 0 then
                                enemy:SetRagdollMode(false)
                                --print("enemy:SetRagdollMode(false)", enemy)

                                local zloc = enemy:GetLocation()

                                enemy:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
                                --print("StuckNB Set 0 getup")
                                enemy:SetValue("StuckNB", 0, false)

                                --print("Zombie Get up")

                                EnemyRefreshTarget(enemy)
                            end
                        end
                    end, Enemies_Ragdoll_Get_Up_Timeout_ms)
                end
            end
        else
            enemy:SetCollision(CollisionType.Normal)
        end
    end
end)

Timer.SetInterval(function()
    if not GAME_PAUSED then
        if ROUND_NB > 0 then
            for k, v in pairs(GetMergedEnemiesChars()) do
                if v:IsValid() then
                    if not v:IsInRagdollMode() then
                        if not v:GetValue("PunchCoolDownTimer") then
                            local target_type = v:GetValue("Target_type")
                            if target_type then
                                if target_type == "player" or target_type == "noise_player" then
                                    local char = v:GetValue("Target")
                                    if (IsValid(char) and (not char:GetValue("PlayerDown")) and (not char:GetValue("EnemiesDontTarget"))) then
                                        local zloc = v:GetLocation()
                                        local targetloc = char:GetLocation()
                                        local targetveh = char:GetVehicle()
                                        local dir = char:GetVelocity():GetSafeNormal()
                                        if (zloc:DistanceSquared(targetloc) < GetEnemyTable(v).Damage_At_Distance_sq*((targetveh and targetveh:GetValue("Damage_Radius_sq_Mult")) or 1) or zloc:DistanceSquared(targetloc + dir * (char:GetVelocity():Size() / Enemies_Damage_Prediction_Div)) < GetEnemyTable(v).Damage_At_Distance_sq) then
                                            --print("Zombie StopMovement, distance : " .. tostring(zloc:Distance(targetloc)))
                                            v:StopMovement()
                                            ZMoveCompleted(v, true)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end, Enemies_Check_Can_Damage_Interval_ms)

function GetNearestEnemy(loc)
    local nearest_z
    local nearest_dist_sq
    for k, v in pairs(GetMergedEnemiesChars()) do
        if v:IsValid() then
            if v:GetHealth() > 0 then
                if not v:IsInRagdollMode() then
                    local zloc = v:GetLocation()
                    local dist_sq = loc:DistanceSquared(zloc)
                    if (not nearest_dist_sq or dist_sq < nearest_dist_sq) then
                        nearest_dist_sq = dist_sq
                        nearest_z = v
                    end
                end
            end
        end
    end

    return nearest_z, nearest_dist_sq
end

function ChangeEnemyType(char, new_type)
    if new_type == char:GetValue("EnemyType") then return end
    local enemy_table = GetEnemyTable(char)

    if type(enemy_table.Types[new_type]) ~= "table" then return Console.Error("ChangeEnemyType '" .. tostring(char:GetValue("EnemyName")) .. "' cannot change type to '" .. tostring(new_type) .. "' because it doesn't exist in Enemy Config Types") end

    char:SetSpeedMultiplier(enemy_table.Types[new_type].Speed_Multiplier)
    char:SetGaitMode(enemy_table.Types[new_type].GaitMode)

    char:SetValue("EnemyType", new_type, true)
end

function GetCustomSpawnsUnlocked(spawning_config_data)
    if ((not spawning_config_data) or (not spawning_config_data.table_name)) then
        return Console.Error("Missing table_name in spawning_config_data passed in GetCustomSpawnsUnlocked")
    end

    local unlocked_spawns = {}
    if _ENV[spawning_config_data.table_name] then
        for k, v in pairs(_ENV[spawning_config_data.table_name]) do
            if (ROOMS_UNLOCKED[v[spawning_config_data.room_key]] and not ROOMS_SPAWNS_DISABLED[v[spawning_config_data.room_key]]) then
                table.insert(unlocked_spawns, v)
            end
        end
    end

    --print(NanosTable.Dump(unlocked_spawns))

    return unlocked_spawns
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_SpawnGib", function(char, bone, goingtodie)
    local enemy_table = GetEnemyTable(char)

    if bone == enemy_table.Gibs_heart_bone then
        if not goingtodie then
            if char:GetHealth() > 0 then
                char:SetHealth(0)
                --print("Kill Z Head")
            end
        end
    elseif enemy_table.Types.crawl then
        if not goingtodie then
            if char:GetValue("EnemyType") ~= "crawl" then
                if (bone == "foot_l" or bone == "foot_r" or bone == "calf_l" or bone == "calf_r" or bone == "thigh_l" or bone == "thigh_r") then
                    ChangeEnemyType(char, "crawl")
                end
            end
        end
    end
end)


-- Napalm boss fire damage around the enemy
Timer.SetInterval(function()
    for k, v in pairs(BOSS_CHARACTERS) do
        if v:GetValue("EnemyType") == "napalm" then
            local napalm_loc = v:GetLocation()
            for k2, v2 in pairs(Player.GetPairs()) do
                local char = v2:GetControlledCharacter()
                if char then
                    if not char:GetValue("PlayerDown") then
                        if not char:IsInWater() then
                            local char_loc = char:GetLocation()
                            if napalm_loc:DistanceSquared(char_loc) <= Napalm_Fire_Radius_sq then
                                if not v2:GetValue("MM_GodMode") then
                                    char:ApplyDamage(Napalm_Fire_Damage)
                                    Events.CallRemote("PlayVZSound", v2, Reliability.Unreliable, {random_sound_tbl=RANDOM_SOUNDS.napalm_fire_sound})
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end, Napalm_Fire_Damage_Interval)

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Chat", "PlayerSubmit", function(text, ply)
        if not IsValid(ply) then return end
        local char = ply:GetControlledCharacter()
        if IsValid(char) then
            if text then
                local split_txt = split_str(text, " ")
                if (split_txt and split_txt[1] and split_txt[2]) then
                    if split_txt[1] == "/spawnenemy" then
                        if Enemies_Config[split_txt[2]] then
                            local boss_type
                            if (split_txt[3] and Enemies_Config[split_txt[2]].Types[split_txt[3]]) then
                                boss_type = split_txt[3]
                            else
                                for k, v in pairs(Enemies_Config[split_txt[2]].Types) do
                                    boss_type = k
                                    if v.default then
                                        break
                                    end
                                end
                            end
                            SpawnEnemy(split_txt[2], boss_type)
                        end
                    end
                else
                    Chat.SendMessage(ply, "/spawnenemy <EnemyName> (<EnemyType>)")
                end
            end
        end
    end)
end

