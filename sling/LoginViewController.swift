//
//  LoginViewController.swift
//  sling
//
//  Created by Evan O'Connor on 1/7/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class LoginViewController : UIViewController {
    
    
    var screenWidth = UIScreen.mainScreen().bounds.width
    var screenHeight = UIScreen.mainScreen().bounds.height
    
    @IBAction func signinTapped(sender: AnyObject) {
        let installation = PFInstallation.currentInstallation()
        installation["user"] = user
        installation.saveInBackground()
        self.performSegueWithIdentifier("InitialView@Messages", sender: self)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let filePath = NSBundle.mainBundle().pathForResource("redpanda", ofType: "gif"),
            let gifData = NSData(contentsOfFile: filePath) else {
                return
        }
        
        let webViewBG = UIWebView(frame: self.view.frame)
        webViewBG.loadData(gifData, MIMEType: "image/gif", textEncodingName: "", baseURL: NSURL(string: "http://localhost/")!)
        webViewBG.userInteractionEnabled = false;
        //webViewBG.center = CGPoint(x: screenWidth*0.3, y: screenHeight*0.5)
        self.view.addSubview(webViewBG)
        
        let filter = UIView()
        filter.frame = self.view.frame
        filter.backgroundColor = UIColor.blackColor()
        filter.alpha = 0.05
        self.view.addSubview(filter)
        
        let welcomeLabel = UILabel(frame: CGRectMake(0, 100, self.view.bounds.size.width, 100))
        welcomeLabel.text = "yalla"
        welcomeLabel.textColor = UIColor.whiteColor()
        welcomeLabel.font = UIFont(name: "AvenirNext-Regular", size: 50)
        welcomeLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(welcomeLabel)
        
        let loginBtn = UIButton(frame: CGRectMake(0, 0, 240, 40))
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

