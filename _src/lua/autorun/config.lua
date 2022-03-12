MapConfig = MapConfig or {}

-- CONFIG

MapConfig.MapID					= 'wanichka_quest'
MapConfig.ShutUp				= false


MapConfig.EnableFlashlight		= false
MapConfig.EnableDamage			= false
MapConfig.EnableFallDamage		= false
MapConfig.StripWeapons			= true
MapConfig.PlayerWalkSpeed		= 100	-- 200 in sandbox; has to be 7+ or players won't be able to move
MapConfig.PlayerSlowWalkSpeed	= 50	-- 100 in sandbox
MapConfig.PlayerRunSpeed		= 160	-- 400 in sandbox
MapConfig.PlayerClimbSpeed		= 50	-- 200 in sandbox

MapConfig.Name					= 'Sample Wani4ka Quest' -- shown in scoreboard

MapConfig.Authors				= { -- shown in scoreboard
	'Yermak',
}

MapConfig.LocalePrefix			= 'ps' -- looks up for `{LocalePrefix}.{Key}` localization string, where {Key}s are passed by map

-- if set to true, players will be able to view past lines of text in console & scoreboard
-- otherwise the scoreboard will be default
MapConfig.EnableLogs			= true

MapConfig.ShowHealth			= false -- restart the map after changing it

MapConfig.TypesData = {
	['printedText'] = {
		margins = { -- amount of pixel to leave empty from a screen border
			top = 0.5, -- if you specify a number no more than 1, it will get multiplied by width or height of the screen
			left = 0.5,
			-- other possible keys: right, bottom
		},
		alignment = TEXT_ALIGN_CENTER, -- horizontal align of lights, possible values: TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT
		color = Color(255, 255, 255), -- color of lines of text of this type
		font = 'wani4kaFont', -- fontname of lines of text of this type, should be defined below (except if it's already defined by smth else)
	},
	['mainCharacterThoughts'] = {
		margins = {
			top = 0.75,
			left = 0.5,
		},
		alignment = TEXT_ALIGN_CENTER,
		color = Color(255, 205, 0),
		font = 'wani4kaFont',
	},
	['messageFromAuthors'] = {
		margins = {
			top = 0.5,
			left = 0.5,
		},
		alignment = TEXT_ALIGN_CENTER,
		color = Color(255, 205, 0),
		font = 'wani4kaFont',
	},
}

if SERVER then return end

surface.CreateFont('wani4kaFont', {
	font = 'Arial', -- you can specify your custom font name
	extended = true, 
	size = ScrW() / 50, -- or size
	weight = 1000, -- or weight
}) -- or anything else (https://wiki.facepunch.com/gmod/surface.CreateFont)
