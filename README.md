Lumiens Map Vote
=======================
Forked from [Lumiens-Map-Vote](https://github.com/lumien231/Lumiens-Map-Vote)  
Originally made by Willox
Improved by Tyrantelf ([Github](https://github.com/tyrantelf/gmod-mapvote))

Sadly neither Willox Profile nor the original forum threads still exist.

Usage
=======================
Install the addon, should work out of the box for TTT and Deathrun.

Config
=======================

You can find the Config File at garrysmod/data/mapvote/config.txt

Example:
```JSON
{"RTVPlayerCount":3,"MapLimit":24,"TimeLimit":28,"AllowCurrentMap":false,"MapPrefixes":{"1":"ttt_"},"MapsBeforeRevote":3,"EnableCooldown":true}
```

If it doesn't exist yet you can just create it.

* "RTVPlayerCount" is the minimum number of players that need to be online (on TTT) for RTV to work.
* "MapLimit" is the number of maps shown on the vote screen.
* "TimeLimit" is how long the vote is shown for.
* "AllowCurrentMap" true/false to allow the current map in the map vote list.
* "RTVWait" time in seconds how long players have to wait rtv after a mapvote.
* "MapPrefixes" are the prefixes of the maps that should be used in the vote.
* "MapsBeforeRevote" is the number of maps that must be played before a map is in the vote menu again (if EnableCooldown is true)
* "EnableCooldown" is a true/false variable on whether to remove a map from voting for a while after it's played.
* "MapsBeforeRevote" is how many maps before the map is taken off the cooldown list after it's played.
* "RTVPercentPlayersRequired" percent of players 0 - 1 required to trigger an rtv
* "MinimumPlayersBeforeReset" When the server drops bellow this number reset the map to default map
* "DefaultMap" Default map to reset to
* "TimeToReset" Time until map resets when players are bellow MinimumPlayersBeforReset
Adding more Map prefixes

```JSON
{"RTVPlayerCount":3,"MapLimit":24,"TimeLimit":28,"AllowCurrentMap":false,"MapPrefixes":{"1":"ttt_","2":"zm_","3":"de_"},"MapsBeforeRevote":3,"EnableCooldown":true}
```

Screenshot
=======================
![Screenshot](https://i.imgur.com/LpJOR9x.png)

Modifications
=======================
* Replaced Text List with image grid
* Added Play Count to maps
* Some other visual tweaks


Hooks
======================
- **MapVote_IsMapAllowed** Runs to check if a map is allowed in the map rotation, return true/false to modify the result
- **MapVote_ConfigLoaded"** Runs when the mapvote config finnishes loading
- **MapVote_VoteFinished** Runs when a vote finnishes is passed a table with `state`, `results`, and `winner`
- **MapVoteChange** Runs right before the map changes, return false to stop the change. (This will be renamed in the future)

Commands
===================
- **startmpvote** starts a mapvote
- **stopmapvote** stops a mapvote
- **mapvote_migrate_playcounts** migrates adds mapvote/playcount.txt data to playcounts in database, this will add to existing play counts not overwrite them.