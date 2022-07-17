//
//  TextEditorTextItem.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/16.
//

import Combine
import UIKit

@MainActor public class TextEditorTextItem: TextEditorItemRepresentable {
    init(delegate: TextEditorTextViewDelegate?) {
        (contentView as? TextEditorTextView)?.textViewDelegate = delegate
        subscribe()
    }

    private var cancellabes: Set<AnyCancellable> = .init()

    private func subscribe() {
        (contentView as? TextEditorTextView)?.publisher(for: \.contentSize)
            .sink(receiveValue: { [weak self] size in
                let height = max(size.height, TextEditorConstant.minimumItemHeight)
                self?._contentSizeDidChangeSubject.send(CGSize(width: size.width, height: height))
            })
            .store(in: &cancellabes)
    }

    public lazy var contentView: UIView = {
        let textView = TextEditorTextView()
        textView.font = TextEditorConstant.Font.body
        textView.accessibilityIdentifier = #function
        return textView
    }()

    private let _contentSizeDidChangeSubject: PassthroughSubject<CGSize, Never> = .init()

    public var contentSizeDidChangePublisher: AnyPublisher<CGSize, Never> {
        _contentSizeDidChangeSubject.eraseToAnyPublisher()
    }
}
