//
//  TabBarViewController.swift
//  sling
//
//  Created by Evan O'Connor on 1/9/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class TabBarViewController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    
    
        if (PFUser.currentUser() == nil) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            var user = PFUser.currentUser()
        }
    }
    
    @IBAction func onViewTimelinePressed(sender: UIButton)
    {
        var storyboard = UIStoryboard(name: "timeline", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func onFriendsViewPressed(sender: UIButton)
    {
        var storyboard = UIStoryboard(name: "friends", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func onLoginPressed(sender: UIButton)
    {
        var storyboard = UIStoryboard(name: "login", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}
