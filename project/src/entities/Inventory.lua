--
-- Inventory Class

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local Gamestate     = requireLibrary("hump.gamestate")
local Class         = requireLibrary("hump.class")

--------------------------------------------------------------------------------
-- Class Definition
--------------------------------------------------------------------------------

Inventory = Class{
	init = function(self)
		self.items = {}
	end,
  addItem = function(self, itemName)
    if self.items[itemName] == nil then
      self.items[itemName] = 1
    else 
      self.items[itemName] = self.items[itemName] + 1
    end
    self:addedItemCallback(itemName)
    return self.items[itemName]
	end,
  removeItem = function(self, itemName)
    if self.items[itemName] > 1 then
      self.items[itemName] = nil
    else 
      self.items[itemName] = self.items[itemName] - 1
    end
    self:removedItemCallback(itemName)
    return self.items[itemName]
	end,
  countItem = function(self, itemName)
    if self.items[itemName] ~= nil then
      return self.items[itemName]
    else
      return 0
    end
  end,
  hasItem = function(self, itemName)
    return self:countItem(itemName) > 0
  end,
  addedItemCallback = function()
    -- callback to be overwritten
  end,
  removedItemCallback = function()
    -- callback to be overwritten
  end
}

return Inventory