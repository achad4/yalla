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
    var screenHeight = UIScreen.mainScreen().bounds.height
    
    @IBAction func signinTapped(sender: AnyObject) {
        var permissions = ["user_friends"]
        //var permissions = nil
        PFFacebookUtils.logInWithPermissions(permissions, block: { (user : PFUser!, error : NSError!) -> Void in
            if(user != nil){
                
                //var verified =  as Bool
                /*
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
                */
                //else{
                    println("Login successfull")
                    var installation = PFInstallation.currentInstallation()
                    installation["user"] = user
                    installation.saveInBackground()
                    self.populateFacebookInfo(user)
                    self.performSegueWithIdentifier("InitialView@Messages", sender: self)
                //}
                
            }else{
                // The login failed.
                println(error.description)
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failure"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
            
        })

    }
    
    func populateFacebookInfo(user: PFUser) {
        if PFFacebookUtils.isLinkedWithUser(user) {
            FBRequestConnection.startWithGraphPath("me?fields=id,name,picture", completionHandler: {(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if (result != nil) {
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
        
        var filePath = NSBundle.mainBundle().pathForResource("redpanda", ofType: "gif")
        var gif = NSData(contentsOfFile: filePath!)
        
        var webViewBG = UIWebView(frame: self.view.frame)
        webViewBG.loadData(gif, MIMEType: "image/gif", textEncodingName: nil, baseURL: nil)
        webViewBG.userInteractionEnabled = false;
        //webViewBG.center = CGPoint(x: screenWidth*0.3, y: screenHeight*0.5)
        self.view.addSubview(webViewBG)
        
        var filter = UIView()
        filter.frame = self.view.frame
        filter.backgroundColor = UIColor.blackColor()
        filter.alpha = 0.05
        self.view.addSubview(filter)
        
        var welcomeLabel = UILabel(frame: CGRectMake(0, 100, self.view.bounds.size.width, 100))
        welcomeLabel.text = "yalla"
        welcomeLabel.textColor = UIColor.whiteColor()
        welcomeLabel.font = UIFont(name: "AvenirNext-Regular", size: 50)
        welcomeLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(welcomeLabel)
        
        var loginBtn = UIButton(frame: CGRectMake(0, 0, 240, 40))
        loginBtn.center = CGPointMake(screenWidth*0.5, screenHeight*0.5)
        loginBtn.layer.borderColor = UIColor.whiteColor().CGColor
        loginBtn.layer.borderWidth = 2
        loginBtn.tintColor = UIColor.whiteColor()
        loginBtn.setTitle("Login with Facebook", forState: .Normal)
        loginBtn.addTarget(self, action: "signinTapped:", forControlEvents: .TouchUpInside)
        loginBtn.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 20)
        loginBtn.layer.cornerRadius = 7
        self.view.addSubview(loginBtn)
        
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

