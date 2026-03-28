

VZ_PPG_IMPOSTER = nil


RegisterPreparedLoop("Pumpkins_Ground", Prop, "PPG_pumpprop_on_ground")

local function PPG_AlterVZConfig()
    Bots_Enabled = false
    Players_Respawn_Between_Rounds = false

    Player_Zombie_Damage_Money = 0
    Player_Zombie_Kill_Money = 0
    Player_Zombie_Kill_Knife_Money = 0

    WaveInterval_ms = VZ_GetGamemodeConfigValue("Discuss_Time_ms") + VZ_GetGamemodeConfigValue("Voting_Time_ms") + VZ_GetGamemodeConfigValue("Results_Time_ms")

    NanosWorldWeapons[VZ_GetGamemodeConfigValue("Imposter_Weapon_Name")] = VZ_GetGamemodeConfigValue("Imposter_Weapon")
end
PPG_AlterVZConfig()


local function RandomHeadAttached_SM(EnemyName)
    local SMs = VZ_GetGamemodeConfigValue("Random_Head_Attached_SMs")
    local sel = SMs[math.random(#SMs)]

    --print(EnemyName, NanosTable.Dump(sel))

    if sel.Per_Enemy_Config[EnemyName] then
        local sel_enemy_conf = sel.Per_Enemy_Config[EnemyName]
        return sel.model, sel_enemy_conf.Relative_loc, sel_enemy_conf.Relative_rot, sel_enemy_conf.scale, sel_enemy_conf.bone
    end
end


VZ_EVENT_SUBSCRIBE("Events", "VZ_EnemySpawned", function(char)
    local EnemyName = char:GetValue("EnemyName")
    --local enemy_table = Enemies_Config[EnemyName]

    local m, rell, relr, scale, bone = RandomHeadAttached_SM(EnemyName)

    if m then
        local pump_prop = Prop(
            Vector(), Rotator(),
            m,
            CollisionType.NoCollision,
            false,
            GrabMode.Disabled
        )
        pump_prop:SetScale(scale)
        pump_prop:AttachTo(char, AttachmentRule.SnapToTarget, bone, -1, false)
        pump_prop:SetRelativeLocation(rell)
        pump_prop:SetRelativeRotation(relr)
        --print("Attached model", relr)

        pump_prop:SetMaterialScalarParameter("Emissive_Intensity", 1.0)

        pump_prop:SetValue("PPG_pumpprop", true, false)

        char:SetMaterialScalarParameter("Emissive_value", 0.0)
        char:SetValue("PPG_attached_prop", pump_prop, false)
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_EnemyDied", function(char)
    local prop = char:GetValue("PPG_attached_prop")
    if (IsValid(prop)) then
        prop:SetMaterialScalarParameter("Emissive_Intensity", 0.0)
        prop:Detach()
        prop:SetGrabMode(GrabMode.Enabled)
        prop:SetCollision(CollisionType.IgnoreOnlyPawn)
        prop:SetGravityEnabled(true)
        char:SetValue("PPG_attached_prop", nil, false)

        prop:SetValue("PPG_pumpprop_on_ground", true, false)

        local tid = Timer.SetTimeout(function()
            prop:Destroy()
        end, VZ_GetGamemodeConfigValue("Pumpkins_On_Ground_Cleanup_Time_s")*1000)
        Timer.Bind(tid, prop)
    end
end)

function PPG_GetPumpkinsCollected(char)
    if IsValid(char) then
        return char:GetValue("Pumpkins_Collected") or 0
    end
end

function PPG_AddPumpkinsCollected(char, added)
    if IsValid(char) then
        local pumpkins = PPG_GetPumpkinsCollected(char)
        local new_p = pumpkins + added
        char:SetValue("Pumpkins_Collected", new_p, false)
        --print(char:GetPlayer():GetAccountName() .. "'s pumpkins:", new_p)

        if IsValid(VZ_PPG_IMPOSTER) then
            if char == VZ_PPG_IMPOSTER:GetControlledCharacter() then
                Events.CallRemote("UpdateClientPumpkins", VZ_PPG_IMPOSTER, new_p)
            end
        end

        return new_p
    end
end


function PPG_CharacterPickupPumpkin(char, prop)
    if IsValid(char) then
        local ply = char:GetPlayer()
        if IsValid(ply) then
            if prop:GetValue("PPG_pumpprop") then
                if not char:GetValue("PlayerDown") then
                    PPG_AddPumpkinsCollected(char, 1)
                    AddMoney(ply, VZ_GetGamemodeConfigValue("Pumpkins_Money_Given_On_Grab"))

                    prop:Destroy()
                end
                return false
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE("Character", "Interact", PPG_CharacterPickupPumpkin)


VZ_EVENT_SUBSCRIBE("Events", "VZ_GameEnding", function()
    for k, v in pairs(Prop.GetAll()) do
        if IsValid(v) then
            if v:GetValue("PPG_pumpprop") then
                v:Destroy()
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerCharacterSpawned", function(char)
    local ply = char:GetPlayer()
    if IsValid(ply) then
        if ROUND_NB == 1 then
            char:GetPlayer():SetValue("PPG_Imposter", nil, false)
        end

        --Events.CallRemote("TellSpawnedTest", char:GetPlayer())

        --[[local loc = char:GetLocation()
        local goo = GooTentacles(loc)
        --print("Spawned Goo", goo)
        local intervalid = Timer.SetInterval(function()
            if IsValid(goo) then
                if goo:IsTentaclesOut() then
                    goo:DeactivateTentacles()
                else
                    goo:ActivateTentacles()
                end
            end
        end, 10000)]]--
    end
end)


function SpawnImposterParticle(loc)
    if IsValid(VZ_PPG_IMPOSTER) then
        local char = VZ_PPG_IMPOSTER:GetControlledCharacter()
        if IsValid(char) then
            local ip_conf = VZ_GetGamemodeConfigValue("Imposter_Particles")
            if ip_conf then
                local part = Particle(loc, Rotator(0, 0, 0), ip_conf.asset, false, true)

                local params_set = {}

                for k, v in pairs(ip_conf.Parameters or {}) do
                    part[v.setter](part, k, v.value)
                    params_set[k] = v.value
                end

                for k, v in pairs(ip_conf.Dynamic_Pumpkins_Parameters or {}) do
                    local retval = v.func(PPG_GetPumpkinsCollected(char))
                    part[v.setter](part, k, retval)
                    params_set[k] = retval
                end

                --print("Spawned Imposter Particle at " .. tostring(loc))
                --print("parameters: " .. NanosTable.Dump(params_set))

                local part_destroy_time = math.random(ip_conf.Destroy_Timer_Random[1], ip_conf.Destroy_Timer_Random[2])
                local des_id = Timer.SetTimeout(function()
                    part:Deactivate()
                    part:Destroy()
                end, part_destroy_time)
                Timer.Bind(des_id, part)
            end
        end
    end
end


function PPG_Start_Particles_Timer()
    if IsValid(VZ_PPG_IMPOSTER) then
        local char = VZ_PPG_IMPOSTER:GetControlledCharacter()
        if IsValid(char) then
            local Imp_Particles_Config = VZ_GetGamemodeConfigValue("Imposter_Particles")
            if Imp_Particles_Config then

                local wnext_time_ms = Imp_Particles_Config.Spawn_Timer_Wait_Next_Timer(PPG_GetPumpkinsCollected(char))
                --print("Start Imposter particle waitnext timer (" .. tostring(wnext_time_ms) .. ")")
                local waitnext_id = Timer.SetTimeout(function()
                    local cur_char_loc = char:GetLocation()

                    local wait_for_imposter_move_time_ms = math.random(Imp_Particles_Config.Spawn_Timer_Random[1], Imp_Particles_Config.Spawn_Timer_Random[2])
                    --print("Start Imposter particle move timer (" .. tostring(wait_for_imposter_move_time_ms) .. ")")
                    local spawn_timer_id = Timer.SetTimeout(function()
                        SpawnImposterParticle(cur_char_loc)
                        PPG_Start_Particles_Timer()
                    end, wait_for_imposter_move_time_ms)
                    Timer.Bind(spawn_timer_id, char)

                end, wnext_time_ms)
                Timer.Bind(waitnext_id, char)
            else
                warn("Missing imposter particles config!")
            end
        else
            print("Missing imposter character, aborting Start_Particles_Timer")
        end
    end
end

function PPG_Game_Chose_Imposter(imp)
    if imp == nil then
        VZ_PPG_IMPOSTER = nil
        return
    end

    VZ_PPG_IMPOSTER = imp

    imp:SetValue("PPG_Imposter", true, false)

    Events.CallRemote("PPG_Imposter_Notice", imp)
    --print("Sent PPG_Imposter_Notice to " .. imp:GetAccountName())
    print("PPG Imposter: ", imp:GetAccountName() .. " (ID: " .. imp:GetID() .. ")")

    PPG_Start_Particles_Timer()
end


VZ_EVENT_SUBSCRIBE("Events", "VZ_GameStarting", function()
    PPG_Game_Chose_Imposter(nil)
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_WaveStarted", function(wave_nb)
    if wave_nb == 2 then
        local players_tbl_list = {}
        for k, v in pairs(PLAYING_PLAYERS) do
            if not v.BOT then
                local char = v:GetControlledCharacter()
                if IsValid(char) then
                    if not char:GetValue("PlayerDown") then
                        table.insert(players_tbl_list, v)
                    end
                end
            end
        end
        if #players_tbl_list > 0 then
            local imposter = players_tbl_list[math.random(#players_tbl_list)]
            PPG_Game_Chose_Imposter(imposter)
            CheckRoundFinished()
        else
             print("Did not find an imposter at round 2. Normal game occuring...")
        end
    end
end)


function PPG_GetPlayersAliveWOImposterNB()
    local alive_count = GetPlayersAliveNB()
    if ROUND_NB >= 2 then
        if VZ_PPG_IMPOSTER then
            local char = VZ_PPG_IMPOSTER:GetControlledCharacter()
            if IsValid(char) then
                if not char:GetValue("PlayerDown") then
                    alive_count = alive_count - 1
                end
            end
        end
        return alive_count
    else
        return alive_count
    end
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_CheckGameReset", function()
    if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].MIN_PLAYERS > table_count(PLAYING_PLAYERS) then
        return false
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_CheckGameRestart", function()
    -- Check if innocents are still here
    if PPG_GetPlayersAliveWOImposterNB() <= 0 then
        local imp_name = nil
        if IsValid(VZ_PPG_IMPOSTER) then
            imp_name = VZ_PPG_IMPOSTER:GetAccountName()
        end
        Chat.BroadcastMessage("[" .. VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Name .. "] <red>Imposter</> (" .. tostring(imp_name) .. ") won!" )
        return false
    end

    local bystanders_won
    if IsValid(VZ_PPG_IMPOSTER) then
        local char = VZ_PPG_IMPOSTER:GetControlledCharacter()
        if IsValid(char) then
            if char:GetValue("PlayerDown") then
                bystanders_won = true
            end
        else
            bystanders_won = true
        end
    elseif ROUND_NB >= 2 then
        bystanders_won = true
    end

    if bystanders_won then
        Chat.BroadcastMessage("[" .. VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Name .. "] <blue>Bystanders</> won!" )
        return false
    end
end)

Timer.SetInterval(function()
    for k, v in pairs(PLAYING_PLAYERS) do
        local char = v:GetControlledCharacter()
        if IsValid(char) then
            if not char:GetValue("PlayerDown") then
                local copied_pg = TableDeepCopy(PreparedLoops["Pumpkins_Ground"])
                for k2, v2 in pairs(copied_pg) do
                    local dist_sq = v2:GetLocation():DistanceSquared(char:GetLocation())
                    --print(math.sqrt(dist_sq))
                    if dist_sq <= VZ_GetGamemodeConfigValue("Pumpkins_On_Ground_Pickup_Distance_sq") then
                        PPG_CharacterPickupPumpkin(char, v2)
                    end
                end
            end
        end
    end
end, VZ_GetGamemodeConfigValue("Pumpkins_On_Ground_Pickup_Check_Interval_ms"))

function GiveImposterPowerToPlayer(ply)
    local char = ply:GetControlledCharacter()
    if (IsValid(char)) then
        if not char:GetValue("PlayerDown") then
            if not char:GetValue("PPG_Imposter_Activated") then
                for k, v in pairs(PLAYING_PLAYERS) do
                    local vchar = v:GetControlledCharacter()
                    if IsValid(vchar) then
                        local veh = vchar:GetVehicle()
                        if IsValid(veh) then
                            vchar:LeaveVehicle()
                        end
                    end
                end

                DestroyInventoryByChar(char, false)
                char:SetCanGrabProps(false)
                --char:SetCanPickupPickables(false)

                char:SetValue("CanUseKnife", false, true)
                char:SetValue("ZGrenadesNB", 0, true)
                char:SetValue("CanPickupGibs", false, true)
                char:SetValue("CanThrowGrenades", false, true)

                local imp_stats_conf = VZ_GetGamemodeConfigValue("Imposter_Stats")
                if imp_stats_conf then
                    local pumpkins = PPG_GetPumpkinsCollected(char)

                    --print(NanosTable.Dump(imp_stats_conf))

                    for i, v in ipairs(imp_stats_conf) do
                        v.Setfunc(char, v.Base + (v.Per_Pumpkin or 0)*pumpkins + (v.Per_Bystander or 0)*PPG_GetPlayersAliveWOImposterNB())
                    end
                end

                char:SetCameraMode(CameraMode.TPSOnly)

                -- Damage between Bystanders and Imposter
                char:SetTeam(2)

                SetCharacterNotTargeted(char, true)

                char:SetValue("PPG_Imposter_Activated", true, true)

                AddCharacterWeapon(char, VZ_GetGamemodeConfigValue("Imposter_Weapon_Name"), 0, true)
            end
        end
    end
end

VZ_EVENT_SUBSCRIBE("Character", "AttemptEnterVehicle", function(char, veh, seat)
    if IsValid(VZ_PPG_IMPOSTER) then
        local impchar = VZ_PPG_IMPOSTER:GetControlledCharacter()
        if IsValid(impchar) then
            if impchar:GetValue("PPG_Imposter_Activated") then
                return false
            end
        end
    end
end)


VZ_EVENT_SUBSCRIBE_REMOTE("ActivateImposterPower", function(ply)
    if ply == VZ_PPG_IMPOSTER then
        local char = ply:GetControlledCharacter()
        if (IsValid(char)) then
            if not char:GetValue("PlayerDown") then
                if PPG_CanActivateImposterPower() then
                    GiveImposterPowerToPlayer(ply)
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_CanAddWeaponToInventory", function(char, weapon_name)
    if char:GetValue("PPG_Imposter_Activated") then
        -- Activated Imposter cannot add other weapons in his inventory
        if weapon_name ~= VZ_GetGamemodeConfigValue("Imposter_Weapon_Name") then
            return false
        end
    -- Others cannot get the imposter weapon
    elseif weapon_name == VZ_GetGamemodeConfigValue("Imposter_Weapon_Name") then
        return false
    end
end)


function PPG_SpawnSabotage(loc, classes_tbl, duration_s, goo_type)
    local sabotage_distsq = VZ_GetGamemodeConfigValue("Imposter_Sabotage_Distance_sq") or 0
    local sabotage_dist = math.sqrt(sabotage_distsq)

    local affected_entities = {}

    for i, classname in ipairs(classes_tbl or {}) do
        for k2, v2 in pairs((_ENV[classname] or {}).GetPairs() or {}) do
            if not v2:GetAttachedTo() then
                if (not v2.GetHandler) or (not v2:GetHandler()) then
                    local dist_sq = loc:DistanceSquared(v2:GetLocation())
                    if (dist_sq <= sabotage_distsq) then
                        v2:SetValue("PPG_Last_Sabotaged_Time", GAME_TIMER_SECONDS, true)
                        v2:SetValue("PPG_Sabotaged", (v2:GetValue("PPG_Sabotaged") or 0) + 1, false)
                        table.insert(affected_entities, v2)
                    end
                end
            end
        end
    end

    print("PPG_SpawnSabotage", #affected_entities)

    local checks_limit = 100

    local goo = GooTentacles(loc, nil, goo_type)
    goo:SetSearchAnchorableTag(true)
    goo:SetConfig(math.floor(math.min(((#affected_entities)*3.5)+1, checks_limit)), math.ceil(math.min(((#affected_entities)*2)+1, checks_limit)), sabotage_dist, 4000)
    goo:ActivateTentacles()

    local sab_destroy_timeoutid = Timer.SetTimeout(function()
        if IsValid(goo) then
            goo:ExplodeTentacles()
        end
        for i, v in ipairs(affected_entities) do
            if v:IsValid() then
                local s_value = v:GetValue("PPG_Sabotaged")
                if s_value <= 1 then
                    v:SetValue("PPG_Sabotaged", nil, false)
                    v:SetValue("PPG_Last_Sabotaged_Time", nil, true)
                else
                    v:SetValue("PPG_Sabotaged", s_value-1, false)
                end
            end
        end
    end, duration_s*1000)
    --Timer.Bind(sab_destroy_timeoutid, goo)

    return goo
end

VZ_EVENT_SUBSCRIBE_REMOTE("ImposterSabotage", function(ply)
    if ply == VZ_PPG_IMPOSTER then
        if ROUND_NB > 0 then
            local char = ply:GetControlledCharacter()
            if (IsValid(char) and (not char:GetValue("PlayerDown"))) then
                if (not char:GetValue("InSabotageCooldown")) then
                    char:SetValue("InSabotageCooldown", true, false)

                    local cdown_timeoutid = Timer.SetTimeout(function()
                        char:SetValue("InSabotageCooldown", nil, false)
                    end, VZ_GetGamemodeConfigValue("Imposter_Sabotage_Cooldown_s")*1000)
                    Timer.Bind(cdown_timeoutid, char)

                    local goo
                    if not char:GetValue("PPG_Imposter_Activated") then
                        PPG_SpawnSabotage(char:GetLocation(), VZ_GetGamemodeConfigValue("Imposter_Sabotage_Check_Classes"), VZ_GetGamemodeConfigValue("Imposter_Sabotage_Duration_s"))
                    else
                        PPG_SpawnSabotage(char:GetLocation(), VZ_GetGamemodeConfigValue("Imposter_Dark_Sabotage_Check_Classes"), VZ_GetGamemodeConfigValue("Imposter_Dark_Sabotage_Duration_s"), 2)
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "PPG_Sabotaged" then
        local ply = char:GetPlayer()
        if IsValid(ply) then
            if ply ~= VZ_PPG_IMPOSTER then
                if not char:GetValue("PlayerDown") then
                    print("Sabotage Character", value)

                    char:SetInputEnabled(not value)
                    char:SetCanAim(not value)
                    char:SetCameraMode((value and CameraMode.TPSOnly) or CAMERA_MODE)
                end
            end
        end
    end
end)