//
//  UIScrollView+.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/23.
//

import UIKit

extension UIScrollView {
    var visibleFrame: CGRect {
        CGRect(x: contentOffset.x, y: contentOffset.y, width: bounds.size.width, height: bounds.size.height)
    }
}
