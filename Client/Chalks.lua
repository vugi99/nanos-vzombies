

if VZ_GetFeatureValue("Map_Weapons", "spawned") then
    for k, v in pairs(MAP_WEAPONS) do
        local is_chalk = Chalks_Images[v.weapon_name]
        if is_chalk then
            for k2, v2 in pairs(Weapon.GetPairs()) do
                local map_weap_id = v2:GetValue("MapWeaponID")
                if (map_weap_id and map_weap_id == k) then
                    local chalk = Decal(
                        Vector(),
                        Rotator(),
                        "nanos-world::M_NanosDecal",
                        Chalks_Size,
                        -1,
                        0.01
                    )

                    chalk:SetMaterialTextureParameter("Texture", "package://" .. Package.GetPath() .. "/Client/images/Chalks/" .. v.weapon_name .. ".png")
                    chalk:SetMaterialScalarParameter("Opacity", 1)
                    chalk:SetMaterialColorParameter("Emissive", Chalks_Emissive_Color * Chalks_Emissive_Value)

                    chalk:AttachTo(v2, AttachmentRule.SnapToTarget, "", 0)
                    chalk:SetRelativeRotation(Rotator(0, 90, 90))
                    chalk:SetRelativeLocation(Chalks_Offset)
                    break
                end
            end
        end
    end
end