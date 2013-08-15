
local Model = require 'bamboo.model'

local Person = Model:extend {
  __name = "Person",
  __fields = {
    ['name'] = {},
    ['age'] = {},
    ['home'] = {}
  },
  
  equal = function (self, another)
    
    return 
      self.name == another.name
      and self.age == another.age
      and self.home == another.home
      and self.id == another.id
    
  end,

}

return Person
