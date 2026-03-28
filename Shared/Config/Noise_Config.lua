
-- At falloff, less than 0.01 : 1/100
function VZ_InverseAttenuation(dist_m_rad, falloff_m_rad)
    return 1 / (1 + ((dist_m_rad*99)/falloff_m_rad))
end
Package.Export("VZ_InverseAttenuation", VZ_InverseAttenuation)

function VZ_LinearAttenuation(dist_m_rad, falloff_m_rad)
    return 1 - (dist_m_rad/falloff_m_rad)
end
Package.Export("VZ_LinearAttenuation", VZ_LinearAttenuation)

-- Weird convex curve above linear Attenuation
--[[
function VZ_LogarithmicAttenuation(dist_m_rad, falloff_m_rad)
    return math.log(2 - dist_m_rad/falloff_m_rad, 2)
end
Package.Export("VZ_LogarithmicAttenuation", VZ_LogarithmicAttenuation)
]]--

local tho_factor = 6
function VZ_ExponentialAttenuation(dist_m_rad, falloff_m_rad)
    return math.exp(-((tho_factor*dist_m_rad)/falloff_m_rad))
end
Package.Export("VZ_ExponentialAttenuation", VZ_ExponentialAttenuation)

-- Start : Inverse, End : Logarithmic
function VZ_NaturalAttenuation(dist_m_rad, falloff_m_rad)
    local fact = dist_m_rad/falloff_m_rad
    local fact_2 = 1 - fact
    return fact_2*VZ_InverseAttenuation(dist_m_rad, falloff_m_rad) + fact*VZ_ExponentialAttenuation(dist_m_rad, falloff_m_rad)
end
Package.Export("VZ_NaturalAttenuation", VZ_NaturalAttenuation)

Noise_Config = {
    Events = {
        GaitModeChangeWalking = {
            classname = "Character",
            name = "GaitModeChange",
            causer_arg_index = 1,
            new_value_index = 3,
            expected_new_value = GaitMode.Walking,

            LoopingNoise = {
                Noise = {
                    Amount = 1,
                    Radius = 400,
                    Falloff = 3000,
                    Falloff_Func = VZ_NaturalAttenuation,
                },

                Interval_ms = 1000,
                Stop = true,
            }
        },

        GaitModeChangeSprinting = {
            classname = "Character",
            name = "GaitModeChange",
            causer_arg_index = 1,
            new_value_index = 3,
            expected_new_value = GaitMode.Sprinting,

            LoopingNoise = {
                Noise = {
                    Amount = 5,
                    Radius = 600,
                    Falloff = 4000,
                    Falloff_Func = VZ_NaturalAttenuation,
                },

                Interval_ms = 1000,
                Stop = true,
            }
        },

        StanceModeChange = {
            classname = "Character",
            name = "StanceModeChange",
            causer_arg_index = 1,
            new_value_index = 3,
            new_value_tables = {
                --[[[StanceMode.None] = {
                    Set_Instigator_Values = {
                        Noise_Multiplier = 0,
                    },
                },]]--
                [StanceMode.Standing] = {
                    Set_Instigator_Values = {
                        Noise_Multiplier = 1,
                    },
                },
                [StanceMode.Crouching] = {
                    Set_Instigator_Values = {
                        Noise_Multiplier = 0.5,
                    },
                },
                [StanceMode.Proning] = {
                    Set_Instigator_Values = {
                        Noise_Multiplier = 0.4,
                    },
                },
            },

            Noise = {
                Amount = 3,
                Radius = 500,
                Falloff = 3500,
                Falloff_Func = VZ_NaturalAttenuation,
            },
        },

        Fire = {
            classname = "Character",
            name = "Fire",
            causer_arg_index = 1,

            Noise = {
                Amount = 100,
                Radius = 2000,
                Falloff = 60000,
                Falloff_Func = VZ_NaturalAttenuation,
            },
        },

        ReloadStart = {
            classname = "Character",
            name = "AttemptReload",
            causer_arg_index = 1,

            Noise = {
                Amount = 3,
                Radius = 500,
                Falloff = 3500,
                Falloff_Func = VZ_NaturalAttenuation,
            },
        },

        ReloadEnd = {
            classname = "Character",
            name = "Reload",
            causer_arg_index = 1,

            Noise = {
                Amount = 5,
                Radius = 500,
                Falloff = 4500,
                Falloff_Func = VZ_NaturalAttenuation,
            },
        },

        VOIP = {
            classname = "Player",
            name = "VOIP",
            instigator_arg_index = 1,
            new_value_index = 2,
            expected_new_value = true,

            LoopingNoise = {
                Noise = {
                    Amount = 10,
                    Radius = 600,
                    Falloff = 5000,
                    Falloff_Func = VZ_NaturalAttenuation,
                },

                Interval_ms = 1000,
                Stop = true,
            }
        },

        FallingModeChangeJumping = {
            classname = "Character",
            name = "FallingModeChange",
            causer_arg_index = 1,
            new_value_index = 3,
            expected_new_value = FallingMode.Jumping,

            Noise = {
                Amount = 3,
                Radius = 400,
                Falloff = 3000,
                Falloff_Func = VZ_NaturalAttenuation,
            },
        },

        FallingModeChangeNone = {
            classname = "Character",
            name = "FallingModeChange",
            causer_arg_index = 1,
            new_value_index = 3,
            expected_new_value = FallingMode.None,

            Noise = {
                Amount = 7,
                Radius = 600,
                Falloff = 4500,
                Falloff_Func = VZ_NaturalAttenuation,
            },
        },
    },
}