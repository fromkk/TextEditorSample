//
//  RemoveTextConverter.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/22.
//

import UIKit

public final class RemoveTextConverter: TextEditorConverter {
    public weak var textViewDelegate: TextEditorTextViewDelegate?
    public func callAsFunction(_ textView: TextEditorTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.location == 0, range.length == 0, text.isEmpty {
            if textView.text.isEmpty {
                textViewDelegate?.textViewDeleteIfNeeded(textView)
                return false
            } else {
                textViewDelegate?.textViewJoinIfNeeded(textView)
                return false
            }
        } else {
            return true
        }
    }
}
