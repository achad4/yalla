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
            //Attempt to log in user
            PFUser.logInWithUsernameInBackground(username, password:password) {
                    (user: PFUser!, error: NSError!) -> Void in
                if(user != nil){
                    // Successful login.
                    NSLog("Login successfull")
                    var installation = PFInstallation.currentInstallation()
                    installation["user"] = user
                    installation.saveInBackground()
                    self.populateFacebookInfo(user)
                    self.performSegueWithIdentifier("InitialView@Messages", sender: self)
                }else{
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
    
    func populateFacebookInfo(user: PFUser) {
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
                    //populate users fbID
                    if let name = resultdict?["id"] as? String {
                        user["fbID"] = name
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(PFUser.currentUser() != nil){
            self.performSegueWithIdentifier("InitialView@Messages", sender: nil)
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

