local PANEL = {}

function PANEL:Paint( w, h )
    draw.RoundedBox( 10, 0, 0, w, h, MapVote.style.primaryBG )
end

vgui.Register( "MapVote_Frame", PANEL, "DFrame" )
