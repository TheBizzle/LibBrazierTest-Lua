local E = Brazier.Equals
local F = Brazier.Function
local M = Brazier.Maybe
local T = Brazier.Table

local function exploder(x)
  error("This code should not get run.")
end

-- BEGIN DATA

local crapValues = { nil }

local booleanValues = { true, false }

local negativeInfinity = -math.huge
local minNumber        = math.mininteger
local negativeNumber   = -10
local zeroNumber       = 0
local positiveNumber   = 9001
local maxNumber        = math.maxinteger
local infinity         = math.huge
local numberValues     = { negativeInfinity, minNumber, negativeNumber, zeroNumber, positiveNumber, maxNumber, infinity }

local emptyString     = ""
local singletonString = "x"
local normalString    = "lorem ipsum magico crapjico"
local stringValues    = { emptyString, singletonString, normalString }

local singletonArray = { 1 }
local numberArray    = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
local unorderedArray = { 1, 9, 2, 5, 3, 8, 17, 209, 32, 1, 3 }
local mixedArray     = { true, 19, "apples", "oranges", {}, false, {}, { 1, 2, 3 }, { a = 10 }, "grapes", -10 }
local arrayValues    = { singletonArray, numberArray, unorderedArray, mixedArray }

local emptyTable   = {}
local normalTable  = { a = 1, b = "apples" }
local nestedTable  = { a = normalTable, z = emptyTable, g = { apples = "grapes" } }
local tableValues  = { emptyTable, normalTable, nestedTable }

local noopFunction     = function() end
local identityFunction = function(x) return x end
local doublerFunction  = function(x) return x * 2 end
local splatFunction    = function(...) return ... end
local functionValues   = { noopFunction, identityFunction, doublerFunction, splatFunction }

local allBundles = { crapValues, booleanValues, numberValues, stringValues, arrayValues, tableValues, functionValues }

-- END DATA

function TestSuite.testMaybe()

  local n = 1
  local function testFilter(maybe, f, expected)
    TestSuite.equal("Maybe")("filter")(n)(M.filter(f)(maybe), expected)
    n = n + 1
  end

  testFilter(M.None, (function(x) error("BOOM!  HAHAHA!") end), M.None)
  testFilter(M.None, (function(x)            return  true end), M.None)
  testFilter(M.None, (function(x)            return false end), M.None)

  testFilter(M.Something("apples"), (function(x) return  true end), M.Something("apples"))
  testFilter(M.Something("apples"), (function(x) return false end), M.None)

  testFilter(M.Something(3), (function(x) return  true end), M.Something(3))
  testFilter(M.Something(3), (function(x) return false end), M.None)

  testFilter(M.Something(true), (function(x) return  true end), M.Something(true))
  testFilter(M.Something(true), (function(x) return false end), M.None)

  testFilter(M.Something({}), (function(x) return  true end), M.Something({}))
  testFilter(M.Something({}), (function(x) return false end), M.None)

  testFilter(M.Something("apples"), (function(x) return string.len(x) == 3 end), M.None)
  testFilter(M.Something("apples"), (function(x) return string.len(x) == 6 end), M.Something("apples"))
  testFilter(M.Something("apples"), (function(x) return     x ==  "apples" end), M.Something("apples"))
  testFilter(M.Something("apples"), (function(x) return     x == "oranges" end), M.None)
  testFilter(M.Something("apples"), (function(x) return string.sub(x, 4, 4) == "l" end), M.Something("apples"))
  testFilter(M.Something("apples"), (function(x) return string.sub(x, 4, 4) == "p" end), M.None)

  n = 1
  local function testFlatMap(maybe, f, expected)
    TestSuite.equal("Maybe")("flatMap")(n)(M.flatMap(f)(maybe), expected)
    n = n + 1
  end

  testFlatMap(M.None, exploder, M.None)

  testFlatMap(M.Something(0), (function(x) return M.None end), M.None)

  testFlatMap(M.Something(0), (function(x) if (x % 2) == 0 then return M.Something("me") else return M.None end end), M.Something("me"))
  testFlatMap(M.Something(1), (function(x) if (x % 2) == 0 then return M.Something("me") else return M.None end end),            M.None)

  testFlatMap(M.Something(M.Something("apples")), (function(x) return x end), M.Something("apples"))

  testFlatMap(M.Something( "apples"), (function(x) if string.len(x) ~= 7 then return M.Something(x) else return M.None end end), M.Something("apples"))
  testFlatMap(M.Something( "grapes"), (function(x) if string.len(x) ~= 7 then return M.Something(x) else return M.None end end), M.Something("grapes"))
  testFlatMap(M.Something("oranges"), (function(x) if string.len(x) ~= 7 then return M.Something(x) else return M.None end end),                M.None)
  testFlatMap(M.Something("bananas"), (function(x) if string.len(x) ~= 7 then return M.Something(x) else return M.None end end),                M.None)

  -- Monad law tests below

  local point        = M.Something
  local f            = function(x) return point(x .. "!") end
  local g            = function(x) return point(x .. "?") end
  local h            = function(x) return point(x .. "~") end
  local shortCircuit = function(x) return M.None end

  local item    = "apples"
  local wrapped = M.Something(item)

  -- Kleisli Arrow / Kleisli composition operator
  local function kleisli(f1)
    return function(f2)
      return function(x)
        return M.flatMap(f2)(f1(x))
      end
    end
  end

  local fgh1 = kleisli(kleisli(f)(g))(h)
  local fgh2 = kleisli(f)(kleisli(g)(h))

  local sgh = kleisli(shortCircuit)(kleisli(g)(h))
  local fsh = kleisli(f)(kleisli(shortCircuit)(h))
  local fgs = kleisli(f)(kleisli(g)(shortCircuit))

  testFlatMap(point(item), f,     f(item)) -- Left identity
  testFlatMap(wrapped,     point, wrapped) -- Right identity
  TestSuite.equal("Maybe")("flatMap - Associativity")(1)(M.flatMap(fgh1)(wrapped), M.flatMap(fgh2)(wrapped)) -- Associativity

  TestSuite.equal("Maybe")("flatMap - Associativity")(2)(M.flatMap(sgh)(wrapped), M.None) -- Associative short circuiting #1
  TestSuite.equal("Maybe")("flatMap - Associativity")(3)(M.flatMap(fsh)(wrapped), M.None) -- Associative short circuiting #2
  TestSuite.equal("Maybe")("flatMap - Associativity")(4)(M.flatMap(fgs)(wrapped), M.None) -- Associative short circuiting #3

  -- No more monads

  n = 1
  local function testFold(maybe, f, g, expected)
    TestSuite.equal("Maybe")("fold")(n)(M.fold(f)(g)(maybe), expected)
    n = n + 1
  end

  testFold(M.None, (function() return        3 end),                           exploder,        3)
  testFold(M.None, (function() return "apples" end),                           exploder, "apples")
  testFold(M.None, (function() return "apples" end), (function(x) return "oranges" end), "apples")

  testFold(M.Something(9001), (function() return    -1 end), (function(x) return x / 10 end), 9001 / 10)
  testFold(M.Something( -11), (function() return    -1 end), (function(x) return x / 10 end),  -11 / 10)
  testFold(M.Something(   0), (function() return false end), (function(x) return x == 0 end),      true)

  testFold(M.Something( true), (function() return false end), (function(x) return     x end),  true)
  testFold(M.Something( true), (function() return false end), (function(x) return not x end), false)
  testFold(M.Something(false), (function() return false end), (function(x) return not x end),  true)

  testFold(M.Something( "apples"), (function() return 0 end), (function(x) return string.len(x) end), 6)
  testFold(M.Something("bananas"), (function() return 0 end), (function(x) return string.len(x) end), 7)

  testFold(M.Something(                               {}), (function() return -1 end), (function(x) return getn(x) end), 0)
  testFold(M.Something({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }), (function() return -9 end), (function(x) return    x[3] end), 3)

  testFold(M.Something({                    }), (function() return { "none" } end), (function(x) return       T.keys(x) end), {})
  testFold(M.Something({ daysThisMonth = 28 }), (function() return         30 end), (function(x) return x.daysThisMonth end), 28)

  n = 1
  local function testIsSomething(maybe, expected)
    TestSuite.equal("Maybe")("isSomething")(n)(M.isSomething(maybe), expected)
    n = n + 1
  end

  testIsSomething(M.None, false)

  testIsSomething(M.Something(   3),  true)
  testIsSomething(M.Something(true),  true)
  testIsSomething(M.Something(  {}),  true)

  testIsSomething(   3, false)
  testIsSomething(true, false)
  testIsSomething(  {}, false)

  n = 1
  local function testMap(maybe, f, expected)
    TestSuite.equal("Maybe")("map")(n)(M.map(f)(maybe), expected)
    n = n + 1
  end

  testMap(M.None,                             exploder, M.None)
  testMap(M.None, (function(x) return tostring(x) end), M.None)
  testMap(M.None, (function()  return        9001 end), M.None)

  testMap(M.Something(true), (function() return 9001 end), M.Something(9001))
  testMap(M.Something(   3), (function() return 9001 end), M.Something(9001))

  testMap(M.Something(    7), (function(x) return x + 1 end), M.Something(    8))
  testMap(M.Something(-3001), (function(x) return x + 1 end), M.Something(-3000))
  testMap(M.Something(    7), (function(x) return x * 2 end), M.Something(   14))
  testMap(M.Something(-3001), (function(x) return x * 2 end), M.Something(-6002))

  testMap(M.Something( true), (function(x) return x end), M.Something( true))
  testMap(M.Something(false), (function(x) return x end), M.Something(false))

  testMap(M.Something("oranges"), (function(x) return string.len(x) end), M.Something( 7 ))
  testMap(M.Something(  "merpy"), (function(x) return string.len(x) end), M.Something( 5 ))
  testMap(M.Something( "gurpy!"), (function(x) return string.len(x) end), M.Something( 6 ))
  testMap(M.Something("oranges"), (function(x) return string.sub(x, 1, 1) end), M.Something("o"))
  testMap(M.Something(  "merpy"), (function(x) return string.sub(x, 1, 1) end), M.Something("m"))
  testMap(M.Something( "gurpy!"), (function(x) return string.sub(x, 1, 1) end), M.Something("g"))

  testMap(M.Something({ 13, 14, 15, 16, 17, 18, 19 }), (function(x) return x ~=   nil end),         M.Something( true))
  testMap(M.Something({ 13, 14, 15, 16, 17, 18, 19 }), (function(x) return x ==   nil end),         M.Something(false))
  testMap(M.Something({ 13, 14, 15, 16, 17, 18, 19 }), (function(x) return x == false end),         M.Something(false))
  testMap(M.Something({ 13, 14, 15, 16, 17, 18, 19 }), (function(x) return getn(x) > 3 end),        M.Something( true))
  testMap(M.Something({ 13, 14, 15, 16, 17, 18, 19 }), (function(x) return type(x) == 'table' end), M.Something( true))

  testMap(M.Something(nil), (function(x) return x ~=   nil end),         M.Something(false))
  testMap(M.Something(nil), (function(x) return x ==   nil end),         M.Something( true))
  testMap(M.Something(nil), (function(x) return x == false end),         M.Something(false))
  testMap(M.Something(nil), (function(x) return getn({}) > 3 end),       M.Something(false))

  testMap(M.Something({ apples = 3 }), (function(x) return x ~= nil end),           M.Something( true))
  testMap(M.Something({ apples = 3 }), (function(x) return x == nil end),           M.Something(false))
  testMap(M.Something({ apples = 3 }), (function(x) return x == false end),         M.Something(false))
  testMap(M.Something({ apples = 3 }), (function(x) return getn({}) > 3 end),       M.Something(false))
  testMap(M.Something({ apples = 3 }), (function(x) return type(x) == 'table' end), M.Something( true))

  -- Functor laws!

  local f     = function(x) return x .. "!" end
  local g     = function(x) return x .. "?" end
  local id    = function(x) return        x end
  local maybe = M.Something("bananas")

  local mapTwice    = F.pipeline(M.map(f), M.map(g))
  local mapComposed = M.map(F.pipeline(f, g))

  testMap(maybe, id, maybe)                                                               -- Identity
  TestSuite.equal("Maybe")("map - Associativity")(1)(mapTwice(maybe), mapComposed(maybe)) -- Associativity

  -- No more functors

  n = 1
  local bundlyBoys = { arrayValues, booleanValues, numberValues, tableValues, stringValues }
  for _, bundle in ipairs(bundlyBoys) do
    for _, item in ipairs(bundle) do

      local res
      if value ~= nil then
        res = value
      else
        res = "loser"
      end

      TestSuite.equal("Maybe")("maybe")(n)(
        M.fold(function() return "loser" end)(function(x) return x end)(M.maybe(value))
      , res
      )

      n = n + 1

    end
  end

  local ps =
    { { E.arrayEquals,   arrayValues   }
    , { E.booleanEquals, booleanValues }
    , { E.numberEquals,  numberValues  }
    , { E.tableEquals,   tableValues   }
    , { E.stringEquals,  stringValues  }
    }

  TestSuite.equal("Maybe")("toArray")(1)(M.toArray(M.None), {})

  n = 2
  for _, x in ipairs(ps) do
    for _, v in ipairs(x[2]) do
      local result = M.toArray(M.Something(v))
      TestSuite.assert("Maybe")("toArray")(n    )(getn(result) == 1)
      TestSuite.assert("Maybe")("toArray")(n + 1)(x[1](v)(result[1]))
      n = n + 2
    end
  end

  print("testMaybe complete")

end
