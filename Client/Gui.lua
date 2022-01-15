

-- Render
-- Group 1 : Buy something text
-- Group 2 : Health text

GUI = WebUI("vzombies GUI", "file:///gui/index.html", true, true, true)

ROUND_NB = 0

local HealthText = Render.AddText(2, "", Vector2D(math.floor(Render.GetViewportSize().X * 0.95), 50), 0, 16, Color.GREEN, 0, true, true, false, Vector2D(0, 0), Color.WHITE, false, Color.WHITE)

local PlayersMoney = {}

local Powerups_On_GUI = {}

CurPerks = {}

function IsSelfCharacter(char)
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        if local_char == char then
            return true
        end
    end
    return false
end

function GetPlayersMoneyCopy()
    local tbl = {}
    for i, v in ipairs(PlayersMoney) do
        tbl[i] = {}
        tbl[i].money = v.money
        tbl[i].ply = v.ply
    end
    return tbl
end

function NeedToUpdateAmmoText(char, weapon)
    if IsSelfCharacter(char) then
        GUI:CallEvent("SetAmmoText", tostring(weapon:GetAmmoClip()), tostring(weapon:GetAmmoBag()))
    end
end
Character.Subscribe("Fire", NeedToUpdateAmmoText)
Character.Subscribe("Reload", NeedToUpdateAmmoText)
Character.Subscribe("PickUp", NeedToUpdateAmmoText)
Character.Subscribe("Drop", function(char)
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        if local_char == char then
            GUI:CallEvent("SetAmmoText", "0", "0")
        end
    end
end)
Events.Subscribe("UpdateAmmoText", function()
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        local weap = local_char:GetPicked()
        if weap then
            GUI:CallEvent("SetAmmoText", tostring(weap:GetAmmoClip()), tostring(weap:GetAmmoBag()))
        end
    end
end)

function AddPlayerMoney(ply, money)
    if ply then -- Ghost player appear if i don't do that ?
        GUI:CallEvent("AddPlayerMoney", tostring(money))
        table.insert(PlayersMoney, {ply = ply, money = money})
    end
end

function SetPlayerMoney(ply, money)
    for i, v in ipairs(PlayersMoney) do
        if v.ply == ply then
            if ply == Client.GetLocalPlayer() then
                if money - PlayersMoney[i].money < 0 then
                    local buy_sound = Sound(
                        Vector(0, 0, 0),
                        Buy_Sound.asset,
                        true,
                        true,
                        SoundType.SFX,
                        Buy_Sound.volume
                    )
                end
            end
            GUI:CallEvent("SetPlayerMoney", i-1, tostring(money), tostring(money - PlayersMoney[i].money))
            PlayersMoney[i].money = money
        end
    end
end

function RemovePlayerMoney(ply)
    for i, v in ipairs(PlayersMoney) do
        if v.ply == ply then
            GUI:CallEvent("RemovePlayerMoney", i-1)
            table.remove(PlayersMoney, i)
            break
        end
    end
end

function RemoveAllPlayersMoney()
    for i, v in ipairs(PlayersMoney) do
        GUI:CallEvent("RemovePlayerMoney", 0)
    end
    PlayersMoney = {}
end

function BuildPlayersMoney()
    local local_player = Client.GetLocalPlayer()
    for i2, v2 in pairs(Player.GetPairs()) do
        if v2 ~= local_player then
            local money = v2:GetValue("ZMoney")
            if money then
                AddPlayerMoney(ply, money)
            end
        end
    end
end

Player.Subscribe("ValueChange", function(ply, key, value)
    if key == "ZMoney" then
        local found
        for i, v in ipairs(PlayersMoney) do
            if v.ply == ply then
                if value == nil then
                    RemovePlayerMoney(ply)
                else
                    SetPlayerMoney(ply, value)
                end
                found = true
            end
        end
        if not found then
            local local_player = Client.GetLocalPlayer()
            if ply ~= local_player then
                AddPlayerMoney(ply, value)
            else
                RemoveAllPlayersMoney()
                BuildPlayersMoney()
                AddPlayerMoney(local_player, value)
            end
        end
    end
end)

Player.Subscribe("Destroy", function(ply)
    RemovePlayerMoney(ply)
end)

Client.Subscribe("SpawnLocalPlayer", function()
    RemoveAllPlayersMoney()
    BuildPlayersMoney()
    local ply = Client.GetLocalPlayer()
    local ply_m = ply:GetValue("ZMoney")
    if ply_m then
        AddPlayerMoney(ply, ply_m)
    end
end)

function SetRoundNumber(nb)
    GUI:CallEvent("NewWave", tostring(nb))
    local new_round = Sound(
        Vector(0, 0, 0),
        NewWave_Sound.asset,
        true,
        true,
        SoundType.SFX,
        NewWave_Sound.volume
    )
    ROUND_NB = nb
end

Events.Subscribe("SetClientRoundNumber", function(nb)
    SetRoundNumber(nb)
end)

function InteractText(text)
    Render.ClearItems(1)
    Render.AddText(
        1,
        text,
        (Render.GetViewportSize() / 2) + Vector2D(0, Interact_Text_Y_Offset),
        0,
        20,
        Color.WHITE,
        0,
        true,
        true,
        false,
        Vector2D(),
        Color.WHITE,
        false,
        Color.WHITE
    )
end

function BuyText(buy_name, buy_price)
    InteractText("Buy " .. tostring(buy_name) .. " (" .. tostring(buy_price) .. "$)")
end



Character.Subscribe("TakeDamage", function(char, damage, bone, type, from_direction, instigator, causer)
    if IsSelfCharacter(char) then
        local health = char:GetHealth() - damage - 1000
        Render.UpdateItemText(2, HealthText, tostring(health) .. " HP")
    end
end)

Character.Subscribe("Destroy", function(char)
    if IsSelfCharacter(char) then
        Render.UpdateItemText(2, "")
    end
end)

Events.Subscribe("UpdateGUIHealth", function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        local health = char:GetHealth() - 1000
        Render.UpdateItemText(2, HealthText, tostring(health) .. " HP")
    end
end)

Player.Subscribe("Possess", function(ply, char)
    if ply == Client.GetLocalPlayer() then
        local health = char:GetHealth()
        Render.UpdateItemText(2, HealthText, tostring(PlayerHealth) .. " HP")
    end
end)

function GUIStartRevive(time)
    GUI:CallEvent("StartRevive", tostring(time))
end

function GUIStopRevive()
    GUI:CallEvent("StopRevive")
end

Events.Subscribe("PowerupGrabbed", function(powerup_name)
    PowerupSound(Powerups_Config[powerup_name].sound)
    if (Powerups_Config[powerup_name].icon and not Powerups_On_GUI[powerup_name]) then
        GUI:CallEvent("AddPowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = true
    end
end)

Events.Subscribe("DurationPowerupRemoved", function(powerup_name)
    if Powerups_Config[powerup_name].icon then
        GUI:CallEvent("RemovePowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = nil
    end
end)

Events.Subscribe("RemoveGUIPowerups", function()
    for k, v in pairs(Powerups_Config) do
        if v.icon then
            GUI:CallEvent("RemovePowerup", v.icon)
        end
    end
    Powerups_On_GUI = {}
end)

function GUINewPerk(perk_name)
    GUI:CallEvent("AddPerk", PERKS_CONFIG[perk_name].icon)
end

Character.Subscribe("ValueChange", function(char, key, value)
    if IsSelfCharacter(char) then
        if key == "OwnedPerks" then
            for k, v in pairs(value) do
                local found
                for k2, v2 in pairs(CurPerks) do
                    if k2 == k then
                        found = true
                    end
                end
                if not found then
                    NewPerkSound()
                    GUINewPerk(k)
                end
            end
            if table_count(value) == 0 then
                GUI:CallEvent("ResetPerks")
            end
            CurPerks = value
        end
    end
end)

Character.Subscribe("Destroy", function(char)
    if IsSelfCharacter(char) then
        CurPerks = {}
        GUI:CallEvent("ResetPerks")
    end
end)

if ZDEV_MODE then
    Client.SetHighlightColor(Color(10, 2.5, 0, 2), 0)

    Character.Subscribe("Spawn", function(character)
        character:SetHighlightEnabled(true, 0)
    end)

    for k, v in pairs(StaticMesh.GetPairs()) do
        if v:GetValue("MapPowerHANDLE") then
            print("HADLE")
            v:SetHighlightEnabled(true, 0)
        end
    end
end