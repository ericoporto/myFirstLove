--
--  Game
--

local Gamestate     = requireLibrary("hump.gamestate")
local timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local tween         = timer.tween
local map
local a
local b
local strength
local cnv

Game = Gamestate.new()

local stuff = {}
function Game:enter()
  map = sti("map/test.lua")
  a=0
  b=0
end

function Game:update(dt)
  if keys_pressed['up'] then
    a=a+1
    b=math.cos(a/32)
    map:update(dt)
  end
end


local function drawFn()
    -- <Your drawing logic goes here.>
    -- love.graphics.draw(padLeft,a,2)
    love.graphics.setShader()
    cnv = love.graphics.newCanvas(320,180)
    cnv:renderTo(function()

        -- mapa
        map:draw()


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