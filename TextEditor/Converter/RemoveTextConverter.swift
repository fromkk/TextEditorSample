//
//  RemoveTextConverter.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/22.
//

import UIKit

public final class RemoveTextConverter: TextEditorConverter {
    public weak var textViewDelegate: TextEditorTextViewDelegate?
    public func callAsFunction(_ textView: TextEditorTextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if textView.text.isEmpty, text.isEmpty {
            textViewDelegate?.textViewDeleteIfNeeded(textView)
            return false
        } else {
            return true
        }
    }
}
