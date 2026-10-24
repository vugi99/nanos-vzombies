

local PPG_Voting_Game_Players = {}
local PPG_players_voting = {}
local PPG_Voting_With_Alive_Field = {}
local PPG_votes = {}

local VotesOpen = false

local CurVoteTimer


function PPG_IsValidVote(ply, targetSteamId)
    local char = ply:GetControlledCharacter()
    if (IsValid(char)) then
        if (not char:GetValue("PlayerDown")) then
            if targetSteamId == "skip" then
                return true
            end

            -- Cannot vote yourself
            --[[if ply:GetSteamID() == targetSteamId then
                return false
            end]]--

            for i, v in ipairs(PPG_Voting_With_Alive_Field) do
                if v.id == targetSteamId then
                    if v.alive then
                        return true
                    end
                end
            end
        end
    end
    return false
end


VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerCharacterSpawned", function(char)
    local ply = char:GetPlayer()
    if IsValid(ply) then
        table.insert(PPG_Voting_Game_Players, {name=ply:GetAccountName(), id=ply:GetSteamID()})
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_GameStarting", function()
    PPG_Voting_Game_Players = {}
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_GameEnding", function()
    if CurVoteTimer and Timer.IsValid(CurVoteTimer) then
        Timer.ClearTimeout(CurVoteTimer)
        CurVoteTimer = nil
    end
    VotesOpen = false
    Events.BroadcastRemote("PPG_HideVotingUI", Reliability.Reliable)
    for k, v in pairs(Player.GetPairs()) do
        v:SetVOIPGlobalChannelSetting(3, VOIPSetting.None)
    end
end)

function PPG_BroadcastRemoteWithout(event_name, ply, ...)
    for _, v in pairs(Player.GetPairs()) do
        if v ~= ply then
            Events.CallRemote(event_name, v, ...)
        end
    end
end


function PPG_MakeVotingWithAliveField()
    PPG_Voting_With_Alive_Field = {}

    for i, v in ipairs(PPG_Voting_Game_Players) do
        local found
        for k2, v2 in pairs(PPG_players_voting) do
            if IsValid(v2) then
                if v2:GetSteamID() == v.id then
                    table.insert(PPG_Voting_With_Alive_Field, TableDeepCopy(v))
                    PPG_Voting_With_Alive_Field[#PPG_Voting_With_Alive_Field].alive = true
                    found = true
                    break
                end
            end
        end

        if not found then
            table.insert(PPG_Voting_With_Alive_Field, TableDeepCopy(v))
            PPG_Voting_With_Alive_Field[#PPG_Voting_With_Alive_Field].alive = false
        end
    end
end

function PPG_BuildVotingConfigPlayers(wo_ply)
    PPG_players_voting = GetPlayersAliveWO(wo_ply)
    PPG_MakeVotingWithAliveField()
end

function PPG_CalculateVoteResults()
    local Voting_Count = #GetPlayersAlive()
    local votes_on = {}

    for voter, target in pairs(PPG_votes) do
        votes_on[target] = (votes_on[target] or 0) + 1
    end

    local most_votes_plysids = {}
    for plysid, votes in pairs(votes_on) do
        if (#most_votes_plysids == 0) or votes > votes_on[most_votes_plysids[1]] then
            most_votes_plysids = {plysid}
        elseif votes == votes_on[most_votes_plysids[1]] then
            table.insert(most_votes_plysids, plysid)
        end
    end

    if (#most_votes_plysids == 0) then
        return {type="no_votes"}
    end

    for i, v in ipairs(most_votes_plysids) do
        if v == "skip" then
            return {type="skip_wins"}
        end
    end

    local most_ratio = votes_on[most_votes_plysids[1]]/Voting_Count
    if (most_ratio < VZ_GetGamemodeConfigValue("Voting_Required_Ratio_To_Eliminate")) then
        return {type="no_one_eliminated", most_ratio=most_ratio, most_players=most_votes_plysids, count=votes_on[most_votes_plysids[1]]}
    else
        if (#most_votes_plysids > 1) then
            return {type="tie", most_ratio=most_ratio, ties=most_votes_plysids, count=votes_on[most_votes_plysids[1]]}
        else
            return {type="eliminate", most_ratio=most_ratio, eliminated=most_votes_plysids[1], count=votes_on[most_votes_plysids[1]]}
        end
    end
end

function PPG_HandleResults(results)
    if (results.type == "no_votes") then
        Chat.BroadcastMessage("[Votes] No votes this round!")
    elseif (results.type == "skip_wins") then
        Chat.BroadcastMessage("[Votes] Skip won!")
    elseif (results.type == "no_one_eliminated") then
        Chat.BroadcastMessage("[Votes] Votes were too splited to eliminate someone!")
    elseif (results.type == "tie") then
        Chat.BroadcastMessage("[Votes] Tie!")
    elseif (results.type == "eliminate") then
        local el_name
        for i, v in ipairs(PPG_Voting_Game_Players) do
            if v.id == results.eliminated then
                el_name = v.name
                break
            end
        end
        Chat.BroadcastMessage("[Votes] " .. tostring(el_name) .. " got <red>eliminated</>! (" .. tostring(results.count) .. " votes)" )

        local found
        for k, v in pairs(PLAYING_PLAYERS) do
            if v:GetSteamID() == results.eliminated then
                found = true

                local char = v:GetControlledCharacter()
                if IsValid(char) then
                    PlayerCharacterDie(char, true)
                else
                    print("Eliminated char is not valid, he is already eliminated (sid: " .. tostring(results.eliminated) .. ", name: " .. tostring(el_name) .. ")")
                end
                break
            end
        end

        if not found then
            print("Could not find eliminated player (sid: " .. tostring(results.eliminated) .. ", name: " .. tostring(el_name) .. ") to 'eliminate' him properly. Maybe he has left?")
        end
    end
end

function PPG_FinishVote()
    if VotesOpen then
        if CurVoteTimer and Timer.IsValid(CurVoteTimer) then
            Timer.ClearTimeout(CurVoteTimer)
            CurVoteTimer = nil
        end
        VotesOpen = false
        PPG_BuildVotingConfigPlayers()
        local results = PPG_CalculateVoteResults()
        PPG_HandleResults(results)
        Events.BroadcastRemote("PPG_VotingPhaseClosed", Reliability.Reliable, PPG_Voting_With_Alive_Field, results)

        CurVoteTimer = Timer.SetTimeout(function()
            CurVoteTimer = nil
            Events.BroadcastRemote("PPG_HideVotingUI", Reliability.Reliable)

            for k, v in pairs(PLAYING_PLAYERS) do
                v:SetVOIPGlobalChannelSetting(3, VOIPSetting.None)
            end

            if ROUND_NB > 0 then
                if WaitingNewRound_Timer then
                    Timer.ClearTimeout(WaitingNewRound_Timer)
                    WaitingNewRound_Timer = nil
                    NewRoundTimer_Func()
                end
            end
        end, VZ_GetGamemodeConfigValue("Results_Time_ms"))
    end
end

function PPG_HasEveryoneVoted()
    --print(NanosTable.Dump(PPG_players_voting), NanosTable.Dump(PPG_votes))
    for k, v in pairs(PPG_players_voting) do
        if not IsValid(v) then
            --print(v, "not valid")
            return false
        end
        if not v.BOT then
            local found
            for k2, v2 in pairs(PPG_votes) do
                if v:GetSteamID() == k2 then
                    found = true
                end
            end

            if not found then
                --print(v, "not found in votes")
                return false
            end
        end
    end
    return true
end

function PPG_CheckFinishVote()
    if VotesOpen then
        if PPG_HasEveryoneVoted() then
            PPG_FinishVote()
        end
    end
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_WaveFinished", function(wave_nb)
    if IsValid(VZ_PPG_IMPOSTER) then
        --print("VZ_WaveFinished", "Start PPG Vote")

        local imp_char = VZ_PPG_IMPOSTER:GetControlledCharacter()
        -- Do not start votes when imposter is activated
        if (IsValid(imp_char) and (not imp_char:GetValue("PPG_Imposter_Activated"))) then
            PPG_votes = {}
            PPG_BuildVotingConfigPlayers()

            Events.BroadcastRemote("PPG_StartDiscussionPhase", Reliability.Reliable, PPG_Voting_With_Alive_Field)

            for k, v in pairs(PLAYING_PLAYERS) do
                local char = v:GetControlledCharacter()
                if (IsValid(char) and (not char:GetValue("PlayerDown"))) then
                    v:SetVOIPGlobalChannelSetting(3, VOIPSetting.Both)
                end
            end

            if CurVoteTimer and Timer.IsValid(CurVoteTimer) then
                Timer.ClearTimeout(CurVoteTimer)
                CurVoteTimer = nil
            end

            CurVoteTimer = Timer.SetTimeout(function()
                if ROUND_NB > 0 then
                    if IsValid(VZ_PPG_IMPOSTER) then
                        -- Discuss time finished, votes opened !
                        PPG_BuildVotingConfigPlayers()
                        Events.BroadcastRemote("PPG_StartVotingPhase", Reliability.Reliable, PPG_Voting_With_Alive_Field)

                        VotesOpen = true

                        CurVoteTimer = Timer.SetTimeout(PPG_FinishVote, VZ_GetGamemodeConfigValue("Voting_Time_ms"))

                        PPG_CheckFinishVote()
                    end
                end
            end, VZ_GetGamemodeConfigValue("Discuss_Time_ms"))
        end
    end
end)

--[[VZ_EVENT_SUBSCRIBE("Events", "VZ_WaveStarted", function(wave_nb)
    if IsValid(VZ_PPG_IMPOSTER) then
        Events.BroadcastRemote("PPG_HideVotingUI", Reliability.Reliable)
    end
end)]]--

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_PlayerVote", function(ply, targetSteamId)
    if VotesOpen then
        if PPG_IsValidVote(ply, targetSteamId) then
            PPG_votes[ply:GetSteamID()] = targetSteamId
            PPG_BroadcastRemoteWithout("PPG_SyncVote", ply, Reliability.Reliable, ply:GetSteamID(), targetSteamId)
            PPG_CheckFinishVote()
        end
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerLeft", function(ply)
    if VotesOpen then
        PPG_votes[ply:GetSteamID()] = nil
        PPG_BroadcastRemoteWithout("PPG_SyncVote", ply, Reliability.Reliable, ply:GetSteamID(), nil)

        PPG_BuildVotingConfigPlayers(ply)
        PPG_BroadcastRemoteWithout("PPG_VotingSetPlayers", ply, Reliability.Reliable, PPG_Voting_With_Alive_Field)
        PPG_CheckFinishVote()
    end
end)

VZ_EVENT_SUBSCRIBE("Events", "VZ_CharacterDown", function(char)
    local ply = char:GetPlayer()
    if IsValid(ply) then
        if VotesOpen then
            PPG_votes[ply:GetSteamID()] = nil
            Events.BroadcastRemote("PPG_SyncVote", Reliability.Reliable, ply:GetSteamID(), nil)

            PPG_BuildVotingConfigPlayers(ply)
            Events.BroadcastRemote("PPG_VotingSetPlayers", Reliability.Reliable, PPG_Voting_With_Alive_Field)
            PPG_CheckFinishVote()
        end
    end
end)