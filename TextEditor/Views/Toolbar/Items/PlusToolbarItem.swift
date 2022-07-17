//
//  PlusToolbarItem.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/16.
//

import UIKit

public protocol PlusToolbarItemDelegate: AnyObject {
    var textEditorViewController: TextEditorViewController? { get }
}

public final class PlusToolbarItem: UIButton, TextEditorSheetViewControllerDelegate {
    public weak var delegate: PlusToolbarItemDelegate?

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
        let image = UIImage(systemName: "plus.app", withConfiguration: configuration)
        setImage(image, for: .normal)
        addTarget(self, action: #selector(tap(sender:)), for: .primaryActionTriggered)
        return {}
    }()

    @objc private func tap(sender _: PlusToolbarItem) {
        let sheetViewController = TextEditorSheetViewController()
        sheetViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: sheetViewController)
        if #available(iOS 15.0, *), let sheet = sheetViewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 24
        }
        delegate?.textEditorViewController?.present(navigationController, animated: true)
    }

    public var textEditorViewController: TextEditorViewController? {
        delegate?.textEditorViewController
    }
}
