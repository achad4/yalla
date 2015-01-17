//
//  SignupViewController.swift
//  sling
//
//  Created by Evan O'Connor on 1/7/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class SignupViewController : UIViewController {
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBAction func signupTapped(sender: UIButton) {
    
        var username:NSString = txtUsername.text as NSString
        var password:NSString = txtPassword.text as NSString
        var confirm_password:NSString = txtConfirmPassword.text as NSString
    
        // Alert user no username/password was entered
        if ( username.isEqualToString("") || password.isEqualToString("") ) {
    
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
    
        // Alert user that passwords do not match
        } else if ( !password.isEqual(confirm_password) ) {
    
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Passwords do not match"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
    
            var user = PFUser()
            user.username = username
            user.password = password
            //user["email"] = username
    
            user.signUpInBackgroundWithBlock {
                    (succeeded: Bool!, error: NSError!) -> Void in
                if error == nil {
    
                    // Signup succeeded
                    NSLog("sign up success")
                    //self.performSegueWithIdentifier("InitialView@Messages", sender: self)
                } else {
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign up Failed!"
                    alertView.message = "New username required"
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
                    NSLog("user linked with Facebook")
                    self.populateFacebookProfile(user)
                    self.performSegueWithIdentifier("InitialView@Messages", sender: self)
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
    
    func populateFacebookProfile(user: PFUser) {
        if PFFacebookUtils.isLinkedWithUser(user) {
            FBRequestConnection.startWithGraphPath("me?fields=id,name,picture", completionHandler: {(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if (result? != nil) {
                    NSLog("error = \(error)")
                    var resultdict = result as? NSDictionary
                    
                    // Populate profile page with user's Facebook name
                    if let name = resultdict?["name"] as? String {
                        user["realName"] = name
                        user.saveInBackground()
                    }
                    
                    // Populate profile page image view with user's FB profile pic
                    if let picture = resultdict?["picture"] as? NSDictionary {
                        if let data = picture["data"] as? NSDictionary {
                            if let photoURL = data["url"] as? String {
                                let url = NSURL(string: photoURL)
                                if let imageData = NSData(contentsOfURL: url!) {
                                    var userPicFile : PFFile = PFFile(data: imageData)
                                    user["picture"] = userPicFile
                                    user.saveInBackground()
                                }
                            }
                        }
                    }
                } else {
                    //self.usernameLabel.text = user.username
                }
                } as FBRequestHandler)
        }
    }

    
    @IBAction func alreadyUserTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
