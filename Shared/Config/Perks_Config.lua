

PERKS_CONFIG = {
    juggernog = {
        Name = "Juggernog",
        price = 2500,
        PlayerHealth = 250,
        Asset = "vzombies-assets::juggernog",
        scale = Vector(1.5, 1.5, 1.5),
        bottle_asset = "vzombies-assets::jugg_bottle",
        icon = "images/Juggernog_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_jugganog_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    quick_revive = {
        Name = "Quick Revive",
        price = 1500,
        ReviveTime_ms = 2500,
        Solo_ReviveTime_ms = 10000,
        Asset = "vzombies-assets::revive",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::revive_bottle",
        icon = "images/Quick_Revive_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_revive_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    doubletap = {
        Name = "Double Tap",
        price = 2000,
        MultDamage = 1.33,
        Asset = "vzombies-assets::doubletap",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::doubletap_bottle",
        icon = "images/Doubletap_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_doubletap_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    three_gun = {
        Name = "Three Gun",
        price = 4000,
        Asset = "vzombies-assets::three_gun",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::three_gun_bottle",
        icon = "images/three_gun_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_mulekick_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    stamin_up = {
        Name = "Stamin-Up",
        price = 2000,
        Speed_Multiplier = 1.6,
        Asset = "vzombies-assets::stamin_up",
        scale = Vector(1, 1, 1),
        bottle_asset = "vzombies-assets::stamin_up_bottle",
        icon = "images/StaminUp_icon.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_stamin_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
    speed_cola = {
        Name = "Speed Cola",
        price = 3000,
        Reload_Speed_Timescale = 1.3,
        Asset = "vzombies-assets::speed_cola",
        scale = Vector(0.01, 0.01, 0.01),
        bottle_asset = "vzombies-assets::speed_cola_bottle",
        icon = "images/speed_cola_icon_fix.png",
        Amb_Sound = {
            asset = "vzombies-assets::mus_speed_jingle",
            volume = 1,
            radius = 200,
            falloff_distance = 1500,
        },
    },
}

-- Gone since nanos removed proning
Prone_Perk_Config = {
    enabled = true,
    money = 100,
    Rel_Rot_Between = {60, 120},
    Max_Distance_sq = 40000,
}