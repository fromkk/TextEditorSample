//
//  TextEditorItemView.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import Combine
import UIKit

@MainActor public final class TextEditorItemView: UIView {
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
        replaceContentView()
        return {}
    }()

    public var item: TextEditorItemRepresentable = TextEditorTextItem() {
        didSet {
            replaceContentView()
        }
    }

    private func resetContentView() {
        contentView?.removeFromSuperview()
        contentView = nil
        contentViewConstraints.forEach { $0.isActive = false }
        contentViewConstraints = []
        cancellables.removeAll()
        contentViewHeightConstraint = nil
    }

    private func replaceContentView() {
        resetContentView()
        addContentView(item.contentView)
        subscribeContentSize()
    }

    public var contentView: UIView?

    private lazy var contentViewConstraints: [NSLayoutConstraint] = []
    private var contentViewHeightConstraint: NSLayoutConstraint?

    private func addContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: TextEditorConstant.minimumItemHeight)
        contentViewConstraints = [
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            view.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8),
            heightConstraint
        ]
        NSLayoutConstraint.activate(contentViewConstraints)
        contentViewHeightConstraint = heightConstraint
    }

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribeContentSize() {
        item.contentSizeDidChangePublisher
            .removeDuplicates()
            .sink { [weak self] size in
                self?.contentViewHeightConstraint?.constant = size.height
                self?.invalidateIntrinsicContentSize()
            }
            .store(in: &cancellables)
    }
}
