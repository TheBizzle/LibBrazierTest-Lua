local M = Brazier.Maybe
local T = Brazier.Table

function TestSuite.testTable()

  local equal = TestSuite.equal("Table")

  local n = 1
  local function testClone(x)
    equal("clone")(n)(T.clone(x), x)
    n = n + 1
  end

  testClone({})
  testClone({ a = nil })
  testClone({ a = 3 })
  testClone({ a = "abc", z = 123, d = {}, b = false })

  n = 1
  local function testKeys(x, y)
    equal("keys")(n)(T.keys(x), y)
    n = n + 1
  end

  testKeys({},                                        {})
  testKeys({ a = nil },                         {})
  testKeys({ a = 3 },                                 { "a" })
  testKeys({ a = "abc", z = 123, d = {}, b = false }, { "a", "d", "b", "z" })

  n = 1
  local function testLookup(key, obj, y)
    equal("lookup")(n)(T.lookup(key)(obj), y)
    n = n + 1
  end

  testLookup('anything', {},                                        M.None)
  testLookup('a',        { a = nil },                               M.None)
  testLookup('other',    { a = nil },                               M.None)
  testLookup('marvin',   { marvin = 3 },                            M.Something(3))
  testLookup('a',        { a = "abc", z = 123, d = {}, b = false }, M.Something("abc"))
  testLookup('b',        { a = "abc", z = 123, d = {}, b = false }, M.Something(false))
  testLookup('z',        { a = "abc", z = 123, d = {}, b = false }, M.Something(123))
  testLookup('d',        { a = "abc", z = 123, d = {}, b = false }, M.Something({}))
  testLookup('g',        { a = "abc", z = 123, d = {}, b = false }, M.None)

  n = 1
  local function testPairs(x, y)
    equal("pairs")(n)(T.pairs(x), y)
    n = n + 1
  end

  testPairs({},                                        {})
  testPairs({ a = nil },                         {})
  testPairs({ a = 3 },                                 { { "a", 3 } })
  testPairs({ a = "abc", z = 123, d = {}, b = false }, { { "a", "abc" }, { "d", {} }, { "b", false }, { "z", 123 } })

  n = 1
  local function testValues(x, y)
    equal("values")(n)(T.values(x), y)
    n = n + 1
  end

  testValues({},                                        {})
  testValues({ a = nil },                               {})
  testValues({ a = 3 },                                 { 3 })
  testValues({ a = "abc", z = 123, d = {}, b = false }, { "abc", {}, false, 123 })

  print("testTable complete")

end
