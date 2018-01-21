--
--  Game
--

local Gamestate     = requireLibrary("hump.gamestate")
local timer         = requireLibrary("hump.timer")
local Vector        = requireLibrary("hump.vector")
local tween         = timer.tween

Game = Gamestate.new()

local stuff = {}
function Game:enter()

	
end

function Game:update(dt)
   
end


local function drawFn()
    -- <Your drawing logic goes here.>
    -- love.graphics.draw(padLeft,a,2)
    love.graphics.setFont(font_TimesNewPixel)
    love.graphics.print(love.timer.getFPS(), 1, 1)
  end

function Game:draw()
    screen:draw(drawFn) -- Additional arguments will be passed to drawFn.
end