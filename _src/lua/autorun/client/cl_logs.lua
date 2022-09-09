local cfg = MapConfig
if game.GetMap() ~= string.lower(cfg.MapID) then return end

-- LOGS
qLogs = qLogs or {}
local colScrollbar = Color(30, 30, 30)
local colScrollbarHovered = Color(40, 40, 40)
local colScrollbarPressed = Color(50, 50, 50)

local function label(pnl, col, txt, shCol)
	local lbl = pnl:Add 'DLabel'
	lbl:SetText(txt)
	lbl:Dock(TOP)
	lbl:SetTextColor(col)
	lbl:SetContentAlignment(5)
	lbl:SetAutoStretchVertical(true)
	lbl:SetFont('ScoreboardDefaultTitle')
	if shCol then lbl:SetExpensiveShadow(2, shCol) end
	return lbl
end

local function _addLogLine(pnl, col, txt)
	local lbl = label(pnl, col, txt)
	lbl:DockMargin(0, 5, 0, 0)
	lbl:SetFont('ScoreboardDefault')
end

local function updateScroll()
	local scr = qScoreboard.Logs
	local children = scr:GetCanvas():GetChildren()
	if children[1] then
		scr:ScrollToChild(children[#children])
	end
end

function addLogLine(col, txt, length)

	if not (txt == '' or timer.Exists('addEmptyLog') or not next(qLogs)) then
		addLogLine(color_shadow, '')
	end

	qLogs[#qLogs + 1] = { col, txt }
	MsgC(col, txt, '\n')
	if IsValid(qScoreboard) then
		_addLogLine(qScoreboard.Logs, col, txt)
		qScoreboard.Logs:GetCanvas():InvalidateLayout(true)
		updateScroll()
	end

	if length then
		timer.Create('addEmptyLog', length + 3, 1, function() end)
	end

end

local function createScoreboard()

	if IsValid(qScoreboard) then
		qScoreboard:Remove()
	end
	local pnl = vgui.Create 'EditablePanel'
	qScoreboard = pnl

	local header = pnl:Add 'Panel'
	header:Dock(TOP)
	header:DockMargin(0, 0, 0, 5)
	header:SetHeight(35)

	local map = label(header, color_white, cfg.Name, color_shadow)

	local wrap = pnl:Add 'DPanel'
	wrap:Dock(FILL)
	wrap:SetPaintBackground(false)
	local logs = wrap:Add 'DScrollPanel'
	logs:Dock(FILL)
	local canvas, vbar = logs:GetCanvas(), logs:GetVBar()
	canvas:DockPadding(5, 0, 5, 5)
	pnl.Logs = logs
	for _, log in ipairs(qLogs) do
		_addLogLine(logs, unpack(log))
	end

	canvas.Paint = function(_, w, h)
		draw.RoundedBox(4, 0, 0, w, h, color_shadow)
	end
	vbar:SetHideButtons(true)
	vbar.Paint = function() end
	vbar.btnGrip.Paint = function(self, w, h)
		local col = self.Depressed and colScrollbarPressed or self.Hovered and colScrollbarHovered or colScrollbar
		draw.RoundedBox(4, 2, 0, 8, h, col)
	end

	local authors = pnl:Add 'DLabel'
	authors:Dock(BOTTOM)
	authors:SetContentAlignment(4)
	authors:SetText(table.concat(cfg.Authors, ' x ') .. ' x Wani4ka')
	authors:SetTextColor(Color(80, 80, 80))
	authors:SetExpensiveShadow(1, color_shadow)

	function pnl:PerformLayout()
		self:SetSize(700, 400)
		self:SetPos(ScrW() / 2 - 350, 100)
		updateScroll()
	end

	return pnl
end

hook.Add('ScoreboardShow', 'quests', function()
	if not cfg.EnableLogs then return end
	local sc = qScoreboard
	if not IsValid(sc) then
		sc = createScoreboard()
	end
	sc:Show()
	sc:MakePopup()
	sc:SetKeyboardInputEnabled(true)
	return true
end)

hook.Add('ScoreboardHide', 'quests', function()
	if IsValid(qScoreboard) then
		qScoreboard:Hide()
		return true
	end
end)
