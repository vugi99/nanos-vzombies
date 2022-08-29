

VZ_EVENT_SUBSCRIBE("Events", "VZ_SpawnGib", function(char, bone, goingtodie, instigator)
    if char:IsValid() then
        local bone_transform = char:GetBoneTransform(bone)

        char:HideBone(bone)

        --[[local blood_particle = Particle(
            bone_transform.Location,
            bone_transform.Rotation,
            Enemies_Gibs_Particle,
            true,
            true
        )]]--


        local enemy_table = GetEnemyTable(char)

        if bone == enemy_table.Gibs_heart_bone then
            char:SetValue("HeadGibSpawned", true)
        end

        local self_char = Client.GetLocalPlayer():GetControlledCharacter()

        local dist
        if self_char then
            dist = char:GetLocation():DistanceSquared(self_char:GetLocation())
        else
            dist = 0
        end

        --print(math.sqrt(dist))
        --if dist < Enemies_Gibs_Max_Spawn_Distance_sq then

        if (instigator == Client.GetLocalPlayer() or (dist < Enemies_Gibs_Max_Spawn_Distance_sq)) then

            local gib = Prop(
                bone_transform.Location,
                bone_transform.Rotation,
                enemy_table.Gibs[bone].asset,
                CollisionType.IgnoreOnlyPawn,
                true,
                GrabMode.Disabled
            )
            gib:SetValue("GibData", {char:GetValue("EnemyName"), bone})
            --print(gib:GetID())

            if (enemy_table.Enemy_Materials_Assets and enemy_table.Models_Materials) then
                if enemy_table.Gibs[bone].materials then
                    local char_mesh = char:GetMesh()
                    local splited = split_str(char_mesh, ":")
                    if splited[2] then
                        gib:SetValue("GibData", {char:GetValue("EnemyName"), bone, splited[2]})
                        SetGibMaterials(splited[2], gib, bone, enemy_table)
                    end
                end
            end

            Timer.SetTimeout(function()
                if gib:IsValid() then
                    gib:Destroy()
                end
            end, Enemies_Gibs_Destroy_Timeout_ms)

            if bone == enemy_table.Gibs_heart_bone then
                gib:SetMaterialScalarParameter("Emissive_value", 0.0)
            end
        else
            --print("Gib aborted")
        end
    end
end)

-- Remove character head if the death hit is on the head (To fix the last TakeDamage not called if it was killed on the server)
-- I don't really understand why last_bone_damage is head when the character was killed serverside, this could become an issue if it gets fixed
VZ_EVENT_SUBSCRIBE("Character", "Death", function(char, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer)
    if char:GetValue("EnemyType") then
        local enemy_table = GetEnemyTable(char)
        if enemy_table.Gibs then

            --print("Zombie Death", last_bone_damage)
            if (last_bone_damage == enemy_table.Gibs_heart_bone and damage_type_reason == DamageType.Shot) then
                if not char:GetValue("HeadGibSpawned") then
                    Events.Call("VZ_SpawnGib", char, last_bone_damage)
                end
            end
        end
    end
end)