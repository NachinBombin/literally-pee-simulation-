AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PissDown = false
ENT.Splashed = false
ENT.Phys = nil
ENT.PissType = 1

peeCloudEffectData = EffectData()


/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()

	if !IsValid(self.Owner) then self:Remove() return end

	self.Entity:SetModel("models/dav0r/hoverball.mdl")
	self:SetMaterial("Models/effects/vol_light001")
	self:PhysicsInitSphere(1)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.Entity:SetTrigger(true)
	
	local phys = self.Entity:GetPhysicsObject()
	phys:EnableGravity( true )
	phys:SetMass(1)

	self.Entity:SetModelScale(.1)
	self.MaxLifetime = CurTime() + 5
	self:NextThink(CurTime()+0.15)
end

function ENT:Think()
	if self.Splashed then self:NextThink(CurTime()+69) return end --Redundant
	if self.MaxLifetime < CurTime() then self:Remove() end
	if self.Entity:WaterLevel() > 1 then
		if self.PissType == 3 then
			/* -- this doesnt work super well but someday i want to make it so napalm will float on water
			local startPos = self:GetPos()
			local traceData = {
				start = startPos,
				endpos = startPos + self:GetUp() * 5,
				mask = MASK_WATER + MASK_SOLID
			}
			local trace = util.TraceLine(traceData)
			if trace.Hit then
				if trace.MatType ~= MAT_WATER then
					self:SetPos(trace.HitPos)
				end
			end
			self:Napalm() 
			*/
			self.Splashed = true
			self:Remove()
		else
			ParticleEffect( "slime_splash_01_droplets", self:GetPos(), self:GetAngles() )
			self:PissCloud()
			self:Remove()
			return
		end
	end
	self:NextThink(CurTime()+0.15)
end

function ENT:Touch(object)
	if object == self.Owner
		and CurTime() <= self.DelayPissOwner or self:GetVelocity().z > 0 then -- only splash the player if the piss is falling or after a 1-second delay to prevent accidentally pissing on yourself when aiming down
		return
	end 	
	self:Splash(object)
end

function ENT:PhysicsCollide(data, object) --for world collision
	self:Splash(data.HitEntity)
end

function ENT:PissCloud()
	peeCloudEffectData:SetEntity( self )
	peeCloudEffectData:SetScale (1)
	peeCloudEffectData:SetOrigin( self:GetPos() )
	util.Effect( 'pee_cloud', peeCloudEffectData )
end

function ENT:Splash(obj)
	--if CLIENT then return end
	if self.Splashed then return end
	
	if obj == game.GetWorld() then --if we splashed the world, do a sphere check for flame entities
		if self.PissType == 3 then
			self:Napalm(obj, self:GetPos())
		else
			for _,thing in pairs (ents.FindInSphere(self:GetPos(), 18)) do
				if thing:GetClass() == "ent_postal_pee" then goto SKIPOTHERPISS end --gnore other piss particles entirely, saving... oh boy two checks that would return false anyway. no idea if this actually does much for performance

				if thing:GetClass() == "ttt_flame" then --ttt_flame will remove itself when dietime is 0
					thing.dietime = flame.dietime -1
				elseif thing:GetClass() == "vfire" then -- vfire support
					thing:SoftExtinguish(1)
				elseif thing:GetClass() == "env_fire" then --env_fire should be checked after ttt_flame, because it has its own env_fire and we don't want to touch that directly
					thing:SetKeyValue("health", thing:GetInternalVariable("health") - 1)
					if thing:GetInternalVariable("health") <= 0 then thing:Fire("Extinguish") end
				end
			end
		end
		::SKIPOTHERPISS:: -- wow this is not great code lmao
	else
		
		if self.PissType == 3 then
			obj:Ignite(20)
		else
			if obj: IsOnFire() then obj:Extinguish() end
			if obj == self.Owner then
			if not obj.PissReaction or (obj.PissReactionEndTime and CurTime() > obj.PissReactionEndTime) then
				if GetConVar("piss_player_disgust"):GetBool() then
					obj.PissReaction = CreateSound(self.Owner, "postal2/Dude_pissingonself.wav")
					obj.PissReaction:PlayEx(1, 100)
					obj.PissReactionEndTime = CurTime()+SoundDuration("postal2/Dude_pissingonself.wav")
				end
			end
			elseif obj.OnSplashedWithPiss then --support for other addons
				obj:OnSplashedWithPiss(self.Owner, self)
			elseif obj:IsNPC() then
				if GetConVar("piss_npc_hostile"):GetBool() then
					local pisser = self.Owner
					obj:AddEntityRelationship( pisser, D_FR,99)
					timer.Create(obj:EntIndex().."PissedOffBy"..pisser:EntIndex(),3,0, function()
						if IsValid(obj) and IsValid(pisser) then obj:AddEntityRelationship( pisser, D_HT,99) end
					end)
				end
			elseif obj:GetClass() == "npc_civ" then --theoretical patch for Civs - Wandering NPCs
				obj:FreakOut(self.Owner:GetPos(), self.Owner, "hurt")
			end 
		end
	end

	--visual stuff
	ParticleEffect( "slime_splash_01_droplets", self:GetPos(), self:GetAngles() )
	self.Entity:GetPhysicsObject():EnableMotion(false)
	self.Splashed = true
	self:NextThink(CurTime()+69) --We continue to exist for an additional 0.05 seconds after splashing, which isn't very long but that's still maybe a Tick saved
	timer.Simple(0.03, function() --disable motion and then remove 0.035 seconds later so the rope to the next particle doesn't disappear prematurely
		if IsValid(self) then self.Entity:Remove() end
	end)
end

function ENT:Napalm(parent, pos)
	for k, ent in ipairs(ents.FindInSphere(self:GetPos(), 10)) do
		if IsValid(ent) and ent:GetClass() == "env_fire" then return end -- prevent spamming a SHITLOAD of env_fire entities
		-- we don't need to do this check for vfire, because it already does something similar
	end
	local vfire = scripted_ents.GetStored("vfire")

	if vfire then
		CreateVFire(parent, pos, self:GetUp(), 5, self.Owner)
	else
		local fire = ents.Create("env_fire")
			fire:SetKeyValue("health", 20)

			fire:SetKeyValue("fireattack", 10)
			fire:SetKeyValue("ignitionpoint", 10)
			fire:SetKeyValue("damagescale", 25)
			--fire:SetParent(parent or nil)
			fire:Fire("AddOutput", "OnExtinguished !self,Kill", 0)

			--no glow + delete when out + start on + last forever
			fire:SetKeyValue("spawnflags", tostring(128 + 32 + 16 + 4 + 2 + 0))
			fire:SetKeyValue("firesize", math.Rand(15, 25))
			fire:SetPos(pos)
			fire:SetPhysicsAttacker(self.Owner)
			fire:SetOwner(self.Owner)
			fire:Spawn()
			fire:Activate()
	end
end