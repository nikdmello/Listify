//
//  AppDelegate.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/9/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let categoryVC = CategoryViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Initializes Realm to catch errors
        do {
            _ = try Realm()
        }
        catch {
            print("Fail to initalize Realm, \(error)")
        }
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.nikdmello.Listify" {
            let vc = UIStoryboard(name: "Main", bundle: nil)
            vc.instantiateInitialViewController()
            
            
//            let cat = CategoryViewController()
//            cat.addCategory()
        }
    }

    
}

