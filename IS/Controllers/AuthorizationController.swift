//
//  AuthorizationController.swift
//  Permits
//
//  Created by Andrew on 10/10/21.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Cocoa

class AuthorizationController: NSViewController {
    @IBOutlet var signInStackView: NSStackView!
    @IBOutlet var signUpStackView: NSStackView!
    @IBOutlet var proceedButton: NSButton!
    
    @IBOutlet var loginSignInTextField: NSTextField!
    @IBOutlet var passwordSignInTextField: NSSecureTextField!
    
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var surnameTextField: NSTextField!
    @IBOutlet var positionTextField: NSTextField!
    @IBOutlet var loginSignUpTextField: NSTextField!
    @IBOutlet var passwordSignUpTextField: NSSecureTextField!
    @IBOutlet var passwordRepeatTextField: NSSecureTextField!
    
    var currentState: CurrentState = .signIn
    enum CurrentState: Int {
        case signIn = 0, signUp
    }
    
    public var onLogin: (() -> ())? = nil
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        change(state: 0)
    }
    
    // MARK: Data
    
    private func change(state: Int) {
        currentState = CurrentState(rawValue: state)!
        switch currentState {
        case .signIn:
            signInStackView.isHidden = false
            signUpStackView.isHidden = true
            proceedButton.title = "Войти"
        case .signUp:
            signInStackView.isHidden = true
            signUpStackView.isHidden = false
            proceedButton.title = "Зарегистироваться"
        }
    }
    
    private func canProceed() -> Bool {
        switch currentState {
        case .signIn:
            return !(loginSignInTextField.stringValue.isEmpty || passwordSignInTextField.stringValue.isEmpty)
        case .signUp:
            return !(
                nameTextField.stringValue.isEmpty ||
                surnameTextField.stringValue.isEmpty ||
                loginSignUpTextField.stringValue.isEmpty ||
                passwordSignUpTextField.stringValue.isEmpty ||
                passwordRepeatTextField.stringValue.isEmpty ||
                passwordSignUpTextField.stringValue != passwordRepeatTextField.stringValue
            )
        }
    }
    
    private func getUser(with login: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@", login)
        return try? context.fetch(request).first
    }
    
    private func getAllUsers() -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    private func signUp() {
        guard getUser(with: loginSignUpTextField.stringValue) == nil else {
            presentAlert(title: "Ошибка регистрации.", description: "Пользователь с таким логином уже существует", style: .warning)
            return
        }
        
        let isUserFirst = getAllUsers().isEmpty
        
        let newUser = User(context: context)
        newUser.id = UUID()
        newUser.name = nameTextField.stringValue
        newUser.position = positionTextField.stringValue
        newUser.surname = surnameTextField.stringValue
        newUser.login = loginSignUpTextField.stringValue
        newUser.password = passwordSignUpTextField.stringValue.sha256()
        
        // The first user is admin
        newUser.isAdmin = isUserFirst
        
        do {
            try context.save()
            loginSignInTextField.stringValue = newUser.login!
            passwordSignInTextField.stringValue = passwordSignUpTextField.stringValue
            presentAlert(title: "Успешная регистрация!")
        } catch {
            presentAlert(title: "Ошибка регистрации.", description: "Не удалось сохранить пользователя.", style: .critical)
        }
    }
    
    private func signIn() {
        guard let user = getUser(with: loginSignInTextField.stringValue) else {
            presentAlert(title: "Ошибка авторизации.", description: "Пользователя с таким логином не существует.", style: .warning)
            return
        }
        guard user.password == passwordSignInTextField.stringValue.sha256() else {
            presentAlert(title: "Ошибка авторизации.", description: "Неверный пароль.", style: .warning)
            return
        }
        presentAlert(title: "Успешная авторизация!")
        PersistentStore.shared.currentUser = user
        onLogin?()
        dismiss(self)
    }
    
    private func proceed() {
        switch currentState {
        case .signIn:
            signIn()
        case .signUp:
            signUp()
        }
    }
        
    // MARK: Actions
    
    @IBAction func segmentControlValueChanged(_ sender: NSSegmentedControl) {
        change(state: sender.selectedSegment)
    }
    @IBAction func proceedButtonClicked(_ sender: NSButton) {
        if canProceed() {
            proceed()
        } else {
            presentAlert(title: "Ошибка", description: "Возможно, вы заполнили не все поля или заполнили их неправильно.", style: .warning)
        }
    }
    
}
