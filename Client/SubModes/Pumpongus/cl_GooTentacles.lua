

function GooTSoundAsset(goo, sound_tbl)
    if type(sound_tbl.asset) == "string" then
        return sound_tbl.asset
    elseif type(sound_tbl.asset) == "table" then
        return sound_tbl.asset[goo:GetValue("GooType")]
    end

    --error("Invalid GooTentacles sound_tbl value")
end


function GooTPlaySound(goo, sound_tbl)
    if IsValid(goo) then
        if sound_tbl then
            local goo_t_sound = Sound(
                goo:GetLocation(),
                GooTSoundAsset(goo, sound_tbl),
                false,
                (not sound_tbl.looping),
                SoundType.SFX,
                sound_tbl.volume or 1,
                1,
                sound_tbl.radius or 400,
                sound_tbl.falloff_distance or 3600,
                AttenuationFunction.NaturalSound
            )

            if sound_tbl.looping then
                goo_t_sound:AttachTo(goo, AttachmentRule.SnapToTarget, "", 0)
                return goo_t_sound
            end
        end
    end
end

function GetGooTSoundConfigTable(name)
    local goot_sounds = VZ_GetGamemodeConfigValue("Tentacles_Sounds")
    if goot_sounds then
        return goot_sounds[name]
    end
end


function ClientHandleGooTentaclesSpawn(v)
    GooTPlaySound(v, GetGooTSoundConfigTable("Spawn"))
    GooTPlaySound(v, GetGooTSoundConfigTable("Loop"))
end
VZ_EVENT_SUBSCRIBE("GooTentacles", "Spawn", ClientHandleGooTentaclesSpawn)
for k, v in pairs(GooTentacles.GetPairs()) do
    if v:IsValid() then
        ClientHandleGooTentaclesSpawn(v)
    end
end

VZ_EVENT_SUBSCRIBE("GooTentacles", "Destroy", function(v)
    --print("Unload")
    --print("GooTentacles Destroy", v, v:GetID())
    -- Nanos has weird (wrong network messages ordering) inherited entities initialization leading to bugs at this point, tentacles can persist across reloads and this will error
    if v:IsTentaclesOut() then
        v:DeactivateTentacles()
        --print("Destroy DeactivateTentacles")
    end
end)

VZ_EVENT_SUBSCRIBE("GooTentacles", "ValueChange", function(goo, key, value)
    if key == "TentaclesActivated" then
        if value then
            GooTPlaySound(goo, GetGooTSoundConfigTable("Out"))
            if ZDEV_IsModeEnabled("ZDEV_DEBUG_SHOW_TENTACLES_RADIUS") then
                Debug.DrawSphere(goo:GetLocation(), goo:GetValue("CheckRadius"), 25, Color.GREEN, 15, 1)
            end
        else
            GooTPlaySound(goo, GetGooTSoundConfigTable("In"))
        end
    end

    if key == "GooExploding" then
        if value then
            GooTPlaySound(goo, GetGooTSoundConfigTable("Explode"))
        end
    end
end)