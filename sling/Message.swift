//
//  Message.swift
//  sling
//
//  Created by Avi Chad-Friedman on 12/21/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class Message{
    var sender : PFUser;
    var recievers : NSMutableArray;
    var timeCreated : NSDate;
    var text : NSString;
    
    init(text : NSString){
        self.sender = PFUser.currentUser();
        self.timeCreated = NSDate();
        self.text = text;
        recievers = NSMutableArray();
    }
    
    func sendTo(user : PFUser){
        recievers.addObject(user);
    }
    
    
    
}