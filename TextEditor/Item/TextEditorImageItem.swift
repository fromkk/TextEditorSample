//
//  TextEditorImageItem.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/16.
//

import Combine
import UIKit

@MainActor public final class TextEditorImageItem: TextEditorItemRepresentable {
    public init() {
        setUp()
    }

    private var cancellables: Set<AnyCancellable> = .init()

    private lazy var setUp: () -> Void = {
        guard let boundsDidSetPublisher = (contentView as? TextEditorItemImageView)?.boundsDidSetPublisher else {
            return {}
        }

        $image
            .combineLatest(boundsDidSetPublisher) { ($0, $1) }
            .sink { [weak self] args in
                let image = args.0
                let bounds = args.1
                (self?.contentView as? UIImageView)?.image = image
                guard let self = self, let image = image else {
                    self?._contentSizeDidChangeSubject.send(.zero)
                    return
                }
                let aspect = image.size.height / image.size.width
                let height = bounds.size.width * aspect
                self._contentSizeDidChangeSubject.send(CGSize(width: bounds.size.width, height: height))
            }
            .store(in: &cancellables)
        return {}
    }()

    public lazy var contentView: UIView = {
        let imageView = TextEditorItemImageView(frame: .null)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = #function
        return imageView
    }()

    private let _contentSizeDidChangeSubject: PassthroughSubject<CGSize, Never> = .init()
    public var contentSizeDidChangePublisher: AnyPublisher<CGSize, Never> { _contentSizeDidChangeSubject.eraseToAnyPublisher() }

    @Published public var image: UIImage?
}
