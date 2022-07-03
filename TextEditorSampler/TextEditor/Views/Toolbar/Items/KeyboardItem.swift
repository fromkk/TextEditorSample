//
//  KeyboardItem.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/29.
//

import Combine
import UIKit

public protocol KeyboardItemDelegate: AnyObject {
    var currentTextView: UITextView? { get }
}

open class KeyboardItem: UIButton {
    public weak var delegate: KeyboardItemDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUp()
    }

    private var cancellables: Set<AnyCancellable> = .init()

    private lazy var setUp: () -> Void = {
        publisher(for: \.isEnabled)
            .sink { [weak self] isEnabled in
                if isEnabled {
                    self?.tintColor = TextEditorConstant.Color.normalText
                } else {
                    self?.tintColor = TextEditorConstant.Color.disabled
                }
            }
            .store(in: &cancellables)
        return {}
    }()
}
