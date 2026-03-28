
local BP_VZ_Extras = Blueprint(Vector(), Rotator(), "vzombies-assets::VZ_Extras")

VZ_IS_PPG_IMPOSTER = false

VZ_Register_Input("Imposter Power", "K")
VZ_Register_Input("Imposter Sabotage", "C")

--RegisterPreparedLoop("Pumpkins_Ground", Prop, "PPG_pumpprop_on_ground")


local function SpawnCharacterHandAuraParticle(char, bone)
    if type(bone) == "string" then
        local hand_part = Particle(
            Vector(0, 0, 0),
            Rotator(0, 0, 0),
            "vzombies-assets::NS_aura",
            false,
            true
        )

        hand_part:AttachTo(char, AttachmentRule.SnapToTarget, bone, 0)

        char:SetValue("HandAuraParticle_" .. bone, hand_part)
    end
end

local function SetCharacterAura(char, enabled)
    if IsValid(char) then
        --print("SetCharacterAura", char, enabled)

        --if not IsSelfCharacter(char) then
        --char:AddActorTag("vzextrastag")
        --local is_set = BP_VZ_Extras:CallBlueprintEvent("SetMaterialOverlay", enabled or false)
        --end
        --print("SetCharacterAura", enabled, is_set)


        local bone_l = "hand_l"
        local bone_r = "hand_r"
        --if IsSelfCharacter(char) then
            --bone_l = "foot_l"
            --bone_r = "foot_r"
        --end

        if enabled then
            SpawnCharacterHandAuraParticle(char, bone_l)
            SpawnCharacterHandAuraParticle(char, bone_r)
        else
            local part_l = char:GetValue("HandAuraParticle_" .. bone_l)
            if IsValid(part_l) then
                part_l:Deactivate()
                part_l:Destroy()
            end

            local part_r = char:GetValue("HandAuraParticle_" .. bone_r)
            if IsValid(part_r) then
                part_r:Deactivate()
                part_r:Destroy()
            end
        end
    end
end


function PPG_SetImposter(imposter)
    --print("Imposter change", imposter)
    VZ_IS_PPG_IMPOSTER = imposter
    PPG_One_Time_Update_Data.ImposterActivated = nil
    if imposter then
        PPG_UI_Set_Role("Imposter")
        PPG_UI_ShowImposterImage(5000, true)

        local chosen_sound_conf = VZ_GetGamemodeConfigValue("Imposter_Chosen_Sound")
        if chosen_sound_conf then
            local chosen_sound = Sound(
                Vector(0, 0, 0),
                chosen_sound_conf.asset,
                true,
                true,
                SoundType.SFX,
                chosen_sound_conf.volume,
                1
            )
        end
    else
        PPG_UI_Set_Role("Bystander")
    end
end

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "PlayerDown" then
        if value then
            SetCharacterAura(char, false)
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    if ply == Client.GetLocalPlayer() then
        PPG_SetImposter(false)
        VZ_ShowHowToPlayFrame(true)
    end
end)
if IsValid(Client.GetLocalPlayer():GetControlledCharacter()) then
    PPG_SetImposter(false)
end
VZ_ShowHowToPlayFrame(true)

VZ_EVENT_SUBSCRIBE("Player", "UnPossess", function(ply, char)
    if ply == Client.GetLocalPlayer() then
        PPG_SetImposter(false)
        PPG_UI_Set_Role(nil)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_Imposter_Notice", function()
    PPG_SetImposter(true)
end)

VZ_BIND("Imposter Power", InputEvent.Pressed, function()
    if VZ_IS_PPG_IMPOSTER then
        if PPG_CanActivateImposterPower() then
            Events.CallRemote("ActivateImposterPower")
        end
    end
end)

VZ_BIND("Imposter Sabotage", InputEvent.Pressed, function()
    if VZ_IS_PPG_IMPOSTER then
        local char = GetLocalCharacter()
        if IsValid(char) and (not char:GetValue("PlayerDown")) then
            if not PPG_One_Time_Update_Data.Sabotage_Cooldown then
                PPG_One_Time_Update_Data.Sabotage_Cooldown = VZ_GetGamemodeConfigValue("Imposter_Sabotage_Cooldown_s") or 0
                PPG_One_Time_Updates_Canvas:Repaint()

                local cdown_timeout = Timer.SetTimeout(function()
                    PPG_One_Time_Update_Data.Sabotage_Cooldown = nil
                    PPG_One_Time_Updates_Canvas:Repaint()
                end, PPG_One_Time_Update_Data.Sabotage_Cooldown*1000)
                Timer.Bind(cdown_timeout, char)

                local cdown_remaining
                cdown_remaining = Timer.SetInterval(function()
                    if PPG_One_Time_Update_Data.Sabotage_Cooldown then
                        if PPG_One_Time_Update_Data.Sabotage_Cooldown >= 1 then
                            PPG_One_Time_Update_Data.Sabotage_Cooldown = PPG_One_Time_Update_Data.Sabotage_Cooldown - 1
                            PPG_One_Time_Updates_Canvas:Repaint()
                            return
                        end
                    end

                    Timer.ClearInterval(cdown_remaining)
                end, 1000)
                Timer.Bind(cdown_remaining, char)

                Events.CallRemote("ImposterSabotage")
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "PPG_Imposter_Activated" and value then
        local Imposter_Activated_Sound_conf = VZ_GetGamemodeConfigValue("Imposter_Activated_Sound")
        if Imposter_Activated_Sound_conf then
            if IsSelfCharacter(char) then
                local imp_activated_sound = Sound(
                    Vector(0, 0, 0),
                    Imposter_Activated_Sound_conf.asset,
                    true,
                    true,
                    SoundType.SFX,
                    Imposter_Activated_Sound_conf.volume,
                    1
                )
            end
        end

        SetCharacterAura(char, true)

        if IsSelfCharacter(char) then
            PPG_One_Time_Update_Data.ImposterActivated = true
            PPG_One_Time_Updates_Canvas:Repaint()
        end
    end
end)

for i, classname in ipairs(VZ_GetGamemodeConfigValue("Imposter_Sabotage_Check_Classes") or {}) do
    VZ_EVENT_SUBSCRIBE(classname, "ValueChange", function(ent, key, value)
        if key == "PPG_Last_Sabotaged_Time" then
            if value then
                if ent.AddActorTag then
                    ent:AddActorTag("TentacleAnchorable")
                    --print("Sabotage AddActorTag", ent)
                end
            else
                if ent.RemoveActorTag then
                    ent:RemoveActorTag("TentacleAnchorable")
                    --print("Sabotage RemoveActorTag", ent)
                end
            end
        end
    end)
end

function PPG_ClientCheckSabotaged(try_target)
    if IsValid(try_target) and try_target.GetValue then
        if try_target:GetValue("PPG_Last_Sabotaged_Time") then
            InteractText("Buyable locked for " .. tostring(math.ceil((VZ_GetGamemodeConfigValue("Imposter_Sabotage_Duration_s") or 0) - ((GAME_TIMER_SECONDS or 0) - try_target:GetValue("PPG_Last_Sabotaged_Time")))) .. "s")
            InteractThing = nil
        end
    end
end
