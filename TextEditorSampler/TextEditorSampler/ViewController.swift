//
//  ViewController.swift
//  TextEditorSampler
//
//  Created by Ueoka Kazuya on 2022/06/20.
//

import Photos
import PhotosUI
import TextEditor
import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController, TextEditorViewControllerDelegate, PHPickerViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        addOpenEditorButton()
    }

    lazy var openEditorButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Open Editor", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(openEditor(sender:)), for: .primaryActionTriggered)
        button.accessibilityIdentifier = #function
        return button
    }()

    private func addOpenEditorButton() {
        openEditorButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openEditorButton)
        NSLayoutConstraint.activate([
            openEditorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openEditorButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openEditor(sender _: UIButton) {
        let editorViewController = TextEditorViewController()
        editorViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: editorViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    // MARK: - TextEditorViewControllerDelegate

    private var coverContinuation: CheckedContinuation<UIImage?, Error>?

    func textEditorPickCoverImage(_ textEditor: TextEditorViewController) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            coverContinuation = continuation
            guard let self = self else {
                continuation.resume(returning: nil)
                return
            }
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            configuration.preferredAssetRepresentationMode = .current
            let pickerViewController = PHPickerViewController(configuration: configuration)
            pickerViewController.delegate = self
            textEditor.present(pickerViewController, animated: true)
        }
    }

    // MARK: - PHPickerViewControllerDelegate

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        defer {
            picker.dismiss(animated: true)
        }

        guard let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            coverContinuation?.resume(returning: nil)
            coverContinuation = nil
            return
        }
        result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
            defer {
                self?.coverContinuation = nil
            }
            if let error = error {
                self?.coverContinuation?.resume(throwing: error)
            } else if let data = data {
                self?.coverContinuation?.resume(returning: UIImage(data: data))
            }
        }
    }
}
