//
//  DoubleNewLineConverterTest.swift
//  TextEditorTests
//
//  Created by Kazuya Ueoka on 2022/07/09.
//

@testable import TextEditor
import XCTest

final class DoubleNewLineConverterTest: XCTestCase {
    /// ## 仕様
    /// - 通常のテキストを入力したら `true` が返る
    /// - 最初に改行を入力したらそのまま改行を入力し、`true` を返す
    /// - 次に連続で改行を入力したら新しい行を挿入して `false` を返す( `delegate.textViewAdd(_:)` が呼ばれる )
    /// - 次にテキストもしくは改行を入力したら `true` が返る
    func testAddNewLine() {
        let converter = DoubleNewLineConverter()
        let textView = TextEditorTextView()
        let delegate = TextEditorTextViewDelegateMock()
        converter.textViewDelegate = delegate

        // 通常のテキストを入力したら `true` が返る
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "こんにちは"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        textView.text = "こんにちは"

        // 最初に改行を入力したらそのまま改行を入力し、`true` を返す
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 5, length: 0), replacementText: "\n"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        textView.text = "こんにちは\n"

        // 次に連続で改行を入力したら新しい行を挿入して `false` を返す
        XCTAssertFalse(converter(textView, shouldChangeTextIn: NSRange(location: 6, length: 0), replacementText: "\n"))
        XCTAssertEqual(delegate.textViewAddCallCount, 1)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(textView.text, "こんにちは")

        // 次にテキストもしくは改行を入力したら `true` が返る
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 5, length: 0), replacementText: "\n"))
        XCTAssertEqual(delegate.textViewAddCallCount, 1)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
    }

    /// ## 仕様
    /// - 通常のテキストを入力したら `true` が返る
    /// - 最初に改行を入力したらそのまま改行を入力し、`true` を返す
    /// - 次に連続で改行を入力したら新しい行を挿入して `false` を返す()
    /// - 次にテキストもしくは改行を入力したら `true` が返る
    func testInsertNewLine() {
        let converter = DoubleNewLineConverter()
        let textView = TextEditorTextView()
        let delegate = TextEditorTextViewDelegateMock()
        converter.textViewDelegate = delegate

        // 通常のテキストを入力したら `true` が返る
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "こんにちはこんにちは"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        textView.text = "こんにちはこんにちは"

        // 最初に改行を入力したらそのまま改行を入力し、`true` を返す
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 5, length: 0), replacementText: "\n"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        textView.text = "こんにちは\nこんにちは"

        // 次に連続で改行を入力したら新しい行を挿入して `false` を返す
        XCTAssertFalse(converter(textView, shouldChangeTextIn: NSRange(location: 6, length: 0), replacementText: "\n"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 1)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        XCTAssertEqual(textView.text, "こんにちは\nこんにちは")

        // 次にテキストもしくは改行を入力したら `true` が返る
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 5, length: 0), replacementText: "\n"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 1)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
    }

    /// ## 仕様
    /// - 通常のテキストを入力したら `true` が返る
    /// - 最初に改行を入力したらそのまま改行を入力し、`true` を返す
    /// - 次にテキストを入力したら `true` が返る
    /// - 次にテキストもしくは改行を入力したら `true` が返る
    func testCancel() {
        let converter = DoubleNewLineConverter()
        let textView = TextEditorTextView()
        let delegate = TextEditorTextViewDelegateMock()
        converter.textViewDelegate = delegate

        // 通常のテキストを入力したら `true` が返る
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "こんにちは"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        textView.text = "こんにちは"

        // 最初に改行を入力したらそのまま改行を入力し、`true` を返す
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 5, length: 0), replacementText: "\n"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        textView.text = "こんにちは\n"

        // 次にテキストもしくは改行を入力したら `true` が返る
        XCTAssertTrue(converter(textView, shouldChangeTextIn: NSRange(location: 6, length: 0), replacementText: "こんにちは"))
        XCTAssertEqual(delegate.textViewAddCallCount, 0)
        XCTAssertEqual(delegate.textViewCallCount, 0)
        XCTAssertEqual(delegate.textViewDeleteIfNeededCallCount, 0)
        textView.text = "こんにちは\nこんにちは"
    }
}
