--
--
--  Created by Tilmann Hars
--  Copyright (c) 2014 Headchant. All rights reserved.
--

-- Set Library Folders
_LIBRARYPATH = "libs"
_LIBRARYPATH = _LIBRARYPATH .. "/"

requireLibrary = function(name)
	return require(_LIBRARYPATH..name)
end

-- Get the libs manually
local strict    = requireLibrary("strict")
local slam      = requireLibrary("slam")
local Terebi    = requireLibrary("terebi")
local Gamestate = requireLibrary("hump/gamestate")

-- the library for Tiled map
sti = requireLibrary("sti")

-- Declare Global Variables
screen = nil
class_commons = nil
common = nil
no_game_code = nil


-- fonts
font_16bfZX = nil
font_HelvetiPixel = nil
font_MicroStyle = nil
font_Minimal4 = nil
font_PixelMordred = nil
font_SullyVerge = nil
font_TimesNewPixel = nil
font_Verdana2 = nil

-- shader screen
shader_screen = nil

-- the keyboard and joystick interface
keys = {}

-- Global Functions inspired by picolove https://github.com/gamax92/picolove/blob/master/api.lua
function all(a)
	if a==nil or #a==0 then
		return function() end
	end
	local i, li=1
	return function()
		if (a[i] == li) then 
			i = i + 1 
		end
		while(a[i] == nil and i<=#a) do
			i = i + 1 
		end
		li = a[i]
		return a[i]
	end
end

function add(a, v)
	if a == nil then
		return
	end
	a[#a+1] = v
end

function del(a, dv)
	if a == nil then
		return
	end
	for i=1, #a do
		if a[i] == dv then
			table.remove(a, i)
			return
		end
	end
end

function rnd()
	return math.random()
end

--[[
require("tests.tests")
--]]

-- Creates a proxy via rawset.
-- Credit goes to vrld: https://github.com/vrld/Princess/blob/master/main.lua
-- easier, faster access and caching of resources like images and sound
-- or on demand resource loading
local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

-- Standard proxies
Image   = Proxy(function(k) return love.graphics.newImage('img/' .. k .. '.png') end)
Sfx     = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.ogg', 'static') end)
Music   = Proxy(function(k) return love.audio.newSource('music/' .. k .. '.ogg', 'stream') end)

--[[ examples:
    love.graphics.draw(Image.background)
-- or    
    Sfx.explosion:play()
--]]
    
-- Require all files in a folder and its subfolders, this way we do not have to require every new file
local function recursiveRequire(folder, tree)
    local tree = tree or {}
    for i,file in ipairs(love.filesystem.getDirectoryItems(folder)) do
        local filename = folder.."/"..file
        if love.filesystem.isDirectory(filename) then
            recursiveRequire(filename)
        elseif file ~= ".DS_Store" then
            require(filename:gsub(".lua",""))
        end
    end
    return tree
end



local function extractFileName(str)
	return string.match(str, "(.-)([^\\/]-%.?([^%.\\/]*))$")
end

-- Initialization
function love.load(arg)
	math.randomseed(os.time())
	love.graphics.setDefaultFilter("nearest", "nearest")
	-- love.mouse.setVisible(false)
    -- print "Require Sources:"
	recursiveRequire("src")
	Gamestate.registerEvents()
	Gamestate.switch(Game)

  -- Set nearest-neighbour scaling. Calling this is optional.
  Terebi.initializeLoveDefaults()

  -- Parameters: game width, game height, starting scale factor
  screen = Terebi.newScreen(320, 180, 3)
    -- This color will used for fullscreen letterboxing when content doesn't fit exactly. (Optional)
    :setBackgroundColor(64, 64, 64)

  -- add all font as objects
	font_16bfZX = love.graphics.newFont("fonts/16bfZX.ttf", 16)
	font_HelvetiPixel = love.graphics.newFont("fonts/HelvetiPixel.ttf", 16)
	font_MicroStyle = love.graphics.newFont("fonts/MicroStyle.ttf", 16)
	font_Minimal4 = love.graphics.newFont("fonts/Minimal4.ttf", 16)
	font_PixelMordred = love.graphics.newFont("fonts/PixelMordred.ttf", 16)
	font_SullyVerge = love.graphics.newFont("fonts/SullyVerge.ttf", 16)
	font_TimesNewPixel = love.graphics.newFont("fonts/TimesNewPixel.ttf", 16)
	font_Verdana2 = love.graphics.newFont("fonts/Verdana2.ttf", 16)

	--shader test from rxi
	shader_screen = love.graphics.newShader[[
		extern vec2 abberationVector;

		vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
			vec4 finalColor = vec4(1);
			finalColor.r = Texel(currentTexture, texCoords.xy + abberationVector).r;
			finalColor.g = Texel(currentTexture, texCoords.xy).g;
			finalColor.b = Texel(currentTexture, texCoords.xy - abberationVector).b;
			return finalColor;
		}
  ]]
end

-- Logic
function love.update( dt )
	
end




-- Rendering
function love.draw()
end

-- Input
function love.keypressed(key)
  if     key == '=' or key == '+' then
    screen:increaseScale()
  elseif key == '-' then
    screen:decreaseScale()
  elseif key == 'f11' then
    screen:toggleFullscreen()
	end	
	

end

function love.keyreleased()
	
end

function love.mousepressed()
	
end

function love.mousereleased()
	
end

function love.joystickpressed()
	
end

function love.joystickreleased()
	
end

-- Get console output working with sublime text
io.stdout:setvbuf("no")
