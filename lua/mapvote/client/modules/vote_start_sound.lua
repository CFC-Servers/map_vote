local soundPath = "hl1/fvox/blip.wav"
local numBeeps = 4
local beepGap = 0.15

hook.Add( "MapVote_VoteStarted", "MapVote_PlaySoundOnStart", function()
    surface.PlaySound( soundPath )

    if numBeeps <= 1 then return end

    timer.Create( "MapVote_PlaySoundOnStart", beepGap, numBeeps - 1, function()
        surface.PlaySound( soundPath )
    end )
end )
