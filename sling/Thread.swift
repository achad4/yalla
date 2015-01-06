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
    init(sender : PFObject, topic : String){
        //messages = NSMutableArray()
        followers = NSMutableArray()
        //messages.addObject(initialMessage)
        self.followers.addObject(sender)
        self.thread = PFObject(className: "Thread")
        println(topic)
        self.topic = topic
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
        self.thread.saveInBackgroundWithTarget(nil, selector: nil)
    }
}