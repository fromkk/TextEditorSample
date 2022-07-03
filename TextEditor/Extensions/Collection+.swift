//
//  Collection+.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/23.
//

import Foundation

extension Collection {
    func count(where predicate: (Element) -> Bool) -> Int {
        reduce(into: 0) { partialResult, element in
            if predicate(element) {
                partialResult += 1
            }
        }
    }
}
