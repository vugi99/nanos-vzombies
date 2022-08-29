

local Weapons_Table_Indexes = {}
for k, v in pairs(NanosWorldWeapons) do
    table.insert(Weapons_Table_Indexes, k)
end

function PickRandomWeapon()
    return Weapons_Table_Indexes[math.random(table_count(Weapons_Table_Indexes))]
end

Player_Start_Weapon.weapon_name = PickRandomWeapon()
Player_Start_Weapon.ammo = VZ_GetGamemodeConfigValue("Weapon_Ammo_Bag")

Timer.SetInterval(function()
    if ROUND_NB > 0 then

        local random_weapon = PickRandomWeapon()

        for k, v in pairs(Character.GetPairs()) do
            if v:GetPlayer() then
                if not v:GetValue("PlayerDown") then
                    local charInvID = GetCharacterInventory(v)

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

                    AddCharacterWeapon(v, random_weapon, VZ_GetGamemodeConfigValue("Weapon_Ammo_Bag"), true)
                end
            end
        end
    end
end, VZ_GetGamemodeConfigValue("Weapon_Change_Interval_ms"))

function GetPlayersAliveSharpshooter()
    local tbl = {}
    for k, v in pairs(PLAYING_PLAYERS) do
        local char = v:GetControlledCharacter()
        if (char and not char:GetValue("PlayerDown")) then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function Sharpshooter_End_Check()
    local Players_Alive_Sharp = GetPlayersAliveSharpshooter()
    if table_count(Players_Alive_Sharp) == 1 then
        Server.BroadcastChatMessage(Players_Alive_Sharp[1]:GetAccountName() .. " won the Sharpshooter game.")

        RoundFinished(false, true)
    end
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_CharacterDown", function(char)
    Sharpshooter_End_Check()
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerLeft", function(ply)
    if ROUND_NB > 0 then
        Sharpshooter_End_Check()
    end
end)