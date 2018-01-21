--
--  Game
--

local Gamestate     = requireLibrary("hump.gamestate")
local timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local tween         = timer.tween
local a
local b

Game = Gamestate.new()

local stuff = {}
function Game:enter()
    a=0
	b=0
end

function Game:update(dt)
   a=a+1
   b=math.cos(a/32)
end


local function drawFn()
    -- <Your drawing logic goes here.>
    -- love.graphics.draw(padLeft,a,2)
    love.graphics.setFont(font_Verdana2)
    love.graphics.print(love.timer.getFPS(), 1, 1)
    love.graphics.rectangle("fill", 5+10*b, 50*b, 60, 120 )
  end

function Game:draw()
    love.graphics.setShader(shader_screen)
    screen:draw(drawFn) -- Additional arguments will be passed to drawFn.
end