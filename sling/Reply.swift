//
//  Reply.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/8/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class Reply : NSObject, JSQMessageData {
    /*
    var sender : PFUser;
    var recipients : NSMutableArray;
    var timeCreated : NSDate;
    var text : NSString;
    
    init(text : NSString){
    self.sender = PFUser.currentUser();
    self.timeCreated = NSDate();
    self.text = text;
    recipients = NSMutableArray();
    }
    
    func sendTo(user : PFUser){
    recipients.addObject(user);
    }
    */
    var text_: String
    //var sender_: String
    var senderUser : PFUser?
    var date_: NSDate
    var imageUrl_: String?
    var score : Int
    var _senderDisplayName: String?
    var _senderId: String?
    
    convenience init(text: String?, sender: PFUser?) {
        self.init(text: text, sender: sender, imageUrl: nil, score: 0)
    }
    
    init(text: String?, sender: PFUser?, imageUrl: String?, score: Int) {
        self.text_ = text!
        self.senderUser = sender!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
        self.score = score
        self._senderId = senderUser?.objectId
    }
    
    func text() -> String! {
        return text_;
    }
    func stringScore() -> String!{
        var stringScore : String = toString(self.score)
        return stringScore
    }
    func sender() -> String! {
        return senderUser?.objectForKey("username") as String
    }
    
    func date() -> NSDate! {
        return date_
    }
    
    func imageUrl() -> String? {
        return imageUrl_
    }
    
    func hash() -> UInt {
        return hash()
    }
    
    func senderDisplayName() -> String! {
        return self._senderDisplayName
    }
    
    func senderId() -> String! {
        return self._senderId
    }
    
    
    
    
}