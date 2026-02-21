local GTBaseURL="http://image.www.gametracker.com/images/maps/160x120/garrysmod/%s.jpg"
/*---------------------------------------------------------
VoteRow Panel
---------------------------------------------------------*/
local VoteRowPanel = {}

function VoteRowPanel:Init()
	self:SetDrawBackground(false)
	self:SetDrawBorder(false)
	//self:SetStretchToFit(false)
	self:SetSize(ScrW() -120, 140)
	self.PercentToWidth = 0
	self.VotePercentage = 0
	self.AvatarSize = 32
	self.BackColor = SHOUT.Theme.ControlColor
	self.TextColor = Color(200, 255, 255, 250 )
	self.VoteBarColor = Color(41, 128, 185)
	self.Hovering = false
	self.MissingImage = false
	
	self.HeaderLbl = vgui.Create("DLabel", self)
	self.HeaderLbl:SetFont("OpenSans50Font")
	
	self.MapImage = vgui.Create("DImage", self)
	self.MapImage:SetSize(160,120)
	
	if SHOUT.Settings.ShowPercentages then
		self.PercentageLbl = vgui.Create("DLabel", self)
		self.PercentageLbl:SetFont("OpenSans50Font")
		self.PercentageLbl:SetText("")
	end

	if ScrW() < 1600 then self.AvatarSize = 16 end
end

function VoteRowPanel:SetSmallRow(size)
	self:SetSize(ScrW() -120, 70)
	self.MapImage:SetSize(107,60)
	self.HeaderLbl:SetFont("OpenSans30Font")
	if self.PercentageLbl then
		self.PercentageLbl:SetFont("OpenSans30Font")
	end
	self.AvatarSize = 16
	self.SmallRow = true
end

function VoteRowPanel:SetColor(color)
	if not type(color) == "color" then return end
	self.VoteBarColor = color
end

function VoteRowPanel:GetColor()
	return self.VoteBarColor
end

function VoteRowPanel:GetMap(mapname)
	return self.Map
end

function VoteRowPanel:SetMap(mapname,nominate)
	if not mapname then return end
	self.Map = mapname
	
	if SHOUT.Settings.EnableExtendMapOption and (mapname == string.lower(game.GetMap())) then
	self.HeaderLbl:SetText(string.format("Extend %s",mapname))
	else
	self.HeaderLbl:SetText(mapname)
	end
	self.HeaderLbl:SizeToContents()
	
	local SmallRow = self.SmallRow
	//No more hacky awesomium panels
	if file.Exists(string.format("shoutvote/%s.jpg",mapname),"DATA") then
		self.MapImage:SetMaterial(Material(string.format("../data/shoutvote/%s.jpg",mapname,mapname)))
	else
		http.Fetch(string.format(GTBaseURL,mapname), function(body,len,headers,code)
			if not IsValid(self) then return end
			//Image was retrieved successfully
			if code == 200 then
				file.Write(string.format("shoutvote/%s.jpg",mapname),body)
				self.MapImage:SetMaterial(Material(string.format("../data/shoutvote/%s.jpg",mapname,mapname)))
			else self.MissingImage = true end
			end,
			function(e) 
				if not IsValid(self) then return end
				self.MissingImage = true
			end)
	end
	
	if nominate then self.NominateRow = true end
end

function VoteRowPanel:SetPercentage(pct)
	self.VotePercentage = math.Clamp(pct,0,100)
	if self.PercentageLbl then
		self.PercentageLbl:SetText(string.format("%i%%",math.Round(pct,1)))
		self.PercentageLbl:SizeToContents()
	end
end

function VoteRowPanel:AddPlayerVote(ply)
	if not SHOUT.Settings.ShowAvatars or not IsValid(ply) then return end
	local avatar = vgui.Create("AvatarImage",self)
	avatar:SetSize(self.AvatarSize, self.AvatarSize)
	avatar:SetPlayer( ply, self.AvatarSize )
	avatar.Player = ply
	avatar:SetPos(self:GetWide() - (self.AvatarSize + 15),self:GetTall() - 42)
	avatar:SetToolTip(ply:Nick())
	
	if self.AvatarList and ((#self.AvatarList * (self.AvatarSize + 3)) > (self:GetWide() - 200) ) then return end
	if not self.AvatarList then 
		self.AvatarList = {} 
		table.insert(self.AvatarList, avatar)
	else
		avatar:MoveLeftOf(self.AvatarList[#self.AvatarList],3)
		table.insert(self.AvatarList, avatar)
	end
end

function VoteRowPanel:RemovePlayerVote(ply)
	if not SHOUT.Settings.ShowAvatars or not IsValid(ply) or not self.AvatarList then return end
	local reposition
	for k,v in pairs(self.AvatarList) do
		if IsValid(v.Player) and (v.Player == ply) then
			reposition = true v:Remove() table.remove(self.AvatarList,k) break
		end
	end
	if reposition then
		local anum = 0
		for k,v in pairs(self.AvatarList) do
			if (anum == 0) then v:SetPos(self:GetWide() - (self.AvatarSize + 15),self:GetTall() - 42)
			else v:MoveLeftOf(self.AvatarList[anum],3) end
			anum = (anum + 1)
		end
	if #self.AvatarList < 1 then self.AvatarList = nil self.VotePercentage = 0 self.PercentageLbl:SetText("") end
	end
end

function VoteRowPanel:SetWinner(winner)
	if winner then self.IsWinner = true
	else self.IsWinner = false end
end

function VoteRowPanel:StartSelectionFlash(time)
	self.RandomSelect = CurTime() + time
end

function VoteRowPanel:PerformLayout()
	
	self.MapImage:SetPos(10,self.SmallRow and 5 or 10)
	self.HeaderLbl:SetPos(self.SmallRow and 127 or 180, 40)
	if self.PercentageLbl then 	self.PercentageLbl:SetPos(self:GetWide() - (self.PercentageLbl:GetWide() + 5), self.SmallRow and 0 or 40) end
end

function VoteRowPanel:Paint()

	surface.SetDrawColor(self.BackColor)
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())
	
	if self.IsWinner then
		surface.SetDrawColor(self.VoteBarColor.r, self.VoteBarColor.g, self.VoteBarColor.b, 50 + math.sin(RealTime() * 2) * 50)
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())
	elseif self.RandomSelect and (self.RandomSelect > CurTime()) then
		surface.SetDrawColor(Color(255,255,255,200))
		self.PercentToWidth = math.Approach(self.PercentToWidth,((self:GetWide() / 100) * self.VotePercentage),FrameTime() * 600)
		surface.DrawRect( 0, 0, self.PercentToWidth, self:GetTall())
	else
		surface.SetDrawColor(self.VoteBarColor)
		self.PercentToWidth = math.Approach(self.PercentToWidth,((self:GetWide() / 100) * self.VotePercentage),FrameTime() * 600)
		surface.DrawRect( 0, 0, self.PercentToWidth, self:GetTall())
	end
	
	if self.MissingImage then
		surface.SetDrawColor(Color(217,217,217,100))
		surface.DrawRect( 10, self.SmallRow and 5 or 10, self.SmallRow and 107 or 160, self.SmallRow and 60 or 120)
	end
	
	if self.NominateRow and self.Hovering then
		surface.SetDrawColor(self.VoteBarColor.r, self.VoteBarColor.g, self.VoteBarColor.b, 50)
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall())
	end
end

function VoteRowPanel:PaintOver()
	if self.IsWinner or (self.RandomSelect and (self.RandomSelect > CurTime())) then
		surface.SetDrawColor(Color(255,255,255,255))
		surface.SetMaterial(SHOUT.Theme.WinnerMat)
		surface.DrawTexturedRect( 16, self.SmallRow and 5 or 10, self.SmallRow and 93 or 146, self.SmallRow and 60 or 120)
	elseif self.CurrentSelection or self.Hovering and (SHOUT.Settings.PlayersCanChangeVote or !SHOUT.SelectionsLocked) and not SHOUT.VoteChangeLocked then
		surface.SetDrawColor(Color(255,255,255,255))
		surface.SetMaterial(SHOUT.Theme.SelectedMat)
		surface.DrawTexturedRect( 10, self.SmallRow and 5 or 10, self.SmallRow and 107 or 160, self.SmallRow and 60 or 120)
	end
	if self.CurrentSelection then
		self.SelectFadeAlpha = math.Approach(self.SelectFadeAlpha,0,FrameTime() * 200)
		surface.SetDrawColor(Color(255,255,255,self.SelectFadeAlpha))
		surface.DrawRect( 10, self.SmallRow and 5 or 10, self.SmallRow and 107 or 160, self.SmallRow and 60 or 120)
	end

end

function VoteRowPanel:OnCursorEntered()
	self.Hovering = true
	self.ColorBarWidth = 38
end

function VoteRowPanel:OnCursorExited()
	self.Hovering = false
end

function VoteRowPanel:ToggleSelect(select)
	if select then
		self.SelectFadeAlpha = 255
		self.CurrentSelection = true
	else
		self.CurrentSelection = false
	end
end

function VoteRowPanel:ColorWithCurrentAlpha(c)
	local r,g,b = c.r,c.g,c.b
	return Color(r,g,b,self.CurrentAlpha)
end
derma.DefineControl("VoteRowPanel", "Map vote row panel", VoteRowPanel, "DImageButton")

/*---------------------------------------------------------
End of VoteRowPanel
---------------------------------------------------------*/