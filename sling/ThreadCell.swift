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
        println(PFUser.currentUser().objectId)
        var count : Int = 0;
        query.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    count++
                    //println(count)
                    let pdf = object as PFObject
                    threadsFollowing.addObject(pdf)
                }
            }
            
            var followRelation : PFRelation = self.thread.relationForKey("follower")
            if(count == 0){
                println("User wants to follow")
                self.follow.setTitle("Unfollow", forState: UIControlState.Normal)
                followRelation.addObject(PFUser.currentUser())
                self.thread.saveInBackgroundWithTarget(nil, selector: nil)
                
            }
            else{
                println("User wants to unfollow")
                println(self.thread.objectId)
                self.follow.setTitle("Follow", forState: UIControlState.Normal)
                followRelation.removeObject(PFUser.currentUser())
                self.thread.saveInBackgroundWithTarget(nil, selector: nil)
                
            }

        }
      
    }
}