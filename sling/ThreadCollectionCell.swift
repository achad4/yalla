//
//  ThreadCollectionCell.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/24/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadCollectionCell : UICollectionViewCell{
    var thread : PFObject!
    var text : String!
    
    @IBAction func threadAction(sender: AnyObject) {
        var reply:PFObject = PFObject(className: "Reply")
        reply["text"] = text
        reply["inThread"] = self.thread as PFObject
        reply["sender"] = PFUser.currentUser()
        reply["score"] = 0
        reply.ACL.setPublicWriteAccess(true)
        reply.saveInBackgroundWithTarget(nil, selector: nil)
        self.thread.saveInBackground()
    }
    
    @IBOutlet weak var threadButton: UIButton!
}