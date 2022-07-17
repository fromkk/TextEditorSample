//
//  TextEditorSheetViewController.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/16.
//

import UIKit

public protocol TextEditorSheetViewControllerDelegate: AnyObject {
    var textEditorViewController: TextEditorViewController? { get }
}

public final class TextEditorSheetViewController: UIViewController, UICollectionViewDelegate {
    public weak var delegate: TextEditorSheetViewControllerDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TextEditorConstant.Color.background
        viewRespectsSystemMinimumLayoutMargins = false
        view.layoutMargins = .zero
        addCollectionView()
        apply()
    }

    public lazy var collectionViewLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 4), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        group.interItemSpacing = .fixed(8)
        group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        return UICollectionViewCompositionalLayout(section: section)
    }()

    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = TextEditorConstant.Color.background
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = #function
        return collectionView
    }()

    private func addCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
    }

    public let cellRegistration = UICollectionView.CellRegistration<TextEditorSheetCell, TextEditorSheetItem>(handler: { cell, _, itemIdentifier in
        cell.imageView.image = itemIdentifier.image
        cell.titleLabel.text = itemIdentifier.title
    })

    public enum Section {
        case list
    }

    public typealias Item = TextEditorSheetItem

    public lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        }
        return dataSource
    }()

    public var items: [Item] = [TextEditorSheetImageItem()] {
        didSet {
            apply()
        }
    }

    private func apply() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.list])
        snapshot.appendItems(items, toSection: .list)
        dataSource.apply(snapshot)
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            guard
                let self = self,
                let itemIdentifier = self.dataSource.itemIdentifier(for: indexPath),
                let viewController = self.delegate?.textEditorViewController
            else {
                return
            }
            itemIdentifier.perform(for: viewController)
        }
    }
}
