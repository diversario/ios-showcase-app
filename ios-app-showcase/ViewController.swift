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
    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func attemptLogin(sender: MaterialButton) {
        if let email = emailField.text where email != "", let pw = passwordField.text where pw != "" {
            DataService.ds.REF_BASE.authUser(email, password: pw, withCompletionBlock: { err, authData in
                if err != nil {
                    print(err)
                    
                    if err.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.ds.REF_BASE.createUser(email, password: pw, withValueCompletionBlock: { err, result in
                            if err != nil {
                                self.showErrorAlert("Could not create account", msg: "Error")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                print("Email login OK")
                                
                                DataService.ds.REF_BASE.authUser(email, password: pw, withCompletionBlock: { error, authData in
                                    let user = ["provider": authData.provider!, "foo": "bar"]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    } else {
                        self.showErrorAlert("Login failed", msg: "Please check your email and password.")
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.valueForKey(KEY_UID), forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
        } else {
            showErrorAlert("Incomplete data", msg: "Please enter both email and password.")
        }
    }
    
    @IBAction func fbButtonPressed (sender: UIButton) {
        let fbLogin = FBSDKLoginManager()
        
        fbLogin.logInWithReadPermissions(["email"], fromViewController: self) { (fbResult: FBSDKLoginManagerLoginResult!, fbError: NSError!) -> Void in
            if fbError != nil {
                print("Facebook login failed", fbError.debugDescription)
            } else {
                let access_token = FBSDKAccessToken.currentAccessToken().tokenString
                print("Logged in with Facebook", access_token)
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: access_token, withCompletionBlock: { err, authData in
                    if err != nil {
                        print("Firebase facebook login failed", err.debugDescription)
                        self.showErrorAlert("Facebook login failed", msg: "Something went wrong.")
                    } else {
                        print("Firebase Facebook logged in", authData)
                        
                        let user = ["provider": authData.provider!]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        }
    }
    
    func showErrorAlert (title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}

