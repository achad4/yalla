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
    var messages: NSMutableArray
    var participants: NSMutableArray
    init(initialMessage : PFObject, sender : PFObject){
        messages = NSMutableArray()
        participants = NSMutableArray()
        messages.addObject(initialMessage)
        participants.addObject(sender)
        convo = PFObject(className: "Conversation")
    }
    
    func addRecipient(user : PFObject){
        self.participants.addObject(user);
    }
    
    func addMessage(message : PFObject){
        self.messages.addObject(message);
    }
    
    func save(){
        for user in participants{
            var participant = convo.relationForKey("participant")
            participant.addObject(user as PFObject);
        }
        for message in messages{
            convo["message"] = message
        }
        convo.saveInBackgroundWithTarget(nil, selector: nil)
    }
}