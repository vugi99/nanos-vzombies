

local EnemiesBonesHealth = {}

function DamageZombieBone(char, bone, damage, goingtodie, instigator)
    if EnemiesBonesHealth[char:GetID()][bone] then
        if EnemiesBonesHealth[char:GetID()][bone] - damage > 0 then
            EnemiesBonesHealth[char:GetID()][bone] = EnemiesBonesHealth[char:GetID()][bone] - damage
        else
            EnemiesBonesHealth[char:GetID()][bone] = 0
            if GetEnemyTable(char).Gibs[bone].Detach then
                for i, v in ipairs(GetEnemyTable(char).Gibs[bone].Detach) do
                    if EnemiesBonesHealth[char:GetID()][v] > 0 then
                        DamageZombieBone(char, v, EnemiesBonesHealth[char:GetID()][v], goingtodie, instigator)
                    end
                end
            end
            Events.Call("VZ_SpawnGib", char, bone, goingtodie, instigator)
        end
    end
end

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, type, from_direction, instigator, causer)
    if (char:GetValue("EnemyType") and damage > 0) then

        --print("TakeDamage", bone, damage)

        if GetEnemyTable(char).Gibs then

            -- Not called when the zombie dies so missing last hit clientside
            --print("Health", char:GetHealth())
            if not EnemiesBonesHealth[char:GetID()] then
                local health = char:GetHealth()
                EnemiesBonesHealth[char:GetID()] = {}
                for k, v in pairs(GetEnemyTable(char).Gibs) do
                    EnemiesBonesHealth[char:GetID()][k] = (health * v.health_p) / 100
                    --print((health * v.health_p) / 100)
                end
            end

            DamageZombieBone(char, bone, damage, char:GetHealth() - damage <= 0, instigator)
        end
    end
end)

function SetGibMaterials(gib, bone, enemy_table, enemy_mats)
    for i, v in ipairs(enemy_table.Gibs[bone].materials) do
        --print(v)
        gib:SetMaterial(enemy_mats[v][2], i-1)
    end
end

function GetRealGibAsset(char, gib_asset)
    local enemy_table = GetEnemyTable(char)
    if type(gib_asset) == "table" then
        local char_mesh = char:GetMesh()
        for i, v in ipairs(enemy_table.Models) do
            if type(v) == "string" then
                if v == char_mesh then
                    gib_asset = gib_asset[i]
                    break
                end
            else
                if v.asset == char_mesh then
                    gib_asset = gib_asset[i]
                    break
                end
            end
        end
    end

    return gib_asset
end