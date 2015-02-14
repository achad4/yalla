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
    var participants: Dictionary<PFObject, Bool>
    //var isAnon : Bool
    init(sender : PFObject){
        //messages = NSMutableArray()
        participants = Dictionary<PFObject, Bool>()
        //messages.addObject(initialMessage)
        //self.participants.addObject(sender)
        convo = PFObject(className: "Conversation")
        self.convo.ACL.setPublicWriteAccess(true)
        convo["owner"] = sender
        //isAnon = true
    }
  
    init(convo : PFObject){
        participants = Dictionary()
        //isAnon = true
        self.convo = convo
        convo.saveInBackgroundWithTarget(nil, selector: nil)
    }

    func removeRecipient(user : PFObject){
        self.participants.removeValueForKey(user)
    }
    
    func addRecipient(user : PFObject, isOwner : Bool){
        self.participants[user] = isOwner
    }
    
    func save(){
        for (user, isOwner) in participants{
            var participant = PFObject(className: "Participant")
            participant.ACL.setPublicWriteAccess(true)
            participant["participant"] = user
            participant["isOwner"] = isOwner as NSNumber
            participant["convo"] = convo
            participant["active"] = false as NSNumber
            participant.saveInBackground()
            //var participant = convo.relationForKey("participant") as PFRelation
            //participant.addObject(user as PFObject);
        }
        //convo["isAnon"] = self.isAnon as NSNumber
        convo.saveInBackgroundWithTarget(nil, selector: nil)
    }
}