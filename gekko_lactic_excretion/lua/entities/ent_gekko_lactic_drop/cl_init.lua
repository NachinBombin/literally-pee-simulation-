include("shared.lua")

-- The drop entity is invisible; all visuals come from the rope trail and splash particles.
function ENT:Draw()
	return false
end

function ENT:IsTranslucent()
	return true
end
