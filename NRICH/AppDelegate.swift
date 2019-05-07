//
//  AppDelegate.swift
//  NRICH
//
//  Created by Gregory Weiss on 12/30/18.
//  Copyright © 2018 gergusa04. All rights reserved.
//  added repo on github

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        return true
    }




}

