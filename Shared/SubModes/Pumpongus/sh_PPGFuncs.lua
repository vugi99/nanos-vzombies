

-- Does the conditions are met for the imposter to activate the end game power ?
function PPG_CanActivateImposterPower()
    local min_activation_round = VZ_GetGamemodeConfigValue("Imposter_Min_Round_Activation")
    if ROUND_NB >= min_activation_round then
        return true
    end
end