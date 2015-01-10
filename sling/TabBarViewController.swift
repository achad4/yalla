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
    
}
