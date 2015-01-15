//
//  TestViewController.swift
//  sling
//
//  Created by Nick De Heras on 1/13/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        recognizer.direction = .Left
        self.view .addGestureRecognizer(recognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onViewMessagesPressed(sender: UIView)
    {
        var storyboard = UIStoryboard(name: "Messages", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func onFeedViewPressed(sender: UIView)
    {
        var storyboard = UIStoryboard(name: "Feed", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func swipeLeft(recognizer : UISwipeGestureRecognizer) {
        
        var storyboard = UIStoryboard(name: "Feed", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}
