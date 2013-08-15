local testing = require "bamboo.testing"

local NAMES = {
'Aaron亚伦',
'Abraham亚伯拉罕',
'Albert艾伯特',
'Andrew安德鲁',
'Ben本',
'Benson本森',
'Bill比尔',
'Brant布兰特'
}

local HOMES = {'AAA', 'BBB', 'CCC', 'DDD', 'EEE', 
'FFF', 'GGG', 'HHH', 'III', 'JJJ'}

local ITEMS = 100

context("Bamboo Core Feature Testing", function ()

  -- all models were registered in handler_entry.lua
  -- now we can use them by bamboo.getModelByName
  local Person = bamboo.getModelByName('Person')
  local mongodb = Person.__db
  local collection = Person.__collection
  -- clean the test target collection
  mongodb:drop(collection)

  -- add ITEMS items
  math.randomseed(os.time())
  for i = 1, ITEMS do
    local p = Person {
      name = NAMES[math.random(1, 8)],
      age = math.random(1,ITEMS),
      home = HOMES[math.random(1,10)],
    }
    p:save()
  end
  
  context("Global Functions Defined", function ()
    
    test("isClass()", function ()
      assert_equal(isClass(Person), true)
      assert_equal(isClass({}), false)
      local instance = Person:getByIndex(1)
      assert_equal(isClass(instance), false)
    end)
    test("isInstance()", function ()
      local instance = Person:getByIndex(1)
      assert_equal(isInstance(instance), true)			
    end)
    test("isQuerySet()", function ()
      local query_set = Person:all()
      assert_equal(isQuerySet(query_set), true)
    end)
    
    
    --[[
    local tester = testing.browser("tester")
    local t1 = socket.gettime()
    local ret 
    for i=1, 10000 do
      ret = tester:click("/test")
    end
    local t2 = socket.gettime()
    print(t2 - t1)
    --]]
  end)
  
  context("Assertions", function ()
    test("I_AM_CLASS()", function ()
      local ret, err = pcall(I_AM_CLASS, Person)
      assert_equal(ret, true)
    end)
    test("I_AM_INSTANCE()", function ()
      local instance = Person:getByIndex(1)
      local ret, err = pcall(I_AM_INSTANCE, instance)
      assert_equal(ret, true)
    end)
    test("I_AM_QUERY_SET()", function ()
      local query_set = Person:all()
      local ret, err = pcall(I_AM_QUERY_SET, query_set)
      assert_equal(ret, true)
    end)
    
  end)

	context("Session - session.lua", function ()
			
	end)
	
	context("Web & Request - web.lua", function ()
			
	end)

	context("Form - form.lua", function ()
			
	end)
	

	context("Model - model.lua", function ()


		
		
		context("Basic API", function ()

      test("test all", function ()
        local instances = Person:all()
        assert_equal(#instances, ITEMS)
        
        for i, v in ipairs(instances) do
          assert_equal(v:equal(v), true)
        end
        
        local instances2 = Person:all({}, 'rev')
        assert_equal(#instances2, ITEMS)
        
        for i, v in ipairs(instances2) do
          assert_equal(v:equal(v), true)
        end
        
        -- check all the reverse results
        for i, v in ipairs(instances2) do
          assert_equal(v:equal( instances[ITEMS+1-i], true ), true)
        end
        
        -- 检测只取name字段
        local instances3 = Person:all({name=true}, 'rev')
        assert_equal(#instances3, ITEMS)
        
        
        for i, v in ipairs(instances3) do
          -- 正向检测
          assert_equal(v.name, instances[ITEMS+1-i].name)
          -- 逆向检测
          assert_equal(v.age == instances[ITEMS+1-i].age, false)
        end
        
        
      end)
    
    
      test("test getById, getByIndex", function ()
        local instance = Person:getByIndex(10)
        local id = instance.id
        local newobj = Person:getById(id)
        
        assert_equal(instance.name, newobj.name)
        assert_equal(instance.age, newobj.age)
        assert_equal(instance.home, newobj.home)
        
        local newobj = Person:getById(id, {age=true})
        
        assert_equal(instance.name == newobj.name, false)
        assert_equal(instance.age == newobj.age, true)
        assert_equal(instance.home == newobj.home, false)
        
      end)
      
      test("test getByIds, slice", function ()
        local instances = Person:slice({}, 21, 30)
        local ids = {}
        instances:each(function (e) table.insert(ids, e.id) end)
        
        local objs = Person:getByIds(ids)
        
        for i, v in ipairs(instances) do
          assert_equal(v:equal(objs[i]), true)
        end
        
        local instances2 = Person:slice({}, 21, 30, 'rev')
        local ids = {}
        instances2:each(function (e) table.insert(ids, e.id) end)
        
        local objs2 = Person:getByIds(ids)
        
        for i, v in ipairs(instances2) do
          assert_equal(v:equal(objs2[i]), true)
        end
        
        -- 检查正反向顺序
        for i, v in ipairs(objs2) do
          assert_equal(v:equal(objs[10+1-i]), true)
        end
        
      end)
      
      test("test allIds", function ()
        local all_ids = Person:allIds()
        assert_equal(#all_ids == ITEMS, true)
        
        for i, v in ipairs(all_ids) do
          assert_equal(type(v) == 'string', true)
        end
        
        local all_ids2 = Person:allIds('rev')
        assert_equal(#all_ids2 == ITEMS, true)
        
        for i, v in ipairs(all_ids2) do
          assert_equal(v == all_ids[ITEMS+1-i], true)
        end
        
      end)
      
      test("test sliceIds", function ()
        local all_ids = Person:sliceIds(11, 20)
        assert_equal(#all_ids == 10, true)
        
        for i, v in ipairs(all_ids) do
          assert_equal(type(v) == 'string', true)
        end
        
        local all_ids2 = Person:sliceIds(11, 20, 'rev')
        assert_equal(#all_ids2 == 10, true)
        
        for i, v in ipairs(all_ids2) do
          assert_equal(v == all_ids[10+1-i], true)
        end
        
      end)
    
      test("test numbers", function ()
        local n = Person:numbers()
        assert_equal(n == ITEMS, true)
      end)
      
      test("test count", function ()
        local n = Person:count({name=startsWith('B')})
        local persons = Person:all()
        local cnt = 0
        persons:each(function (u) if u.name:startsWith('B') then cnt = cnt + 1 end end)
        
        assert_equal(n == cnt, true)
      end)
      
      test("test get", function ()
        local persons = Person:all()

        -- test high level logic api
        local p = Person:get({name=contains('Albert')})
        local np
        persons:each(function (u) if u.name:contains('Albert') then np = u; return false end end)
        assert_equal(p:equal(np), true)
        
        -- test mongo style query args: $query
        local p = Person:get({
          ['$query'] = {
            age = {
              ['$gte'] = 20,
              ['$lt'] = 50
            }
          }
        })
        local np
        persons:each(function (u) if u.age >= 20 and u.age < 50 then np = u; return false end end)
        assert_equal(p:equal(np), true)
        
        -- test mongo style query args: $regex
        local p = Person:get({
          ['$query'] = {
            ['$regex'] = 'Albert'
          }
        })
        local np
        persons:each(function (u) if u.name:contains('Albert') then np = u; return false end end)
        assert_equal(p:equal(np), true)
        
        
        -- test fields
        local p = Person:get({
          ['$query'] = {
            ['$regex'] = 'Albert'
          }
        }, {name=true})
        local np
        persons:each(function (u) if u.name:contains('Albert') then np = u; return false end end)
        
        assert_equal(p.name == np.name, true)
        assert_equal(p.age == np.age, false)
        
        
      end)
      
      
      test("test filter", function ()
        local persons = Person:all()

        -- test high level logic api
        local ps = Person:filter({name=contains('Albert')})
        assert_equal(type(ps) == 'table', true)
        local nps = {}
        persons:each(function (u) if u.name:contains('Albert') then table.insert(nps, u) end end)
        
        for i, v in ipairs(ps) do
          assert_equal(v:equal(nps[i]), true)
        end
      
        -- test javascript query grammer
        local ps = Person:filter({
          ["$where"] = "obj.name.indexOf('Albert') == 0"
        })
        local nps = {}
        persons:each(function (u) if u.name:startsWith('Albert') then table.insert(nps, u) end end)
        
        for i, v in ipairs(ps) do
          assert_equal(v:equal(nps[i]), true)
        end
      
      
        -- test fields
        local ps = Person:filter({
          ['$query'] = {
            ['$regex'] = 'Albert'
          }
        }, {name=true})
        assert_equal(type(ps) == 'table', true)
        local nps = {}
        persons:each(function (u) if u.name:contains('Albert') then table.insert(nps, u) end end)
        
        for i, v in ipairs(ps) do
          assert_equal(v.name == nps[i].name, true)
          assert_equal(v.age == nps[i].age, false)
        end
      
      
        -- test $orderby
        local ps = Person:filter({
          ['$query'] = {
            ['$regex'] = '^A'
          },
          ['$orderby'] = {age=1}
        })
        assert_equal(type(ps) == 'table', true)
        local nps = {}
        persons:each(function (u) if u.name:startsWith('A') then table.insert(nps, u) end end)
        table.sort(nps, function (a, b) return a.age < b.age  end)
        
        for i, v in ipairs(ps) do
          assert_equal(v:equal(nps[i]), true)
        end
      
        -- test $maxScan
        local ps = Person:filter({
          ['$query'] = {
            ['$regex'] = '^A'
          },
          ['$maxScan'] = 10,
          ['$orderby'] = {age=1}
        })
        assert_equal(type(ps) == 'table', true)
        local nps = {}
        persons:each(function (u) if u.name:startsWith('A') then table.insert(nps, u) end end)
        nps = nps:slice(1, 10)
        table.sort(nps, function (a, b) return a.age < b.age  end)
        
        for i, v in ipairs(ps) do
          assert_equal(v:equal(nps[i]), true)
        end
      
      
      end)
      
      
      
    
		end)
    
    context("Query Logic API", function ()
      local persons = Person:all()
      local cnt = 0
      
      test("test eq", function ()
        local n = Person:count({name=eq('Bill比尔')})
        persons:each(function (u) if u.name == 'Bill比尔' then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      test("test uneq", function ()
        cnt = 0
        local n = Person:count({name=uneq('Bill比尔')})
        persons:each(function (u) if u.name ~= 'Bill比尔' then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test lt
      test("test lt", function ()
        cnt = 0
        local n = Person:count({age=lt(50)})
        persons:each(function (u) if u.age < 50 then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test gt
      test("test gt", function ()
        cnt = 0
        local n = Person:count({age=gt(50)})
        persons:each(function (u) if u.age > 50 then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test lte
      test("test lte", function ()
        cnt = 0
        local n = Person:count({age=lte(50)})
        persons:each(function (u) if u.age <= 50 then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test gte
      test("test gte", function ()
        cnt = 0
        local n = Person:count({age=gte(50)})
        persons:each(function (u) if u.age >= 50 then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test bt
      test("test bt", function ()
        cnt = 0
        local n = Person:count({age=bt(30, 80)})
        persons:each(function (u) if u.age > 30 and u.age < 80 then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test bte
      test("test bte", function ()
        cnt = 0
        local n = Person:count({age=bte(30, 80)})
        persons:each(function (u) if u.age >= 30 and u.age <= 80 then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test outside
      test("test outside", function ()
        cnt = 0
        local n = Person:count({age=outside(30, 80)})
        persons:each(function (u) if u.age < 30 or u.age > 80 then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test contains
      test("test contains", function ()
        cnt = 0
        local n = Person:count({name=contains('Albert')})
        persons:each(function (u) if u.name:contains('Albert') then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test uncontains
      test("test uncontains", function ()
        cnt = 0
        local n = Person:count({name=uncontains('Albert')})
        persons:each(function (u) if not u.name:contains('Albert') then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test startsWith
      test("test startsWith", function ()
        cnt = 0
        local n = Person:count({name=startsWith('Albert')})
        persons:each(function (u) if u.name:startsWith('Albert') then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test unstartsWith
      test("test unstartsWith", function ()
        cnt = 0
        local n = Person:count({name=unstartsWith('Albert')})
        persons:each(function (u) if not u.name:startsWith('Albert') then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test endsWith
      test("test endsWith", function ()
        cnt = 0
        local n = Person:count({name=endsWith('艾伯特')})
        persons:each(function (u) if u.name:endsWith('艾伯特') then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test unendsWith
      test("test unendsWith", function ()
        cnt = 0
        local n = Person:count({name=unendsWith('艾伯特')})
        persons:each(function (u) if not u.name:endsWith('艾伯特') then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test inset
      test("test inset", function ()
        cnt = 0
        local set = {}
        for i=1, ITEMS, 2 do table.insert(set, i) end
        local n = Person:count({age=inset(set)})
        
        local hashset = {}
        for i, v in ipairs(set) do hashset[v] = true  end
        persons:each(function (u) if hashset[u.age] then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      -- test uninset
      test("test uninset", function ()
        cnt = 0
        local set = {}
        for i=1, ITEMS, 2 do table.insert(set, i) end
        local n = Person:count({age=uninset(set)})
        
        local hashset = {}
        for i, v in ipairs(set) do hashset[v] = true  end
        persons:each(function (u) if not hashset[u.age] then cnt = cnt + 1 end end)
        assert_equal(n == cnt, true)
      end)
      
      
      
		end)
		
    
    context("Foreign API", function ()
		
		end)
		
		context("Custom API", function ()
		
		end)
		
		context("Cache API", function ()
		
		end)
		
	end)
	
	context("Views - view.lua", function ()
			
	end)
	
	context("Utils - util.lua", function ()
			
	end)
	
	

end)
