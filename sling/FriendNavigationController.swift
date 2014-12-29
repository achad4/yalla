//
//  FriendNavigationController.swift
//  sling
//
//  Created by De Heras on 2014-12-28.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit

class FriendNavigationController: UINavigationController {
    
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
