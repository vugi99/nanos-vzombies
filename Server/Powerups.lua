
POWERUPS_PICKUPS = {}
POWERUPS_IDS = 0

ACTIVE_POWERUPS = {}

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

function DestroyPowerups()
    for k, v in pairs(POWERUPS_PICKUPS) do
        v.SM_Powerup:Destroy()
        v.PS_Powerup:Destroy()
        Timer.ClearTimeout(v.DestroyTimeout)
    end
    POWERUPS_PICKUPS = {}
    POWERUPS_IDS = 0
    for k, v in pairs(ACTIVE_POWERUPS) do
        Timer.ClearTimeout(v.timeout)
    end
    ACTIVE_POWERUPS = {}
    Events.BroadcastRemote("RemoveGUIPowerups")
end

function PowerupGrabbed(powerup_name, by_char, at_loc)
    local ply = by_char:GetPlayer()
    Events.CallRemote("PowerupGrabSound", ply)
    if powerup_name == "carpenter" then
        for k, v in pairs(BARRICADES) do
            for i = 1, 5 do
                RepairBarricade(v)
            end
        end
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
                                Package.Error("PowerupGrabbed:max_ammo, GetWeaponNameMaxAmmo doesn't work for weapon : " .. tostring(v.weapon_name))
                            end
                        end
                    end
                    char:SetValue("ZGrenadesNB", Max_Grenades_NB, true)
                end
            end
        end
    elseif powerup_name == "nuke" then
        for k, v in pairs(Character.GetPairs()) do
            if v:GetValue("Zombie") then
                if v:GetHealth() > 0 then
                    v:SetHealth(0)
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
    end
    Events.BroadcastRemote("PowerupGrabbed", powerup_name)
end

Timer.SetInterval(function()
    for k, v in pairs(GetPowerupsOnMapCopy()) do
        local powerup_loc = v.SM_Powerup:GetLocation()
        for k2, v2 in pairs(Character.GetPairs()) do
            local ply = v2:GetPlayer()
            if ply then
                local char_loc = v2:GetLocation()
                if powerup_loc:DistanceSquared(char_loc) <= Powerup_Grab_Distance_Squared then
                    if v.SM_Powerup:IsValid() then
                        v.SM_Powerup:Destroy()
                        v.PS_Powerup:Destroy()
                        Timer.ClearTimeout(v.DestroyTimeout)
                        PowerupGrabbed(v.powerup_name, v2, powerup_loc)
                    end
                    POWERUPS_PICKUPS[k] = nil
                end
            end
        end
    end
end, Powerup_Check_Grab_Interval_ms)

function ZombieDie_SpawnRandomPowerup(zombie)
    local random_perc = math.random(100)
    if random_perc <= Powerup_Spawn_Percentage then
        local loc = zombie:GetLocation()
        local random_powerup_name = Powerups_Names[math.random(table_count(Powerups_Names))]
        local random_powerup_config = Powerups_Config[random_powerup_name]
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
            powerup_name = random_powerup_name,
            DestroyTimeout = Timer.SetTimeout(function()
                for k, v in pairs(POWERUPS_PICKUPS) do
                    if v.SM_Powerup == SM_Powerup then
                        POWERUPS_PICKUPS[k] = nil
                    end
                end
                SM_Powerup:Destroy()
                PS_Powerup:Destroy()
            end, Powerup_Delete_after_ms)
        })
    end
end