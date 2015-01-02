//
//  Conversation.swift
//  sling
//
//  Created by Evan O'Connor on 12/23/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class Conversation{
    var convo : PFObject
    //var messages: NSMutableArray
    var participants: NSMutableArray
    init(sender : PFObject){
        //messages = NSMutableArray()
        participants = NSMutableArray()
        //messages.addObject(initialMessage)
        self.participants.addObject(sender)
        convo = PFObject(className: "Conversation")
    }
    
    func addRecipient(user : PFObject){
        self.participants.addObject(user);
    }
    
    func save(){
        //println(self.convo.objectId)
        for user in participants{
            println("Selected user ID: "+user.objectId!)
            var participant = convo.relationForKey("participant") as PFRelation
            participant.addObject(user as PFObject);
        }
        convo.saveInBackgroundWithTarget(nil, selector: nil)
    }
}