


One_Time_Update_Data = {
    Zombies_Remaining_Number = nil,
    Remaining_Wave_Time = nil,
    InteractText = nil,
    WaitingPlayer = nil,
}

local LocalXP
local LocalLevel


local screen_scaling_mult = math.min(Viewport.GetViewportSize().X/Drawn_Text_Scaling_Base_Resolution_Size.X, Viewport.GetViewportSize().Y/Drawn_Text_Scaling_Base_Resolution_Size.Y)

function GUI_TextDrawnScalingSize(base_size)
    if Drawn_Text_Screen_Scaling and VZ_CL_Current_Settings.GUI_Auto_Scaling then
        return base_size*screen_scaling_mult
    end
    return base_size
end

function GUI_PositionScaling(vec, anchor)
    if Drawn_Text_Screen_Scaling and VZ_CL_Current_Settings.GUI_Auto_Scaling and vec then
        if anchor == nil then
            error("nil anchor passed in GUI_PositionScaling")
            return
        end

        local x, y = vec.X, vec.Y

        local anchor_x = math.floor(anchor / 3) -- 0:LEFT, 1:MIDDLE, 2:RIGHT
        local anchor_y = anchor % 3 -- 0:TOP, 1:MIDDLE, 2:BOTTOM

        --print(anchor_x, anchor_y)

        local middle_mult_x = math.abs((anchor_x-1))
        local middle_mult_y = math.abs(anchor_y-1)

        if middle_mult_x == 0 then
            middle_mult_x = 1/screen_scaling_mult
        end
        if middle_mult_y == 0 then
            middle_mult_y = 1/screen_scaling_mult
        end

        local ssize = Viewport.GetViewportSize()
        local size_x, size_y = ssize.X, ssize.Y

        local anchor_base_x = ((anchor_x == 2) and size_x) or 0
        local anchor_base_y = ((anchor_y == 2) and size_y) or 0

        local ret_x, ret_y = anchor_base_x + middle_mult_x*(x-anchor_base_x)*screen_scaling_mult, anchor_base_y + middle_mult_y*(y-anchor_base_y)*screen_scaling_mult

        return Vector2D(ret_x, ret_y)
    end
    return vec
end

Viewport.Subscribe("Resize", function(new_size)
    --print("RESIZED screen, recalculate screen_scaling_mult")
	screen_scaling_mult = math.min(new_size.X/Drawn_Text_Scaling_Base_Resolution_Size.X, new_size.Y/Drawn_Text_Scaling_Base_Resolution_Size.Y)
    if Frozen_Canvas then
        Frozen_Canvas:Repaint()
    end
    if One_Time_Updates_Canvas then
        One_Time_Updates_Canvas:Repaint()
    end
end)

local VZ_Canvases = {}

function VZ_Canvas(key, ...)
    local canvas = Canvas(...)
    if VZ_Canvases[key] then return error(string.format("Trying to create %s canvas that already exists", key)) end
    _ENV[key] = canvas
    VZ_Canvases[key] = canvas
    VZ_ENT_EVENT_SUBSCRIBE(canvas, "Destroy", function(self)
        VZ_EVENT_CALL("Events", "VZ_Canvas_Destroy", key, self)
        VZ_Canvases[key] = nil
    end)
    VZ_EVENT_CALL("Events", "VZ_Canvas_Created", key, canvas)
    return canvas
end
Package.Export("VZ_Canvas", VZ_Canvas)

function VZ_GetCanvases()
    return VZ_Canvases
end
Package.Export("VZ_GetCanvases", VZ_GetCanvases)

-- This canvas will be completly frozen
Frozen_Canvas = VZ_Canvas("Frozen_Canvas",
    true,
    Color(0, 0, 0, 0),
    -1,
    true
)
Frozen_Canvas:Subscribe("Update", function(self, width, height)
    if ZDEV_CONFIG.ENABLED then
        self:DrawText("VZ DEV MODE", GUI_PositionScaling(Vector2D(math.floor(Viewport.GetViewportSize().X * 0.5), 10), VZ_GUI_ANCHOR_TOP_MIDDLE), 0, GUI_TextDrawnScalingSize(16), Color.RED, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end

    local left_bottom_corner_text = "VZombies " .. Package.GetVersion()
    if VZ_CL_Current_Settings.Selected_Gamemode_Showed then
        local gm_text = VZ_SELECTED_GAMEMODE
        if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Name then
            gm_text = VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Name
        end
        if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Version then
            gm_text = gm_text .. " " .. tostring(VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].Version)
        end
        left_bottom_corner_text = left_bottom_corner_text .. ", " .. gm_text .. " Mode"
    end
    self:DrawText(left_bottom_corner_text, GUI_PositionScaling(Vector2D(1, math.max(0, Viewport.GetViewportSize().Y-11)), VZ_GUI_ANCHOR_BOTTOM_LEFT), FontType.Roboto, GUI_TextDrawnScalingSize(11), Color.WHITE, 0, false, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)

    --if VZ_CL_Current_Settings.Selected_Gamemode_Showed then
        --self:DrawText(VZ_SELECTED_GAMEMODE .. " Mode", Vector2D(math.max(0, Viewport.GetViewportSize().X - 440), math.max(0, Viewport.GetViewportSize().Y-65)), 0, GUI_TextDrawnScalingSize(12), Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), true, Color.BLACK)
    --end
end)
Frozen_Canvas:Repaint()

-- This canvas will be used for one time updates
One_Time_Updates_Canvas = VZ_Canvas("One_Time_Updates_Canvas",
    true,
    Color(0, 0, 0, 0),
    -1,
    true
)
One_Time_Updates_Canvas:Subscribe("Update", function(self, width, height)
    --if One_Time_Update_Data.HTP_Text_Showed then
        --self:DrawText("How to play (" .. Input.GetMappedKeys("How to play")[1] .. ")", GUI_PositionScaling(Vector2D(math.floor(Viewport.GetViewportSize().X * 0.5), math.floor(Viewport.GetViewportSize().Y * 0.5)), VZ_GUI_ANCHOR_MIDDLE_MIDDLE), 0, GUI_TextDrawnScalingSize(25), Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    --end
    if (Remaining_Enemies_Text and VZ_CL_Current_Settings.Zombies_Remaining_Showed) then
        local remaining_text
        if One_Time_Update_Data.Zombies_Remaining_Number then
            remaining_text = "Remaining Enemies : " .. tostring(One_Time_Update_Data.Zombies_Remaining_Number)
        elseif One_Time_Update_Data.Remaining_Wave_Time then
            local minutes, seconds = SecondsToMinutesAndSeconds(math.floor(One_Time_Update_Data.Remaining_Wave_Time/1000 + 0.5))
            remaining_text = "Wave Remaining Time : " .. string.format("%02d:%02d", minutes, seconds)
        end
        if remaining_text then
            self:DrawText(remaining_text, GUI_PositionScaling(Vector2D(135, math.floor(Viewport.GetViewportSize().Y * 0.04)), VZ_GUI_ANCHOR_TOP_LEFT), 0, GUI_TextDrawnScalingSize(14), Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
        end
    end
    if One_Time_Update_Data.InteractText then
        self:DrawText(
            One_Time_Update_Data.InteractText,
            GUI_PositionScaling((Viewport.GetViewportSize() / 2) + Vector2D(0, Interact_Text_Y_Offset), VZ_GUI_ANCHOR_MIDDLE_MIDDLE),
            0,
            GUI_TextDrawnScalingSize(20),
            Color.WHITE,
            0,
            true,
            true,
            Color(0, 0, 0, 0),
            Vector2D(),
            false,
            Color.WHITE
        )
    end
    if One_Time_Update_Data.WaitingPlayer then
        local text = "Game full, Waiting for free slot"
        if One_Time_Update_Data.WaitingPlayer == "No_Players" then
            text = "Bot only game"
        elseif One_Time_Update_Data.WaitingPlayer == "Waiting_More_Players" then
            text = "Waiting for more players to start (" .. tostring((VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE] and VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].MIN_PLAYERS)) .. ")"
        end
        self:DrawText(text, GUI_PositionScaling(Vector2D(math.floor(Viewport.GetViewportSize().X * 0.5), 30), VZ_GUI_ANCHOR_TOP_MIDDLE), 0, GUI_TextDrawnScalingSize(14), Color.ORANGE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
    if (Spectating_Player and not Free_Cam and VZ_CL_Current_Settings.Spectating_Player_Showed) then
        local text = "Spectating : " .. Spectating_Player:GetAccountName()
        self:DrawText(text, GUI_PositionScaling(Vector2D(math.floor(Viewport.GetViewportSize().X * 0.5), 50), VZ_GUI_ANCHOR_TOP_MIDDLE), 0, GUI_TextDrawnScalingSize(14), Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
    if GAME_PAUSED then
        self:DrawText("PAUSE", GUI_PositionScaling(Vector2D(math.floor(Viewport.GetViewportSize().X * 0.5), math.floor(Viewport.GetViewportSize().Y * 0.5)), VZ_GUI_ANCHOR_MIDDLE_MIDDLE), FontType.OpenSans, GUI_TextDrawnScalingSize(120), Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), true, Color.BLACK)
    end
end)
One_Time_Updates_Canvas:Repaint()

GAME_TIMER_SECONDS = 0

GUI = WebUI("VZombies GUI", "file://gui/index.html", WidgetVisibility.Visible, true, true)
Package.Export("GUI", GUI)

ROUND_NB = 0

HTP_Showed = false

local PlayersMoney = {}

local Powerups_On_GUI = {}

local Last_Ping_ID = 0
local Pings_To_Display = {}

CurPerks = {}

RequestedTabData = false
Tab_Open = false

GUI:Subscribe("Ready", function()
    if ZDEV_IsModeEnabled("ZDEV_DEBUG_WEBUIS_DEVTOOLS") then
        GUI:OpenDevTools()
    end
end)

Viewport.SetBloodScreenEnabled(false)

Client.SetOutlineColor(Outline_Selected_Bot_Color, 0)
Client.SetOutlineColor(Outline_Players_Color, 1)

Chat.SetConfiguration(table.unpack(Chat_Config))

Input.SetMouseEnabled(false)
Input.SetInputEnabled(true)

if VZ_GetFeatureValue("Levels", "script_loaded") then
    GUI:CallEvent("AddTabTopCategory", "Level")
end

if VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].HowToPlay_HTML then
    GUI:CallEvent("HelpAddInnerHTML", VZ_GAMEMODES_CONFIG[VZ_SELECTED_GAMEMODE].HowToPlay_HTML, true)
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

function SetWeaponNameText(text)
    if type(text) == "string" then
        local splited = split_str(text, " ")
        if splited[2] then
            text = table.concat(splited, " ", 2) -- remove first text before space (eg : modern-weapons text)
        end
    end
    GUI:CallEvent("SetWeaponNameText", text)
end

function NeedToUpdateAmmoText(char, weapon)
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
        if (not weapon:IsA(Grenade) and not weapon:IsA(Melee)) then
            --print("NeedToUpdateAmmoText", weapon:GetAmmoClip(), weapon:GetAmmoBag())
            GUI:CallEvent("SetAmmoText", tostring(weapon:GetAmmoClip()), tostring(weapon:GetAmmoBag()))
        end
    end
end
--VZ_EVENT_SUBSCRIBE("Character", "Fire", NeedToUpdateAmmoText) -- 1.95 clientside prediction makes desync on ammo
--VZ_EVENT_SUBSCRIBE("Character", "Reload", NeedToUpdateAmmoText)
VZ_EVENT_SUBSCRIBE("Weapon", "AmmoBagChange", function(weapon)
    NeedToUpdateAmmoText(weapon:GetHandler(), weapon)
end)
VZ_EVENT_SUBSCRIBE("Weapon", "AmmoClipChange", function(weapon)
    NeedToUpdateAmmoText(weapon:GetHandler(), weapon)
end)
VZ_EVENT_SUBSCRIBE("Character", "PickUp", function(char, weapon)
    if (IsValid(char) and IsValid(weapon)) then
        NeedToUpdateAmmoText(char, weapon)
        if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
            SetWeaponNameText(weapon:GetValue("WeaponName"))
        end
    end
end)
VZ_EVENT_SUBSCRIBE("Character", "Drop", function(char)
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        if (local_char == char) then
            GUI:CallEvent("SetAmmoText", "0", "0")
            GUI:CallEvent("ShowRepackIcon")
            SetWeaponNameText()
        end
    elseif IsSpectatingPlayerCharacter(char) then
        GUI:CallEvent("SetAmmoText", "0", "0")
        GUI:CallEvent("ShowRepackIcon")
        SetWeaponNameText()
    end
end)
VZ_EVENT_SUBSCRIBE_REMOTE("UpdateAmmoText", function()
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        local weap = local_char:GetPicked()
        if weap then
            GUI:CallEvent("SetAmmoText", tostring(weap:GetAmmoClip()), tostring(weap:GetAmmoBag()))
            SetWeaponNameText(weap:GetValue("WeaponName"))
        end
    end
end)
if Client.GetLocalPlayer() then
    if Client.GetLocalPlayer():GetControlledCharacter() then
        local weap = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
        if weap then
            NeedToUpdateAmmoText(Client.GetLocalPlayer():GetControlledCharacter(), weap)
            SetWeaponNameText(weap:GetValue("WeaponName"))
        end
    end
end

function IsLocalPlayerInPlayersMoney()
    for i, v in ipairs(PlayersMoney) do
        if v.ply == Client.GetLocalPlayer() then
            return true
        end
    end
    return false
end

function AddPlayerMoney(ply, money)
    if ply then -- Ghost player appear if i don't do that ? - Yes I was adding nil players because of wrong variable in BuildPlayersMoney
        local is_self = false
        if (Client.GetLocalPlayer() and ply == Client.GetLocalPlayer()) then
            is_self = true
        end

        local money_displays_limit = Max_Players_Money_Displayed
        if (not IsLocalPlayerInPlayersMoney()) then
            money_displays_limit = Max_Players_Money_Displayed - 1 -- let space for local_player
        end

        if (is_self or table_count(PlayersMoney) < money_displays_limit) then
            GUI:CallEvent("AddPlayerMoney", tostring(money), is_self)
            table.insert(PlayersMoney, {ply = ply, money = money})

            return true
        end
    end
    return false
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
            if LocalXP then
                if Client.GetLocalPlayer() == ply then
                    AddLocalXP(math.floor((money - PlayersMoney[i].money)*VZ_GetFeatureValue("Levels", "score_mult_into_xp")))
                end
            end
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
                AddPlayerMoney(v2, money)
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

function SetRoundNumber(nb, is_hellhound)
    GUI:CallEvent("NewWave", tostring(nb))

    local wave_sound_to_play = NewWave_Sound
    if is_hellhound then
        wave_sound_to_play = Hellhound_Start_Sound
    end

    local new_round = Sound(
        Vector(0, 0, 0),
        wave_sound_to_play.asset,
        true,
        true,
        SoundType.SFX,
        wave_sound_to_play.volume
    )
    ROUND_NB = nb
    UpdateDiscordRichPresence()

    VZ_EVENT_CALL("Events", "VZ_WaveStarted", nb, is_hellhound)
end

VZ_EVENT_SUBSCRIBE_REMOTE("SetClientRoundNumber", function(nb, is_hellhound)
    SetRoundNumber(nb, is_hellhound)
end)

function InteractText(text)
    One_Time_Update_Data.InteractText = text
    One_Time_Updates_Canvas:Repaint()
end

function BuyText(buy_name, buy_price)
    InteractText("Buy " .. tostring(buy_name) .. " (" .. tostring(buy_price) .. "$)")
end

function UpdateHealth(char, health)
    --print("UpdateHealth", char, health)
    if health then
        if not IsValid(char) then return end

        local max_health = PlayerHealth
        if char:GetMaxHealth() > 0 then
            max_health = char:GetMaxHealth()-1000
        end
        if char:GetValue("OverrideUIMaxHealth") then
            max_health = char:GetValue("OverrideUIMaxHealth")
        end

        GUI:CallEvent("UpdateGUIHealth", max_health, health)

        if health <= 0 then
            Viewport.SetBloodScreenIntensity(1.1)
        elseif health <= PlayerHealth then
            Viewport.SetBloodScreenIntensity(((health * 0.01) - (PlayerHealth * 0.01)) * -1)
        else
            Viewport.SetBloodScreenIntensity(0.0)
        end
    else
        GUI:CallEvent("HideGUIHealth")
        Viewport.SetBloodScreenIntensity(0.0)

        --print("UpdateHealth invalid health", health)
    end
end

VZ_EVENT_SUBSCRIBE_REMOTE("OverrideUIMaxHealth", function(new_max)
    local char = GetLocalCharacter()
    if IsValid(char) then
        char:SetValue("OverrideUIMaxHealth", new_max, false)
        UpdateHealth(Client.GetLocalPlayer():GetControlledCharacter(), char:GetHealth()-1000)
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, dtype, from_direction, instigator, causer)
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
        if char:IsDead() then return end
        if dtype == DamageType.Punch then
            PlayPlayerHurtSound()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
        UpdateHealth()
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("UpdateGUIHealth", function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        local health = char:GetHealth() - 1000
        UpdateHealth(char, health)
        if (Playing_LowHealth_Sound and health > LowHealth_Trigger_Health) then
            PlayExitLowHealthSound()
            StopLowHealthLoop()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "HealthChange", function(char, old_health, new_health)
    if IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char) then
        local health = new_health-1000
        UpdateHealth(char, health)
        if (health <= LowHealth_Trigger_Health and health > 0) then
            if not Playing_LowHealth_Sound then
                PlayLowHealthLoop()
            end
        end
    end
end)

--[[
VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    print("Player Possess", ply, ply:GetAccountName(), char)
    if ply == Client.GetLocalPlayer() then
        local sethealth = char:GetHealth()-1000
        UpdateHealth(char, sethealth)
    end
end)
]]--

if Client.GetLocalPlayer() then
    local char = Client.GetLocalPlayer():GetControlledCharacter()
    if char then
        UpdateHealth(char, char:GetHealth() - 1000)
    end
end

function GUIStartRevive(time)
    GUI:CallEvent("StartRevive", tostring(time))
end

function GUIStopRevive()
    GUI:CallEvent("StopRevive")
end

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    local local_ply = Client.GetLocalPlayer()
    if local_ply then
        local local_char = local_ply:GetControlledCharacter()
        if local_char then
            if local_char == char then
                if key == "SoloQuickReviving" then
                    if value then
                        GUIStartRevive(PERKS_CONFIG.quick_revive.Solo_ReviveTime_ms)
                    else
                        GUIStopRevive()
                    end
                end
            end
        end
    end
end)

function PowerupGrabbedGUI(powerup_name)
    PlayVZSound({basic_sound_tbl=Powerups_Config[powerup_name].sound})
    if (Powerups_Config[powerup_name].icon and not Powerups_On_GUI[powerup_name]) then
        GUI:CallEvent("AddPowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = true
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("PowerupGrabbed", PowerupGrabbedGUI)

function DurationPowerupRemovedGUI(powerup_name)
    if Powerups_Config[powerup_name].icon then
        GUI:CallEvent("RemovePowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = nil
    end
end
VZ_EVENT_SUBSCRIBE_REMOTE("DurationPowerupRemoved", DurationPowerupRemovedGUI)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if IsSelfCharacter(char) then
        if key == "DeathMachineTimer" then
            if value then
                PowerupGrabbedGUI("death_machine")
            else
                DurationPowerupRemovedGUI("death_machine")
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("RemoveGUIPowerups", function()
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
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
        if key == "OwnedPerks" then
            for k, v in pairs(value) do
                local found
                for k2, v2 in pairs(CurPerks) do
                    if k2 == k then
                        found = true
                    end
                end
                if not found then
                    PlayVZSound({basic_sound_tbl=NewPerk_Sound})
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
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
        CurPerks = {}
        GUI:CallEvent("ResetPerks")
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("TabData", function(tab_data, id_line_highlight)
    Tab_Open = true
    --print(NanosTable.Dump(tab_data), id_line_highlight)
    GUI:CallEvent("ShowTab", JSON.stringify(tab_data), id_line_highlight)
    RequestedTabData = false
end)

function UpdateGrenadesNB(nb)
    GUI:CallEvent("SetGrenadesNB", nb)
end
if Client.GetLocalPlayer() then
    if Client.GetLocalPlayer():GetControlledCharacter() then
        if Client.GetLocalPlayer():GetControlledCharacter():GetValue("ZGrenadesNB") then
            UpdateGrenadesNB(Client.GetLocalPlayer():GetControlledCharacter():GetValue("ZGrenadesNB"))
        end
    end
end

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    if ply == Client.GetLocalPlayer() then
        if char:GetValue("ZGrenadesNB") then
            UpdateGrenadesNB(char:GetValue("ZGrenadesNB"))
        else
            UpdateGrenadesNB(0)
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
        if key == "ZGrenadesNB" then
            UpdateGrenadesNB(value)
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
        UpdateGrenadesNB(0)
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("SetClientRemainingZombies", function(remaining)
    if Remaining_Enemies_Text then
        if not Timed_Waves then
            One_Time_Update_Data.Zombies_Remaining_Number = remaining
            One_Time_Updates_Canvas:Repaint()
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("SetClientRemainingWaveTime", function(remaining_ms)
    if Remaining_Enemies_Text then
        if Timed_Waves then
            One_Time_Update_Data.Remaining_Wave_Time = remaining_ms
            One_Time_Updates_Canvas:Repaint()
        end
    end
end)

function Get3DLocationOnScreen(loc)
    local project = Viewport.ProjectWorldToScreen(loc)
    if (project and project ~= Vector2D(-1, -1)) then
        return project
    end
end

function HandlePlayerWaitingValue(value)
    --print("HandlePlayerWaitingValue PlayerWaiting", value)
    One_Time_Update_Data.WaitingPlayer = value
    One_Time_Updates_Canvas:Repaint()
end

VZ_EVENT_SUBSCRIBE("Player", "ValueChange", function(ply, key, value)
    if ply == Client.GetLocalPlayer() then
        if key == "PlayerWaiting" then
            HandlePlayerWaitingValue(value)
        end
    end
end)
HandlePlayerWaitingValue(Client.GetLocalPlayer():GetValue("PlayerWaiting"))

VZ_EVENT_SUBSCRIBE_REMOTE("SetGlobalPlayerWaitingValue", function(value)
    HandlePlayerWaitingValue(value)
end)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "PlayerDown" then
        if not IsSelfCharacter(char) then
            if value then
                AddNotification(char:GetPlayer():GetAccountName() .. " is down", 10000)
                local billboard = Billboard(
                    Vector(0, 0, 0),
                    "nanos-world::M_NanosTranslucent_Depth",
                    Vector2D(32, 32),
                    false
                )
                billboard:SetMaterialTextureParameter("Texture", Player_To_Revive_image)
                billboard:SetMaterialScalarParameter("Opacity", 1)
                billboard:SetValue("ToReviveBillboard", true)

                billboard:AttachTo(char, AttachmentRule.SnapToTarget, "", 0)
                billboard:SetRelativeLocation(To_Revive_Billboard_Relative_Location)
            else
                for k, v in pairs(char:GetAttachedEntities()) do
                    if v:GetValue("ToReviveBillboard") then
                        v:Destroy()
                        break
                    end
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("UpdateGameTime", function(time_s)
    GAME_TIMER_SECONDS = time_s
end)

local sum_wait_second = 0
VZ_EVENT_SUBSCRIBE("Client", "Tick", function(ds)
    --print(ds)
    if not GAME_PAUSED then
        if Game_Time_On_Screen then
            GAME_TIMER_SECONDS = GAME_TIMER_SECONDS + ds
        end
        if One_Time_Update_Data.Remaining_Wave_Time then
            sum_wait_second = sum_wait_second + ds
            One_Time_Update_Data.Remaining_Wave_Time = math.max(One_Time_Update_Data.Remaining_Wave_Time-(ds*1000), 0)
            if (sum_wait_second >= 1) then
                sum_wait_second = 0
                One_Time_Updates_Canvas:Repaint()
            end
        end
    end
end)


local Outlined_Characters = {}

function ResetOutlined()
    for k, v in pairs(Outlined_Characters) do
        v:SetOutlineEnabled(false, 1)
        --print("Disable wall outline")
    end
    Outlined_Characters = {}
end

function EnableCharOutline(v, enable)
    if not (enable and Outlined_Characters[v:GetID()]) then
        if v ~= Selected_Bot_For_Order then
            v:SetOutlineEnabled(enable, 1)
            --print("Disable wall outline")
            if enable then
                Outlined_Characters[v:GetID()] = v
            else
                Outlined_Characters[v:GetID()] = nil
            end
        end
    end
end


if Outline_Players_Enabled then
    Timer.SetInterval(function()
        local local_char = Client.GetLocalPlayer():GetControlledCharacter()
        local TraceFrom
        if local_char then
            TraceFrom = local_char:GetSocketTransform("head").Location
        else
            TraceFrom = Client.GetLocalPlayer():GetCameraLocation()
        end

        if TraceFrom then
            for k, v in pairs(Character.GetPairs()) do
                if local_char ~= v then
                    local ply = v:GetPlayer()
                    if ply then
                        local ignored_actors = {}
                        if local_char then
                            ignored_actors = {local_char}
                        elseif (Spectating_Player and Spectating_Player:IsValid()) then
                            local spec_char = Spectating_Player:GetControlledCharacter()
                            if spec_char:IsValid() then
                                ignored_actors = {spec_char}
                            end
                        end

                        local trace_mode = TraceMode.ReturnEntity
                        if ZDEV_IsModeEnabled("ZDEV_DEBUG_TRACES") then
                            trace_mode = trace_mode | TraceMode.DrawDebug
                        end

                        local trace = Trace.LineSingle(TraceFrom, v:GetLocation(), CollisionChannel.Pawn | CollisionChannel.WorldStatic, trace_mode, ignored_actors)

                        if trace.Success then
                            if (trace.Entity and trace.Entity == v) then
                                EnableCharOutline(v, false)
                            else
                                EnableCharOutline(v, true)
                            end
                        else
                            EnableCharOutline(v, true)
                        end
                    end
                end
            end
        else
            ResetOutlined()
        end
    end, Outline_Players_Check_Interval_ms)
end

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if Outlined_Characters[char:GetID()] then
        Outlined_Characters[char:GetID()] = nil
    end
end)

local Text3Ds = {}
VZ_EVENT_SUBSCRIBE("Text3D", "Destroy", function(text_3d)
    for i, v in ipairs(Text3Ds) do
        if v == text_3d then
            table.remove(Text3Ds, i)
            break
        end
    end
end)

function CheckToAddText3D(char)
    --print(char, char:GetPlayer())
    if not VZ_CL_Current_Settings.Player_Names_On_Heads then return end
    local local_ply = Client.GetLocalPlayer()
    if local_ply then
        local local_char = local_ply:GetControlledCharacter()
        if local_char == char then
            return
        end
    end
    if (char:GetPlayer() and (not IsValid(char:GetValue("Text3DEnt")))) then
        local text_3d = Text3D(
            Vector(),
            Rotator(),
            char:GetPlayer():GetAccountName(),
            Player_Name_Text3D_Scale,
            Color.AZURE,
            FontType.OpenSans,
            Text3DAlignCamera.FaceCamera
        )
        text_3d:SetTextSettings(0, 0, 0, TextRenderHorizontalAlignment.Center, TextRenderVerticalAlignment.Center)
        text_3d:AttachTo(char, AttachmentRule.SnapToTarget, "", 0, false)
        text_3d:SetRelativeLocation(Player_Name_Text3D_Head_Offset)
        text_3d:SetMaterialColorParameter("Emissive", Color.AZURE * 2)

        -- Nanos 1.164.0 Broken https://nanos-world.com/feedback/p/textrender-cameraaligned-broken
        --[[local text_3d = TextRender(
            Vector(),
            Rotator(),
            char:GetPlayer():GetAccountName(),
            26,
            Color.AZURE,
            TextRenderRenderingType.UnlitCameraAligned
        )
        text_3d:AttachTo(char, AttachmentRule.SnapToTarget, "", 0, false)
        text_3d:SetRelativeLocation(Player_Name_Text3D_Head_Offset)]]--

        char:SetValue("Text3DEnt", text_3d)
        table.insert(Text3Ds, text_3d)
    end
end

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "OwnedPerks" then
        CheckToAddText3D(char)
    end
end)

RegisterPreparedLoop("PlayerCharacters", Character, "OwnedPerks")

function CleanupText3Ds()
    for i, v in ipairs(TableDeepCopy(Text3Ds)) do
        if IsValid(v) then
            v:Destroy()
        end
    end
end

function SpawnText3Ds()
    for k, v in pairs(PreparedLoops["PlayerCharacters"]) do
        CheckToAddText3D(v)
    end
end
SpawnText3Ds()

if Game_Time_On_Screen then
    GAME_TIME_Canvas = VZ_Canvas("GAME_TIME_Canvas",
        true,
        Color(0, 0, 0, 0),
        Game_Time_Canvas_Update_Interval_ms / 1000,
        true
    )
    GAME_TIME_Canvas:Subscribe("Update", function(self, width, height)
        if VZ_CL_Current_Settings.Game_Time_Showed then
            local time_seconds = math.floor(GAME_TIMER_SECONDS)
            local minutes, seconds = SecondsToMinutesAndSeconds(time_seconds)
            self:DrawText(string.format("%02d:%02d", minutes, seconds), GUI_PositionScaling(Vector2D(150, math.max(0, Viewport.GetViewportSize().Y-45)), VZ_GUI_ANCHOR_BOTTOM_LEFT), FontType.Oswald, GUI_TextDrawnScalingSize(15), Color.WHITE, 0, false, true, Color.TRANSPARENT, Vector2D(), false, Color.TRANSPARENT)
        end
    end)
end

if Ping_Enabled then
    Ping_Canvas = VZ_Canvas("Ping_Canvas",
        true,
        Color(0, 0, 0, 0),
        -1,
        true
    )

    function DrawPing(self, location, text, color)
        local marker_vector2 = Get3DLocationOnScreen(location)
        if marker_vector2 then
            self:DrawPolygon("", marker_vector2, Vector2D(4, 4), 6, Color.YELLOW)
            self:DrawText(text, marker_vector2 + Vector2D(0, 15), FontType.OpenSans, GUI_TextDrawnScalingSize(10), color, 0, true, true, Color.TRANSPARENT, Vector2D(), false, Color.TRANSPARENT)
        end
    end

    Ping_Canvas:Subscribe("Update", function(self, width, height)
        for k, v in pairs(Pings_To_Display) do
            if v.entity then
                if v.entity:IsValid() then
                    if v.entity:GetValue("DoorID") then
                        DrawPing(self, v.location, "Door", v.color)
                    elseif v.entity:IsA(Weapon) then
                        if v.entity:GetValue("MapWeaponID") then
                            DrawPing(self, v.location, MAP_WEAPONS[v.entity:GetValue("MapWeaponID")].weapon_name .. " WallBuy", v.color)
                        elseif not v.entity:GetHandler() then
                            DrawPing(self, v.location, "Ground Weapon", v.color)
                        else
                            DrawPing(self, v.location, "Ping", v.color)
                        end
                    elseif (v.entity.GetMesh and v.entity:GetMesh() == "vzombies-assets::mystery_box") then
                        DrawPing(self, v.location, "Mystery Box", v.color)
                    elseif (v.entity:GetValue("MapPower") or v.entity:GetValue("MapPowerHANDLE")) then
                        DrawPing(self, v.location, "Power", v.color)
                    elseif v.entity:GetValue("IsPackAPunch") then
                        DrawPing(self, v.location, "Pack A Punch", v.color)
                    elseif v.entity:GetValue("MapPerk") then
                        DrawPing(self, v.location, v.entity:GetValue("MapPerk") .. " Perk", v.color)
                    elseif (v.entity.GetMesh and v.entity:GetMesh() == "vzombies-assets::wunderfizz_body") then
                        DrawPing(self, v.location, "Wunderfizz", v.color)
                    elseif v.entity:GetValue("EnemyName") then
                        DrawPing(self, v.entity:GetLocation(), v.entity:GetValue("EnemyName"), v.color)
                    elseif (v.entity:IsA(Character) and v.entity:GetPlayer()) then
                        DrawPing(self, v.entity:GetLocation(), v.entity:GetPlayer():GetAccountName(), v.color)
                    elseif (IsAVehicle(v.entity) and v.entity:GetValue("VehName")) then
                        DrawPing(self, v.entity:GetLocation(), v.entity:GetValue("VehName"), v.color)
                    else
                        DrawPing(self, v.location, "Ping", v.color)
                    end
                end
            else
                DrawPing(self, v.location, "Ping", v.color)
            end
        end
    end)

    VZ_EVENT_SUBSCRIBE_REMOTE("SyncPing", function(color, location, entity)
        Last_Ping_ID = Last_Ping_ID + 1
        local current_id = Last_Ping_ID
        Pings_To_Display[current_id] = {
            color = color,
            location = location,
            entity = entity,
            timeout = Timer.SetTimeout(function()
                if Pings_To_Display[current_id] then
                    Pings_To_Display[current_id] = nil
                    if table_count(Pings_To_Display) == 0 then
                        Ping_Canvas:SetAutoRepaintRate(-1)
                        Ping_Canvas:Clear(Color.TRANSPARENT)
                    end
                end
            end, Ping_Display_Time_ms)
        }

        if table_count(Pings_To_Display) == 1 then
            Ping_Canvas:SetAutoRepaintRate(Ping_Canvas_Update_Interval_ms / 1000)
        end
    end)
end

VZ_EVENT_SUBSCRIBE("Player", "VOIP", function(ply, is_talking)
    if is_talking then
        GUI:CallEvent("PlayerStartedVOIP", ply:GetAccountName(), ply:GetID())
    else
        GUI:CallEvent("PlayerStoppedVOIP", ply:GetID())
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZOMBIES_CLIENT_GAMEMODE_LOADED", function()
    local passed_tbl = {}
    for i, v in ipairs(Binded_Keys) do
        table.insert(passed_tbl, {v, Input.GetMappedKeys(v)[1]})
    end
    GUI:CallEvent("HelpMenuDefaultKeys", passed_tbl)
end)


VZ_EVENT_SUBSCRIBE_REMOTE("PlayerLevelXPUpdate", function(level, xp)
    if not LocalXP then
        GUI:CallEvent("EnableVZLevels")
    end
    if LocalLevel ~= level then
        LocalLevel = level
        SetGUILevel(level)
    end
    if LocalXP ~= xp then
        LocalXP = xp
        SetGUIXP(xp, VZ_GetFeatureValue("Levels", "levels_xp_func")(LocalLevel))
    end
end)

function SetGUILevel(level)
    GUI:CallEvent("SetLvlText", tostring(level))
end

function SetGUIXP(xp, target)
    GUI:CallEvent("SetBarPercentage", (xp * 100) / target)
end

function AddLocalXP(added)
    if LocalXP then
        if added > 0 then
            LocalXP = LocalXP + added
            local XP_target = VZ_GetFeatureValue("Levels", "levels_xp_func")(LocalLevel)
            if LocalXP >= XP_target then
                LocalXP = LocalXP - XP_target
                LocalLevel = LocalLevel + 1
                AddNotification("Level Up")
                SetGUILevel(LocalLevel)
            end
            SetGUIXP(LocalXP, XP_target)
        end
    end
end

function AddNotification(text, time)
    time = time or 5000
    GUI:CallEvent("AddNotification", text, time)
end
VZ_EVENT_SUBSCRIBE_REMOTE("AddNotification", AddNotification)
Package.Export("AddNotification", AddNotification)


VZ_EVENT_SUBSCRIBE("Character", "PickUp", function(char, picked)
    if IsValid(char) and IsValid(picked) then
        if (Client.GetLocalPlayer():GetControlledCharacter() == char or (IsSpectatingPlayerCharacter(char))) then
            if picked:GetValue("PAPRepackEffect") then
                local config = PAP_Repack_Config[picked:GetValue("PAPRepackEffect")]
                if (config and config.icon) then
                    GUI:CallEvent("ShowRepackIcon", config.icon)
                end
            end
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "UnPossess", function(ply, char)
    if (ply == Client.GetLocalPlayer() or ply == Spectating_Player) then
        GUI:CallEvent("ShowRepackIcon")
    end
end)

VZ_EVENT_SUBSCRIBE("Weapon", "ValueChange", function(weap, key, value)
    if (weap and weap:IsValid()) then
        if key == "PAPRepackEffect" then
            local handler = weap:GetHandler()
            if handler then
                local handler_ply = handler:GetPlayer()
                if handler_ply then
                    --print(handler_ply == Client.GetLocalPlayer() or handler_ply == Spectating_Player)
                    if (handler_ply == Client.GetLocalPlayer() or handler_ply == Spectating_Player) then
                        if value then
                            local config = PAP_Repack_Config[value]
                            if (config and config.icon) then
                                GUI:CallEvent("ShowRepackIcon", config.icon)
                            else
                                GUI:CallEvent("ShowRepackIcon")
                            end
                        else
                            GUI:CallEvent("ShowRepackIcon")
                        end
                    end
                end
            end
        end
    end
end)


UI_Charging_Canvas = nil
local ui_charging_canvas_data

function UI_MakeChargingCanvas()
    if UI_Charging_Canvas then return UI_Charging_Canvas end
    if not VZ_CL_Current_Settings["UI_Charging_Canvas"] then return end

    ui_charging_canvas_data = {}

    UI_Charging_Canvas = VZ_Canvas("UI_Charging_Canvas",
        true,
        Color(0, 0, 0, 0),
        0,
        true
    )
    UI_Charging_Canvas:Subscribe("Update", function(self, width, height)
        if not ui_charging_canvas_data then return end
        if not IsValid(ui_charging_canvas_data.charging_entity) then return end
        local time_remaining = math.ceil((ui_charging_canvas_data.charge_time or 0) - ((GAME_TIMER_SECONDS or 0) - (ui_charging_canvas_data.charger_begin_time or 0)))
        --[[self:DrawText(
            "Charging Module, " .. tostring(time_remaining) .. "s remaining",
            GUI_PositionScaling((Viewport.GetViewportSize() / 2) + Vector2D(0, Interact_Text_Y_Offset+20+50), VZ_GUI_ANCHOR_MIDDLE_MIDDLE),
            0,
            GUI_TextDrawnScalingSize(18),
            Color.WHITE,
            0,
            true,
            true,
            Color(0, 0, 0, 0),
            Vector2D(),
            false,
            Color.WHITE
        )]]--

        local screen_loc = Get3DLocationOnScreen(ui_charging_canvas_data.charging_entity:GetLocation() + Vector(0, 0, 125))
        if screen_loc then
        self:DrawText(
            "Charging, " .. tostring(time_remaining) .. "s remaining",
            screen_loc,
            0,
            GUI_TextDrawnScalingSize(12),
            Color.WHITE,
            0,
            true,
            true,
            Color(0, 0, 0, 0),
            Vector2D(),
            false,
            Color.WHITE
        )
        end
    end)
    return UI_Charging_Canvas
end

function UI_DestroyChargingCanvas()
    if UI_Charging_Canvas then
        UI_Charging_Canvas:Destroy()
        UI_Charging_Canvas = nil
        ui_charging_canvas_data = nil
    end
end

function UI_SetChargingID(new_charging_id)
    if not new_charging_id then
        UI_DestroyChargingCanvas()
    else
        UI_MakeChargingCanvas()
        if ui_charging_canvas_data then
            ui_charging_canvas_data.charging_id = new_charging_id

            if not PreparedLoops["Chargers"] then return end
            for _, v in pairs(PreparedLoops["Chargers"]) do
                if IsValid(v) then
                    if v:GetValue("MapChargerID") == new_charging_id then
                        ui_charging_canvas_data.charging_entity = v
                        break
                    end
                end
            end

            if not IsValid(ui_charging_canvas_data.charging_entity) then
                Console.Error("Charging entity invalid when setting ui_charging_canvas_data")
                ui_charging_canvas_data = nil
                return
            end

            local stored_charge_time = ui_charging_canvas_data.charging_entity:GetValue("MapChargerChargeTime")
            if not stored_charge_time then
                Console.Error("Cannot find MapChargerChargeTime on Charging entity in UI_SetChargingID")
                ui_charging_canvas_data = nil
                return
            end
            ui_charging_canvas_data.charge_time = math.floor(stored_charge_time/1000 + 0.5)
        end
    end
end

VZ_EVENT_SUBSCRIBE_REMOTE("ClientSetChargingID", function(new_charging_id, charger_begin_time)
    UI_SetChargingID(new_charging_id)
    if ui_charging_canvas_data then
        ui_charging_canvas_data.charger_begin_time = charger_begin_time
    end
end)