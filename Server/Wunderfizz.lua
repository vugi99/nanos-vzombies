

SM_Wunderfizzes = {}
Active_Wunderfizz_ID = nil
local Wunderfizz_Bought_Timeout
local Wunderfizz_Finished_Waiting_Timeout
local Wunderfizz_Fake_Bottles_Interval
local Wunderfizz_Particle_Ref

if MAP_WUNDERFIZZ then
    for k, v in pairs(MAP_WUNDERFIZZ) do
        local Wunder_SM = StaticMesh(
            v.location,
            v.rotation,
            "vzombies-assets::wunderfizz_body"
        )
        table.insert(SM_Wunderfizzes, {body = Wunder_SM})
    end
end

function ResetRunningWunderfizzStage1()
    if SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle then
        SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:Destroy()
        SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle = nil
    end

    if (Wunderfizz_Particle_Ref and Wunderfizz_Particle_Ref:IsValid()) then
        Wunderfizz_Particle_Ref:Destroy()
    end
    Wunderfizz_Particle_Ref = nil

    Timer.ClearTimeout(Wunderfizz_Bought_Timeout)
    Wunderfizz_Bought_Timeout = nil

    Timer.ClearInterval(Wunderfizz_Fake_Bottles_Interval)
    Wunderfizz_Fake_Bottles_Interval = nil
end

function ResetRunningWunderfizzStage2()
    if SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle then
        SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:Destroy()
        SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle = nil
    end

    SM_Wunderfizzes[Active_Wunderfizz_ID].body:SetValue("CanBuyWunder", true, true)

    Timer.ClearTimeout(Wunderfizz_Finished_Waiting_Timeout)
    Wunderfizz_Finished_Waiting_Timeout = nil
end

function ResetWunderfizz(id)
    SM_Wunderfizzes[id].body:SetValue("CanBuyWunder", nil, true)
    SM_Wunderfizzes[id].ball:Destroy()
    SM_Wunderfizzes[id].ball = nil

    if Wunderfizz_Bought_Timeout then
        ResetRunningWunderfizzStage1()
    elseif Wunderfizz_Finished_Waiting_Timeout then
        ResetRunningWunderfizzStage2()
    end

    Active_Wunderfizz_ID = nil
end

function ResetWunderfizzes()
    if Active_Wunderfizz_ID then
        ResetWunderfizz(Active_Wunderfizz_ID)
    end
end

function PickNewWunderfizz()
    local pick_tbl = {}
    for i, v in ipairs(SM_Wunderfizzes) do
        if not v.ball then
            table.insert(pick_tbl, i)
        end
    end

    if table_count(pick_tbl) > 0 then -- If theres more than 1 wunder on the map
        local random_pick_id = math.random(table_count(pick_tbl))
        local random_pick = SM_Wunderfizzes[pick_tbl[random_pick_id]]

        if Active_Wunderfizz_ID then
            ResetWunderfizz(Active_Wunderfizz_ID)
        end

        random_pick.ball = StaticMesh(
            random_pick.body:GetLocation(),
            random_pick.body:GetRotation(),
            "vzombies-assets::wunderfizz_ball"
        )
        random_pick.ball:SetCollision(CollisionType.NoCollision)
        random_pick.body:SetValue("CanBuyWunder", true, true)

        Active_Wunderfizz_ID = pick_tbl[random_pick_id]
    end
end

function FakeBottleInterval()
    if SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle then
        SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:Destroy()
    end
    local random_pick_id = math.random(table_count(PERKS_CONFIG))
    local random_pick
    local count = 0
    for k, v in pairs(PERKS_CONFIG) do
        count = count + 1
        if random_pick_id == count then
            random_pick = v
            break
        end
    end
    SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle = StaticMesh(
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset,
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetRotation(),
        random_pick.bottle_asset
    )
    SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:SetCollision(CollisionType.NoCollision)
    SM_Wunderfizzes[Active_Wunderfizz_ID].fake_bottle:SetScale(Vector(0.01, 0.01, 0.01))
end

function OpenActiveWunderfizz(char)
    SM_Wunderfizzes[Active_Wunderfizz_ID].body:SetValue("CanBuyWunder", false, true)

    Wunderfizz_Particle_Ref = Particle(
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Particle_Offset,
        SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetRotation(),
        Wonderfizz_Particle,
        false,
        true -- Auto Activate?
    )

    Wunderfizz_Bought_Timeout = Timer.SetTimeout(function()
        ResetRunningWunderfizzStage1()

        local random_move = math.random(100)
        if (random_move <= Wonderfizz_Move_Percentage and table_count(SM_Wunderfizzes) > 1) then
            local players_sound = GetPlayersInRadius(SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset, Wunderfizz_leave_Sound.falloff_distance)
            for k, v in pairs(players_sound) do
                Events.CallRemote("PlayVZSound", v, {basic_sound_tbl=Wunderfizz_leave_Sound}, SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset)
            end

            PickNewWunderfizz()
        else
            local pick_tbl = {}
            local char_perks = char:GetValue("OwnedPerks")

            for k, v in pairs(PERKS_CONFIG) do
                if not char_perks[k] then
                    table.insert(pick_tbl, k)
                end
            end

            if table_count(pick_tbl) > 0 then
                local perk_selected = pick_tbl[math.random(table_count(pick_tbl))]

                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle = Prop(
                    SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetLocation() + Wonderfizz_Bottles_Offset,
                    SM_Wunderfizzes[Active_Wunderfizz_ID].body:GetRotation(),
                    PERKS_CONFIG[perk_selected].bottle_asset
                )
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetCollision(CollisionType.NoCollision)
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetScale(Vector(0.01, 0.01, 0.01))
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetGravityEnabled(false)
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetGrabMode(GrabMode.Disabled)
                SM_Wunderfizzes[Active_Wunderfizz_ID].real_bottle:SetValue("RealBottleData", {char:GetID(), perk_selected}, true)

                Wunderfizz_Finished_Waiting_Timeout = Timer.SetTimeout(function()
                    ResetRunningWunderfizzStage2()
                end, Wonderfizz_Real_Bottle_Destroyed_After_ms)
            end
        end
    end, Wonderfizz_Real_Bottle_After_ms)

    Wunderfizz_Fake_Bottles_Interval = Timer.SetInterval(function()
        FakeBottleInterval()
    end, Wonderfizz_Fake_Bottle_Interval_ms)
    FakeBottleInterval()
end

VZ_EVENT_SUBSCRIBE_REMOTE("TakeWunderfizzPerk", function(ply, bottle)
    if ply:IsValid() then
        if ply:GetValue("ZMoney") ~= -666 then
            local char = ply:GetControlledCharacter()
            if char then
                if not char:GetValue("PlayerDown") then
                    if bottle then
                        if bottle:IsValid() then
                            local wunder_bottle = bottle:GetValue("RealBottleData")
                            if wunder_bottle then
                                if wunder_bottle[1] == char:GetID() then
                                    local char_perks = char:GetValue("OwnedPerks")
                                    if not char_perks[wunder_bottle[2]] then
                                        ResetRunningWunderfizzStage2()

                                        GiveCharacterPerk(char, wunder_bottle[2])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("BuyWunderfizz", function(ply, SM_Wunder)
    if (SM_Wunder and SM_Wunder:IsValid()) then
        if ply:GetValue("ZMoney") ~= -666 then
            local char = ply:GetControlledCharacter()
            if char then
                if not char:GetValue("PlayerDown") then
                    local can_buy_wunder = SM_Wunder:GetValue("CanBuyWunder")
                    if can_buy_wunder then
                        if Active_Wunderfizz_ID then
                            if table_count(char:GetValue("OwnedPerks")) < table_count(PERKS_CONFIG) then
                                if Buy(ply, Wonderfizz_Price) then
                                    OpenActiveWunderfizz(char)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

