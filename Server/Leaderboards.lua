

Leaderboads_DB = Database(DatabaseEngine.SQLite, "db=VZ_Leaderboards.db timeout=2")

Current_Map_Leaderboard = {}

function InitializeLeaderboardsDatabase()
    Leaderboads_DB:Execute([[
        CREATE TABLE IF NOT EXISTS maps (
            map_asset TEXT,
            leaderboard TEXT
        )
    ]])
end
InitializeLeaderboardsDatabase()


function InitializeMapLeaderboard()
    local rows = Leaderboads_DB:Select("SELECT * FROM maps WHERE map_asset = :0", Server.GetMap())
    if not rows[1] then -- map not registered in database
        Leaderboads_DB:Execute("INSERT INTO maps VALUES ('" .. Server.GetMap() .. "', '[]')")
    else
        Current_Map_Leaderboard = JSON.parse(rows[1].leaderboard)
        local count = table_count(Current_Map_Leaderboard)
        if count > VZ_GetFeatureValue("Leaderboards", "records_saved") then
            for i = VZ_GetFeatureValue("Leaderboards", "records_saved"), count - 1 do
                table.remove(Current_Map_Leaderboard, VZ_GLOBAL_FEATURES.Leaderboards.records_saved + 1)
            end
        end
    end
    --print("InitializeMapLeaderboard", NanosTable.Dump(Current_Map_Leaderboard))
end
InitializeMapLeaderboard()


function SaveMapLeaderboard()
    --print("SaveMapLeaderboard", NanosTable.Dump(Current_Map_Leaderboard), Server.GetMap())
    local stringified_ldb = JSON.stringify(Current_Map_Leaderboard)
    if type(stringified_ldb) == "string" then
        local ldb_sanitized = stringified_ldb:gsub("'", "")
        if type(ldb_sanitized) == "string" then
            Leaderboads_DB:Execute("UPDATE maps SET leaderboard = '" .. ldb_sanitized .. "' WHERE map_asset = '" .. Server.GetMap() .. "'")
            --print(JSON.stringify(Current_Map_Leaderboard))
            Events.BroadcastRemote("SendMapLeaderboard", Current_Map_Leaderboard, Server.GetMap())
        else
            Console.Error("Cannot save leaderboard (2)")
        end
    else
        Console.Error("Cannot save leaderboard (1)")
    end
end


function InsertMapRecordInLB()
    local players_names = {}
    for k, v in pairs(Player.GetPairs()) do
        local waiting
        for k2, v2 in pairs(WAITING_PLAYERS) do
            if v == v2 then
                waiting = true
                break
            end
        end

        if not waiting then
            table.insert(players_names, v:GetAccountName())
        end
    end
    table.insert(Current_Map_Leaderboard, {
        Rounds = ROUND_NB,
        Players = JSON.stringify(players_names),
        Kills = KILL_COUNT,
        Time = math.floor(GAME_TIMER_SECONDS + 0.5),
        Date = os.date("%H:%M %d/%m/%y"),
    })
end

function SortMapLearderboard()
    table.sort(Current_Map_Leaderboard, function(a, b)
        return a.Rounds > b.Rounds
    end)
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_GameEnding", function(restart_game)
    if VZ_GetFeatureValue("Leaderboards", "records_saved") > 0 then
        if ROUND_NB > 0 then
            --print("VZ_GameEnding Bef", NanosTable.Dump(Current_Map_Leaderboard))
            local count = table_count(Current_Map_Leaderboard)
            if count < VZ_GetFeatureValue("Leaderboards", "records_saved") then
                InsertMapRecordInLB()
                SortMapLearderboard()
                SaveMapLeaderboard()
            elseif count == VZ_GetFeatureValue("Leaderboards", "records_saved") then
                if Current_Map_Leaderboard[count].Rounds < ROUND_NB then
                    table.remove(Current_Map_Leaderboard, count)
                    InsertMapRecordInLB()
                    SortMapLearderboard()
                    SaveMapLeaderboard()
                end
            end
            --print("VZ_GameEnding After", NanosTable.Dump(Current_Map_Leaderboard))
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerJoined", function(ply)
    Events.CallRemote("SendMapLeaderboard", ply, Current_Map_Leaderboard, Server.GetMap())
end)