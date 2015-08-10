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
    
    var confirmationCode : String?
    var phoneNumber : String?
    var userName : String?
    
    
    func showAlert(title: String, message: String) {
        return UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: NSLocalizedString("alertOK", comment: "OK")).show()
    }
    
    func signUpTapped(sender: AnyObject) {
        if(PFUser.currentUser() != nil){
            let installation = PFInstallation.currentInstallation()
            installation["user"] = PFUser.currentUser()
            installation.saveInBackground()
            self.performSegueWithIdentifier("InitialView@Messages", sender: self)
        }else{
            self.signUpWithPhoneNumber()
        }
    }
    
    func signUpWithPhoneNumber(){
        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .Alert)
        let signUpAction = UIAlertAction(title: "Signup Hoe", style: .Default) { (_) in
            let usernameTextField = alertController.textFields![1] as UITextField
            let phoneNumberTextField = alertController.textFields![0] as UITextField
            self.sendCode(usernameTextField.text!, phoneNumber: phoneNumberTextField.text!)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        signUpAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "###-###-####"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                signUpAction.enabled = textField.text != ""
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "username"
        }
        
        alertController.addAction(signUpAction)
        
        self.presentViewController(alertController, animated: true) {
        }

    }
    
    func sendCode(userName:String, phoneNumber:String){
        
        self.phoneNumber = phoneNumber
        self.userName = userName
        let preferredLanguages = NSBundle.mainBundle().preferredLocalizations
        let preferredLanguage = preferredLanguages[0] 
        
        if phoneNumber != "" {
            if (preferredLanguage == "en" && phoneNumber.characters.count != 10)
                || (preferredLanguage == "ja" && phoneNumber.characters.count != 11) {
                    showAlert("Phone Login", message: NSLocalizedString("warningPhone", comment: "You must enter a 10-digit US phone number including area code."))
                    //return step1()
            }
            
            self.editing = false
            let params = ["phoneNumber" : phoneNumber, "language" : preferredLanguage]
            PFCloud.callFunctionInBackground("sendCode", withParameters: params) {
                (response: AnyObject?, error: NSError?) -> Void in
                self.editing = true
                if let error = error {
                    var description = error.description
                    if description.characters.count == 0 {
                        description = NSLocalizedString("warningGeneral", comment: "Something went wrong.  Please try again.") // "There was a problem with the service.\nTry again later."
                    } else if let message = error.userInfo["error"] as? String {
                        description = message
                    }
                    self.showAlert("Login Error", message: description)
                    //return self.step1()
                }
                return self.confirmCode()
            }
        } else {
            if let text = self.confirmationCode{
                let code = Int(text)
                if text.characters.count == 4 {
                    return doLogin(phoneNumber, code: code!)
                }
            }
            
            
            showAlert("Code Entry", message: NSLocalizedString("warningCodeLength", comment: "You must enter the 4 digit code texted to your phone number."))
        }
        
        
    }
    
    func confirmCode() {
        
        let alertController = UIAlertController(title: "Confirm", message: "Message", preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            let confirmationCodeTextField = alertController.textFields![0] as UITextField
            self.confirmationCode = confirmationCodeTextField.text
            
            if let intCode = Int(self.confirmationCode!){
                self.doLogin(self.phoneNumber!, code: intCode)
            }
            alertController.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
        confirmAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "####"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                confirmAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(confirmAction)
        
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    func doLogin(phoneNumber: String, code: Int) {
        self.editing = false
        let params = ["userName": self.userName!, "phoneNumber": phoneNumber, "codeEntry": code] as [NSObject:AnyObject]
        PFCloud.callFunctionInBackground("logIn", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            if let description = error?.description {
                self.editing = true
                return self.showAlert("Login Error", message: description)
            }
            if let token = response as? String {
                PFUser.becomeInBackground(token) { (user: PFUser?, error: NSError?) -> Void in
                    if error != nil {
                        self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something happened while trying to log in.\nPlease try again."))
                        self.editing = true
                        //return self.step1()
                    }
                    return self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                self.editing = true
                self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something went wrong.  Please try again."))
                //return self.step1()
            }
        }
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
        loginBtn.setTitle("Login", forState: .Normal)
        loginBtn.addTarget(self, action: "signUpTapped:", forControlEvents: .TouchUpInside)
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

