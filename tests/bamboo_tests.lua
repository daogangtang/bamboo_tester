local testing = require "bamboo.testing"
local socket = require 'socket'

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
  local Comment = bamboo.getModelByName('Comment')
  -- clean the test target collection
  fptable(Person.__db)
  print(Person.__collection)
  Person.__db:drop(Person.__collection)
  Comment.__db:drop(Comment.__collection)
  print('Finish clear db.') 

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
	print('----> id, ', id)
        local newobj = Person:getById(id)
        -- fptable( newobj ) 
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
	assert_equal(type(p) == 'table', true)
        local flag = false
        persons:each(function (u) if u.name:contains('Albert') then local ret = u:equal(p); if ret then flag = true ; return false end; end end)
	--fptable(p)
        assert_equal(flag, true)
        
        -- test mongo style query args: $query
        local p = Person:get({
          ['$query'] = {
            age = {
              ['$gte'] = 20,
              ['$lt'] = 80
            }
          }
        })
	assert_equal(type(p) == 'table', true)
        local flag = false
        persons:each(function (u) local ret = u:equal(p); if ret then flag = true ; return false end; end)
	assert_equal(flag, true)
        
        -- test mongo style query args: $regex
        local p = Person:get({
          ['$query'] = {
            name = {['$regex'] = 'Albert'}
          }
        })
	assert_equal(type(p) == 'table', true)
        local flag = false
        persons:each(function (u) local ret = u:equal(p); if ret then flag = true ; return false end; end)
	assert_equal(flag, true)
        
        
        -- test fields
        local p = Person:get({
          ['$query'] = {
            name = {['$regex'] = 'Albert' }
          }
        }, {name=true})
	assert_equal(type(p) == 'table', true)
        local flag = false
        persons:each(function (u) local ret; if u.name == p.name and u.id == p.id then ret = true end;  if ret then flag = true ; return false end; end)
	assert_equal(flag, true)
        
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
            name = {['$regex'] = 'Albert'}
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
            name={['$regex'] = '^A'}
          },
          ['$orderby'] = {age=1}
        })
        assert_equal(type(ps) == 'table', true)
        local nps = {}
        persons:each(function (u) if u.name:startsWith('A') then table.insert(nps, u) end end)
        table.sort(nps, function (a, b) return a.age < b.age  end)

        for i, v in ipairs(ps) do
          assert_equal(v.age == nps[i].age, true)
        end
      
        -- test number to return 
        local ps = Person:filter({
          ['$query'] = {
            name = {['$regex'] = '^A'}
          },
          ['$orderby'] = {age=1}
        }, nil, nil, 10)
        assert_equal(type(ps) == 'table', true)
	print('#ps', #ps)
        assert_equal(#ps == 10, true)

        local nps = List()
        persons:each(function (u) if u.name:startsWith('A') then table.insert(nps, u) end end)
        table.sort(nps, function (a, b) return a.age < b.age  end)
        nps = nps:slice(1, 10)
        -- fptable(ps)
        -- fptable(nps)
        for i, v in ipairs(ps) do
          assert_equal(v.age == nps[i].age, true)
        end
      
      
      end)
      
            
      test("test save, update, del", function ()
        local p = Person {
          name = 'TGG',
          age = 28,
          home = 'SiChuan'
        }
        p:save()
        assert_equal( Person:numbers() == ITEMS + 1, true)
        local nn = Person:getByIndex(ITEMS+1)
        -- check id assignment after insert doc
        assert_equal(p.id == nn.id, true)
        
        
        local p = Person {
          name = 'TGG2',
          age = 29,
          home = 'SiChuanChuan'
        }
        p:save()
        assert_equal( Person:numbers() == ITEMS + 2, true)
        
        local p = Person:getByIndex(ITEMS+2)
        assert_equal(type(p) == 'table', true)
        
        -- test new params when save
        p:save({
          name = 'TGG3',
          age = 30,
          home = 'SiChuan2'
        })
        local p = Person:getByIndex(ITEMS+2)
        assert_equal(type(p) == 'table', true)
        assert_equal(p.name == 'TGG3', true)
        assert_equal(p.age == 30, true)
        assert_equal(p.home == 'SiChuan2', true)
        
        -- test update
        local p = Person:getByIndex(ITEMS+2)
        assert_equal(type(p) == 'table', true)
        p:update('name', 'TGG4')
        p:update('age', 32)
        p:update('home', 'SiChuan3')
        local p2 = Person:getByIndex(ITEMS+2)
        assert_equal(type(p2) == 'table', true)
        assert_equal(p2.name == 'TGG4', true)
        assert_equal(p2.age == 32, true)
        assert_equal(p2.home == 'SiChuan3', true)
        -- check in memory attribute update
        assert_equal(p.name == 'TGG4', true)
        assert_equal(p.age == 32, true)
        assert_equal(p.home == 'SiChuan3', true)
        
        -- test del
        local p = Person:getByIndex(ITEMS+2)
        assert_equal(type(p) == 'table', true)
        p:del()
        assert_equal( Person:numbers() == ITEMS + 1, true)
        
        local p = Person:getByIndex(ITEMS+1)
        assert_equal(type(p) == 'table', true)
        p:del()
        assert_equal( Person:numbers() == ITEMS, true)
        
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
      
      -- test outside ;(
      test("test outside", function ()
        cnt = 0
        local n = Person:count({
		['$or'] = {
			{ age = {['$lt'] = 30} },
			{ age = {['$gt'] = 80} }
		}
	})
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
        local n = Person:count({
		['$where'] = "this.name.indexOf(".."'Albert'"..") < 0"
	})
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
        local n = Person:count({
		['$where'] = "this.name.indexOf(".."'Albert'"..") != 0"
	})
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
        local n = Person:count({
		['$where'] = "var p = this.name.lastIndexOf(".."'艾伯特'".."); return p < 0 || p+'艾伯特'.length != this.name.length"
			
	})
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
	print(n, cnt)
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
      
      test("test addForeign, getForeign", function ()
        -- add a new person
        local p = Person {
          name = 'TGG',
          age = 28,
          home = 'SiChuan'
        }
        p:save()
        assert_equal( Person:numbers() == ITEMS + 1, true)
        
        p = Person:getByIndex(ITEMS + 1)
        local fromp = Person:getByIndex(1)
        local comment = Comment {
          content = '你好棒哦',
          date = socket.gettime()
        }
        comment:save()
        comment:addForeign('from', fromp)
        
        local fromp2 = Person:getByIndex(2)
        local comment2 = Comment {
          content = '你好2.',
          date = socket.gettime()
        }
        comment2:save()
        comment2:addForeign('from', fromp2)
        
        local fromp3 = Person:getByIndex(3)
        local comment3 = Comment {
          content = '你好3.',
          date = socket.gettime()
        }
        comment3:save()
        comment3:addForeign('from', fromp3)
        
        local fromp4 = Person:getByIndex(4)
        local comment4 = Comment {
          content = '你好4.',
          date = socket.gettime()
        }
        comment4:save()
        comment4:addForeign('from', fromp4)
        
        -------------------------------------
        -- test NORMAL
        -------------------------------------
        local testForeignGroup = function (comment, n, m)
          p:addForeign('ff1', comment)  -- ONE
          local tp = p:getForeign('ff1')
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
	  print(comment.date, tp.date, type(comment.date), type(tp.date))
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ff2', comment)  -- MANY
          local tps = p:getForeign('ff2')
          assert_equal(#tps == n, true)
          local tp = tps[n]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ff3', comment)  -- LIST
          local tps = p:getForeign('ff3')
          assert_equal(#tps == n, true)
          local tp = tps[n]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ff4', comment) -- FIFO
          local tps = p:getForeign('ff4')
          assert_equal(#tps == m, true)
          local tp = tps[m]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ff5', comment) -- ZFIFO
          local tps = p:getForeign('ff5')
          assert_equal(#tps == m, true)
          local tp = tps[m]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
        
        
        end
        
        -- add comment
        testForeignGroup(comment, 1, 1)
        
        -- add comment2
        testForeignGroup(comment2, 2, 2)
        
        -- add comment3
        testForeignGroup(comment3, 3, 2)
        
        -- add comment4
        testForeignGroup(comment4, 4, 2)
                
        -------------------------------------
        -- test ANYOBJ
        -------------------------------------
        local testAnyobjForeignGroup = function (comment, n, m)
          p:addForeign('ffa', comment)  -- ONE
          local tp = p:getForeign('ffa')
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ffb', comment)  -- MANY
          local tps = p:getForeign('ffb')
          assert_equal(#tps == n, true)
          local tp = tps[n]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ffc', comment)  -- LIST
          local tps = p:getForeign('ffc')
          assert_equal(#tps == n, true)
          local tp = tps[n]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ffd', comment) -- FIFO
          local tps = p:getForeign('ffd')
	  print('--->', #tps, m)
          assert_equal(#tps == m, true)
          local tp = tps[m]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
          p:addForeign('ffe', comment) -- ZFIFO
          local tps = p:getForeign('ffe')
          assert_equal(#tps == m, true)
          local tp = tps[m]
          assert_equal( comment.id == tp.id, true)
          assert_equal( comment.content == tp.content, true)
          assert_equal( tostring(comment.date) == tostring(tp.date), true)
          
        end
        
        -- add comment
        testAnyobjForeignGroup(comment, 1, 1)
        
        -- add comment2
        testAnyobjForeignGroup(comment2, 2, 2)

        -- add comment3
        testAnyobjForeignGroup(comment3, 3, 2)

        -- add comment4
        testAnyobjForeignGroup(comment4, 4, 2)
      
      end)

      -- now p has some foreigns in its each foreign field
      test("test numForeign", function ()
        local p = Person:getByIndex(ITEMS + 1)

        assert_equal( p:numForeign('ff1') == 1, true)
        assert_equal( p:numForeign('ff2') == 4, true)
        assert_equal( p:numForeign('ff3') == 4, true)
        assert_equal( p:numForeign('ff4') == 2, true)
        assert_equal( p:numForeign('ff5') == 2, true)
        
        assert_equal( p:numForeign('ffa') == 1, true)
        assert_equal( p:numForeign('ffb') == 4, true)
        assert_equal( p:numForeign('ffc') == 4, true)
        assert_equal( p:numForeign('ffd') == 2, true)
        assert_equal( p:numForeign('ffe') == 2, true)
        
      end)
    
      -- now p has some foreigns in its each foreign field
      test("test hasForeignKey", function ()
        local p = Person:getByIndex(ITEMS + 1)

        assert_equal( p:hasForeignKey('ff1'), true)
        assert_equal( p:hasForeignKey('ff2'), true)
        assert_equal( p:hasForeignKey('ff3'), true)
        assert_equal( p:hasForeignKey('ff4'), true)
        assert_equal( p:hasForeignKey('ff5'), true)
        
        assert_equal( p:hasForeignKey('ff6'), false)
        assert_equal( p:hasForeignKey('name'), false)
        
        assert_equal( p:hasForeignKey('ffa'), true)
        assert_equal( p:hasForeignKey('ffb'), true)
        assert_equal( p:hasForeignKey('ffc'), true)
        assert_equal( p:hasForeignKey('ffd'), true)
        assert_equal( p:hasForeignKey('ffe'), true)
        
        assert_equal( p:hasForeignKey('fff'), false)
        assert_equal( p:hasForeignKey('age'), false)
        
      end)
      
      -- now p has some foreigns in its each foreign field
      test("test hasForeignMember", function ()
        local p = Person:getByIndex(ITEMS + 1)
	local comment = Comment:getByIndex(1)
	local comment2 = Comment:getByIndex(2)
	local comment3 = Comment:getByIndex(3)
	local comment4 = Comment:getByIndex(4)
	assert_equal( type(comment) == 'table', true)
	assert_equal( type(comment2) == 'table', true)
	assert_equal( type(comment3) == 'table', true)
	assert_equal( type(comment4) == 'table', true)


        assert_equal( p:hasForeignMember('ff1', comment4), true)
        assert_equal( p:hasForeignMember('ff1', comment2), false)
        
        assert_equal( p:hasForeignMember('ff2', comment4), true)
        assert_equal( p:hasForeignMember('ff2', comment3), true)
        assert_equal( p:hasForeignMember('ff2', comment2), true)
        assert_equal( p:hasForeignMember('ff2', comment), true)
        
        assert_equal( p:hasForeignMember('ff3', comment4), true)
        assert_equal( p:hasForeignMember('ff3', comment3), true)
        assert_equal( p:hasForeignMember('ff3', comment2), true)
        assert_equal( p:hasForeignMember('ff3', comment), true)
        
        assert_equal( p:hasForeignMember('ff4', comment4), true)
        assert_equal( p:hasForeignMember('ff4', comment3), true)
        assert_equal( p:hasForeignMember('ff4', comment2), false)
        assert_equal( p:hasForeignMember('ff4', comment), false)
        
        assert_equal( p:hasForeignMember('ff5', comment4), true)
        assert_equal( p:hasForeignMember('ff5', comment3), true)
        assert_equal( p:hasForeignMember('ff5', comment2), false)
        assert_equal( p:hasForeignMember('ff5', comment), false)
        
        assert_equal( p:hasForeignMember('ffa', comment4), true)
        assert_equal( p:hasForeignMember('ffa', comment), false)

        assert_equal( p:hasForeignMember('ffb', comment4), true)
        assert_equal( p:hasForeignMember('ffb', comment3), true)
        assert_equal( p:hasForeignMember('ffb', comment2), true)
        assert_equal( p:hasForeignMember('ffb', comment), true)
        
        assert_equal( p:hasForeignMember('ffc', comment4), true)
        assert_equal( p:hasForeignMember('ffc', comment3), true)
        assert_equal( p:hasForeignMember('ffc', comment2), true)
        assert_equal( p:hasForeignMember('ffc', comment), true)
        
        assert_equal( p:hasForeignMember('ffd', comment4), true)
        assert_equal( p:hasForeignMember('ffd', comment3), true)
        assert_equal( p:hasForeignMember('ffd', comment2), false)
        assert_equal( p:hasForeignMember('ffd', comment), false)

        assert_equal( p:hasForeignMember('ffe', comment4), true)
        assert_equal( p:hasForeignMember('ffe', comment3), true)
        assert_equal( p:hasForeignMember('ffe', comment2), false)
        assert_equal( p:hasForeignMember('ffe', comment), false)
        
      end)
    
      -- now p has some foreigns in its each foreign field
      test("test removeForeignMember", function ()
        local p = Person:getByIndex(ITEMS + 1)
	local comment = Comment:getByIndex(1)
	local comment2 = Comment:getByIndex(2)
	local comment3 = Comment:getByIndex(3)
	local comment4 = Comment:getByIndex(4)
	assert_equal( type(comment) == 'table', true)
	assert_equal( type(comment2) == 'table', true)
	assert_equal( type(comment3) == 'table', true)
	assert_equal( type(comment4) == 'table', true)


        p:removeForeignMember('ff1', comment4)
        local c = p:getForeign('ff1')
        assert_equal(c, nil)
        
        p:removeForeignMember('ff2', comment4)
        local cs = p:getForeign('ff2')
        assert_equal(#cs, 3)
        
        p:removeForeignMember('ff3', comment4)
        local cs = p:getForeign('ff3')
        assert_equal(#cs, 3)
        
        
        p:removeForeignMember('ff4', comment)
        local cs = p:getForeign('ff4')
        assert_equal(#cs, 2)
        p:removeForeignMember('ff4', comment4)
        local cs = p:getForeign('ff4')
        assert_equal(#cs, 1)
        
        p:removeForeignMember('ff5', comment)
        local cs = p:getForeign('ff5')
        assert_equal(#cs, 2)
        
        p:removeForeignMember('ff5', comment4)
        local cs = p:getForeign('ff5')
        assert_equal(#cs, 1)

        --------------------------------------
        -- test ANYOBJ
        p:removeForeignMember('ffa', comment4)
        local c = p:getForeign('ffa')
        assert_equal(c, nil)
        
        p:removeForeignMember('ffb', comment4)
        local cs = p:getForeign('ffb')
        assert_equal(#cs, 3)
        
        p:removeForeignMember('ffc', comment4)
        local cs = p:getForeign('ffc')
        assert_equal(#cs, 3)
        
        
        p:removeForeignMember('ffd', comment)
        local cs = p:getForeign('ffd')
        assert_equal(#cs, 2)
        p:removeForeignMember('ffd', comment4)
        local cs = p:getForeign('ffd')
        assert_equal(#cs, 1)
        
        p:removeForeignMember('ffe', comment)
        local cs = p:getForeign('ffe')
        assert_equal(#cs, 2)
        
        p:removeForeignMember('ffe', comment4)
        local cs = p:getForeign('ffe')
        assert_equal(#cs, 1)
        
        
      end)
    
      
      -- now p has some foreigns in its each foreign field
      test("test delForeign", function ()
        local p = Person:getByIndex(ITEMS + 1)
        p:delForeign('ffa')
        local c = p:getForeign('ffa')
        assert_equal(c, nil)
        
        p:delForeign('ffb')
        local cs = p:getForeign('ffb')
        assert_equal(#cs, 0)
        
        p:delForeign('ffc')
        local cs = p:getForeign('ffc')
        assert_equal(#cs, 0)
        
        p:delForeign('ffd')
        local cs = p:getForeign('ffd')
        assert_equal(#cs, 0)
        
        p:delForeign('ffe')
        local cs = p:getForeign('ffe')
        assert_equal(#cs, 0)
        
      end)
    
      -- now p has some foreigns in its each foreign field
      test("test deepDelForeign", function ()
        local p = Person:getByIndex(ITEMS + 1)
        
        local c3 = Comment:getByIndex(3)
        assert_equal(c3 ~= nil, true)
        local c4 = Comment:getByIndex(4)
        assert_equal(c4 ~= nil, true)
        
        p:deepDelForeign('ff4')
        local cs = p:getForeign('ff4')
        assert_equal(#cs, 0)
        
        local c3 = Comment:getById(c3.id)
        assert_equal(c3 == nil, true)
        
        local c1 = Comment:getByIndex(1)
        assert_equal(c1 ~= nil, true)
        local c2 = Comment:getByIndex(2)
        assert_equal(c2 ~= nil, true)
        
        p:deepDelForeign('ff2')
        local cs = p:getForeign('ff2')
        assert_equal(#cs, 0)
        
        local c1 = Comment:getById(c1.id)
        assert_equal(c1 == nil, true)
        local c2 = Comment:getById(c2.id)
        assert_equal(c2 == nil, true)
        
        
      end)

		
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
