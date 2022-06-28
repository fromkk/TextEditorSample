//
//  TextEditorToolbar.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import UIKit

public final class TextEditorToolbar: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUp()
    }

    private lazy var setUp: () -> Void = {
        backgroundColor = TextEditorConstant.Color.background
        addCloseKeyboardButton()
        addScrollView()
        addTopSeparatorView()
        return {}
    }()

    public lazy var closeKeyboardButton: UIButton = {
        let button = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(font: TextEditorConstant.Font.body)
        let image = UIImage(systemName: "keyboard.chevron.compact.down", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = TextEditorConstant.Color.normalText
        button.accessibilityIdentifier = #function
        return button
    }()

    private func addCloseKeyboardButton() {
        closeKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeKeyboardButton)
        NSLayoutConstraint.activate([
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: closeKeyboardButton.trailingAnchor, constant: 8),
            closeKeyboardButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: bounds)
        scrollView.backgroundColor = TextEditorConstant.Color.background
        scrollView.accessibilityIdentifier = #function
        return scrollView
    }()

    private func addScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            closeKeyboardButton.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8)
        ])
    }

    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = TextEditorConstant.Color.separator
        view.accessibilityIdentifier = #function
        return view
    }()

    private func addTopSeparatorView() {
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparatorView)
        NSLayoutConstraint.activate([
            topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: topSeparatorView.trailingAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: topAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 1 / traitCollection.displayScale)
        ])
    }
}
