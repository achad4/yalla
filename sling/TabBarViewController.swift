//
//  TabBarViewController.swift
//  sling
//
//  Created by Evan O'Connor on 1/9/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class TabBarViewController : UITabBarController {
    
    /*
    let messages = UITabBarItem(title: "Messages", image: nil, tag: 1)
    let friends  = UITabBarItem(title: "Friends", image: nil, tag: 2)
    let profile  = UITabBarItem(title: "Profile", image: nil, tag: 3)
    let more     = UITabBarItem(title: "More", image: nil, tag: 4)
    */ 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var messagesStoryboard: UIStoryboard = UIStoryboard(name: "Messages", bundle: nil)
        var initialViewController: UIViewController = messagesStoryboard.instantiateViewControllerWithIdentifier("MessagesView") as UIViewController
        
        var viewsInTBC = self.tabBarController?.viewControllers
        viewsInTBC?.append(initialViewController)
        self.tabBarController?.viewControllers = viewsInTBC
        
        self.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    
    
        if (PFUser.currentUser() == nil) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            var user = PFUser.currentUser()
        }
    }
    
    @IBAction func onViewMessagesPressed(sender: UIButton)
    {
        var storyboard = UIStoryboard(name: "Messages", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func onFeedViewPressed(sender: UIButton)
    {
        var storyboard = UIStoryboard(name: "Feed", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }


    
}
