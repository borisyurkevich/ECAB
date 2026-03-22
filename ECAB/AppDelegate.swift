//
//  AppDelegate.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

private enum AppSection: Int, CaseIterable {
    case tests
    case contacts
    case history
    
    var title: String {
        switch self {
        case .tests:
            return "Tests"
        case .contacts:
            return "Contacts"
        case .history:
            return "History"
        }
    }
    
    var symbolName: String {
        switch self {
        case .tests:
            return "checklist"
        case .contacts:
            return "person.2"
        case .history:
            return "clock.arrow.circlepath"
        }
    }
}

private protocol SidebarViewControllerDelegate: AnyObject {
    func sidebarViewController(_ controller: SidebarViewController, didSelect section: AppSection)
}

private final class SidebarViewController: UITableViewController {
    
    weak var selectionDelegate: SidebarViewControllerDelegate?
    var selectedSection: AppSection = .tests
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ECAB"
        navigationItem.title = "ECAB"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SidebarCell")
        tableView.allowsMultipleSelection = false
        tableView.cellLayoutMarginsFollowReadableWidth = true
        updateSelection(animated: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SidebarCell", for: indexPath)
        let section = AppSection.allCases[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = section.title
        content.image = UIImage(systemName: section.symbolName)
        cell.contentConfiguration = content
        cell.accessoryType = selectedSection == section ? .checkmark : .none
        cell.backgroundColor = .clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = AppSection.allCases[indexPath.row]
        selectedSection = section
        updateSelection(animated: true)
        selectionDelegate?.sidebarViewController(self, didSelect: section)
    }
    
    func updateSelection(animated: Bool) {
        let indexPath = IndexPath(row: selectedSection.rawValue, section: 0)
        tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
        tableView.reloadData()
    }
}

private final class RootSplitViewController: UISplitViewController, SidebarViewControllerDelegate {
    
    typealias SectionControllers = (supplementary: UIViewController, secondary: UIViewController)
    
    private let sidebarViewController = SidebarViewController()
    private let sidebarNavigationController: UINavigationController
    private let sectionControllers: [AppSection: SectionControllers]
    
    init(sectionControllers: [AppSection: SectionControllers], initialSection: AppSection = .tests) {
        self.sectionControllers = sectionControllers
        self.sidebarNavigationController = UINavigationController(rootViewController: sidebarViewController)
        
        super.init(style: .tripleColumn)
        
        sidebarViewController.selectionDelegate = self
        
        preferredDisplayMode = .twoBesideSecondary
        preferredSplitBehavior = .tile
        presentsWithGesture = true
        minimumPrimaryColumnWidth = 220
        maximumPrimaryColumnWidth = 320
        preferredPrimaryColumnWidthFraction = 0.24
        
        setViewController(sidebarNavigationController, for: .primary)
        showSection(initialSection, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sidebarViewController(_ controller: SidebarViewController, didSelect section: AppSection) {
        showSection(section, animated: true)
    }
    
    private func showSection(_ section: AppSection, animated: Bool) {
        guard let controllers = sectionControllers[section] else {
            return
        }
        
        sidebarViewController.selectedSection = section
        sidebarViewController.updateSelection(animated: animated)
        
        setViewController(controllers.supplementary, for: .supplementary)
        setViewController(controllers.secondary, for: .secondary)
        show(.supplementary)
    }
}

private struct PlaceholderMessageView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIGuidedAccessRestrictionDelegate {

	lazy var coreDataStack = CoreDataStack()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    func applicationWillTerminate(_ application: UIApplication) {
		coreDataStack.saveContext()
    }

    func configureInitialViewController(for window: UIWindow) {
        Model.sharedInstance.setupWithContext(coreDataStack.context)

        let testsListController = TestsTableViewController(style: .insetGrouped)
        let menuViewController = MenuViewController(managedContext: coreDataStack.context)
        let historyListController = SessionsTableViewController(style: .insetGrouped)
        let historyDetailController = HistoryViewController()
        let playersController = PlayersTableViewController(style: .insetGrouped)

        let testsPrimary = UINavigationController(rootViewController: testsListController)
        let testsSecondary = UINavigationController(rootViewController: menuViewController)

        let contactsPrimary = UINavigationController(rootViewController: playersController)
        let contactsSecondary = UINavigationController(rootViewController: makePlaceholderController(title: "Players", message: "Choose a player from the list to make them active for the next test."))

        let historyPrimary = UINavigationController(rootViewController: historyListController)
        let historySecondary = UINavigationController(rootViewController: historyDetailController)

        let sectionControllers: [AppSection: RootSplitViewController.SectionControllers] = [
            .tests: (
                supplementary: testsPrimary,
                secondary: testsSecondary
            ),
            .contacts: (
                supplementary: contactsPrimary,
                secondary: contactsSecondary
            ),
            .history: (
                supplementary: historyPrimary,
                secondary: historySecondary
            )
        ]
        window.rootViewController = RootSplitViewController(sectionControllers: sectionControllers)
    }

    private func makePlaceholderController(title: String, message: String) -> UIViewController {
        UIHostingController(rootView: PlaceholderMessageView(title: title, message: message))
    }

    // MARK: - UIGuidedAccessRestrictionDelegate
    
    let controlsRestrictionId = "net.borisy.ecab.ControlsRestrictionId"
    let notificationId = "kECABGuidedAccessNotification"
    
    var guidedAccessRestrictionIdentifiers: [String]? {
        return [controlsRestrictionId]
    }
    
    func textForGuidedAccessRestriction(withIdentifier restrictionIdentifier: String) -> String? {
        if restrictionIdentifier == controlsRestrictionId {
            return "Pause button"
        }
        return nil
    }
    
    func detailTextForGuidedAccessRestriction(withIdentifier restrictionIdentifier: String) -> String? {
        if restrictionIdentifier == controlsRestrictionId {
            return "Pause and quit game at any time"
        }
        return nil
    }
    
    func guidedAccessRestriction(withIdentifier restrictionIdentifier: String,
        didChange newRestrictionState: UIAccessibility.GuidedAccessRestrictionState) {
            
            if restrictionIdentifier == controlsRestrictionId
            {
                let enabled = newRestrictionState != UIAccessibility.GuidedAccessRestrictionState.deny
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationId), object: nil, userInfo: ["restriction":enabled])
            }
    }
}
