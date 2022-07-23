//
//  TextEditorViewController+Drop.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/17.
//

import UIKit

extension TextEditorViewController: UIDropInteractionDelegate {
    func removeDragPreviewView() {
        stackView.arrangedSubviews.forEach {
            guard let previewView = $0 as? TextEditorDragPreviewView else { return }
            stackView.removeArrangedSubview(previewView)
            previewView.removeFromSuperview()
        }
    }

    func showDragPreviewView() {
        stackView.arrangedSubviews.enumerated().reversed().forEach {
            let offset = $0.offset
            guard offset > 0 else { return }
            let preview = TextEditorDragPreviewView()
            preview.isHidden = true
            stackView.insertArrangedSubview(preview, at: offset + 1)
        }
    }

    func configureDrop() {
        let item = UIDropInteraction(delegate: self)
        view.addInteraction(item)
    }

    func currentPreviewView(for itemView: TextEditorItemView, at point: CGPoint) -> TextEditorDragPreviewView? {
        let allPreviewViews: [TextEditorDragPreviewView] = stackView.arrangedSubviews.compactMap { $0 as? TextEditorDragPreviewView }
        let y = itemView.convert(point, to: view).y
        return allPreviewViews.sorted { lhs, rhs in
            let lhsY = lhs.convert(lhs.bounds, to: view).origin.y
            let rhsY = rhs.convert(rhs.bounds, to: view).origin.y
            return abs(y - lhsY) < abs(y - rhsY)
        }.first
    }

    private func currentPreviewView(for session: UIDropSession) -> TextEditorDragPreviewView? {
        let allPreviewViews: [TextEditorDragPreviewView] = stackView.arrangedSubviews.compactMap { $0 as? TextEditorDragPreviewView }
        let y = session.location(in: view).y
        return allPreviewViews.sorted { lhs, rhs in
            let lhsY = lhs.convert(lhs.bounds, to: view).origin.y
            let rhsY = rhs.convert(rhs.bounds, to: view).origin.y
            return abs(y - lhsY) < abs(y - rhsY)
        }.first
    }

    public func dropInteraction(_: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        if session.canLoadObjects(ofClass: UIImage.self) {
            showDragPreviewView()
        }
    }

    public func dropInteraction(_: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        if session.canLoadObjects(ofClass: UIImage.self) {
            scrollIfNeeded(for: session)
            showCurrentDragItem(with: session)
            return UIDropProposal(operation: .copy)
        } else {
            return UIDropProposal(operation: .cancel)
        }
    }

    func scrollIfNeeded(for session: UIDropSession) {
        let convertedPoint = session.location(in: view)
        scrollIfNeeded(at: convertedPoint)
    }

    func scrollIfNeeded(at convertedPoint: CGPoint) {
        let thresholdRate: CGFloat = 0.1 // %
        let move: CGFloat = 30.0
        let top = view.bounds.size.height * thresholdRate
        let bottom = view.bounds.size.height - top
        if top > convertedPoint.y {
            if scrollView.contentOffset.y - move > 0 {
                scrollView.contentOffset.y -= move
            } else {
                scrollView.contentOffset.y = 0
            }
        } else if bottom < convertedPoint.y {
            if (scrollView.contentOffset.y + scrollView.bounds.size.height + move) < scrollView.contentSize.height {
                scrollView.contentOffset.y += move
            }
        }
    }

    public func dropInteraction(_: UIDropInteraction, sessionDidExit _: UIDropSession) {
        hideCurrentDragItem()
    }

    private func showCurrentDragItem(with session: UIDropSession) {
        let currentPreviewView = currentPreviewView(for: session)
        stackView.arrangedSubviews.forEach {
            guard let previewView = $0 as? TextEditorDragPreviewView else { return }
            previewView.isHidden = !previewView.isEqual(currentPreviewView)
        }
    }

    func showCurrentDragItem(with itemView: TextEditorItemView, at location: CGPoint) {
        let currentPreviewView = currentPreviewView(for: itemView, at: location)
        stackView.arrangedSubviews.forEach {
            guard let previewView = $0 as? TextEditorDragPreviewView else { return }
            previewView.isHidden = !previewView.isEqual(currentPreviewView)
        }
    }

    private func convertIndex(of stackViewIndex: Int) -> Int {
        // ヘッダー部分とタイトル入力欄を無視する
        (stackViewIndex - 2) / 2 + 2
    }

    func hideCurrentDragItem() {
        removeDragPreviewView()
    }

    public func dropInteraction(_: UIDropInteraction, performDrop session: UIDropSession) {
        defer {
            hideCurrentDragItem()
        }

        var currentView: TextEditorItemView?
        if
            let currentPreviewView = currentPreviewView(for: session),
            let index = stackView.arrangedSubviews.firstIndex(of: currentPreviewView)
        {
            let toIndex = convertIndex(of: index)
            if session.canLoadObjects(ofClass: UIImage.self) {
                session.loadObjects(ofClass: UIImage.self) { [weak self] images in
                    guard let self = self else { return }
                    let images = images.compactMap { $0 as? UIImage }
                    images.enumerated().forEach {
                        let itemView = self.makeImageItem($0.element)
                        if $0.offset == 0 {
                            self.stackView.insertArrangedSubview(itemView, at: toIndex)
                        } else if let lastView = currentView, let currentIndex = self.stackView.arrangedSubviews.firstIndex(of: lastView) {
                            self.stackView.insertArrangedSubview(itemView, at: currentIndex + 1)
                        }
                        currentView = itemView
                    }
                    self.addTextItemViewIfNeeded()
                }
            }
        } else {
            if session.canLoadObjects(ofClass: UIImage.self) {
                session.loadObjects(ofClass: UIImage.self) { [weak self] images in
                    guard let self = self else { return }
                    let images = images.compactMap { $0 as? UIImage }
                    images.forEach {
                        let itemView = self.makeImageItem($0)
                        if let lastView = currentView, let currentIndex = self.stackView.arrangedSubviews.firstIndex(of: lastView) {
                            self.stackView.insertArrangedSubview(itemView, at: currentIndex + 1)
                        } else {
                            self.stackView.addArrangedSubview(itemView)
                        }
                        currentView = itemView
                    }
                    self.addTextItemViewIfNeeded()
                }
            }
        }
    }
}
