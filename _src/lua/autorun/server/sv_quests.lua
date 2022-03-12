if game.GetMap() ~= MapConfig.MapID then return end

util.AddNetworkString 'quest.sendTyped'
util.AddNetworkString 'quest.sendCustom'
util.AddNetworkString 'quest.hide'

hook.Add('PlayerNoClip', 'quests', function() return false end)
hook.Add('PlayerSwitchFlashlight','quests', function()
	if not MapConfig.EnableFlashlight then
		return false
	end
end)

hook.Add('PlayerSpawn', 'quests', function(ply)
	local walk, slowWalk, run, climb = MapConfig.PlayerWalkSpeed, MapConfig.PlayerSlowWalkSpeed, MapConfig.PlayerRunSpeed, MapConfig.PlayerClimbSpeed
	if not (walk or slowWalk or run or climb) then return end
	timer.Simple(0, function()
		if not ply:IsValid() then return end
		if walk then ply:SetWalkSpeed(walk) end
		if slowWalk then ply:SetSlowWalkSpeed(slowWalk) end
		if run then ply:SetRunSpeed(run) end
		if climb then ply:SetLadderClimbSpeed(climb) end
	end)
end)

hook.Add('PlayerLoadout', 'quests', function()
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