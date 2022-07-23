//
//  TextEditorItemView.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import Combine
import UIKit

public protocol TextEditorItemViewDelegate: AnyObject {
    func itemView(_ itemView: TextEditorItemView, didStartDraggingAt point: CGPoint)
    func itemView(_ itemView: TextEditorItemView, didChangeDraggingAt point: CGPoint)
    func itemView(_ itemView: TextEditorItemView, didEndDraggingAt point: CGPoint)
}

@MainActor public final class TextEditorItemView: UIView {
    public weak var delegate: TextEditorItemViewDelegate?

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
        isUserInteractionEnabled = true
        backgroundColor = TextEditorConstant.Color.background
        replaceContentView()
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        tapGestureRecognizer.shouldRequireFailure(of: longPressGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressGestureRecognizer)
        return {}
    }()

    @objc private func tap(gesture _: UITapGestureRecognizer) {
        if let textView = contentView as? TextEditorTextView {
            textView.becomeFirstResponder()
        }
    }

    @objc private func longPress(gesture: UILongPressGestureRecognizer) {
        let currentPosition = gesture.location(in: gesture.view)
        switch gesture.state {
        case .began:
            delegate?.itemView(self, didStartDraggingAt: currentPosition)
        case .changed:
            delegate?.itemView(self, didChangeDraggingAt: currentPosition)
        case .ended:
            delegate?.itemView(self, didEndDraggingAt: currentPosition)
        default:
            break
        }
    }

    public var item: TextEditorItemRepresentable? {
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
        guard let item = item else { return }
        contentView = item.contentView
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
        guard let item = item else { return }
        item.contentSizeDidChangePublisher
            .map { max(TextEditorConstant.minimumItemHeight, $0.height) }
            .removeDuplicates()
            .sink { [weak self] height in
                self?.contentViewHeightConstraint?.constant = height
                self?.invalidateIntrinsicContentSize()
            }
            .store(in: &cancellables)
    }
}
