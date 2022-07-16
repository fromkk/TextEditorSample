//
//  TextEditorViewController.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/20.
//

import Combine
import SwiftUI
import UIKit

public protocol TextEditorViewControllerDelegate: AnyObject {
    func textEditorPickCoverImage(_ textEditor: TextEditorViewController) async throws -> UIImage?
}

/// note のテキストエディタ
@MainActor
open class TextEditorViewController: UIViewController {
    public weak var delegate: TextEditorViewControllerDelegate?

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TextEditorConstant.Color.background
        navigationItem.leftBarButtonItem = closeBarButtonItem
        viewRespectsSystemMinimumLayoutMargins = false
        view.layoutMargins = .zero
        addScrollView()
        addToolbar()
        setEditorToolbarItems()
        addStackView()
        addCoverView()
        addTitleView()
        let defaultInputView = makeDefaultItemView()
        stackView.addArrangedSubview(defaultInputView)
        subscribe()
    }

    private func invalidateIntrinsicContentSizeSubViews() {
        stackView.arrangedSubviews.forEach {
            $0.invalidateIntrinsicContentSize()
        }
    }

    /// 閉じるボタン
    public lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: L10n.close, style: .plain, target: self, action: #selector(close(sender:)))
        item.accessibilityIdentifier = #function
        return item
    }()

    @objc private func close(sender _: UIBarButtonItem) {
        dismiss(animated: true)
    }

    /// スクロールビュー
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.accessibilityIdentifier = #function
        return scrollView
    }()

    private func addScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }

    /// コンテンツを全て内包するstackView
    public lazy var stackView: TextEditorStackView = {
        let stackView = TextEditorStackView(frame: view.bounds)
        stackView.delegate = self
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.accessibilityIdentifier = #function
        return stackView
    }()

    private func addStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }

    /// カバー画像を設定する
    public lazy var coverView: TextEditorCoverView = {
        let coverView = TextEditorCoverView()
        coverView.delegate = self
        coverView.accessibilityIdentifier = #function
        return coverView
    }()

    private lazy var coverViewHasImageHeightConstraint = coverView.heightAnchor.constraint(equalTo: coverView.widthAnchor, multiplier: 196 / 375)
    private lazy var coverViewNoImageHeightConstraint = coverView.heightAnchor.constraint(equalTo: coverView.widthAnchor, multiplier: 80 / 375)

    private func addCoverView() {
        coverView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(coverView)
        coverViewNoImageHeightConstraint.isActive = true
    }

    /// タイトルを入力
    public lazy var titleView: TextEditorTitleView = {
        let titleView = TextEditorTitleView()
        titleView.accessibilityIdentifier = #function
        return titleView
    }()

    private func addTitleView() {
        stackView.addArrangedSubview(titleView)
    }

    private func makeDefaultItemView() -> TextEditorItemView {
        let itemView = TextEditorItemView()
        let item = TextEditorTextItem(delegate: self)
        itemView.item = item
        return itemView
    }

    fileprivate let textViewPlaceholder: String? = [
        L10n.TextEditor.Body.placeholder0,
        L10n.TextEditor.Body.placeholder1
    ].randomElement()

    public lazy var toolbar: TextEditorToolbar = {
        let toolbar = TextEditorToolbar()
        toolbar.keyboardItemDelegate = self
        toolbar.closeKeyboardButton.addAction(.init { [weak self] _ in
            self?.view.endEditing(true)
        }, for: .primaryActionTriggered)
        toolbar.accessibilityIdentifier = #function
        return toolbar
    }()

    private func addToolbar() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50),
            toolbar.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            toolbarBottomConstraint
        ])
    }

    private lazy var toolbarBottomConstraint: NSLayoutConstraint = {
        if #available(iOS 15.0, *) {
            return view.keyboardLayoutGuide.topAnchor.constraint(equalTo: toolbar.bottomAnchor)
        } else {
            return view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor)
        }
    }()

    public lazy var editorToolbarItems: [KeyboardItem] = [
        BoldKeyboardItem(type: .custom)
    ] {
        didSet {
            setEditorToolbarItems()
        }
    }

    private func setEditorToolbarItems() {
        toolbar.items = editorToolbarItems
    }

    override open var keyCommands: [UIKeyCommand]? {
        if #available(iOS 15.0, *) {
            return super.keyCommands
        } else {
            var result = super.keyCommands ?? []
            result.append(contentsOf: toolbar.keyCommands ?? [])
            return result
        }
    }

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if toolbar.canPerformAction(action, withSender: sender) {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    override open func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        toolbar.target(forAction: action, withSender: sender)
    }

    // MARK: - Combine

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        handleCoverViewHeightConstraint()
        handleToolbarBottomConstraint()
    }

    private func handleCoverViewHeightConstraint() {
        coverView.$image
            .map { $0 != nil }
            .sink { [weak self] hasImage in
                self?.coverViewHasImageHeightConstraint.isActive = hasImage
                self?.coverViewNoImageHeightConstraint.isActive = !hasImage
                self?.coverView.invalidateIntrinsicContentSize()
            }
            .store(in: &cancellables)
    }

    private func handleToolbarBottomConstraint() {
        if #available(iOS 15.0, *) { return }
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap(\.keyboard)
            .sink { [weak self] keyboard in
                guard let self = self else { return }
                self.toolbarBottomConstraint.constant = keyboard.frame.height - self.view.safeAreaInsets.bottom
                UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options: keyboard.animationCurve) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap(\.keyboard)
            .sink { [weak self] keyboard in
                guard let self = self else { return }
                self.toolbarBottomConstraint.constant = 0
                UIView.animate(withDuration: keyboard.animationDuration, delay: 0, options: keyboard.animationCurve) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
}

extension TextEditorViewController: TextEditorCoverViewDelegate {
    public func coverViewDidTapPickImage(_: TextEditorCoverView) {
        pickCoverImage()
    }

    public func coverViewDidTapEdit(_: TextEditorCoverView) {
        pickCoverImage()
    }

    private func pickCoverImage() {
        Task {
            do {
                coverView.image = try await self.delegate?.textEditorPickCoverImage(self)
            } catch {
                print("error \(error.localizedDescription)")
            }
        }
    }

    public func coverViewDidTapDelete(_ coverView: TextEditorCoverView) {
        coverView.image = nil
    }
}

extension TextEditorViewController: TextEditorTextViewDelegate {
    public func textViewAdd(_ textView: TextEditorTextView) {
        let nextItemView = makeDefaultItemView()
        if let index = stackView.arrangedSubviews.firstIndex(where: { itemView in
            guard let itemView = itemView as? TextEditorItemView else { return false }
            return itemView.contentView?.isEqual(textView) ?? false
        }) {
            stackView.insertArrangedSubview(nextItemView, at: index + 1)
        } else {
            stackView.addArrangedSubview(nextItemView)
        }
        (nextItemView.contentView as? TextEditorTextView)?.becomeFirstResponder()
    }

    public func textView(_ textView: TextEditorTextView, separateAt range: NSRange) {
        let location = range.location + range.length
        let length = textView.attributedText.length - location
        let cutRange = NSRange(location: location, length: length)
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let cutText = attributedString.attributedSubstring(from: cutRange)
        attributedString.replaceCharacters(in: cutRange, with: "")
        textView.attributedText = attributedString
        textView.removeLastNewLine()

        let afterItemView = makeDefaultItemView()
        (afterItemView.contentView as? TextEditorTextView)?.attributedText = cutText

        if let index = stackView.arrangedSubviews.firstIndex(where: {
            guard let itemView = $0 as? TextEditorItemView else { return false }
            return itemView.contentView?.isEqual(textView) ?? false
        }) {
            stackView.insertArrangedSubview(afterItemView, at: index + 1)
        }
        (afterItemView.contentView as? TextEditorTextView)?.becomeFirstResponder()
        (afterItemView.contentView as? TextEditorTextView)?.selectedRange = NSRange(location: 0, length: 0)
    }

    public func textViewDeleteIfNeeded(_ textView: TextEditorTextView) {
        guard let index = stackView.arrangedSubviews.firstIndex(where: { itemView in
            guard let itemView = itemView as? TextEditorItemView else { return false }
            return itemView.contentView?.isEqual(textView) ?? false
        }) else {
            return
        }
        guard
            let previousItemView = stackView.arrangedSubviews[index - 1] as? TextEditorItemView,
            let textView = previousItemView.contentView as? TextEditorTextView
        else {
            return
        }
        textView.becomeFirstResponder()

        let itemView = stackView.arrangedSubviews[index]
        stackView.removeArrangedSubview(itemView)
        itemView.removeFromSuperview()
    }
}

extension TextEditorViewController: TextEditorStackViewDelegate {
    public func stackViewDidAdd(_: TextEditorStackView, arrangedSubview _: UIView) {
        updatePlaceholderForFirstTextView()
    }

    public func stackViewDidInsert(_: TextEditorStackView, arrangedSubview _: UIView, at _: Int) {
        updatePlaceholderForFirstTextView()
    }

    public func stackViewDidRemove(_: TextEditorStackView, arrangedSubview _: UIView) {
        updatePlaceholderForFirstTextView()
    }

    private func updatePlaceholderForFirstTextView() {
        stackView.arrangedSubviews
            .compactMap { $0 as? TextEditorItemView }
            .enumerated()
            .forEach { offset, element in
                guard let textView = element.contentView as? TextEditorTextView else { return }
                if offset == 0 {
                    textView.placeholderText = textViewPlaceholder
                } else {
                    textView.placeholderText = nil
                }
            }
    }
}

extension TextEditorViewController: KeyboardItemDelegate {
    public var currentTextView: UITextView? {
        stackView.arrangedSubviews
            .compactMap { ($0 as? TextEditorItemView)?.contentView as? UITextView }
            .first(where: { $0.isFirstResponder })
    }
}
