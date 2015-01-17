//
//  MyProfileViewController.swift
//  sling
//
//  Created by Evan O'Connor on 1/9/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class MyProfileViewController : UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        populateFacebookProfile(PFUser.currentUser())
        
    }
    
    func populateFacebookProfile(user: PFUser) {
        if PFFacebookUtils.isLinkedWithUser(user) {
            FBRequestConnection.startWithGraphPath("me?fields=id,name,picture", completionHandler: {(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if (result? != nil) {
                    NSLog("error = \(error)")
                    var resultdict = result as? NSDictionary
                    
                    // Populate profile page with user's Facebook name
                    if let name = resultdict?["name"] as? String {
                        self.usernameLabel.text = name
                        user["realName"] = name
                        user.saveInBackground()
                    }
                    
                    // Populate profile page image view with user's FB profile pic
                    if let picture = resultdict?["picture"] as? NSDictionary {
                        if let data = picture["data"] as? NSDictionary {
                            if let photoURL = data["url"] as? String {
                                let url = NSURL(string: photoURL)
                                if let imageData = NSData(contentsOfURL: url!) {
                                    self.userPhoto.image = UIImage(data: imageData)
                                    var userPicFile : PFFile = PFFile(data: imageData)
                                    user["picture"] = userPicFile
                                    user.saveInBackground()
                                }
                            }
                        }
                    }
                } else {
                    self.usernameLabel.text = user.username
                }
                } as FBRequestHandler)
        }
    }
    
    
    @IBAction func logoutTapped(sender: AnyObject) {
        if(PFUser.currentUser() != nil) {
            PFUser.logOut()
        }
        self.performSegueWithIdentifier("logout", sender: self)
    }
    
    @IBAction func linkFBTapped(sender: UIButton) {
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
    
}


