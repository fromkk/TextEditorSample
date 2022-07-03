//
//  TextEditorTextView.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import UIKit

/// @mockable
public protocol TextEditorTextViewDelegate: AnyObject {
    func textViewAdd(_ textView: TextEditorTextView)
    func textViewDeleteIfNeeded(_ textView: TextEditorTextView)
    func textView(_ textView: TextEditorTextView, separateAt range: NSRange)
}

@MainActor public final class TextEditorTextView: PlaceholderTextView, UITextViewDelegate {
    public weak var textViewDelegate: TextEditorTextViewDelegate?

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    @MainActor override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUp()
    }

    private lazy var setUp: () -> Void = {
        delegate = self
        return {}
    }()

    public var textConverters: [TextEditorConverter] = [
        RemoveTextConverter(),
        DoubleNewLineConverter()
    ]

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textConverters.allSatisfy { checker in
            guard let textView = textView as? TextEditorTextView else { return false }
            checker.textViewDelegate = textViewDelegate
            return checker(textView, shouldChangeTextIn: range, replacementText: text)
        }
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        NotificationCenter.default.post(name: .textViewDidChangeSelection, object: textView)
    }
}
