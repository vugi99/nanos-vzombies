


ENEMIES_SPAWN_INTERVAL = 0

ENEMY_CHARACTERS = {}
BOSS_CHARACTERS = {}

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
        if v:GetValue("AttackB") then
            Timer.ClearInterval(v:GetValue("AttackBInterval"))
        end
        if type(v:GetValue("RefreshTargetInterval")) == "number" then
            Timer.ClearInterval(v:GetValue("RefreshTargetInterval"))
        end
        v:Destroy()
    end
    ENEMY_CHARACTERS = {}
end

function DestroyBosses()
    for k, v in pairs(BOSS_CHARACTERS) do
        v:Destroy()
    end
    BOSS_CHARACTERS = {}
end

function RandomEnemyAttackAnim(enemy)
    return GetEnemyTable(enemy).Attack_Anims[math.random(table_count(GetEnemyTable(enemy).Attack_Anims))]
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
        local health = Zombies_Health_Start[hardcoded_health_count]
        for i = hardcoded_health_count, ROUND_NB - 1 do
            health = health * Zombies_Health_Multiplier_At_Each_Wave
        end
        return health * return_mult
    end
end

function SpawnEnemy(EnemyName, EnemyType)
    local players_alive = GetPlayersAlive()
    if table_count(players_alive) > 0 then

        local enemy_table = Enemies_Config[EnemyName]

        local selected_spawn
        if enemy_table.Spawning_Config.type == "zombie_spawns" then
            selected_spawn = SmartSpawnLogic(SPAWNS_UNLOCKED)
        elseif enemy_table.Spawning_Config.type == "custom_spawns" then
            selected_spawn = SmartSpawnLogic(GetCustomSpawnsUnlocked(enemy_table))
        end

        if selected_spawn then
            local selected_spawn_target = GetSpawnTargetFromZSpawnID(selected_spawn.zspawnid)

            local is_ground_anim_disabled = false
            if (enemy_table.Spawning_Config.type ~= "zombie_spawns" or (selected_spawn.ground_anim == false or selected_spawn_target.ground_anim == false)) then
                is_ground_anim_disabled = true
            end

            local spawn_location = selected_spawn.location + Vector(0, 0, 100)
            if (not is_ground_anim_disabled) then
                spawn_location = selected_spawn.location - Vector(0, 0, 140)
            end
            local enemy = Character(
                spawn_location,
                selected_spawn.rotation,
                enemy_table.Models[math.random(table_count(enemy_table.Models))],
                CollisionType.Normal,
                true,
                Calculate_Enemy_Health(enemy_table),
                VZ_RandomSound(enemy_table.Death_Sounds),
                ""
            )

            if ZDEV_IsModeEnabled("ZDEV_DEBUG_ZOMBIES_SPAWNS") then
                print("Enemy (" .. enemy:GetID() .. ", " .. EnemyType .. ") spawn, in spawn " .. tostring(selected_spawn.zspawnid) .. " (" .. selected_spawn_target.type .. ")")
            end

            enemy:SetSpeedMultiplier(enemy_table.Types[EnemyType].Speed_Multiplier)
            enemy:SetGaitMode(enemy_table.Types[EnemyType].GaitMode)

            enemy:SetCapsuleSize(enemy_table.Collision_Radius, enemy_table.Collision_Height or 96)

            enemy:SetValue("Enemy", true, false)
            enemy:SetValue("EnemyName", EnemyName, true)
            enemy:SetValue("EnemyType", EnemyType, true)
            enemy:SetValue("EnemyTypeAtSpawn", EnemyType, false)

            if enemy_table.Spawning_Config.type == "zombie_spawns" then
                if (not is_ground_anim_disabled) then
                    enemy:SetFlyingMode(true)
                    enemy:SetValue("GroundAnim", true, false)
                    enemy:PlayAnimation("vzombies-assets::FreehangClimb", AnimationSlotType.FullBody, false, 0, 0)

                    local players_sound = GetPlayersInRadius(selected_spawn.location, RANDOM_SOUNDS.spawn_dirt_sound.falloff_distance)
                    for k, v in pairs(players_sound) do
                        Events.CallRemote("ZombieGroundDirt", v, VZ_RandomSound(RANDOM_SOUNDS.spawn_dirt_sound), selected_spawn.location)
                    end

                    Timer.SetTimeout(function()
                        if enemy:IsValid() then
                            if enemy:GetHealth() > 0 then
                                EnemyOutGround(enemy, selected_spawn, selected_spawn_target, true)
                            end
                        end
                    end, 6100)
                else
                    EnemyOutGround(enemy, selected_spawn, selected_spawn_target, false)
                end
            else
                EnemySwitchToPlayerTarget(enemy)
            end

            if not enemy_table.Boss then
                table.insert(ENEMY_CHARACTERS, enemy)
            else
                table.insert(BOSS_CHARACTERS, enemy)
            end

            if enemy:IsValid() then
                Events.Call("VZ_EnemySpawned", enemy)
            end
        else
            Package.Error("VZombies : Can't select a zombie spawn")
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
        enemy:StopAnimation("vzombies-assets::FreehangClimb")
        enemy:SetLocation(selected_spawn.location + Vector(0, 0, 97))
        --zombie:SetGravityEnabled(true)
        enemy:SetFlyingMode(false)
    end

    if selected_spawn_target.type == "ground" then
        EnemySwitchToPlayerTarget(enemy)
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

function SmartSpawnLogic(spawns_table)
    if table_count(spawns_table) == 0 then
        return
    end

    local players_alive = GetPlayersAlive()

    local random_player = players_alive[math.random(table_count(players_alive))]
    local loc = random_player:GetControlledCharacter():GetLocation()

    local Percentages_Count = table_count(Zombies_Nearest_SmartSpawns_Percentage)

    local nearest_spawns = {}
    for k, v in pairs(spawns_table) do
        local dist_sq = loc:DistanceSquared(v.location)
        if table_count(nearest_spawns) < Percentages_Count then
            table.insert(nearest_spawns, {v, dist_sq})
        elseif nearest_spawns[Percentages_Count][2] > dist_sq then
            for i2, v2 in ipairs(nearest_spawns) do
                if v2[2] > dist_sq then
                    nearest_spawns[i2] = {v, dist_sq}
                    break
                end
            end
        end
    end

    local selected_spawn

    local random_percentage_to = 100
    if table_count(nearest_spawns) < Percentages_Count then
        random_percentage_to = 0
        for i = 1, table_count(nearest_spawns) do
            random_percentage_to = random_percentage_to + Zombies_Nearest_SmartSpawns_Percentage[i]
        end
    end

    local random_percentage = math.random(random_percentage_to)
    local cur_percentage = 0
    for i, v in ipairs(Zombies_Nearest_SmartSpawns_Percentage) do
        cur_percentage = cur_percentage + v
        if cur_percentage >= random_percentage then
            --print("Selected spawn " .. tostring(i))
            selected_spawn = nearest_spawns[i][1]
            break
        end
    end

    return selected_spawn
end

function ZombieSpawnSelection()
    return selected_spawn
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
                                    if v.Spawning_Config.minimum_round_to_spawn <= ROUND_NB then
                                        local chance_to_spawn = v.Spawning_Config.spawn_chance_per_zombie
                                        if math.random(1000) <= chance_to_spawn then
                                            local boss_type
                                            for k2, v2 in pairs(v.Types) do
                                                boss_type = k2
                                                break
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
                error("VZombies : Missing enemies in the TO_SPAWN Table")
            end
        end
    end
end

function EnemyRefreshTarget(enemy)
    if enemy:IsValid() then
        if not GAME_PAUSED then
            if not enemy:GetValue("PunchCoolDownTimer") then
                if not enemy:IsInRagdollMode() then
                    local cur_target = enemy:GetValue("Target")
                    if cur_target then
                        cur_target = GetCharacterFromId(cur_target)
                    end
                    local nearest_ply_char
                    local nearest_dist_sq
                    local zombie_loc = enemy:GetLocation()
                    for k, v in pairs(Character.GetPairs()) do
                        local ply = v:GetPlayer()
                        if ply then
                            if not v:GetValue("PlayerDown") then
                                local dist_sq = zombie_loc:DistanceSquared(v:GetLocation())
                                if (not nearest_ply_char or (nearest_dist_sq > dist_sq)) then
                                    nearest_ply_char = v
                                    nearest_dist_sq = dist_sq
                                end
                            end
                        end
                    end
                    if (nearest_ply_char and (not cur_target or cur_target ~= nearest_ply_char)) then
                        enemy:SetValue(
                            "Target_type",
                            "player",
                            false
                        )
                        enemy:SetValue(
                            "Target",
                            nearest_ply_char:GetID(),
                            false
                        )


                        if nearest_dist_sq < GetEnemyTable(enemy).Damage_At_Distance_sq then
                            EnemyAttack(enemy)
                        else
                            enemy:Follow(nearest_ply_char, GetEnemyTable(enemy).Acceptance_Radius, true, true, Enemy_Route_Update_ms / 1000)
                            UpdateEnemyLookAt(enemy)
                        end

                    elseif (not nearest_ply_char) then
                        --print("StopFollow")
                        enemy:SetValue(
                            "Target",
                            nil,
                            false
                        )

                        enemy:MoveTo(zombie_loc, 100)
                    end
                end
            end
        end
    end
end

function EnemySwitchToPlayerTarget(enemy)
    if enemy:IsValid() then
        enemy:SetValue(
            "RefreshTargetInterval",
            Timer.SetInterval(EnemyRefreshTarget, Enemies_Target_Refresh_ms, enemy),
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
        EnemyRefreshTarget(enemy)
    end
end

function LeaveBarricade(enemy, barricade)
    if enemy:GetValue("AttackB") then
        Timer.ClearInterval(enemy:GetValue("AttackBInterval"))
        enemy:SetValue("AttackBInterval", nil, false)
        enemy:SetValue("AttackB", nil, false)
        enemy:SetValue("AttackBID", nil, false)
    end
    --print(NanosUtils.Dump(barricade))
    local spawn = GetSpawnTargetFromZSpawnID(barricade.zspawnid)
    enemy:SetLocation(spawn.z_leave_b_tp_location + Vector(0, 0, 100))
    enemy:SetRotation(spawn.z_leave_b_tp_rotation)

    EnemySwitchToPlayerTarget(enemy)
end

function EnemyAttackSound(enemy)
    local enemy_table = GetEnemyTable(enemy)
    local zombie_loc = enemy:GetLocation()
    local play_sound_for_players = GetPlayersInRadius(zombie_loc, enemy_table.Attack_Sounds.falloff_distance)
    for i, v in ipairs(play_sound_for_players) do
        Events.CallRemote("PlayVZSound", v, {random_sound_tbl=enemy_table.Attack_Sounds, random_sound_selected=VZ_RandomSound(enemy_table.Attack_Sounds)}, zombie_loc)
    end
end

function AttackBarricade(enemy, barricade, start)
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
            local random_z_attack_anim = RandomEnemyAttackAnim(enemy)
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
    Package.Warn("vzombies : Reach target (blocker) failed, Respawning zombie, the zombie was there : " .. tostring(enemy:GetLocation()))
    Timer.SetTimeout(function()
        SpawnEnemy(enemy:GetValue("EnemyName"), enemy:GetValue("EnemyTypeAtSpawn"))
        enemy:SetHealth(0)
    end, 1)
end

function EnemyAttack(enemy)
    local charid = enemy:GetValue("Target")
    if charid then
        local plychar = GetCharacterFromId(charid)
        if plychar then
            local random_z_attack_anim = RandomEnemyAttackAnim(enemy)
            enemy:PlayAnimation(random_z_attack_anim[1], AnimationSlotType.FullBody, false)
            enemy:SetValue("Target", nil, false)
            enemy:SetValue("StuckNB", nil, false)

            if not ZDEV_IsModeEnabled("ZDEV_GODMODE") then
                Timer.SetTimeout(function()
                    if enemy:IsValid() then
                        if enemy:GetHealth() > 0 then
                            if plychar:IsValid() then
                                if not plychar:GetValue("PlayerDown") then
                                    local plychar_loc = plychar:GetLocation()
                                    local z_loc = enemy:GetLocation()
                                    --print(plychar_loc:DistanceSquared(z_loc))
                                    if plychar_loc:DistanceSquared(z_loc) <= GetEnemyTable(enemy).Damage_At_Distance_sq then
                                        plychar:ApplyDamage(GetEnemyTable(enemy).Damage_Amount, "", DamageType.Punch)
                                    end
                                end
                            end
                        end
                    end
                end, random_z_attack_anim[2])

                enemy:SetValue("PunchCoolDownTimer", Timer.SetTimeout(function()
                    if enemy:IsValid() then
                        enemy:SetValue("PunchCoolDownTimer", nil, false)
                        local zloc = enemy:GetLocation()
                        enemy:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
                        --print("StuckNB Set 0 PunchCoolDownTimer finished")
                        enemy:SetValue("StuckNB", 0, false)
                        EnemyRefreshTarget(enemy)
                    end
                end, GetEnemyTable(enemy).Damage_Cooldown_ms), false)
            else
                enemy:SetValue("PunchCoolDownTimer", true, false)
            end

            EnemyAttackSound(enemy)
        end
    end
end

function ZMoveCompleted(enemy, succeeded)
    if enemy:IsValid() then
        --print("Enemy MoveCompleted", succeeded)
        local target_type = enemy:GetValue("Target_type")
        if target_type == "barricade" then
            if succeeded then
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

                            EnemySwitchToPlayerTarget(enemy)
                        end
                    end
                end, anim.timeout_ms)
            else
                ReachTarget_PrePlayerTargetFailed(enemy)
            end
        elseif target_type == "player" then
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
VZ_EVENT_SUBSCRIBE("Character", "MoveCompleted", ZMoveCompleted)

VZ_EVENT_SUBSCRIBE("Character", "Death", function(char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer)
    if char:GetValue("Enemy") == true then
        if causer then
            if causer:IsValid() then
                if not NanosUtils.IsA(causer, Character) then
                    local instig_char = causer:GetHandler()
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
        if type(char:GetValue("RefreshTargetInterval")) == "number" then
            Timer.ClearInterval(char:GetValue("RefreshTargetInterval"))
        end
        -- No instigator when zombies killed by nuke so it doesn't spawn new powerups or give player money, same in instakill (money given at damage for instakill)
        if instigator then
            local zkills = instigator:GetValue("ZKills")
            if zkills then
                local instig_char = instigator:GetControlledCharacter()
                if instig_char  then
                    local picked_thing = instig_char:GetPicked()
                    if (picked_thing and picked_thing:IsValid() and NanosUtils.IsA(picked_thing, Melee)) then
                        AddMoney(instigator, Player_Zombie_Kill_Knife_Money)
                    else
                        AddMoney(instigator, Player_Zombie_Kill_Money)
                    end
                    instigator:SetValue("ZKills", zkills + 1, false)
                    ZombieDie_SpawnRandomPowerup(char)
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
        char:SetMaterialScalarParameter("Emissive_value", 0.0)

        SendEnemiesRemaining()

        if char:GetValue("EnemyType") == "napalm" then
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

        Timer.SetTimeout(function()
            char:Destroy()
        end, DestroyEnemy_After_death_ms)
        if (table_count(ENEMY_CHARACTERS) == 0 and REMAINING_ENEMIES_TO_SPAWN == 0 and not WaitingNewRound_Timer) then
            if In_Hellhound_Round then
                SpawnPowerup(char:GetLocation(), "max_ammo")
            end

            RoundFinished()
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
                    char:SetRagdollMode(true)
                    Events.BroadcastRemote("JokerZombieSound", char)
                end
            end
        end
    end
end


local DoubleDamage_Applied = false

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, dtype, from_direction, instigator, causer)
    if (char:GetValue("Enemy") == true and damage > 0) then
        if causer then
            if causer:IsValid() then
                if not NanosUtils.IsA(causer, Character) then
                    local instig_char = causer:GetHandler()
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
                    Events.Call("VZ_ZombieKill_InstaKill", char, damage, bone, dtype, from_direction, instigator_passed, causer)

                    local zkills = instigator:GetValue("ZKills")
                    if zkills then
                        AddMoney(instigator, Player_Zombie_Kill_Money)
                        ZombieDie_SpawnRandomPowerup(char)
                        instigator:SetValue("ZKills", zkills + 1, false)
                        char:SetHealth(0)
                    end
                elseif instig_char then
                    if (not causer or not causer:IsValid() or not NanosUtils.IsA(causer, Melee)) then
                        local perks = instig_char:GetValue("OwnedPerks")
                        local mult = 1
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
                                            end
                                        end
                                        break
                                    end
                                end
                            end
                        end
                        if mult > 1 then
                            DoubleDamage_Applied = true
                            --print("DOUBLE APPLY", mult)
                            if char:GetHealth() - damage - damage * mult > 0 then
                                RandomEnemyJoker(char)
                            end
                            if not instigator.BOT then
                                --print(causer)
                                if causer then
                                    char:ApplyDamage(damage * mult, bone, dtype, from_direction, instigator, causer)
                                else
                                    char:ApplyDamage(damage * mult, bone, dtype, from_direction, instigator)
                                end
                            else
                                char:ApplyDamage(damage * mult, bone, dtype, from_direction, nil, causer)
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
                            SpawnEnemy(v:GetValue("EnemyName"), v:GetValue("EnemyTypeAtSpawn"))
                            v:SetHealth(0)
                        end
                    elseif v:GetPlayer() then
                        PlayerCharacterDie(v)
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
                                            SpawnEnemy(v:GetValue("EnemyName"), v:GetValue("EnemyTypeAtSpawn"))
                                            v:SetHealth(0)
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
                if (target_type and target_type == "player") then
                    local target_charid = v:GetValue("Target")
                    if target_charid then
                        local char = GetCharacterFromId(target_charid)
                        if char then
                            v:LookAt(char:GetLocation())
                        end
                    end
                end
            end
        end
    end
end

Timer.SetInterval(function()
    for k, v in pairs(GetMergedEnemiesChars()) do
        UpdateEnemyLookAt(v)
    end
end, Enemy_Look_At_Update_ms)

VZ_EVENT_SUBSCRIBE("Character", "RagdollModeChanged", function(enemy, old_state, new_state)
    if enemy:GetValue("Enemy") then
        if new_state then
            enemy:SetCollision(CollisionType.StaticOnly)
            --print("Zombie Ragdoll", zombie:GetHealth())
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
                        SpawnEnemy(enemy:GetValue("EnemyName"), enemy:GetValue("EnemyTypeAtSpawn"))
                        enemy:SetHealth(0)
                    end, Enemies_Ragdoll_Get_Up_Timeout_ms)
                elseif target_type == "player" then
                    enemy:SetValue("Target", nil, false)
                    enemy:SetValue("StuckNB", nil, false)

                    Timer.SetTimeout(function()
                        if enemy:IsValid() then
                            if enemy:GetHealth() > 0 then
                                enemy:SetRagdollMode(false)

                                local zloc = enemy:GetLocation()

                                enemy:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
                                --print("StuckNB Set 0 getup")
                                enemy:SetValue("StuckNB", 0, false)

                                --print("Zombie Get up")
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
        for k, v in pairs(GetMergedEnemiesChars()) do
            if v:IsValid() then
                if not v:IsInRagdollMode() then
                    if not v:GetValue("PunchCoolDownTimer") then
                        local target_type = v:GetValue("Target_type")
                        if target_type then
                            if target_type == "player" then
                                local charid = v:GetValue("Target")
                                if charid then
                                    local char = GetCharacterFromId(charid)
                                    if (char and not char:GetValue("PlayerDown")) then
                                        local zloc = v:GetLocation()
                                        local targetloc = char:GetLocation()
                                        local dir = char:GetVelocity():GetSafeNormal()
                                        if (zloc:DistanceSquared(targetloc) < GetEnemyTable(v).Damage_At_Distance_sq or zloc:DistanceSquared(targetloc + dir * (char:GetVelocity():Size() / Enemies_Damage_Prediction_Div)) < GetEnemyTable(v).Damage_At_Distance_sq) then
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
    local enemy_table = GetEnemyTable(char)

    char:SetSpeedMultiplier(enemy_table.Types[new_type].Speed_Multiplier)
    char:SetGaitMode(enemy_table.Types[new_type].GaitMode)

    char:SetValue("EnemyType", new_type, true)
end

function GetCustomSpawnsUnlocked(enemy_table)
    local unlocked_spawns = {}
    if _ENV[enemy_table.Spawning_Config.table_name] then
        for k, v in pairs(_ENV[enemy_table.Spawning_Config.table_name]) do
            if ROOMS_UNLOCKED[v[enemy_table.Spawning_Config.room_key]] then
                table.insert(unlocked_spawns, v)
            end
        end
    end

    --print(NanosUtils.Dump(unlocked_spawns))

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
    elseif char:GetValue("EnemyName") == "Zombie" then
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
                        if not char:IsInWater() then -- Copilot idea
                            local char_loc = char:GetLocation()
                            if napalm_loc:DistanceSquared(char_loc) <= Napalm_Fire_Radius_sq then
                                if not ZDEV_IsModeEnabled("ZDEV_GODMODE") then
                                    char:ApplyDamage(Napalm_Fire_Damage)
                                    Events.CallRemote("PlayVZSound", v2, {random_sound_tbl=RANDOM_SOUNDS.napalm_fire_sound})
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
    VZ_EVENT_SUBSCRIBE("Server", "Chat", function(text, ply)
        local char = ply:GetControlledCharacter()
        if char then
            if text then
                local split_txt = split_str(text, " ")
                if (split_txt and split_txt[1] and split_txt[2]) then
                    if split_txt[1] == "/spawnboss" then
                        if Enemies_Config[split_txt[2]] then
                            local boss_type
                            for k, v in pairs(Enemies_Config[split_txt[2]].Types) do
                                boss_type = k
                                break
                            end
                            SpawnEnemy(split_txt[2], boss_type)
                        end
                    end
                end
            end
        end
    end)
end

