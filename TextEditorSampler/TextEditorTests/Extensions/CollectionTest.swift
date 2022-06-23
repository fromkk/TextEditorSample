//
//  CollectionTest.swift
//  TextEditorTests
//
//  Created by Ueoka Kazuya on 2022/06/23.
//

@testable import TextEditor
import XCTest

final class CollectionTest: XCTestCase {
    func testCountWhere() {
        XCTContext.runActivity(named: "positive") { _ in
            let inputs = [-1, -100, 0, 1, 99, 3, 2000]
            XCTAssertEqual(4, inputs.count { $0 > 0 })
        }

        XCTContext.runActivity(named: "UPPER CASED") { _ in
            let inputs = ["a", "B", "C", "d", "E"]
            XCTAssertEqual(3, inputs.count { $0 == $0.uppercased() })
        }
    }
}
