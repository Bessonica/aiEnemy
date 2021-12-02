AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
--[[
local function LoadFiles( filePath, lastFolder )=
end ]]
--[[
LoadFiles( "gamemodes/aiEnemy/gamemode", "" )

17
npc:SetPos(ply:GetPos() + Vector(0, 300, 0) )

]]
function GM:PlayerSpawn( ply )
    local npc = ents.Create("npc_custom")
	npc:SetPos(Vector(0, 300, 0) )
	npc:Spawn()
	
	ply:Give("weapon_shotgun")
end