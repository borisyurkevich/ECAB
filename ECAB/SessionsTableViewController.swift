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
    private var selectedCounterpointingSession:CounterpointingSession?
    
    var counterpointingSessions = [CounterpointingSession]()
    var flankerSessions = [CounterpointingSession]()
    var visualSustainSessions = [CounterpointingSession]()
    
    let rowNameformatter = NSDateFormatter()
    let fileNameformatter = NSDateFormatter()
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rowNameformatter.dateFormat = "dd MMM yyyy HH:mm"
        fileNameformatter.dateFormat = "ddMMM_HHmm"
    }
    
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		title = model.games[Int(model.data.selectedGame)]
		
        
        actionButton.enabled = false
        
        // Build sessions
        counterpointingSessions.removeAll()
        flankerSessions.removeAll()
        visualSustainSessions.removeAll()
        
        for session in model.data.counterpointingSessions {
            
            let mySession = session as! CounterpointingSession
            let sessionType = SessionType(rawValue: mySession.type.integerValue)!
            
            switch sessionType {
                
            case .Counterpointing:
                counterpointingSessions.append(mySession)
                
            case .Flanker, .FlankerRandomized:
                
                flankerSessions.append(mySession)
                
            case .VisualSustain:
                
                visualSustainSessions.append(mySession)
            }
        }
        
        // Need to reload table to show possible
        // new elements.
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

        var fileName = ""
        var dateName: String
        
        switch model.data.selectedGame {
        case GamesIndex.VisualSearch.rawValue:
            if let visualSearchSession: Session = selectedSession {
                dateName = fileNameformatter.stringFromDate(visualSearchSession.dateStart)
                fileName = "VisualSearch_\(dateName).csv"
            }
        break
        case GamesIndex.VisualSust.rawValue:
            if let counterpointingSession = selectedCounterpointingSession {
                dateName = fileNameformatter.stringFromDate(counterpointingSession.dateStart)
                fileName = "VisualSustain_\(dateName).csv"
            }
        break
        case GamesIndex.Counterpointing.rawValue:
            if let counterpointingSession = selectedCounterpointingSession {
                dateName = fileNameformatter.stringFromDate(counterpointingSession.dateStart)
                fileName = "Counterpoining_\(dateName).csv"
            }
        break
        case GamesIndex.Flanker.rawValue:
            if let counterpointingSession = selectedCounterpointingSession {
                dateName = fileNameformatter.stringFromDate(counterpointingSession.dateStart)
                fileName = "Flanker_\(dateName).csv"
            }
        break
        default:
        break
        }

        let tempExportPath = NSTemporaryDirectory().stringByAppendingString(fileName)
        let url: NSURL! = NSURL(fileURLWithPath: tempExportPath)
        
        let exportManager = DataExportModel()
        exportManager.pickedVisualSearchSession = selectedSession
        exportManager.pickedCounterpointingSession = selectedCounterpointingSession
        
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
		
		switch model.data.selectedGame {
		
        case GamesIndex.VisualSearch.rawValue:
			let session = model.data.sessions[indexPath.row] as! Session
			let dateStr = rowNameformatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
			
		case GamesIndex.Counterpointing.rawValue:
			
			let session = counterpointingSessions[indexPath.row]
			let dateStr = rowNameformatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
			
		case GamesIndex.Flanker.rawValue:
			
			let session = flankerSessions[indexPath.row]
			let dateStr = rowNameformatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
			
		case GamesIndex.VisualSust.rawValue:
			
			let session = visualSustainSessions[indexPath.row]
			let dateStr = rowNameformatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
            
		default:
			break;
		}
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var returnValue = 0
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			
            returnValue = model.data.sessions.count
			
		case GamesIndex.Counterpointing.rawValue:
			
            returnValue = counterpointingSessions.count
            
		case GamesIndex.Flanker.rawValue:
            
            returnValue = flankerSessions.count
            
		case GamesIndex.VisualSust.rawValue:
            
            returnValue = visualSustainSessions.count
            
		default:
			break
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
		
			// Session to remove
			switch model.data.selectedGame {
			case GamesIndex.VisualSearch.rawValue:
				let session = model.data.sessions[indexPath.row] as! Session
				model.managedContext.deleteObject(session)
				var error: NSError?
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			case GamesIndex.Counterpointing.rawValue:

				let session = counterpointingSessions[indexPath.row]
				model.managedContext.deleteObject(session)
				var error: NSError?
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			case GamesIndex.Flanker.rawValue:
            
				let session = flankerSessions[indexPath.row]
				model.managedContext.deleteObject(session)
				var error: NSError?
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			case GamesIndex.VisualSust.rawValue:
				
				let session = visualSustainSessions[indexPath.row]
				model.managedContext.deleteObject(session)
				var error: NSError?
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			default:
                break
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
		
		let gameName = model.games[Int(model.data.selectedGame)]
        
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			let pickedSession = model.data.sessions[indexPath.row] as! Session
			let visualSearchLog = logModel.generateVisualSearchLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = visualSearchLog
			detailVC.helpMessage.text = ""
			
            actionButton.enabled = true
			selectedSession = pickedSession
            
		case GamesIndex.Counterpointing.rawValue:

			let pickedSession = counterpointingSessions[indexPath.row]
			let counterpointingLog = logModel.generateCounterpointingLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = counterpointingLog
			detailVC.helpMessage.text = ""
			
            actionButton.enabled = true
			selectedCounterpointingSession = pickedSession
            
		case GamesIndex.Flanker.rawValue: // Flanker - exact copy of Counterpointing
			
            let pickedSession = flankerSessions[indexPath.row]
			let text = logModel.generateFlankerLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = text
			detailVC.helpMessage.text = ""
			
            actionButton.enabled = true
			selectedCounterpointingSession = pickedSession
            
		case GamesIndex.VisualSust.rawValue:
			
            let pickedSession = visualSustainSessions[indexPath.row]
			detailVC.textView.text = logModel.generateVisualSustainLogWithSession(pickedSession, gameName: gameName)
			detailVC.helpMessage.text = ""
			
            actionButton.enabled = true
			selectedCounterpointingSession = pickedSession
            
		default:
			break
		}
	}
}
