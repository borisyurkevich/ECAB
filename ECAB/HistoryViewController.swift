//
//  HistoryViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UIDocumentInteractionControllerDelegate {

	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var helpMessage: UILabel!
	@IBOutlet weak var actionButton: UIBarButtonItem!
	
	let exportManager = DataExportModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		
		textView.text = ""
		helpMessage.text = "Select any session from the left."
    }

	@IBAction func handleShare(sender: UIBarButtonItem) {
		
		let exportDialog = UIAlertController(title: "Export", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
		let fileOption = UIAlertAction(title: "Export file", style: UIAlertActionStyle.Default, handler: { action in
			self.exportToCSV()
		})
		let emailOption = UIAlertAction(title: "Send file", style: UIAlertActionStyle.Default, handler: { action in
			// TODO impliment
		})
		exportDialog.addAction(fileOption)
		exportDialog.addAction(emailOption)
		exportDialog.popoverPresentationController?.barButtonItem = sender
		navigationController?.presentViewController(exportDialog, animated: true, completion: nil)
	}
	func exportToCSV() {
		
		let tempExportPath = NSTemporaryDirectory().stringByAppendingString("export.csv")
		let url: NSURL! = NSURL(fileURLWithPath: tempExportPath)
		
		if let data = exportManager.export() {
			do {
				try data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
			} catch {
				let writeError = error as NSError
				print("Error. Can't write a file: \(writeError)")
				// TODO Add alert.
				return;
			}
			
			if url != nil {
				let docController = UIDocumentInteractionController(URL: url)
				docController.UTI = "public.comma-separated-values-text"
				docController.delegate = self
				docController.presentOpenInMenuFromBarButtonItem(actionButton, animated: true)
			}
		}
		
//		let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//		
//		let data: NSData! = exportManager.export()
//		data.writeToFile(documentsPath, atomically: true)
//		
//		let docController = UIDocumentInteractionController(URL: NSURL.fileURLWithPath(documentsPath))
//		docController.UTI = "public.comma-separated-values-text"
//		docController.delegate = self
//		docController.presentOpenInMenuFromBarButtonItem(actionButton, animated: true)
	}
	
	// MARK: - UIDocumentInteractionControllerDelegate
	
//	func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
//		let filePresenter = UIViewController()
//		return filePresenter
//	}
}

