//
//  TestData.swift
//  BigDecimalTestTests
//
//  Created by Leif Ibsen on 06/02/2023.
//

import XCTest
import BigInt

final class TestData: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    func doTest(_ x: BigDecimal) {
        XCTAssertEqual(x, BigDecimal(x.asData()))
    }

    func doTest1(_ x: BInt) {
        doTest(BigDecimal(x, 0))
        doTest(BigDecimal(x, 1))
        doTest(BigDecimal(x, -1))
        doTest(BigDecimal(x, 10))
        doTest(BigDecimal(x, -10))
        doTest(BigDecimal(x, Int.max))
        doTest(BigDecimal(x, Int.min))
        for _ in 0 ..< 10 {
            let exponent = Int.random(in: -50...50)
            doTest(BigDecimal(x, exponent))
        }
    }

    func test1() throws {
        doTest(BigDecimal.InfinityP)
        doTest(BigDecimal.InfinityN)
        doTest1(BInt(0))
        doTest1(BInt(1))
        doTest1(BInt(-1))
        for _ in 0 ..< 100 {
            doTest1(BInt(bitWidth: 100))
        }
    }

}
