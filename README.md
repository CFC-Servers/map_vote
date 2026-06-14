# Usage
### Commands
- **startmpvote** starts a mapvote
- **stopmapvote** stops a mapvote
- **mapvote_migrate_playcounts** migrates adds mapvote/playcount.txt data to playcounts in database, this will add to existing play counts not overwrite them.

# Configuration
### Using the in game configuration menu
Type `mapvote_config` in console, you can edit most config settings in this menu. **Note:** MapPrefixes can currently not be edited in the settings menu

Pressing the Open Map Config button will allow you to set overrides for enabling/disabling maps. Pressing clear will delete the override so inclusion of the map can be decided by MapPrefixe or other methods.

## Styling
- Create a file at `lua/mapvote/client/plugins/mystyle.lua`
- You can update colors and other style configuration by merging new values into the existing style table
Example:
```lua
table.Merge(MapVote.style, {
    colorPrimaryBG = Color( 30, 30, 46 ),
    colorSecondaryBG = Color( 49, 50, 68 ),
})
```
# Integrating other addons with MapVote
### Plugins directory
You can create file in lua/mapvote/client/plugins and lua/mapvote/server/plugins these files will be loaded after the main mapvote modules have been loaded

### Usable Hooks
| Name                    | description                                                                        | args      | realm  |
| ----------------------- | ---------------------------------------------------------------------------------- | --------- | ------ |
| MapVote_Loaded          | Called when all lua files for mapvote have been loaded                             |           | shared |
| MapVote_RTVStart        | Called a vote starts via !rtv, return false to prevent map vote starting           |           | server |
| MapVote_CanStartVote    | Always called during MapVote.Start(), return false to prevent map vote starting    |           | server |
| MapVote_IsMapAllowed    | Called to determine if a map is allowed, return true/false to allow/disallow a map | map       | server |
| MapVote_VoteStarted     | Called after all maps are picked for a vote                                        | voteState | server |
| MapVote_VoteMultiplier  | Multiply a player's weight in the vote, return vote multiplier                     | ply       | server |
| MapVote_VoteFinished    | Called when a vote is finished serverside                                          | results   | server |
| MapVote_ChangeMap       | Called just before mapvote changes the map, return false to skip                   | map       | server |
| MapVote_MapIconCreated  | Called when a map icon panel is created                                            | panel     | client |
| MapVote_VotePanelOpened | Called when the vote panel is shown                                                |           | client |
| MapVote_VotePanelClosed | Called when the vote panel is hidden                                               |           | client |
