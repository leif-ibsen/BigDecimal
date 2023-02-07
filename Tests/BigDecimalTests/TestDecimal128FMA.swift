//
//  TestDecimal128FMA.swift
//  BigDecimalTests
//
//  Created by Leif Ibsen on 09/09/2021.
//

//
// Test cases from General Decimal Arithmetic - speleotrove.com
//

import XCTest

class TestDecimal128FMA: XCTestCase {

    override func setUpWithError() throws {
        BigDecimal.NaNFlag = false
    }

    override func tearDownWithError() throws {
        XCTAssertFalse(BigDecimal.NaNFlag)
    }

    struct testa {

        let a: String
        let b: String
        let c: String
        let x: String

        init(_ a: String, _ b: String, _ c: String, _ x: String) {
            self.a = a
            self.b = b
            self.c = c
            self.x = x
        }
    }

    let testsa: [testa] = [
        testa("1", "1", "1", "2"),
        testa("25.2", "63.6", "-438", "1164.72"),
        testa("0.301", "0.380", "334", "334.114380"),
        testa("49.2", "-4.8", "23.3", "-212.86"),
        testa("4.22", "0.079", "-94.6", "-94.26662"),
        testa("903", "0.797", "0.887", "720.578"),
        testa("6.13", "-161", "65.9", "-921.03"),
        testa("28.2", "727", "5.45", "20506.85"),
        testa("4", "605", "688", "3108"),
        testa("93.3", "0.19", "0.226", "17.953"),
        testa("0.169", "-341", "5.61", "-52.019"),
        testa("-72.2", "30", "-51.2", "-2217.2"),
        testa("-0.409", "13", "20.4", "15.083"),
        testa("317", "77.0", "19.0", "24428.0"),
        testa("47", "6.58", "1.62", "310.88"),
        testa("1.36", "0.984", "0.493", "1.83124"),
        testa("72.7", "274", "1.56", "19921.36"),
        testa("335", "847", "83", "283828"),
        testa("666", "0.247", "25.4", "189.902"),
        testa("-3.87", "3.06", "78.0", "66.1578"),
        testa("0.742", "192", "35.6", "178.064"),
        testa("-91.6", "5.29", "0.153", "-484.411"),
        testa("2", "2", "0e+6144", "4"),
        testa("2", "3", "0e+6144", "6"),
        testa("5", "1", "0e+6144", "5"),
        testa("5", "2", "0e+6144", "10"),
        testa("1.20", "2", "0e+6144", "2.40"),
        testa("1.20", "0", "0e+6144", "0.00"),
        testa("1.20", "-2", "0e+6144", "-2.40"),
        testa("-1.20", "2", "0e+6144", "-2.40"),
        testa("-1.20", "0", "0e+6144", "0.00"),
        testa("-1.20", "-2", "0e+6144", "2.40"),
        testa("5.09", "7.1", "0e+6144", "36.139"),
        testa("2.5", "4", "0e+6144", "10.0"),
        testa("2.50", "4", "0e+6144", "10.00"),
        testa("1.23456789", "1.0000000000000000000000000000", "0e+6144", "1.234567890000000000000000000000000"),
        testa("2.50", "4", "0e+6144", "10.00"),
        testa("9.99999999999999999", "9.99999999999999999", "0e+6144", "99.99999999999999980000000000000000"),
        testa("9.99999999999999999", "-9.99999999999999999", "0e+6144", "-99.99999999999999980000000000000000"),
        testa("-9.99999999999999999", "9.99999999999999999", "0e+6144", "-99.99999999999999980000000000000000"),
        testa("-9.99999999999999999", "-9.99999999999999999", "0e+6144", "99.99999999999999980000000000000000"),
    ]

    func test1() throws {
        for t in testsa {
            let a = BigDecimal(t.a)
            let b = BigDecimal(t.b)
            let c = BigDecimal(t.c)
            let x = c.fma(a, b, Rounding.decimal128)
            XCTAssertEqual(x.asString(), t.x)
        }
    }

    struct testb {

        let a: String
        let b: String
        let c: String
        let fused: String
        let notfused: String

        init(_ a: String, _ b: String, _ c: String, _ fused: String, _ notfused: String) {
            self.a = a
            self.b = b
            self.c = c
            self.fused = fused
            self.notfused = notfused
        }
    }
    
    let testsb: [testb] = [
        testb("68537985861355864457.5694", "6565875762972086605.85969", "35892634447236753.172812",
              "4.500119002100000209469729375698779E+38", "4.500119002100000209469729375698778E+38"),
        testb("89261822344727628571.9", "6717595845654131383336.89", "5061036497288796076266.11",
              "5.996248469584594346858881620185513E+41", "5.996248469584594346858881620185514E+41"),
        testb("320506237232448685.495971", "59257597764017967.984448", "3205615239077711589912.85",
              "1.899242968678256924021594770874071E+34", "1.899242968678256924021594770874070E+34"),
        testb("220247843259112263.17995", "321392340287987979002.80", "47533279819997167655440",
              "7.078596978842809537929699954860308E+37", "7.078596978842809537929699954860309E+37"),
        testb("23880729790368880412.1449", "512947333827064719.55407", "217117438419590824502.963",
              "1.224955667581427559754106862350744E+37", "1.224955667581427559754106862350743E+37"),
        testb("2539892357016099706.4126", "-996142232667504817717435", "53682082598315949425.937",
              "-2.530094043253148806272276368579143E+42", "-2.530094043253148806272276368579144E+42"),
        testb("4546339491341624464.0804", "3768717864169205581", "83578980278690395184.620",
              "1.713387085759711954319391412788453E+37", "1.713387085759711954319391412788454E+37"),
        testb("409242119433816131.42253", "992633815166741501.477249", "70179636544416756129546",
              "4.062275663405823716411579117771548E+35", "4.062275663405823716411579117771547E+35"),
        testb("817941336593541742159684", "733867339769310729266598", "78563844650942419311830.8",
              "6.002604327732568490562249875306822E+47", "6.002604327732568490562249875306823E+47"),
        testb("387617310169161270.737532", "-5229442703414956061216.62", "57665666816652967150473.5",
              "-2.027022514381452197510103395283873E+39", "-2.027022514381452197510103395283874E+39"),
        testb("-847655845720565274701.210", "92685316564117739.83984", "22780950041376424429.5686",
              "-7.856525039803554001144089842730360E+37", "-7.856525039803554001144089842730361E+37"),
        testb("21590290365127685.3675", "7853139227576541379426.8", "-3275859437236180.761544",
              "1.695515562011520746125607502237558E+38", "1.695515562011520746125607502237559E+38"),
        testb("-974320636272862697.971586", "867109103641860247440.756", "-9775170775902454762.98",
              "-8.448422935783289219748115038014709E+38", "-8.448422935783289219748115038014710E+38"),
    ]
    
    func test2() throws {
        for t in testsb {
            let a = BigDecimal(t.a)
            let b = BigDecimal(t.b)
            let c = BigDecimal(t.c)
            let x1 = c.fma(a, b, Rounding.decimal128)
            let x2 = ((a * b).round(Rounding.decimal128) + c).round(Rounding.decimal128)
            let x3 = a.multiply(b, Rounding.decimal128).add(c, Rounding.decimal128)
            XCTAssertEqual(x1.asString(), t.fused)
            XCTAssertEqual(x2.asString(), t.notfused)
            XCTAssertEqual(x3.asString(), t.notfused)
        }
    }

}
