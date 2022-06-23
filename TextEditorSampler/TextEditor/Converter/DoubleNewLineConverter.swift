//
//  DoubleNewLineChecker.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/22.
//

import UIKit

public final class DoubleNewLineConverter: TextEditorConverter {
    public weak var textViewDelegate: TextEditorTextViewDelegate?

    private var isLastNewLine: Bool = false

    public func callAsFunction(_ textView: TextEditorTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLineCharacterSet = CharacterSet.newlines
        let isNewLine: Bool
        if let unicodeScalar = text.unicodeScalars.first, newLineCharacterSet.contains(unicodeScalar) {
            isNewLine = true
        } else {
            isNewLine = false
        }
        defer {
            isLastNewLine = isNewLine
        }

        if isLastNewLine, isNewLine {
            if (textView.text as NSString).length == range.location {
                textViewDelegate?.textViewAdd(textView)
            } else {
                textViewDelegate?.textView(textView, separateAt: range)
            }
            textView.removeLastNewLine()
            return false
        } else {
            return true
        }
    }
}
