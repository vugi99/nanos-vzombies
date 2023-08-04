

VZ_EVENT_SUBSCRIBE("Player", "Possess", function(ply, char)
    if (ply and char and ply:IsValid() and char:IsValid()) then
        char:SetViewMode(ViewMode.TopDown)
    end
end)