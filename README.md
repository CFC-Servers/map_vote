Lumiens Map Vote
=======================

Originally made by Willox
Improved by Tyrantelf ([Github](https://github.com/tyrantelf/gmod-mapvote))

Sadly neither Willox Profile nor the original forum threads still exist.

Usage
=======================
Install the addon, should work out of the box for TTT and Deathrun.

Since i only modified this addon for one specific server I will not fix issues in
gamemodes other than TTT. (Though i will accept PRs for them)


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
* "MapPrefixes" are the prefixes of the maps that should be used in the vote.
* "MapsBeforeRevote" is the number of maps that must be played before a map is in the vote menu again (if EnableCooldown is true)
* "EnableCooldown" is a true/false variable on whether to remove a map from voting for a while after it's played.
* "MapsBeforeRevote" is how many maps before the map is taken off the cooldown list after it's played.

Adding more Map prefixes

```JSON
{"RTVPlayerCount":3,"MapLimit":24,"TimeLimit":28,"AllowCurrentMap":false,"MapPrefixes":{"1":"ttt_","2":"zm_","3":"de_"},"MapsBeforeRevote":3,"EnableCooldown":true}
```

Modifications
=======================
* Replaced Text List with image grid
* Added Play Count to maps
* Some other visual tweaks