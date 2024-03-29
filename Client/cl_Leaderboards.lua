

VZ_Register_Input("Leaderboard", "I")

Current_Map_Leaderboard = {}

CreateVZFrame(GUI, "Leaderboard", "65%", "65%", "Leaderboard", "Leaderboard", false)
AddVZFrameTab("Leaderboard", "Leaderboard", "Leaderboard")

VZ_EVENT_SUBSCRIBE_REMOTE("SendMapLeaderboard", function(ml, map)
    Current_Map_Leaderboard = ml
    ClearVZFrameTab("Leaderboard", "Leaderboard")

    AddTabText("Leaderboard", "Leaderboard", tostring(map) .. " leaderboard : ")
    AddTabEmptySpace("Leaderboard", "Leaderboard", 35, true)
    for i, v in ipairs(Current_Map_Leaderboard) do
        v.Date = v.Date or "?"
        local players = string.gsub(v.Players, '"', "")
        AddTabText("Leaderboard", "Leaderboard", tostring(i) .. ".   Round " .. tostring(v.Rounds) .. ",   Kills " .. tostring(v.Kills) .. ",   Time " .. tostring(v.Time) .. "s,   Date " .. v.Date .. ",   Players : " .. players)
    end
end)