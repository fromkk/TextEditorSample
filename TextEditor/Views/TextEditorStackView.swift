//
//  TextEditorStackView.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import UIKit

public protocol TextEditorStackViewDelegate: AnyObject {
    func stackViewDidAdd(_ stackView: TextEditorStackView, arrangedSubview: UIView)
    func stackViewDidInsert(_ stackView: TextEditorStackView, arrangedSubview: UIView, at stackIndex: Int)
    func stackViewDidRemove(_ stackView: TextEditorStackView, arrangedSubview: UIView)
}

open class TextEditorStackView: UIStackView {
    public weak var delegate: TextEditorStackViewDelegate?

    override open func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        delegate?.stackViewDidAdd(self, arrangedSubview: view)
    }

    override open func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        super.insertArrangedSubview(view, at: stackIndex)
        delegate?.stackViewDidInsert(self, arrangedSubview: view, at: stackIndex)
    }

    override open func removeArrangedSubview(_ view: UIView) {
        super.removeArrangedSubview(view)
        delegate?.stackViewDidRemove(self, arrangedSubview: view)
    }
}
