//
//  TextEditorCoverViewTest.swift
//  TextEditorTests
//
//  Created by Ueoka Kazuya on 2022/06/20.
//

@testable import TextEditor
import XCTest

@MainActor final class TextEditorCoverViewTest: XCTestCase {
    var coverView: TextEditorCoverView!
    var delegate: TextEditorCoverViewDelegateMock!

    @MainActor override func setUp() {
        super.setUp()
        delegate = .init()
        coverView = .init()
        coverView.delegate = delegate
    }

    func testPick() {
        XCTAssertEqual(delegate.coverViewDidTapPickImageCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapEditCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapDeleteCallCount, 0)
        coverView.pickButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(delegate.coverViewDidTapPickImageCallCount, 1)
        XCTAssertEqual(delegate.coverViewDidTapEditCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapDeleteCallCount, 0)
    }

    func testEdit() {
        XCTAssertEqual(delegate.coverViewDidTapPickImageCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapEditCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapDeleteCallCount, 0)
        coverView.editButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(delegate.coverViewDidTapPickImageCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapEditCallCount, 1)
        XCTAssertEqual(delegate.coverViewDidTapDeleteCallCount, 0)
    }

    func testDelete() {
        XCTAssertEqual(delegate.coverViewDidTapPickImageCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapEditCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapDeleteCallCount, 0)
        coverView.deleteButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(delegate.coverViewDidTapPickImageCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapEditCallCount, 0)
        XCTAssertEqual(delegate.coverViewDidTapDeleteCallCount, 1)
    }
}
