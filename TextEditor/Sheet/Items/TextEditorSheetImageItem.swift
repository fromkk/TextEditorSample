//
//  TextEditorSheetImageItem.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/16.
//

import Photos
import PhotosUI
import UIKit
import UniformTypeIdentifiers

protocol TextEditorSheetImageItemDelegate: AnyObject {
    func sheetImageItem(_ item: TextEditorSheetImageItem, addImage image: UIImage)
    func sheetImageItem(_ item: TextEditorSheetImageItem, didFailedWith error: Error)
}

public final class TextEditorSheetImageItem: TextEditorSheetItem, PHPickerViewControllerDelegate {
    public convenience init() {
        let configuration = UIImage.SymbolConfiguration(font: TextEditorConstant.Font.subHeader)
        self.init(image: UIImage(systemName: "photo", withConfiguration: configuration), title: L10n.image)
    }

    private weak var viewController: UIViewController?

    override public func perform(for viewController: UIViewController) {
        defer {
            self.viewController = viewController
        }
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            picker.dismiss(animated: true)
            return
        }
        result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
            DispatchQueue.main.async { [weak self, weak picker] in
                defer {
                    picker?.dismiss(animated: true)
                }
                guard let self = self else { return }
                if let error = error {
                    (self.viewController as? TextEditorSheetImageItemDelegate)?.sheetImageItem(self, didFailedWith: error)
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    // something wrong...
                    return
                }
                (self.viewController as? TextEditorSheetImageItemDelegate)?.sheetImageItem(self, addImage: image)
            }
        }
    }
}
