//
//  UIFont+.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/07/04.
//

import UIKit

public extension UIFont {
    var isBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }

    func bold() -> UIFont {
        withTraits(traits: .traitBold)
    }
}
