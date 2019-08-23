TestSuite = {}

function TestSuite.assert(suiteName)
  return function(subSuiteName)
    return function(testNum)
      return function(cond)
        if cond == false then
          print("FAIL: " .. suiteName .. "/" .. subSuiteName .. " #" .. testNum)
        end
      end
    end
  end
end

function TestSuite.testAll()
  TestSuite.testArray()
  TestSuite.testEquals()
  TestSuite.testFunction()
  TestSuite.testMaybe()
  TestSuite.testNumber()
  TestSuite.testTable()
  TestSuite.testType()
end

function TestSuite.equal(suiteName)
  return function(subSuiteName)
    return function(testNum)
      return function(x, y)
        TestSuite.assert(suiteName)(subSuiteName)(testNum)(Brazier.Equals.eq(x)(y))
      end
    end
  end
end
