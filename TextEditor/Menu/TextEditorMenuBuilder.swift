//
//  TextEditorMenuBuilder.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/07/04.
//

import UIKit

public enum TextEditorMenuBuilder {
    public static func build(with builder: UIMenuBuilder) {
        guard builder.system == .main else { return }
        let formatMenu = UIMenu(title: L10n.format, options: .displayInline, children: [
            BoldKeyboardItem.boldKeyCommand
        ])
        builder.replace(menu: .format, with: formatMenu)
    }
}
