SLASH_BRAZIERTEST1 = '/braziertest'

-- String => Unit
function SlashCmdList.BRAZIERTEST(msg)
  if msg == 'all' then
    TestSuite.testAll()
  elseif msg == 'array' then
    TestSuite.testArray()
  elseif msg == 'equals' then
    TestSuite.testEquals()
  elseif msg == 'function' then
    TestSuite.testFunction()
  elseif msg == 'maybe' then
    TestSuite.testMaybe()
  elseif msg == 'number' then
    TestSuite.testNumber()
  elseif msg == 'table' then
    TestSuite.testTable()
  elseif msg == 'type' then
    TestSuite.testType()
  end
end
