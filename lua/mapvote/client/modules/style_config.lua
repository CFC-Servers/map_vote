MapVote.style = {
    primaryBG = Color( 52, 70, 92, 255 ), -- used for backgrounds for main panels and frames
    secondaryBG = Color( 70, 93, 122 ),
    configLabelFont = "MapVote_ConfigNameLabel"
}

-- fonts
surface.CreateFont( "MapVote_ConfigNameLabel", {
    font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 15,
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
