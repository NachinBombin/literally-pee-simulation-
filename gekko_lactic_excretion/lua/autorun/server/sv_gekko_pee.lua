-- sv_gekko_pee.lua
-- Server-side lactic acid excretion system for the Gekko NPC.
-- Extends the NPC metatable with StartLacticPee() and StopLacticPee().
-- Call these from your Gekko ENT:Think() or a custom AI schedule.
--
-- Usage:
--   self:StartLacticPee()   -- begin stream
--   self:StopLacticPee()    -- end stream
--
-- Sound files required (copy from literally-pee-simulation /sound/postal2/):
--   sound/postal2/Piss_Start.wav
--   sound/postal2/Piss_Loop.wav
--   sound/postal2/Piss_End.wav
--
-- Material required (copy from literally-pee-simulation /materials/piss/trails/):
--   materials/piss/trails/pee.vmt
--   materials/piss/trails/pee.vtf  (or _normal.vtf depending on the source)

if CLIENT then return end

local PEE_RATE     = 0.05  -- seconds between drops (lower = denser stream, more expensive)
local PEE_FORCE    = 280   -- forward impulse applied to each drop
local PEE_MATERIAL = "piss/trails/pee"
local PEE_COLOR    = Color(255, 255, 255, 255)
local PEE_SOUND_START = "postal2/Piss_Start.wav"
local PEE_SOUND_LOOP  = "postal2/Piss_Loop.wav"
local PEE_SOUND_END   = "postal2/Piss_End.wav"
local PEE_LOOP_INTERVAL = 1.8 -- Piss_Loop.wav duration; re-trigger before it ends

local function SpawnDrop(npc)
	-- Prefer pelvis bone for spawn position (humanoid skeletons)
	local bone = npc:LookupBone("ValveBiped.Bip01_Pelvis")
	local bmat = bone and npc:GetBoneMatrix(bone)
	local spawnpos = bmat and bmat:GetTranslation() or npc:GetPos()

	local drop = ents.Create("ent_gekko_lactic_drop")
	if not IsValid(drop) then return end

	drop:SetPos(spawnpos)
	drop:SetAngles(npc:GetAngles())
	drop:SetOwner(npc)
	drop.OwnerNPC = npc
	drop:Spawn()

	local phys = drop:GetPhysicsObject()
	if IsValid(phys) then
		-- Aim forward with a slight downward arc (creature excretes forward-down)
		local dir = npc:GetForward()
		dir.z = dir.z - 0.2
		phys:ApplyForceCenter(dir:GetNormalized() * PEE_FORCE)
	end

	-- Connect this drop to the previous one with a rope to form the stream visual
	if IsValid(npc.__lastPeeDrop) then
		constraint.Rope(
			npc.__lastPeeDrop,         -- ent1
			drop,                      -- ent2
			0, 0,                      -- bone1, bone2
			Vector(0.5, 0, 0),         -- localpos1
			Vector(-0.5, 0, 0),        -- localpos2
			drop:GetPos():Distance(npc.__lastPeeDrop:GetPos()) * 3, -- length
			5,                         -- addlength
			0,                         -- forcelimit
			0.8,                       -- width
			PEE_MATERIAL,              -- material
			false,                     -- rigid
			PEE_COLOR                  -- color
		)
	end

	npc.__lastPeeDrop = drop
end

local npcmeta = FindMetaTable("NPC")

-- Begin lactic acid excretion stream
function npcmeta:StartLacticPee()
	if self.__isPeeing then return end
	self.__isPeeing    = true
	self.__lastPeeDrop = nil

	self:EmitSound(PEE_SOUND_START, 75, 100)
	self.__peeLoopNext = CurTime() + PEE_LOOP_INTERVAL

	local timerName = "GekkoLacticPee_" .. self:EntIndex()
	timer.Create(timerName, PEE_RATE, 0, function()
		if not IsValid(self) or not self.__isPeeing then
			timer.Remove(timerName)
			return
		end

		-- Re-trigger loop sound before it ends
		if (self.__peeLoopNext or 0) <= CurTime() then
			self:EmitSound(PEE_SOUND_LOOP, 75, 100)
			self.__peeLoopNext = CurTime() + PEE_LOOP_INTERVAL
		end

		SpawnDrop(self)
	end)
end

-- Stop lactic acid excretion stream
function npcmeta:StopLacticPee()
	if not self.__isPeeing then return end
	self.__isPeeing    = false
	self.__lastPeeDrop = nil
	timer.Remove("GekkoLacticPee_" .. self:EntIndex())
	self:EmitSound(PEE_SOUND_END, 75, 100)
end
