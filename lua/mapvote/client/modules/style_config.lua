MapVote.style = {
    colorPrimaryBG = Color( 30, 30, 46 ),
    colorSecondaryBG = Color( 49, 50, 68 ),
    colorSecondaryFG = Color( 69, 71, 90 ),

    colorTextSecondary = Color( 166, 173, 200 ),
    colorTextPrimary = Color( 205, 214, 244 ),
    colorSelected = Color( 137, 180, 250 ),

    colorRed = Color( 243, 139, 168 ),
    colorYellow = Color( 249, 226, 175 ),
    colorGreen = Color( 166, 227, 161 ),
    colorPurple = Color( 203, 166, 247 ),
    frameBlurLevel = 0,
    configLabelFont = "MapVote_ConfigNameLabel",
    mapVoteTitleFont = "MapVote_Title",
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

-- fonts
surface.CreateFont( "MapVote_Title", {
    font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 34,
    weight = 800,
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
