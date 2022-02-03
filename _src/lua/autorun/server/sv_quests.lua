if game.GetMap() ~= MapConfig.MapID then return end

util.AddNetworkString('quest.sendLines')

function Postsoviet_Text(hold, type, ...)
	net.Start('quest.sendLines')
		net.WriteTable({...})
		net.WriteInt(hold, 10)
		net.WriteInt(type, 5)
	net.Broadcast()
end

hook.Add('PlayerNoClip', 'quests', function() return false end)
hook.Add('PlayerSwitchFlashlight','quests', function()
	if not MapConfig.EnableFlashlight then
		return false
	end
end)

hook.Add('PlayerSpawn', 'quests', function(ply)
	if not MapConfig.StripWeapons then return end
	timer.Simple(0, function()
		if not ply:IsValid() then return end
		ply:SetWalkSpeed(MapConfig.PlayerWalkSpeed)
		ply:SetSlowWalkSpeed(MapConfig.PlayerSlowWalkSpeed)
		ply:SetRunSpeed(MapConfig.PlayerRunSpeed)
		ply:SetLadderClimbSpeed(MapConfig.PlayerClimbSpeed)
	end)
end)

hook.Add('PlayerLoadout', 'Postsoviet.NoWeapons', function()
	if MapConfig.StripWeapons then
		return true
	end
end)

hook.Add('GetFallDamage', 'quests', function()
	if not MapConfig.EnableFallDamage then
		return 0
	end
end)

hook.Add('ScalePlayerDamage', 'quests', function(ply, _, dmg)
	if not MapConfig.EnableDamage then
		dmg:ScaleDamage(0)
		return true
	end
end)