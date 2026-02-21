/*---------------------------------------------------------
RTV Ribbon
---------------------------------------------------------*/
local RTVRibbon = {}

function RTVRibbon:Init()
	self:SetDrawBackground(false)
	//self:SetDrawBorder(false)
	//self:SetStretchToFit(false)
	self:SetSize(ScrW(), 32)
	self.VotePercentage = SHOUT.LastRTVPercentage or 0
	self.PercentToWidth = ((self:GetWide() / 100) * self.VotePercentage)

	self.AvatarSize = 28
	self.BackColor = SHOUT.Theme.ControlColor
	self.TextColor = Color(200, 255, 255, 250 )
	self.VoteBarColor = SHOUT.Theme.RTVBarColor
	self.Hovering = false
	self.MissingImage = false
	
	self.HeaderLbl = vgui.Create("DLabel", self)
	self.HeaderLbl:SetFont("Bebas24Font")

	self.AvatarList = vgui.Create("DIconLayout", self)
	self.AvatarList:SetSize(self:GetWide() - 20, self:GetTall() - 4)
	self.AvatarList:SetSpaceX( 3 )
	self.AvatarList:SetSpaceY( 0 )
	
	//if ScrW() < 1600 then self.AvatarSize = 16 end
	//self:SetAlpha(225)
end

function RTVRibbon:SetNoActionEnbaled(results)
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

function RTVRibbon:SetColor(color)
	if not type(color) == "color" then return end
	self.VoteBarColor = color
end

function RTVRibbon:GetColor()
	return self.VoteBarColor
end

function RTVRibbon:SetData(players, pct, votesneeded, flashcolor)
	if not players then return end

	self.AvatarList:Clear()
	for k,v in pairs(players) do
		if not IsValid(v) or not v:IsPlayer() then continue end
		if ((#self.AvatarList:GetChildren() * (self.AvatarSize + 3)) > (self:GetWide() - 20) ) then break end
		local avatar = self.AvatarList:Add("AvatarImage")
		avatar:SetSize(self.AvatarSize, self.AvatarSize)
		avatar:SetPlayer( v, self.AvatarSize )
		avatar:SetAlpha(90)
	end
	if flashcolor then
		self.BarColorR = 255
		self.BarColorG = 255
		self.BarColorB = 255
	end
	if pct then self.VotePercentage = math.Clamp(pct,0,100) end
	if votesneeded then
		self.HeaderLbl:SetText(string.format("%i more votes needed to rock the vote",tonumber(votesneeded)))
		self.HeaderLbl:SizeToContents()
	end
end

function RTVRibbon:SetCloseTime(time)
	if not time then return end
	self.FadeOutAlpha = 255
	self.CloseTime = time
end


function RTVRibbon:PerformLayout()
	
	self.HeaderLbl:SetPos(self:GetWide() - self.HeaderLbl:GetWide() - 10, 4)
	self.AvatarList:SetPos(10, 2)
end

function RTVRibbon:Paint()

	surface.SetDrawColor(Color(self.BackColor.r,self.BackColor.g,self.BackColor.b,200))
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())
	
	self.BarColorR = math.Approach(self.BarColorR or self.VoteBarColor.r, self.VoteBarColor.r,FrameTime() * 400)
	self.BarColorG = math.Approach(self.BarColorG or self.VoteBarColor.g,self.VoteBarColor.g,FrameTime() * 400)
	self.BarColorB = math.Approach(self.BarColorB or self.VoteBarColor.b,self.VoteBarColor.b,FrameTime() * 400)
	
	surface.SetDrawColor(Color(self.BarColorR,self.BarColorG,self.BarColorB))
	self.PercentToWidth = math.Approach(self.PercentToWidth,((self:GetWide() / 100) * self.VotePercentage),FrameTime() * 400)
	//self.PercentToWidth = (self:GetWide() / 100) * self.VotePercentage
	surface.DrawRect( 0, 0, self.PercentToWidth, self:GetTall())
	
	local markerx = (self:GetWide() / 100) * SHOUT.Settings.RTVPercent
	surface.SetDrawColor(Color(204,204,204))
	surface.DrawRect( markerx - 2, 0, 4, self:GetTall())
	
	//Vote count box
	
	//self.CurrentAlpha = math.Approach( self.CurrentAlpha, 0, FrameTime() * 200 )

	//surface.SetDrawColor(self:ColorWithCurrentAlpha(SHOUT.Theme.ControlColor))
end

function RTVRibbon:Think()
	if self.CloseTime and (CurTime() >= self.CloseTime) then
		self:SetAlpha(math.Approach(self:GetAlpha(),0,FrameTime() * 300))
		if self:GetAlpha() <= 0 then SHOUT.RTVRibbon:Remove() SHOUT.RTVRibbon = nil end
	end
end

function RTVRibbon:ColorWithCurrentAlpha(c)
	local r,g,b = c.r,c.g,c.b
	return Color(r,g,b,self.CurrentAlpha)
end
derma.DefineControl("RTVRibbon", "Map vote RTV ribbon", RTVRibbon, "DPanel")

/*---------------------------------------------------------
End of RTVRibbon
---------------------------------------------------------*/