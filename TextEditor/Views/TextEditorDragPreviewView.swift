//
//  TextEditorDragPreviewView.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/17.
//

import UIKit

final class TextEditorDragPreviewView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private lazy var heightConstraint: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: 3)

    private lazy var setUp: () -> Void = {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.isActive = true
        addLineView()
        return {}
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = TextEditorConstant.Color.point
        view.accessibilityIdentifier = #function
        return view
    }()

    private func addLineView() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 16),
            lineView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
}
