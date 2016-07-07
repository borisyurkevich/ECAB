//
//  SessionsTableViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/13/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class SessionsTableViewController: UITableViewController, UIDocumentInteractionControllerDelegate {
	
	let model = Model.sharedInstance
	let logModel = LogModel()
	
	private let reuseIdentifier = "Session Table Cell"
    
    var documentInteractionController: UIDocumentInteractionController?
    // Has to be global var because in some cases it can be released during export
    // http://stackoverflow.com/a/32746567/1162044
	
    private var selectedSession: Session?
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.enabled = false
    }
    
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		title = model.games[Int(model.data.selectedGame)].rawValue
		
		// For some reason there's delay and table is not updated streight after
		// game is finished.
		tableView.reloadData()
	}
    
    // Export
    
    @IBAction func handleExport(sender: UIBarButtonItem) {
        
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
    
    func showAlert() {
        let errorAlert = UIAlertController(title: "No data to export", message: nil, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertActionStyle.Cancel, handler: nil)
        errorAlert.addAction(okayAction)
        navigationController?.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    func writeFileAndReturnURL() -> NSURL? {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMM_HHmm"

        var fileName = ""
        var dateName: String
        
        switch model.data.selectedGame {
            case GamesIndex.VisualSearch.rawValue:
                if let session = selectedSession {
                    dateName = formatter.stringFromDate(session.dateStart)
                    fileName = "VisualSearch_\(dateName).csv"
                }
                break
            case GamesIndex.VisualSust.rawValue:
                if let session = selectedSession {
                    dateName = formatter.stringFromDate(session.dateStart)
                    fileName = "VisualSustain_\(dateName).csv"
                }
                break
            case GamesIndex.Counterpointing.rawValue:
                if let session = selectedSession {
                    dateName = formatter.stringFromDate(session.dateStart)
                    fileName = "Counterpoining_\(dateName).csv"
                }
                break
            case GamesIndex.Flanker.rawValue:
                if let session = selectedSession {
                    dateName = formatter.stringFromDate(session.dateStart)
                    fileName = "Flanker_\(dateName).csv"
                }
                break
            case GameTitle.auditorySust.rawValue:
                break
            case GameTitle.dualSust.rawValue:
                if let session = selectedSession {
                    dateName = formatter.stringFromDate(session.dateStart)
                    fileName = "DualSustain_\(dateName).csv"
                }
                break
            case GameTitle.verbal.rawValue:
                break
            case GameTitle.balloon.rawValue:
                break
            default:
                break
        }

        let tempExportPath = NSTemporaryDirectory().stringByAppendingString(fileName)
        let url: NSURL! = NSURL(fileURLWithPath: tempExportPath)
        
        let exportManager = DataExportModel()
        exportManager.pickedSession = selectedSession
        
        if let data = exportManager.export() {
            do {
                try data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                let writeError = error as NSError
                let message = "Error. Can't write a file: \(writeError)"
                let errorAlert = UIAlertController(title: "Can't Write File", message: message, preferredStyle: .Alert)
                let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertActionStyle.Cancel, handler: nil)
                errorAlert.addAction(okayAction)
                navigationController?.presentViewController(errorAlert, animated: true, completion: nil)
                return nil
            }
            return url

        } else {
            let title = NSLocalizedString("Couldn't read this session", comment: "alert title")
            let errorAlert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertActionStyle.Cancel, handler: nil)
            errorAlert.addAction(okayAction)
            navigationController?.presentViewController(errorAlert, animated: true, completion: nil)
            
            return nil
        }
    }
    
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
		
		// Date
		let formatter = NSDateFormatter()
		formatter.dateFormat = "dd MMM yyyy HH:mm"
        
        var cSessions = [Session]()
        
        for session in model.data.sessions {
            let cSession = session as! Session
            if cSession.type.integerValue == model.data.selectedGame {
                cSessions.append(cSession)
            }
        }
        
        let session = cSessions[indexPath.row]
        let dateStr = formatter.stringFromDate(session.dateStart)
        let label = "\(indexPath.row+1). \(dateStr)"
        cell.textLabel!.text = label
		
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var returnValue = 0
        
        for session in model.data.sessions {
            let cSession = session as! Session
            if cSession.type.integerValue == model.data.selectedGame {
                returnValue += 1
            }
        }
        
		return returnValue
	}
	
	// MARK: - Table view delegate
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle
		editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
		
			let navVC = splitViewController!.viewControllers.last as! UINavigationController
			let detailVC = navVC.topViewController as! HistoryViewController
            
            var cSessions = [Session]()
            for session in model.data.sessions {
                let cSession = session as! Session
                if cSession.type.integerValue == model.data.selectedGame{
                    cSessions.append(cSession)
                }
            }
            let session = cSessions[indexPath.row]
            model.managedContext.deleteObject(session)
            var error: NSError?
            do {
                try model.managedContext.save()
            } catch let error1 as NSError {
                error = error1
                print("Could not save after delete: \(error)")
            }
		
			// Last step
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			detailVC.textView.text = ""
			detailVC.helpMessage.text = "Select any session from the left."
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let navVC = splitViewController!.viewControllers.last as! UINavigationController!
		let detailVC = navVC.topViewController as! HistoryViewController
		
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss:S"
		let smallFormatter = NSDateFormatter()
		smallFormatter.locale = NSLocale.autoupdatingCurrentLocale()
		smallFormatter.dateFormat = "HH:mm:ss:S"
		
		let gameName = model.games[Int(model.data.selectedGame)]
        
        var array = [Session]()
        for session in model.data.sessions {
            let cSession = session as! Session
            if cSession.type.integerValue == model.data.selectedGame{
                array.append(cSession)
            }
        }
        
        let pickedSession = array[indexPath.row]
        
        switch model.data.selectedGame {
            
            case GamesIndex.VisualSearch.rawValue:
                detailVC.textView.text = logModel.generateVisualSearchLogWithSession(pickedSession, gameName: gameName.rawValue)
                break
            
            case GamesIndex.Counterpointing.rawValue:
                detailVC.textView.text = logModel.generateCounterpointingLogWithSession(pickedSession, gameName: gameName.rawValue)
                break
            
            case GamesIndex.Flanker.rawValue:
                detailVC.textView.text = logModel.generateFlankerLogWithSession(pickedSession, gameName: gameName.rawValue)
                break
            
            case GamesIndex.VisualSust.rawValue:
                detailVC.textView.text = logModel.generateVisualSustainLogWithSession(pickedSession, gameName: gameName.rawValue)
                break
            
            case GamesIndex.AuditorySust.rawValue:
                break
            
            case GamesIndex.DualSust.rawValue:
                detailVC.textView.text = logModel.generateDualSustainLogWithSession(pickedSession, gameName: gameName.rawValue)
                break
            
            case GamesIndex.Verbal.rawValue:
                break
            
            case GamesIndex.Balloon.rawValue:
                break
                
            default:
                break
        }

        detailVC.helpMessage.text = ""
        
        actionButton.enabled = true
        selectedSession = pickedSession
	}
}
