//
//  Notification+Keyboard.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import UIKit

extension Notification {
    struct Keyboard {
        public let frame: CGRect
        public let animationDuration: TimeInterval
        public let animationCurve: UIView.AnimationOptions
    }

    var keyboard: Keyboard? {
        guard let frame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let animationCurve = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return nil
        }
        return Keyboard(frame: frame, animationDuration: animationDuration, animationCurve: UIView.AnimationOptions(rawValue: animationCurve))
    }
}
