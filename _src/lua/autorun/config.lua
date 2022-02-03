MapConfig = MapConfig or {}

-- CONFIG

MapConfig.MapID					= 'quest_postsoviet_yard'

if SERVER then
MapConfig.EnableFlashlight		= false
MapConfig.EnableDamage			= false
MapConfig.EnableFallDamage		= false
MapConfig.StripWeapons			= true
MapConfig.PlayerWalkSpeed		= 100	-- 200 in sandbox; has to be 7+ or players won't be able to move
MapConfig.PlayerSlowWalkSpeed	= 50	-- 100 in sandbox
MapConfig.PlayerRunSpeed		= 160	-- 400 in sandbox
MapConfig.PlayerClimbSpeed		= 50	-- 200 in sandbox
return
end

MapConfig.Name					= 'Postsoviet Yard' -- shown in scoreboard

MapConfig.Authors				= { -- shown in scoreboard
	'Yermak',
	'MoreTeam',
}

MapConfig.LocalePrefix			= 'ps' -- looks up for `{LocalePrefix}.{Key}` localization string, where {Key}s are passed by map

-- if set to true, players will be able to view past lines of text in console & scoreboard
-- otherwise the scoreboard will be default
MapConfig.EnableLogs			= true

MapConfig.ShowHealth			= false -- restart the map after changing it

MapConfig.TypesData = {
	[0] = {
		startY = function(screenHeight) -- function to calculate initial height of lines of text of this type
			return screenHeight / 2
		end,
		color = Color(255, 255, 255), -- color of lines of text of this type
		font = 'psoviet', -- fontname of lines of text of this type, should be defined below (except if it's already defined by smth else)
	},
	[-1] = {
		startY = function(screenHeight)
			return screenHeight / 1.4
		end,
		color = Color(255, 205, 0),
		font = 'psoviet',
	},
	[2] = {
		startY = function(screenHeight)
			return screenHeight / 2
		end,
		color = Color(255, 205, 0),
		font = 'psoviet',
	},
}

surface.CreateFont('psoviet', {
	font = 'Arial', -- you can specify your custom font name
	extended = true, 
	size = ScrW() / 50, -- or size
	weight = 1000, -- or weight
}) -- or anything else (https://wiki.facepunch.com/gmod/surface.CreateFont)
