  [Tiled](http://www.mapeditor.org/) is the map editor used for this game. 
It can be [downloaded here](https://thorbjorn.itch.io/tiled). I used Tiled 1.1.1
which was the latest stable when Codename_LT was made, but should be good with the 
latest stable available.

In Codename_LT repo, download the code, and look inside the folder `project/map`. There
are 5 tmx files, level0.tmx to level4.tmx, those the game levels. More levels can
be added by editing `Game.lua` in `project/src/states`, but I am not going to explain
this in this document.

With Tiled opened, look into layers. If a layer has the custom property with **key**
`collidable` with a value that is a **string**, written `true`, that layer is considered
a collidable, and anything drawn there will be collidable, even if it's *invisible*. 
Use the **ERASER** to erase the tiles instead of painting with transparent tiles. 
Right now, there is only a single collidable layer, and it's called `tileLayerWalls`.

We placed objects in two layers, one is called objDecoracao, to store decoratives, and
other is called objLayer. The engine doesn't care for the layers, it will search all the
map looking for objects that have special things in them:

- An object named `Player`, it will be the player entry point in the map.

- An object named `Exit`, it will be the exit point of the map, to advance to next Level.

- An object named `itemSpawner`, with the custom property `item`. Acceptable values for
item right now are either `radio` or `secret` (the suitcase).

- An object named `ennemySpawner` (with typo TM!) with a custom property id that takes a
numeric value. This will be considered a spawn point for agents, it will be better explained
later on.

- An object with the custom property `type` with string value `trigger`. This is a trigger object.
I will explain below how they work.

## trigger objects!

A trigger object contain a field called runLuaChain that takes a string text containing a valid
Lua Chain for the engine. 

A simple chain can be of the type:

    Say('This is some text!'),
    Say('Some more text!'),
    closeSay(),
    SpawnEnemy(3)

Much attention to the proper comma on all lines except the last. `SpawnEnemy(number)` spawns enemys
in the spawn points of the same id as the number passed. After a `Say('text')`, a `closeSay()` is needed
to close the text dialog. 

Supported actions right now:

    SpawnEnemy( number_id )
    Say( string_text )
    timedSay( seconds_number , string_text )
    closeSay(  )
    playSound( string_soundName )
    EndGame(  )


If your trigger object runs a Lua Chain ( you can just add a closeSay() if it needs to be empty), you 
can also add a custom property runLuaScript and run pure lua functions. They aren't chained so they will
happen instantly.

**Trigger objects are destroyed when the player activates them!**

## Adding more features

Sure it's possible!
