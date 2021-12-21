//
//  PersistentStore.swift
//  Permits
//
//  Created by Andrew on 5/11/20.
//  Copyright © 2020 Andrew Yakovlev. All rights reserved.
//

import Cocoa

class PersistentStore {
    
    public static var shared = PersistentStore()
    
    private let userLoginKey = "com.andrew-yakovlev.Permits.userLoginKey"
    
    private let defaults = UserDefaults.standard
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    private var _user: User? = nil
    var currentUser: User? {
        set {
            _user = newValue
            defaults.set(newValue?.login, forKey: userLoginKey)
        }
        get {
            if _user == nil {
                if let login = defaults.string(forKey: userLoginKey) {
                    let request: NSFetchRequest<User>  = User.fetchRequest()
                    request.predicate = NSPredicate(format: "login == %@", login)
                    if let user = try? context.fetch(request).first {
                        _user = user
                    }
                }
            }
            return _user
        }
    }
}
