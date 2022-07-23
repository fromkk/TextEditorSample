//
//  UIView+snapshot.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/23.
//

import Combine
import UIKit

public extension UIView {
    func snapshot() -> AnyPublisher<UIImage?, Never> {
        let size = bounds.size
        return Deferred { [weak self] in
            Future<UIImage?, Never> { [weak self] promise in
                DispatchQueue.main.async { [weak self] in
                    let format = UIGraphicsImageRendererFormat()
                    let renderer = UIGraphicsImageRenderer(size: size, format: format)
                    let image = renderer.image { [weak self] _ in
                        guard let self = self else { return }
                        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
                    }
                    promise(.success(image))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
