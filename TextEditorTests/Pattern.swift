//
//  Pattern.swift
//  TextEditorTests
//
//  Created by Ueoka Kazuya on 2022/06/23.
//

import Foundation

struct Pattern<Input, Output: Equatable> {
    let input: Input
    let output: Output
    let file: StaticString
    let line: UInt

    init(input: Input, output: Output, file: StaticString = #file, line: UInt = #line) {
        self.input = input
        self.output = output
        self.file = file
        self.line = line
    }
}
