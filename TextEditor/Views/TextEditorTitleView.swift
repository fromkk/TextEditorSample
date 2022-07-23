//
//  TextEditorTitleView.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import Combine
import UIKit

/// テキストエディタのタイトルを入力する
@MainActor
public final class TextEditorTitleView: UIView, UITextViewDelegate {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    @MainActor override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUp()
    }

    private lazy var setUp: () -> Void = {
        backgroundColor = TextEditorConstant.Color.background
        addTextView()
        subscribe()
        return {}
    }()

    /// タイトルを入力
    public lazy var textView: PlaceholderTextView = {
        let textView = PlaceholderTextView(frame: bounds)
        textView.placeholderText = L10n.title
        textView.font = TextEditorConstant.Font.title
        textView.textColor = TextEditorConstant.Color.normalText
        textView.textContainerInset = .zero
        textView.delegate = self
        let item = textView.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        textView.accessibilityIdentifier = #function
        return textView
    }()

    private lazy var textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: TextEditorConstant.minimumItemHeight)

    private func addTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 16),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            textViewHeightConstraint,
            bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0)
        ])
    }

    // MARK: - UITextViewDelegate

    public func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        let newLines = CharacterSet.newlines
        if let unicodeScalar = text.unicodeScalars.first, newLines.contains(unicodeScalar) {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        guard textView.text.unicodeScalars.contains(where: { CharacterSet.newlines.contains($0) }) else { return }
        let range = NSRange(location: 0, length: (textView.text as NSString).length)
        textView.text = (textView.text as NSString).replacingOccurrences(of: "\n|\r|\t", with: "", options: .regularExpression, range: range)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        NotificationCenter.default.post(name: .textViewDidChangeSelection, object: textView)
    }

    // MARK: - Combine

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        textView.publisher(for: \.contentSize)
            .map { max($0.height, TextEditorConstant.minimumItemHeight) }
            .removeDuplicates()
            .sink { [weak self] height in
                self?.textViewHeightConstraint.constant = height
                self?.invalidateIntrinsicContentSize()
            }
            .store(in: &cancellables)
    }
}
