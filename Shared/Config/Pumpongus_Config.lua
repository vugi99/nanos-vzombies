
ZDEV_CONFIG.DEV_MODES.ZDEV_DEBUG_SHOW_TENTACLES_RADIUS = false

local pumpkin_zombie_attach = {
    Relative_loc = Vector(0, 0, 0),
    Relative_rot = Rotator(25, 90, -90),
    scale = Vector(1.5, 1.5, 1.5),
    bone = "neck_01",
}

local pumpkin2_zombie_attach = TableDeepCopy(pumpkin_zombie_attach)
pumpkin2_zombie_attach.scale = Vector(2, 2, 2)
pumpkin2_zombie_attach.Relative_rot = Rotator(0, 90, -90)


local pumpkin_hellhound_attach = {
    Relative_loc = Vector(0, 0, 0),
    Relative_rot = Rotator(-25, -60, 90),
    scale = Vector(1.5, 1.5, 1.5),
    bone = "Wolf_-Head",
}
local pumpkin2_hellhound_attach = TableDeepCopy(pumpkin_hellhound_attach)
pumpkin2_hellhound_attach.scale = Vector(2, 2, 2)
pumpkin2_hellhound_attach.Relative_rot = Rotator(0, -60, 90)

local PUMPONGUS = {
    Name = "PumpongUs",
    Version = "0.1.0",

    Scripts = {
        Server = {
            "SubModes/Pumpongus/Pumpongus.lua",
            "SubModes/Pumpongus/Voting.lua",
        },
        Client = {
            "SubModes/Pumpongus/cl_PPG_UI.lua",
            "SubModes/Pumpongus/cl_Pumpongus.lua",
            "SubModes/Pumpongus/cl_Voting.lua",
            "SubModes/Pumpongus/cl_GooTentacles.lua",
        },
        Shared = {
            "SubModes/Pumpongus/sh_PPGFuncs.lua",
            "SubModes/Pumpongus/sh_GooTentacles.lua",
        },
    },
    MIN_PLAYERS = 2,
    Config = {
        Discuss_Time_ms = 15000,
        Voting_Time_ms = 30000,
        Results_Time_ms = 5000,

        Voting_Required_Ratio_To_Eliminate = 0.5,

        Random_Head_Attached_SMs = {
            {
                model = "vzombies-assets::SM_Pumpkin_Carved_00",
                Per_Enemy_Config = {
                    Hellhound = pumpkin_hellhound_attach,
                },
            },
            {
                model = "vzombies-assets::SM_Pumpkin_Carved_01",
                Per_Enemy_Config = {
                    Hellhound = pumpkin_hellhound_attach,
                },
            },
            {
                model = "vzombies-assets::SM_Pumpkin_Carved_02",
                Per_Enemy_Config = {
                    Hellhound = pumpkin_hellhound_attach,
                },
            },
            {
                model = "vzombies-assets::SM_Pumpkin_Carved_03",
                Per_Enemy_Config = {
                    Hellhound = pumpkin2_hellhound_attach,
                }
            },
        },

        Pumpkins_On_Ground_Cleanup_Time_s = 60,
        Pumpkins_On_Ground_Pickup_Check_Interval_ms = 1000,
        Pumpkins_On_Ground_Pickup_Distance_sq = 18000,
        Pumpkins_Money_Given_On_Grab = 100,

        Imposter_Sabotage_Cooldown_s = 45,

        Imposter_Sabotage_Duration_s = 60,
        Imposter_Dark_Sabotage_Duration_s = 7,

        Imposter_Sabotage_Check_Classes = {
            "StaticMesh",
            --"Weapon",
        },
        Imposter_Dark_Sabotage_Check_Classes = {
            "Character",
        },
        Imposter_Sabotage_Distance_sq = 450^2,

        Imposter_Min_Round_Activation = 5,

        Tentacles_Sounds = {
            Spawn = {
                asset = "vzombies-assets::SFX_Vefects_Tentacles_Body_Activation_01_Cue",
                volume = 1,
                radius = 500,
                falloff_distance = 4000,
            },
            Explode = {
                asset = "vzombies-assets::SFX_Vefects_Tentacles_Body_Explode_01_Cue",
                volume = 1,
                radius = 500,
                falloff_distance = 4000,
            },
            Loop = {
                asset = {"vzombies-assets::SFX_Vefects_Tentacles_Body_Loop_01_Cue", "vzombies-assets::SFX_Vefects_Tentacles_Body_Loop_02_Cue"}, -- Depending on goo type ID
                volume = 0.5,
                radius = 400,
                falloff_distance = 3000,
                looping = true,
            },
            In = {
                asset = "vzombies-assets::SFX_Vefects_Tentacles_In_01_Cue",
                volume = 1,
                radius = 500,
                falloff_distance = 4000,
            },
            Out = {
                asset = "vzombies-assets::SFX_Vefects_Tentacles_Out_01_Cue",
                volume = 1,
                radius = 500,
                falloff_distance = 4000,
            },
        },

        Imposter_Chosen_Sound = {
            asset = "nanos-world::A_BigHammer_Impact",
            volume = 1,
        },

        Imposter_Activated_Sound = {
            asset = "nanos-world::A_BigHammer_Land",
            volume = 3,
        },

        Imposter_Stats = {
            {
                Name = "Weapon Damage",
                Base = 75,
                Per_Pumpkin = 0.1,
                Per_Bystander = 10,
                Setfunc = function(char, value)
                    if IsValid(char:GetPicked()) and char:GetPicked():IsA(Melee) then
                        char:GetPicked():SetBaseDamage(value)
                        return true
                    end
                end,
            },
            {
                Name = "Life",
                Base = PlayerHealth,
                Per_Pumpkin = 3,
                Per_Bystander = 25,
                Setfunc = function(char, value)
                    char:SetHealth(1000 + value)
                    char:SetMaxHealth(1000 + value)
                    local ply = char:GetPlayer()
                    if (IsValid(ply)) then
                        Events.CallRemote("OverrideUIMaxHealth", ply, value)
                    end
                    return true
                end,
            },
            {
                Name = "Speed Multiplier",
                Base = PlayerSpeedMultiplier,
                Per_Pumpkin = 0.001,
                Per_Bystander = 0.03,
                Setfunc = function(char, value)
                    char:SetSpeedMultiplier(value)
                    return true
                end
            },
        },

        Imposter_Particles = {
            asset = "nanos-world::P_HangingParticulates",
            Parameters = {
                Color = {
                    setter = "SetParameterColor",
                    --value = Color(255, 128, 0),
                    value = Color(87, 0, 191),
                },
            },
            Dynamic_Pumpkins_Parameters = {
                BoxSize = {
                    setter = "SetParameterVector",
                    func = function(pumpkins)
                        local added_per_p = 0.5
                        local size = 30 + added_per_p*pumpkins
                        return Vector(size, size, 96)
                    end
                },
                SpawnRate = {
                    setter = "SetParameterFloat",
                    func = function(pumpkins)
                        local added_per_p = 0.5
                        local srate = 0 + added_per_p*pumpkins
                        return srate
                    end
                },
            },
            Spawn_Timer_Random = {2500, 25000},
            Spawn_Timer_Wait_Next_Timer = function(pumpkins)
                local min_wait = 0
                local base_wait = math.random(120000)
                local removed_per_p = 50
                return math.max(base_wait - pumpkins*removed_per_p, min_wait)
            end,
            Destroy_Timer_Random = {10000, 45000},
        },

        Imposter_Weapon_Name = "Imposter Shovel",
        Imposter_Weapon = function(location, rotation)
            local melee = Melee(location or Vector(), rotation or Rotator(), "nanos-world::SM_Shovel_01", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
            melee:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Slash_Attack")
            melee:SetDamageSettings(0.3, 0.5)
            melee:SetCooldown(1)

            --melee:SetAttachmentSettings(Vector(-83, 17, 49), Rotator(180, 80, 282))
            melee:SetAttachmentSettings(Vector(7, 45, 85), Rotator(150, 80, 360))

            melee:SetValue("CanDamagePlayers", true, false)

            return melee
        end,
    },
    overwrites = {
        Leaderboards = {
            script_loaded = false,
        },
        Vehicles = {
            script_loaded = false,
            can_interact = false,
        },
    },

    HowToPlay_HTML = [[<div class="HTP_title">How to play PumpongUs</div>
    <div class="HTP_text">There is one imposter among us (selected at wave 2), he has a power that he can activate to defeat all of the Bystanders, when he unveils his power there's no turning back</div>
    <center>
    <img src="./pumpongus/images/Pumpongus_Artwork.jpg" height="500"/>
    </center>
    <div class="HTP_category_title">Pumpkins</div>
    <div class="HTP_text">Take pumpkins that fall from enemies to earn money.</div>
    <center>
    <img src="./pumpongus/images/ppg_help_pumpkins.jpg" height="300"/>
    </center>

    <div class="HTP_category_title">Bystanders: finding and eliminating the imposter</div>
    <div class="HTP_text">Between rounds you will be able to vote to eliminate someone, discuss and choose wisely.</div>
    <center>
    <img src="./pumpongus/images/ppg_help_voting.jpg" height="200"/>
    </center>
    <div class="HTP_text">The imposter leaves particles behind him and their settings depends on how much power he has.</div>
    <center>
    <img src="./pumpongus/images/ppg_help_imposter_particles.jpg" height="300"/>
    </center>

    <div class="HTP_category_title">Imposter: build your power with pumpkins until you unveil your true power</div>
    <div class="HTP_text">You need to improve your strength before unveiling but you also need to hide that your are the Imposter.</div>
    <center>
    <img src="./pumpongus/images/ppg_help_imposter_stats.jpg" height="200"/>
    </center>
    <div class="HTP_text">When you activate your power, kill the Bystanders to win the game.</div>
    <center>
    <img src="./pumpongus/images/ppg_help_imposter_power.jpg" height="400"/>
    </center>

    <div class="HTP_category_title">Imposter Sabotage Entity</div>
    <div class="HTP_text">The imposter can spawn an entity to lock buyables for some time, it can block players progression (and can reveal who is the imposter).</div>
    <center>
    <img src="./pumpongus/images/ppg_help_imposter_sabotage.jpg" height="300"/>
    </center>
    <div class="HTP_text">When the imposter activated his power, he gets dark entities that can block players for a small amount of time.</div>
    <center>
    <img src="./pumpongus/images/ppg_help_imposter_dark_sabotage.jpg" height="200"/>
    </center>
    ]],
}


for k, v in pairs(Enemies_Config) do
    if v.Spawning_Config then
        if v.Spawning_Config.type == "zombie_spawns" then
            if not v.Boss then
                for i2, v2 in ipairs(PUMPONGUS.Config.Random_Head_Attached_SMs) do
                    if v2.model ~= "vzombies-assets::SM_Pumpkin_Carved_03" then
                        v2.Per_Enemy_Config[k] = pumpkin_zombie_attach
                    else
                        v2.Per_Enemy_Config[k] = pumpkin2_zombie_attach
                    end
                end
            end
        end
    end
end


VZ_GAMEMODES_CONFIG["PUMPONGUS"] = PUMPONGUS

