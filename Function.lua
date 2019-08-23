local A = Brazier.Array
local E = Brazier.Equals
local F = Brazier.Function

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

local exploder = function(x) error("This code should not get run.") end

function TestSuite.testFunction()

  local ps =
    { { E.arrayEquals,   arrayValues   }
    , { E.booleanEquals, booleanValues }
    , { E.numberEquals,  numberValues  }
    , { E.tableEquals,   tableValues   }
    , { E.stringEquals,  stringValues  }
    }

  local n = 1
  for _, x in ipairs(ps) do
    for _, v in ipairs(x[2]) do
      TestSuite.assert("Function")("apply")(n)(F.apply(x[1](v))(v))
      n = n + 1
    end
  end

  TestSuite.equal("Function")("apply - Map")(1)(
                   A.map(F.apply(function(x) return x * 3 end))(
                     { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
                 , { 3, 6, 9, 12, 15, 18, 21, 24, 27, 30 })

  TestSuite.equal("Function")("apply - Map")(2)(
                   A.map(F.flip(F.apply)(21))(
                     { (function()  return       4 end)
                     , (function(x) return "" .. x end)
                     , (function(x) return   x / 7 end)
                     })
                 , { 4, "21", 3 })

  local bundles = { booleanValues, numberValues, tableValues, stringValues }

  n = 1
  for _, bundle in ipairs(allBundles) do
    for _, item in ipairs(bundle) do
      TestSuite.equal("Function")("constantly")(n)(F.constantly(item)(), item)
      n = n + 1
    end
  end

  local add      = function(x) return function(y) return        x + y end end -- Commutative
  local subtract = function(x) return function(y) return        x - y end end -- Not commutative
  local concat   = function(x) return function(y) return "" .. x .. y end end -- Not commutative

  TestSuite.equal("Function")("flip")(1)(F.flip(     add)(1)(5),      add(1)(5))
  TestSuite.equal("Function")("flip")(2)(F.flip(subtract)(1)(5), subtract(5)(1))

  TestSuite.equal("Function")("flip")(3)(F.flip(concat)("apples")("oranges"), concat("oranges")("apples"))

  local ps2 =
    { { E.arrayEquals,   arrayValues   }
    , { E.booleanEquals, booleanValues }
    , { E.numberEquals,  numberValues  }
    , { E.tableEquals,   tableValues   }
    , { E.stringEquals,  stringValues  }
    }

  n = 1
  for _, p in ipairs(ps2) do
    for _, v in ipairs(p[2]) do
      TestSuite.assert("Function")("id")(n)(p[1](v)(F.id(v)))
      n = n + 1
    end
  end

  local function plusOne (x) return       x + 1 end
  local function double  (x) return       x * 2 end
  local function toString(x) return tostring(x) end

  TestSuite.equal("Function")("pipeline")(1)(F.pipeline(toString)("appleseed"), "appleseed")
  TestSuite.equal("Function")("pipeline")(2)(F.pipeline(toString, toString, toString, toString, toString)("apples"), "apples")
  TestSuite.equal("Function")("pipeline")(3)(F.pipeline(double)(1), 2)
  TestSuite.equal("Function")("pipeline")(4)(F.pipeline(double, double, double, double, double, double)(1), 64)
  TestSuite.equal("Function")("pipeline")(5)(F.pipeline(double, plusOne, double)(1), 6)
  TestSuite.equal("Function")("pipeline")(6)(F.pipeline(double, plusOne, double, toString)(1), "6")

  TestSuite.equal("Function")("tee")(1)(F.tee(function()  return                3 end)(function()  return                 4 end)("pooey"), { 3, 4 })
  TestSuite.equal("Function")("tee")(2)(F.tee(function(x) return    string.len(x) end)(function(x) return          x .. "!" end)("pooey"), { 5, "pooey!" })
  TestSuite.equal("Function")("tee")(3)(F.tee(function(x) return x .. " so gooey" end)(function(x) return string.len(x) * 6 end)("pooey"), { "pooey so gooey", 30 })

  print("testFunction complete")

end
