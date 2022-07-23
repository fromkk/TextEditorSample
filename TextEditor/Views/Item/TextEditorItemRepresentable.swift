//
//  TextEditorItemRepresentable.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/21.
//

import Combine
import UIKit

public protocol TextEditorValueRepresentable {}

@MainActor public protocol TextEditorItemRepresentable {
    /// 実際にUIとして表示するview（Valueを編集して結果を返すなどを想定）
    var contentView: UIView { get }

    /// 画面サイズが更新されたことを通知するpublisher
    var contentSizeDidChangePublisher: AnyPublisher<CGSize, Never> { get }
}
