


One_Time_Update_Data = {
    HTP_Text_Showed = true,
    Zombies_Remaining_Number = 0,
    InteractText = nil,
    WaitingPlayer = nil,
}

-- This canvas will be completly frozen
Frozen_Canvas = Canvas(
    true,
    Color(0, 0, 0, 0),
    -1,
    true
)
Frozen_Canvas:Subscribe("Update", function(self, width, height)
    if ZDEV_CONFIG.ENABLED then
        self:DrawText("VZ DEV MODE", Vector2D(math.floor(Client.GetViewportSize().X * 0.5), 10), 0, 16, Color.RED, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
    self:DrawText("VZombies " .. Package.GetVersion(), Vector2D(60, math.floor(Client.GetViewportSize().Y * 0.99)), 0, 12, Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)

    self:DrawText(VZ_SELECTED_GAMEMODE .. " Mode", Vector2D(math.floor(Client.GetViewportSize().X * 0.78), math.floor(Client.GetViewportSize().Y * 0.96)), 0, 12, Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), true, Color.BLACK)
end)
Frozen_Canvas:Repaint()

-- This canvas will be used for one time updates
One_Time_Updates_Canvas = Canvas(
    true,
    Color(0, 0, 0, 0),
    -1,
    true
)
One_Time_Updates_Canvas:Subscribe("Update", function(self, width, height)
    if One_Time_Update_Data.HTP_Text_Showed then
        self:DrawText("How to play (" .. Input.GetMappedKey("How to play") .. ")", Vector2D(math.floor(Client.GetViewportSize().X * 0.5), math.floor(Client.GetViewportSize().Y * 0.5)), 0, 25, Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
    if Remaining_Enemies_Text then
        self:DrawText("Remaining Enemies : " .. tostring(One_Time_Update_Data.Zombies_Remaining_Number), Vector2D(135, math.floor(Client.GetViewportSize().Y * 0.04)), 0, 14, Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
    if One_Time_Update_Data.InteractText then
        self:DrawText(
            One_Time_Update_Data.InteractText,
            (Client.GetViewportSize() / 2) + Vector2D(0, Interact_Text_Y_Offset),
            0,
            20,
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
        self:DrawText("Game full, Waiting for free slot", Vector2D(135, math.floor(Client.GetViewportSize().Y * 0.06)), 0, 14, Color.ORANGE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
    if Spectating_Player then
        local text = "Spectating : " .. Spectating_Player:GetAccountName()
        self:DrawText(text, Vector2D(math.floor(Client.GetViewportSize().X * 0.5), 30), 0, 14, Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), false, Color.WHITE)
    end
    if GAME_PAUSED then
        self:DrawText("PAUSE", Vector2D(math.floor(Client.GetViewportSize().X * 0.5), math.floor(Client.GetViewportSize().Y * 0.5)), FontType.OpenSans, 120, Color.WHITE, 0, true, true, Color(0, 0, 0, 0), Vector2D(), true, Color.BLACK)
    end
end)
One_Time_Updates_Canvas:Repaint()

Timer.SetTimeout(function()
    One_Time_Update_Data.HTP_Text_Showed = false
    One_Time_Updates_Canvas:Repaint()
end, How_To_Play_Text_Destroy_ms)

GAME_TIMER_SECONDS = 0

GUI = WebUI("vzombies GUI", "file://gui/index.html", true, true, true)

ROUND_NB = 0

HTP_Showed = false

local PlayersMoney = {}

local Powerups_On_GUI = {}

local Last_Ping_ID = 0
local Pings_To_Display = {}

CurPerks = {}

RequestedTabData = false
Tab_Open = false

Client.SetBloodScreenEnabled(false)

Client.SetOutlineColor(Outline_Selected_Bot_Color, 0)
Client.SetOutlineColor(Outline_Players_Color, 1)

Client.SetChatConfiguration(table.unpack(Chat_Config))

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
    if (IsSelfCharacter(char) or IsSpectatingPlayerCharacter(char)) then
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
        if (local_char == char) then
            GUI:CallEvent("SetAmmoText", "0", "0")
        end
    elseif IsSpectatingPlayerCharacter(char) then
        GUI:CallEvent("SetAmmoText", "0", "0")
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
if Client.GetLocalPlayer() then
    if Client.GetLocalPlayer():GetControlledCharacter() then
        local weap = Client.GetLocalPlayer():GetControlledCharacter():GetPicked()
        if weap then
            NeedToUpdateAmmoText(Client.GetLocalPlayer():GetControlledCharacter(), weap)
        end
    end
end

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
end

VZ_EVENT_SUBSCRIBE("Events", "SetClientRoundNumber", function(nb, is_hellhound)
    SetRoundNumber(nb, is_hellhound)
end)

function InteractText(text)
    One_Time_Update_Data.InteractText = text
    One_Time_Updates_Canvas:Repaint()
end

function BuyText(buy_name, buy_price)
    InteractText("Buy " .. tostring(buy_name) .. " (" .. tostring(buy_price) .. "$)")
end

function UpdateHealth(health)
    if health then

        local max_health = PlayerHealth
        local char = Client.GetLocalPlayer():GetControlledCharacter()
        if char then
            local perks = char:GetValue("OwnedPerks")
            if (perks and perks["juggernog"]) then
                max_health = PERKS_CONFIG.juggernog.PlayerHealth
            end
        end

        GUI:CallEvent("UpdateGUIHealth", max_health, health)

        if health <= 0 then
            Client.SetBloodScreenIntensity(1.1)
        elseif health <= PlayerHealth then
            Client.SetBloodScreenIntensity(((health * 0.01) - (PlayerHealth * 0.01)) * -1)
        else
            Client.SetBloodScreenIntensity(0.0)
        end
    else
        GUI:CallEvent("HideGUIHealth")
        Client.SetBloodScreenIntensity(0.0)
    end
end

VZ_EVENT_SUBSCRIBE("Character", "TakeDamage", function(char, damage, bone, dtype, from_direction, instigator, causer)
    if IsSelfCharacter(char) then
        local health = char:GetHealth() - damage - 1000
        UpdateHealth(health)
        --print("Here")
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
        UpdateHealth(nil)
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "UpdateGUIHealth", function()
    local ply = Client.GetLocalPlayer()
    local char = ply:GetControlledCharacter()
    if char then
        local health = char:GetHealth() - 1000
        UpdateHealth(health)
        if (Playing_LowHealth_Sound and health > LowHealth_Trigger_Health) then
            PlayExitLowHealthSound()
            StopLowHealthLoop()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    if ply == Client.GetLocalPlayer() then
        UpdateHealth(PlayerHealth)
    end
end)

if Client.GetLocalPlayer() then
    if Client.GetLocalPlayer():GetControlledCharacter() then
        UpdateHealth(Client.GetLocalPlayer():GetControlledCharacter():GetHealth() - 1000)
    end
end

function GUIStartRevive(time)
    GUI:CallEvent("StartRevive", tostring(time))
end

function GUIStopRevive()
    GUI:CallEvent("StopRevive")
end

function PowerupGrabbedGUI(powerup_name)
    PlayVZSound({basic_sound_tbl=Powerups_Config[powerup_name].sound})
    if (Powerups_Config[powerup_name].icon and not Powerups_On_GUI[powerup_name]) then
        GUI:CallEvent("AddPowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = true
    end
end
VZ_EVENT_SUBSCRIBE("Events", "PowerupGrabbed", PowerupGrabbedGUI)

function DurationPowerupRemovedGUI(powerup_name)
    if Powerups_Config[powerup_name].icon then
        GUI:CallEvent("RemovePowerup", Powerups_Config[powerup_name].icon)
        Powerups_On_GUI[powerup_name] = nil
    end
end
VZ_EVENT_SUBSCRIBE("Events", "DurationPowerupRemoved", DurationPowerupRemovedGUI)

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
    if IsSelfCharacter(char) then
        CurPerks = {}
        GUI:CallEvent("ResetPerks")
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

VZ_EVENT_SUBSCRIBE("Events", "SetClientRemainingZombies", function(remaining)
    if Remaining_Enemies_Text then
        One_Time_Update_Data.Zombies_Remaining_Number = remaining
        One_Time_Updates_Canvas:Repaint()
    end
end)

function Get3DLocationOnScreen(loc)
    local project = Client.ProjectWorldToScreen(loc)
    if (project and project ~= Vector2D(-1, -1)) then
        return project
    end
end

if ZDEV_IsModeEnabled("ZDEV_DEBUG_HIGHLIGHT_ZOMBIES") then
    local highlight_color = Color(10, 2.5, 0)
    Client.SetHighlightColor(highlight_color, 0, HighlightMode.Always)

    VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
        if key == "EnemyType" then
            if value then
                char:SetHighlightEnabled(true, 0)
            end
        end
    end)

    for k, v in pairs(Character.GetPairs()) do
        if v:GetValue("EnemyType") then
            v:SetHighlightEnabled(true, 0)
        end
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

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "PlayerDown" then
        if not IsSelfCharacter(char) then
            if value then
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

VZ_EVENT_SUBSCRIBE("Events", "UpdateGameTime", function(time_s)
    GAME_TIMER_SECONDS = time_s
end)

VZ_EVENT_SUBSCRIBE("Client", "Tick", function(ds)
    --print(ds)
    if not GAME_PAUSED then
        if Game_Time_On_Screen then
            GAME_TIMER_SECONDS = GAME_TIMER_SECONDS + ds
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

Timer.SetInterval(function()
    local local_char = Client.GetLocalPlayer():GetControlledCharacter()
    local TraceFrom
    if local_char then
        TraceFrom = local_char:GetBoneTransform("head").Location
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

                    local trace = Client.TraceLineSingle(TraceFrom, v:GetLocation(), CollisionChannel.Pawn | CollisionChannel.WorldStatic, trace_mode, ignored_actors)

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

VZ_EVENT_SUBSCRIBE("Character", "Destroy", function(char)
    if Outlined_Characters[char:GetID()] then
        Outlined_Characters[char:GetID()] = nil
    end
end)

if Player_Names_On_Heads then
    PNOH_Canvas = Canvas(
        true,
        Color(0, 0, 0, 0),
        Player_Names_On_Heads_Canvas_Update_Interval_ms / 1000,
        true
    )
    PNOH_Canvas:Subscribe("Update", function(self, width, height)
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
        for k, v in pairs(Character.GetPairs()) do
            local ply = v:GetPlayer()
            if ply then
                if ply ~= Client.GetLocalPlayer() then
                    local char_loc = v:GetLocation()
                    local dist_sq = self_loc:DistanceSquared(char_loc)
                    if dist_sq <= Player_Name_Displayed_at_dist_sq then
                        local Vector_head_text = Get3DLocationOnScreen(char_loc + Vector(0, 0, 97))
                        if Vector_head_text then
                            self:DrawText(
                                ply:GetAccountName(),
                                Vector_head_text,
                                FontType.Roboto,
                                16,
                                Color.AZURE,
                                0,
                                true,
                                true,
                                Color(0, 0, 0, 0),
                                Vector2D(),
                                true,
                                Color.BLACK
                            )
                        end
                    end
                end
            end
        end
    end)
end

if Game_Time_On_Screen then
    GAME_TIME_Canvas = Canvas(
        true,
        Color(0, 0, 0, 0),
        Game_Time_Canvas_Update_Interval_ms / 1000,
        true
    )
    GAME_TIME_Canvas:Subscribe("Update", function(self, width, height)
        local time_seconds = math.floor(GAME_TIMER_SECONDS)
        local minutes = math.floor(time_seconds/60)
        local seconds = time_seconds - (minutes * 60)

        local minutes_text = tostring(minutes)
        if minutes < 10 then
            minutes_text = "0" .. minutes_text
        end
        local seconds_text = tostring(seconds)
        --print(seconds)
        if seconds < 10 then
            seconds_text = "0" .. seconds_text
        end
        self:DrawText(minutes_text .. ":" .. seconds_text, Vector2D(150, Client.GetViewportSize().Y * 0.97), FontType.Oswald, 15, Color.WHITE, 0, false, true, Color.TRANSPARENT, Vector2D(), false, Color.TRANSPARENT)
    end)
end

if Ping_Enabled then
    Ping_Canvas = Canvas(
        true,
        Color(0, 0, 0, 0),
        -1,
        true
    )

    function DrawPing(self, location, text, color)
        local marker_vector2 = Get3DLocationOnScreen(location)
        if marker_vector2 then
            self:DrawPolygon("", marker_vector2, Vector2D(4, 4), 6, Color.YELLOW)
            self:DrawText(text, marker_vector2 + Vector2D(0, 15), FontType.OpenSans, 10, color, 0, true, true, Color.TRANSPARENT, Vector2D(), false, Color.TRANSPARENT)
        end
    end

    Ping_Canvas:Subscribe("Update", function(self, width, height)
        for k, v in pairs(Pings_To_Display) do
            if v.entity then
                if v.entity:IsValid() then
                    if v.entity:GetValue("DoorID") then
                        DrawPing(self, v.location, "Door", v.color)
                    elseif v.entity:GetType() == "Weapon" then
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
                    elseif (v.entity:GetType() == "Character" and v.entity:GetPlayer()) then
                        DrawPing(self, v.entity:GetLocation(), v.entity:GetPlayer():GetAccountName(), v.color)
                    else
                        DrawPing(self, v.location, "Ping", v.color)
                    end
                end
            else
                DrawPing(self, v.location, "Ping", v.color)
            end
        end
    end)

    VZ_EVENT_SUBSCRIBE("Events", "SyncPing", function(color, location, entity)
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