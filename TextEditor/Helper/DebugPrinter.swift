//
//  DebugPrinter.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/07/04.
//

import Foundation

@resultBuilder
enum DebugPrinter {
    public static func buildBlock<T: CustomDebugStringConvertible>(
        _ component: T,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> T {
        print(file, function, line, component.debugDescription)
        return component
    }
}
