//
//  TextEditorViewController+ItemViewDelegate.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/23.
//

import UIKit

extension TextEditorViewController: TextEditorItemViewDelegate {
    public func itemView(_ itemView: TextEditorItemView, didStartDraggingAt point: CGPoint) {
        showDragPreviewView()
        itemView.snapshot().sink { [weak self, weak itemView] image in
            guard
                let self = self,
                let image = image,
                let itemView = itemView else { return }
            let convertedPoint = itemView.convert(point, to: self.view)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(
                x: convertedPoint.x - image.size.width / 4,
                y: convertedPoint.y - image.size.height / 4,
                width: image.size.width / 2,
                height: image.size.height / 2
            )
            imageView.alpha = 0.5
            imageView.accessibilityIdentifier = "dragPreviewImageView"
            self.view.addSubview(imageView)
            self.dragPreviewImageView = imageView
        }
        .store(in: &cancellables)
        UIView.animate(withDuration: 0.3) { [weak itemView] in
            guard let itemView = itemView else { return }
            itemView.alpha = 0.5
            itemView.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        }
    }

    public func itemView(_ itemView: TextEditorItemView, didChangeDraggingAt point: CGPoint) {
        guard let imageView = dragPreviewImageView, let image = dragPreviewImageView?.image else { return }
        scrollIfNeeded(for: itemView, at: point)
        let convertedPoint = itemView.convert(point, to: view)
        imageView.frame = CGRect(
            x: convertedPoint.x - image.size.width / 4,
            y: convertedPoint.y - image.size.height / 4,
            width: image.size.width / 2,
            height: image.size.height / 2
        )
        showCurrentDragItem(with: itemView, at: point)
    }

    func scrollIfNeeded(for itemView: TextEditorItemView, at point: CGPoint) {
        let convertedPoint = itemView.convert(point, to: view)
        scrollIfNeeded(at: convertedPoint)
    }

    public func itemView(_ itemView: TextEditorItemView, didEndDraggingAt point: CGPoint) {
        if let previewView = currentPreviewView(for: itemView, at: point) {
            stackView.removeArrangedSubview(itemView)
            itemView.removeFromSuperview()
            if let previewIndex = stackView.arrangedSubviews.firstIndex(of: previewView) {
                stackView.insertArrangedSubview(itemView, at: previewIndex)
            }
        }
        hideCurrentDragItem()
        dragPreviewImageView?.image = nil
        dragPreviewImageView?.removeFromSuperview()

        UIView.animate(withDuration: 0.3) { [weak itemView] in
            guard let itemView = itemView else { return }
            itemView.alpha = 1
            itemView.transform = .identity
        }
    }
}
