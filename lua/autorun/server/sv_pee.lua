if CLIENT then return end


local plymeta = FindMetaTable("Player")

local zip = Sound ("postal2/zipperup.wav")
local unzip = Sound ("postal2/zipperdown.wav")
local pissColor = Color(255,255,255,255) -- this isn't used, currently. piss color is determined by the .vmt associated with whichever piss mode the player is currently using


CreateConVar("piss_holster_on_switch", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "1 = on, 0 = off\nEnables auto-holstering when switching weapons", 0, 1)
CreateConVar("piss_limited", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "1 = on, 0 = off\nEnables limited piss reserves that refill over time", 0, 1)
CreateConVar("piss_force_swep", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "1 = on, 0 = off\nForces using the SWEP to piss (disallows +piss binds)", 0, 1)
CreateConVar("piss_allow_swep_typeswitch", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "1 = on, 0 = off\nEnables right clicking with the piss SWEP to change your piss type", 0, 1)
CreateConVar("piss_rate", "0.03", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Floating point delay between spawned piss particles. Higher = slower piss that looks worse, lower = smoother streams that tank performance (default 0.03)\n", 0, 1)



function DebugPrintPiss()
	print("========")
	for i,ply in ipairs( player.GetAll() ) do
		print(ply)
		print(ply.Piss)
		PrintTable(ply.Piss)
		print("========")
	end
	
end


function plymeta:InitPiss()
	self.Piss = {} --table containing piss-related vars
	self.Piss["Force"] = 300
	self.Piss["Unzipped"] = false
	self.Piss["Pissing"] = false
	self.Piss["NextPiss"] = 0
	self.Piss["NextIncrease"] = 0
	self.Piss["Type"] = 1 -- refer to PISS_TYPES in sh_pee.lua
	self.Piss["PissLevel"] = 100
end

function plymeta:Unzip(new_unzipped)
	if not self:Alive()
	or (engine.ActiveGamemode() == "terrortown" and self:IsSpec()) then return end

	if new_unzipped == self:GetNWBool("unzipped") then return end --return if the new unzip state is the same as our current state... can't exactly whip it out if it's already out, yknow?
	if new_unzipped and not self:GetNWBool("unzipped") then
		self:EmitSound(unzip)
		self:ChatPrint("Unzipped!")
	else
		self:EmitSound(zip)
		self:ChatPrint("Zipped!")
		if self.Piss["Pissing"] then self:StopPissing() end
	end
	self:SetNWBool("unzipped", new_unzipped)
	
end

function plymeta:RefillPiss(amount)
	self:SetNWFloat( "pee_level", self:GetNWFloat("pee_level", 0) + amount)
end

function plymeta:StartPissing()
	self.Piss["Pissing"] = true
	if self.PissSound then self.PissSound:Stop() end
	self.PissSound = CreateSound(self, "postal2/Piss_Start.wav")
	self.PissSound:PlayEx(1, 100)
	self.__pissLoopNext = CurTime() + 1.8
end

function plymeta:StopPissing()
	
	if not self.Piss["Pissing"] then return end
	self:DoPiss(false) -- fire one last particle so the trail looks right
	self.Piss["Pissing"] = false
	self.LastPissParticle = nil
	if self.PissSound then self.PissSound:Stop() end
	self.PissSound = CreateSound(self, "postal2/Piss_End.wav")
	self.PissSound:PlayEx(1, 100)
	
end

function plymeta:IsPissing()
	return self.Piss["Pissing"]
end

local aim_angle = Angle(0,0,0)
function plymeta:DoPiss(pissing)
	if CLIENT then return end
	if not self:Alive()
		or (engine.ActiveGamemode() == "terrortown" and self:IsSpec()) then return end -- keep TTT spectators from pissing... probably better ways to do this and prob needed for other gamemodes as well

	local underwater = self:WaterLevel() > 1

	if GetConVar("piss_limited"):GetBool() and self:GetNWFloat("pee_level", 0) <= 0 then return end -- do we have enough piss, if that feature is enabled?


    local trace = self:GetEyeTrace();
    local ent = ents.Create ("ent_postal_pee");
    local ang = self:GetAimVector():Angle()
	

    local pelvis = "ValveBiped.Bip01_Pelvis"
    local bone = self:LookupBone(pelvis)
    local boneMat = self:GetBoneMatrix(bone)
    local pisspos = boneMat:GetTranslation()

	if not underwater then 
		pisspos = pisspos + boneMat:GetUp()*(1+math.abs(self:GetAimVector().z)*7) -- Spawn the piss a bit closer to the player so it's not so far away, but shift it back out so it doesnt look weird when they piss straight up or down
	end

    ent:SetPos(pisspos)
       ent:SetAngles(ang) 
    ent:SetOwner(self)
    ent:Spawn()

	if underwater then ent:PissCloud() ent:Remove() end

    local phys = ent:GetPhysicsObject();
    
    if IsValid(phys) then
		if GetConVar("piss_allow_swep_typeswitch"):GetBool() then ent.PissType = self.Piss["Type"] else ent.PissType=1 end
		
		--ent.PissDown = self:GetAngles().p > -5 --prevents premature splashing when pissing at a downward angle. the number is entirely arbitrary
		local lock_aim_vector = self:GetAimVector()
		lock_aim_vector.z = lock_aim_vector.z+0.75+(0.75*lock_aim_vector.z)

		phys:ApplyForceCenter (lock_aim_vector:GetNormalized() * self.Piss["Force"]) --little bit of upward force at the end so it properly splashes back down on the player's head when they piss straight up
		
		--piss trail v2
		--gives us a nice stream like in Postal 2
		if IsValid(self.LastPissParticle) then
			local pisstype = PISS_TYPES[self.Piss["Type"]]
			local rope = constraint.Rope(
				self.LastPissParticle, -- ent1
				ent, --ent2
				0, --bone1
				0, --bone2
				Vector(0.5,0,0), --localpos1
				Vector(-0.5,0,0), --localpos2
				ent:GetPos():Distance(self.LastPissParticle:GetPos())*3, --length
				5, --addlength
				0, --forcelimit
				.8, --width
				PISS_MATERIAL[pisstype], --material string
				false, --rigid
				--self.Piss["Color"] --color
				pissColor
			)
		end
		self.LastPissParticle = ent
		ent.DelayPissOwner = CurTime()+1
		if not pissing then return end -- halt the code early because the last particle is just the end of the stream

		self:SetNWFloat( "pee_level", math.Clamp(self:GetNWFloat("pee_level") -0.2, 0, 100))
		--self:SetNWFloat( "peeincrease", CurTime() + 3 )
		self.Piss["NextIncrease"] = CurTime() + 3
	
	
		if not underwater and (self.__pissLoopNext or 0) < CurTime() then
			if self.PissSound then self.PissSound:Stop() end
			self.PissSound = CreateSound(self, "postal2/Piss_Loop.wav")
			self.PissSound:PlayEx(1, 100)
			self.__pissLoopNext = CurTime() + 1.8 -- patch for loop sound no longer working for some reason
		end

		local rate = GetConVar("piss_rate"):GetFloat()
		self.Piss["NextPiss"] = CurTime() + rate

	end
end

hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawnInitPissMod", function( ply )
	ply:InitPiss() -- set up piss mod variables on initial spawn
end )

hook.Add("PlayerSpawn", "PlayerSpawnResetPissStuff", function(ply,t)
    ply:SetNWFloat( "pee_level", 100)
    ply:SetNWBool("unzipped", false)
end)

hook.Add( "PlayerPostThink", "PeeTick", function( ply, mv )
	if !ply:Alive() then
		ply:SetNWFloat( "pee_level", 0 )
		ply:StopPissing()
		return
	elseif ply:GetNWBool("unzipped") and ply.Piss["Pissing"] and CurTime() >= ply.Piss["NextPiss"] then ply:DoPiss(true)
	elseif ply:GetNWFloat("pee_level", 0) < 100 and CurTime() >= ply.Piss["NextIncrease"] then -- refil piss over time
		ply:RefillPiss(0.5)
		ply.Piss["NextIncrease"] = CurTime() + 0.25
	end
end)

