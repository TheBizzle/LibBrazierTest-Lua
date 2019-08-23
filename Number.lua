local N = Brazier.Number

function TestSuite.testNumber()

  local equal = TestSuite.equal("Number")

  equal("multiply")( 1)(N.multiply(  0)(  5),    0)
  equal("multiply")( 2)(N.multiply(  5)(  0),    0)
  equal("multiply")( 3)(N.multiply(  5)(  6),   30)
  equal("multiply")( 4)(N.multiply(  6)(  5),   30)
  equal("multiply")( 5)(N.multiply(  1)(  1),    1)
  equal("multiply")( 6)(N.multiply(  6)(  1),    6)
  equal("multiply")( 7)(N.multiply(  1)(  6),    6)
  equal("multiply")( 8)(N.multiply(  0)(  0),    0)
  equal("multiply")( 9)(N.multiply(-10)(-15),  150)
  equal("multiply")(10)(N.multiply( 10)(-15), -150)
  equal("multiply")(11)(N.multiply( 15)(-10), -150)

  equal("plus")(1)(N.plus(  0)(  5),   5)
  equal("plus")(2)(N.plus(  5)(  0),   5)
  equal("plus")(3)(N.plus(  5)(  6),  11)
  equal("plus")(4)(N.plus(  6)(  5),  11)
  equal("plus")(5)(N.plus(  1)(  1),   2)
  equal("plus")(6)(N.plus(  0)(  0),   0)
  equal("plus")(7)(N.plus(-10)(-15), -25)
  equal("plus")(8)(N.plus( 10)(-15),  -5)
  equal("plus")(9)(N.plus( 15)(-10),   5)

  equal("rangeTo")(1)(N.rangeTo(0)( 5), { 0, 1, 2, 3, 4, 5 })
  equal("rangeTo")(2)(N.rangeTo(0)( 0), { 0 })
  equal("rangeTo")(3)(N.rangeTo(0)(-1), {})

  equal("rangeUntil")(1)(N.rangeUntil(0)( 5), { 0, 1, 2, 3, 4 })
  equal("rangeUntil")(2)(N.rangeUntil(0)( 0), {})
  equal("rangeUntil")(3)(N.rangeUntil(0)(-1), {})

  print("testNumber complete")

end
