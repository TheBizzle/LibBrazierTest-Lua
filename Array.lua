local A = Brazier.Array
local F = Brazier.Function
local M = Brazier.Maybe

local function exploder(x) error("This code should not get run.") end

-- Any => Number => Number?
local function bLengthD(x)
  return function(default)
    if type(x) == "string" then
      return string.len(x)
    elseif type(x) == "table" then
      if getn(x) == 0 then
        local out = 0
        for _ in pairs(x) do
          out = out + 1
        end
        return out
      else
        return getn(x)
      end
    else
      return default
    end
  end
end

Windie = bLengthD

-- Any => Number?
local function bLength(x)
  return bLengthD(x)(nil)
end

local function testArrayAll()

  local n = 1
  local function testGreaterThan10(input, expected)
    TestSuite.equal("Array")("all - gt10")(n)(A.all(function(x) return x > 10 end)(input), expected)
    n = n + 1
  end

  testGreaterThan10(            {}, true)
  testGreaterThan10({          1 }, false)
  testGreaterThan10({         11 }, true)
  testGreaterThan10({ 13, 14, 15 }, true)
  testGreaterThan10({ 10, 11, 12 }, false)

  local n = 1
  local function testAtLeast3Elems(input, expected)
    TestSuite.equal("Array")("all - 3+")(n)(A.all(function(x) return bLengthD(x)(0) >= 3 end)(input), expected)
    n = n + 1
  end

  testAtLeast3Elems({},                           true)
  testAtLeast3Elems({ 1 },                          false)
  testAtLeast3Elems({ { 13, 14, 15 } },                   true)
  testAtLeast3Elems({ { 13, 14, 15 }, { 10, 11, 12, 13, 14, 15 },  { 1, 2, 3 } }, true)
  testAtLeast3Elems({ { 13, 14, 15 }, { nil }, { 1, 2, 3 } }, false)
  testAtLeast3Elems({ "merp" },                     true)
  testAtLeast3Elems({ "merpy", "gurpy" },           true)
  testAtLeast3Elems({ "ep", "merpy", "gurpy" },     false)
  testAtLeast3Elems({ { 13, 14, 15 }, "dreq", { 1, 2, 3 } },   true)

  TestSuite.equal("Array")("all - General")(1)(A.all(exploder)({}), true)

end

local function testArrayConcat()

  local n = 1
  local function test(ys, xs, expected)
    TestSuite.equal("Array")("concat")(n)(A.concat(xs)(ys), expected)
    n = n + 1
  end

  test({ 1 },        {},                     { 1 })
  test({},           { 976 },                { 976 })
  test({ 5 },        { 1 },                  { 1, 5 })
  test({ { 3, 4, 5, 6 } }, { { 13, 14, 15, 16, 17, 18, 19 } },         { { 13, 14, 15, 16, 17, 18, 19 }, { 3, 4, 5, 6 } })
  test({ 17 },       { 13, 14, 15, 16, 17, 18, 19 },             { 13, 14, 15, 16, 17, 18, 19, 17 })
  test({ "merp" },   { "merpy", "gurpy" },   { "merpy", "gurpy", "merp" })
  test({ 9001 },     { "merpy", "gurpy" },   { "merpy", "gurpy", 9001 })
  test({ 3, 4, 5, 6 },     { 13, 14, 15, 16, 17, 18, 19 },             { 13, 14, 15, 16, 17, 18, 19, 3, 4, 5, 6 })

end

local function testArrayContains()

  local n = 1
  local function test(input, x, expected)
    TestSuite.equal("Array")("contains")(n)(A.contains(x)(input), expected)
    n = n + 1
  end

  test({},                         1,        false)
  test({ 1 },                        1,        true)
  test({ { 13, 14, 15, 16, 17, 18, 19 } },                 { 13, 14, 15, 16, 17, 18, 19 }, true)
  test({ 13, 14, 15, 16, 17, 18, 19 },                   17,       true)
  test({ "merpy", "gurpy" },         "merp",   false)
  test({ "merpy", "gurpy" },         "merpy",  true)
  test({ "merpy", "gurpy" },         "gurpy",  true)
  test({ { 13, 14, 15, 16, 17, 18, 19 }, "dreq", { 1, 2, 3 } }, "dreq",   true)

end

local function testArrayCountBy()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("countBy")(n)(A.countBy(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x == 0 end), { [false] = 10 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x == 1 end), { [true] = 1, [false] = 9 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return      x end), { [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, [7] = 1, [8] = 1, [9] = 1, [10] = 1 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return  x % 3 end), { [1] = 4, [2] = 3, [0] = 3 })

  test({ false, false, false }, (function(x) return    not x end), { [ true] = 3 })
  test({ false, false, false }, (function(x) return        x end), { [false] = 3 })
  test({ true,  true,  true  }, (function(x) return    not x end), { [false] = 3 })
  test({ true,  false, false }, (function(x) return        x end), { [ true] = 1, [false] = 2 })
  test({ true,  false, false }, (function(x) return    not x end), { [false] = 1, [ true] = 2 })
  test({ true,  false, false }, (function(x) return x == nil end), { [false] = 3 })

  test({ "merpy", "gurpy" }, (function(x) return string.len(x)      end), { [    5] = 2 })
  test({ "merpy", "gurpy" }, (function(x) return string.len(x) > 10 end), { [false] = 2 })
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "m" end), { [ true] = 1, [false] = 1 })
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "g" end), { [false] = 1, [ true] = 1 })
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "x" end), { [false] = 2 })

  test({}, (function() return  true end),  {})
  test({}, (function() return false end), {})
  test({}, exploder,   {})

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) return x ~= nil end),          { [ true] = 6 })
  test(megalist, (function(x) return x == nil end),          { [false] = 6 })
  test(megalist, (function(x) return not x end),             { [false] = 5, [ true] = 1 })
  test(megalist, (function(x) return bLength(x) ~= nil end), { [ true] = 4, [false] = 2 })
  test(megalist, (function(x) return type(x) end),           { table = 3, boolean = 1, number = 1, string = 1 })

end

local function testArrayDifference()

  local n = 1
  local function test(xs, ys, expected)
    TestSuite.equal("Array")("difference")(n)(A.difference(xs)(ys), expected)
    n = n + 1
  end

  test({},                               {},          {})
  test({ 1 },                            {},          { 1 })
  test({ 13, 14, 15, 16, 17, 18, 19 },                       {},          { 13, 14, 15, 16, 17, 18, 19 })
  test({ 13, 14, 15, 16, 17, 18, 19 },                       { 14, 15, 16, 17, 18, 19 },  { 13 })
  test({ 14, 15, 16, 17, 18, 19 },                       { 13, 14, 15, 16, 17, 18, 19 },  {})
  test({ 13, 14, 15, 16, 17, 18, 19 },                       { 17 },      { 13, 14, 15, 16, 18, 19 })
  test({ false, false, false },          { false },   {})
  test({ true, false, false },           { false },   { true })
  test({ "merpy", "gurpy" },             { "merp" },  { "merpy", "gurpy" })
  test({ "merpy", "gurpy" },             { "merpy" }, { "gurpy" })
  test({ { 13, 14, 15, 16, 17, 18, 19 }, "dreq", { 1, 2, 3 } }, { "dreq" },  { { 13, 14, 15, 16, 17, 18, 19 }, { 1, 2, 3 } })

end

local function testArrayExists()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("exists")(n)(A.exists(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    0      end), false)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    1      end), true)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    3      end), true)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   10      end), true)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   11      end), false)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  <    0      end), false)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  < 9001      end), true)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    2 == 0 end), true)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    6 == 0 end), true)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %   15 == 0 end), false)

  test({ false, false, false }, (function(x) return    not x end),  true)
  test({ false, false, false }, (function(x) return        x end),      false)
  test({ true,  true,  true  }, (function(x) return    not x end),  false)
  test({ true,  false, false }, (function(x) return        x end),      true)
  test({ true,  false, false }, (function(x) return    not x end),  true)
  test({ true,  false, false }, (function(x) return x == nil end), false)

  test({ "merpy", "gurpy" }, (function(x) return bLength(x) == 5 end), true)
  test({ "merpy", "gurpy" }, (function(x) return bLength(x) > 10 end), false)
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "m" end),   true)
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "g" end),   true)
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "x" end),   false)

  test({}, (function() return  true end), false)
  test({}, (function() return false end), false)
  test({}, exploder,   false)

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) return           x ~= nil end), true)
  test(megalist, (function(x) return           x == nil end), false)
  test(megalist, (function(x) return          x == true end), false)
  test(megalist, (function(x) return         x == false end), true)
  test(megalist, (function(x) return type(x) == 'table' and x[2] == 2 end), true)
  test(megalist, (function(x) return        x == "dreq" end), true)
  test(megalist, (function(x) return        x == "grek" end), false)
  test(megalist, (function(x) return type(x) == 'number' and x > 10 end), true)
  test(megalist, (function(x) return type(x) ~= 'table' end), true)
  test(megalist, (function(x) return    bLengthD(x)(0) > 10 end), false)
  test(megalist, (function(x) return    bLengthD(x)(0) == 4 end), true)
  test(megalist, (function(x) return    bLengthD(x)(0) >  4 end), true)
  test(megalist, (function(x) if type(x) == "table" then return x.apples ~= nil else return false end end),        true)
  test(megalist, (function(x) if type(x) == "table" then return x.apples ==   4 else return false end end),    false)

end

local function testArrayFilter()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("filter")(n)(A.filter(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    0      end), {})
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    1      end), { 1 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    3      end), { 3 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   10      end), { 10 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   11      end), {})
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  <    0      end), {})
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  < 9001      end), { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    2 == 0 end), { 2, 4, 6, 8, 10 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    6 == 0 end), { 6 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %   15 == 0 end), {})

  test({ false, false, false }, (function(x) return not x end),  { false, false, false })
  test({ false, false, false }, (function(x) return x end),      {})
  test({ true,  true,  true  }, (function(x) return not x end),  {})
  test({ true,  false, false }, (function(x) return x end),      { true })
  test({ true,  false, false }, (function(x) return not x end),  { false, false })
  test({ true,  false, false }, (function(x) return x == nil end), {})

  test({ "merpy", "gurpy" }, (function(x) return string.len(x) == 5 end), { "merpy", "gurpy" })
  test({ "merpy", "gurpy" }, (function(x) return string.len(x) > 10 end), {})
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "m" end),   { "merpy" })
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "g" end),   { "gurpy" })
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "x" end),   {})

  test({}, (function() return  true end),  {})
  test({}, (function() return false end), {})
  test({}, exploder,   {})

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) return           x ~= nil end), { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } })
  test(megalist, (function(x) return           x == nil end), {})
  test(megalist, (function(x) return          x == true end), {})
  test(megalist, (function(x) return         x == false end), { false })
  test(megalist, (function(x) return type(x) == 'table' and x[2] == 2 end), { { 1, 2, 3 } })
  test(megalist, (function(x) return        x == "dreq" end), { "dreq" })
  test(megalist, (function(x) return        x == "grek" end), {})
  test(megalist, (function(x) return type(x) == 'number' and x > 10 end), { 22 })
  test(megalist, (function(x) return    bLengthD(x)(0) > 10 end), {})
  test(megalist, (function(x) return    bLengthD(x)(0) == 4 end), { "dreq" })
  test(megalist, (function(x) return    bLengthD(x)(0) >  4 end), { { 13, 14, 15, 16, 17, 18, 19 } })
  test(megalist, (function(x) return type(x) ~= 'table' end), { false, 22, "dreq" })
  test(megalist, (function(x) if type(x) == "table" then return x.apples ~= nil else return false end end),        { { apples = 3 } })
  test(megalist, (function(x) if type(x) == "table" then return x.apples ==   4 else return false end end),    {})

end

local function testArrayFind()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("find")(n)(A.find(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    0      end), M.None)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    1      end), M.Something(1))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    3      end), M.Something(3))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   10      end), M.Something(10))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   11      end), M.None)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  <    0      end), M.None)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  < 9001      end), M.Something(1))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    2 == 0 end), M.Something(2))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    6 == 0 end), M.Something(6))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %   15 == 0 end), M.None)

  test({ false, false, false }, (function(x) return not x end),  M.Something(false))
  test({ false, false, false }, (function(x) return x end),      M.None)
  test({ true,  true,  true  }, (function(x) return not x end),  M.None)
  test({ true,  false, false }, (function(x) return x end),      M.Something(true))
  test({ true,  false, false }, (function(x) return not x end),  M.Something(false))
  test({ true,  false, false }, (function(x) return x == nil end), M.None)

  test({ "merpy", "gurpy" }, (function(x) return bLengthD(x)(0) == 5 end), M.Something("merpy"))
  test({ "merpy", "gurpy" }, (function(x) return bLengthD(x)(0) > 10 end), M.None)
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "m" end),   M.Something("merpy"))
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "g" end),   M.Something("gurpy"))
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "x" end),   M.None)

  test({}, (function() return  true end),  M.None)
  test({}, (function() return false end), M.None)
  test({}, exploder,   M.None)

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) return           x ~= nil end), M.Something({ 13, 14, 15, 16, 17, 18, 19 }))
  test(megalist, (function(x) return           x == nil end), M.None)
  test(megalist, (function(x) return          x == true end), M.None)
  test(megalist, (function(x) return         x == false end), M.Something(false))
  test(megalist, (function(x) return type(x) == 'table' and x[2] == 2 end), M.Something({ 1, 2, 3 }))
  test(megalist, (function(x) return        x == "dreq" end), M.Something("dreq"))
  test(megalist, (function(x) return        x == "grek" end), M.None)
  test(megalist, (function(x) return type(x) == 'number' and x > 10 end), M.Something(22))
  test(megalist, (function(x) return    bLengthD(x)(0) > 10 end), M.None)
  test(megalist, (function(x) return    bLengthD(x)(0) == 4 end), M.Something("dreq"))
  test(megalist, (function(x) return    bLengthD(x)(0) >  4 end), M.Something({ 13, 14, 15, 16, 17, 18, 19 }))
  test(megalist, (function(x) return type(x) ~= 'table' end), M.Something(false))
  test(megalist, (function(x) if type(x) == "table" then return x.apples ~= nil else return false end end),        M.Something({ apples = 3 }))
  test(megalist, (function(x) if type(x) == "table" then return x.apples ==   4 else return false end end),    M.None)

end

local function testArrayFindIndex()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("findIndex")(n)(A.findIndex(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    0      end), M.None)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    1      end), M.Something(1))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==    3      end), M.Something(3))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   10      end), M.Something(10))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x ==   11      end), M.None)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  <    0      end), M.None)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  < 9001      end), M.Something(1))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    2 == 0 end), M.Something(2))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %    6 == 0 end), M.Something(6))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x  %   15 == 0 end), M.None)

  test({ false, false, false }, (function(x) return    not x end),  M.Something(1))
  test({ false, false, false }, (function(x) return        x end),      M.None)
  test({ true,  true,  true  }, (function(x) return    not x end),  M.None)
  test({ true,  false, false }, (function(x) return        x end),      M.Something(1))
  test({ true,  false, false }, (function(x) return    not x end),  M.Something(2))
  test({ true,  false, false }, (function(x) return x == nil end), M.None)

  test({ "merpy", "gurpy" }, (function(x) return bLength(x) == 5 end), M.Something(1))
  test({ "merpy", "gurpy" }, (function(x) return bLength(x) > 10 end), M.None)
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "m" end), M.Something(1))
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "g" end), M.Something(2))
  test({ "merpy", "gurpy" }, (function(x) return string.sub(x, 1, 1) == "x" end), M.None)

  test({}, (function() return true end),  M.None)
  test({}, (function() return false end), M.None)
  test({}, exploder,   M.None)

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) return           x ~= nil end), M.Something(1))
  test(megalist, (function(x) return           x == nil end), M.None)
  test(megalist, (function(x) return          x == true end), M.None)
  test(megalist, (function(x) return         x == false end), M.Something(3))
  test(megalist, (function(x) return type(x) == 'table' and x[2] == 2 end), M.Something(6))
  test(megalist, (function(x) return        x == "dreq" end), M.Something(5))
  test(megalist, (function(x) return        x == "grek" end), M.None)
  test(megalist, (function(x) return type(x) == 'number' and x > 10 end), M.Something(4))
  test(megalist, (function(x) return    bLengthD(x)(0) > 10 end), M.None)
  test(megalist, (function(x) return    bLengthD(x)(0) == 4 end), M.Something(5))
  test(megalist, (function(x) return    bLengthD(x)(0) >  4 end), M.Something(1))
  test(megalist, (function(x) return type(x) ~= 'table' end), M.Something(3))
  test(megalist, (function(x) if type(x) == "table" then return x.apples ~= nil else return false end end),    M.Something(2))
  test(megalist, (function(x) if type(x) == "table" then return x.apples ==   4 else return false end end),    M.None)

end

local function testArrayFlatMap()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("flatMap")(n)(A.flatMap(f)(xs), expected)
    n = n + 1
  end

  test({},                                     exploder,                                 {})
  test({ 0, 1, 2, 3, 4, 5 },                           (function() return {} end),                              {})
  test({ 0, 1, 2, 3, 4, 5 },                           (function(x) if x % 2 == 0 then return { x } else return {} end end), ({ 0, 2, 4 }))
  test({ { 0, 2, 4 }, { 3, 6, 9 }, { 4, 8, 12, 16 } }, (function(x) return x end),                               { 0, 2, 4, 3, 6, 9, 4, 8, 12, 16 })

  test({ "apples", "grapes", "oranges", "grapes", "bananas" }, (function(x) if string.len(x) ~= 7 then return { x } else return {} end end), { "apples", "grapes", "grapes" })

  -- Monad law tests below

  local point = function(x) return           { x } end
  local f     = function(x) return point(x .. "!") end
  local g     = function(x) return point(x .. "?") end
  local h     = function(x) return point(x .. "~") end

  local str  = "apples"
  local strs = { "apples", "grapes", "oranges" }

  -- Kleisli Arrow / Kleisli composition operator
  local kleisli = function(f1)
    return function(f2)
      return function(x)
        return A.flatMap(f2)(f1(x))
      end
    end
  end

  local fgh1 = kleisli(kleisli(f)(g))(h)
  local fgh2 = kleisli(f)(kleisli(g)(h))

  test(point(str), f,     f(str)) -- Left identity
  test(strs,       point, strs)   -- Right identity

  -- Associativity
  TestSuite.equal("Array")("flatMap - Assoc")(1)(A.flatMap(fgh1)(strs), A.flatMap(fgh2)(strs))

end

local function testArrayFlattenDeep()

  local n = 1
  local function test(xs, expected)
    TestSuite.equal("Array")("flattenDeep")(n)(A.flattenDeep(xs), expected)
    n = n + 1
  end

  test({},                                                                                 {})
  test({ {} },                                                                               {})
  test({ { 42 } },                                                                             { 42 })
  test({ { 42 }, {}, { {} } },                                                                   { 42 })
  test({ { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } },                         { 13, 14, 15, 16, 17, 18, 19, { apples = 3 }, false, 22, "dreq", 1, 2, 3 })
  test({ { 13, 14, 15, 16, 17, 18, 19 }, { nil }, { { {}, { { apples = 3 } }, false }, {}, 22 }, { "dreq", { 1, 2, 3 } }, { {} } }, { 13, 14, 15, 16, 17, 18, 19, { apples = 3 }, false, 22, "dreq", 1, 2, 3 })

end

local function testArrayFoldl()

  local n = 1
  local function test(xs, x, f, expected)
    TestSuite.equal("Array")("foldl")(n)(A.foldl(f)(x)(xs), expected)
    n = n + 1
  end

  -- Non-functions
  test({}, 9001, exploder, 9001)

  -- Unprincipled functions
  test({},        0,  (function(acc, x) return x end),                   0)         -- No-op
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 0,  (function(acc, x) return x end),                   10)      -- Grab last
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, {}, (function(acc, x) return A.concat(acc)({ x }) end),     { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }) -- Constructor replacement
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, {}, (function(acc, x) return A.concat(acc)({ x + 1 }) end), {    2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }) -- Map +1

  -- Associative functions
  local strs = { "I", "want", "chicken", "I", "want", "liver", "Meow", "Mix", "Meow", "Mix", "please", "deliver" }
  test(strs, "", (function(acc, x) return acc .. " " .. x end), " I want chicken I want liver Meow Mix Meow Mix please deliver") -- String concatenation

  -- Commutative functions from here on out

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 9001, (function(acc, x) return acc + x end), 9056) -- Sum
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 0,    (function(acc, x) return acc * x end), 0)    -- Product

  local arr = { "apples", "oranges", "grapes", "bananas" }
  test(arr, 0, (function(acc, x) return acc + string.len(x) end), string.len(table.concat(arr, ""))) -- Length of string sum == sum of string lengths

  local objs = { { a = 4 }, { a = 10 }, { b = 32 }, { a = 2 } }
  test(objs, 1, (function(acc, x) if x.a ~= nil then return acc * x.a else return acc * 1 end end), 4 * 10 * 2) -- Product of object properties

  local trues  = { true, true, true, true, true, true, true, true, true }
  local falses = { false, false, false, false, false }
  local mixed  = { true, false, false, true, true }

  -- All?
  local andF = function(x, y) return x and y end
  test(trues,  true,  andF, true)
  test(trues,  false, andF, false)
  test(falses, true,  andF, false)
  test(falses, false, andF, false)
  test(mixed,  true,  andF, false)
  test(mixed,  false, andF, false)

  -- Any?
  local orF = function(x, y) return x or y end
  test(trues,  true,  orF, true)
  test(trues,  false, orF, true)
  test(falses, true,  orF, true)
  test(falses, false, orF, false)
  test(mixed,  true,  orF, true)
  test(mixed,  false, orF, true)

  local x2     = function(x) return x * 2 end
  local x5     = function(x) return x * 5 end
  local x10    = function(x) return x * 10 end
  local bigBoy = function(x) return x2(x5(x10(x))) end

  -- Monoidal binary operator
  local compose = function(f, g)
    return function(x)
      return g(f(x))
    end
  end

  -- Monoidal identity element
  local id = function(x) return x end

  -- Function composition: Read it and weep
  TestSuite.equal("Array")("foldl - comp")(1)(A.foldl(compose)(id)({ x2, x5, x10 })(9), bigBoy(9))

end

local function testArrayForEach()

  local acc = ""

  local n = 1
  local function test(input, expected)
    A.forEach(function(x) acc = acc .. x end)(input)
    TestSuite.equal("Array")("forEach")(n)(A.foldl((function(x, y) return x .. y end))("")(input), acc)
    acc = ""
    n = n + 1
  end

  test({}, "")
  test({ "1" }, "1")
  test({ "1", "2" }, "12")
  test({ "0", "0", "0", "00", "0" }, "000000")
  test({ "13", "14", "15", "16", "17", "18", "19" }, "13141516171819")

end

local function testArrayHead()

  local n = 1
  local function test(input, expected)
    TestSuite.equal("Array")("head")(n)(A.head(input), expected)
    n = n + 1
  end

  test({},                     M.None)
  test({ 1 },                  M.Something(1))
  test({ 1, 2 },               M.Something(1))
  test({ 13, 14, 15, 16, 17, 18, 19 },             M.Something(13))
  test({ true, false, true },  M.Something(true))
  test({ false, false, true }, M.Something(false))
  test({ "apples" },           M.Something("apples"))
  test({ {}, true, 10 },       M.Something({}))

end

local function testArrayIsEmpty()

  local n = 1
  local function test(input, expected)
    TestSuite.equal("Array")("isEmpty")(n)(A.isEmpty(input), expected)
    n = n + 1
  end

  test({},                     true)
  test({ nil },                true)
  test({ 1 },                  false)
  test({ 1, 2 },               false)
  test({ 13, 14, 15, 16, 17, 18, 19 },             false)
  test({ true, false, true },  false)
  test({ "apples" },           false)
  test({ {}, true, 10 },       false)

end

local function testArrayItem()

  local n = 1
  local function test(i, xs, expected)
    TestSuite.equal("Array")("item")(n)(A.item(i)(xs), expected)
    n = n + 1
  end

  test(1,      {},                 M.None)
  test(0,     { 1 },                M.None)
  test(1,      { 1 },                M.Something(1))
  test(2,      { 1 },                M.None)
  test(9001,   { 1 },                M.None)
  test(1,      { nil },              M.None)
  test(2,      { nil },              M.None)
  test(1,      { 13, 14, 15, 16, 17, 18, 19 },           M.Something(13))
  test(2,      { 13, 14, 15, 16, 17, 18, 19 },           M.Something(14))
  test(3,      { 13, 14, 15, 16, 17, 18, 19 },           M.Something(15))
  test(4,      { 13, 14, 15, 16, 17, 18, 19 },           M.Something(16))
  test(5,      { 13, 14, 15, 16, 17, 18, 19 },           M.Something(17))
  test(6,      { 13, 14, 15, 16, 17, 18, 19 },           M.Something(18))
  test(7,      { 13, 14, 15, 16, 17, 18, 19 },           M.Something(19))
  test(8,      { 13, 14, 15, 16, 17, 18, 19 },           M.None)
  test(2,      { "merpy", "gurpy" }, M.Something("gurpy"))
  test(1,      { "merpy", "gurpy" }, M.Something("merpy"))

end

local function testArrayLast()

  local n = 1
  local function test(input, expected)
    TestSuite.equal("Array")("last")(n)(A.last(input), expected)
    n = n + 1
  end

  test({},                   nil)
  test({ 1 },                  1)
  test({ 1, 2 },               2)
  test({ 13, 14, 15, 16, 17, 18, 19 },             19)
  test({ true, false, true },  true)
  test({ false, false, true }, true)
  test({ "apples" },           "apples")
  test({ {}, true, 10 },       10)

end

local function testArrayLength()

  local n = 1
  local function test(input, expected)
    TestSuite.equal("Array")("length")(n)(A.length(input), expected)
    n = n + 1
  end

  test({},                   0)
  test({ 1 },                  1)
  test({ 1, 2 },               2)
  test({ 13, 14, 15, 16, 17, 18, 19 },             7)
  test({ true, false, true },  3)
  test({ "apples" },           1)
  test({ {}, true, 10 },       3)

end

local function testArrayMap()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("map")(n)(A.map(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x + 1 end), { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return x * 2 end), ({ 2, 4, 6, 8, 10, 12, 14, 16, 18, 20 }))

  test({ true, false, false }, (function(x) return x end), { true, false, false })

  test({ "oranges", "merpy", "gurpy!" }, (function(x) return string.len(x) end), { 7, 5, 6 })
  test({ "oranges", "merpy", "gurpy!" }, (function(x) return string.sub(x, 1, 1) end), { "o", "m", "g" })

  test({}, (function() return 9001 end), {})
  test({}, exploder,  {})

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) return x ~=   nil end),                      {  true,  true,  true,  true,  true,  true })
  test(megalist, (function(x) return x ==   nil end),                { false, false, false, false, false, false })
  test(megalist, (function(x) return x == false end),              { false, false, true,  false, false, false })
  test(megalist, (function(x) return bLengthD(x)(0) > 3 end),     {  true, false, false, false,  true, false })
  test(megalist, (function(x) return type(x) == 'table' end),      {  true,  true, false, false, false,  true })

  -- Functor laws!

  local f    = function(x) return x .. "!" end
  local g    = function(x) return x .. "?" end
  local id   = function(x) return x end
  local strs = { "apples", "grapes", "oranges", "bananas" }

  local mapTwice    = F.pipeline(A.map(f), A.map(g))
  local mapComposed = A.map(F.pipeline(f, g))

  test(strs, id, strs) -- Identity

  -- Associativity
  TestSuite.equal("Array")("map - Assoc")(1)(mapTwice(strs), mapComposed(strs))

end

local function testArrayMaxBy()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("maxBy")(n)(A.maxBy(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return  x end), M.Something(10))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return -x end), M.Something(1))
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, (function(x) return  0 end), M.Something(1))
  test({ 4, 2, 6, 10 },                   (function(x) return  0 end), M.Something(4))

  test({ false, false, false }, (function(x) if x then return 1 else return 0 end end), M.Something(false))
  test({ true,   true,  true }, (function(x) if x then return 1 else return 0 end end), M.Something(true))
  test({ true,  false, false }, (function(x) if x then return 1 else return 0 end end), M.Something(true))
  test({ true,  false, false }, (function(x) if x then return 0 else return 1 end end), M.Something(false))

  test({ "apples", "grapes", "oranges", "bananas" }, (function(x) return                        string.len(x) end), M.Something("oranges"))
  test({ "apples", "grapes", "oranges", "bananas" }, (function(x) return (select(2, string.gsub(x, "a", ""))) end), M.Something("bananas"))

  test({}, (function() return 0 end),   M.None)
  test({}, exploder, M.None)

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) if type(x) == "table" and x.apples ~= nil then return x.apples else return 0 end end),                       M.Something({ apples = 3 }))
  test(megalist, (function(x) if bLength(x) ~= nil then return bLength(x) else return 0 end end),                       M.Something({ 13, 14, 15, 16, 17, 18, 19 }))
  test(megalist, (function(x) if type(x) ~= "number" then return 0 else return x end end), M.Something(22))

end

local function testArrayReverse()

  local n = 1
  local function test(xs, expected)
    TestSuite.equal("Array")("reverse")(n)(A.reverse(xs), expected)
    n = n + 1
  end

  test({},                                                                        {})
  test({ true },                                                                    { true })
  test({ 9001 },                                                                    { 9001 })
  test({ 3, 4, 5, 6 },                                                              { 6, 5, 4, 3 })
  test({ "merpy", "gerpy", "derpy" },                                               { "derpy", "gerpy", "merpy" })
  test({ true, false, false, true },                                                { true, false, false, true })
  test({ true, false, true, true },                                                 { true, true, false, true })
  test({ {}, { apples = 3 }, { isFruitBasket = true, apples = 9001, oranges = 8999 } }, { { isFruitBasket = true, apples = 9001, oranges = 8999 }, { apples = 3 }, {} })
  test({ { true }, { 9001 }, { 3, 4, 5, 6 }, { 6, 5, 4, 3 }, { "merpy", "gerpy", "derpy" } },             { { "merpy", "gerpy", "derpy" }, { 6, 5, 4, 3 }, { 3, 4, 5, 6 }, { 9001 }, { true } })
  test({ true, 9001, { 3, 4, 5, 6 }, 6, { "merpy", "gerpy", "derpy" } },                      { { "merpy", "gerpy", "derpy" }, 6, { 3, 4, 5, 6 }, 9001, true })
  test({ -6, 24, 4, -78, 22, -4, 4, 13, 22, -0 },                                   { -0, 22, 13, 4, -4, 22, -78, 4, 24, -6 })

end

local function testArraySingleton()

  local n = 1
  local function test(x, expected)
    TestSuite.equal("Array")("singleton")(n)(A.singleton(x), expected)
    n = n + 1
  end

  test(1,                  { 1 })
  test(9001,               { 9001 })
  test(true,               { true })
  test(false,              { false })
  test("merp",             { "merp" })
  test({ 3, 4, 5, 6 },             { { 3, 4, 5, 6 } })
  test({ "merpy", "gerpy" }, { { "merpy", "gerpy" } })
  test({ apples = 3 },      { { apples = 3 } })

end

local function testArraySortBy()

  local n = 1
  local function test(xs, f, expected)
    TestSuite.equal("Array")("sortBy")(n)(A.sortBy(f)(xs), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0 },       (function(x) return x end),           { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
  test({ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },       (function(x) return x end),           { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
  test({ 1, 2, 3, 0, 4, 5, 6, 7, 8, 9, 10 },       (function(x) return x end),           { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
  test({ 1, 2, 3, 0, 4, 5, 6, 7, 8, 0, 9, 10, 0 }, (function(x) return x end),           { 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
  test({ 6, 24, 4, 78, 22, 4, 4, 13, 22, 0 },      (function(x) return x end),           { 0, 4, 4, 4, 6, 13, 22, 22, 24, 78 })
  test({ -6, 24, 4, -78, 22, -4, 4, 13, 22, -0 },  (function(x) return x end),           { -78, -6, -4, -0, 4, 4, 13, 22, 22, 24 })
  test({ -6, 24, 4, -78, 22, -4, 4, 13, 22, -0 },  (function(x) return math.abs(x) end), { -0, 4, 4, -4, -6, 13, 22, 22, 24, -78 })

  test({ false, false, false }, (function(x) if x then return 1 else return 0 end end), { false, false, false })
  test({ false, false, false }, (function(x) if x then return 0 else return 1 end end), { false, false, false })
  test({ true,  true,  true  }, (function(x) if x then return 1 else return 0 end end), { true,  true,  true  })
  test({ true,  true,  true  }, (function(x) if x then return 0 else return 1 end end), { true,  true,  true  })
  test({ true,  false, false }, (function(x) if x then return 1 else return 0 end end), { false, false, true  })
  test({ true,  false, false }, (function(x) if x then return 0 else return 1 end end), { true,  false, false })

  test({ "short",  "a long",  "a longer", "the longest" }, (function(x) return x end),        { "a long", "a longer", "short", "the longest" })
  test({ "a long", "short",   "a longer", "the longest" }, (function(x) return string.len(x) end), { "short", "a long", "a longer", "the longest" })

  test({},        (function() return 0 end),   {})
  test({},        exploder, {})
  test({ 4, 2, 6 }, (function() return 0 end),   { 4, 2, 6 })

  test({ 8 },                  (function() return 0 end), { 8 })
  test({ {} },                 (function() return 0 end), { {} })
  test({ { argon = 18 } },     (function() return 0 end), { { argon = 18 } })
  test({ "" },                 (function() return 0 end), { "" })
  test({ "apples" },           (function() return 0 end), { "apples" })
  test({ {} },                 (function() return 0 end), { {} })
  test({ { true, false, 1 } }, (function() return 0 end), { { true, false, 1 } })
  test({ true },               (function() return 0 end), { true })
  test({ false },              (function() return 0 end), { false })

  local megalist = { { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, false, 22, "dreq", { 1, 2, 3 } }
  test(megalist, (function(x) return type(x) end),                                                                   { false, 22, "dreq", { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, { 1, 2, 3 } })
  test(megalist, (function(x) if type(x) == "table" and x.apples ~= nil then return x.apples else return 0 end end), { { 13, 14, 15, 16, 17, 18, 19 }, 22, "dreq", false, { 1, 2, 3 }, { apples = 3 } })
  test(megalist, (function(x) return bLengthD(x)(0) end),                                                            { false, 22, { apples = 3 }, { 1, 2, 3 }, "dreq", { 13, 14, 15, 16, 17, 18, 19 } })

end

local function testArraySortedIndexBy()

  local n = 1
  local function test(xs, x, f, expected)
    TestSuite.equal("Array")("sortedIndexBy")(n)(A.sortedIndexBy(f)(xs)(x), expected)
    n = n + 1
  end

  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 0,    (function(x) return x end), 1)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 2,    (function(x) return x end), 2)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 2.1,  (function(x) return x end), 3)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 11,   (function(x) return x end), 11)
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 9001, (function(x) return x end), 11)

  test({ false, false, false }, false, (function(x) if x then return 1 else return 0 end end), 1)
  test({ false, false, false }, true,  (function(x) if x then return 1 else return 0 end end), 4)
  test({ false, false, false }, false, (function(x) if x then return 0 else return 1 end end), 1)
  test({ false, false, false }, true,  (function(x) if x then return 0 else return 1 end end), 1)
  test({ true,  true,  true  }, false, (function(x) if x then return 1 else return 0 end end), 1)
  test({ true,  true,  true  }, true,  (function(x) if x then return 1 else return 0 end end), 1)
  test({ true,  true,  true  }, false, (function(x) if x then return 0 else return 1 end end), 4)
  test({ true,  true,  true  }, true,  (function(x) if x then return 0 else return 1 end end), 1)
  test({ true,  false, false }, false, (function(x) if x then return 1 else return 0 end end), 1)
  test({ true,  false, false }, true,  (function(x) if x then return 1 else return 0 end end), 1)
  test({ true,  false, false }, false, (function(x) if x then return 0 else return 1 end end), 2)
  test({ true,  false, false }, true,  (function(x) if x then return 0 else return 1 end end), 1)

  test({ "short", "a long", "a longer", "the longest" }, "a longish",         string.len, 4)
  test({ "short", "a long", "a longer", "the longest" }, "123",               string.len, 1)
  test({ "short", "a long", "a longer", "the longest" }, "lorem ipsum dolor", string.len, 5)
  test({ "short", "a long", "a longer", "the longest" }, "a long",            string.len, 2)
  test({ "short", "a long", "a longer", "the longest" }, "a longé",           string.len, 3)

  test({},                  8, (function() return 9001 end), 1)
  test({},                 {}, (function() return 9001 end), 1)
  test({},     { argon = 18 }, (function() return 9001 end), 1)
  test({},                 "", (function() return 9001 end), 1)
  test({},           "apples", (function() return 9001 end), 1)
  test({},                 {}, (function() return 9001 end), 1)
  test({}, { true, false, 1 }, (function() return 9001 end), 1)
  test({},               true, (function() return 9001 end), 1)
  test({},              false, (function() return 9001 end), 1)

  local megalist = { false, 22, { 13, 14, 15, 16, 17, 18, 19 }, { apples = 3 }, { 1, 2, 3 }, "dreq" }
  test(megalist,        true, (function(x) return type(x) end), 1)
  test(megalist,          23, (function(x) return type(x) end), 2)
  test(megalist, { 2, 3, 4 }, (function(x) return type(x) end), 3)
  test(megalist,         nil, (function(x) return type(x) end), 2)
  test(megalist,          {}, (function(x) return type(x) end), 3)
  test(megalist,          "", (function(x) return type(x) end), 3)
  test(megalist,     "bobby", (function(x) return type(x) end), 3)

end

local function testArrayTail()

  local n = 1
  local function test(input, expected)
    TestSuite.equal("Array")("tail")(n)(A.tail(input), expected)
    n = n + 1
  end

  test({},       {})
  test({ 1 },      {})
  test({ 1, 2 },   { 2 })
  test({ 13, 14, 15, 16, 17, 18, 19 }, { 14, 15, 16, 17, 18, 19 })

end

local function testArrayToTable()

  local n = 1
  local function test(input, expected)
    TestSuite.equal("Array")("toTable")(n)(A.toTable(input), expected)
    n = n + 1
  end

  test({},           {})
  test({ { "a", "b" } }, { a = "b" })
  test({ { 1, 2 } },     { [1] = 2 })
  test({ { 1, 2 }, { "a", "b" }, { "blue", 42 }, { "redIsGreen", false } }, { [1] = 2, a = "b", blue = 42, redIsGreen = false })

end

local function testArrayUnique()

  local n = 1
  local function test(input, expected)
    TestSuite.equal("Array")("unique")(n)(A.unique(input), expected)
    n = n + 1
  end

  test({},     {})
  test({ 1 },    { 1 })
  test({ 1, 1 }, { 1 })
  test({ 1, 7, 4, 2, 7, 1, 3 }, { 1, 7, 4, 2, 3 })

  test({ "" },       { "" })
  test({ "A" },      { "A" })
  test({ "A", "A" }, { "A" })
  test({ "A", "B", "A", "F", "D", "B", "C" }, { "A", "B", "F", "D", "C" })

  test({ true,  true },  { true })
  test({ false, false }, { false })
  test({ true,  false }, { true, false })
  test({ false, true, true }, { false, true })

  test({     {} },  { {} })
  test({    { 1 } }, { { 1 } })
  test({ {}, {} },  { {} })

  local apples = { a = 10, sargus = "mcmargus" }
  test({ {} }, { {} })
  test({ apples }, { apples })
  test({ apples, {} }, { apples, {} })
  test({ apples, apples, {} }, { apples, {} })
  test({ apples, apples, {} }, { apples, {} })
  test({ apples, {}, apples, {}, {} }, { apples, {} })

end

local function testArrayUniqueBy()

  local n = 1
  local function testEq(input, expected)
    TestSuite.equal("Array")("uniqueBy - id")(n)(A.uniqueBy(F.id)(input), expected)
    n = n + 1
  end

  local apples = { a = 10, sargus = "mcmargus" }

  testEq({},     {})
  testEq({ 1 },    { 1 })
  testEq({ 1, 1 }, { 1 })
  testEq({ 1, 7, 4, 2, 7, 1, 3 }, { 1, 7, 4, 2, 3 })

  testEq({ "" },       { "" })
  testEq({ "A" },      { "A" })
  testEq({ "A", "A" }, { "A" })
  testEq({ "A", "B", "A", "F", "D", "B", "C" }, { "A", "B", "F", "D", "C" })

  testEq({ true,  true },  { true })
  testEq({ false, false }, { false })
  testEq({ true,  false }, { true, false })
  testEq({ false, true, true }, { false, true })

  testEq({ {} },  { {} })
  testEq({ { 1 } }, { { 1 } })
  testEq({ {}, {} }, { {} })

  testEq({ {} }, { {} })
  testEq({ apples }, { apples })
  testEq({ apples, {} }, { apples, {} })
  testEq({ apples, apples, {} }, { apples, {} })
  testEq({ apples, apples, {} }, { apples, {} })
  testEq({ apples, {}, apples, {}, {} }, { apples, {} })

  local n = 1
  local function testLength(input, expected)
    TestSuite.equal("Array")("uniqueBy - length")(n)(A.uniqueBy(getn)(input), expected)
    n = n + 1
  end

  testLength({},       {})
  testLength({ {} },     { {} })
  testLength({ {}, {} }, { {} })
  testLength({ {}, {}, { 9001 }, {}, { 2 }, { 1, 2, 3, 4 }, {}, { 0 } }, { {}, { 9001 }, { 1, 2, 3, 4 } })

end

local function testArrayZip()

  local n = 1
  local function test(xs, ys, expected)
    TestSuite.equal("Array")("zip")(n)(A.zip(xs)(ys), expected)
    n = n + 1
  end

  test({},                    {},       {})
  test({},                    { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, {})
  test({ "apples" },            {},       {})
  test({ "apples" },            { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, { { "apples", 10 } })
  test({ "apples", "oranges" }, { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, { { "apples", 10 }, { "oranges", 11 } })
  test({ "apples", "oranges" }, { 10 },     { { "apples", 10 } })
  test({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },               { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, { { 1, 10 }, { 2, 11 }, { 3, 12 }, { 4, 13 }, { 5, 14 }, { 6, 15 }, { 7, 16 }, { 8, 17 }, { 9, 18 }, { 10, 19 } })

end

function TestSuite.testArray()
  testArrayAll()
  testArrayConcat()
  testArrayContains()
  testArrayCountBy()
  testArrayDifference()
  testArrayExists()
  testArrayFilter()
  testArrayFind()
  testArrayFindIndex()
  testArrayFlatMap()
  testArrayFlattenDeep()
  testArrayFoldl()
  testArrayForEach()
  testArrayHead()
  testArrayIsEmpty()
  testArrayItem()
  testArrayLast()
  testArrayLength()
  testArrayMap()
  testArrayMaxBy()
  testArrayReverse()
  testArraySingleton()
  testArraySortBy()
  testArraySortedIndexBy()
  testArrayTail()
  testArrayToTable()
  testArrayUnique()
  testArrayUniqueBy()
  testArrayZip()
  print("testArray complete")
end
