//
//  NewItemController.swift
//  Permits
//
//  Created by Andrew on 5/11/20.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Cocoa

class NewPermitController: NSViewController {

    @IBOutlet var statusControl: NSSegmentedControl!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var journalTextField: NSTextField!
    @IBOutlet weak var keywordsTextField: NSTextField!
    @IBOutlet weak var annotationTextField: NSTextField!

    @IBOutlet weak var datePicker: NSDatePicker!
    @IBAction func saveButtonClicked(_ sender: NSButton) {
        saveUser()
    }
    
    var onPermitCreation: (() -> ())? = nil
    
    private var users: [User] = []
    private var selectedUser: User? = nil

    var currentPaper: Paper? = nil
    var onDisappear: (() -> Void)?
        
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    private func getAllUsers() -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    private func saveUser() {
        if let paper = currentPaper {
            paper.date = datePicker.dateValue
            paper.journal = journalTextField.stringValue
            paper.keywords = keywordsTextField.stringValue
            paper.title = titleTextField.stringValue
            paper.annotation = annotationTextField.stringValue

            do {
                try context.save()
                presentAlert(title: "Успешно изменена мета-информация.")
                onPermitCreation?()
                dismiss(self)
            } catch {
                presentAlert(title: "Ошибка.", description: "Не удалось изменить работу.", style: .warning)
            }

            return
        }

        guard !titleTextField.stringValue.isEmpty else {
            presentAlert(title: "Ошибка.", description: "Обязательно укажите название работы.", style: .warning)
            return
        }
        
        let newPaper = Paper(context: context)
        newPaper.id = UUID()
        newPaper.author = selectedUser ?? PersistentStore.shared.currentUser
        newPaper.status = Int16(statusControl.integerValue)
        newPaper.date = datePicker.dateValue
        newPaper.journal = journalTextField.stringValue
        newPaper.keywords = keywordsTextField.stringValue
        newPaper.title = titleTextField.stringValue
        newPaper.annotation = annotationTextField.stringValue

        do {
            try context.save()
            presentAlert(title: "Работа успешно добавлена.")
            onPermitCreation?()
            dismiss(self)
        } catch {
            presentAlert(title: "Ошибка.", description: "Не удалось добавить работу.", style: .warning)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        users = getAllUsers()

        if let paper = currentPaper {
            titleTextField.stringValue = paper.title ?? ""
            journalTextField.stringValue = paper.journal ?? ""
            keywordsTextField.stringValue = paper.keywords ?? ""
            annotationTextField.stringValue = paper.annotation ?? ""
            datePicker.dateValue = paper.date ?? Date()
        }
    }

    override func viewWillDisappear() {
        onDisappear?()
    }
    
}
