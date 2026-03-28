

local VotesOpen = false


local function VotingGetLocalId()
    local char = GetLocalCharacter()
    if IsValid(char) then
        if not char:GetValue("PlayerDown") then
            return Client.GetLocalPlayer():GetSteamID()
        end
    end

    return "spectator"
end

local function VotingConfigure(voting_alive, show_voting_ui, keep_votes)
    local config_passed = {players=voting_alive, LocalId=VotingGetLocalId()}

    --print("VotingConfigure", NanosTable.Dump(config_passed))

    PPG_UI:CallEvent("VotingUIInit", JSON.stringify(config_passed), keep_votes)
    if show_voting_ui then
        PPG_UI_ShowVoting(true)
    end
end

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_StartDiscussionPhase", function(PPG_Voting_With_Alive_Field)
    VotingConfigure(PPG_Voting_With_Alive_Field, true)
    PPG_UI:CallEvent("VotingUICall", "startDiscuss", (math.floor(VZ_GetGamemodeConfigValue("Discuss_Time_ms")/1000)))
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_StartVotingPhase", function(PPG_Voting_With_Alive_Field)
    VotesOpen = true

    VotingConfigure(PPG_Voting_With_Alive_Field)
    PPG_UI:CallEvent("VotingUICall", "startVoting", (math.floor(VZ_GetGamemodeConfigValue("Voting_Time_ms")/1000)))
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_VotingPhaseClosed", function(PPG_Voting_With_Alive_Field, results)
    VotesOpen = false
    VotingConfigure(PPG_Voting_With_Alive_Field, false, true)

    --print("PPG_VotingPhaseClosed", NanosTable.Dump(PPG_Voting_With_Alive_Field), NanosTable.Dump(results), JSON.stringify(results))
    PPG_UI:CallEvent("VotingUIShowResults", JSON.stringify(results), (math.floor(VZ_GetGamemodeConfigValue("Results_Time_ms")/1000)))
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_HideVotingUI", function()
    PPG_UI_ShowVoting(false)
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_SyncVote", function(voterId, targetSteamId)
    PPG_UI:CallEvent("VotingUICall", "castVote", voterId, targetSteamId)
end)

VZ_EVENT_SUBSCRIBE_REMOTE("PPG_VotingSetPlayers", function(players)
    PPG_UI:CallEvent("VotingUISetPlayers", JSON.stringify(players))
end)

VZ_EVENT_SUBSCRIBE("Character", "ValueChange", function(char, key, value)
    if VotesOpen then
        if key == "PlayerDown" then
            if value then
                if IsSelfCharacter(char) then
                    PPG_UI:CallEvent("VotingUICall", "setLocalId", "spectator")
                end
            end
        end
    end
end)

PPG_UI:Subscribe("VotingUIClosed", function()
    PPG_UI_ShowVoting(false, true)
end)

PPG_UI:Subscribe("LocalPlayerVote", function(targetId)
    Events.CallRemote("PPG_PlayerVote", targetId)
end)
