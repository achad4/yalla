//
//  Thread.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/5/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class Thread{
    var thread : PFObject
    //var messages: NSMutableArray
    var followers: NSMutableArray
    var topic : String
    var score : Int
    init(sender : PFObject, topic : String){
        //messages = NSMutableArray()
        followers = NSMutableArray()
        //messages.addObject(initialMessage)
        self.followers.addObject(sender)
        self.thread = PFObject(className: "Thread")
        self.thread.ACL.setPublicWriteAccess(true)
        println(topic)
        self.topic = topic
        self.score = 0
    }
    
    func addFollower(user : PFObject){
        self.followers.addObject(user);
    }
    
    func save(){
        //println(self.convo.objectId)
        for user in followers{
            var follower = thread.relationForKey("follower") as PFRelation
            follower.addObject(user as PFObject);
        }
        thread["topic"] = self.topic
        thread["score"] = self.score
        self.thread.saveInBackgroundWithTarget(nil, selector: nil)
    }
}