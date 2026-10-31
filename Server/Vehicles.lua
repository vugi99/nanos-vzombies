
VEHICLE_PADS_SMs = {}

function SpawnVehicle(veh_name, location, rotation)
    local veh = VZVehicles[veh_name](location, rotation)
    veh:SetCollision(CollisionType.IgnoreOnlyPawn)
    veh:SetValue("VehName", veh_name, true)
    veh:SetValue("AR_Multiplier", VZVehicles[veh_name].AR_Multiplier, false)
    veh:SetValue("Damage_Radius_sq_Mult", VZVehicles[veh_name].Damage_Radius_sq_Mult, false)
    --veh:SetValue("VehHealth", VZVehicles[veh_name].health, true)
    veh:SetMaxHealth(VZVehicles[veh_name].health)
    veh:SetHealth(VZVehicles[veh_name].health)

    return veh
end

-- Used when the map requires vehicles
function LoadNanosVehicles()
    if not NanosWorldVehicles then
        local success = Server.LoadPackage("default-vehicles")
        if not success then return Console.Warn("Couldn't load default-vehicles") end
        if not NanosWorldVehicles then return error("Loaded default-vehicles but NanosWorldVehicles is invalid?") end
        ParseAndInjectVehicles(NanosWorldVehicles)
    else
        ParseAndInjectVehicles(NanosWorldVehicles)
    end
end

if VEHICLES_PADS then
    LoadNanosVehicles()

    for i, v in ipairs(VEHICLES_PADS) do
        local veh_pad = StaticMesh(v.location, v.rotation, "vzombies-assets::station_low")
        veh_pad:SetScale(Vector(1, 0.5, 0.5))

        local veh_pad_terminal = StaticMesh(v.location + v.rotation:GetRightVector() * 252, v.rotation, "vzombies-assets::terminal")

        --local veh_pad_screen = StaticMesh(v.location + v.rotation:GetRightVector() * 252, v.rotation, "vzombies-assets::ecran1")

        veh_pad_terminal:SetValue("VehiclePad", i, true)
        veh_pad_terminal:SetValue("GroundPad", veh_pad, false)

        --local debug_trigger = Trigger(v.location + Vector(0, 0, 100), v.rotation, Vector(500, 250, 300), TriggerType.Box, true, Color.RED)

        VEHICLE_PADS_SMs[i] = {veh_pad, veh_pad_terminal}
    end

    VZ_EVENT_SUBSCRIBE_REMOTE("BuyVehicle", function(ply, InteractThing, veh_name)
        if (ply and ply:IsValid()) then
            --print("BuyVehicle", ply:GetAccountName(), InteractThing, veh_name)
            if type(InteractThing) == "number" then
                --print(VEHICLE_PADS_SMs, NanosTable.Dump(VEHICLE_PADS_SMs[InteractThing]))
                local pad = VEHICLE_PADS_SMs[InteractThing]
                if pad then
                    InteractThing = pad[2]
                end
                if not POWER_ON then
                    Events.CallRemote("AddNotification", ply, Reliability.Reliable, "No Power")
                    return
                end
            end
            if (InteractThing and IsValid(InteractThing) and InteractThing:GetValue("VehiclePad")) then
                if InteractThing:GetValue("PPG_Sabotaged") then
                    return
                end

                local veh_pad_ground = InteractThing:GetValue("GroundPad")
                if veh_pad_ground then
                    local char = ply:GetControlledCharacter()
                    if char then
                        if (not char:GetValue("PlayerDown") and not char:GetVehicle()) then
                            if VZVehicles[veh_name] then
                                local is_occupied = CheckIfEntityInRectangle(VehicleWheeled, veh_pad_ground:GetLocation() + Vector(0, 0, 100), veh_pad_ground:GetRotation(), Vector(500, 250, 300)) or CheckIfEntityInRectangle(Character, veh_pad_ground:GetLocation() + Vector(0, 0, 100), veh_pad_ground:GetRotation(), Vector(500, 250, 300))
                                if is_occupied then
                                    Events.CallRemote("AddNotification", ply, Reliability.Reliable, "Cannot Spawn Vehicle")
                                    return
                                else
                                    if Buy(ply, VZVehicles[veh_name].price) then
                                        SpawnVehicle(veh_name, veh_pad_ground:GetLocation() + Vector(0, 0, 100), veh_pad_ground:GetRotation())
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    --[[VZ_EVENT_SUBSCRIBE("VehicleWheeled", "TakeDamage", function(veh, damage, bone, dtype, from_direction, instigator, causer)
        if veh:IsDead() then return end
        print(veh, damage, bone, dtype, from_direction, instigator, causer)
    end)]]--

    local loaded = Server.LoadPackage("webui3d2d")
    if not loaded then
        Console.Warn("Missing webui3d2d package, running in compatibility mode")
    end
end

VZ_EVENT_SUBSCRIBE("Character", "AttemptEnterVehicle", function(char, veh, seat)
    if char:GetValue("PlayerDown") then return false end

    if char:GetValue("ChargingChargerID") then return false end

    local picked = char:GetPicked()
    if picked then
        if (picked:IsA(Grenade) or picked:IsA(Melee)) then
            return false
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "EnterVehicle", function(char, veh, seat)
    if veh:GetCollision() == CollisionType.IgnoreOnlyPawn then
        veh:SetCollision(CollisionType.Normal)
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "LeaveVehicle", function(char, veh)
    --print("Set")
    veh:SetCollision(CollisionType.IgnoreOnlyPawn)
end)

function DestroyVehicles()
    for k, v in pairs(VehicleWheeled.GetAll()) do
        if v:IsValid() then
            v:Destroy()
        end
    end
end