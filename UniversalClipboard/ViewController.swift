//
//  ViewController.swift
//  UniversalClipboard
////

import UIKit
import QuickLook

final class AttachmentListControler: UITableViewController {

  private var attachments: [AttachmentItem] = []
  private lazy var previewController: QLPreviewController = .init()
  private var previewDataSource: PreviewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareNavigation()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    attachments.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let attachmentCell = tableView.dequeueReusableCell(withIdentifier: AttachmentTableCell.identifier) as? AttachmentTableCell else{return UITableViewCell()}
    attachmentCell.update(attachment: attachments[indexPath.row])
    return attachmentCell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    80
  }
  
  override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    "Delete"
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else{return}
    attachments.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .right)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    previewDataSource = .init(previewItems: attachments, destinationIndex: indexPath.row)
    previewController.dataSource = previewDataSource
    present(previewController, animated: true, completion: nil)
  }

}

/// Navigation methods
private extension AttachmentListControler {
  
  func prepareNavigation() {
    navigationItem.title = "Attachments"
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.on.clipboard", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), style: .done, target: self, action: #selector(didTapPaste))
  }
  
  @objc func didTapPaste() {
    for itemProvider in UIPasteboard.general.itemProviders {
      guard let item = itemProvider.copy() as? NSItemProvider,
        let attachmentName = item.suggestedName,
            let uti = item.registeredTypeIdentifiers.first else {break}
      item.loadDataRepresentation(forTypeIdentifier: uti) { data, error in
        if let data = data {
          DispatchQueue.main.async {
            self.attachments.insert(.init(name: attachmentName, data: data), at: .zero)
            self.tableView.insertRows(at: [IndexPath(row: .zero, section: .zero)], with: .left)
          }
        }
      }
    }
  }
  
}



/// AttachmentTableCell
final class AttachmentTableCell: UITableViewCell {
  
  static let identifier: String = "AttachmentTableCell"
  
  @IBOutlet private weak var thumbNail: UIImageView!
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var size: UILabel!
  
  func update(attachment: AttachmentListControler.AttachmentItem) {
    name.text = attachment.name
    size.text = attachment.size
    if let image = UIImage(data: attachment.data) {
      thumbNail.image = image
    } else {
      thumbNail.image = .init(systemName: "doc")
    }
  }
  
}


extension AttachmentListControler {
  
  class AttachmentItem: NSObject {
    var name: String
    var size: String { getSizeInMB() }
    var data: Data
    
    init(name: String, data: Data) {
      self.name = name
      self.data = data
    }
    
    func getSizeInMB() -> String {
      let bcf = ByteCountFormatter()
      bcf.allowedUnits = [.useMB]
      bcf.countStyle = .file
      return bcf.string(fromByteCount: Int64(data.count)).replacingOccurrences(of: ",", with: ".")
    }
    
  }
  
}

