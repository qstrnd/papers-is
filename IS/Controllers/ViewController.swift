//
//  ViewController.swift
//  Permits
//
//  Created by Andrew on 10/10/21.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var userInfoStackView: NSStackView!
    @IBOutlet var authorizeButton: NSButton!
    
    @IBOutlet var userName: NSTextField!
    @IBOutlet var userSurname: NSTextField!
    @IBOutlet var position: NSTextField!
    @IBOutlet var userLogin: NSTextField!
    @IBOutlet var userRights: NSTextField!
    
    @IBOutlet var contentHideView: BorderedView!
    @IBOutlet var contentView: BorderedView!
    @IBOutlet var tableView: NSTableView!
    
    
    @IBOutlet var permitContainerStack: NSStackView!
    @IBOutlet var permitId: NSTextField!
    @IBOutlet var permitUserName: NSTextField!
    @IBOutlet var permitUserSurname: NSTextField!
    @IBOutlet var permitUserPosition: NSTextField!
    @IBOutlet var permitLevel: NSTextField!
    @IBOutlet var permitDate: NSTextField!
    
    @IBOutlet var cancelPermitButton: NSButton!
    @IBOutlet var resumeSuspendButton: NSButton!
    
    @IBOutlet var newPermitButton: NSButton!
    
    @IBAction func orderControlChanged(_ sender: NSSegmentedControl) {
        orderAscending = sender.selectedSegment == 0
        updateData()
    }
    @IBAction func sortKeyControlChanged(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 1: sortingKey = "title"
        case 2: sortingKey = "journal"
        case 3: sortingKey = "keywords"
        case 4: sortingKey = "annotation"
        case 5: sortingKey = "status"
        case 6: sortingKey = "date"
        default: sortingKey = "id"
        }
        updateData()
    }
    
    @IBAction func resumeSuspendPermit(_ sender: NSButton) {
        if selectedPaper!.status == 0 {
            selectedPaper!.status = 1
        } else {
            selectedPaper!.status = 0
        }
        
        do {
            try context.save()
            updateData()
        } catch {
            presentAlert(title: "Ошибка", description: "", style: .critical)
        }
    }
    @IBAction func cancelPermit(_ sender: NSButton) {
        selectedPaper!.status = 2
        do {
            try context.save()
            updateData()
        } catch {
            presentAlert(title: "Ошибка", description: "", style: .critical)
        }
    }

    private var showOnlyMine = false
    private var sortingKey = "id"
    private var orderAscending = true
    private lazy var permits: [Paper] = {
        getAllPermits()
    }()
    private var selectedPaper: Paper? = nil
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    
    private func getAllPermits() -> [Paper] {
        let request: NSFetchRequest<Paper> = Paper.fetchRequest()
        if let user = PersistentStore.shared.currentUser, showOnlyMine {
            request.predicate = NSPredicate(format: "user.id == %@", "\(user.id!)")
        }
        request.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: orderAscending)]
        return (try? context.fetch(request)) ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if PersistentStore.shared.currentUser == nil {
            cleanData()
        } else {
            loadData()
        }

    }

    override func viewDidAppear() {
        tableView.reloadData()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "newId", let newPermitVC = segue.destinationController as? NewPermitController {
            newPermitVC.onPermitCreation = { [unowned self] in
                self.updateData()
            }
            newPermitVC.onDisappear = { [unowned self] in
                self.updateData()
            }
        } else if (segue.identifier == "showAuthController") {
            let authVC = segue.destinationController as! AuthorizationController
            authVC.onLogin = { [unowned self] in
                self.loadData()
            }
        } else if (segue.identifier == "editCurrentPaper") {
            let paperVC = segue.destinationController as! NewPermitController
            paperVC.currentPaper = selectedPaper
            paperVC.onDisappear = { [unowned self] in
                self.updateData()
            }
        }
    }
    
    // MARK: Data
    
    private func displayCurrentPermit() {
        guard let paper = selectedPaper else {
            permitContainerStack.isHidden = true
            return
        }
        permitContainerStack.isHidden = false
        permitId.stringValue = "\(paper.id!)"
        permitUserName.stringValue = "\(paper.author!.name!)"
        permitUserSurname.stringValue = "\(paper.author!.surname!)"
        permitUserPosition.stringValue = "\(paper.author!.position!)"
        permitLevel.stringValue = "\(paper.status)"
        permitDate.stringValue = dateFormatter.string(from: paper.date!)
        
        if PersistentStore.shared.currentUser!.isAdmin && paper.status == 0 {
            resumeSuspendButton.isHidden = false
            if paper.status == 0 {
                resumeSuspendButton.title = "Снять"
            } else {
                resumeSuspendButton.title = "Восстановить"
            }
        } else {
            resumeSuspendButton.isHidden = true
        }

        if PersistentStore.shared.currentUser!.isAdmin || selectedPaper!.author!.id == PersistentStore.shared.currentUser!.id {
            cancelPermitButton.isHidden = false
        } else {
            cancelPermitButton.isHidden = true
        }
        
    }
    
    private func updateData() {
        permits = getAllPermits()
        displayCurrentPermit()
        tableView.reloadData()
    }
    
    private func loadData() {
        authorizeButton.isHidden = true
        userInfoStackView.isHidden = false
        contentHideView.isHidden = true
        contentView.isHidden = false
        
        let user = PersistentStore.shared.currentUser!
        userName.stringValue = user.name!
        userSurname.stringValue = user.surname!
        userLogin.stringValue = user.login!
        position.stringValue = user.position!
        userRights.stringValue = user.isAdmin ? "Админ" : "Пользователь"

        updateData()
    }
    
    private func cleanData() {
        authorizeButton.isHidden = false
        userInfoStackView.isHidden = true
        contentHideView.isHidden = false
        contentView.isHidden = true
    }
    
    // MARK: Actions

    @IBAction func logout(_ sender: NSButton) {
        cleanData()
    }
    

}


extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let i = permits.count
        return i
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "permitCell"), owner: nil) as? NSTableCellView
        let permit = permits[row]

        if (tableColumn == tableView.tableColumns[0]) {
            view?.textField?.stringValue = "\(permit.id!)"
        } else if (tableColumn == tableView.tableColumns[1]) {
            view?.textField?.stringValue = "\(permit.title!)"
        } else if (tableColumn == tableView.tableColumns[2]) {
            view?.textField?.stringValue = "\(permit.journal!)"
        } else if (tableColumn == tableView.tableColumns[3]) {
            view?.textField?.stringValue = "\(permit.keywords!)"
        } else if (tableColumn == tableView.tableColumns[4]) {
            view?.textField?.stringValue = "\(permit.annotation ?? "")"
        } else if (tableColumn == tableView.tableColumns[5]) {
            switch permit.status {
            case 0:
                view?.textField?.stringValue = "Не опубликовано"
            case 1:
                view?.textField?.stringValue = "Опубликовано"
            case 2:
                view?.textField?.stringValue = "Свяно с публикации"
            default:
                break
            }
        } else if (tableColumn == tableView.tableColumns[6]) {
            view?.textField?.stringValue = dateFormatter.string(from: permit.date!)
        }
        
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        selectedPaper = permits[secure: selectedRow]
        displayCurrentPermit()
    }
    
}
