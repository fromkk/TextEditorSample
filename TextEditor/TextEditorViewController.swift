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
        configureDrop()
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

    /// 本文を入力
    /// - Returns: TextEditorItemView
    func makeDefaultItemView() -> TextEditorItemView {
        let itemView = TextEditorItemView()
        itemView.delegate = self
        let item = TextEditorTextItem(delegate: self)
        itemView.item = item
        return itemView
    }

    /// 画像を入力
    /// - Parameter image: 表示する画像
    /// - Returns: TextEditorItemView
    func makeImageItem(_ image: UIImage) -> TextEditorItemView {
        let itemView = TextEditorItemView()
        itemView.delegate = self
        let item = TextEditorImageItem()
        item.image = image
        itemView.item = item
        return itemView
    }

    /// 現在選択されているview
    var currentItemView: TextEditorItemView? {
        stackView.arrangedSubviews.first { itemView in
            guard
                let itemView = itemView as? TextEditorItemView,
                let textView = itemView.contentView as? TextEditorTextView,
                textView.isFirstResponder
            else {
                return false
            }
            return true
        } as? TextEditorItemView
    }

    /// 本文入力欄を最後に追加する（最後がテキスト入力ではない場合）
    func addTextItemViewIfNeeded() {
        if
            let lastView = stackView.arrangedSubviews.last as? TextEditorItemView,
            lastView.contentView is TextEditorTextView
        {
            return
        }
        let itemView = makeDefaultItemView()
        stackView.addArrangedSubview(itemView)
    }

    /// placeholderのテキスト
    let textViewPlaceholder: String? = [
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
            toolbar.heightAnchor.constraint(equalToConstant: TextEditorConstant.toolbarHeight),
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

    var dragPreviewImageView: UIImageView?

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

    func scrollTo(_ view: UIView) {
        if let textView = view as? UITextView, let position = textView.selectedTextRange?.end {
            let bounds = textView.caretRect(for: position)
            let rect = textView.convert(bounds, to: scrollView)
            guard !scrollView.visibleFrame.contains(rect) else { return }
            scrollView.setContentOffset(CGPoint(x: 0, y: rect.maxY + TextEditorConstant.toolbarHeight - scrollView.bounds.size.height), animated: true)
        } else {
            let rect = view.convert(view.bounds, to: scrollView)
            guard !scrollView.visibleFrame.contains(rect) else { return }
            scrollView.setContentOffset(CGPoint(x: 0, y: rect.maxY + TextEditorConstant.toolbarHeight - scrollView.bounds.size.height), animated: true)
        }
    }

    // MARK: - Combine

    var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        handleCoverViewHeightConstraint()
        handleToolbarBottomConstraint()
        handleScrollForTextViewDidBeginEditing()
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

    private func handleScrollForTextViewDidBeginEditing() {
        NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification)
            .compactMap { $0.object as? UITextView }
            .filter { [weak self] in self?.view.window?.windowScene?.isEqual($0.window?.windowScene) ?? false }
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink { [weak self] textView in
                self?.scrollTo(textView)
            }
            .store(in: &cancellables)
    }
}
