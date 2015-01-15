//
//  ThreadBubble.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/8/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadAvatarImageView : UIImageView {
    var reply :PFObject = PFObject(className: "Reply")
    
    override init() {
        super.init()
        self.userInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
    }
    
    func tapped(nizer: UITapGestureRecognizer){
        
        // Query for replies that current user has voted on
        var current = PFUser.currentUser()
        var votedQuery = PFQuery(className: "Reply")
        votedQuery.whereKey("voted", equalTo: current)
        
        votedQuery.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                var currentHasVoted = false
                for object in objects {
            
                    if(object.objectId == self.reply.objectId) {
                        currentHasVoted = true
                    }
                }
                if(!currentHasVoted) {
                    // Allow user to upvote
                    var votedOn = self.reply.relationForKey("voted") as PFRelation
                    votedOn.addObject(current);
                    var score : Int = self.reply["score"] as Int
                    score = score + 1
                    self.reply["score"] = score
                    self.reply.saveInBackgroundWithTarget(nil, selector: nil)
                } else {
                    
                    // User has already voted on this reply
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Voting failed!"
                    alertView.message = "You have already voted on this reply"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(image: UIImage!) {
        super.init(image: image)
        self.userInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
    }
}