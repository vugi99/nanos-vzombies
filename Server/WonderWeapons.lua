
WonderWeapons = {
    Raygun = function(location, rotation)
        local weapon = Weapon(location or Vector(), rotation or Rotator(), "vzombies-assets::raygun")

        weapon:SetAmmoSettings(20, 1000)
        weapon:SetDamage(70)
        weapon:SetSpread(15)
        weapon:SetRecoil(0.6)
        weapon:SetBulletSettings(1, 20000, 5000, Color(0, 125, 0))

        weapon:SetSightTransform(Vector(3, 0, -4.8), Rotator(0, 0, 0))
        weapon:SetLeftHandTransform(Vector(1, -1, -6.5), Rotator(0, 60.46875, 99.84375))
        weapon:SetRightHandOffset(Vector(-30, -3, -2))

        weapon:SetHandlingMode(HandlingMode.SingleHandedWeapon)
        weapon:SetCadence(0.3)
        weapon:SetWallbangSettings(0, 0.25)

        weapon:SetSightFOVMultiplier(0.6)
        weapon:SetUsageSettings(false, false)

        weapon:SetParticlesBulletTrail("nanos-world::P_Bullet_Trail")
        weapon:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")

        weapon:SetSoundDry("nanos-world::A_Pistol_Dry")
        weapon:SetSoundLoad("vzombies-assets::wpn_ray_reload_close")
        weapon:SetSoundUnload("vzombies-assets::wpn_ray_reload_open")
        weapon:SetSoundZooming("nanos-world::A_AimZoom")
        weapon:SetSoundAim("nanos-world::A_Rattle")
        weapon:SetSoundFire("vzombies-assets::ray_shot_f")

        weapon:SetAnimationCharacterFire("nanos-world::A_Mannequin_Sight_Fire_Pistol")
        weapon:SetAnimationReload("nanos-world::AM_Mannequin_Reload_Pistol")

        weapon:SetCrosshairMaterial("nanos-world::MI_Crosshair_Circle")

        return weapon
    end,

    Raygun_mk2 = function(location, rotation)
        local weapon = Weapon(location or Vector(), rotation or Rotator(), "vzombies-assets::raygun_mk2")

        weapon:SetAmmoSettings(10, 1000)
        weapon:SetDamage(40)
        weapon:SetSpread(5)
        weapon:SetRecoil(0.7)
        weapon:SetBulletSettings(3, 20000, 5000, Color(0, 125, 0))

        weapon:SetSightTransform(Vector(4.2, 0, -5), Rotator(0, 0, 0))
        weapon:SetLeftHandTransform(Vector(-8, -1, -6.5), Rotator(0, 60.46875, 99.84375))
        weapon:SetRightHandOffset(Vector(-33, -4, -3.5))

        weapon:SetHandlingMode(HandlingMode.SingleHandedWeapon)
        weapon:SetCadence(0.5)
        weapon:SetWallbangSettings(0, 0.25)

        weapon:SetSightFOVMultiplier(0.6)
        weapon:SetUsageSettings(false, false)

        weapon:SetParticlesBulletTrail("nanos-world::P_Bullet_Trail")
        weapon:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")

        weapon:SetSoundDry("nanos-world::A_Pistol_Dry")
        weapon:SetSoundLoad("vzombies-assets::putin_mk2")
        weapon:SetSoundUnload("vzombies-assets::pullout_mk2")
        weapon:SetSoundZooming("nanos-world::A_AimZoom")
        weapon:SetSoundAim("nanos-world::A_Rattle")
        weapon:SetSoundFire("vzombies-assets::wpn_raygun_mk2_fire")

        weapon:SetAnimationCharacterFire("nanos-world::A_Mannequin_Sight_Fire_Pistol")
        weapon:SetAnimationReload("nanos-world::AM_Mannequin_Reload_Pistol")

        weapon:SetCrosshairMaterial("nanos-world::MI_Crosshair_Circle")

        return weapon
    end,

    --[[Thundergun = function(location, rotation)
        local weapon = Weapon(location or Vector(), rotation or Rotator(), "vzombies-assets::thundergun")

        weapon:SetAmmoSettings(2, 50)
        weapon:SetDamage(1)
        weapon:SetSpread(25)
        weapon:SetRecoil(3)
        weapon:SetBulletSettings(1, 20000, 0, Color(0, 0, 0))

        weapon:SetSightTransform(Vector(10, -14.5, -13.5), Rotator(0, 0, 0))
        weapon:SetLeftHandTransform(Vector(24.1, 0, 9), Rotator(0, 60.46875, 90))
        weapon:SetRightHandOffset(Vector(-18, -9, -15))

        weapon:SetHandlingMode(HandlingMode.DoubleHandedWeapon)
        weapon:SetCadence(0.5)
        weapon:SetWallbangSettings(0, 0.25)

        weapon:SetSightFOVMultiplier(0.6)
        weapon:SetUsageSettings(false, false)

        weapon:SetParticlesBulletTrail("nanos-world::P_Bullet_Trail")
        weapon:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")

        weapon:SetSoundDry("nanos-world::A_Rifle_Dry")
        weapon:SetSoundLoad("vzombies-assets::fly_thundergun_cell_replace")
        weapon:SetSoundUnload("vzombies-assets::fly_thundergun_eject")
        weapon:SetSoundZooming("nanos-world::A_AimZoom")
        weapon:SetSoundAim("nanos-world::A_Rattle")
        weapon:SetSoundFire("vzombies-assets::wpn_thundergun_fire_plr")

        weapon:SetAnimationCharacterFire("nanos-world::AM_Mannequin_Sight_Fire")
        weapon:SetAnimationReload("nanos-world::AM_Mannequin_Reload_Rifle")

        weapon:SetCrosshairMaterial("nanos-world::MI_Crosshair_Regular")

        return weapon
    end,

    Wunderwaffe = function(location, rotation)
        local weapon = Weapon(location or Vector(), rotation or Rotator(), "vzombies-assets::wunderwaffe")

        weapon:SetAmmoSettings(3, 100)
        weapon:SetDamage(50)
        weapon:SetSpread(25)
        weapon:SetRecoil(1.5)
        weapon:SetBulletSettings(1, 20000, 5000, Color(46, 109, 156))

        weapon:SetSightTransform(Vector(9, 0, -2.1), Rotator(0, 0, 0))
        weapon:SetLeftHandTransform(Vector(44.8, 0, -5), Rotator(0, 60.46875, 90))
        weapon:SetRightHandOffset(Vector(-6, -4, 1))

        weapon:SetHandlingMode(HandlingMode.DoubleHandedWeapon)
        weapon:SetCadence(0.4)
        weapon:SetWallbangSettings(0, 0.25)

        weapon:SetSightFOVMultiplier(0.6)
        weapon:SetUsageSettings(false, false)

        weapon:SetParticlesBulletTrail("nanos-world::P_Bullet_Trail")
        weapon:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")

        weapon:SetSoundDry("nanos-world::A_Rifle_Dry")
        weapon:SetSoundLoad("vzombies-assets::tesla_clip_in")
        weapon:SetSoundUnload("vzombies-assets::tesla_start_reload")
        weapon:SetSoundZooming("nanos-world::A_AimZoom")
        weapon:SetSoundAim("nanos-world::A_Rattle")
        weapon:SetSoundFire("vzombies-assets::shot_00_f_dg2")

        weapon:SetAnimationCharacterFire("nanos-world::AM_Mannequin_Sight_Fire")
        weapon:SetAnimationReload("nanos-world::AM_Mannequin_Reload_Rifle")

        weapon:SetCrosshairMaterial("nanos-world::MI_Crosshair_Regular")

        return weapon
    end]]--
}

for k, v in pairs(WonderWeapons) do
    NanosWorldWeapons[k] = v
end

--[[VZ_EVENT_SUBSCRIBE("Weapon", "Fire", function(weap, char)
    if (weap and weap:IsValid() and char and char:IsValid()) then
        local weapon_name = weap:GetValue("WeaponName")
        if weapon_name == "Thundergun" then
            local muzzle_transform = weap:GetBoneTransform("muzzle")
            print(NanosUtils.Dump(muzzle_transform))
            if muzzle_transform then
                if (muzzle_transform.Location and muzzle_transform.Rotation) then
                    
                end
            end
        end
    end
end)]]--