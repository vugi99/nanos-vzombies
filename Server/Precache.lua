

for k, v in pairs(NanosWorldWeapons) do
    local weap = v(Vector(), Rotator())
    if weap:IsA(Weapon) then
        Assets.Precache(weap:GetMesh(), AssetType.SkeletalMesh)
    elseif (weap:IsA(Grenade) or weap:IsA(Melee)) then
        Assets.Precache(weap:GetMesh(), AssetType.StaticMesh)
    end
    weap:Destroy()
end