
POWERUPS_PICKUPS = {}
POWERUPS_IDS = 0

ACTIVE_POWERUPS = {}

Carpenter_Interval_ID = nil
Carpenter_Repair_Index = nil

function GetWeaponNameMaxAmmo(weapon_name)
    if Player_Start_Weapon.weapon_name == weapon_name then
        return Player_Start_Weapon.ammo
    end
    for i, v in ipairs(MAP_WEAPONS) do
        if v.weapon_name == weapon_name then
            return v.max_ammo
        end
    end
    for i, v in ipairs(Mystery_box_weapons) do
        if v.weapon_name == weapon_name then
            return v.max_ammo
        end
    end
    return 10666
end

function GetPowerupsOnMapCopy()
    local tbl = {}
    for k, v in pairs(POWERUPS_PICKUPS) do
        tbl[k] = {}
        for k2, v2 in pairs(v) do
            tbl[k][k2] = v2
        end
    end
    return tbl
end

function DestroyPowerup(v)
    v.SM_Powerup:Destroy()
    v.PS_Powerup:Destroy()
    Timer.ClearTimeout(v.DestroyTimeout)
end

function DestroyPowerups()
    for k, v in pairs(POWERUPS_PICKUPS) do
        DestroyPowerup(v)
    end
    POWERUPS_PICKUPS = {}
    POWERUPS_IDS = 0
    for k, v in pairs(ACTIVE_POWERUPS) do
        Timer.ClearTimeout(v.timeout)
    end
    ACTIVE_POWERUPS = {}
    Events.BroadcastRemote("RemoveGUIPowerups")
end

function Carpenter_Repair_Func()
    --print("Repair Carpenter Call")
    for k, v in pairs(BARRICADES) do
        RepairBarricade(v)
    end
    Carpenter_Repair_Index = Carpenter_Repair_Index + 1
    if Carpenter_Repair_Index >= 6 then
        Timer.ClearInterval(Carpenter_Interval_ID)
        Carpenter_Interval_ID = nil
        Carpenter_Repair_Index = nil
    end
end

function PowerupGrabbed(powerup_name, by_char)
    if Powerups_Config[powerup_name] then
        local ply = by_char:GetPlayer()
        Events.CallRemote("PlayVZSound", ply, {basic_sound_tbl=Powerup_Grab_Sound})
        if powerup_name == "carpenter" then
            if Carpenter_Interval_ID then
                Timer.ClearInterval(Carpenter_Interval_ID)
            end

            Carpenter_Repair_Index = 1
            Carpenter_Interval_ID = Timer.SetInterval(Carpenter_Repair_Func, Powerups_Config.carpenter.repair_interval_ms)

            for k, v in pairs(Character.GetPairs()) do
                local vply = v:GetPlayer()
                if vply then
                    AddMoney(vply, Powerups_Config.carpenter.money_won)
                end
            end
        elseif powerup_name == "max_ammo" then
            for k, char in pairs(Character.GetPairs()) do
                if char:GetPlayer() then
                    if not char:GetValue("PlayerDown") then
                        local charInvID = GetCharacterInventory(char)
                        if charInvID then
                            for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                                local max_ammo = GetWeaponNameMaxAmmo(v.weapon_name)
                                if max_ammo then
                                    v.ammo_bag = max_ammo
                                    if v.weapon then
                                        v.weapon:SetAmmoBag(max_ammo)
                                        Events.CallRemote("UpdateAmmoText", char:GetPlayer())
                                    end
                                else
                                    Console.Error("PowerupGrabbed:max_ammo, GetWeaponNameMaxAmmo doesn't work for weapon : " .. tostring(v.weapon_name))
                                end
                            end
                        end
                        char:SetValue("ZGrenadesNB", Max_Grenades_NB, true)
                    end
                end
            end
        elseif powerup_name == "nuke" then
            for k, v in pairs(Character.GetAll()) do
                if v:IsValid() then -- Ragdolls being removed can destroy some zombies in the list
                    if v:GetValue("Enemy") then
                        local enemy_table = Enemies_Config[v:GetValue("EnemyName")]
                        if not enemy_table.Boss then
                            if v:GetHealth() > 0 then
                                v:SetHealth(0)
                            end
                        end
                    end
                end
            end
            for k, v in pairs(Character.GetPairs()) do
                local vply = v:GetPlayer()
                if vply then
                    AddMoney(vply, Powerups_Config.nuke.money_won)
                end
            end
        elseif powerup_name == "instakill" then
            local remove_Active_Timeout = Timer.SetTimeout(function()
                ACTIVE_POWERUPS.instakill = nil
                Events.BroadcastRemote("DurationPowerupRemoved", "instakill")
            end, Powerups_Config.instakill.duration)
            if ACTIVE_POWERUPS.instakill then
                Timer.ClearTimeout(ACTIVE_POWERUPS.instakill.timeout)
                ACTIVE_POWERUPS.instakill.timeout = remove_Active_Timeout
            else
                ACTIVE_POWERUPS.instakill = {
                    timeout = remove_Active_Timeout
                }
            end
        elseif powerup_name == "x2" then
            local remove_Active_Timeout = Timer.SetTimeout(function()
                ACTIVE_POWERUPS.x2 = nil
                Events.BroadcastRemote("DurationPowerupRemoved", "x2")
            end, Powerups_Config.x2.duration)
            if ACTIVE_POWERUPS.x2 then
                Timer.ClearTimeout(ACTIVE_POWERUPS.x2.timeout)
                ACTIVE_POWERUPS.x2.timeout = remove_Active_Timeout
            else
                ACTIVE_POWERUPS.x2 = {
                    timeout = remove_Active_Timeout
                }
            end
        elseif powerup_name == "death_machine" then
            local remove_active_timeout_char = by_char:GetValue("DeathMachineTimer")
            if remove_active_timeout_char then
                Timer.ClearTimeout(remove_active_timeout_char)

                local held_weapon = by_char:GetPicked()
                if held_weapon then
                    held_weapon:Destroy()
                end
            end

            local charInvID = GetCharacterInventory(by_char)
            if charInvID then
                local Inv = PlayersCharactersWeapons[charInvID]

                for i, v in ipairs(Inv.weapons) do
                    if (v.slot == Inv.selected_slot and v.weapon) then
                        if v.weapon:IsValid() then
                            v.ammo_bag = v.weapon:GetAmmoBag()
                            v.ammo_clip = v.weapon:GetAmmoClip()

                            v.destroying = true
                            v.weapon:Destroy()
                            v.destroying = nil
                        end
                        v.weapon = nil
                        break
                    end
                end
            end

            local death_machine_weapon = NanosWorldWeapons[Powerups_Config.death_machine.minigun_weapon_name]()
            death_machine_weapon:SetAmmoSettings(Powerups_Config.death_machine.minigun_clip, Powerups_Config.death_machine.minigun_clip)

            by_char:PickUp(death_machine_weapon)

            death_machine_weapon:Subscribe("Drop", function(weap, char, was_triggered_by_player)
                weap:Destroy()
            end)

            remove_active_timeout_char = Timer.SetTimeout(function()
                if by_char:IsValid() then
                    by_char:SetValue("DeathMachineTimer", nil, true)

                    local charInvID = GetCharacterInventory(by_char)
                    if charInvID then
                        local Inv = PlayersCharactersWeapons[charInvID]

                        EquipSlot(by_char, Inv.selected_slot)
                    end
                end
            end, Powerups_Config.death_machine.duration)
            by_char:SetValue("DeathMachineTimer", remove_active_timeout_char, true)

            by_char:SetValue("BOTReloading", nil, false)
        end

        if powerup_name == "death_machine" then
            return
        end
        Events.BroadcastRemote("PowerupGrabbed", powerup_name)
    end
end

Timer.SetInterval(function()
    if ROUND_NB > 0 then
        for k, v in pairs(GetPowerupsOnMapCopy()) do
            local powerup_loc = v.SM_Powerup:GetLocation()
            for k2, v2 in pairs(Character.GetPairs()) do
                local ply = v2:GetPlayer()
                if ply then
                    local char_loc = v2:GetLocation()
                    if powerup_loc:DistanceSquared(char_loc) <= Powerup_Grab_Distance_Squared then
                        if v.SM_Powerup:IsValid() then
                            Events.Call("VZ_PowerupGrabbed", v2, v.SM_Powerup:GetValue("GrabPowerup"), v.powerup_name)
                            DestroyPowerup(v)
                            PowerupGrabbed(v.powerup_name, v2)
                        end
                        POWERUPS_PICKUPS[k] = nil
                    end
                end
            end
        end
    end
end, Powerup_Check_Grab_Interval_ms)

function SpawnPowerup(loc, powerup_name)
    local random_powerup_config = Powerups_Config[powerup_name]
    local SM_Powerup = StaticMesh(
        loc,
        Rotator(0, 0, 0),
        random_powerup_config.SM_Path
    )
    SM_Powerup:SetScale(Vector(0.01, 0.01, 0.01))
    SM_Powerup:SetCollision(CollisionType.NoCollision)
    POWERUPS_IDS = POWERUPS_IDS + 1
    SM_Powerup:SetValue("GrabPowerup", POWERUPS_IDS, true)
    local PS_Powerup = Particle(
        loc,
        Rotator(0, 0, 0),
        Powerups_particle_path,
        false,
        true
    )
    table.insert(POWERUPS_PICKUPS, {
        SM_Powerup = SM_Powerup,
        PS_Powerup = PS_Powerup,
        powerup_name = powerup_name,
        DestroyTimeout = Timer.SetTimeout(function()
            for k, v in pairs(POWERUPS_PICKUPS) do
                if v.SM_Powerup == SM_Powerup then
                    POWERUPS_PICKUPS[k] = nil
                end
            end
            if SM_Powerup:IsValid() then
                SM_Powerup:Destroy()
            end
            if PS_Powerup:IsValid() then
                PS_Powerup:Destroy()
            end
        end, Powerup_Delete_after_ms)
    })
end

function ZombieDie_SpawnRandomPowerup(zombie)
    if not In_Hellhound_Round then
        local random_perc = math.random(100)
        if random_perc <= Powerup_Spawn_Percentage then
            local loc = zombie:GetLocation()
            if zombie:GetValue("GroundAnim") then
                loc = loc + Vector(0, 0, 237)
            end

            local random_powerup_name = Powerups_Names[math.random(table_count(Powerups_Names))]
            SpawnPowerup(loc, random_powerup_name)
        end
    end
end

function GetPowerupPickupFromPowerupID(P_ID)
    for k, v in pairs(POWERUPS_PICKUPS) do
        if v.SM_Powerup:GetValue("GrabPowerup") == P_ID then
            return k, v
        end
    end
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_EquippedInventorySlot", function(char, slot)
    local remove_timer = char:GetValue("DeathMachineTimer")
    if remove_timer then
        Timer.ClearTimeout(remove_timer)
        char:SetValue("DeathMachineTimer", nil, true)
    end
end)

if ZDEV_IsModeEnabled("ZDEV_COMMANDS") then
    VZ_EVENT_SUBSCRIBE("Chat", "PlayerSubmit", function(text, ply)
        local char = ply:GetControlledCharacter()
        if char then
            if text then
                local split_txt = split_str(text, " ")
                if (split_txt and split_txt[1] and split_txt[2]) then
                    if split_txt[1] == "/spawnpwrup" then
                        if Powerups_Config[split_txt[2]] then
                            SpawnPowerup(char:GetLocation() + Vector(500, 0, 0), split_txt[2])
                        end
                    end
                end
            end
        end
    end)
end