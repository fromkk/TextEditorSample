//
//  TextEditorCoverView.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/20.
//

import Combine
import SwiftUI
import UIKit

/// @mockable
public protocol TextEditorCoverViewDelegate: AnyObject {
    /// 画像選択ボタンをタップした際に呼ばれる
    /// - Parameter coverView: TextEditorCoverView
    func coverViewDidTapPickImage(_ coverView: TextEditorCoverView)

    /// 画像編集ボタンをタップした際に呼ばれる
    /// - Parameter coverView: TextEditorCoverView
    func coverViewDidTapEdit(_ coverView: TextEditorCoverView)

    /// 画像削除ボタンをタップした際に呼ばれる
    /// - Parameter coverView: TextEditorCoverView
    func coverViewDidTapDelete(_ coverView: TextEditorCoverView)
}

/// テキストエディタのカバー画像を設定する画面
/// 画像の選択、編集、削除ができます
@MainActor
public final class TextEditorCoverView: UIView {
    public weak var delegate: TextEditorCoverViewDelegate?

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
        addImageView()
        addPickButton()
        addDeleteButton()
        addEditButton()
        subscribe()
        return {}
    }()

    /// 選択した画像を表示する
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.backgroundColor = TextEditorConstant.Color.background
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = TextEditorConstant.Color.placeholderText
        imageView.accessibilityLabel = L10n.coverImage
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.accessibilityIdentifier = #function
        return imageView
    }()

    private func addImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
    }

    /// 画像を選択するボタン
    public lazy var pickButton: UIButton = {
        let button = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 48))
        let image: UIImage?
        if #available(iOS 15.0, *) {
            image = UIImage(systemName: "photo.circle.fill", withConfiguration: configuration)
        } else {
            image = UIImage(systemName: "photo.fill", withConfiguration: configuration)
        }
        button.setImage(image, for: .normal)
        button.tintColor = TextEditorConstant.Color.placeholderText
        button.imageView?.contentMode = .scaleAspectFit
        button.addAction(.init { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.coverViewDidTapPickImage(self)
        }, for: .primaryActionTriggered)
        button.accessibilityLabel = L10n.pickImage
        button.accessibilityIdentifier = #function
        return button
    }()

    private func addPickButton() {
        pickButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickButton)
        NSLayoutConstraint.activate([
            pickButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            pickButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            bottomAnchor.constraint(greaterThanOrEqualTo: pickButton.bottomAnchor, constant: 16),
            pickButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            pickButton.widthAnchor.constraint(equalToConstant: 48),
            pickButton.heightAnchor.constraint(equalTo: pickButton.widthAnchor)
        ])
    }

    /// 既に画像を選択済みの場合に表示する編集ボタン
    public lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 48))
        let image = UIImage(systemName: "pencil.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = TextEditorConstant.Color.placeholderText
        button.imageView?.contentMode = .scaleAspectFit
        button.addAction(.init { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.coverViewDidTapEdit(self)
        }, for: .primaryActionTriggered)
        button.accessibilityLabel = L10n.edit
        button.accessibilityIdentifier = #function
        return button
    }()

    private func addEditButton() {
        editButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editButton)
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: 8),
            editButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            bottomAnchor.constraint(greaterThanOrEqualTo: editButton.bottomAnchor, constant: 16),
            editButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 48),
            editButton.heightAnchor.constraint(equalTo: editButton.widthAnchor)
        ])
    }

    /// 既に画像を選択済みの場合に表示する削除ボタン
    public lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 48))
        let image = UIImage(systemName: "trash.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray3
        button.imageView?.contentMode = .scaleAspectFit
        button.addAction(.init { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.coverViewDidTapDelete(self)
        }, for: .primaryActionTriggered)
        button.accessibilityLabel = L10n.delete
        button.accessibilityIdentifier = #function
        return button
    }()

    private func addDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 16),
            deleteButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            bottomAnchor.constraint(greaterThanOrEqualTo: deleteButton.bottomAnchor, constant: 16),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 48),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])
    }

    @Published var image: UIImage?

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        $image.assign(to: \.image, on: imageView).store(in: &cancellables)
        let imageIsNilPublisher = $image.map { $0 == nil }.eraseToAnyPublisher()
        // pickButton
        imageIsNilPublisher.map { !$0 }.assign(to: \.isHidden, on: pickButton).store(in: &cancellables)
        // editButton
        imageIsNilPublisher.assign(to: \.isHidden, on: editButton).store(in: &cancellables)
        // deleteButton
        imageIsNilPublisher.assign(to: \.isHidden, on: deleteButton).store(in: &cancellables)
        // imageView
        imageIsNilPublisher.assign(to: \.isHidden, on: imageView).store(in: &cancellables)
    }
}

struct TextEditorCoverView_View: UIViewRepresentable {
    typealias UIViewType = TextEditorCoverView
    let image: UIImage?

    func makeUIView(context _: Context) -> TextEditorCoverView {
        TextEditorCoverView()
    }

    func updateUIView(_ uiView: TextEditorCoverView, context _: Context) {
        uiView.image = image
    }
}

struct TextEditorCoverView_Preview: PreviewProvider {
    static var previews: some View {
        TextEditorCoverView_View(image: nil)
        TextEditorCoverView_View(image: UIImage())
    }
}
