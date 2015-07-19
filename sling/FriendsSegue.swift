//
//  FriendsSegue.swift
//  sling
//
//  Created by Nick De Heras on 1/11/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
//import UIKIT

@objc(FriendsSegue)

class FriendsSegue: UIStoryboardSegue {
    
    
    func sceneNamed(identifier : NSString) -> UIViewController{
        print("scene")
        let info : NSArray = identifier.componentsSeparatedByString("@")
        let storyBoardName : NSString = info[1] as! NSString
        let sceneName : NSString = info[0] as! NSString
        let storyBoard : UIStoryboard = UIStoryboard(name: storyBoardName as String, bundle: nil)
        let scene : UIViewController = storyBoard.instantiateViewControllerWithIdentifier(sceneName as String) as UIViewController
        return scene
    }
    
    override init(identifier: String!, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        
        let sourceViewController      = self.sourceViewController as UIViewController
        let destinationViewController = self.sceneNamed(self.identifier!)
        if(self.identifier == "FriendsView@Friends"){
            let sourceViewController      = self.sourceViewController as! MessagesViewController
            let destinationViewController = self.sceneNamed(self.identifier!) as! FriendParentViewController
            sourceViewController.addedParticipants = true
            sourceViewController.newMessgae = false
            //destinationViewController.convo = sourceViewController.convo
            //destinationViewController.convos.addObject(sourceViewController.convo)
            destinationViewController.messageText = sourceViewController.messageText
            sourceViewController.navigationController?.pushViewController(destinationViewController, animated: true)
        }
        else if(self.identifier == "InitialView@Profile"){
            print("init segue")
            let sourceViewController = self.sourceViewController as! InboxTableViewController
            let destinationViewController = self.sceneNamed(self.identifier!)
            sourceViewController.navigationController?.pushViewController(destinationViewController, animated: true)
        }
        else{
            print("login segue")
            sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
        }
        
    }
}