local E = Brazier.Equals
local T = Brazier.Type

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

local normalTable  = { a = 1, b = "apples" }
local nestedTable  = { a = normalTable, z = emptyTable, g = { apples = "grapes" } }
local tableValues  = { emptyTable, normalTable, nestedTable }

local noopFunction     = function() end
local identityFunction = function(x) return x end
local doublerFunction  = function(x) return x * 2 end
local splatFunction    = function(...) return ... end
local functionValues   = { noopFunction, identityFunction, doublerFunction, splatFunction }

local allBundles = { crapValues, booleanValues, numberValues, stringValues, arrayValues, tableValues, functionValues }

local allValues = {}
for _, bundle in ipairs(allBundles) do
  for _, item in ipairs(bundle) do
    table.insert(allValues, item)
  end
end

-- END DATA

local function forAll(f)
  return function(xs)
    for _, x in ipairs(xs) do
      if not f(x) then
        return false
      end
    end
    return true
  end
end

local function forNone(f)
  return function(xs)
    for _, x in ipairs(xs) do
      if f(x) then
        return false
      end
    end
    return true
  end
end

local function contains(x)
  return function(arr)
    for _, item in ipairs(arr) do
      if E.eq(x)(item) then
        return true
      end
    end
    return false
  end
end

local function without(undesirables)
  return function(xs)
    local out = {}
    for _, x in ipairs(xs) do
      if not contains(x)(undesirables) then
        table.insert(out, x)
      end
    end
    return out
  end
end

local function test(goods)
  return function(f)
    return function(n)
      local bads = without(goods)(allValues)
      Pooey = function()
        for _, x in ipairs(bads) do
          print(tostring(x) .. " | " .. tostring(f(x)))
        end
      end
      TestSuite.assert("Typechecking")("Whatever - All" )(n)(forAll (f)(goods) == true)
      TestSuite.assert("Typechecking")("Whatever - None")(n)(forNone(f)( bads) == true)
    end
  end
end

local ps =
  { { arrayValues,    T.isArray    }
  , { booleanValues,  T.isBoolean  }
  , { functionValues, T.isFunction }
  , { numberValues,   T.isNumber   }
  , { tableValues,    T.isTable    }
  , { stringValues,   T.isString   }
  }

function TestSuite.testType()
  local n = 1
  for _, p in ipairs(ps) do
    test(p[1])(p[2])(n)
    n = n + 1
  end
  print("testType complete")
end
