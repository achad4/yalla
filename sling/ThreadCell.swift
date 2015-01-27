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
    var isFollowing : Bool = false
    
    @IBOutlet weak var tableCell: UIView!
    @IBOutlet weak var followMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var preview: UILabel!
    
    func follow() {
        
        var query:PFQuery = PFQuery(className: "Thread")
        var threadsFollowing : NSMutableArray = NSMutableArray()
        query.whereKey("follower", equalTo: PFUser.currentUser())
        
        var count : Int = 0;
        query.findObjectsInBackgroundWithBlock {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                self.isFollowing = false
                for object in objects{
                    if(object.objectId == self.thread.objectId) {
                        self.isFollowing = true
                    }
                }
                var followRelation : PFRelation = self.thread.relationForKey("follower")
                if(self.isFollowing == false) {
                    self.followMessage.text = " +"
                    followRelation.addObject(PFUser.currentUser())
                    self.thread.saveInBackgroundWithTarget(nil, selector: nil)
                } else {
                    self.followMessage.text = " –"
                    followRelation.removeObject(PFUser.currentUser())
                    self.thread.saveInBackgroundWithTarget(nil, selector: nil)
                    
                }
            }
            
        }

    }
}