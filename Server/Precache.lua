
local precached_assets = {}
local pa_count = 0

function VZ_GetPrecachedAssets()
    return precached_assets
end

function VZ_GetPrecachedAssetsCount()
    return pa_count
end

function VZ_PRECACHE_ASSET(asset, atype)
    if precached_assets[asset] == nil then
        pa_count = pa_count + 1
    end
    precached_assets[asset] = atype
    local pre_ret = Assets.Precache(asset, atype)
    return pre_ret
end

VZ_PRECACHE_ASSET(Player_Down_Animation, AssetType.Animation)

for k, v in pairs(NanosWorldWeapons) do
    local weap = v(Vector(), Rotator())
    if weap:IsA(Weapon) then
        VZ_PRECACHE_ASSET(weap:GetMesh(), AssetType.SkeletalMesh)
    elseif (weap:IsA(Grenade) or weap:IsA(Melee)) then
        VZ_PRECACHE_ASSET(weap:GetMesh(), AssetType.StaticMesh)
    end
    weap:Destroy()
end


VZ_PRECACHE_ASSET(Enemy_Under_Ground_Animation.asset, AssetType.Animation)

for k, v in pairs(Enemies_Config) do
    for i2, v2 in ipairs(v.Models or {}) do
        if type(v2) == "table" then
            VZ_PRECACHE_ASSET(v2.asset, AssetType.SkeletalMesh)
        else
            VZ_PRECACHE_ASSET(v2, AssetType.SkeletalMesh)
        end
    end

    for i2, v2 in ipairs(v.Attack_Anims or {}) do
        VZ_PRECACHE_ASSET(v2[1], AssetType.Animation)
    end

    for k2, v2 in pairs(v.Gibs or {}) do
        if type(v2.asset) == "table" then
            for i3, v3 in ipairs(v2.asset) do
                VZ_PRECACHE_ASSET(v3, AssetType.StaticMesh)
            end
        else
            VZ_PRECACHE_ASSET(v2.asset, AssetType.StaticMesh)
        end
    end

    for enemy_name, v2 in pairs(v.Types or {}) do
        if v2.Vault_Anim then
            VZ_PRECACHE_ASSET(v2.Vault_Anim.path, AssetType.Animation)
        elseif v2.New_Attack_Anims then
            for i3, v3 in ipairs(v2.New_Attack_Anims) do
                VZ_PRECACHE_ASSET(v3[1], AssetType.Animation)
            end
        end
    end

    for i2, v2 in ipairs(v.Enemy_Materials_Assets or {}) do
        for part, v3 in pairs(v2) do
            for i4, v4 in ipairs(v3) do
                VZ_PRECACHE_ASSET(v4, AssetType.Material)
            end
        end
    end
end

for name, v in pairs(Player_Models) do
    for i2, v2 in ipairs(v.Models or {}) do
        VZ_PRECACHE_ASSET(v2, AssetType.SkeletalMesh)
    end
end

print(tostring(VZ_GetPrecachedAssetsCount()) .. " assets to Precache")