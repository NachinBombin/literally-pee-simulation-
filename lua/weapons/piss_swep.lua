if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Piss Swep"
SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.Category = "VladiMatt's Silly Shit"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"
SWEP.Base = "weapon_base"
SWEP.Spawnable = true

SWEP.Instructions = "RELOAD to zip/unzip\nPrimaryFire to piss"
SWEP.Icon = "materials/piss/balls.png"

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.AllowDelete            = false
SWEP.AllowDrop              = false
SWEP.NoSights               = true
SWEP.isPissSWEP = true


SWEP.Hold = {normal = "normal", dicks_out = "normal"} --was using the "passive" hold type for a while cause from certain angles it looks like you're holding your dick, but it doesnt work when crouched so for now this doesnt do anything

SWEP.firsttimenotify = false

SWEP.ShowWorldModel = false
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = false
SWEP.DrawAmmo = false
SWEP.Ammo = nil

function SWEP:Initialize()
    self:SetHoldType( self.Hold.normal )
    self:SetNextPrimaryFire(CurTime()+0.03)
end

local nextZip = 0
function SWEP:Reload()
    if CurTime() < nextZip then return false end
    if CLIENT then return end
    self.Owner:Unzip(not self.Owner:GetNWBool("unzipped"))

    nextZip = CurTime()+0.8
end

if SERVER then
    function SWEP:Deploy()
        if self.firsttimenotify then return end
        self.firsttimenotify = true
        self.Owner:ChatPrint("Press RELOAD to unzip, and FIRE to piss\nAlso you can bind keys to 'unzip' and '+piss' or type '!unzip' in chat if the server has 'piss_force_swep' turned off")
    end
end


 
if CLIENT then
    function SWEP:DrawWorldModel()
        self:SetHoldType( self.Owner:GetNWBool("unzipped") and self.Hold.dicks_out or self.Hold.normal)
    end
end


function SWEP:CanPrimaryAttack()
    return true
end

function SWEP:CanSecondaryAttack()
    return true
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:OnDrop()
    self:Remove()
 end

function SWEP:Holster()
    if SERVER then
        if GetConVar("piss_holster_on_switch"):GetBool() then
            if self.Owner:GetNWBool("unzipped") then
                self:GetOwner():Unzip(false)
            end
        end
    end
    return true
end

function SWEP:PrimaryAttack()
    --[[if CLIENT then return end
    if self.Owner:GetNWBool("unzipped") then
        self:SetNextPrimaryFire(CurTime()+0.03)
        if not self.Pissing then
            self.Owner:ConCommand("+piss")
            self.Pissing = true
        end
        
    end
    return false]]
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    local ply = self.Owner
    ply:ConCommand("piss_type")

    --eventually i want to add a radial menu or something here to make it easier to quick switch types
end


function SWEP:Think()
    --if CLIENT or not self.Pissing then return end
    --[[if not self.Owner:KeyDown(IN_ATTACK) then self.Owner:ConCommand("-piss") self.Pissing = false end
    --if we're due to stop pissing, stop pissing
    if self.Pissing and CurTime() > self:GetNextPrimaryFire()+0.015 then
        --self.Owner:ConCommand("-piss")
        --self.Pissing = false
    end]]
 
    -- this is way less stupid than how i was doing it before
    if self.Owner:GetNWBool("unzipped") and not self.Pissing and self.Owner:KeyDown(IN_ATTACK) then
       self.Pissing = true
       self.Owner:ConCommand("+piss")
    elseif not self.Owner:GetNWBool("unzipped") or (self.Pissing and not self.Owner:KeyDown(IN_ATTACK)) then
       self.Pissing = false
       self.Owner:ConCommand("-piss")
    end
 end