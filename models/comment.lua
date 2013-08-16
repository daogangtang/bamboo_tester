
local Model = require 'bamboo.model'

local Comment = Model:extend {
  __name = "Comment",
  __fields = {
    ['content'] = {},
    ['from'] = {foreign="Person", st="ONE"},
    ['date'] = {}
  },
  
}

return Comment
