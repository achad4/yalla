//
//  FriendsSegue.swift
//  sling
//
//  Created by Nick De Heras on 1/11/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKIT

@objc(FriendsSegue)

class FriendsSegue: UIStoryboardSegue {
    
    
    func sceneNamed(identifier : NSString) -> UIViewController{
        var info : NSArray = identifier.componentsSeparatedByString("@")
        var storyBoardName : NSString = info[1] as NSString
        var sceneName : NSString = info[0] as NSString
        var storyBoard : UIStoryboard = UIStoryboard(name: storyBoardName, bundle: nil)
        var scene : UIViewController = storyBoard.instantiateViewControllerWithIdentifier(sceneName) as UIViewController
        return scene
    }
    
    override init!(identifier: String!, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        
        var sourceViewController      = self.sourceViewController as UIViewController
        //var destinationViewController = self.destinationViewController as UIViewController
        var destinationViewController = self.sceneNamed(self.identifier!)
        sourceViewController.navigationController?.pushViewController(destinationViewController, animated: true)
        //sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
    }
}