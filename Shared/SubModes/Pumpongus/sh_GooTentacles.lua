

GooTentacles = Blueprint.Inherit("GooTentacles")

function GooTentacles:Constructor(location, rotation, goo_type)
    if type(goo_type) ~= "number" and type(goo_type) ~= "nil" then
        error("Invalid goo type, expected number")
        return
    end

    if type(goo_type) == "number" then
        if not (goo_type == 1 or goo_type == 2) then
            error("Expected goo type 1 or 2")
            return
        end
    end

    location = location + Vector(0, 0, 100)
    self.Super:Constructor(location or Vector(), rotation or Rotator(), "vzombies-assets::BP_Goo")
    self:CallBlueprintEvent("InitTentacles", goo_type or 1)
    self:SetValue("TentaclesActivated", false, true)
    self:SetValue("CheckRadius", 1234.0, true)
    self:SetValue("GooType", goo_type or 1, true)
end

function GooTentacles:SetConfig(max_checks, min_checks, check_radius, loop_safe)
    self:SetValue("CheckRadius", check_radius or 1234.0, true)
    self:CallBlueprintEvent("SetTentaclesConfig", max_checks or 7, min_checks or 5, check_radius or 1234.0, loop_safe or 3333)
end

function GooTentacles:ActivateTentacles()
    self:CallBlueprintEvent("ActivateTentacles")
    self:SetValue("TentaclesActivated", true, true)
end

function GooTentacles:DeactivateTentacles()
    self:CallBlueprintEvent("DeactivateTentacles")
    self:SetValue("TentaclesActivated", false, true)
end

function GooTentacles:IsTentaclesOut()
    return self:GetValue("TentaclesActivated")
end

-- Search for "TentacleAnchorable" tag on actors to anchor tentacles on specific entities
function GooTentacles:SetSearchAnchorableTag(search)
    self:CallBlueprintEvent("SetSearchAnchorableTag", search)
end

function GooTentacles:ExplodeTentacles()
    self:SetValue("GooExploding", true, true)

    self:CallBlueprintEvent("ExplodeTentacles")
    Timer.SetTimeout(function()
        if self:IsValid() then
            self:Destroy()
        end
    end, 1000)
end

function GooTentacles:SetSphereScale(scale)
    -- default : 0.5, 0.5, 0.369
    self:CallBlueprintEvent("SetSphereScale", scale)
end

--print("GooTentacles class loaded")