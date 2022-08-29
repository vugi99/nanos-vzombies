
Custom_Anims_BP = Blueprint(
    Vector(0, 0, 0),
    Rotator(0, 0, 0),
    "vzombies-assets::VZ_CustomAnims"
)


function HandleEnemyType(char, value)
    local enemy_table = GetEnemyTable(char)

    local old_value = char:GetValue("OldEnemyType")
    if old_value ~= nil then
        if enemy_table.Custom_Anims_Transform["to_" .. value] then
            enemy_table.Custom_Anims_Transform["to_" .. value](Custom_Anims_BP, char)
        end
    else
        if enemy_table.Custom_Anims_Func then
            enemy_table.Custom_Anims_Func(Custom_Anims_BP, char)
        end

        char:SetValue("OldEnemyType", value)
    end

    if value == "brutus" then
        local bat = StaticMesh(
            Vector(),
            Rotator(),
            "vzombies-assets::Brutus_Bat",
            CollisionType.NoCollision
        )
        bat:AttachTo(char, AttachmentRule.SnapToTarget, "RightHand", 0)
        bat:SetRelativeLocation(Vector(-15, 5, 0))
    elseif value == "napalm" then
        local napalm_fire = Particle(
            Vector(),
            Rotator(0, 0, 0),
            "nanos-world::P_Fire_01",
            false,
            true
        )
        napalm_fire:AttachTo(char, AttachmentRule.SnapToTarget, "", 0)
        napalm_fire:SetRelativeLocation(Vector(0, 0, -96))

        local napalm_fire_sound = Sound(
            Vector(),
            Napalm_Fire_Ambient_Sound.asset,
            false,
            false,
            SoundType.SFX,
            Napalm_Fire_Ambient_Sound.volume,
            1,
            Napalm_Fire_Ambient_Sound.radius,
            Napalm_Fire_Ambient_Sound.falloff_distance,
            AttenuationFunction.NaturalSound,
            false,
            SoundLoopMode.Forever
        )
        napalm_fire_sound:AttachTo(char, AttachmentRule.SnapToTarget, "", 0)
    end
end

for k, v in pairs(Character.GetPairs()) do
    if v:IsValid() then
        if v:GetValue("EnemyType") then
            HandleEnemyType(v, v:GetValue("EnemyType"))
        end
    end
end


VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "EnemyType" then
        if value then
            HandleEnemyType(char, value)

            if value == "hellhound" then
                local hellhound_spawn_particle = Particle(
                    char:GetLocation() - Vector(0, 0, 100),
                    char:GetRotation(),
                    "vzombies-assets::P_ky_lightning3",
                    true,
                    true
                )

                local spawn_sound_part1 = Sound(
                    char:GetLocation(),
                    "vzombies-assets::hell_spawn",
                    false,
                    true,
                    SoundType.SFX,
                    1,
                    1,
                    400,
                    3500
                )

                local spawn_sound_part2 = Sound(
                    char:GetLocation(),
                    "vzombies-assets::hell_strikes",
                    false,
                    true,
                    SoundType.SFX,
                    1,
                    1,
                    400,
                    3500
                )
            elseif value == "brutus" then
                local hellhound_spawn_particle = Particle(
                    char:GetLocation() - Vector(0, 0, 100),
                    char:GetRotation(),
                    "vzombies-assets::P_ky_lightning3",
                    true,
                    true
                )

                local spawn_sound_part1 = Sound(
                    char:GetLocation(),
                    "vzombies-assets::brutus_spawn",
                    false,
                    true,
                    SoundType.SFX,
                    1,
                    1,
                    400,
                    3500
                )

            elseif value == "napalm" then
                local hellhound_spawn_particle = Particle(
                    char:GetLocation() - Vector(0, 0, 100),
                    char:GetRotation(),
                    "vzombies-assets::P_ky_lightning3",
                    true,
                    true
                )

                local spawn_sound_part1 = Sound(
                    char:GetLocation(),
                    "vzombies-assets::Napalm_Spawn",
                    false,
                    true,
                    SoundType.SFX,
                    1,
                    1,
                    400,
                    3500
                )
            end
        end
    end
end)


if ZDEV_IsModeEnabled("ZDEV_DEBUG_ENEMIES_PREDICTION") then
    Client.Subscribe("Tick", function(ds)
        local local_ply = Client.GetLocalPlayer()
        if local_ply then
            local char = local_ply:GetControlledCharacter()
            if char then
                local dir = char:GetVelocity():GetSafeNormal()
                Client.DrawDebugLine(char:GetLocation(), char:GetLocation() + dir * (char:GetVelocity():Size() / Enemies_Damage_Prediction_Div), Color.GREEN, ds * 4, 1)
            end
        end
    end)
end