//
//  TextEditorViewController+.swift
//  TextEditor
//
//  Created by Kazuya Ueoka on 2022/07/17.
//

import UIKit

extension TextEditorViewController: TextEditorCoverViewDelegate {
    public func coverViewDidTapPickImage(_: TextEditorCoverView) {
        pickCoverImage()
    }

    public func coverViewDidTapEdit(_: TextEditorCoverView) {
        pickCoverImage()
    }

    private func pickCoverImage() {
        Task {
            do {
                coverView.image = try await self.delegate?.textEditorPickCoverImage(self)
            } catch {
                print("error \(error.localizedDescription)")
            }
        }
    }

    public func coverViewDidTapDelete(_ coverView: TextEditorCoverView) {
        coverView.image = nil
    }
}

extension TextEditorViewController: TextEditorTextViewDelegate {
    public func textViewAdd(_ textView: TextEditorTextView) {
        let nextItemView = makeDefaultItemView()
        if let index = stackView.arrangedSubviews.firstIndex(where: { itemView in
            guard let itemView = itemView as? TextEditorItemView else { return false }
            return itemView.contentView?.isEqual(textView) ?? false
        }) {
            stackView.insertArrangedSubview(nextItemView, at: index + 1)
        } else {
            stackView.addArrangedSubview(nextItemView)
        }
        (nextItemView.contentView as? TextEditorTextView)?.becomeFirstResponder()
    }

    public func textView(_ textView: TextEditorTextView, separateAt range: NSRange) {
        let location = range.location + range.length
        let length = textView.attributedText.length - location
        let cutRange = NSRange(location: location, length: length)
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let cutText = attributedString.attributedSubstring(from: cutRange)
        attributedString.replaceCharacters(in: cutRange, with: "")
        textView.attributedText = attributedString
        textView.removeLastNewLine()

        let afterItemView = makeDefaultItemView()
        (afterItemView.contentView as? TextEditorTextView)?.attributedText = cutText

        if let index = stackView.arrangedSubviews.firstIndex(where: {
            guard let itemView = $0 as? TextEditorItemView else { return false }
            return itemView.contentView?.isEqual(textView) ?? false
        }) {
            stackView.insertArrangedSubview(afterItemView, at: index + 1)
        }
        (afterItemView.contentView as? TextEditorTextView)?.becomeFirstResponder()
        (afterItemView.contentView as? TextEditorTextView)?.selectedRange = NSRange(location: 0, length: 0)
    }

    public func textViewDeleteIfNeeded(_ textView: TextEditorTextView) {
        guard let index = stackView.arrangedSubviews.firstIndex(where: { itemView in
            guard let itemView = itemView as? TextEditorItemView else { return false }
            return itemView.contentView?.isEqual(textView) ?? false
        }) else {
            return
        }
        guard
            let previousItemView = stackView.arrangedSubviews[index - 1] as? TextEditorItemView,
            let previousTextView = previousItemView.contentView as? TextEditorTextView
        else {
            return
        }
        previousTextView.becomeFirstResponder()

        let itemView = stackView.arrangedSubviews[index]
        stackView.removeArrangedSubview(itemView)
        itemView.removeFromSuperview()
    }

    public func textViewJoinIfNeeded(_ textView: TextEditorTextView) {
        guard let index = stackView.arrangedSubviews.firstIndex(where: { itemView in
            guard let itemView = itemView as? TextEditorItemView else { return false }
            return itemView.contentView?.isEqual(textView) ?? false
        }) else {
            return
        }
        guard
            let previousItemView = stackView.arrangedSubviews[index - 1] as? TextEditorItemView,
            let previousTextView = previousItemView.contentView as? TextEditorTextView
        else {
            return
        }
        let location = previousTextView.attributedText.length
        let attributedString = NSMutableAttributedString(attributedString: previousTextView.attributedText)
        attributedString.append(textView.attributedText)
        previousTextView.attributedText = attributedString
        previousTextView.becomeFirstResponder()
        previousTextView.selectedRange = NSRange(location: location, length: 0)

        let itemView = stackView.arrangedSubviews[index]
        stackView.removeArrangedSubview(itemView)
        itemView.removeFromSuperview()
    }
}

extension TextEditorViewController: TextEditorStackViewDelegate {
    public func stackViewDidAdd(_: TextEditorStackView, arrangedSubview _: UIView) {
        updatePlaceholderForFirstTextView()
    }

    public func stackViewDidInsert(_: TextEditorStackView, arrangedSubview _: UIView, at _: Int) {
        updatePlaceholderForFirstTextView()
    }

    public func stackViewDidRemove(_: TextEditorStackView, arrangedSubview _: UIView) {
        updatePlaceholderForFirstTextView()
    }

    private func updatePlaceholderForFirstTextView() {
        stackView.arrangedSubviews
            .compactMap { $0 as? TextEditorItemView }
            .enumerated()
            .forEach { offset, element in
                guard let textView = element.contentView as? TextEditorTextView else { return }
                if offset == 0 {
                    textView.placeholderText = textViewPlaceholder
                } else {
                    textView.placeholderText = nil
                }
            }
    }
}

extension TextEditorViewController: KeyboardItemDelegate {
    public var currentTextView: UITextView? {
        stackView.arrangedSubviews
            .compactMap { ($0 as? TextEditorItemView)?.contentView as? UITextView }
            .first(where: { $0.isFirstResponder })
    }

    public var textEditorViewController: TextEditorViewController? { self }
}

extension TextEditorViewController: TextEditorSheetImageItemDelegate {
    func sheetImageItem(_: TextEditorSheetImageItem, addImage image: UIImage) {
        let itemView = makeImageItem(image)
        if let currentItemView = currentItemView, let index = stackView.arrangedSubviews.firstIndex(of: currentItemView) {
            stackView.insertArrangedSubview(itemView, at: index + 1)
        } else {
            stackView.addArrangedSubview(itemView)
            addTextItemViewIfNeeded()
        }
    }

    func sheetImageItem(_: TextEditorSheetImageItem, didFailedWith error: Error) {
        print("\(#function) error \(error.localizedDescription)")
    }
}
