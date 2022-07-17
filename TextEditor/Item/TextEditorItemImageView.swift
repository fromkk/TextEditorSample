//
//  TextEditorItemImageView.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/17.
//

import Combine
import UIKit

open class TextEditorItemImageView: UIImageView {
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

    private lazy var setUp: () -> Void = {
        backgroundColor = TextEditorConstant.Color.background
        return {}
    }()

    override open var bounds: CGRect {
        didSet {
            _boundsDidSetSubject.send(bounds)
        }
    }

    private let _boundsDidSetSubject: PassthroughSubject<CGRect, Never> = .init()
    public var boundsDidSetPublisher: AnyPublisher<CGRect, Never> { _boundsDidSetSubject.eraseToAnyPublisher() }
}
