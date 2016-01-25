//
//  ViewController.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit

import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fbButtonPressed (sender: UIButton) {
        let fbLogin = FBSDKLoginManager()
        
        fbLogin.logInWithReadPermissions(["email"], fromViewController: self) { (fbResult: FBSDKLoginManagerLoginResult!, fbError: NSError!) -> Void in
            if fbError != nil {
                print("Facebook login failed", fbError.debugDescription)
            } else {
                let access_token = FBSDKAccessToken.currentAccessToken().tokenString
                print("Logged in with Facebook", access_token)
            }
        }
    }
}

