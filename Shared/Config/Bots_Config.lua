

Bots_Enabled = true
No_Players = false -- Won't spawn players, bots will play alone
Bots_Start_Moving_ms = 7500
Max_Bots = 1

Bots_Move_Max_Radius = 2500

Bots_Acceptance_Radius = 80
Bots_Reach_Acceptance_Radius_sq = 300^2

Bots_Remaining_Ammo_Bag_Buy_Refill = 30

Bots_CheckTarget_Interval = 2500
Bots_Target_MaxDistance3D_Sq = 36000000

Bots_Shoot_Inaccuracy_Each_Distance_Unit = 0.02

Bots_Reach_PAP_Around = 100
Bots_Reach_Door_Around = 125

Bots_Ragdoll_Get_Up_Timeout_ms = 10000

Bots_Zombies_Dangerous_Point_Distance_sq = 6250000
Bots_Flee_Zombies_Move_Distance = 750
Bots_Flee_Zombies_Move_Radius = 500
Bots_Flee_Point_Retry_Number = 3

Bots_Smart_Reload_Check_Interval_ms = 2500

Weird_Attack_On_Bots_Unique_Count_Kill = 50 -- If x unique characters do a weird punch on them, they get killed (if they entered ragdoll before that)

Bots_Behavior_Config = {
    "REVIVE",
    "POWER",
    "POWERUPS",
    "WEAPONS",
    "PERKS",
    "PACKAPUNCH",
    "DOORS",
    "MOVE",
}

Bots_Weapons_Ranks = {
    "Makarov",
    "M1911",
    "Glock",
    "ColtPython",
    "DesertEagle",
    "AWP",
    "M1Garand",
    "Lewis",
    "Ithaca37",
    "Moss500",
    "Rem870",
    "SPAS12",
    "SMG11",
    "AP5",
    "UMP45",
    "P90",
    "ASVal",
    "AR4",
    "GE3",
    "GE36",
    "SA80",
    "AK5C",
    "AK74U",
    "AK47",
}

Bots_Perks_Buy_Order = {
    "juggernog",
    "doubletap",
    "speed_cola",
    "stamin_up",
    "three_gun",
    "quick_revive",
}

Bots_Orders = {
    "MoveTo",
    "Follow",
    "StayHere",
}

Outline_Selected_Bot_Color = Color.GREEN
Bot_Select_At_Distance_sq = 250^2
Bot_MoveTo_Order_Distance_From_Camera = 5000
Bot_Follow_Order_Update_Rate = 250