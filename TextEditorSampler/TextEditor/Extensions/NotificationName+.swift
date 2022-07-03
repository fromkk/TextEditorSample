//
//  NotificationName+.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/28.
//

import Foundation

extension Notification.Name {
    static let textViewDidChangeSelection: Notification.Name = .init(rawValue: "me.note.TextEditor.TextView.DidChangeSelection")
}
