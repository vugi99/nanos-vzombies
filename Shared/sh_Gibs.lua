

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

function SetGibMaterials(char_asset, gib, bone, enemy_table)
    if char_asset then
        if enemy_table.Models_Materials[char_asset] then
            for i, v in ipairs(enemy_table.Gibs[bone].materials) do
                local material_part_asset_index = enemy_table.Models_Materials[char_asset][v]
                if material_part_asset_index then
                    if enemy_table.Enemy_Materials_Assets[v][material_part_asset_index] then
                        --print("Set Gib Mat", bone, i-1, enemy_table.Enemy_Materials_Assets[v][material_part_asset_index])
                        gib:SetMaterial(enemy_table.Enemy_Materials_Assets[v][material_part_asset_index], i-1)
                    end
                end
            end
        end
    end
end