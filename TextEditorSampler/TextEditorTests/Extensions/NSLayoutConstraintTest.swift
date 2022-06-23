//
//  NSLayoutConstraintTest.swift
//  TextEditorTests
//
//  Created by Ueoka Kazuya on 2022/06/23.
//

@testable import TextEditor
import XCTest

final class NSLayoutConstraintTest: XCTestCase {
    func testUpdatePriority() {
        let patterns: [Pattern<UILayoutPriority, UILayoutPriority>] = [
            .init(input: .defaultLow, output: .defaultLow),
            .init(input: .defaultHigh, output: .defaultHigh),
            .init(input: .required, output: .required)
        ]
        patterns.forEach {
            let constraint = NSLayoutConstraint()
            constraint.updatePriority($0.input)
            XCTAssertEqual($0.output, constraint.priority, file: $0.file, line: $0.line)
        }
    }
}
