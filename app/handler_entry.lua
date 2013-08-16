require 'bamboo'

local redis = require 'bamboo.db.redis'
local redisdb = redis.connect({
  host = "127.0.0.1",
  port = 6379,
  db = 15,
})


local mongo = require 'bamboo.db.mongo'
local mongodb = mongo.connect({
  host = "127.0.0.1",
  port = 27017,
  db = 'test'
})

fptable(redisdb)
fptable(mongodb)
--_G.BAMBOO_MDB = mongodb
--_G.BAMBOO_DB = redisdb

local Person = require 'models.person'
bamboo.registerModel(Person, mongodb, redisdb)

local Comment = require 'models.comment'
bamboo.registerModel(Comment, mongodb, redisdb)

local function index(web, req)
    
    local persons = Person:all()
    fptable(persons)
    web:page(View("index.html"){'locals'})
    
end

local function add(web, req)
  return web:page(View('add.html'){})
end

local function addit(web, req)
  local params = req.PARAMS
  fptable(params)
  local person = Person(params)
  person:save()
  --fptable(Person)
  --fptable(person)

  return web:redirect('/')
end


URLS = { '/',
    ['/'] = index,
    ['index/'] = index,
    
    ['add/'] = add,
    ['addit/'] = addit,
    
    ['/test'] = function (web, req) return web:page(View('crossdomain.html'){}) end
}

