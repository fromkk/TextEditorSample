//
//  RemoveTextConverterTest.swift
//  TextEditorTests
//
//  Created by Kazuya Ueoka on 2022/09/10.
//

@testable import TextEditor
import XCTest

final class RemoveTextConverterTest: XCTestCase {
    let converter = RemoveTextConverter()
    var delegate: TextEditorTextViewDelegateMock!

    override func setUp() {
        super.setUp()
        delegate = .init()
        converter.textViewDelegate = delegate
    }

    /// ブロックを削除する
    func testDeleteBlock() {
        let textVIew = TextEditorTextView()
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 0)
        XCTAssertFalse(converter.callAsFunction(textVIew, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: ""))
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 1)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 0)
    }

    /// 前のブロックと結合する
    func testJoinBlock() {
        let textVIew = TextEditorTextView()
        textVIew.text = "not empty text"
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 0)
        XCTAssertFalse(converter.callAsFunction(textVIew, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: ""))
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 1)
    }

    /// 先頭以外でテキストを削除する
    func testNotFirst() {
        let textVIew = TextEditorTextView()
        textVIew.text = "not empty text"
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 0)
        XCTAssertTrue(converter.callAsFunction(textVIew, shouldChangeTextIn: NSRange(location: 5, length: 0), replacementText: ""))
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 0)
    }

    /// そもそも削除ではない
    func testNotDelete() {
        let textVIew = TextEditorTextView()
        textVIew.text = "not empty text"
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 0)
        XCTAssertTrue(converter.callAsFunction(textVIew, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "not delete"))
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(delegate.textViewJoinIfNeededCallCount, 0)
    }
}
