MapVote.Net = MapVote.Net or {}

function MapVote.Net.receiveWithMiddleware( name, cb, ... )
    for _, v in pairs( { ... } ) do
        cb = v( cb )
    end

    net.Receive( name, cb )
end

function MapVote.Net.requirePermission( perm )
    return function( cb )
        return function( n, ply )
            if not CAMI then
                if not ply:IsSuperAdmin() then return end
                return cb( n, ply )
            end

            CAMI.PlayerHasAccess( ply, perm, function( b )
                if not b then return end
                cb( n, ply )
            end )
        end
    end
end
