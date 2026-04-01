-- gekko_lactic_cloud
-- Client-side mist/vapor cloud spawned on each drop splash.
-- Greenish-yellow tint to sell the lactic acid lore.
-- Adapted from pee_cloud.lua in literally-pee-simulation, stripped of all ConVar checks.

local SMOKE_PARTICLES = {
	"particle/particle_smokegrenade",
	"particle/particle_noisesphere"
}

local emitter -- persistent emitter, created once and reused

function EFFECT:Init(data)
	local pos  = data:GetOrigin()
	local norm = data:GetNormal()

	if not IsValid(emitter) then
		emitter = ParticleEmitter(pos)
	end

	local p = emitter:Add(table.Random(SMOKE_PARTICLES), pos)
	if p then
		p:SetVelocity(norm * -0.5 + VectorRand() * 2)
		p:SetStartAlpha(110)
		p:SetEndAlpha(0)
		p:SetStartSize(1)
		p:SetEndSize(math.Rand(14, 18))
		p:SetRoll(180)
		p:SetDieTime(3)
		p:SetColor(180, 200, 20) -- greenish-yellow: lactic acid
	end

	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end
