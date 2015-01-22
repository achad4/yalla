//
//  LoginViewController.swift
//  sling
//
//  Created by Evan O'Connor on 1/7/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class LoginViewController : UIViewController {
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBAction func signinTapped(sender: AnyObject) {
        var username:NSString = txtUsername.text
        var password:NSString = txtPassword.text
    
        // Alert user no username/password was entered
        if ( username.isEqualToString("") || password.isEqualToString("") ) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
    
        } else {
    
            // Attempt to log in user
            PFUser.logInWithUsernameInBackground(username, password:password) {
                    (user: PFUser!, error: NSError!) -> Void in
                if user != nil {
                    // Successful login.
                    NSLog("Login successfull")
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    //if(PFFacebookUtils.isLinkedWithUser(user)){
                    var installation = PFInstallation.currentInstallation()
                    installation["user"] = user
                    installation.saveInBackground()
                    self.performSegueWithIdentifier("InitialView@Messages", sender: self)
                    //}
                    //else{
                    /*
                        NSLog("Login failed")
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "Almost there! Link your account with Facebook to start using yalla"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    */
                    //}
                } else {
                    // The login failed.
                    NSLog("Login failed")
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign in Failed!"
                    alertView.message = "Connection Failure"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }
    
        }
    
    }
    
    @IBAction func linkFacebook(sender: AnyObject) {
        var user = PFUser.currentUser()
        if !PFFacebookUtils.isLinkedWithUser(user) {
            PFFacebookUtils.linkUser(user, permissions:nil, {
                (succeeded: Bool, error: NSError!) -> Void in
                if (succeeded) {
                    NSLog("user logged in with Facebook!")
                }
            })
        } else {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Failed to Link Facebook!"
            alertView.message = "Your account is already linked"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if(PFUser.currentUser() != nil){
            println(PFUser.currentUser().username)
            self.performSegueWithIdentifier("InitialView@Messages", sender: self)
        }
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

