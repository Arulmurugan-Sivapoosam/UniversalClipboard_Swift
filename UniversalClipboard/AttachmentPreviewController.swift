//
//  AttachmentPreviewController.swift
//  UniversalClipboard
//
//  Created by arul-zt258 on 22/12/21.
//

import Foundation
import QuickLook

final class PreviewController: QLPreviewControllerDataSource {
  typealias PreviewItems = [AttachmentListControler.AttachmentItem]
  private var previewItems: PreviewItems
  private var index: Int
  
  init(previewItems: PreviewItems, destinationIndex: Int) {
    self.previewItems = previewItems
    self.index = destinationIndex
  }
  
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    previewItems.count
  }
  
  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    previewItems[index]
  }
  
}


extension AttachmentListControler.AttachmentItem: QLPreviewItem {
  
  var previewItemURL: URL? {
    guard var documentDir = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else{return nil}
    documentDir.appendPathComponent(name)
    return FileManager.default.fileExists(atPath: documentDir.absoluteString) ? documentDir : {
      try? data.write(to: documentDir)
      return documentDir
    }()
  }
  
  var previewItemTitle: String? { name }
  
}
