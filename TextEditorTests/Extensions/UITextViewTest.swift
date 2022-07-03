//
//  UITextViewTest.swift
//  TextEditorTests
//
//  Created by Ueoka Kazuya on 2022/06/23.
//

@testable import TextEditor
import XCTest

final class UITextViewTest: XCTestCase {
    func testRemoveLastNewLine() {
        XCTContext.runActivity(named: "empty") { _ in
            let text = ""
            let textView = UITextView()
            textView.text = text
            textView.removeLastNewLine()
            XCTAssertEqual(text, textView.text)
        }

        XCTContext.runActivity(named: "no new line") { _ in
            let text = "hello world"
            let textView = UITextView()
            textView.text = text
            textView.removeLastNewLine()
            XCTAssertEqual(text, textView.text)
        }

        XCTContext.runActivity(named: "have last new line") { _ in
            let text = "hello world\n"
            let textView = UITextView()
            textView.text = text
            textView.removeLastNewLine()
            XCTAssertEqual("hello world", textView.text)
        }

        XCTContext.runActivity(named: "have new line in the middle") { _ in
            let text = "hello\nworld"
            let textView = UITextView()
            textView.text = text
            textView.removeLastNewLine()
            XCTAssertEqual(text, textView.text)
        }
    }
}
