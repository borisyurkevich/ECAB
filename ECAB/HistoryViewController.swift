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
	
	var exportManager: DataExportModel? = nil
    var documentInteractionController: UIDocumentInteractionController?
    // Has to be global var because in some cases it can be released during export
    // http://stackoverflow.com/a/32746567/1162044
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		exportManager = DataExportModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		
		textView.text = ""
		helpMessage.text = "Select any session from the left."
		actionButton.enabled = false
    }

	@IBAction func handleShare(sender: UIBarButtonItem) {
		
		let exportDialog = UIAlertController(title: "Export", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
		let fileOption = UIAlertAction(title: "Export file", style: UIAlertActionStyle.Default, handler: { action in
			self.exportToCSV()
		})
		let emailOption = UIAlertAction(title: "Send file", style: UIAlertActionStyle.Default, handler: { action in
			self.presentActivityViewController()
		})
		exportDialog.addAction(emailOption)
		exportDialog.addAction(fileOption)
		exportDialog.popoverPresentationController?.barButtonItem = sender
		navigationController?.presentViewController(exportDialog, animated: true,
																completion: nil)
	}

	func exportToCSV() {
		if let url = writeFileAndReturnURL() {
            documentInteractionController = UIDocumentInteractionController(URL: url)
			documentInteractionController!.UTI = "public.comma-separated-values-text"
			documentInteractionController!.delegate = self
			documentInteractionController!.presentOpenInMenuFromBarButtonItem(actionButton, animated: true)
		}
	}
	func presentActivityViewController() {
		if let url = writeFileAndReturnURL() {
			let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
			activityVC.popoverPresentationController?.barButtonItem = actionButton
			self.navigationController?.presentViewController(activityVC, animated: true, completion: nil)
		}
	}
	func writeFileAndReturnURL() -> NSURL? {
		let tempExportPath = NSTemporaryDirectory().stringByAppendingString("export.csv")
		let url: NSURL! = NSURL(fileURLWithPath: tempExportPath)
		
		if (exportManager == nil) {
			return nil
		}
		
		if let data = exportManager!.export() {
			do {
				try data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
			} catch {
				let writeError = error as NSError
				let message = "Error. Can't write a file: \(writeError)"
				let errorAlert = UIAlertController(title: "Can't write file", message: message, preferredStyle: .Alert)
				let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertActionStyle.Cancel, handler: nil)
				errorAlert.addAction(okayAction)
				navigationController?.presentViewController(errorAlert, animated: true, completion: nil)
				return nil
			}
			return url
		} else {
			let errorAlert = UIAlertController(title: "No data to export", message: nil, preferredStyle: .Alert)
			let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertActionStyle.Cancel, handler: nil)
			errorAlert.addAction(okayAction)
			navigationController?.presentViewController(errorAlert, animated: true, completion: nil)
			return nil
		}
	}
}

