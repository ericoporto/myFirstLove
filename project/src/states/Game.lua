--
--  Game State 
--

local Gamestate     = requireLibrary("hump.gamestate")
local Timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local Camera        = requireLibrary("hump.camera")
local anim8         = requireLibrary("anim8")
local Chain         = requireLibrary("knife.chain")
local Tween         = Timer.tween
local Character     = require 'src.entities.Character'
local Item          = require 'src.entities.Item'
local Inventory     = require 'src.entities.Inventory'
local ScreenMsg     = require 'src.entities.ScreenMsg'
local lume          = requireLibrary("lume")
local WaitForButton = requireLibrary("waitforbutton")

-- the level map to be loaded with sti
local map  

-- strength for the shader
local strength  

-- canvas for drawing
local cnv  

-- a variable to hold player character information
local player

-- game camera
local camera

-- world used for physics
local world 

Game = Gamestate.new()

-- holds information on the screen text dialog.
-- use .setMsg(msg) for writing text on screen
local onScreenDialog = ScreenMsg()

local last_level

local list_triggers = {}
local list_exit_points = {}
local list_enemySpawner = {}
local sprite_list = {}

local transmissionMessages = {}
local currentTransmissionId = nil
local nextTransmissionRequest = false

local agent_ray_of_seeing = 160


-- Prevents the player from skipping too much by disabling the 
-- Accept button after it's checked
local is_accept_enable = true
local function f_isAcceptPressed()
  if  is_accept_enable and keys_pressed['buttona'] then 
    is_accept_enable = false

    -- we can remove buttona if claiming the event is necessary
    keys_pressed['buttona'] = nil

    -- prevents player from skipping all text by accident
    Timer.after(0.2, function()
      is_accept_enable = true
    end)
    return true
  else
    return false
  end
end

-- after Accept is pressed, the passed function is called
local function waitAccept(fn)
  WaitForButton:init(f_isAcceptPressed, fn)
end


-- every local function we want to expose to the tiled lua script
-- MUST be in Action table
local Action = {}

-- shows a dialog, and executes the next function after a period 
-- of time
function Action.timedSay (seconds, text)
  return function (go)
      onScreenDialog:setMsg(text)
      Timer.after(seconds, go)
  end
end

-- shows a dialog, and after Accept is pressed, runs the next function
-- in chain
function Action.Say ( text)
  return function (go)
      onScreenDialog:setMsg(text)
      waitAccept(go)
  end
end

-- close dialog from screen, needs to be called after a Say to remove it
-- from screen.
function Action.closeSay ()
  return function (go)
      onScreenDialog:setMsg()
      go()
  end
end

-- a helper function to run a lua script written as string, using Chain
-- Chain allows passing the next function as callback, enabling that the
-- the next function can be executed from Asynchronous calls, but
-- hides this complexity
local function runLuaScriptInChain(scriptAsString)

  local context = {Chain = Chain,
    timedSay = Action.timedSay,
    closeSay = Action.closeSay,
    Say = Action.Say,
  }

  setmetatable(context, { __index = _G })
  local aLuaFunction = loadstring('Chain(	' .. scriptAsString .. ')()')
  setfenv(aLuaFunction, context)
  assert(aLuaFunction)()
end

-- initialize player Character 
local function initializePlayerCharacter(spawnX,spawnY)
  local player = Character.init('player','img/chara_player.png',spawnX,spawnY)
  player.body = love.physics.newBody(world, player.pos.x, player.pos.y, "dynamic")
  player.body:setLinearDamping(10)
  player.body:setFixedRotation(true)
  player.shape   = love.physics.newCircleShape(player.pxw/2, player.pxh/2, 6)
  player.fixture = love.physics.newFixture(player.body, player.shape)
  player.inventory = Inventory()

  -- let's define how the items in this game works!
  player.inventory:defineItem('radio',
  -- draw function
  function(self)
    for radio_i =1, self.count() do
      love.graphics.draw(Image.radio_ui_icon,radio_i*(Image.radio_ui_icon:getWidth()+2),6)
    end
  end,
  -- update function
  function(self,dt)
        -- use item if available
    if f_isAcceptPressed() then
      goToGameState('Cutscene')
      self.remove()
    end
  end)

  -- a callback function for when an item is added, we can use this 
  -- for sound effect and triggering drawing effects
  player.inventory.addedItemCallback = function(self,itemName)
    -- an item was added!
    if itemName=='radio' then
      Sfx.GGJ18_walkie_talkie:play()
    end

    if debug_mode then 
      print(self:countItem(itemName))
    end
  end

  table.insert(sprite_list,player)

  player.current_animation = player.animations.walk

  return player
end

-- initialize an enemy character
local function initializeEnemyCharacter(spawnX,spawnY,enemyId)
  enemyId = tonumber(enemyId )
  -- table.insert(list_enemySpawner,object)
  local enemy = Character.init('enemy','img/chara_agent.png',spawnX,spawnY)
  enemy.id = enemyId
  enemy.active = false
  enemy.body = love.physics.newBody(world, enemy.pos.x, enemy.pos.y, "dynamic")
  enemy.body:setLinearDamping(10)
  enemy.body:setFixedRotation(true)
  enemy.shape   = love.physics.newCircleShape(enemy.pxw/2, enemy.pxh/2, 6)
  enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
  enemy.body:setActive(false)
  enemy.pursuitacc = 0
  enemy.update = function(target)
    if onScreenDialog:hasMsg() then
    else
      local vx, vy = enemy.body:getLinearVelocity()
      local max_acc = 12
      local acc = enemy.pursuitacc
      if enemy.pursuitacc<max_acc then
        enemy.pursuitacc = enemy.pursuitacc + 1
      end

      local dst = lume.distance(enemy.pos.x, enemy.pos.y, target.pos.x, target.pos.y)
      if (dst < agent_ray_of_seeing) then
        if (enemy.pos.x > target.pos.x + 6) then
          vx = vx - acc
        elseif (enemy.pos.x < target.pos.x - 6) then
          vx = vx + acc
        end

        if (enemy.pos.y > target.pos.y + 6) then
          vy = vy - acc
        elseif (enemy.pos.y < target.pos.y - 6) then
          vy = vy + acc
        end
        enemy.body:setLinearVelocity(vx, vy)
        enemy.pos.x, enemy.pos.y = enemy.body:getWorldCenter()

        if (vx > 10) then
          enemy.current_direction = 'right'
          if vy > 10 then
            enemy.current_direction = 'down_right'
          elseif vy < -10 then
            enemy.current_direction = 'up_right'
          end
        elseif (vx < -10) then
          enemy.current_direction = 'left'
          if vy > 10 then
            enemy.current_direction = 'down_left'
          elseif vy < -10 then
            enemy.current_direction = 'up_left'
          end
        else
          if enemy.pursuitacc > 1 then
            enemy.pursuitacc = enemy.pursuitacc - 1
          end

          if vy > 10 then
            enemy.current_direction = 'down'
          elseif vy < -10 then
            enemy.current_direction = 'up'
          end
        end
      end
    end
  end
  table.insert(sprite_list,enemy)
  return enemy
end

-- changes the level for level n
local function setLevel(n)
  list_triggers = {}
  list_exit_points = {}
  list_enemySpawner = {}
  sprite_list = {}
  transmissionMessages = {}
  currentTransmissionId = nil

  map = sti("map/level" .. n .. ".lua", { "box2d" })

  if last_level==1 then 
    Music.ggj18_theme:stop()
    -- Music.theme:stop()
  elseif n==2 then
    -- Music.theme:stop()
  elseif n==3 then
    -- Music.theme:stop()
  elseif n==4 then
    -- Music.theme:stop()
  elseif n==5 then
    Music.ggj18_ambient:stop()
    Music.ggj18_theme:stop()
    Music.ggj18_theme:play()
  end

  if n==1 then
    Music.ggj18_theme:stop()
    Music.ggj18_ambient:play()
  elseif n==2 then
    -- Music.theme:play()
  elseif n==3 then
    -- Music.theme:play()
  elseif n==4 then
    -- Music.theme:play()
  elseif n==5 then
    -- Music.theme:play()
  end
    
  if map ~= nil then
    -- Prepare physics world
    world = love.physics.newWorld(0, 0)

    -- Prepare collision objects
    map:box2d_init(world)

    sprite_list = {}
    -- Create new dynamic data layer called "Sprites" as the nth layer
    local layerSprites = map:addCustomLayer("Sprites", #map.layers - 1)
    -- Draw player
    layerSprites.draw = function(self)
  
      -- Temporarily draw a point at our location so we know
      -- that our sprite is offset properly
      -- love.graphics.setPointSize(8)
      -- love.graphics.points(math.floor(player.pos.x), math.floor(player.pos.y))
  
      for _,spr in pairs(sprite_list) do
        if spr.active then
          spr.current_animation[spr.current_direction]:draw(spr.sprite,spr.pos.x-spr.pxw/2,spr.pos.y-spr.pxh/1.1)
        end
        if spr.type == 'enemy' then
          if spr.active then
            spr.update(player)
          end        
        end
        
        if debug_mode then
          if spr.body ~= nil then 
            love.graphics.setColor(255,0,0)
            -- love.graphics.polygon("line",spr.body:getWorldPoints(spr.shape:getPoints()))
            local x, y = spr.body:getWorldCenter()
            love.graphics.circle("line", x, y, 4)
          end
          love.graphics.setColor(20, 180, 255)
          love.graphics.circle("line", spr.pos.x, spr.pos.y, agent_ray_of_seeing)
          love.graphics.setColor(255,255,255)
        end
      end
    end
  
    local spawn_point
    
    -- let's look all map objects
    for k, object in pairs(map.objects) do

      -- Get exit points of the map
      if object ~= nil and  object.name == "Exit" then
        table.insert(list_exit_points, object)
      end

      -- Get player spawn object
      if object ~= nil and  object.name == "Player" then
        spawn_point = object
      end

      -- let's get trigger objects
      -- the msg different nil can be removed once the maps are refactored
      if object ~= nil and  object.properties['type'] == "trigger" and object.properties.msg ~= nil then
        table.insert(list_triggers,object)
        object.properties.id = tonumber(object.properties.spawnEnnemy )
        transmissionMessages[object.properties.id] = {}
        local aMessages = lume.splitStr(object.properties.msg, "&")
        for i = 1, #aMessages do
          table.insert(transmissionMessages[object.properties.id], { seen = false, msg = aMessages[i] })
        end
        table.insert(transmissionMessages[object.properties.id], { seen = false, msg = "" })
      end

      -- let's look if item's should be placed in map
      if object ~= nil and  object.name == "itemSpawner" then
        if object.properties.item == 'radio' then
          local radio = Item.init('radio','img/chara_radio.png',object.x,object.y)
          table.insert(sprite_list,radio)
          object = nil 
          map.objects[k] = nil
        end
      end 

      -- let's place enemys where required
      if object ~= nil and  object.name == "ennemySpawner" then
        initializeEnemyCharacter(object.x,object.y,object.properties.id)
      end

    end

    -- let's initialize the player only once, this game is single player
    player = initializePlayerCharacter(spawn_point.x,spawn_point.y)
  
    -- let's set the camera to track the player
    camera = Camera(player.pos.x, player.pos.y)
  end

  last_level = n
end



-- everytime we enter this gamestate, we do this
function Game:enter()
  is_accept_enable = true

end



-- just called the first time we enter this state
function Game:init()
  cnv = love.graphics.newCanvas(GAME_WIDTH,GAME_HEIGHT)

  -- got to the first level
  setLevel(0)
end


-- this is the update function
-- if this state is the current state, it will be called every dt time
function Game:update(dt)
  -- update wait for button, this will claim a button if
  -- it's waiting a press
  WaitForButton:update(dt)

  -- Make sure to do this or nothing will work!
  -- updates Timer, pay attention to use dot instead of collon
  Timer.update(dt)

  -- update the world, for physics
  world:update(dt)


  -- player movement related functions
  local speed = 96
  
  -- responsive player direction in animation
  if keys_pressed['up'] and keys_pressed['right'] then 
    player.current_direction = 'up_right'
  elseif  keys_pressed['up'] and keys_pressed['left'] then 
    player.current_direction = 'up_left'
  elseif  keys_pressed['down'] and keys_pressed['right'] then 
    player.current_direction = 'down_right'
  elseif  keys_pressed['down'] and keys_pressed['left'] then 
    player.current_direction = 'down_left'
  elseif  keys_pressed['up'] then 
    player.current_direction = 'up'
  elseif  keys_pressed['left'] then 
    player.current_direction = 'left'
  elseif  keys_pressed['right'] then 
    player.current_direction = 'right'
  elseif  keys_pressed['down'] then 
    player.current_direction = 'down'
  end

  
  local force_x, force_y = 0, 0
  local vx, vy = player.body:getLinearVelocity()
  local acc = 44
  
  if keys_pressed['up'] or keys_pressed['down'] then
    if keys_pressed['up']then
      if player.pos.y > 0 then
        -- player.pos.y=player.pos.y-speed*dt
        -- force_y = force_y - 400
        vy = vy - acc
      end
    end

    if keys_pressed['down'] then
      if player.pos.y < map.height*map.tileheight then
        -- player.pos.y=player.pos.y+speed*dt
        -- force_y = force_y + 400
        vy = vy + acc
      end
    end
  else
    vy = lume.lerp(vy, 0, 0.2)
  end

  if keys_pressed['left'] or keys_pressed['right'] then
    if keys_pressed['left'] then
      if player.pos.x > 0 then
        -- player.pos.x=player.pos.x-speed*dt
        -- force_x = force_x - 400
        vx = vx - acc
      end
    end

    if keys_pressed['right'] then
      if player.pos.x < map.width*map.tilewidth then
        -- player.pos.x=player.pos.x+speed*dt
        -- force_x = force_x + 400
        vx = vx + acc
      end
    end
  else
    vx = lume.lerp(vx, 0, 0.2)
  end

  if onScreenDialog:hasMsg() then
    vx = 0
    vy = 0
  else
    vx = lume.clamp(vx, -140, 140)
    vy = lume.clamp(vy, -140, 140)
  end

  player.body:setLinearVelocity(vx, vy);

	-- player.body:applyForce(force_x, force_y)
  player.pos.x, player.pos.y = player.body:getWorldCenter()
  player.pos.y = player.pos.y + 2

  local dx = player.pos.x - camera.x
  local dy = player.pos.y - camera.y

  for _,spr in pairs(sprite_list) do
    spr.current_animation[spr.current_direction]:update(dt)
  end

  -- let's update the map, this ensures any in map animations happen
  map:update(dt)

  -- let's move the camera to the difference between camera and player
  -- this is smoothed by only moving the camera to half the difference
  -- so if next frame the player is in the same place, we get a nice 
  -- 1/x like tweening
  camera:move(dx/2, dy/2)


  -- lets check collision with items
  for k, object in pairs(sprite_list) do
    if object ~= nil and object.type == 'radio' then

      if object.pos.x >= player.pos.x - player.pxw/2 and
        object.pos.x <= player.pos.x + player.pxw/2 and 
        object.pos.y >= player.pos.y - player.pxh/2 and
        object.pos.y <= player.pos.y + player.pxh/2 then

          player.inventory:addItem('radio')

        object = nil
        sprite_list[k] = nil

        -- this is where we need to add the item radio to the inventory
        --goToGameState('Cutscene')

      end 
    end 
  end


  --     this function checks for all exit points and go to 
  -- next level then when player is on top
  for k, object in pairs(list_exit_points) do
    if object ~= nil then

      if object.x >= player.pos.x - player.pxw/2 and
        object.x <= player.pos.x + player.pxw/2 and 
        object.y >= player.pos.y - player.pxh/2 and
        object.y <= player.pos.y + player.pxh/2 then

        -- hack, we need to have a property to tell the proper level to advance to
        -- we don't have, so we just advance to the next level
        setLevel(last_level+1)

      end 
    end 
  end

  -- this is the what makes the messages work! 
  -- this block of code can be removed if we refactor the game maps to just
  -- have lua functions! (using Say('string') commands)
  if currentTransmissionId ~= nil then
    local i = 1
    local t = transmissionMessages[currentTransmissionId]
    
    if t ~= nil then
      for i = 1, #t do
        if i == #t then
          local playCutscene = false
          for j,ent in pairs(sprite_list) do
            if ent.type == 'enemy' and ent.id == currentTransmissionId then
              playCutscene = not ent.active
              ent.active = true
              ent.body:setActive(true)
            end
            if playCutscene then 

              --goToGameState('Cutscene')
            end
          end
          -- break
        end
        if not t[i].seen and f_isAcceptPressed() then
          --t[i].seen = onScreenDialog:skipMessage()
          -- using the above breaks Cutscenes
          -- going back to using true
          t[i].seen = true
        end
        if not t[i].seen then
          onScreenDialog:setMsg(t[i].msg)
          break
        end
      end
    end
  end

  -- this function checks for all triggers and triger then when player is on top
  for k, object in pairs(list_triggers) do
    if object ~= nil then

      if object.x + object.width >= player.pos.x - player.pxw / 2 and
          object.x <= player.pos.x + player.pxw / 2 and 
          object.y >= player.pos.y - player.pxh / 2 and
          object.y-object.height <= player.pos.y + player.pxh / 2 then
        
        currentTransmissionId = tonumber(object.properties.id)
      
        -- I would like to remove the previous code and have
        --     runLuaScriptInChain(object.properties.runLuaScript)
        -- doing so would make this block of code repeat all the time.
        -- this can be solved by killing this object:
        --     object = nil	
        --     list_triggers[k]=nil

        break
      end
    end

  end

  -- update onScreenDialog
  onScreenDialog:update(dt)

  -- player update inventory is here so it won't conflict with the dialog
  -- it has to be after all f_isAcceptPressed
  -- update the inventory
  if player ~= nil then
    player.inventory:update(dt)
  end


  if restart == true then
    restart = false
    setLevel(last_level)
  end

end



local function drawFn()
  -- <Your drawing logic goes here.>
  -- let's disable the shader before drawing everything
  love.graphics.setShader()
  cnv:renderTo(function()
    love.graphics.clear(0,0,0,255)

    -- let's first calculate map translation for the
    -- hump camera to work with sti
    local tx = camera.x - GAME_WIDTH / 2
    local ty = camera.y - GAME_HEIGHT / 2

    if tx < 0 then 
        tx = 0 
    end
    if ty < 0 then 
        ty = 0 
    end
    if tx > map.width  * map.tilewidth  - GAME_WIDTH  then
        tx = map.width  * map.tilewidth  - GAME_WIDTH 
    end
    if ty > map.height * map.tileheight - GAME_HEIGHT then
        ty = map.height * map.tileheight - GAME_HEIGHT
    end

    tx = math.floor(tx)
    ty = math.floor(ty)

    -- now draw the map
    map:draw(-tx, -ty, camera.scale, camera.scale)
    if debug_mode then
      -- this draws the box2d interpretation of collisions 
      map:box2d_draw(-tx, -ty, camera.scale, camera.scale)
    end

    camera:draw(function()
        -- if we had to draw something allign with the camera,
        -- but not in the map, we would need to do it here
        -- right now this is empty
    end)

    -- draws items in inventory
    if player ~= nil then
      player.inventory:draw()
    end

    -- draw screen dialog
    onScreenDialog:draw()
    
    if debug_mode then
      -- let's draw additional debug info
      love.graphics.setColor( 255, 255, 255, 255 )
      love.graphics.setFont(font_Verdana2)
      love.graphics.print("DEBUG MODE",32,32)
      love.graphics.print("player x="..player.pos.x..", y="..player.pos.y,32,8)
    end
    
  end)

  -- now we enable the shader, this will translate pixel position and colors once
  -- the next draw is called
  love.graphics.setShader(shader_screen)
  strength = math.sin(love.timer.getTime()*2)
  shader_screen:send("abberationVector", {
    lume.clamp(strength * math.sin(love.timer.getTime() * 3) / 200, 0, 100), 
    lume.clamp(strength * math.sin(love.timer.getTime() * 5) / 200, 0, 100)
  })

  -- draw everything on screen
  love.graphics.draw(cnv,0,0)
  
end

function Game:draw()


  screen:draw(drawFn) -- Additional arguments will be passed to drawFn.


end

return Game