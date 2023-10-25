

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
}

Player_VOIP_Setting_Alive = VOIPSetting.Local

Outline_Players_Enabled = false
Outline_Players_Check_Interval_ms = 1500
Outline_Players_Color = Color.AZURE

Character_RadialDamageToRagdoll = -1