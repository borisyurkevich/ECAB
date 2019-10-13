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
    
    let rowNameformatter = DateFormatter()
    let fileNameformatter = DateFormatter()
    
    @IBOutlet weak var actionButton: UIBarButtonItem!

    @IBAction func tapEdit(_ sender: UIBarButtonItem) {
        toggleEditMode()
    }
    
    @objc func toggleEditMode() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
            navigationItem.setLeftBarButton(editButton, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleEditMode))
            navigationItem.setLeftBarButton(doneButton, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rowNameformatter.dateFormat = "dd MMM yyyy HH:mm"
        fileNameformatter.dateFormat = "ddMMM_HHmm"
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		title = model.games[model.data.selectedGame.intValue]
        actionButton.isEnabled = false
        rebuild()
        // Need to reload table to show possible
        // new elements.
        tableView.reloadData()
	}
    
    private func rebuild() {
        // Build sessions
        counterpointingSessions.removeAll()
        flankerSessions.removeAll()
        visualSustainSessions.removeAll()
        
        for session in model.data.counterpointingSessions {
            
            let mySession = session as! CounterpointingSession
            let sessionType = SessionType(rawValue: mySession.type.intValue)!
            
            switch sessionType {
                
            case .counterpointing:
                counterpointingSessions.append(mySession)
                
            case .flanker, .flankerRandomized:
                
                flankerSessions.append(mySession)
                
            case .visualSustain:
                
                visualSustainSessions.append(mySession)
            }
        }
    }
    
    // Export
    
    @IBAction func handleExport(_ sender: UIBarButtonItem) {
        
        let exportDialog = UIAlertController(title: "Export", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let fileOption = UIAlertAction(title: "Export file", style: UIAlertAction.Style.default, handler: { action in
            self.exportToCSV()
        })
        let emailOption = UIAlertAction(title: "Send file", style: UIAlertAction.Style.default, handler: { action in
            self.presentActivityViewController()
        })
        exportDialog.addAction(emailOption)
        exportDialog.addAction(fileOption)
        exportDialog.popoverPresentationController?.barButtonItem = sender
        navigationController?.present(exportDialog, animated: true,
            completion: nil)
        
    }
    
    func exportToCSV() {
        if let url = writeFileAndReturnURL() {
            documentInteractionController = UIDocumentInteractionController(url: url)
            documentInteractionController!.uti = "public.comma-separated-values-text"
            documentInteractionController!.delegate = self
            documentInteractionController!.presentOpenInMenu(from: actionButton, animated: true)
        }
    }
    func presentActivityViewController() {
        if let url = writeFileAndReturnURL() {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = actionButton
            self.navigationController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func showAlert() {
        let errorAlert = UIAlertController(title: "No data to export", message: nil, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertAction.Style.cancel, handler: nil)
        errorAlert.addAction(okayAction)
        navigationController?.present(errorAlert, animated: true, completion: nil)
    }
    
    func writeFileAndReturnURL() -> URL? {

        var fileName = ""
        var dateName: String
        
        switch model.data.selectedGame {
        case GamesIndex.visualSearch.rawValue:
            if let visualSearchSession: Session = selectedSession {
                dateName = fileNameformatter.string(from: visualSearchSession.dateStart as Date)
                fileName = "VisualSearch_\(dateName).csv"
            }
        break
        case GamesIndex.visualSust.rawValue:
            if let counterpointingSession = selectedCounterpointingSession {
                dateName = fileNameformatter.string(from: counterpointingSession.dateStart as Date)
                fileName = "VisualSustain_\(dateName).csv"
            }
        break
        case GamesIndex.counterpointing.rawValue:
            if let counterpointingSession = selectedCounterpointingSession {
                dateName = fileNameformatter.string(from: counterpointingSession.dateStart as Date)
                fileName = "Counterpoining_\(dateName).csv"
            }
        break
        case GamesIndex.flanker.rawValue:
            if let counterpointingSession = selectedCounterpointingSession {
                dateName = fileNameformatter.string(from: counterpointingSession.dateStart as Date)
                fileName = "Flanker_\(dateName).csv"
            }
        break
        default:
        break
        }

        let tempExportPath = NSTemporaryDirectory() + fileName
        let url: URL! = URL(fileURLWithPath: tempExportPath)
        
        let exportManager = DataExportModel()
        exportManager.pickedVisualSearchSession = selectedSession
        exportManager.pickedCounterpointingSession = selectedCounterpointingSession
        
        if let data = exportManager.export() {
            do {
                try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                let writeError = error as NSError
                let message = "Error. Can't write a file: \(writeError)"
                let errorAlert = UIAlertController(title: "Can't Write File", message: message, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertAction.Style.cancel, handler: nil)
                errorAlert.addAction(okayAction)
                navigationController?.present(errorAlert, animated: true, completion: nil)
                return nil
            }
            return url

        } else {
            let title = NSLocalizedString("Couldn't read this session", comment: "alert title")
            let errorAlert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: UIAlertAction.Style.cancel, handler: nil)
            errorAlert.addAction(okayAction)
            navigationController?.present(errorAlert, animated: true, completion: nil)
            
            return nil
        }
    }
    
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		switch model.data.selectedGame {
		
        case GamesIndex.visualSearch.rawValue:
			let session = model.data.sessions[indexPath.row] as! Session
			let dateStr = rowNameformatter.string(from: session.dateStart as Date)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
			
		case GamesIndex.counterpointing.rawValue:
			
			let session = counterpointingSessions[indexPath.row]
			let dateStr = rowNameformatter.string(from: session.dateStart as Date)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
			
		case GamesIndex.flanker.rawValue:
			
			let session = flankerSessions[indexPath.row]
			let dateStr = rowNameformatter.string(from: session.dateStart as Date)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
			
		case GamesIndex.visualSust.rawValue:
			
			let session = visualSustainSessions[indexPath.row]
			let dateStr = rowNameformatter.string(from: session.dateStart as Date)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
            
		default:
			break;
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var returnValue = 0
		
		switch model.data.selectedGame {
		case GamesIndex.visualSearch.rawValue:
			
            returnValue = model.data.sessions.count
			
		case GamesIndex.counterpointing.rawValue:
			
            returnValue = counterpointingSessions.count
            
		case GamesIndex.flanker.rawValue:
            
            returnValue = flankerSessions.count
            
		case GamesIndex.visualSust.rawValue:
            
            returnValue = visualSustainSessions.count
            
		default:
			break
		}
		
		return returnValue
	}
	
	// MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit
		editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == UITableViewCell.EditingStyle.delete {
		
			let navVC = splitViewController!.viewControllers.last as! UINavigationController
			let detailVC = navVC.topViewController as! HistoryViewController
		
			// Session to remove
			switch model.data.selectedGame {
			case GamesIndex.visualSearch.rawValue:
				let session = model.data.sessions[indexPath.row] as! Session
				model.managedContext.delete(session)
				do {
					try model.managedContext.save()
				} catch let error as NSError {
					print("Could not save after delete: \(error.localizedDescription)")
				}
			case GamesIndex.counterpointing.rawValue:

				let session = counterpointingSessions[indexPath.row]
				model.managedContext.delete(session)
				do {
					try model.managedContext.save()
				} catch let error as NSError {
					print("Could not save after delete: \(error.localizedDescription)")
				}
			case GamesIndex.flanker.rawValue:
            
				let session = flankerSessions[indexPath.row]
				model.managedContext.delete(session)
				do {
					try model.managedContext.save()
				} catch let error as NSError {
					print("Could not save after delete: \(error.localizedDescription)")
				}
			case GamesIndex.visualSust.rawValue:
				
				let session = visualSustainSessions[indexPath.row]
				model.managedContext.delete(session)
				do {
					try model.managedContext.save()
				} catch let error as NSError {
					print("Could not save after delete: \(error.localizedDescription)")
				}
			default:
                break
			}
            model.save()
		
			// Last step
            rebuild()
			tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
			detailVC.textView.text = ""
			detailVC.helpMessage.text = "Select any session from the left."
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
        guard let navVC = splitViewController!.viewControllers.last as? UINavigationController else {
            return
        }
		let detailVC = navVC.topViewController as! HistoryViewController
		
		let gameName = model.games[model.data.selectedGame.intValue]
        
		switch model.data.selectedGame {
		case GamesIndex.visualSearch.rawValue:
			let pickedSession = model.data.sessions[indexPath.row] as! Session
			let visualSearchLog = logModel.generateVisualSearchLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = visualSearchLog
			detailVC.helpMessage.text = ""
			
            actionButton.isEnabled = true
			selectedSession = pickedSession
            
		case GamesIndex.counterpointing.rawValue:

			let pickedSession = counterpointingSessions[indexPath.row]
			let counterpointingLog = logModel.generateCounterpointingLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = counterpointingLog
			detailVC.helpMessage.text = ""
			
            actionButton.isEnabled = true
			selectedCounterpointingSession = pickedSession
            
		case GamesIndex.flanker.rawValue: // Flanker - exact copy of Counterpointing
			
            let pickedSession = flankerSessions[indexPath.row]
			let text = logModel.generateFlankerLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = text
			detailVC.helpMessage.text = ""
			
            actionButton.isEnabled = true
			selectedCounterpointingSession = pickedSession
            
		case GamesIndex.visualSust.rawValue:
			
            let pickedSession = visualSustainSessions[indexPath.row]
			detailVC.textView.text = logModel.generateVisualSustainLogWithSession(pickedSession, gameName: gameName)
			detailVC.helpMessage.text = ""
			
            actionButton.isEnabled = true
			selectedCounterpointingSession = pickedSession
            
		default:
			break
		}
	}
}
