--
--  Game
--

local Gamestate     = requireLibrary("hump.gamestate")
local timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local Camera        = requireLibrary("hump.camera")
local tween         = timer.tween
local map
local a
local b
local strength
local cnv
local player
local camera

Game = Gamestate.new()

local stuff = {}
function Game:enter()
  player = {
    pos = {
      x = 64,
      y = 128
    }
  }

  camera = Camera(player.pos.x, player.pos.y)
  map = sti("map/test.lua")
  a=0
  b=0
end

function Game:update(dt)

  
  if keys_pressed['up'] then
    if player.pos.y>0 then
      player.pos.y=player.pos.y-4
    end
  end

  if keys_pressed['down'] then
    if player.pos.y<map.height*map.tileheight then
      player.pos.y=player.pos.y+4
    end
  end

  if keys_pressed['left'] then
    if player.pos.x>0 then
      player.pos.x=player.pos.x-4
    end
  end

  if keys_pressed['right'] then
    if player.pos.x<map.width*map.tilewidth then
      player.pos.x=player.pos.x+4
    end
  end

  a=a+1
  b=math.cos(a/32)

  local dx = player.pos.x - camera.x
  local dy = player.pos.y - camera.y
  map:update(dt)
  camera:move(dx/2, dy/2)

end


local function drawFn()
    -- <Your drawing logic goes here.>
    -- love.graphics.draw(padLeft,a,2)
    love.graphics.setShader()
    cnv = love.graphics.newCanvas(320,180)
    cnv:renderTo(function()


        local tx = camera.x - love.graphics.getWidth() / 2
        local ty = camera.y - love.graphics.getHeight() / 2
    
        if tx < 0 then 
            tx = 0 
        end
        if ty < 0 then 
            ty = 0 
        end
        --  if tx > map.width  * map.tilewidth  - love.graphics.getWidth()  then
        --      tx = map.width  * map.tilewidth  - love.graphics.getWidth()  
        --  end
        if ty > map.height * map.tileheight - love.graphics.getHeight() then
            ty = map.height * map.tileheight - love.graphics.getHeight()
        end
    
        tx = math.floor(tx)
        ty = math.floor(ty)

        print("tx = " , tostring(tx) , "; ty = " , tostring(ty))


	    map:draw(-tx, -ty, camera.scale, camera.scale)


        camera:draw(function()
            
        end)
        -- mapa

        -- zuera
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.setFont(font_Verdana2)
        love.graphics.print("O Papagaio come milho.\nperiquito leva a fama.\nCantam uns e choram outros\nTriste sina de quem ama.", 80+20*b, 25)
        love.graphics.rectangle("fill", 30+12*b, 30+15*b, 16, 32 )
    end)


    love.graphics.setShader(shader_screen)
    strength = math.sin(love.timer.getTime()*2)
    shader_screen:send("abberationVector", {strength*math.sin(love.timer.getTime()*7)/200, strength*math.cos(love.timer.getTime()*7)/200})

    love.graphics.draw(cnv,0,0)
    
end

function Game:draw()


    screen:draw(drawFn) -- Additional arguments will be passed to drawFn.


end