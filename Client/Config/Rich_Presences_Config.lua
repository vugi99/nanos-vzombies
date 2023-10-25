

-------------------------------------------------------------------------------------------------------------------------------
-- Discord Rich Presence

DRP_Enabled = true

DRP_ClientID = 923919278036635719 -- Put 0 for no clientID, large_image and large_text can't work with that

-- Use {ROUND_NB} for the round, {MAP_NAME} for the map name
DRP_CONFIG = {
    state = "In Round {ROUND_NB}",
    details = "Killing Zombies (Nanos World)",
    large_text = "On {MAP_NAME}",
    large_image = "avatar2_upscale",
}

-----------------------------------------------------------------------------------------------------------------------------------
-- Steam Rich Presence

Steam_Rich_Presence_Enabled = true
Steam_Rich_Presence_Text = "VZombies on {MAP_NAME}"