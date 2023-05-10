do return end
surface.CreateFont( "MapVote_ReopenText", {
    font = "Marlett",
    extended = false,
    size = 40,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

hook.Add( "PlayerButtonDown", "MapVote_ReopenMapvote", function( _, button )
    if button ~= KEY_F3 then return end
    if not IsValid( MapVote.Panel ) then return end
    MapVote.Panel:SetVisible( true )
end )

hook.Add( "HUDPaint", "MapVote_DrawOpenNotification", function()
    local huge = math.huge --[[@as number]]
    local timeLeft = math.Round( math.Clamp( MapVote.EndTime - CurTime(), 0, huge ) )
    local text = "Press F3 to open the mapvote menu. Changing in " .. timeLeft .. " seconds."

    if not IsValid( MapVote.Panel ) then return end

    local x = ScrW() * 0.5
    local y = ScrH() * 0.05
    draw.SimpleText( text, "MapVote_ReopenText", x + 4, y + 4, color_black, TEXT_ALIGN_CENTER )
    draw.SimpleText( text, "MapVote_ReopenText", x, y, color_white, TEXT_ALIGN_CENTER )
end )
