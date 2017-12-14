# Ares Details

## Archtectures
The names of all script files should follow the principles defined in Dota2 Bot scripting official [wiki](https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting). But for extra utility files, it's not restricited. Customed bot scripts is functional for overriding the default action or think functions. There're also many global functions and constants for coding.

### Team level
+ ```hero_selection.lua```
Define the team in hero selection process

+ ```team_desires.lua```
Principles about team decisionmaking, i.e, push, defend, or roshan

### Mode level
+ ```mode_[action]_generic.lua```
Define the generic action mode for all heros

+ ```mode_[action]_[hero].lua```
Define the action mode for specific hero

There're many ```[action]``` mode can be overrided:
+ ```laning```
+ ```attack```
+ ```roam```
+ ```retreat```
+ ```secret_shop```
+ ```side_shop```
+ ```rune```
+ ```push_tower_top```
+ ```push_tower_mid```
+ ```push_tower_bot```
+ ```defend_tower_top```
+ ```defend_tower_mid```
+ ```defend_tower_bottom```
+ ```assemble```
+ ```team_roam```
+ ```farm```
+ ```defend_ally```
+ ```evasive_maneuvers```
+ ```roshan```
+ ```item```
+ ```ward```

### Action level
+ ```ability_item_usage_generic.lua```
Define the generic ability and item usage for all heros

+ ```ability_item_usage_[hero].lua```
Define the generic ability and item usage for specific hero

+ ```item_purchase_generic.lua```
Define the generic item purchasing way for all heros

+ ```item_purchase_[hero].lua```
Define the item purchasing way for specific hero

## Challenges and Difficulties
+ Making a good file ```bot_[hero name].lua``` to replace or add official bots is a hard thing