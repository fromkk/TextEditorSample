//
//  UITextView+.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/22.
//

import UIKit

extension UITextView {
    /// 最後の改行を削除する
    func removeLastNewLine() {
        guard
            let start = position(from: endOfDocument, offset: -1),
            let range = textRange(from: start, to: endOfDocument),
            let lastChar = text(in: range)?.unicodeScalars.first,
            CharacterSet.newlines.contains(lastChar)
        else {
            return
        }
        replace(range, withText: "")
    }
}
