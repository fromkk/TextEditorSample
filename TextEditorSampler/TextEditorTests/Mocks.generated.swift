///
/// @Generated by Mockolo
///



import Combine
import SwiftUI
import UIKit
@testable import TextEditor


public class TextEditorCoverViewDelegateMock: TextEditorCoverViewDelegate {
    public init() { }


    public private(set) var coverViewDidTapPickImageCallCount = 0
    public var coverViewDidTapPickImageArgValues = [TextEditorCoverView]()
    public var coverViewDidTapPickImageHandler: ((TextEditorCoverView) -> ())?
    public func coverViewDidTapPickImage(_ coverView: TextEditorCoverView)  {
        coverViewDidTapPickImageCallCount += 1
        coverViewDidTapPickImageArgValues.append(coverView)
        if let coverViewDidTapPickImageHandler = coverViewDidTapPickImageHandler {
            coverViewDidTapPickImageHandler(coverView)
        }
        
    }

    public private(set) var coverViewDidTapEditCallCount = 0
    public var coverViewDidTapEditArgValues = [TextEditorCoverView]()
    public var coverViewDidTapEditHandler: ((TextEditorCoverView) -> ())?
    public func coverViewDidTapEdit(_ coverView: TextEditorCoverView)  {
        coverViewDidTapEditCallCount += 1
        coverViewDidTapEditArgValues.append(coverView)
        if let coverViewDidTapEditHandler = coverViewDidTapEditHandler {
            coverViewDidTapEditHandler(coverView)
        }
        
    }

    public private(set) var coverViewDidTapDeleteCallCount = 0
    public var coverViewDidTapDeleteArgValues = [TextEditorCoverView]()
    public var coverViewDidTapDeleteHandler: ((TextEditorCoverView) -> ())?
    public func coverViewDidTapDelete(_ coverView: TextEditorCoverView)  {
        coverViewDidTapDeleteCallCount += 1
        coverViewDidTapDeleteArgValues.append(coverView)
        if let coverViewDidTapDeleteHandler = coverViewDidTapDeleteHandler {
            coverViewDidTapDeleteHandler(coverView)
        }
        
    }
}

