AddCSLuaFile()

if SERVER then return end

local balls = Material( "piss/balls.png", "noclamp" )
local height = 100
local anchor = 275
local scale = 1
local pee = 100
local lerp = 1

local x = 280

local alpha = 0
local target_alpha = nil

CreateClientConVar("piss_censor_thirdperson", "1", true, false, "1 = on, 0 = off\nShow censor in thirdperson and on other players", 0, 1)
CreateClientConVar("piss_censor_firstperson", "1", true, false, "1 = on, 0 = off\nShow censor in firstperson", 0, 1)
CreateClientConVar("piss_water_clouds", "1", true, false, "1 = on, 0 = off\nEnables clouds when pissing in the water.", 0, 1)
CreateClientConVar("piss_meter", "0", true, false, "1 = on, 0 = off\nShow the piss meter (for now you can't run out but you can still see the meter if you want)", 0, 1) --unused for now
CreateClientConVar("piss_clean", "0", true, false, "1 = on, 0 = off\nIf set to 1, makes piss streams look more like water and less like piss (also disables water clouds).", 0, 1)
CreateClientConVar("piss_hide", "0", true, false, "1 = on, 0 = off\nIf set to 1, makes piss invisible (also disables water clouds).", 0, 1)



--this is the player's piss meter that shows them how much piss they have left, but that system is disabled for now so the meter is unnecessary. still works fine though
hook.Add( "HUDPaint", "DrawPeeBalls", function()
	target_alpha = (GetConVar("piss_meter"):GetBool() and 1) or -0.1 --negative otherwise Lerp will never reach 0
	alpha = Lerp(0.3, alpha, target_alpha)
	if alpha <= 0 then return end

	pee = math.Clamp( LocalPlayer():GetNWFloat("pee_level", 0), 0, 100 ) 
	lerp = math.Clamp(pee/100, 0.05, 0.2)
	height = math.Approach(height, pee, lerp)
	surface.SetMaterial( balls)

	surface.SetDrawColor( 255/2, 255/2, 255/2, 125*alpha ) --the "empty" balls
	surface.DrawTexturedRect( x,
		ScrH() - anchor,
		256,
		189 )

	surface.SetDrawColor( 255, 255, 255, 255*alpha ) --the "full" balls
	surface.DrawTexturedRectUV( x, --x
		ScrH() - anchor+189-(height * 1.89), --y
		256, --width
		(height * 1.89), --height
		0, --u start
		1 - height * 0.01, --v start
		1, --u end
		1 ) --v end
end )



local censormat = Material("piss/censored.vtf")
local drawSize = 16 --we could totally turn this into a networked int that represent's the player's dick size for smaller or larger censor boxes, but certain models would break that entirely so it's not a priority



hook.Add("PostPlayerDraw", "DrawPlayerCensor", function(ply)
	if GetConVar("piss_censor_thirdperson"):GetBool() and ply:IsPlayer() and ply:GetNWBool("unzipped") then
		local pelvis = "ValveBiped.Bip01_Pelvis"
		local bone = ply:LookupBone(pelvis)
		local boneMat = ply:GetBoneMatrix(bone)
		if not boneMat then return end
		local pelvisPos = boneMat:GetTranslation()+boneMat:GetUp()*(5+(drawSize*0.35))
		cam.Start3D(EyePos(), EyeAngles())
			render.SetMaterial( censormat )
			render.DrawSprite( pelvisPos, drawSize, drawSize, color_white)
		cam.End3D()
	end
end)

local pissMat = Material("piss/trails/pee")
local changed_pissMat = nil
hook.Add("PostDrawTranslucentRenderables", "DrawPissViewmodelCensor", function()
	local ply = LocalPlayer()
	if GetConVar("piss_censor_firstperson"):GetBool() and ply:IsPlayer() and ply:GetNWBool("unzipped") and ply:Alive() then
		local vm = ply:GetViewModel()
		local eyePos = vm:GetPos()
		local plyAngle = ply:GetAngles()
		plyAngle.x = 0
		plyAngle.z = 0

		local forward = plyAngle:Forward()
		local right = plyAngle:Right()
		local up = plyAngle:Up()

		local spritePos = eyePos + forward * ((drawSize*0.35)) + up * -30
		render.SetMaterial(censormat)
		render.DrawSprite(spritePos, drawSize, drawSize, color_white)
	end

	-- locally override the color of the piss material for people who don't like the yellow color
	local clean = GetConVar("piss_clean"):GetBool()
	local pisscolor = (clean and Vector(0.5,0.5,1) or Vector(1,1,0))
	if pissMat:GetVector("$color") != pisscolor then
		pissMat:SetVector("$color", pisscolor)
		print("Changed piss color to "..(clean and "CLEAN/BLUE" or "YELLOW"))
	end

	local hide = GetConVar("piss_hide"):GetBool()
	local pissHide = hide and 0 or 1
	if pissMat:GetFloat("$alpha") != pissHide then
		pissMat:SetFloat("$alpha", pissHide)
		print("Toggled piss visibility")
	end
end)