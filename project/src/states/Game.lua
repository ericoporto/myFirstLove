--
--  Game
--

local Gamestate     = requireLibrary("hump.gamestate")
local timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local Camera        = requireLibrary("hump.camera")
local anim8         = requireLibrary("anim8")
local tween         = timer.tween
local Character     = require 'src/entities/Character'
local map
local a
local b
local strength
local cnv
local player
local camera

Game = Gamestate.new()

local stuff = {}

local img_chara_player
local img_chara_agent
local player
local last_level

local list_triggers = {}
local list_enemySpawner = {}
local sprite_list = {}

function setLevel(n)
  if last_level==1 then 
    Music.theme:stop()
  end

  if n==1 then
    map = sti("map/level1.lua", { "box2d" })
    sprite_list = {}
    -- Create new dynamic data layer called "Sprites" as the nth layer
    local layerSprites = map:addCustomLayer("Sprites", #map.layers + 1)
    -- Draw player
    layerSprites.draw = function(self)
  
      -- Temporarily draw a point at our location so we know
      -- that our sprite is offset properly
      -- love.graphics.setPointSize(8)
      -- love.graphics.points(math.floor(player.pos.x), math.floor(player.pos.y))
  
      for _,spr in pairs(sprite_list) do
        spr.current_animation[spr.current_direction]:draw(spr.sprite,spr.pos.x-spr.pxw/2,spr.pos.y-spr.pxh/1.1)
      end
  
    end
  
    local spawn_point
    -- Get player spawn object
    for k, object in pairs(map.objects) do
      if object.name == "Player" then
        spawn_point = object
          break
        end
    end
  

    -- Get triggers object
    for k, object in pairs(map.objects) do
      if object.properties['type'] == "trigger" then
        table.insert(list_triggers,object)
        end
    end


    -- Get triggers object
    for k, object in pairs(map.objects) do
      if object.name == "ennemySpawner" then
        object.properties.id = tonumber(object.properties.id )
        table.insert(list_enemySpawner,object)
        end
    end

    player = Character.init('player','img/chara_player.png',spawn_point.x,spawn_point.y)
    table.insert(sprite_list,player)
  
    player.current_animation = player.animations.walk
  
    camera = Camera(player.pos.x, player.pos.y)
    a=0
    b=0
  
    Music.theme:play()
  end

  last_level = n
end

function Game:enter()
  img_chara_agent = love.graphics.newImage('img/chara_agent.png')
  local g_chara_agent = anim8.newGrid(24, 24, img_chara_agent:getWidth(), img_chara_agent:getHeight())

  cnv = love.graphics.newCanvas(GAME_WIDTH,GAME_HEIGHT)

  setLevel(1)
end

function Game:update(dt)

  local speed = 96

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

  
  if keys_pressed['up'] then
    if player.pos.y>0 then
      player.pos.y=player.pos.y-speed*dt
    end
  end

  if keys_pressed['down'] then
    if player.pos.y<map.height*map.tileheight then
      player.pos.y=player.pos.y+speed*dt
    end
  end

  if keys_pressed['left'] then
    if player.pos.x>0 then
      player.pos.x=player.pos.x-speed*dt
    end
  end

  if keys_pressed['right'] then
    if player.pos.x<map.width*map.tilewidth then
      player.pos.x=player.pos.x+speed*dt
    end
  end

  a=a+1
  b=math.cos(a/32)

  local dx = player.pos.x - camera.x
  local dy = player.pos.y - camera.y

  for _,spr in pairs(sprite_list) do
    spr.current_animation[spr.current_direction]:update(dt)
  end

  map:update(dt)
  camera:move(dx/2, dy/2)


  for k, object in pairs(list_triggers) do
    if object ~= nil then

      if object.x >= player.pos.x - player.pxw/2 and
      object.x <= player.pos.x + player.pxw/2 and 
      object.y >= player.pos.y - player.pxh/2 and
      object.y <= player.pos.y + player.pxh/2 then
      
        if object.properties['spawnEnnemy'] ~= nil then
          print(object.properties.spawnEnnemy)

          for j,enemySpawner in pairs(list_enemySpawner) do
            if enemySpawner.properties.id == tonumber(object.properties.spawnEnnemy) then 
              print('spawned!')
              local enemy = Character.init('enemy','img/chara_agent.png',enemySpawner.x,enemySpawner.y)
              enemy.current_direction = 'down'
              table.insert(sprite_list,enemy)

              enemySpawner = nil
              list_enemySpawner[j]=nil
            end
          end

          object = nil
          list_triggers[k]=nil
        end
      print('test')
        break
      end
    end

  end

  if player.pos.x>400 then
    setLevel(1)
  end

end


local function drawFn()
  -- <Your drawing logic goes here.>
  -- love.graphics.draw(padLeft,a,2)
  love.graphics.setShader()
  cnv:renderTo(function()


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

    -- print("tx = " , tostring(tx) , "; ty = " , tostring(ty))


    map:draw(-tx, -ty, camera.scale, camera.scale)


    camera:draw(function()
        
    end)
    -- mapa

    -- zuera
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setFont(font_Verdana2)
    love.graphics.print("ui do jogo placeholder",32,32)
    
    -- love.graphics.print("O Papagaio come milho.\nperiquito leva a fama.\nCantam uns e choram outros\nTriste sina de quem ama.", 80+20*b, 25)
    -- love.graphics.rectangle("fill", 30+12*b, 30+15*b, 16, 32 )
  end)


  love.graphics.setShader(shader_screen)
  strength = math.sin(love.timer.getTime()*2)
  shader_screen:send("abberationVector", {strength*math.sin(love.timer.getTime()*7)/200, strength*math.cos(love.timer.getTime()*7)/200})

  love.graphics.draw(cnv,0,0)
  
end

function Game:draw()


  screen:draw(drawFn) -- Additional arguments will be passed to drawFn.


end