return {
    groupName = "MapVote",
    cases = {
        {
            timeout = 10,
            async = true,
            name = "test rate limit work",
            func = function()
                local bucket = MapVote.newRateLimitBucket( 5, 1 )
                timer.Simple( 2, function()
                    for _ = 1, 5 do
                        expect( bucket:consume( 1 ) ).to.equal( true )
                    end
                    expect( bucket:consume( 1 ) ).to.equal( false )
                end )
                timer.Simple( 2 + 3.5, function()
                    for _ = 1, 3 do
                        expect( bucket:consume( 1 ) ).to.equal( true )
                    end
                    expect( bucket:consume( 1 ) ).to.equal( false )

                    done()
                end )
                timer.Simple( 2 + 3.5 + 2, function()
                    for _ = 1, 2 do
                        expect( bucket:consume( 1 ) ).to.equal( true )
                    end
                    expect( bucket:consume( 1 ) ).to.equal( false )

                    done()
                end )
            end
        },
        {
            timeout = 5,
            async = true,
            name = "test vote state function exists",
            func = function()
                -- Test that the new sendVoteState function exists
                expect( MapVote.Net.sendVoteState ).to.be.a( "function" )
                
                -- Test that the existing sendVoteStart function still exists
                expect( MapVote.Net.sendVoteStart ).to.be.a( "function" )
                
                done()
            end
        },
    }
}
