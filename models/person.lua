
local Model = require 'bamboo.model'

local Person = Model:extend {
  __name = "Person",
  __fields = {
    ['name'] = {},
    ['age'] = {},
    ['home'] = {},

    ['ff1'] = {foreign="Comment", st='ONE'},
    ['ff2'] = {foreign="Comment", st='MANY'},
    ['ff3'] = {foreign="Comment", st='LIST'},
    ['ff4'] = {foreign="Comment", st='FIFO', fifolen=2},
    ['ff5'] = {foreign="Comment", st='ZFIFO', fifolen=2},
    
    ['ffa'] = {foreign="ANYOBJ", st='ONE'},
    ['ffb'] = {foreign="ANYOBJ", st='MANY'},
    ['ffc'] = {foreign="ANYOBJ", st='LIST'},
    ['ffd'] = {foreign="ANYOBJ", st='FIFO'},
    ['ffe'] = {foreign="ANYOBJ", st='ZFIFO'},
    
    
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
