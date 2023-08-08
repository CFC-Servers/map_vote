---@param panel Panel
---@param newPos Vector
---@param newSize Vector
---@param duration number
---@param callback fun(tbl: AnimationData, pnl: Panel)
function MapVote.DoPanelMove( panel, newPos, newSize, duration, callback )
    local anim = panel:NewAnimation( duration, 0, 1, callback )

    local startSize = Vector( panel:GetSize() )
    local startPos = Vector( panel:GetPos() )

    anim.Think = function( _, pnl, fraction )
        local n = fraction

        local size = LerpVector( n, startSize, newSize )
        pnl:SetSize( size.x, size.y )

        local pos = LerpVector( n, startPos, newPos )
        pnl:SetPos( pos.x, pos.y )
    end

    return {
        startSize = startSize,
        startPos = startPos,
    }
end
