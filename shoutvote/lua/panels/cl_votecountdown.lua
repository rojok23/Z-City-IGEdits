/*---------------------------------------------------------
VoteCountdown Panel
---------------------------------------------------------*/
local VoteCountdownPanel = {}

function VoteCountdownPanel:Init()
	self:SetDrawBackground(false)
	self:SetDrawBorder(false)
	//self:SetStretchToFit(false)
	self:SetSize(311, 70)
	self.TotalPadding = 30
	self.TimerCircleSize = 50
	self.PrefixText = "Time Remaining:"
	self.BackColor = SHOUT.Theme.WindowColor
	self.TextColor = Color(200, 255, 255, 250 )
	self.TimerCircleColor = SHOUT.Theme.TimerCircleColor
	self.Hovering = false
	self.MissingImage = false
	
	self.HeaderLbl = vgui.Create("DLabel", self)
	self.HeaderLbl:SetFont("Bebas40Font")
	
	
	//self.HeaderLbl:SetColor(self.TextColor)
	//self.BorderColor = Color(190,40,0,255)
end

function VoteCountdownPanel:SetNoActionEnbaled(results)
	self.NoAction = true
	self.HoverColor = Color(0, 0, 0, 155 )
	self.AlphaFade = 255
	self.StartAlphaFade = true
	self.HeaderLbl:SetColor(Color(153, 153, 153, 90 ))
	self.VoteLbl:SetColor(Color(153, 153, 153, 90 ))
	if results then
		self.PlayerIcon:SetVisible(false)
		self.VoteCircle:SetVisible(false)
	end
end

function VoteCountdownPanel:SetColor(color)
	if not type(color) == "color" then return end
	self.TimerCircleColor = color
end

function VoteCountdownPanel:GetColor()
	return self.TimerCircleColor
end
function VoteCountdownPanel:StartTimer(seconds,text)
	if not tonumber(seconds) then return end
	if seconds < 1 then return end
	self.TimerLength = seconds
	self.EndTime = CurTime() + seconds
	
	if text then self.PrefixText = text end
end

function VoteCountdownPanel:PerformLayout()

	self.HeaderLbl:SetPos(70, 15)
	
	self:SetWide(self.TotalPadding + self.TimerCircleSize + self.HeaderLbl:GetWide())
end

function VoteCountdownPanel:Paint()

	surface.SetDrawColor(self.BackColor)
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())
	
	surface.SetDrawColor(Color(255,255,255,100))
	surface.SetMaterial(SHOUT.Theme.TimerCircleMat)
	surface.DrawTexturedRect( 10, 10, self.TimerCircleSize, self.TimerCircleSize)
	
	if self.EndTime then
		local timeremaining = math.Clamp((self.EndTime - CurTime()),0,self.TimerLength)
		local fraction = timeremaining / self.TimerLength
		local width = self.TimerCircleSize * fraction
		surface.SetDrawColor(self.TimerCircleColor)
		surface.SetMaterial(SHOUT.Theme.TimerCircleMat)
		surface.DrawTexturedRectUV( 10, 10, width, self.TimerCircleSize, 0, 0, fraction, 1 )
	end
end

function VoteCountdownPanel:Think()
	if self.EndTime then
		local timeremaining = math.Clamp((self.EndTime - CurTime()),0,self.TimerLength)
		self.HeaderLbl:SetText(string.FormattedTime(timeremaining, self.PrefixText.." %02i:%02i"))
		self.HeaderLbl:SizeToContents()
	end
end

function VoteCountdownPanel:OnCursorEntered()
	self.Hovering = true
	self.ColorBarWidth = 38
end

function VoteCountdownPanel:OnCursorExited()
	self.Hovering = false
end

function VoteCountdownPanel:ToggleSelect(select)
	if select then
		self.SelectFadeAlpha = 255
		self.CurrentSelection = true
	else
		self.CurrentSelection = false
	end
end

function VoteCountdownPanel:ColorWithCurrentAlpha(c)
	local r,g,b = c.r,c.g,c.b
	return Color(r,g,b,self.CurrentAlpha)
end
derma.DefineControl("VoteCountdownPanel", "Map vote countdown panel", VoteCountdownPanel, "DImageButton")

/*---------------------------------------------------------
End of VoteCountdownPanel
---------------------------------------------------------*/