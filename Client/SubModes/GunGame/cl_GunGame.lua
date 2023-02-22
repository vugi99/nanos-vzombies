

local Total_Weapons = 0

GunGame_Canvas = Canvas(
    true,
    Color(0, 0, 0, 0),
    -1,
    true
)
GunGame_Canvas:Subscribe("Update", function(self, width, height)
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        local gungame_cur_weapon = local_char:GetValue("CurrentWeapon")
        if gungame_cur_weapon then
            local gungame_cur_killcount = local_char:GetValue("WeaponKillCount")
            if gungame_cur_killcount then
                self:DrawText(tostring(VZ_GetGamemodeConfigValue("Kills_To_Next_Weapon") - gungame_cur_killcount) .. " Kills for next weapon", Vector2D(5, math.floor(Viewport.GetViewportSize().Y * 0.55)), FontType.OpenSans, 13, Color.WHITE, 0, false, true, Color(0, 0, 0, 0), Vector2D(), false, Color.BLACK)

                self:DrawText(tostring(gungame_cur_weapon) .. " / " .. tostring(Total_Weapons) .. " Weapon", Vector2D(5, math.floor(Viewport.GetViewportSize().Y * 0.6)), FontType.OpenSans, 16, Color.WHITE, 0, false, true, Color(0, 0, 0, 0), Vector2D(), false, Color.BLACK)
            end
        end
    end
end)
GunGame_Canvas:Repaint()

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if key == "WeaponKillCount" then
        GunGame_Canvas:Repaint()
    end
end)

VZ_EVENT_SUBSCRIBE_REMOTE("GunGame_WeaponsNumber", function(number)
    Total_Weapons = number
    GunGame_Canvas:Repaint()
end)