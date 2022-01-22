

-- Render
-- Group 1 : Buy something text
-- Group 2 : Health text
-- Group 3 : How to play text
-- Group 4 : Zombies Remaining Text
-- Group 5 : ZDEV_MODE
-- Group 6 : Waiting For Slot text
-- Group 7 : Spectating : player text
-- Group 10-? : Player names

Input.Register("How to play", "H")

for i = 1, 7 do
    Render.ClearItems(i)
end

GUI = WebUI("vzombies GUI", "file:///gui/index.html", true, true, true)

ROUND_NB = 0

local HealthText = Render.AddText(2, "", Vector2D(math.floor(Render.GetViewportSize().X * 0.95), 50), 0, 16, Color.GREEN, 0, true, true, false, Vector2D(0, 0), Color.WHITE, false, Color.WHITE)

local HTP_Showed = false
local HTP_Text = Render.AddText(3, "How to play (" .. Input.GetMappedKey("How to play") .. ")", Vector2D(math.floor(Render.GetViewportSize().X * 0.5), math.floor(Render.GetViewportSize().Y * 0.5)), 0, 25, Color.WHITE, 0, true, true, false, Vector2D(0, 0), Color.WHITE, false, Color.WHITE)
Timer.SetTimeout(function()
    Render.ClearItems(3)
    HTP_Text = nil
end, How_To_Play_Text_Destroy_ms)

if ZDEV_CONFIG.ENABLED then
    Render.AddText(5, "VZ DEV MODE", Vector2D(math.floor(Render.GetViewportSize().X * 0.5), 10), 0, 16, Color.RED, 0, true, true, false, Vector2D(0, 0), Color.WHITE, false, Color.WHITE)
end

local PlayersMoney = {}

local Powerups_On_GUI = {}

CurPerks = {}

local RequestedTabData = false
local Tab_Open = false

Remaining_Zombies_RenderItem = nil
if Remaining_Zombies_Text then
    Remaining_Zombies_RenderItem = Render.AddText(4, "Remaining Zombies : 0", Vector2D(135, math.floor(Render.GetViewportSize().Y * 0.04)), 0, 14, Color.WHITE, 0, true, true, false, Vector2D(0, 0), Color.WHITE, false, Color.WHITE)
end

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
        if (not NanosUtils.IsA(weapon, Grenade) and not NanosUtils.IsA(weapon, Melee)) then
            GUI:CallEvent("SetAmmoText", tostring(weapon:GetAmmoClip()), tostring(weapon:GetAmmoBag()))
        end
    end
end
VZ_EVENT_SUBSCRIBE("Character", "Fire", NeedToUpdateAmmoText)
VZ_EVENT_SUBSCRIBE("Character", "Reload", NeedToUpdateAmmoText)
VZ_EVENT_SUBSCRIBE("Character", "PickUp", NeedToUpdateAmmoText)
VZ_EVENT_SUBSCRIBE("Character", "Drop", function(char)
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        if local_char == char then
            GUI:CallEvent("SetAmmoText", "0", "0")
        end
    end
end)
VZ_EVENT_SUBSCRIBE("Events", "UpdateAmmoText", function()
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
        local is_self = false
        if (Client.GetLocalPlayer() and ply == Client.GetLocalPlayer()) then
            is_self = true
        end
        GUI:CallEvent("AddPlayerMoney", tostring(money), is_self)
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


function PlyMoneyChangeCheck(ply, key, value)
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
end
VZ_EVENT_SUBSCRIBE("Player", "ValueChange", PlyMoneyChangeCheck)
VZ_EVENT_SUBSCRIBE("VZBot", "ValueChange", PlyMoneyChangeCheck)

VZ_EVENT_SUBSCRIBE("Player", "Destroy", function(ply)
    RemovePlayerMoney(ply)
end)

RemoveAllPlayersMoney()
BuildPlayersMoney()
local _ply = Client.GetLocalPlayer()
local ply_m = _ply:GetValue("ZMoney")
if ply_m then
    AddPlayerMoney(_ply, ply_m)
end

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
    local NewDRP_Config = {}
    if DRP_Enabled then
        for k, v in pairs(DRP_CONFIG) do
            if k ~= large_image then
                NewDRP_Config[k] = v:gsub("{ROUND_NB}", tostring(ROUND_NB))
                local map_name = Client.GetMap()
                NewDRP_Config[k] = NewDRP_Config[k]:gsub("{MAP_NAME}", split_str(map_name, ":")[2])
            else
                NewDRP_Config[k] = v
            end
        end
        Client.SetDiscordActivity(NewDRP_Config.state, NewDRP_Config.details, NewDRP_Config.large_image, NewDRP_Config.large_text)
    end
end

VZ_EVENT_SUBSCRIBE("Events", "SetClientRoundNumber", function(nb)
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


VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, dtype, from_direction, instigator, causer)
    if IsSelfCharacter(char) then
        local health = char:GetHealth() - damage - 1000
        Render.UpdateItemText(2, HealthText, tostring(health) .. " HP")
        if (health <= LowHealth_Trigger_Health and health > 0) then
            if not Playing_LowHealth_Sound then
                PlayLowHealthLoop()
            end
        end
        if dtype == DamageType.Punch then
            PlayPlayerHurtSound()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if IsSelfCharacter(char) then
        Render.UpdateItemText(2, "")
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "UpdateGUIHealth", function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        local health = char:GetHealth() - 1000
        Render.UpdateItemText(2, HealthText, tostring(health) .. " HP")
        if (Playing_LowHealth_Sound and health > LowHealth_Trigger_Health) then
            PlayExitLowHealthSound()
            StopLowHealthLoop()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
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

VZ_EVENT_SUBSCRIBE("Events", "PowerupGrabbed", function(powerup_name)
    PowerupSound(Powerups_Config[powerup_name].sound)
    if (Powerups_Config[powerup_name].icon and not Powerups_On_GUI[powerup_name]) then
        GUI:CallEvent("AddPowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = true
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "DurationPowerupRemoved", function(powerup_name)
    if Powerups_Config[powerup_name].icon then
        GUI:CallEvent("RemovePowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = nil
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "RemoveGUIPowerups", function()
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

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
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

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if IsSelfCharacter(char) then
        CurPerks = {}
        GUI:CallEvent("ResetPerks")
    end
end)

Input.Register("Scoreboard", "Tab")

VZ_BIND("Scoreboard", InputEvent.Pressed, function()
    if (not RequestedTabData and not Tab_Open) then
        RequestedTabData = true
        Events.CallRemote("RequestTabData")
    end
end)

VZ_BIND("Scoreboard", InputEvent.Released, function()
    if Tab_Open then
        GUI:CallEvent("HideTab")
        Tab_Open = false
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "TabData", function(tab_data)
    Tab_Open = true
    GUI:CallEvent("ShowTab", JSON.stringify(tab_data))
    RequestedTabData = false
end)

function UpdateGrenadesNB(nb)
    GUI:CallEvent("SetGrenadesNB", nb)
end

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if IsSelfCharacter(char) then
        if key == "ZGrenadesNB" then
            UpdateGrenadesNB(value)
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if IsSelfCharacter(char) then
        UpdateGrenadesNB(0)
    end
end)


Input.Bind("How to play", InputEvent.Pressed, function()
    HTP_Showed = not HTP_Showed
    Client.SetMouseEnabled(HTP_Showed)
    Client.SetInputEnabled(not HTP_Showed)
    if HTP_Showed then
        GUI:CallEvent("ShowHTPFrame")
        GUI:BringToFront()
        GUI:SetFocus()
    else
        GUI:CallEvent("HideHTPFrame")
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "SetClientRemainingZombies", function(remaining)
    if Remaining_Zombies_RenderItem then
        Render.UpdateItemText(4, Remaining_Zombies_RenderItem, "Remaining Zombies : " .. tostring(remaining))
    end
end)


local groups_texts = {}

function Calculate_Head_Text_Vector(char_loc)
    local project = Render.Project(char_loc + Vector(0, 0, 97))
    if (project and project ~= Vector2D(-1, -1)) then
        return project
    end
end

VZ_EVENT_SUBSCRIBE("Client", "Tick", function(ds)
    if Player_Names_On_Heads then
        local self_char = Client.GetLocalPlayer():GetControlledCharacter()
        local self_loc
        if self_char then
            self_loc = self_char:GetLocation()
        elseif Spectating_Player then
            local specing_char = Spectating_Player:GetControlledCharacter()
            if specing_char then
                self_loc = specing_char:GetLocation()
            end
        else
            self_loc = Client.GetLocalPlayer():GetCameraLocation()
        end
        for k, v in pairs(groups_texts) do
            local remove_group = true
            if v.char:IsValid() then
                local char_loc = v.char:GetLocation()
                local dist_sq = self_loc:DistanceSquared(char_loc)
                if dist_sq <= Player_Name_Displayed_at_dist_sq then
                    local Vector_head_text = Calculate_Head_Text_Vector(char_loc)
                    if Vector_head_text then
                        remove_group = false
                        Render.UpdateItemPosition(v.group_id, v.item_id, Vector_head_text)
                    end
                end
            end
            if remove_group then
                Render.ClearItems(v.group_id)
                groups_texts[k] = nil
            end
        end
        for k, v in pairs(Character.GetPairs()) do
            local ply = v:GetPlayer()
            if ply then
                if ply ~= Client.GetLocalPlayer() then
                    local is_already_on_screen = false
                    for k2, v2 in pairs(groups_texts) do
                        if v2.char == v then
                            is_already_on_screen = true
                            break
                        end
                    end
                    if not is_already_on_screen then
                        local char_loc = v:GetLocation()
                        local dist_sq = self_loc:DistanceSquared(char_loc)
                        if dist_sq <= Player_Name_Displayed_at_dist_sq then
                            local Vector_head_text = Calculate_Head_Text_Vector(char_loc)
                            if Vector_head_text then
                                local head_text_last_count = table_last_count(groups_texts)
                                groups_texts[head_text_last_count + 1] = {
                                    char = v,
                                    group_id = head_text_last_count + 10,
                                    item_id = Render.AddText(
                                        head_text_last_count + 10,
                                        ply:GetAccountName(),
                                        Vector_head_text,
                                        FontType.Roboto,
                                        16,
                                        Color.AZURE,
                                        0,
                                        true,
                                        true,
                                        false,
                                        Vector2D(0, 0),
                                        Color.WHITE,
                                        true,
                                        Color.BLACK
                                    ),
                                }
                            end
                        end
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Package", "Unload", function()
    for k, v in pairs(groups_texts) do
        Render.ClearItems(v.group_id)
    end
end)

if ZDEV_IsModeEnabled("ZDEV_DEBUG_HIGHLIGHT_ZOMBIES") then
    local highlight_color = Color(10, 2.5, 0)
    Client.SetHighlightColor(highlight_color, 0, HighlightMode.Always)

    VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
        if key == "ZombieType" then
            if value then
                char:SetHighlightEnabled(true, 0)
            end
        end
    end)

    for k, v in pairs(Character.GetPairs()) do
        if v:GetValue("ZombieType") then
            v:SetHighlightEnabled(true, 0)
        end
    end
end

function HandlePlayerWaitingValue(value)
    --print("HandlePlayerWaitingValue PlayerWaiting", value)
    if value then
        Render.AddText(6, "Game full, Waiting for free slot", Vector2D(135, math.floor(Render.GetViewportSize().Y * 0.06)), 0, 14, Color.ORANGE, 0, true, true, false, Vector2D(0, 0), Color.WHITE, false, Color.WHITE)
    else
        Render.ClearItems(6)
    end
end

VZ_EVENT_SUBSCRIBE("Player", "ValueChange", function(ply, key, value)
    if ply == Client.GetLocalPlayer() then
        if key == "PlayerWaiting" then
            HandlePlayerWaitingValue(value)
        end
    end
end)
HandlePlayerWaitingValue(Client.GetLocalPlayer():GetValue("PlayerWaiting"))

