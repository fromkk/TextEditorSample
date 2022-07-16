//
//  TextEditorItemRepresentable.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import Combine
import UIKit

public protocol TextEditorValueRepresentable {}

@MainActor public protocol TextEditorItemRepresentable {
    /// 実際にUIとして表示するview（Valueを編集して結果を返すなどを想定）
    var contentView: UIView { get }

    /// 画面サイズが更新されたことを通知するpublisher
    var contentSizeDidChangePublisher: AnyPublisher<CGSize, Never> { get }
}

@MainActor public class TextEditorTextItem: TextEditorItemRepresentable {
    init(delegate: TextEditorTextViewDelegate?) {
        (contentView as? TextEditorTextView)?.textViewDelegate = delegate
        subscribe()
    }

    private var cancellabes: Set<AnyCancellable> = .init()

    private func subscribe() {
        (contentView as? TextEditorTextView)?.publisher(for: \.contentSize)
            .sink(receiveValue: { [weak self] size in
                let height = max(size.height, TextEditorConstant.minimumItemHeight)
                self?._contentSizeDidChangeSubject.send(CGSize(width: size.width, height: height))
            })
            .store(in: &cancellabes)
    }

    public var contentView: UIView = {
        let textView = TextEditorTextView()
        textView.font = TextEditorConstant.Font.body
        return textView
    }()

    private let _contentSizeDidChangeSubject: PassthroughSubject<CGSize, Never> = .init()

    public var contentSizeDidChangePublisher: AnyPublisher<CGSize, Never> {
        _contentSizeDidChangeSubject.eraseToAnyPublisher()
    }
}
