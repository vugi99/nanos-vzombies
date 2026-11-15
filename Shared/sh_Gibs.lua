

local EnemiesBonesHealth = {}

function DamageZombieBone(char, bone, damage, goingtodie, instigator)
    if not EnemiesBonesHealth[char:GetID()] then
        Console.Warn("Missing EnemiesBonesHealth for %s (%d)", char, char:GetID())
        return
    end
    if EnemiesBonesHealth[char:GetID()][bone] and EnemiesBonesHealth[char:GetID()][bone] > 0 then
        --print("DamageZombieBone", char, bone, damage, goingtodie, instigator)
        if EnemiesBonesHealth[char:GetID()][bone] - damage > 0 then
            EnemiesBonesHealth[char:GetID()][bone] = EnemiesBonesHealth[char:GetID()][bone] - damage
        else
            EnemiesBonesHealth[char:GetID()][bone] = 0
            if GetEnemyTable(char).Gibs[bone].Detach then
                for i, v in ipairs(GetEnemyTable(char).Gibs[bone].Detach) do
                    DamageZombieBone(char, v, EnemiesBonesHealth[char:GetID()][v], goingtodie, instigator)
                end
            end
            VZ_EVENT_CALL("Events", "VZ_SpawnGib", char, bone, goingtodie, instigator)
        end
    end
end

local function InitEnemiesBonesHealth(char)
    if EnemiesBonesHealth[char:GetID()] then return end
    local health = char:GetHealth()
    EnemiesBonesHealth[char:GetID()] = {}
    --print("Init EnemiesBonesHealth", char, char:GetID())
    local enemy_table = GetEnemyTable(char)
    if not enemy_table then return end
    if not enemy_table.Gibs then return end
    for k, v in pairs(enemy_table.Gibs) do
        EnemiesBonesHealth[char:GetID()][k] = (health * v.health_p) / 100
        --print((health * v.health_p) / 100)
    end
    return true
end
for k, v in pairs(Character.GetPairs()) do
    if v:GetValue("EnemyType") then
        InitEnemiesBonesHealth(v)
    end
end

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "EnemyType" then
        InitEnemiesBonesHealth(char)
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    EnemiesBonesHealth[char:GetID()] = nil
end)

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, type, from_direction, instigator, causer)
    if not IsValid(char) then return end
    if (char:GetValue("EnemyType") and damage > 0) then
        --if char:IsDead() then return end

        --print("TakeDamage", char, bone, damage)
        --print(debug.traceback("TakeDamage"))

        if GetEnemyTable(char).Gibs then
            --print("Health", char:GetHealth())
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