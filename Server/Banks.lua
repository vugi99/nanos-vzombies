

Banks_DB = Database(DatabaseEngine.SQLite, "db=VZ_Banks.db timeout=2")

function SGetMapForTableName()
    return '"' .. Server.GetMap() .. '"'
end

function InitializeMapBankTable()
    Banks_DB:Execute('CREATE TABLE IF NOT EXISTS ' .. SGetMapForTableName() .. [[ (
            steamid VARCHAR(255),
            stored INTEGER
        )
    ]])
end
InitializeMapBankTable()

if BANKS then
    for k, v in pairs(BANKS) do
        local bank = StaticMesh(v.location, v.rotation, VZ_GetFeatureValue("Banks", "Model"))
        bank:SetScale(VZ_GetFeatureValue("Banks", "Scale"))
        bank:SetValue("MapBank", true, true)
    end
end

VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerJoined", function(ply)
    if not ply.BOT then
        local rows = Banks_DB:Select("SELECT * FROM " .. SGetMapForTableName() .. " WHERE steamid = :0", tostring(ply:GetSteamID()))
        if not rows[1] then
            Banks_DB:Execute("INSERT INTO " .. SGetMapForTableName() .. " VALUES (" .. tostring(ply:GetSteamID()) .. ", 0)")
            ply:SetValue("PlayerStoredMoney", 0, true)
        else
            ply:SetValue("PlayerStoredMoney", rows[1].stored, true)
        end
    end
end)

function SaveBankData(ply)
    if not ply.BOT then
        if ply:GetValue("PlayerStoredMoney") then
            Banks_DB:Execute("UPDATE " .. SGetMapForTableName() .. " SET stored=" .. tostring(ply:GetValue("PlayerStoredMoney")) .. " WHERE steamid = " .. tostring(ply:GetSteamID()))
        end
    end
end
VZ_EVENT_SUBSCRIBE("Events", "VZ_PlayerLeft", SaveBankData)
VZ_EVENT_SUBSCRIBE("Package", "Unload", function()
    for k, v in pairs(Player.GetPairs()) do
        if not v.BOT then
            SaveBankData(v)
            v:SetValue("PlayerStoredMoney", nil, true)
        end
    end
    Banks_DB:Close()
end)

VZ_EVENT_SUBSCRIBE_REMOTE("BankAction", function(ply, bank, action)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if (char and char:IsValid()) then
            if not char:GetValue("PlayerDown") then
                if (bank and bank:IsValid() and bank:GetValue("MapBank")) then
                    local amount = VZ_GetFeatureValue("Banks", "Money_WD_Amount")
                    if action == "Deposit" then
                        local d_fees = VZ_GetFeatureValue("Banks", "D_Fees")
                        local max_money = VZ_GetFeatureValue("Banks", "Max_Money")
                        if ply:GetValue("PlayerStoredMoney") < max_money then
                            if ply:GetValue("PlayerStoredMoney") + amount > max_money then
                                amount = max_money - ply:GetValue("PlayerStoredMoney")
                            end
                            if Buy(ply, d_fees + amount) then
                                ply:SetValue("PlayerStoredMoney", ply:GetValue("PlayerStoredMoney") + amount, true)
                            end
                        else
                            Events.CallRemote("AddNotification", ply, "Bank Full")
                        end
                    elseif action == "Withdraw" then
                        if ply:GetValue("PlayerStoredMoney") > 0 then
                            if ply:GetValue("PlayerStoredMoney") - amount < 0 then
                                amount = ply:GetValue("PlayerStoredMoney")
                            end
                            ply:SetValue("PlayerStoredMoney", ply:GetValue("PlayerStoredMoney") - amount, true)
                            --ply:SetValue("ZMoney", ply:GetValue("ZMoney") + amount, true)
                            AddMoney(ply, amount, true)
                        end
                    end
                end
            end
        end
    end
end)

