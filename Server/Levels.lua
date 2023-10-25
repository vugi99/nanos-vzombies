

Levels_DB = Database(DatabaseEngine.SQLite, "db=VZ_Levels.db timeout=2")

function InitializeLevelsTable()
    Levels_DB:Execute('CREATE TABLE IF NOT EXISTS levels' .. [[ (
            steamid VARCHAR(255),
            xp INTEGER,
            level INTEGER
        )
    ]])
end
InitializeLevelsTable()

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerJoined", function(ply)
    if not ply.BOT then
        local rows = Levels_DB:Select("SELECT * FROM levels WHERE steamid = :0", tostring(ply:GetSteamID()))
        if not rows[1] then
            Levels_DB:Execute("INSERT INTO levels VALUES (" .. tostring(ply:GetSteamID()) .. ", 0, 1)")
            ply:SetValue("PlayerLevel", 1, false)
            ply:SetValue("PlayerXP", 0, false)
        else
            ply:SetValue("PlayerLevel", rows[1].level, false)
            ply:SetValue("PlayerXP", rows[1].xp, false)
            CheckLevelUp(ply)
        end
        Events.CallRemote("PlayerLevelXPUpdate", ply, ply:GetValue("PlayerLevel"), ply:GetValue("PlayerXP"))
    end
end)

function SavePlayerLevelData(ply, async_q)
    --print("SavePlayerLevelData")
    if not ply.BOT then
        if ply:GetValue("PlayerStoredMoney") then
            local query = "UPDATE levels SET xp=" .. tostring(ply:GetValue("PlayerXP")) .. ", level=" .. tostring(ply:GetValue("PlayerLevel")) .. "  WHERE steamid = " .. tostring(ply:GetSteamID())
            if async_q then
                Levels_DB:ExecuteAsync(query)
            else
                Levels_DB:Execute(query)
            end
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerLeft", SavePlayerLevelData)
VZ_EVENT_SUBSCRIBE("Package", "Unload", function()
    --print("Unload")
    for k, v in pairs(Player.GetPairs()) do
        SavePlayerLevelData(v)
        v:SetValue("PlayerXP", nil, false)
        v:SetValue("PlayerLevel", nil, false)
    end
    Levels_DB:Close()
end)

function CheckLevelUp(ply, has_level_up)
    local XP_target = VZ_GetFeatureValue("Levels", "levels_xp_func")(ply:GetValue("PlayerLevel"))
    if ply:GetValue("PlayerXP") >= XP_target then
        ply:SetValue("PlayerXP", ply:GetValue("PlayerXP") - XP_target, false)
        ply:SetValue("PlayerLevel", ply:GetValue("PlayerLevel") + 1, false)
        CheckLevelUp(ply, true)
    elseif has_level_up then
        SavePlayerLevelData(ply, true)
    end
end

function AddPlayerXP(ply, added)
    if (ply and ply:IsValid()) then
        if not ply.BOT then
            if (added and added > 0) then
                if ply:GetValue("PlayerXP") then
                    ply:SetValue("PlayerXP", ply:GetValue("PlayerXP") + added, false)
                    CheckLevelUp(ply)
                end
            end
        end
    end
end