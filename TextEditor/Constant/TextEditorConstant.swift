//
//  TextEditorConstant.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import UIKit

public enum TextEditorConstant {
    public enum Color {
        public static var background: UIColor = .systemBackground
        public static var normalText: UIColor = .label
        public static var placeholderText: UIColor = .systemGray3
        public static var separator: UIColor = .systemGray4
        public static var disabled: UIColor = .systemGray5
    }

    public enum Font {
        public static var title: UIFont = .preferredFont(forTextStyle: .title2)
        public static var header: UIFont = .preferredFont(forTextStyle: .title2)
        public static var subHeader: UIFont = .preferredFont(forTextStyle: .title3)
        public static var body: UIFont = .preferredFont(forTextStyle: .body)
        public static var caption: UIFont = .preferredFont(forTextStyle: .callout)
    }

    public static var minimumItemHeight: CGFloat = 32
}
