AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- ent_gekko_lactic_drop
-- A single physics projectile that forms one segment of the lactic acid stream.
-- Spawned rapidly by sv_gekko_pee.lua and connected via rope constraints to create a stream.

function ENT:Initialize()
	self:SetModel("models/dav0r/hoverball.mdl")
	self:SetMaterial("Models/effects/vol_light001")
	self:PhysicsInitSphere(1)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetTrigger(true)
	self:SetModelScale(0.1)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableGravity(true)
		phys:SetMass(1)
	end

	self.Splashed = false
	self.MaxLifetime = CurTime() + 5
	self:NextThink(CurTime() + 0.15)
end

function ENT:Think()
	if self.Splashed then return false end
	if self.MaxLifetime < CurTime() then self:Remove() return false end
	self:NextThink(CurTime() + 0.15)
	return true
end

function ENT:Touch(ent)
	-- Ignore the owner NPC to prevent self-splash on spawn
	if ent == self.OwnerNPC then return end
	self:DoSplash()
end

function ENT:PhysicsCollide(data, phys)
	self:DoSplash()
end

function ENT:DoSplash()
	if self.Splashed then return end
	self.Splashed = true

	-- Reuse the GMod built-in slime splash particle
	ParticleEffect("slime_splash_01_droplets", self:GetPos(), self:GetAngles())

	-- Trigger the lactic acid mist cloud client-side effect
	local eff = EffectData()
	eff:SetOrigin(self:GetPos())
	eff:SetNormal(Vector(0, 0, 1))
	util.Effect("gekko_lactic_cloud", eff)

	-- Freeze physics then remove on next frame
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	timer.Simple(0.03, function()
		if IsValid(self) then self:Remove() end
	end)
end
