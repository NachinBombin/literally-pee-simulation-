AddCSLuaFile()

--Resource.AddWorkshop("2977971683")

PISS_MATERIAL = {}
PISS_MATERIAL["Pee"] = "piss/trails/pee"
PISS_MATERIAL["Blood"] = "piss/trails/blood"
PISS_MATERIAL["Napalm"] = "piss/trails/napalm"

PISS_TYPES = {
	"Pee",
	"Blood",
    "Napalm"
}

if SERVER then
    function PISS_IsAllowed(ply)
        if (GetConVar("piss_force_swep"):GetBool() and not ply:GetActiveWeapon().isPissSWEP) then
            ply:ChatPrint("You need to equip the Piss SWEP first as the server has 'piss_force_swep' set to 1!")
            return false
        end
        return true 
    end

    util.AddNetworkString("player_piss_cmd")
    util.AddNetworkString("player_unzip_cmd")
    util.AddNetworkString("player_change_piss_type")

    net.Receive("player_change_piss_type", function(len, ply)
        if not GetConVar("piss_allow_swep_typeswitch"):GetBool() then return end
        local piss_type = net.ReadUInt(4)
        if piss_type == 0 then
            piss_type = ply.Piss["Type"] + 1
            if piss_type > #PISS_TYPES then piss_type = 1 end
        end
        ply.Piss["Type"] = piss_type
        ply:ChatPrint("Now pissing: "..PISS_TYPES[ply.Piss["Type"]])
    end)

    net.Receive("player_piss_cmd", function(len, ply)
        local pissing = net.ReadBool()
        

        if pissing and PISS_IsAllowed(ply) then
            if !ply:GetNWBool("unzipped") then ply:ChatPrint("You pee your pants a little.") return end
            ply:StartPissing()
        else
            ply:StopPissing()
        end
    end)

    net.Receive("player_unzip_cmd", function(len, ply)
        if not PISS_IsAllowed(ply) then return end
        ply:Unzip(!ply:GetNWBool("unzipped"))
        ply.Piss["Unzipped"] = ply:GetNWBool("unzipped")
    end)

    hook.Add("PlayerSay", "ChatUnzip", function(ply, text)
        if string.lower(text) == "!unzip" then
            ply:Unzip(!ply:GetNWBool("unzipped"))
            return false
        end
    end)
    
end

if CLIENT then
	concommand.Add("+piss", function(ply, cmd, args)
        net.Start("player_piss_cmd")
            net.WriteBool(true)
        net.SendToServer()
	end)

    concommand.Add("-piss", function(ply, cmd, args)
        net.Start("player_piss_cmd")
            net.WriteBool(false)
        net.SendToServer()
    end)

    concommand.Add("unzip", function(ply, cmd,args)
        net.Start("player_unzip_cmd")
        net.SendToServer()
    end)

    concommand.Add("piss_type", function(ply, cmd, args)
        local arg = string.lower(tostring(args[1]))
        local piss_type = 0
        if arg == "pee" or arg == "piss" then piss_type = 1
        elseif arg == "blood" then piss_type = 2
        elseif arg == "napalm" then piss_type = 3
        elseif not arg == nil then
            print("Available piss types are: 'pee' or 'piss', 'blood', and 'napalm'")
            return
        end
        net.Start("player_change_piss_type")
            net.WriteUInt(piss_type, 4)
        net.SendToServer()
    end)
end