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
    //var isAnon : Bool
    init(sender : PFObject){
        //messages = NSMutableArray()
        participants = NSMutableArray()
        //messages.addObject(initialMessage)
        self.participants.addObject(sender)
        convo = PFObject(className: "Conversation")
        self.convo.ACL.setPublicWriteAccess(true)
        convo["owner"] = sender
        //isAnon = true
    }
  
    init(convo : PFObject){
        participants = NSMutableArray()
        //isAnon = true
        self.convo = convo
        convo.saveInBackgroundWithTarget(nil, selector: nil)
    }

    func removeRecipient(user : PFObject){
        self.participants.removeObject(user)
    }
    
    func addRecipient(user : PFObject){
        self.participants.addObject(user);
    }
    
    func save(){
        //println(self.convo.objectId)
        for user in participants{
            var participant = convo.relationForKey("participant") as PFRelation
            participant.addObject(user as PFObject);
        }
        //convo["isAnon"] = self.isAnon as NSNumber
        convo.saveInBackgroundWithTarget(nil, selector: nil)
    }
}