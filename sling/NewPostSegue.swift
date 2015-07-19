//
//  NewPostSegue.swift
//  sling
//
//  Created by Nick De Heras on 1/12/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit

@objc(NewPostSegue)

class NewPostSegue: UIStoryboardSegue {
    
    override func perform() {
        
        let sourceViewController      = self.sourceViewController as UIViewController
        let destinationViewController = self.destinationViewController as UIViewController

        
        sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
    }
}