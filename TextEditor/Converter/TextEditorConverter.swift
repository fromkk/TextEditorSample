//
//  TextEditorConverter.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/22.
//

import UIKit

public protocol TextEditorConverter: AnyObject {
    var textViewDelegate: TextEditorTextViewDelegate? { get set }
    func callAsFunction(_ textView: TextEditorTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
}
