

CAMERA_MODE = CameraMode.FPSOnly

Player_Start_Weapon = {
    weapon_name = "M1911",
    ammo = 100
}
PlayerHealth = 100

PlayerRegenHealthAfter_ms = 15000
PlayerRegenInterval_ms = 500
PlayerRegenAddedHealth = 10

PlayerSpeedMultiplier = 1.5

Player_Capsule_Size = {38, 96}

PlayerDeadAfterTimerDown_ms = 30000
ReviveTime_ms = 5000

Player_Down_Animation = "vzombies-assets::Death_Idle"

Player_Models = {
    Mannequin = {
        Random_Parameters = {
            {
                type = "Color",
                name = "Tint",
            },
        },
        Models = {
            "nanos-world::SK_Mannequin"
        },
        gender = "male",
    },
    Mannequin_F = {
        Random_Parameters = {
            {
                type = "Color",
                name = "Tint",
            },
        },
        Models = {
            "nanos-world::SK_Mannequin_Female"
        },
        gender = "female",
    },
    PostApocalyptic = {
        Models = {
            "nanos-world::SK_PostApocalyptic"
        },
        gender = "male",
    },
    Adventure_M = {
        Models = {
            "nanos-world::SK_Adventure_02_Full_01",
            "nanos-world::SK_Adventure_02_Full_02",
            "nanos-world::SK_Adventure_02_Full_03",
            "nanos-world::SK_Adventure_04_Full_01",
            "nanos-world::SK_Adventure_04_Full_02",
            --"nanos-world::SK_Adventure_05_Full_01",
            "nanos-world::SK_Adventure_05_Full_02",
        },
        gender = "male",
    },
    Adventure_F = {
        Models = {
            --"nanos-world::SK_Adventure_01_Full_01",
            "nanos-world::SK_Adventure_01_Full_02",
            "nanos-world::SK_Adventure_03_Full_01",
            "nanos-world::SK_Adventure_03_Full_02",
        },
        gender = "female",
    }
}

Player_Local_VOIP_Setting_Alive = VOIPSetting.Both

Outline_Players_Enabled = false
Outline_Players_Check_Interval_ms = 1500
Outline_Players_Color = Color.AZURE

Character_RadialDamageToRagdoll = -1