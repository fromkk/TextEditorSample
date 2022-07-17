//
//  TextEditorToolbar.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import UIKit

public final class TextEditorToolbar: UIView, PlusToolbarItemDelegate {
    public weak var keyboardItemDelegate: KeyboardItemDelegate?

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
        addPlusItem()
        addCloseKeyboardButton()
        addScrollView()
        addStackView()
        addTopSeparatorView()
        return {}
    }()

    lazy var plusItem: PlusToolbarItem = {
        let plusItem = PlusToolbarItem()
        plusItem.delegate = self
        return plusItem
    }()

    private func addPlusItem() {
        plusItem.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plusItem)
        NSLayoutConstraint.activate([
            plusItem.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            plusItem.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: plusItem.bottomAnchor, constant: 0),
            plusItem.widthAnchor.constraint(equalTo: plusItem.heightAnchor)
        ])
    }

    lazy var closeKeyboardButton: CloseKeyboardItem = {
        let button = CloseKeyboardItem(type: .custom)
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
            scrollView.leadingAnchor.constraint(equalTo: plusItem.trailingAnchor, constant: 8),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            closeKeyboardButton.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 8)
        ])
    }

    public lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()

    private func addStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }

    private var itemsConstraints: [NSLayoutConstraint] = []

    public var items: [KeyboardItem] = [] {
        didSet {
            itemsConstraints.forEach { $0.isActive = false }
            itemsConstraints = []
            items.forEach {
                $0.delegate = keyboardItemDelegate
                $0.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview($0)
                itemsConstraints.append(contentsOf: [
                    $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
                ])
            }
            NSLayoutConstraint.activate(itemsConstraints)
        }
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

    override public var keyCommands: [UIKeyCommand]? {
        if #available(iOS 15.0, *) {
            return super.keyCommands
        } else {
            var result = super.keyCommands ?? []
            result = items.reduce(into: result) { partialResult, item in
                partialResult.append(contentsOf: item.keyCommands ?? [])
            }
            return result
        }
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !items.filter({ $0.canPerformAction(action, withSender: sender) }).isEmpty {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    override public func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        items.compactMap { $0.target(forAction: action, withSender: sender) }.first
    }

    // MARK: - PlusToolbarItemDelegate

    public var textEditorViewController: TextEditorViewController? {
        keyboardItemDelegate?.textEditorViewController
    }
}
