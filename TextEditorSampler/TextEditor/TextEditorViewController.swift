//
//  TextEditorViewController.swift
//  TextEditor
//
//  Created by Ueoka Kazuya on 2022/06/20.
//

import UIKit

open class TextEditorViewController: UIViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        addScrollView()
        addStackView()
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
}
