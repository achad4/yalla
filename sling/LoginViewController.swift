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
    
    var screenWidth = UIScreen.mainScreen().bounds.width
    var facebookButton = UIButton()
    
    func loginButton() {

        facebookButton.frame = CGRectMake(0, 0, screenWidth - 60, 50)
        facebookButton.center = CGPointMake(screenWidth*0.5, screenWidth*0.75)
        facebookButton.setTitle("Log In with Facebook", forState: .Normal)
    }
    
    @IBAction func signinTapped(sender: AnyObject) {
        var permissions = ["user_friends"]
        PFFacebookUtils.logInWithPermissions(permissions, block: { (user : PFUser!, error : NSError!) -> Void in
            if(user != nil){
                
                //var verified =  as Bool
                if(user["emailVerified"] == nil){
                    println("here")
                    var alert : UIAlertController = UIAlertController(title: "Almost there!", message: "This app is intended only for Columbia/Barnard students", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                        textField.placeholder = "Univiersity email"
                    })
                    alert.addAction(UIAlertAction(title: "Verify", style: UIAlertActionStyle.Default, handler: {
                        alertAction in
                        var textField = alert.textFields?[0] as? UITextField
                        var emailArray = textField?.text.componentsSeparatedByString("@")
                        if(emailArray?[1] == "columbia.edu" || emailArray?[1] == "barnard.edu"){
                            user["email"] = textField?.text
                            user.saveInBackground()
                            alert.dismissViewControllerAnimated(false, completion: nil)
                        }
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    NSLog("Login successfull")
                    var installation = PFInstallation.currentInstallation()
                    installation["user"] = user
                    installation.saveInBackground()
                    self.populateFacebookInfo(user)
                    self.performSegueWithIdentifier("InitialView@Messages", sender: self)
                }
                
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
            
        })
        /*
        
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
            //PFFacebookUtils.logInWithPermissions(<#permissions: [AnyObject]!#>, block: <#PFUserResultBlock!##(PFUser!, NSError!) -> Void#>)

            /*
            
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
            */
    
        }
       */
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
        self.view.addSubview(facebookButton)
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

