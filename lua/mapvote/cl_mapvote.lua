surface.CreateFont("RAM_VoteFont", {
    font = "Trebuchet MS",
    size = 19,
    weight = 700,
    antialias = true,
    shadow = true
})

surface.CreateFont("RAM_VoteFontCountdown", {
    font = "Tahoma",
    size = 32,
    weight = 700,
    antialias = true,
    shadow = true
})

surface.CreateFont("RAM_VoteSysButton",
                   {font = "Marlett", size = 13, weight = 0, symbol = true})

MapVote.EndTime = 0
MapVote.Panel = false

net.Receive("RAM_MapVoteStart", function()
    MapVote.CurrentMaps = {}
    MapVote.Allow = true
    MapVote.Votes = {}

    local amt = net.ReadUInt(32)

    for i = 1, amt do
        local map = net.ReadString()
        local playCount = net.ReadUInt(32)

        local object = {}
        object["map"] = map
        object["playcount"] = playCount

        MapVote.CurrentMaps[#MapVote.CurrentMaps + 1] = object
    end

    MapVote.EndTime = CurTime() + net.ReadUInt(32)

    if (IsValid(MapVote.Panel)) then MapVote.Panel:Remove() end

    MapVote.Panel = vgui.Create("RAM_VoteScreen")
    MapVote.Panel:SetMaps(MapVote.CurrentMaps)
end)

net.Receive("RAM_MapVoteUpdate", function()
    local update_type = net.ReadUInt(3)

    if (update_type == MapVote.UPDATE_VOTE) then
        local ply = net.ReadEntity()

        if (IsValid(ply)) then
            local map_id = net.ReadUInt(32)
            MapVote.Votes[ply:SteamID()] = map_id

            if (IsValid(MapVote.Panel)) then
                MapVote.Panel:AddVoter(ply)
            end
        end
    elseif (update_type == MapVote.UPDATE_WIN) then
        if (IsValid(MapVote.Panel)) then
            MapVote.Panel:Flash(net.ReadUInt(32))
        end
    end
end)

net.Receive("RAM_MapVoteCancel", function()
    if IsValid(MapVote.Panel) then MapVote.Panel:Remove() end
end)

net.Receive("RTV_Delay", function()
    chat.AddText(Color(102, 255, 51), "[RTV]", Color(255, 255, 255),
                 " The vote has been rocked, map vote will begin on round end")
end)

local PANEL = {}

function PANEL:Init()
   -- self:ParentToHUD()

    self.startTime = SysTime()

    self.Canvas = vgui.Create("Panel", self)
    self.Canvas:MakePopup()
    self.Canvas:SetKeyboardInputEnabled(false)

    self.countDown = vgui.Create("DLabel", self.Canvas)
    self.countDown:SetTextColor(color_white)
    self.countDown:SetFont("RAM_VoteFontCountdown")
    self.countDown:SetText("")
    self.countDown:SetPos(0, 14)
    self.countDown:SetAlpha(0)
    self.countDown:AlphaTo(255, 0.8, 0)


    function self.countDown:PerformLayout()
        self:SizeToContents()
        self:CenterHorizontal()
    end

    self.mapList = vgui.Create("DPanelList", self.Canvas)
    self.mapList:SetDrawBackground(false)
    self.mapList:SetSpacing(4)
    self.mapList:SetPadding(4)
    self.mapList:EnableHorizontal(true)
    self.mapList:EnableVerticalScrollbar()

    self.closeButton = vgui.Create("DButton", self.Canvas)
    self.closeButton:SetText("")

    self.closeButton.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "WindowCloseButton", panel, w, h)
    end

    self.closeButton.DoClick = function()
        self:SetVisible(false)
    end

    self.Voters = {}
end

function PANEL:PerformLayout()
    local cx, cy = chat.GetChatBoxPos()

    self:SetPos(0, 0)
    self:SetSize(ScrW(), ScrH())

    local extra = math.Clamp(1250 - 640, 0, ScrW() - 640)
    self.Canvas:StretchToParent(0, 0, 0, 0)
    self.Canvas:SetWide(640 + extra)
    self.Canvas:SetTall(ScrH() - 100)
    self.Canvas:SetPos(0, 0)
    self.Canvas:CenterHorizontal()
    self.Canvas:SetZPos(0)

    self.mapList:StretchToParent(0, 90, 0, 0)

    local buttonPos = 640 + extra - 31 * 3

    self.closeButton:SetPos(buttonPos - 31 * 0, 4)
    self.closeButton:SetSize(31, 31)
    self.closeButton:SetVisible(true)
end

local heart_mat = Material("icon16/heart.png")
local star_mat = Material("icon16/star.png")
local shield_mat = Material("icon16/shield.png")

function PANEL:AddVoter(voter)
    for k, v in pairs(self.Voters) do
        if (v.Player and v.Player == voter) then return false end
    end

    local icon_container = vgui.Create("Panel", self.mapList:GetCanvas())
    local icon = vgui.Create("AvatarImage", icon_container)
    icon:SetSize(32, 32)
    icon:SetZPos(1000)

    icon_container.Player = voter
    icon:SetPlayer(voter, 32)

    icon_container:SetSize(36, 36)
    icon:SetPos(4, 4)

    icon_container.Paint = function(s, w, h)
        -- draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 80))

        if (icon_container.img) then
            surface.SetMaterial(icon_container.img)
            surface.SetDrawColor(Color(255, 255, 255))
            surface.DrawTexturedRect(2, 2, 16, 16)
        end
    end

    icon_container:SetMouseInputEnabled( false )
    icon_container:SetAlpha(200)

    table.insert(self.Voters, icon_container)
end

function PANEL:Think()
    for k, v in pairs(self.mapList:GetItems()) do v.NumVotes = 0 end

    for k, v in pairs(self.Voters) do
        if (not IsValid(v.Player)) then
            v:Remove()
        else
            if (not MapVote.Votes[v.Player:SteamID()]) then
                v:Remove()
            else
                local bar = self:GetMapButton(MapVote.Votes[v.Player:SteamID()])

                local row = math.floor(bar.NumVotes / 5)
                local column = bar.NumVotes % 5
                local layer = math.floor(row / 4)

                row = row - (layer) * 4;

                bar.NumVotes = bar.NumVotes + 1

                if (IsValid(bar)) then
                    local CurrentPos = Vector(v.x, v.y, 0)

                    local NewPos = Vector(
                                       (bar.x + column * 40),
                                       bar.y + row * 36 + 25, 0)

                    if (not v.CurPos or v.CurPos ~= NewPos) then
                        v:MoveTo(NewPos.x, NewPos.y, 0.3)
                        v.CurPos = NewPos
                    end
                end
            end
        end

    end

    local timeLeft = math.Round(math.Clamp(MapVote.EndTime - CurTime(), 0,
                                           math.huge))

    self.countDown:SetText(tostring(timeLeft or 0) .. " seconds")

    if (timeLeft < 10) then 
        self.countDown:SetTextColor(Color(255,0,0))
    end

    self.countDown:SizeToContents()
    self.countDown:CenterHorizontal()
end

function PANEL:SetMaps(maps)
    self.mapList:Clear()

    local transCounter = 0

    for k, v in RandomPairs(maps) do
        local map = v["map"]
        local playCount = v["playcount"]


        local panel = vgui.Create("DLabel", self.mapList)
        panel.ID = k
        panel.NumVotes = 0
        panel:SetSize( 200, 200 )
        panel:SetText("")
        panel:SetAlpha(0)
        panel:SetPaintBackgroundEnabled( false )


        panel:AlphaTo(255, 0.8, transCounter/40)
        transCounter = transCounter + 1

        function panel:PerformLayout()
            self:SetBGColor(0,150,0,255)
        end

        local button = vgui.Create("DImageButton", panel)
        button:SetImage(getMapThumbnail(map))

        function button:OnMousePressed(code)
            net.Start("RAM_MapVoteUpdate")
            net.WriteUInt(MapVote.UPDATE_VOTE, 3)
            net.WriteUInt(panel.ID, 32)
            net.SendToServer()
        end

        button:SetPos(2,2);
        button:SetSize( 196, 196 )

        local playCountLabel = vgui.Create( "DLabel", button )
        playCountLabel:SetPos( 0, 0 )
        playCountLabel:SetSize(196, 25)
        playCountLabel:SetText(playCount .. "")
        playCountLabel:SetContentAlignment( 5 )
        playCountLabel:SetFont("RAM_VoteFont")
        playCountLabel:SetPaintBackgroundEnabled( true )

        function playCountLabel:PerformLayout()
            self:SetBGColor(0,0,0,220)
        end

        local text = vgui.Create( "DLabel", button )
        text:SetPos( 0, 173 )
        text:SetSize(196, 25)
        text:SetText(map)
        text:SetContentAlignment( 5 )
        text:SetFont("RAM_VoteFont")
        text:SetPaintBackgroundEnabled( true )

        function text:PerformLayout()
            self:SetBGColor(0,0,0,220)
        end

        self.mapList:AddItem(panel)
    end
end

function getMapThumbnail(name)
    if file.Exists("maps/thumb/" .. name .. ".png", "GAME") then
        return "maps/thumb/" .. name .. ".png"
    elseif file.Exists("maps/" .. name .. ".png", "GAME") then
        return "maps/" .. name .. ".png"
    else
        return "maps/thumb/noicon.png"
    end
end

function PANEL:GetMapButton(id)
    for k, v in pairs(self.mapList:GetItems()) do
        if (v.ID == id) then return v end
    end

    return false
end

function PANEL:Paint()
    Derma_DrawBackgroundBlur(self, self.startTime)
end

function PANEL:Flash(id)
    self:SetVisible(true)

    local bar = self:GetMapButton(id)

    if (IsValid(bar)) then
        timer.Simple(0.0, function()
            bar:SetPaintBackgroundEnabled( true )
            surface.PlaySound("hl1/fvox/blip.wav")
        end)
        timer.Simple(0.2, function() bar:SetPaintBackgroundEnabled( false ) end)
        timer.Simple(0.4, function()
            bar:SetPaintBackgroundEnabled( true )
            surface.PlaySound("hl1/fvox/blip.wav")
        end)
        timer.Simple(0.6, function() bar:SetPaintBackgroundEnabled( false ) end)
        timer.Simple(0.8, function()
            bar:SetPaintBackgroundEnabled( true )
            surface.PlaySound("hl1/fvox/blip.wav")
        end)
        timer.Simple(1.0, function() 
            bar:SetBGColor(255,0,255,255)
            bar:SetPaintBackgroundEnabled( true )
         end)
    end
end

derma.DefineControl("RAM_VoteScreen", "", PANEL, "DPanel")
