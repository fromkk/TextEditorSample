//
//  BoldKeyboardItem.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import Combine
import UIKit

public final class BoldKeyboardItem: KeyboardItem {
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
        let configuration = UIImage.SymbolConfiguration(font: TextEditorConstant.Font.body)
        let image = UIImage(systemName: "bold", withConfiguration: configuration)
        setImage(image, for: .normal)
        accessibilityLabel = L10n.bold
        subscribe()
        return {}
    }()

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification)
            .compactMap { $0.object as? UITextView }
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
    }
}
