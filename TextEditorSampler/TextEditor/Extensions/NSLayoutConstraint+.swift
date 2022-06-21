//
//  NSLayoutConstraint+.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func updatePriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
