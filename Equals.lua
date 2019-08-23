local E = Brazier.Equals

local function _testArray(suite, subSuite, equals)

  TestSuite.assert(suite)(subSuite)(1)(equals(         {})(         {}))
  TestSuite.assert(suite)(subSuite)(2)(equals(      { 1 })(      { 1 }))
  TestSuite.assert(suite)(subSuite)(3)(equals({ 1, 2, 3 })({ 1, 2, 3 }))
  TestSuite.assert(suite)(subSuite)(4)(equals({ 9001, 32, "apples", {}, { 3, 32 }, false })({ 9001, 32, "apples", {}, { 3, 32 }, false }))

  TestSuite.assert(suite)(subSuite)(5)(not equals(               {})(            { 1 }))
  TestSuite.assert(suite)(subSuite)(6)(not equals({ 1, 2, 3, 4, 5 })({ 1, 2, 3, 4    }))
  TestSuite.assert(suite)(subSuite)(7)(not equals({ 1, 2, 3, 4    })({ 1, 2, 3, 4, 5 }))

end

local function _testBoolean(suite, subSuite, equals)

  TestSuite.assert(suite)(subSuite)(1)(equals( true)( true))
  TestSuite.assert(suite)(subSuite)(2)(equals(false)(false))

  TestSuite.assert(suite)(subSuite)(3)(not equals( true)(false))
  TestSuite.assert(suite)(subSuite)(4)(not equals(false)( true))

end

local function _testFunction(suite, subSuite, equals)

  TestSuite.assert(suite)(subSuite)(1)(equals(  E.arrayEquals)(  E.arrayEquals))
  TestSuite.assert(suite)(subSuite)(2)(equals(E.booleanEquals)(E.booleanEquals))
  TestSuite.assert(suite)(subSuite)(3)(equals(           E.eq)(           E.eq))
  TestSuite.assert(suite)(subSuite)(4)(equals( E.numberEquals)( E.numberEquals))
  TestSuite.assert(suite)(subSuite)(5)(equals(  E.tableEquals)(  E.tableEquals))
  TestSuite.assert(suite)(subSuite)(6)(equals( E.stringEquals)( E.stringEquals))

end

local function _testNumber(suite, subSuite, equals)

  TestSuite.assert(suite)(subSuite)(1)(equals(        0)(        0))
  TestSuite.assert(suite)(subSuite)(2)(equals(       -1)(       -1))
  TestSuite.assert(suite)(subSuite)(3)(equals(     9001)(     9001))
  TestSuite.assert(suite)(subSuite)(4)(equals(math.huge)(math.huge))

  TestSuite.assert(suite)(subSuite)(5)(not equals(        0)(        -1))
  TestSuite.assert(suite)(subSuite)(6)(not equals(       -1)(         0))
  TestSuite.assert(suite)(subSuite)(7)(not equals(math.huge)(-math.huge))

end

local function _testTable(suite, subSuite, equals)

  TestSuite.assert(suite)(subSuite)(1)(equals({})({}))
  TestSuite.assert(suite)(subSuite)(2)(equals({ a = nil })({ a = nil }))
  TestSuite.assert(suite)(subSuite)(3)(equals({ a = 3 })({ a = 3 }))
  TestSuite.assert(suite)(subSuite)(4)(equals({ a = 3, b = {} })({ a = 3, b = {} }))
  TestSuite.assert(suite)(subSuite)(5)(equals({ a = 3, b = {}, d = { a = 4, b = "apples", z = false, g = "okay" } })({ a = 3, b = {}, d = { a = 4, b = "apples", z = false, g = "okay" } }))
  TestSuite.assert(suite)(subSuite)(6)(equals({})({ a = nil }))

  TestSuite.assert(suite)(subSuite)(7)(not equals(       {})(  { a = 3 }))
  TestSuite.assert(suite)(subSuite)(8)(not equals({ a = 3 })(         {}))

end

local function _testString(suite, subSuite, equals)

    TestSuite.assert(suite)(subSuite)(1)(equals(     "")(     ""))
    TestSuite.assert(suite)(subSuite)(2)(equals(    "1")(    "1"))
    TestSuite.assert(suite)(subSuite)(3)(equals("1..30")("1..30"))
    TestSuite.assert(suite)(subSuite)(4)(equals("9001, 32, 'apples', {}, [3, 32], false")("9001, 32, 'apples', {}, [3, 32], false"))

    TestSuite.assert(suite)(subSuite)(5)(not equals(     "")(    "1"))
    TestSuite.assert(suite)(subSuite)(6)(not equals("1..31")("1..30"))
    TestSuite.assert(suite)(subSuite)(7)(not equals("1..30")("1..31"))

end

function TestSuite.testEquals()

  _testArray   ("Equals", "Any - Array",    E.eq)
  _testBoolean ("Equals", "Any - Boolean",  E.eq)
  _testFunction("Equals", "Any - Function", E.eq)
  _testNumber  ("Equals", "Any - Number",   E.eq)
  _testTable   ("Equals", "Any - Table",    E.eq)
  _testString  ("Equals", "Any - String",   E.eq)

  _testArray   ("Equals", "Array",     E.arrayEquals)
  _testBoolean ("Equals", "Boolean", E.booleanEquals)
  _testFunction("Equals", "Function",           E.eq)
  _testNumber  ("Equals", "Number",   E.numberEquals)
  _testTable   ("Equals", "Table",     E.tableEquals)
  _testString  ("Equals", "String",   E.stringEquals)

  print("testEquals complete")

end
