//
//  MessagesSegue.swift
//  sling
//
//  Created by Nick De Heras on 1/11/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKIT

@objc(MessagesSegue)

class MessagesSegue: UIStoryboardSegue {
    override func perform() {
        var sourceViewController      = self.sourceViewController as UIViewController
        var destinationViewController = self.sourceViewController as UIViewController
        
        sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil) 
    }
}