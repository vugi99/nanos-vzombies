

Powerup_Check_Grab_Interval_ms = 200
Powerup_Grab_Distance_Squared = 5625

Powerup_Delete_after_ms = 20000

Powerups_particle_path = "vzombies-assets::PS_Powerup"

Powerup_Spawn_Percentage = 2 -- x powerups for 100 zombies killed

Powerups_Names = {
    "carpenter",
    "max_ammo",
    "nuke",
    "instakill",
    "x2",
    "death_machine",
}

Powerups_Config = {
    carpenter = {
        repair_interval_ms = 500,
        money_won = 200,
        sound = Carpenter_Sound,
        SM_Path = "vzombies-assets::carpenter",
    },
    max_ammo = {
        sound = MaxAmmo_Sound,
        SM_Path = "vzombies-assets::max_ammo",
    },
    nuke = {
        money_won = 400,
        sound = Nuke_Sound,
        SM_Path = "vzombies-assets::nuke",
    },
    instakill = {
        duration = 30000,
        sound = Instakill_Sound,
        icon = "images/instakill_icon.png",
        SM_Path = "vzombies-assets::instakill",
    },
    x2 = {
        duration = 30000,
        sound = x2_Sound,
        icon = "images/x2_icon_fixed.png",
        SM_Path = "vzombies-assets::x2",
    },
    death_machine = {
        duration = 30000,
        minigun_weapon_name = "modern_weapons Minigun",
        minigun_clip = 10000,
        sound = death_machine_Sound,
        icon = "images/death_machine_icon.png",
        SM_Path = "vzombies-assets::minigun",
    },
}