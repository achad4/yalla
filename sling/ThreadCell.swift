//
//  ThreadCell.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/5/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadCell : UITableViewCell{
    var thread : PFObject = PFObject(className: "Thread")
    
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var topic: UILabel!
    @IBAction func follow(sender: AnyObject) {
        var query:PFQuery = PFQuery(className: "Thread")
        var threadsFollowing : NSMutableArray = NSMutableArray()
        query.whereKey("follower", equalTo: PFUser.currentUser())
        
        var count : Int = 0;
        query.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                var isFollower = false
                for object in objects{
                    if(object.objectId == self.thread.objectId) {
                        isFollower = true
                    }
                    /*
                    let pdf = object as PFObject
                    threadsFollowing.addObject(pdf)
                    */
                }
                var followRelation : PFRelation = self.thread.relationForKey("follower")
                if(isFollower == false) {
                    
                    self.follow.setTitle("Unfollow", forState: UIControlState.Normal)
                    followRelation.addObject(PFUser.currentUser())
                    self.thread.saveInBackgroundWithTarget(nil, selector: nil)
                } else {
                    self.follow.setTitle("Follow", forState: UIControlState.Normal)
                    followRelation.removeObject(PFUser.currentUser())
                    self.thread.saveInBackgroundWithTarget(nil, selector: nil)

                }
            }

        }
      
    }
}