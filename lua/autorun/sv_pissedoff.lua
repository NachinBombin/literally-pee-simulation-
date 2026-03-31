if CLIENT then return end

local PLAYER = FindMetaTable("Player")
local NPC = FindMetaTable("NPC")
local piss_reaction_cooldown = 0.5

CreateConVar("piss_npc_hostile", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "1 = on, 0 = off\nEnables NPC hostility when pissed on", 0, 1)
CreateConVar("piss_npc_disgust", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "1 = on, 0 = off\nEnables NPCs yelling at you for pissing on them", 0, 1)
CreateConVar("piss_player_disgust", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "1 = on, 0 = off\nEnables other players yelling at you for pissing on them", 0, 1)


function PLAYER:OnSplashedWithPiss(pisser, piss)
    if not GetConVar("piss_player_disgust"):GetBool() then return end
    if self.PissReaction and self.PissReactionEndTime and CurTime() < self.PissReactionEndTime then return end

    local model = self:GetModel()
    local npc_from_model = PLAYERMODEL_TO_NPC_PISS_REACTIONS[model]

     -- is the model a generic HL2 citizen?
     local gen = nil
     if string.find(model, "/female_") then
         gen = "f"
     elseif string.find(model, "/male_") then
         gen = "m"
     end
    
    local reaction = GetPissReaction(gen or npc_from_model)
    if reaction == self.LastReaction then reaction = GetPissReaction(gen or npc_from_model) end -- try to avoid repeating the same line twice in a row but don't try *that* hard
    if not reaction then return end -- if at this point we still don't have a valid reaction, fail silently

    self.LastReaction = reaction
    self.PissReaction = nil -- clear the previous reaction. dunno if this helps any but hopefully it helps with garbage collection
    self.PissReaction = CreateSound(self, reaction)
    self.PissReaction:PlayEx(1, 100)
    self.PissReactionEndTime = CurTime()+SoundDuration(reaction)+piss_reaction_cooldown
end


NPC_PISS_ROBOTS = {
    npc_rollermine = true,
    npc_manhack = true,
    npc_clawscanner = true,
    npc_turret_floor = true,
    npc_rollermine_friendly = true,
    npc_cscanner = true,
    npc_turret_ceiling = true,
    npc_combine_camera = true
}



function NPC:OnSplashedWithPiss(pisser, pissent)
    local class = self:GetClass()

    -- if we're pissing on a robot, damage it a bit and then stop there because robots don't talk and shouldn't become hostile from being pissed on
    if NPC_PISS_ROBOTS[class] then
        if self.PissReactionEndTime and CurTime() < self.PissReactionEndTime then return end
        self.PissReactionEndTime = CurTime()+0.1
        self:TakeDamage(2, pisser, pissent)

        self:EmitSound("ambient/energy/spark"..math.random(1, 6)..".wav")
        local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            util.Effect("ManhackSparks", effectData)
        return
    end

    if GetConVar("piss_npc_hostile"):GetBool() then
        self:AddEntityRelationship( pisser, D_FR,99)
        timer.Create(self:EntIndex().."PissedOffBy"..pisser:EntIndex(),3,0, function()
            if IsValid(self) and IsValid(pisser) then self:AddEntityRelationship( pisser, D_HT, 99) end
        end)
    end

    

    

    if not GetConVar("piss_npc_disgust"):GetBool() then return end
    if self.PissReaction and self.PissReactionEndTime and CurTime() < self.PissReactionEndTime then return end
    
    local model = self:GetModel()
    

    -- is the model a generic HL2 citizen?
    local gen = nil
    if string.find(model, "/female_") then
        gen = "f"
    elseif string.find(model, "/male_") then
        gen = "m"
    end

    --select a reaction list
    local reaction = GetPissReaction(gen or class) -- if we've IDed the model as a generic citizen, use the gender; otherwise use the NPC class
    if reaction == self.LastReaction then reaction = GetPissReaction(gen or class) end -- try to avoid repeating the same line twice in a row but don't try *that* hard
    if not reaction then return end -- if at this point we still don't have a valid reaction, fail silently

    self.LastReaction = reaction
    self.PissReaction = nil -- clear the previous reaction. dunno if this helps any but hopefully it helps with garbage collection
    self.PissReaction = CreateSound(self, reaction)
    self.PissReaction:PlayEx(1, 100)
    self.PissReactionEndTime = CurTime()+SoundDuration(reaction)+piss_reaction_cooldown

end

function GetPissReaction(name)
    local reactionlist = NPC_PISS_REACTIONS[name]
    local reaction = nil

    if name == "m" or name == "f" then
        reaction = name
    else
        if not reactionlist or table.IsEmpty(reactionlist) then --fallback in case there's no predefined list
            reactionlist = table.Random(NPC_PISS_REACTIONS)
        end
        if not reactionlist or table.IsEmpty(reactionlist) then return end -- fail silently if we still don't have a valid table
        reaction = reactionlist[math.random(#reactionlist)]
    end

    if reaction == "m" then
        local male_list = NPC_PISS_REACTIONS["m"]
        reaction = male_list[math.random(#male_list)]
    elseif reaction == "f" then
        local female_list = NPC_PISS_REACTIONS["f"]
        reaction = female_list[math.random(#female_list)]
        reaction = string.gsub(reaction, "male01", "female01") -- change the path to quickly
    end
    return reaction
end