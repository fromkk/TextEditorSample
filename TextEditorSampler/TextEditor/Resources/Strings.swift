// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
    /// 閉じる
    public static let close = L10n.tr("Localizable", "close")
    /// キーボードを閉じる
    public static let closeKeyboard = L10n.tr("Localizable", "close_keyboard")
    /// カバー画像
    public static let coverImage = L10n.tr("Localizable", "cover_image")
    /// 削除
    public static let delete = L10n.tr("Localizable", "delete")
    /// 編集
    public static let edit = L10n.tr("Localizable", "edit")
    /// 画像を選択
    public static let pickImage = L10n.tr("Localizable", "pick_image")
    /// タイトル
    public static let title = L10n.tr("Localizable", "title")

    public enum TextEditor {
        public enum Body {
            /// ご自由にお書きください。
            public static let placeholder0 = L10n.tr("Localizable", "text_editor.body.placeholder_0")
            /// 読んだ本の感想を書いてみませんか？
            public static let placeholder1 = L10n.tr("Localizable", "text_editor.body.placeholder_1")
        }
    }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable convenience_type
