

local Weapons_Random_Order = {}

Player_Start_Weapon.ammo = VZ_GetGamemodeConfigValue("Weapon_Ammo_Bag")

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerJoined", function(ply, waittostart)
    Events.CallRemote("GunGame_WeaponsNumber", ply, table_count(Weapons_Random_Order))
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerCharacterSpawned", function(char)
    char:SetValue("CurrentWeapon", 1, true)
    char:SetValue("WeaponKillCount", 0, true)
end)

function GunGame_GenerateRandomWeapons()
    local Weapons_Table_Indexes = {}
    Weapons_Random_Order = {}

    for k, v in pairs(NanosWorldWeapons) do
        table.insert(Weapons_Table_Indexes, k)
    end

    for i = 1, table_count(Weapons_Table_Indexes) do
        local random_index = math.random(table_count(Weapons_Table_Indexes))
        table.insert(Weapons_Random_Order, Weapons_Table_Indexes[random_index])
        table.remove(Weapons_Table_Indexes, random_index)
    end

    Player_Start_Weapon.weapon_name = Weapons_Random_Order[1]
end
GunGame_GenerateRandomWeapons()
VZ_EVENT_SUBSCRIBE("Events", "VZ_GameEnded", GunGame_GenerateRandomWeapons)

function GunGame_HandleZombieDeath(char, instigator)
    if char:GetValue("Enemy") == true then
        if instigator then
            local instig_char = instigator:GetControlledCharacter()
            if instig_char then
                local weapon_kill_count = instig_char:GetValue("WeaponKillCount") + 1
                if weapon_kill_count >= VZ_GetGamemodeConfigValue("Kills_To_Next_Weapon") then
                    local weapon_index = instig_char:GetValue("CurrentWeapon") + 1
                    if weapon_index > table_count(Weapons_Random_Order) then
                        Server.BroadcastChatMessage(instigator:GetAccountName() .. " won the GunGame.")

                        RoundFinished(false, true)
                    else
                        local charInvID = GetCharacterInventory(instig_char)

                        if charInvID then
                            for i2, v2 in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                                if v2.weapon then
                                    if v2.weapon:IsValid() then
                                        v2.destroying = true
                                        v2.weapon:Destroy()
                                        table.remove(PlayersCharactersWeapons[charInvID].weapons, i2)
                                        break
                                    end
                                end
                            end
                        end

                        AddCharacterWeapon(instig_char, Weapons_Random_Order[weapon_index], VZ_GetGamemodeConfigValue("Weapon_Ammo_Bag"), true)

                        instig_char:SetValue("CurrentWeapon", weapon_index, true)
                        instig_char:SetValue("WeaponKillCount", 0, true)
                    end
                else
                    instig_char:SetValue("WeaponKillCount", weapon_kill_count, true)
                end
            end
        end
    end
end


VZ_EVENT_SUBSCRIBE("Character", "Death", function(char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer)
    GunGame_HandleZombieDeath(char, instigator)
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_ZombieKill_InstaKill", function(char, damage, bone, dtype, from_direction, instigator, causer)
    if (instigator and instigator ~= "BOT") then
        GunGame_HandleZombieDeath(char, instigator)
    end
end)