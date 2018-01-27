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

function Game:enter()
  img_chara_agent = love.graphics.newImage('img/chara_agent.png')
  local g_chara_agent = anim8.newGrid(24, 24, img_chara_agent:getWidth(), img_chara_agent:getHeight())

  cnv = love.graphics.newCanvas(GAME_WIDTH,GAME_HEIGHT)
  map = sti("map/test.lua")

  -- Create new dynamic data layer called "Sprites" as the 8th layer
  local layerSprites = map:addCustomLayer("Sprites", 2)
  -- Draw player
  layerSprites.draw = function(self)

    -- Temporarily draw a point at our location so we know
    -- that our sprite is offset properly
    love.graphics.setPointSize(8)
    love.graphics.points(math.floor(player.pos.x), math.floor(player.pos.y))

    player.current_animation[player.current_direction]:draw(player.sprite,player.pos.x-player.pxw/2,player.pos.y-player.pxh/1.1)

  end

  -- Get player spawn object
  for k, object in pairs(map.objects) do
    if object.name == "Player" then
      player = object
        break
      end
  end

  player = Character.init('player','img/chara_player.png',64,128)

  player.current_animation = player.animations.walk

  camera = Camera(player.pos.x, player.pos.y)
  a=0
  b=0
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
  player.current_animation[player.current_direction]:update(dt)

  map:update(dt)
  camera:move(dx/2, dy/2)

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