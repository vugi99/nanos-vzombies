


ZOMBIES_SPAWN_INTERVAL = 0

ZOMBIES_CHARACTERS = {}

function GetZombiesCharsCopy()
    local tbl = {}
    for k, v in pairs(ZOMBIES_CHARACTERS) do
        tbl[k] = v
    end
    return tbl
end

function DestroyZombies()
    for k, v in pairs(ZOMBIES_CHARACTERS) do
        if v:GetValue("AttackB") then
            Timer.ClearInterval(v:GetValue("AttackBInterval"))
        end
        if type(v:GetValue("RefreshTargetInterval")) == "number" then
            Timer.ClearInterval(v:GetValue("RefreshTargetInterval"))
        end
        v:Destroy()
    end
    ZOMBIES_CHARACTERS = {}
end

function RandomZombieAttackAnim()
    return Zombies_Attack_Animations[math.random(table_count(Zombies_Attack_Animations))]
end

function Calculate_Zombie_Health()
    local hardcoded_health_count = table_count(Zombies_Health_Start)
    if ROUND_NB <= hardcoded_health_count then
        return Zombies_Health_Start[ROUND_NB]
    else
        local health = Zombies_Health_Start[hardcoded_health_count]
        for i = hardcoded_health_count, ROUND_NB - 1 do
            health = health * Zombies_Health_Multiplier_At_Each_Wave
        end
        return health
    end
end

function SpawnZombie(ZombieType)
    local random_spawn = SPAWNS_UNLOCKED[math.random(table_count(SPAWNS_UNLOCKED))]

    local random_spawn_target = GetSpawnTargetFromZSpawnID(random_spawn.zspawnid)

    local zombie = Character(
        random_spawn.location - Vector(0, 0, 140),
        random_spawn.rotation,
        Zombies_Models[math.random(table_count(Zombies_Models))],
        CollisionType.Normal,
        true,
        Calculate_Zombie_Health(),
        VZ_RandomSound(RANDOM_SOUNDS.zombie_death)
    )
    --zombie:SetGravityEnabled(false)
    zombie:SetFlyingMode(true)

    if ZombieType == "walk" then
        zombie:SetSpeedMultiplier(Slow_Zombies_SpeedMultiplier)
    elseif ZombieType == "run" then
        zombie:SetSpeedMultiplier(Running_Zombies_SpeedMultiplier)
        zombie:SetGaitMode(GaitMode.Sprinting)
    end

    zombie:SetCapsuleSize(Zombies_Collision_Radius, 96)

    zombie:SetValue("Zombie", true, false)
    zombie:SetValue("ZombieType", ZombieType, true)

    zombie:SetValue("GroundAnim", true, false)
    zombie:PlayAnimation("vzombies-assets::FreehangClimb", AnimationSlotType.FullBody, false, 0, 0)

    local players_sound = GetPlayersInRadius(random_spawn.location, RANDOM_SOUNDS.spawn_dirt_sound.falloff_distance)
    for k, v in pairs(players_sound) do
        Events.CallRemote("ZombieGroundDirt", v, VZ_RandomSound(RANDOM_SOUNDS.spawn_dirt_sound), random_spawn.location)
    end

    Timer.SetTimeout(function()
        if zombie:IsValid() then
            if zombie:GetHealth() > 0 then
                ZombieOutGround(zombie, random_spawn, random_spawn_target)
            end
        end
    end, 6100)

    table.insert(ZOMBIES_CHARACTERS, zombie)
end

function ZombieOutGround(zombie, random_spawn, random_spawn_target)
    zombie:SetValue("GroundAnim", nil, false)
    zombie:StopAnimation("vzombies-assets::FreehangClimb")
    zombie:SetLocation(random_spawn.location + Vector(0, 0, 97))
    --zombie:SetGravityEnabled(true)
    zombie:SetFlyingMode(false)

    if random_spawn_target.type == "ground" then
        ZombieSwitchToPlayerTarget(zombie)
    elseif random_spawn_target.type == "barricade" then
        zombie:SetValue("Target_type", "barricade", false)
        local i, b = GetBarricadeFromZSpawnID(random_spawn_target.zspawnid)
        zombie:SetValue("Target", i, false)

        zombie:MoveTo(random_spawn_target.z_move_to_b_target_location, Zombies_Acceptance_Radius)
        zombie:LookAt(random_spawn_target.barricade_location)
    elseif random_spawn_target.type == "vault" then
        zombie:SetValue("Target_type", "vault", false)
        zombie:SetValue("Target", random_spawn_target.zspawnid, false)

        local target_loc = random_spawn_target.z_target_location_1
        if zombie:GetValue("ZombieType") == "walk" then
            target_loc = random_spawn_target.z_target_location_2
        end
        zombie:MoveTo(target_loc, Zombies_Acceptance_Radius)
        zombie:LookAt(target_loc + Vector(0, 0, 180))
    end
end

function SpawnZombieIntervalFunc()
    if (REMAINING_ZOMBIES_TO_SPAWN > 0 and table_count(ZOMBIES_CHARACTERS) < Max_zombies_spawned) then
        REMAINING_ZOMBIES_TO_SPAWN = REMAINING_ZOMBIES_TO_SPAWN - 1

        local index = math.random(table_count(ZOMBIES_TO_SPAWN_TBL))
        local ZombieType = ZOMBIES_TO_SPAWN_TBL[index]
        SpawnZombie(ZombieType)

        table.remove(ZOMBIES_TO_SPAWN_TBL, index)
    end
end

function ZombieRefreshTarget(zombie)
    if zombie:IsValid() then
        if not zombie:GetValue("PunchCoolDownTimer") then
            if not zombie:IsInRagdollMode() then
                local cur_target = zombie:GetValue("Target")
                if cur_target then
                    cur_target = GetCharacterFromId(cur_target)
                end
                local nearest_ply_char
                local nearest_dist_sq
                local zombie_loc = zombie:GetLocation()
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
                    zombie:SetValue(
                        "Target_type",
                        "player",
                        false
                    )
                    zombie:SetValue(
                        "Target",
                        nearest_ply_char:GetID(),
                        false
                    )


                    if nearest_dist_sq < Zombies_Damage_At_Distance_sq then
                        ZombieAttack(zombie)
                    else
                        zombie:Follow(nearest_ply_char, Zombies_Acceptance_Radius, true, true, Zombies_Route_Update_ms / 1000)
                        UpdateZombieLookAt(zombie)
                    end

                    -- OLD tempfollow
                    --Package.Call("tempfollow", "FollowCharacter", zombie, nearest_ply_char, Zombies_Acceptance_Radius, 100)
                elseif (not nearest_ply_char) then
                    --print("StopFollow")
                    zombie:SetValue(
                        "Target",
                        nil,
                        false
                    )

                    zombie:MoveTo(zombie_loc, 100)
                    -- OLD tempfollow
                    --Package.Call("tempfollow", "StopFollowCharacter", zombie)
                end
            end
        end
    end
end

function ZombieSwitchToPlayerTarget(zombie)
    if zombie:IsValid() then
        zombie:SetValue(
            "RefreshTargetInterval",
            Timer.SetInterval(ZombieRefreshTarget, Zombies_Target_Refresh_ms, zombie),
            false
        )
        zombie:SetValue("CanDamageTimeout", Timer.SetTimeout(function()
            if zombie:IsValid() then
                zombie:SetValue("CanDamageTimeout", nil, false)
            end
        end, Zombies_Can_Damage_After_ms), false)
        local zloc = zombie:GetLocation()
        zombie:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
        zombie:SetValue("StuckNB", 0, false)
        ZombieRefreshTarget(zombie)
    end
end

function LeaveBarricade(zombie, barricade)
    if zombie:GetValue("AttackB") then
        Timer.ClearInterval(zombie:GetValue("AttackBInterval"))
        zombie:SetValue("AttackBInterval", nil, false)
        zombie:SetValue("AttackB", nil, false)
        zombie:SetValue("AttackBID", nil, false)
    end
    --print(NanosUtils.Dump(barricade))
    local spawn = GetSpawnTargetFromZSpawnID(barricade.zspawnid)
    zombie:SetLocation(spawn.z_leave_b_tp_location + Vector(0, 0, 100))
    zombie:SetRotation(spawn.z_leave_b_tp_rotation)

    ZombieSwitchToPlayerTarget(zombie)
end

function ZombieAttackSound(zombie)
    local zombie_loc = zombie:GetLocation()
    local play_sound_for_players = GetPlayersInRadius(zombie_loc, RANDOM_SOUNDS.zombie_attack.falloff_distance)
    for i, v in ipairs(play_sound_for_players) do
        Events.CallRemote("ZombieAttackSound", v, VZ_RandomSound(RANDOM_SOUNDS.zombie_attack), zombie_loc)
    end
end

function AttackBarricade(zombie, barricade, start)
    --print("AttackBarricade", start)
    local top_barricades = table_count(barricade.top.barricades)
    if top_barricades > 0 then
        if start then
            zombie:SetValue(
                "AttackBInterval",
                Timer.SetInterval(AttackBarricade, Zombies_Damage_Barricade_Cooldown_ms,
                zombie,
                barricade,
                false),
                false
            )
            zombie:SetValue(
                "AttackB",
                barricade,
                false
            )
            zombie:SetValue(
                "AttackBID",
                barricade.zspawnid,
                false
            )
            zombie:SetValue(
                "Target",
                nil,
                false
            )
            local spawn = GetSpawnTargetFromZSpawnID(barricade.zspawnid)
            --zombie:SetLocation(spawn.z_move_to_b_target_location)
            zombie:SetRotation(spawn.z_leave_b_tp_rotation)
        else
            local random_z_attack_anim = RandomZombieAttackAnim()
            zombie:PlayAnimation(random_z_attack_anim[1], AnimationSlotType.FullBody, false)
            ZombieAttackSound(zombie)
            Timer.SetTimeout(function()
                if zombie:IsValid() then
                    if zombie:GetValue("AttackB") then
                        DamageBarricade(barricade, zombie)
                        local new_top_barricades = table_count(barricade.top.barricades)
                        if new_top_barricades == 0 then
                            zombie:StopAnimation(random_z_attack_anim[1])
                            for k, v in pairs(ZOMBIES_CHARACTERS) do
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
        LeaveBarricade(zombie, barricade)
    end
end

function ReachTarget_PrePlayerTargetFailed(zombie)
    Package.Warn("vzombies : Reach target (blocker) failed, Respawning zombie, the zombie was there : " .. tostring(zombie:GetLocation()))
    Timer.SetTimeout(function()
        SpawnZombie(zombie:GetValue("ZombieType"))
        zombie:SetHealth(0)
    end, 1)
end

function ZombieAttack(zombie)
    local charid = zombie:GetValue("Target")
    if charid then
        local plychar = GetCharacterFromId(charid)
        if plychar then
            local random_z_attack_anim = RandomZombieAttackAnim()
            zombie:PlayAnimation(random_z_attack_anim[1], AnimationSlotType.FullBody, false)
            zombie:SetValue("Target", nil, false)
            zombie:SetValue("StuckNB", nil, false)

            if not ZDEV_IsModeEnabled("ZDEV_GODMODE") then
                Timer.SetTimeout(function()
                    if zombie:IsValid() then
                        if zombie:GetHealth() > 0 then
                            if plychar:IsValid() then
                                if not plychar:GetValue("PlayerDown") then
                                    local plychar_loc = plychar:GetLocation()
                                    local z_loc = zombie:GetLocation()
                                    --print(plychar_loc:DistanceSquared(z_loc))
                                    if plychar_loc:DistanceSquared(z_loc) <= Zombies_Damage_At_Distance_sq then
                                        plychar:ApplyDamage(Zombies_Damage_Amount, "", DamageType.Punch)
                                    end
                                end
                            end
                        end
                    end
                end, random_z_attack_anim[2])

                zombie:SetValue("PunchCoolDownTimer", Timer.SetTimeout(function()
                    if zombie:IsValid() then
                        zombie:SetValue("PunchCoolDownTimer", nil, false)
                        local zloc = zombie:GetLocation()
                        zombie:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
                        zombie:SetValue("StuckNB", 0, false)
                    end
                end, Zombies_Damage_Cooldown_ms), false)
            else
                zombie:SetValue("PunchCoolDownTimer", true, false)
            end

            ZombieAttackSound(zombie)
        end
    end
end

VZ_EVENT_SUBSCRIBE("Character", "MoveCompleted", function(zombie, succeeded)
    if zombie:IsValid() then
        --print("Zombie MoveCompleted", succeeded)
        local target_type = zombie:GetValue("Target_type")
        if target_type == "barricade" then
            if succeeded then
                AttackBarricade(zombie, BARRICADES[zombie:GetValue("Target")], true)
            else
                ReachTarget_PrePlayerTargetFailed(zombie)
            end
        elseif target_type == "vault" then
            if succeeded then
                local spawn_target = GetSpawnTargetFromZSpawnID(zombie:GetValue("Target"))

                local target_rot = spawn_target.z_target_rotation_1
                local target_loc = spawn_target.z_target_location_1
                if zombie:GetValue("ZombieType") == "walk" then
                    target_loc = spawn_target.z_target_location_2
                    target_rot = spawn_target.z_target_rotation_2
                end
                zombie:SetLocation(target_loc + Vector(0, 0, 97))
                zombie:SetRotation(target_rot)

                local anim = Zombies_Vault_Animations[zombie:GetValue("ZombieType")]
                zombie:PlayAnimation(anim[1], AnimationSlotType.FullBody, false, 0.25, 0)

                Timer.SetTimeout(function()
                    if zombie:IsValid() then
                        if zombie:GetHealth() > 0 then
                            zombie:StopAnimation(anim[1])

                            local leave_loc = spawn_target.z_leave_location_1
                            local leave_rot = spawn_target.z_leave_rotation_1
                            if zombie:GetValue("ZombieType") == "walk" then
                                leave_loc = spawn_target.z_leave_location_2
                                leave_rot = spawn_target.z_leave_rotation_2
                            end

                            zombie:SetLocation(leave_loc + Vector(0, 0, 100))
                            zombie:SetRotation(leave_rot)

                            ZombieSwitchToPlayerTarget(zombie)
                        end
                    end
                end, anim[2])
            else
                ReachTarget_PrePlayerTargetFailed(zombie)
            end
        elseif target_type == "player" then
            --print("MoveCompleted", "player", succeeded)
            if (succeeded and not zombie:GetValue("CanDamageTimeout")) then
                ZombieAttack(zombie)
            else
                zombie:SetValue("Target", nil, false)
                zombie:SetValue("StuckNB", nil, false)
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "Death", function(char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer)
    if char:GetValue("Zombie") == true then
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
        for k, v in pairs(ZOMBIES_CHARACTERS) do
            if v == char then
                ZOMBIES_CHARACTERS[k] = nil
            end
        end
        char:SetMaterialScalarParameter("Emissive_value", 0.0)
        SendZombiesRemaining()
        Timer.SetTimeout(function()
            char:Destroy()
        end, DestroyZombie_After_death_ms)
        if (table_count(ZOMBIES_CHARACTERS) == 0 and REMAINING_ZOMBIES_TO_SPAWN == 0) then
            RoundFinished()
        end
    end
end)

function RandomZombieJoker(char)
    local target_type = char:GetValue("Target_type")
    if target_type ~= "barricade" then
        if not char:IsInRagdollMode() then
            local rand1000 = math.random(10000)
            if rand1000 <= Zombies_Joker_Chance then
                char:SetRagdollMode(true)
                Events.BroadcastRemote("JokerZombieSound", char)
            end
        end
    end
end


local DoubleDamage_Applied = false

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, dtype, from_direction, instigator, causer)
    if (char:GetValue("Zombie") == true and damage > 0) then
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
                if ACTIVE_POWERUPS.instakill then
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
                                RandomZombieJoker(char)
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
                            RandomZombieJoker(char)
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
    for k, v in pairs(Character.GetAll()) do
        if v:IsValid() then
            local loc = v:GetLocation()
            if (loc.Z > MAP_Z_LIMITS.max or loc.Z < MAP_Z_LIMITS.min) then
                --print("Character Reached MAP Z LIMITS")
                if v:GetValue("Zombie") then
                    if v:GetHealth() > 0 then
                        SpawnZombie(v:GetValue("ZombieType"))
                        v:SetHealth(0)
                    end
                elseif v:GetPlayer() then
                    PlayerCharacterDie(v)
                end
            end
        end
    end
end, Map_Z_Limits_Check_Interval_ms)

Timer.SetInterval(function()
    for k, v in pairs(GetZombiesCharsCopy()) do
        if v:IsValid() then
            if v:GetValue("Zombie") then
                if v:GetHealth() > 0 then
                    if not v:IsInRagdollMode() then
                        local stuck_nb = v:GetValue("StuckNB")
                        local last_loc = v:GetValue("LastLocation")
                        if (stuck_nb and last_loc) then
                            last_loc = Vector(last_loc[1], last_loc[2], last_loc[3])
                            local loc = v:GetLocation()
                            if last_loc:DistanceSquared(loc) <= Zombies_Stuck_DistanceSq then
                                stuck_nb = stuck_nb + 1
                                v:SetValue("StuckNB", stuck_nb, false)
                                if stuck_nb >= Zombies_Stuck_Respawn_After_x_Stuck then
                                    SpawnZombie(v:GetValue("ZombieType"))
                                    v:SetHealth(0)
                                    --print("Zombie Respawn, stuck")
                                end
                            else
                                v:SetValue("StuckNB", nil, false)
                            end
                            v:SetValue("LastLocation", {loc.X, loc.Y, loc.Z}, false)
                        end
                    end
                end
            end
        end
    end
end, Zombies_Stuck_Check_Each_ms)

function UpdateZombieLookAt(v)
    if v:IsValid() then
        if v:GetValue("Zombie") then
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
    for k, v in pairs(ZOMBIES_CHARACTERS) do
        UpdateZombieLookAt(v)
    end
end, Zombies_Look_At_Update_ms)

VZ_EVENT_SUBSCRIBE("Character", "RagdollModeChanged", function(zombie, old_state, new_state)
    if zombie:GetValue("Zombie") then
        if new_state then
            zombie:SetCollision(CollisionType.StaticOnly)
            --print("Zombie Ragdoll", zombie:GetHealth())
            if zombie:GetHealth() > 0 then
                local target_type = zombie:GetValue("Target_type")
                if target_type == "barricade" then
                    if zombie:GetValue("AttackB") then
                        Timer.ClearInterval(zombie:GetValue("AttackBInterval"))
                        zombie:SetValue("AttackBInterval", nil, false)
                        zombie:SetValue("AttackB", nil, false)
                        zombie:SetValue("AttackBID", nil, false)
                    end
                    Timer.SetTimeout(function()
                        SpawnZombie(zombie:GetValue("ZombieType"))
                        zombie:SetHealth(0)
                    end, Zombies_Ragdoll_Get_Up_Timeout_ms)
                elseif target_type == "player" then
                    zombie:SetValue("Target", nil, false)
                    zombie:SetValue("StuckNB", nil, false)

                    Timer.SetTimeout(function()
                        if zombie:IsValid() then
                            if zombie:GetHealth() > 0 then
                                zombie:SetRagdollMode(false)

                                local zloc = zombie:GetLocation()

                                zombie:SetValue("LastLocation", {zloc.X, zloc.Y, zloc.Z}, false)
                                zombie:SetValue("StuckNB", 0, false)
                            end
                        end
                    end, Zombies_Ragdoll_Get_Up_Timeout_ms)
                end
            end
        else
            zombie:SetCollision(CollisionType.Normal)
        end
    end
end)