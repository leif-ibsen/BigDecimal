//
//  TestBigDecimal.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 28/04/2021.
//

//
// Test cases from Java BigDecimal tests translated to Swift
//

import XCTest
import BigInt

class TestBigDecimal: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    func equals(_ x: BigDecimal, _ y: BigDecimal) -> Bool {
        return x.significand == y.significand && x.exponent == y.exponent
    }

    let value = BInt("12345908")!
    let value2 = BInt("12334560000")!
    
    func testAbs() throws {
        var big = BigDecimal("-1234")
        var bigabs = big.abs
        XCTAssertEqual(bigabs.asString(), "1234")
        big = BigDecimal(BInt("2345")!, -2)
        bigabs = big.abs
        XCTAssertEqual(bigabs.asString(), "23.45")
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testAdd() throws {
        let add1 = BigDecimal("23.456")
        let add2 = BigDecimal("3849.235")
        let sum = add1 + add2
        XCTAssertEqual(sum.significand.asString(), "3872691")
        XCTAssertEqual(sum.exponent, -3)
        XCTAssertEqual(sum.asString(), "3872.691")
        let add3 = BigDecimal(12.34E02)
        XCTAssertEqual((add1 + add3).asString(), "1257.456")
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testCompare() throws {
        let comp1 = BigDecimal("1.00")
        let comp2 = BigDecimal(1.000000)
        XCTAssertTrue(comp1 == comp2)
        let comp3 = BigDecimal("1.02")
        XCTAssertTrue(comp3 > comp1)
        let comp4 = BigDecimal(0.98)
        XCTAssertTrue(comp4 < comp1)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testDivide1() throws {
        let divd1 = BigDecimal(value, -2)
        var divd2 = BigDecimal("2.335")
        var divd3 = divd1.divide(divd2, Rounding(.UP, 7))
        XCTAssertEqual(divd3.asString(), "52873.27")
        XCTAssertEqual(divd3.exponent, divd1.exponent)
        XCTAssertEqual(divd3.significand.asString(), "5287327")

        divd2 = BigDecimal(123.4)
        divd3 = divd1.divide(divd2, Rounding(.DOWN, 6))
        XCTAssertEqual(divd3.asString(), "1000.47")
        XCTAssertEqual(divd3.exponent, -2)
        XCTAssertEqual(divd3.significand.asInt(), 100047)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }
    
    func testDivide2() throws {
        let divd1 = BigDecimal(value2, -4)
        var divd2 = BigDecimal("0.0023")
        var divd3 = divd1.divide(divd2, Rounding(.HALF_UP, 12))
        XCTAssertEqual(divd3.asString(), "536285217.391")
        XCTAssertEqual(divd3.exponent, -3)
        divd2 = BigDecimal(1345.5E-02)
        divd3 = divd1.divide(divd2, Rounding(.DOWN, 5))
        XCTAssertEqual(divd3.asString(), "91672")
        XCTAssertEqual(divd3.exponent, 0)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testDouble() throws {
        var bigDB = BigDecimal(-1.234E-112)
        XCTAssertEqual(bigDB.asDouble(), -1.234E-112)

        let db = Double(sign: .plus, exponent: -1074, significand: 1.0) // = 5.00E-324
        bigDB = BigDecimal(db)
        XCTAssertEqual(bigDB.asDouble(), db)

        bigDB = BigDecimal(1.79E308)
        XCTAssertEqual(bigDB.asDouble(), 1.79E308)
        XCTAssertEqual(bigDB.exponent, 0)

        bigDB = BigDecimal(-2.33E102)
        XCTAssertEqual(bigDB.asDouble(), -2.33E102)
        XCTAssertEqual(bigDB.exponent, 0)
        
        bigDB = BigDecimal(Double.greatestFiniteMagnitude)
        bigDB = bigDB + bigDB
        XCTAssertEqual(bigDB.asDouble(), Double.infinity)
        
        bigDB = BigDecimal(-Double.greatestFiniteMagnitude)
        bigDB = bigDB + bigDB
        XCTAssertEqual(bigDB.asDouble(), -Double.infinity)
        
        let fl1 = BigDecimal("234563782344567")
        XCTAssertEqual(fl1.asDouble(), 234563782344567)

        var fl2 = BigDecimal(2.345E37)
        XCTAssertEqual(fl2.asDouble(), 2.345E37)
        
        fl2 = BigDecimal(-1.00E-44)
        XCTAssertEqual(fl2.asDouble(), -1.00E-44)
        
        fl2 = BigDecimal(-3E12)
        XCTAssertEqual(fl2.asDouble(), -3E12)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testEqual() throws {
        var equal1 = BigDecimal(1.00)
        var equal2 = BigDecimal("1.0")
        XCTAssertTrue(equal1 == equal2)
        XCTAssertFalse(equals(equal1, equal2))

        equal2 = BigDecimal(1.01)
        XCTAssertFalse(equal1 == equal2)
        XCTAssertFalse(equals(equal1, equal2))

        equal2 = BigDecimal("1.00")
        XCTAssertTrue(equal1 == equal2)

        let val = BInt("100")!
        equal1 = BigDecimal("1.00")
        equal2 = BigDecimal(val, -2)
        XCTAssertTrue(equal1 == equal2)
        XCTAssertTrue(equals(equal1, equal2))

        equal1 = BigDecimal(100)
        equal2 = BigDecimal("2.34576")
        XCTAssertFalse(equal1 == equal2)
        XCTAssertFalse(equals(equal1, equal2))
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testMultiply() throws {
        var multi1 = BigDecimal(value, -5)
        var multi2 = BigDecimal(2.345)
        var result = multi1 * multi2
        XCTAssertTrue(result.asString().starts(with: "289.51154260"))
        XCTAssertEqual(result.exponent, multi1.exponent + multi2.exponent)

        multi1 = BigDecimal("34656")
        multi2 = BigDecimal("-2")
        result = multi1 * multi2
        XCTAssertEqual(result.asString(), "-69312")
        XCTAssertEqual(result.exponent, 0)
 
        multi1 = BigDecimal(-2.345E-02)
        multi2 = BigDecimal(-134E130)
        result = multi1 * multi2
        XCTAssertEqual(result.asDouble(), 3.1422999999999997E130)
        XCTAssertEqual(result.exponent, multi1.exponent + multi2.exponent)
 
        multi1 = BigDecimal("11235")
        multi2 = BigDecimal("0")
        result = multi1 * multi2
        XCTAssertEqual(result.asDouble(), 0)
        XCTAssertEqual(result.exponent, 0)

        multi1 = BigDecimal("-0.00234")
        multi2 = BigDecimal(13.4E10)
        result = multi1 * multi2
        XCTAssertEqual(result.asDouble(), -313560000)
        XCTAssertEqual(result.exponent, multi1.exponent + multi2.exponent)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testNegate() throws {
        var negate1 = BigDecimal(value2, -7)
        XCTAssertEqual((-negate1).asString(), "-1233.4560000")
        
        negate1 = BigDecimal("-23465839")
        XCTAssertEqual((-negate1).asString(), "23465839")
        
        negate1 = BigDecimal(-3.456E6)
        XCTAssertEqual(-(-negate1), negate1)
        XCTAssertTrue(equals(-(-negate1), negate1))
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testScale1() throws {
        let scale1 = BigDecimal(value2, -8)
        XCTAssertEqual(scale1.exponent, -8)

        let scale2 = BigDecimal("29389.")
        XCTAssertEqual(scale2.exponent, 0)
        
        let scale3 = BigDecimal(3.374E13)
        XCTAssertEqual(scale3.exponent, 0)
        
        let scale4 = BigDecimal("-3.45E-203")
        XCTAssertEqual(scale4.exponent, -205)
        
        let scale5 = BigDecimal("-345.4E-200")
        XCTAssertEqual(scale5.exponent, -201)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testRounding1() throws {
        let a = "-12380945E+61"
        let aNumber = BigDecimal(a)
        let precision = 6
        let rm = Rounding.Mode.HALF_DOWN

        let mcIntRm = Rounding(rm, precision)
        let mcStr = Rounding(.HALF_DOWN, 6)
        let mcInt = Rounding(.HALF_UP, precision)
        let res = aNumber.abs.round(mcInt)
        XCTAssertTrue(equals(res, BigDecimal("1.23809E+68")))
        XCTAssertEqual(mcIntRm, mcStr)
        XCTAssertFalse(mcInt == mcStr)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testSignum() throws {
        var sign = BigDecimal(123E-104)
        XCTAssertTrue(sign.signum == 1)
        
        sign = BigDecimal("-1234.3959")
        XCTAssertTrue(sign.signum == -1)
        
        sign = BigDecimal(0.00)
        XCTAssertTrue(sign.signum == 0)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testSubtract() throws {
        var sub1 = BigDecimal("13948")
        var sub2 = BigDecimal("2839.489")
        var result = sub1 - sub2
        XCTAssertEqual(result.asString(), "11108.511")
        XCTAssertEqual(result.exponent, -3)
        
        result = sub2 - sub1
        XCTAssertEqual(result.asString(), "-11108.511")
        XCTAssertEqual(result.exponent, -3)
        
        sub1 = BigDecimal(value, -1)
        sub2 = BigDecimal("0")
        result = sub1 - sub2
        XCTAssertTrue(equals(result, sub1))
        
        sub1 = BigDecimal(1.234E-03)
        sub2 = BigDecimal(3.423E-10)
        result = sub1 - sub2
        XCTAssertEqual(result.asDouble(), 0.0012339996577)
        
        sub1 = BigDecimal(1234.0123)
        sub2 = BigDecimal(1234.0123000)
        result = sub1 - sub2
        XCTAssertEqual(result.asDouble(), 0.0)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testAsString() throws {
        var toString1 = BigDecimal("1234.000")
        XCTAssertEqual(toString1.asString(), "1234.000")

        toString1 = BigDecimal("-123.4E-5")
        XCTAssertEqual(toString1.asString(), "-0.001234")

        toString1 = BigDecimal("-1.455E-20")
        XCTAssertEqual(toString1.asString(), "-1.455E-20")

        toString1 = BigDecimal(value2, -4)
        XCTAssertEqual(toString1.asString(), "1233456.0000")
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testSignificand() throws {
        var unsVal = BigDecimal("-2839485.000")
        XCTAssertEqual(unsVal.significand.asString(), "-2839485000")
        
        unsVal = BigDecimal(123E10)
        XCTAssertEqual(unsVal.significand.asString(), "1230000000000")
        
        unsVal = BigDecimal("-4.56E-13")
        XCTAssertEqual(unsVal.significand.asString(), "-456")
        
        unsVal = BigDecimal(value, 3)
        XCTAssertEqual(unsVal.significand.asString(), "12345908")
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testFromInt() {
        var valueOfL = BigDecimal(9223372036854775806)
        XCTAssertEqual(valueOfL.significand.asString(), "9223372036854775806")
        XCTAssertEqual(valueOfL.exponent, 0)
        XCTAssertEqual(valueOfL.asString(), "9223372036854775806")
        
        valueOfL = BigDecimal(0)
        XCTAssertEqual(valueOfL.significand.asString(), "0")
        XCTAssertEqual(valueOfL.exponent, 0)

        var valueOfJI = BigDecimal(9223372036854775806, -5)
        XCTAssertEqual(valueOfJI.significand.asString(), "9223372036854775806")
        XCTAssertEqual(valueOfJI.exponent, -5)
        XCTAssertEqual(valueOfJI.asString(), "92233720368547.75806")
        
        valueOfJI = BigDecimal(1234, -8)
        XCTAssertEqual(valueOfJI.significand.asString(), "1234")
        XCTAssertEqual(valueOfJI.exponent, -8)
        XCTAssertEqual(valueOfJI.asString(), "0.00001234")
        
        valueOfJI = BigDecimal(0, -3)
        XCTAssertEqual(valueOfJI.significand.asString(), "0")
        XCTAssertEqual(valueOfJI.exponent, -3)
        XCTAssertEqual(valueOfJI.asString(), "0.000")
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func testTrim() throws {
        let sixhundredtest = BigDecimal("600.0")
        XCTAssertTrue(sixhundredtest.trim.exponent == 2)

        let notrailingzerotest = BigDecimal("1")
        XCTAssertTrue(notrailingzerotest.trim.exponent == 0)

        let zerotest = BigDecimal("0.0000")
        XCTAssertEqual(zerotest.trim.exponent, 0)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func doTestMax32(_ enc: BigDecimal.Encoding) throws {
        var x32 = BigDecimal.MAX32.asDecimal32(enc)
        var d32 = Decimal32(x32, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.MAX32, d32)
        x32 = (-BigDecimal.MAX32).asDecimal32(enc)
        d32 = Decimal32(x32, enc).asBigDecimal()
        XCTAssertEqual(-BigDecimal.MAX32, d32)
        x32 = (BigDecimal.MAX32 + BigDecimal.ONE).asDecimal32(enc)
        XCTAssertTrue(Decimal32(x32, enc).asBigDecimal().isNaN)
        x32 = (-BigDecimal.MAX32 - BigDecimal.ONE).asDecimal32(enc)
        XCTAssertTrue(Decimal32(x32, enc).asBigDecimal().isNaN)
    }

    func doTestMax64(_ enc: BigDecimal.Encoding) throws {
        var x64 = BigDecimal.MAX64.asDecimal64(enc)
        var d64 = Decimal64(x64, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.MAX64, d64)
        x64 = (-BigDecimal.MAX64).asDecimal64(enc)
        d64 = Decimal64(x64, enc).asBigDecimal()
        XCTAssertEqual(-BigDecimal.MAX64, d64)
        x64 = (BigDecimal.MAX64 + BigDecimal.ONE).asDecimal64(enc)
        XCTAssertTrue(Decimal64(x64, enc).asBigDecimal().isNaN)
        x64 = (-BigDecimal.MAX64 - BigDecimal.ONE).asDecimal64(enc)
        XCTAssertTrue(Decimal64(x64, enc).asBigDecimal().isNaN)
    }

    func doTestMax128(_ enc: BigDecimal.Encoding) throws {
        var x128 = BigDecimal.MAX128.asDecimal128(enc)
        var d128 = Decimal128(x128, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.MAX128, d128)
        x128 = (-BigDecimal.MAX128).asDecimal128(enc)
        d128 = Decimal128(x128, enc).asBigDecimal()
        XCTAssertEqual(-BigDecimal.MAX128, d128)
        x128 = (BigDecimal.MAX128 + BigDecimal.ONE).asDecimal128(enc)
        XCTAssertTrue(Decimal128(x128, enc).asBigDecimal().isNaN)
        x128 = (-BigDecimal.MAX128 - BigDecimal.ONE).asDecimal128(enc)
        XCTAssertTrue(Decimal128(x128, enc).asBigDecimal().isNaN)
    }

    func testMax() throws {
        try doTestMax32(.BID)
        try doTestMax32(.DPD)
        try doTestMax64(.BID)
        try doTestMax64(.DPD)
        try doTestMax128(.BID)
        try doTestMax128(.DPD)
        XCTAssertTrue(BigDecimal.NaNFlag)
    }
    
    func doTestMin32(_ enc: BigDecimal.Encoding) throws {
        var x32 = BigDecimal.MIN32.asDecimal32(enc)
        var d32 = Decimal32(x32, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.MIN32, d32)
        x32 = (BigDecimal.MIN32 / BigDecimal(2)).asDecimal32(enc)
        d32 = Decimal32(x32, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.ZERO, d32)
        x32 = (BigDecimal.MIN32 - BigDecimal.MIN32.ulp).asDecimal32(enc)
        d32 = Decimal32(x32, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.ZERO, d32)
    }

    func doTestMin64(_ enc: BigDecimal.Encoding) throws {
        var x64 = BigDecimal.MIN64.asDecimal64(enc)
        var d64 = Decimal64(x64, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.MIN64, d64)
        x64 = (BigDecimal.MIN64 / BigDecimal(2)).asDecimal64(enc)
        d64 = Decimal64(x64, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.ZERO, d64)
        x64 = (BigDecimal.MIN64 - BigDecimal.MIN64.ulp).asDecimal64(enc)
        d64 = Decimal64(x64, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.ZERO, d64)
    }

    func doTestMin128(_ enc: BigDecimal.Encoding) throws {
        var x128 = BigDecimal.MIN128.asDecimal128(enc)
        var d128 = Decimal128(x128, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.MIN128, d128)
        x128 = (BigDecimal.MIN128 / BigDecimal(2)).asDecimal128(enc)
        d128 = Decimal128(x128, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.ZERO, d128)
        x128 = (BigDecimal.MIN128 - BigDecimal.MIN128.ulp).asDecimal128(enc)
        d128 = Decimal128(x128, enc).asBigDecimal()
        XCTAssertEqual(BigDecimal.ZERO, d128)
    }

    func testMin() throws {
        try doTestMin32(.BID)
        try doTestMin32(.DPD)
        try doTestMin64(.BID)
        try doTestMin64(.DPD)
        try doTestMin128(.BID)
        try doTestMin128(.DPD)
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

}
