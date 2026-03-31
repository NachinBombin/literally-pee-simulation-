local smokeparticles = {
	"particle/particle_smokegrenade",
	"particle/particle_noisesphere"
 }


function EFFECT:Init(data)
	if not GetConVar("piss_water_clouds"):GetBool() or GetConVar("piss_clean"):GetBool() or GetConVar("piss_hide"):GetBool() then return end
	
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	if not IsValid(LocalPlayer().PISSCLOUDEMITTER) then LocalPlayer().PISSCLOUDEMITTER = ParticleEmitter(pos) end
	local cloud_particle = LocalPlayer().PISSCLOUDEMITTER:Add(table.Random(smokeparticles), pos)
		cloud_particle:SetVelocity(norm * -.5 + VectorRand() * 2)
		cloud_particle:SetStartAlpha(125)
		cloud_particle:SetEndAlpha(0)
		cloud_particle:SetStartSize(1)
		cloud_particle:SetEndSize(math.Rand(16, 20))
		cloud_particle:SetRoll(180)
		cloud_particle:SetDieTime(3)
		cloud_particle:SetColor(155, 155, 0)
	LocalPlayer().PISSCLOUDEMITTER:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
