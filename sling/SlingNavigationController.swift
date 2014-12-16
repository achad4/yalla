//
//  SlingNavigationController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 10/17/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import UIKit
import Foundation

class SlingNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var testObject = PFObject(className:"TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithTarget(nil, selector: nil)

        
        self.setNavigationBarHidden(false, animated:true)
        var postButton : UIBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("postQuestion"))
        self.navigationItem.rightBarButtonItem = postButton
    }
    
    func postQuestion(){
        
    }
   
}
