//
//  BoldKeyboardItem.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import Combine
import UIKit

public final class BoldKeyboardItem: KeyboardItem {
    public static var boldKeyCommand = UIKeyCommand(action: #selector(BoldKeyboardItem.toggleBoldface(_:)), input: "b", modifierFlags: [.command], discoverabilityTitle: L10n.bold)

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
        isEnabled = false
        let configuration = UIImage.SymbolConfiguration(font: TextEditorConstant.Font.body)
        let image = UIImage(systemName: "bold", withConfiguration: configuration)
        setImage(image, for: .normal)
        accessibilityLabel = L10n.bold
        addTarget(self, action: #selector(toggleBoldface(_:)), for: .primaryActionTriggered)
        subscribe()
        return {}
    }()

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification)
            .compactMap { [weak self] _ in self?.delegate?.currentTextView }
            .filter { [weak self] in $0.window?.windowScene?.isEqual(self?.window?.windowScene) ?? false }
            .map { _ in true }
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UITextView.textDidEndEditingNotification)
            .compactMap { $0.object as? UITextView }
            .filter { [weak self] in $0.window?.windowScene?.isEqual(self?.window?.windowScene) ?? false }
            .map { _ in false }
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: .textViewDidChangeSelection)
            .compactMap { $0.object as? UITextView }
            .sink { [weak self] textView in
                guard let self = self else { return }
                self.isSelected = self.isBoldSelected(in: textView)
            }
            .store(in: &cancellables)
    }

    private func isBoldSelected(in textView: UITextView) -> Bool {
        var result = false
        textView.attributedText.enumerateAttributes(in: textView.selectedRange, options: [.longestEffectiveRangeNotRequired]) { attributes, _, _ in
            let font = attributes[.font] as? UIFont
            let isBold = font?.isBold ?? false
            if isBold {
                result = true
            }
        }
        return result
    }

    @objc override public func toggleBoldface(_: Any?) {
        guard let textView = delegate?.currentTextView else { return }
        let selectedRange = textView.selectedRange
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        if isBoldSelected(in: textView) {
            attributedString.addAttribute(.font, value: TextEditorConstant.Font.body, range: selectedRange)
        } else {
            attributedString.addAttribute(.font, value: TextEditorConstant.Font.body.bold(), range: selectedRange)
        }
        textView.attributedText = attributedString
        textView.selectedRange = selectedRange
    }

    override public var keyCommands: [UIKeyCommand]? {
        if #available(iOS 15.0, *) {
            return super.keyCommands
        } else {
            var result = super.keyCommands ?? []
            result.append(Self.boldKeyCommand)
            return result
        }
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == Self.boldKeyCommand.action {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    override public func target(forAction action: Selector, withSender _: Any?) -> Any? {
        if action == Self.boldKeyCommand.action {
            return self
        } else {
            return nil
        }
    }
}
