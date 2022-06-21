//
//  TextEditorViewController.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/20.
//

import Combine
import SwiftUI
import UIKit

public protocol TextEditorViewControllerDelegate: AnyObject {
    func textEditorPickCoverImage(_ textEditor: TextEditorViewController) async throws -> UIImage?
}

@MainActor
open class TextEditorViewController: UIViewController {
    public weak var delegate: TextEditorViewControllerDelegate?

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TextEditorConstant.Color.background
        navigationItem.leftBarButtonItem = closeBarButtonItem
        addScrollView()
        addStackView()
        addCoverView()
        addTitleView()
        subscribe()
    }

    private func invalidateIntrinsicContentSizeSubViews() {
        stackView.arrangedSubviews.forEach {
            $0.invalidateIntrinsicContentSize()
        }
    }

    public lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: L10n.close, style: .plain, target: self, action: #selector(close(sender:)))
        item.accessibilityIdentifier = #function
        return item
    }()

    @objc private func close(sender _: UIBarButtonItem) {
        dismiss(animated: true)
    }

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.accessibilityIdentifier = #function
        return scrollView
    }()

    private func addScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    public lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: view.bounds)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.accessibilityIdentifier = #function
        return stackView
    }()

    private lazy var stackViewLeadingConstraint: NSLayoutConstraint = stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor)
    private lazy var stackViewTrailingConstraint: NSLayoutConstraint = scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)

    private func addStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackViewLeadingConstraint,
            stackViewTrailingConstraint,
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }

    public lazy var coverView: TextEditorCoverView = {
        let coverView = TextEditorCoverView()
        coverView.delegate = self
        coverView.accessibilityIdentifier = #function
        return coverView
    }()

    private lazy var coverViewHasImageHeightConstraint = coverView.heightAnchor.constraint(equalTo: coverView.widthAnchor, multiplier: 196 / 375)
    private lazy var coverViewNoImageHeightConstraint = coverView.heightAnchor.constraint(equalTo: coverView.widthAnchor, multiplier: 80 / 375)

    private func addCoverView() {
        coverView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(coverView)
        coverViewNoImageHeightConstraint.isActive = true
    }

    public lazy var titleView: TextEditorTitleView = {
        let titleView = TextEditorTitleView()
        titleView.accessibilityIdentifier = #function
        return titleView
    }()

    private func addTitleView() {
        stackView.addArrangedSubview(titleView)
    }

    // MARK: - Combine

    private var cancellables: Set<AnyCancellable> = .init()

    private func subscribe() {
        handleCoverViewHeightConstraint()
    }

    private func handleCoverViewHeightConstraint() {
        coverView.$image
            .map { $0 != nil }
            .sink { [weak self] hasImage in
                self?.coverViewHasImageHeightConstraint.isActive = hasImage
                self?.coverViewNoImageHeightConstraint.isActive = !hasImage
                self?.coverView.invalidateIntrinsicContentSize()
            }
            .store(in: &cancellables)
    }
}

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
