//
//  TextEditorSheetCell.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/16.
//

import SwiftUI
import UIKit

public final class TextEditorSheetCell: UICollectionViewCell {
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
        backgroundColor = TextEditorConstant.Color.background
        addImageView()
        addTitleLabel()
        return {}
    }()

    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = #function
        return imageView
    }()

    private func addImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(greaterThanOrEqualTo: imageView.trailingAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = TextEditorConstant.Color.normalText
        label.font = TextEditorConstant.Font.caption
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.accessibilityIdentifier = #function
        return label
    }()

    private func addTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }
}

struct TextEditorSheetCell_View: UIViewRepresentable {
    let image: UIImage?
    let title: String

    typealias UIViewType = TextEditorSheetCell
    func makeUIView(context _: Context) -> TextEditorSheetCell {
        TextEditorSheetCell()
    }

    func updateUIView(_ uiView: TextEditorSheetCell, context _: Context) {
        uiView.imageView.image = image
        uiView.titleLabel.text = title
    }
}

struct TextEditorSheetCell_Preview: PreviewProvider {
    static var previews: some View {
        TextEditorSheetCell_View(image: UIImage(systemName: "photo"), title: L10n.image)
    }
}
