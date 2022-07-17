//
//  TextEditorSheetItem.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/16.
//

import UIKit

open class TextEditorSheetItem: NSObject {
    var image: UIImage?
    var title: String

    public init(image: UIImage?, title: String) {
        self.image = image
        self.title = title
    }

    open func perform(for _: UIViewController) {}
}
