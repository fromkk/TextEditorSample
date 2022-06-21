//
//  PlaceholderTextView.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import Combine
import SwiftUI
import UIKit

/// placeholderの表示をサポートしたtextView
@MainActor
open class PlaceholderTextView: UITextView {
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    @MainActor override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUp()
    }

    private lazy var setUp: () -> Void = {
        backgroundColor = TextEditorConstant.Color.background
        addPlaceholderLabel()
        subscribe()
        return {}
    }()

    override open var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }

    /// placeholderのテキスト
    @Published public var placeholderText: String?

    /// placeholderの文字色
    @Published public var placeholderTextColor: UIColor = TextEditorConstant.Color.placeholderText

    /// placeholderを表示するラベル
    public lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = placeholderText
        label.textColor = placeholderTextColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.isUserInteractionEnabled = false
        label.accessibilityIdentifier = #function
        return label
    }()

    private func addPlaceholderLabel() {
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: placeholderLabel.trailingAnchor, constant: 0),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])
    }

    // MARK: - Combine

    private lazy var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        $placeholderText.assign(to: \.text, on: placeholderLabel).store(in: &cancellables)
        $placeholderTextColor.assign(to: \.textColor, on: placeholderLabel).store(in: &cancellables)
        NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification, object: self)
            .map { _ in true }
            .assign(to: \.isHidden, on: placeholderLabel)
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UITextView.textDidEndEditingNotification, object: self)
            .compactMap { $0.object as? PlaceholderTextView }
            .sink { textView in
                textView.placeholderLabel.isHidden = !textView.text.isEmpty
            }
            .store(in: &cancellables)
    }
}

struct PlaceholderTextView_View: UIViewRepresentable {
    typealias UIViewType = PlaceholderTextView
    let placeholder: String?

    func makeUIView(context _: Context) -> PlaceholderTextView {
        PlaceholderTextView()
    }

    func updateUIView(_ uiView: PlaceholderTextView, context _: Context) {
        uiView.placeholderText = placeholder
    }
}

struct PlaceholderTextView_Preview: PreviewProvider {
    static var previews: some View {
        PlaceholderTextView_View(placeholder: nil)
        PlaceholderTextView_View(placeholder: "placeholder text")
    }
}
