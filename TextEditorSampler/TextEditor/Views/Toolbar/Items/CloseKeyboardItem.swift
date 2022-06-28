//
//  CloseKeyboardItem.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import Combine
import UIKit

final class CloseKeyboardItem: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUp()
    }

    private lazy var setUp: () -> Void = {
        let configuration = UIImage.SymbolConfiguration(font: TextEditorConstant.Font.body)
        let image = UIImage(systemName: "keyboard.chevron.compact.down", withConfiguration: configuration)
        setImage(image, for: .normal)
        accessibilityLabel = L10n.closeKeyboard
        subscribe()
        isEnabled = false
        return {}
    }()

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        publisher(for: \.isEnabled)
            .sink { [weak self] isEnabled in
                if isEnabled {
                    self?.tintColor = TextEditorConstant.Color.normalText
                } else {
                    self?.tintColor = TextEditorConstant.Color.disabled
                }
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification)
            .compactMap { $0.object as? PlaceholderTextView }
            .filter { [weak self] in
                $0.window?.windowScene?.isEqual(self?.window?.windowScene) ?? false
            }
            .map { _ in true }
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UITextView.textDidEndEditingNotification)
            .compactMap { $0.object as? PlaceholderTextView }
            .filter { [weak self] in
                $0.window?.windowScene?.isEqual(self?.window?.windowScene) ?? false
            }
            .map { _ in false }
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)
    }
}
